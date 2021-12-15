# -*- coding: utf-8 -*-
import scrapy
import random
import json
import sentry_sdk
from sentry_sdk import capture_message
import warnings

from urllib.parse import urljoin, urlparse
from alegreme.items import Event, EventOrganizerLoader
from alegreme.event_eb import EventEB
from scrapy_splash import SplashRequest
from scrapy.loader import ItemLoader
from itemloaders.processors import Join
from alegreme.services.proxy_service import ProxyService

sentry_sdk.init(
    "https://REMOVED@o259251.ingest.sentry.io/1454550",
    traces_sample_rate=1.0,
)


user_agents = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:66.0) Gecko/20100101 Firefox/66.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.1 Safari/605.1.15",
    "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:67.0) Gecko/20100101 Firefox/67.0",
    "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36",
]

random.shuffle(user_agents)

# Facebook scripts

parse_facebook_events_page_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:set_viewport_size(411, 823)
        splash:on_request(function(request)
            if string.find(request.url, ".css") ~= nil then
                request.abort()
            end
        end)

        splash:set_custom_headers({
            ["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36",
            ["cache-control"] = "max-age=0",
            ["upgrade-insecure-requests"] = "1",
            ["accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
            ["accept-enconding"] = "gzip, deflate, br",
            ["accept-language"] = "en;q=0.9",
            ["content-language"] = "en-US",
            ["cookie"] = "locale=en_US"
        })

        assert(splash:go(splash.args.url))

        assert(splash:wait(1))
        splash.scroll_position = {y=1000}
        assert(splash:wait(2))
        splash.scroll_position = {y=2000}

        local loadindIndicator = splash:select('.centeredIndicator')
        local emptyEventsInfo = splash:select('._52jd')

        if emptyEventsInfo == nil and loadindIndicator then
            result, error = splash:wait_for_resume([[
                        function main(splash) {
                            var checkExist = setInterval(function() {
                                if (!document.querySelector(".centeredIndicator")) {
                                    clearInterval(checkExist);
                                    splash.resume();
                                }
                            }, 2000);
                        }
                    ]], 10)
        end  

        return splash:html()
    end
"""

parse_facebook_place_page_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:set_viewport_size(411, 823)
        splash:on_request(function(request)
            request:set_http2_enabled(true)
            if string.find(request.url, ".css") ~= nil then
                --request.abort()
            end
        end)

        splash:set_custom_headers({
            ["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36",
            ["cache-control"] = "max-age=0",
            ["upgrade-insecure-requests"] = "1",
            ["accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
            ["accept-enconding"] = "gzip, deflate, br",
            ["accept-language"] = "en;q=0.9",
            ["content-language"] = "en-US",
            ["cookie"] = "locale=en_US"
        })

        local num_scrolls = 20
        local scroll_delay = 2

        assert(splash:go(splash.args.url))
        splash:wait(2)

        for i = 1, num_scrolls do
    		splash.scroll_position = {0, 5000 * i}
            splash:wait(scroll_delay)
        end       

        return splash:html()
    end
"""

parse_facebook_event_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:on_request(function(request)
            if string.find(request.url, ".css") ~= nil then
                request.abort()
            end
        end)

        splash:set_custom_headers({
                ["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36",
                ["cache-control"] = "max-age=0",
                ["upgrade-insecure-requests"] = "1",
                ["accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
                ["accept-enconding"] = "gzip, deflate, br",
                ["accept-language"] = "en;q=0.9",
                ["content-language"] = "en-US",
                ["cookie"] = "locale=en_US"
            })
        assert(splash:go(splash.args.url))
        assert(splash:wait(3))
        splash.scroll_position = {y=1000}

        local signupForm = splash:select('._585r._50f4')

        if signupForm == nil then
            result, error = splash:wait_for_resume([[
                        function main(splash) {
                            var checkExist = setInterval(function() {
                                if (document.querySelector("._63ew").innerText && document.querySelector("._2ycp._5xhk").innerText && document.querySelector('._63ew').innerText) {
                                    clearInterval(checkExist);
                                    splash.resume();
                                }
                            }, 2000);
                        }
                    ]], 30)
        end

        return splash:html()
    end
"""

# Sympla scripts

parse_sympla_events_page_script = """
    function main(splash, args)
        splash.js_enabled = false
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:on_request(function(request)
            if string.find(request.url, ".css") ~= nil or
               string.find(request.url, ".woff2") ~= nil or
               string.find(request.url, "rdstation") ~= nil or
               string.find(request.url, "google-analytics") ~= nil or
               string.find(request.url, "doubleclick") ~= nil then
                request.abort()
            end
        end)

        splash:set_custom_headers({
            ["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36",
            ["cache-control"] = "no-cache",
            ["upgrade-insecure-requests"] = "1",
            ["accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
            ["accept-enconding"] = "gzip, deflate, br",
            ["cookie"] = "_ga=GA1.3.1192868265.1633133384; _gid=GA1.3.1537327894.1633133384; _gcl_au=1.1.1374548467.1633133387; _rd_wa_id.9f9e=a422556f-f593-5c26-b48a-556ef3a31ea5.1633133389.1.1633133389.1633133389.6fb970ee-d89d-52c0-a1bc-4cd6a8ba1933; _rd_wa_ses.9f9e=*; _rd_wa_first_session.9f9e=https%3A%2F%2Fsite.bileto.sympla.com.br%2F; pxcts=0f0d0680-2315-11ec-aebf-6bc6061c1bf7; _pxvid=0f0cbcde-2315-11ec-a1a3-4a6142556e4e; __trf.src=encoded_eyJmaXJzdF9zZXNzaW9uIjp7InZhbHVlIjoiaHR0cHM6Ly9zaXRlLmJpbGV0by5zeW1wbGEuY29tLmJyLyIsImV4dHJhX3BhcmFtcyI6e319LCJjdXJyZW50X3Nlc3Npb24iOnsidmFsdWUiOiJodHRwczovL3NpdGUuYmlsZXRvLnN5bXBsYS5jb20uYnIvIiwiZXh0cmFfcGFyYW1zIjp7fX0sImNyZWF0ZWRfYXQiOjE2MzMxMzMzODk3NTB9; _gat_UA-24958859-7=1; _px3=9d62d5e5e7fc27545a39aca656ee2a27623b1437b354274d015c49aaf236de3e:MEAyjjbt4Psa1bLOIAiaejG32DTCYL3v29hefWBscrqeQyz7iU7WoyuOPep8zDuylYLfB/gRvD9HYD3XHr2myw==:1000:d0DfrwNc+F1quq5L5CtWvahiAlsJgmu5FD79Hy1e/e8NrYldyR/W7JhPqdTMca3chGfWuNT8onoVGcN5bC8f2Q2SyKKCRN95nuWSE9tRxXsmWvRN++h6AaA6ODmWFmZcHA0BV+mn/Fyaue/G1L7INmzg002uZCiFIEJZYcXL9ncrta7AgCo5cNtWDAiskpaT1CfrwZiuf8oqcGLmnZ4CuQ==; _fbp=fb.2.1633133390503.835090510; _pxde=21567e955a475eed81a0a614493076cbf8308a4b8206e205851611a8c53ebe50:eyJ0aW1lc3RhbXAiOjE2MzMxMzM0MTM4Nzh9"
        })

        splash:go(splash.args.url)
        splash.scroll_position = {y=2000}
    
        assert(splash:wait(5))

        return splash:html()
    end
"""

parse_sympla_event_api_script = """
    function main(splash, args)
        api_key = nil

        splash.js_enabled = true
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:on_request(function(request)
            if string.find(request.url, ".css") ~= nil or
               string.find(request.url, ".woff2") ~= nil or
               string.find(request.url, "rdstation") ~= nil or
               string.find(request.url, "google-analytics") ~= nil or
               string.find(request.url, "criteo") ~= nil or
               string.find(request.url, "facebook") ~= nil or
               string.find(request.url, "doubleclick") ~= nil then
                request.abort()
            end
            if string.find(request.url, "bileto.sympla.com.br/api/v1/events") ~= nil then
                api_key = request.headers['x-api-key']
                api_url = request.url
            end
        end)

        splash:set_custom_headers({
            ["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36",
            ["cache-control"] = "no-cache",
            ["upgrade-insecure-requests"] = "1",
            ["accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
            ["accept-enconding"] = "gzip, deflate, br",
            ["cookie"] = '_ga=GA1.3.869050002.1628010327; _gid=GA1.3.492902586.1628010327; _gat_gtag_UA_24958859_7=1; _gcl_au=1.1.1359478704.1628010328; _gat_UA-24958859-7=1; __trf.src=encoded_eyJmaXJzdF9zZXNzaW9uIjp7InZhbHVlIjoiaHR0cHM6Ly9zaXRlLmJpbGV0by5zeW1wbGEuY29tLmJyLyIsImV4dHJhX3BhcmFtcyI6e319LCJjdXJyZW50X3Nlc3Npb24iOnsidmFsdWUiOiJodHRwczovL3NpdGUuYmlsZXRvLnN5bXBsYS5jb20uYnIvIiwiZXh0cmFfcGFyYW1zIjp7fX0sImNyZWF0ZWRfYXQiOjE2MjgwMTAzMjc4MzN9; _fbp=fb.2.1628010328029.603235374; pxcts=004519b1-f47d-11eb-a0d6-efe0bc58b32f; _pxvid=0044cbfc-f47d-11eb-901e-0242ac120008; _pxde=510301da31c3d21fda909e7a04ed23a7f3810f3cf793ceba71391ab8fdbeb530:eyJ0aW1lc3RhbXAiOjE2MjgwMTAzMjg2NDB9; rdtrk={"id":"912f7e43-4c07-4156-a0a4-794f6ee97c1f"}'
        })

        assert(splash:go(splash.args.url))
        
        result, error = splash:wait_for_resume([[
                        function main(splash) {
                            var checkExist = setInterval(function() {
                                if (document.querySelector("[class='summary style-scope event-page']").querySelector("h1").innerText) {
                                    clearInterval(checkExist);
                                    splash.resume();
                                }
                            }, 2000);
                        }
                    ]], 30)


        maxwait = 30
        local i = 0
        while not api_key do
            if i == maxwait then
                break
            end
            i = i + 1
            splash:wait(1)
        end

        return {
            api_key = api_key,
            api_url = api_url
        }
    end
"""


# Eventbrite scripts

parse_eventbrite_event_script = """
    function main(splash, args)
        splash.js_enabled = false
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:on_request(function(request)
            if string.find(request.url, ".css") ~= nil then
                --request.abort()
            end
        end)

        splash:set_custom_headers({
                ["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36",
                ["cache-control"] = "max-age=0",
                ["upgrade-insecure-requests"] = "1",
                ["accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
                ["accept-enconding"] = "gzip, deflate, br",
                ["cookie"] = "location={%22slug%22:%22brazil--porto-alegre--8307%22%2C%22place_id%22:%22101960525%22%2C%22latitude%22:-30.099115%2C%22longitude%22:-51.179506%2C%22place_type%22:%22locality%22%2C%22current_place%22:%22Porto%20Alegre%22%2C%22current_place_parent%22:%22RS%2C%20Brasil%22%2C%22is_online%22:false}"
            })
        assert(splash:go(splash.args.url))
        assert(splash:wait(3))
        splash.scroll_position = {y=500}

        return splash:html()
    end
"""


class EventSpider(scrapy.Spider):
    http_user = "alegreme"
    http_pass = "ve97K8bCwNkNgQSqvMkYRryMG4MQuQGU"

    name = "event"

    custom_settings = {
        "ITEM_PIPELINES": {"alegreme.pipelines.EventPipeline": 400},
        "CLOSESPIDER_ITEMCOUNT": 1000,
        "CLOSESPIDER_PAGECOUNT": 1500,
        "DEPTH_LIMIT": 3,
        "DOMAIN_DEPTHS": {
            "facebook.com": 2,
            "sympla.com.br": 3,
            "eventbrite.com.br": 2,
        },
    }

    allowed_domains = ["facebook.com", "sympla.com.br", "eventbrite.com.br"]

    start_pages = [
        "https://www.eventbrite.com.br/fe/",
        "https://www.sympla.com.br/api/v1/search",
        "https://site.bileto.sympla.com.br/farolsantanderpoa",
        "https://site.bileto.sympla.com.br/opiniao",
        "https://m.facebook.com/events/discovery/?suggestion_token=%7B%22city%22%3A%22111072692249998%22%7D",
    ]

    """  organizers_ids = [
        ["ksacentro", "4569602"],
        ["doneadventuredone", "9290306"],
        ["CHCSantaCasa", "2984476"],
        ["cortexbar", "293710"],
        ["bluelounge", "10514303"],
        ["clubegloria", "10316441"],
        ["cuckopoa", "253072"],
        ["tietafesta", "1892943"],
    ] """

    def start_requests(self):
        self.log("INITIALIZING...")
        self.log("UA: %s" % user_agents[0])

        for page in self.start_pages:

            if "api/v1/search" in page:
                # for organizer_id in self.organizers_ids:
                data = {
                    "service": "/v5/search",
                    "params": {
                        "q": "",
                        "collections": "",
                        "range": "",
                        "need_pay": "",
                        "sort": "location-score",
                        "include_organizers": 0,
                        "only": "name,start_date,end_date,location,url",
                        "components_limit": "4",
                        "components_page": "1",
                        "include_response": "true",
                        "limit": "100",
                        "location": "-30.03405,-51.21363",
                        "matrix_category": "city",
                        "matrix_uuid": "porto-alegre",
                        "component_uuid": "todos-eventos",
                        "page": 1,
                    },
                }
                yield scrapy.Request(
                    page,
                    method="POST",
                    callback=self.parse_search_api_event,
                    body=json.dumps(data),
                    headers={"Content-Type": "application/json"},
                )

            if "bileto.sympla" in page:
                yield SplashRequest(
                    url=page,
                    callback=self.parse_sympla_iframe,
                    endpoint="execute",
                    args={
                        "timeout": 300,
                        "lua_source": parse_sympla_events_page_script,
                        "ua": user_agents[0],
                    },
                )

            if "eventbrite.com.br/fe/" in page:
                cookie_location = '{"slug":"brazil--porto-alegre--8307","place_id":"101960525","latitude":-30.099115,"longitude":-51.179506,"place_type":"locality","current_place":"Porto Alegre","current_place_parent":"RS, Brasil","is_online":false}'

                yield scrapy.Request(
                    page,
                    callback=self.parse_eventbrite_event_api,
                    cookies={"location": cookie_location},
                )

            if "/eventos/porto-alegre-rs" in page:
                yield SplashRequest(
                    url=page,
                    callback=self.parse_sympla_page,
                    endpoint="execute",
                    args={
                        "timeout": 300,
                        "lua_source": parse_sympla_events_page_script,
                        "ua": user_agents[0],
                    },
                )

            if "discovery" in page:
                yield SplashRequest(
                    url=page,
                    callback=self.parse_facebook_page,
                    endpoint="execute",
                    args={
                        "timeout": 300,
                        "lua_source": parse_facebook_place_page_script,
                        "ua": user_agents[0],
                    },
                )

    def parse_facebook_page(self, response):
        title_page = response.xpath("//title/text()").get()

        events_in_page = response.xpath(
            '//a[contains(@href, "events/") and contains(@class, "_49z0")]/@href'
        )

        if not events_in_page:
            self.log(str(title_page) + " PAGE WITHOUT EVENTS")
            capture_message(str(title_page) + " PAGE WITHOUT EVENTS")
        else:
            self.log(
                str(title_page) + " PAGE WITH " + str(len(events_in_page)) + " EVENTS"
            )

        for event_link in events_in_page.getall():
            if event_link is not None:
                yield SplashRequest(
                    url=urljoin("https://www.facebook.com/", urlparse(event_link).path),
                    callback=self.parse_facebook_event,
                    endpoint="execute",
                    args={
                        "timeout": 600,
                        "lua_source": parse_facebook_event_script,
                        "ua": user_agents[0],
                    },
                )
            else:
                pass

    def parse_facebook_event(self, response):
        event_loader = ItemLoader(item=Event(), response=response)
        event_loader.add_value("source_url", response.url)
        event_loader.add_value("source_name", "facebook")
        event_loader.add_xpath("name", "//title[1]/text()")
        event_loader.add_xpath(
            "cover_url",
            '//*[contains(@class, "uiScaledImageContainer")]//*[contains(@class, "scaledImageFit")]/@src',
        )

        primary_address = event_loader.get_xpath(
            '//*[@id="event_summary"]//u[contains(text(), "pin")]/ancestor::tr//*[contains(@class, "_5xhp")]/text()'
        )
        secondary_address = event_loader.get_xpath(
            'string(//*[@id="event_summary"]//*[contains(@class, "_3xd0 _3slj")]//*[contains(@class, "_5xhk")])'
        )
        tertiary_address = event_loader.get_xpath(
            '//*[@id="event_summary"]//*[contains(@class, "_3xd0 _3slj")]//*[contains(@class, "_5xhk")]/text()'
        )
        event_loader.add_value(
            "address", primary_address or secondary_address or tertiary_address
        )

        event_loader.add_xpath(
            "datetimes",
            '//*[@id="event_time_info"]//div[@class="_2ycp _5xhk"][1]/@content',
        )
        event_loader.add_xpath(
            "place_name",
            '//*[@id="event_summary"]//*[contains(@class, "_3xd0 _3slj")]//*[contains(@class, "_5xhk")]/text()',
        )
        event_loader.add_xpath(
            "place_cover_url", '//*[contains(@class, "_2xr0")]/@style'
        )
        event_loader.add_xpath(
            "ticket_url", '//*[contains(@data-testid, "event_ticket")]/a/@href'
        )
        event_loader.add_xpath(
            "latitude",
            '//*[@id="event_summary"]//*[contains(@ajaxify, "latitude")]/@ajaxify',
        )
        event_loader.add_xpath(
            "longitude",
            '//*[@id="event_summary"]//*[contains(@ajaxify, "longitude")]/@ajaxify',
        )

        organizers_els = response.xpath('//*[contains(@class, "_6-i")]/li')
        if organizers_els:
            for organizer_el in organizers_els:
                event_loader.add_value(
                    "organizers",
                    self.parse_facebook_organizer_meta(response, organizer_el),
                )

        event_loader.add_xpath("description", '//*[@class="_63ew"]//span')
        event_loader.add_xpath("prices", '//*[@class="_63ew"]//span/text()')
        event_loader.add_xpath("categories", '//li[@class="_63ep _63eq"]/a/text()')
        event_loader.load_item()

        yield event_loader.load_item()

        related_events_links = response.xpath(
            '//div[@id="event_related_events"]//div[contains(@class, "SuggestionItem")]/a/@href'
        )

        for event_link in related_events_links.getall():
            if event_link is not None:

                yield SplashRequest(
                    url=urljoin(response.url, urlparse(event_link).path),
                    callback=self.parse_facebook_event,
                    endpoint="execute",
                    args={
                        "timeout": 600,
                        "lua_source": parse_facebook_event_script,
                        "ua": user_agents[0],
                    },
                )
                pass
            else:
                pass

    def parse_sympla_iframe(self, response):
        iframe_src = response.xpath('//*[contains(@id, "symplaw2")]/@src').get()

        self.log("FOLLOW IFRAME " + str(iframe_src))

        if iframe_src is not None:
            yield SplashRequest(
                url=iframe_src,
                callback=self.parse_sympla_page,
                endpoint="execute",
                args={
                    "timeout": 600,
                    "lua_source": parse_sympla_events_page_script,
                    "ua": user_agents[0],
                },
            )
        else:
            pass

    def parse_sympla_page(self, response):
        title_page = response.xpath("//title/text()").get()

        events_in_page = response.xpath(
            '//a[contains(@class, "sympla-card w-inline-block") or contains(@class, "CardLink")]/@href'
        )

        if not events_in_page:
            self.log(str(title_page) + " PAGE WITHOUT EVENTS")
            capture_message(str(title_page) + " PAGE WITHOUT EVENTS")
        else:
            self.log(
                str(title_page) + " PAGE WITH " + str(len(events_in_page)) + " EVENTS"
            )

        for event_link in events_in_page.getall():
            if event_link is not None and "bileto" in event_link:
                yield SplashRequest(
                    url=event_link,
                    callback=self.parse_bileto_api_event,
                    endpoint="execute",
                    args={
                        "timeout": 600,
                        "lua_source": parse_sympla_event_api_script,
                        "ua": user_agents[0],
                    },
                )
            elif event_link is not None and "bileto" not in event_link:
                yield SplashRequest(
                    url=event_link,
                    callback=self.parse_sympla_event,
                    endpoint="execute",
                    args={
                        "timeout": 600,
                        "lua_source": parse_sympla_events_page_script,
                        "ua": user_agents[0],
                    },
                )
            else:
                pass

    def parse_bileto_api_event(self, response):
        if "api_key" in response.data:
            api_key = response.data["api_key"]
            api_url = response.data["api_url"]

            self.log("API KEY: " + api_key)
            self.log("API URL: " + api_url)

            yield scrapy.Request(
                api_url,
                callback=self.parse_bileto_event,
                cb_kwargs=dict(source_url=response.url),
                headers={"x-api-key": api_key, "user-agent": user_agents[0]},
            )
        else:
            pass

    def parse_search_api_event(self, response):
        body = json.loads(response.body)

        for event_data in body["data"]:
            yield SplashRequest(
                url=event_data["url"],
                callback=self.parse_sympla_event,
                endpoint="execute",
                args={
                    "timeout": 600,
                    "lua_source": parse_sympla_events_page_script,
                    "ua": user_agents[0],
                },
                cb_kwargs=dict(event_data=event_data),
            )

    def parse_bileto_event(self, response, source_url):
        body = json.loads(response.body)
        event_loader = ItemLoader(item=Event())

        event_loader.add_value("source_url", source_url)
        event_loader.add_value("source_name", "bileto")
        event_loader.add_value("name", body["data"]["name"])
        event_loader.add_value("cover_url", body["data"]["notification_image"])
        event_loader.add_value("address", body["data"]["venue"]["locale"]["address"])
        event_loader.add_value("place_name", body["data"]["venue"]["name"])

        if "exhibitions" in body["data"]:
            event_loader.add_value(
                "datetimes",
                list(
                    map(
                        lambda item: item["local_date_time"],
                        body["data"]["exhibitions"]["items"],
                    )
                ),
            )
            event_loader.add_value("multiple_hours", "true")

        elif "presentations" in body["data"]:
            event_loader.add_value(
                "datetimes",
                list(
                    map(
                        lambda item: item["presentation_local_date_time"],
                        body["data"]["presentations"]["items"],
                    )
                ),
            )
            event_loader.add_value("multiple_hours", "false")
            # if len(body['data']['presentations']['items']) > 1:
            #    event_loader.add_value('multiple_hours', 'true')
            # else:
            #    event_loader.add_value('multiple_hours', 'false')

        else:
            event_loader.add_value("datetimes", [])

        event_loader.add_value("ticket_url", source_url)

        event_loader.add_value("latitude", str(body["data"]["venue"]["locale"]["lat"]))
        event_loader.add_value("longitude", str(body["data"]["venue"]["locale"]["lon"]))

        organizer_loader = EventOrganizerLoader()
        organizer_loader.add_value("name", body["data"]["venue"]["name"])
        event_loader.add_value("organizers", dict(organizer_loader.load_item()))

        event_loader.add_value("description", body["data"]["description"]["raw"])
        event_loader.add_value("prices", body["data"]["description"]["raw"])

        return event_loader.load_item()

    def parse_sympla_event(self, response, event_data):
        event_loader = ItemLoader(item=Event(), response=response)
        event_loader.add_value("source_url", response.url)
        event_loader.add_value("source_name", "sympla")
        event_loader.add_xpath(
            "name", 'normalize-space(//h1[contains(@class, "event-name")]/text())'
        )
        event_loader.add_xpath(
            "cover_url", '//img[contains(@class, "event-banner-img")]/@style'
        )

        event_loader.add_xpath(
            "address",
            '//*[contains(@class, "event-location-text")]//span[2]/text()',
            Join(),
        )
        # secondary_address = event_loader.get_xpath('string(//*[@id="event_summary"]//*[contains(@class, "_3xd0 _3slj")]//*[contains(@class, "_5xhk")])')
        # tertiary_address = event_loader.get_xpath('//*[@id="event_summary"]//*[contains(@class, "_3xd0 _3slj")]//*[contains(@class, "_5xhk")]/text()')
        # event_loader.add_value('address', primary_address)

        event_loader.add_xpath(
            "datetimes", '//*[contains(@class, "event-info-calendar")]/text()'
        )
        event_loader.add_xpath(
            "place_name",
            'normalize-space(//*[contains(@class, "event-location-name")]//text())',
        )
        # event_loader.add_xpath('place_cover_url', '//*[contains(@class, "_2xr0")]/@style')
        event_loader.add_value("ticket_url", response.url)
        event_loader.add_value("latitude", event_data["location"]["lat"])
        event_loader.add_value("longitude", event_data["location"]["lon"])

        organizers_els = response.xpath('//*[contains(@id, "produtor")]')
        if organizers_els:
            for organizer_el in organizers_els:
                event_loader.add_value(
                    "organizers",
                    self.parse_sympla_organizer_meta(response, organizer_el),
                )

        event_loader.add_xpath("description", '//*[contains(@id, "event-description")]')
        event_loader.add_xpath(
            "prices", '//*[contains(@id, "ticket-form")]//text()', Join()
        )
        # event_loader.add_xpath('categories', '//li[@class="_63ep _63eq"]/a/text()')
        event_loader.load_item()

        yield event_loader.load_item()

    def parse_eventbrite_event_api(self, response):
        body = json.loads(response.body)

        events = body["flatBucket"]["results"]

        for event in events:
            if "url" in event:
                yield SplashRequest(
                    url=event["url"],
                    callback=self.parse_eventbrite_event,
                    endpoint="execute",
                    args={
                        "timeout": 300,
                        "lua_source": parse_eventbrite_event_script,
                        "ua": user_agents[0],
                    },
                )
            else:
                pass

    def parse_eventbrite_event(self, response):
        event_loader = ItemLoader(
            item=EventEB(), response=response, source="eventbrite"
        )

        event_loader.add_value("source_url", response.url)
        event_loader.add_value("source_name", "eventbrite")
        event_loader.add_xpath("name", "//*[contains(@class, 'hero-title')]//text()")
        event_loader.add_xpath(
            "cover_url",
            '//source[contains(@srcset, "800w")]//@srcset',
        )
        event_loader.add_xpath(
            "address",
            '//*[contains(@class, "listing-map-card-street-address")]/text()',
        )
        event_loader.add_xpath(
            "datetimes",
            '//*[contains(@class, "listing-info__body")]//*[contains(text(), "Data e hora")]/following-sibling::div/meta[1]/@content',
        )
        event_loader.add_xpath(
            "place_name",
            '//*[contains(@class, "listing-info__body")]//*[contains(text(), "Localização")]/following-sibling::div/p[1]/text()',
        )
        event_loader.add_xpath(
            "place_cover_url",
            '//*[contains(@class, "_2xr0")]/@style//*[contains(@class, "listing-info__body")]//*[contains(text(), "Localização")]/following-sibling::div/p[1]/text()',
        )
        event_loader.add_value("ticket_url", response.url)
        event_loader.add_xpath(
            "latitude",
            '//meta[contains(@property, "latitude")]/@content',
        )
        event_loader.add_xpath(
            "longitude",
            '//meta[contains(@property, "longitude")]/@content',
        )

        organizer_loader = EventOrganizerLoader()
        organizer_loader.add_value(
            "cover_url",
            event_loader.get_xpath(
                '//*[contains(@class, "listing-organizer")]//picture/@content'
            ),
        )
        organizer_loader.add_value(
            "name",
            event_loader.get_xpath(
                '//*[contains(@data-automation, "organizer-name")]/a/text()'
            ),
        )
        organizer_loader.add_value(
            "source_url",
            event_loader.get_xpath(
                '//*[contains(@data-automation, "organizer-name")]/a/@href'
            ),
        )
        event_loader.add_value("organizers", dict(organizer_loader.load_item()))

        event_loader.add_xpath(
            "description", '//*[contains(@class, "structured-content-rich-text")]'
        )
        event_loader.add_xpath(
            "prices", '//*[contains(@class, "js-display-price")]/text()'
        )
        event_loader.load_item()

        yield event_loader.load_item()

    def parse_facebook_organizer_meta(self, response, organizer_el):
        organizer_loader = EventOrganizerLoader(selector=organizer_el)
        organizer_loader.add_xpath("name", './/*[contains(@class, "_50f7")]//text()')
        organizer_loader.add_xpath("cover_url", './/*[contains(@class, "_rw")]/@src')
        organizer_loader.add_xpath("source_url", './/*[contains(@class, "_ohe")]/@href')

        return dict(organizer_loader.load_item())

    def parse_sympla_organizer_meta(self, response, organizer_el):
        organizer_loader = EventOrganizerLoader(selector=organizer_el)
        organizer_loader.add_xpath("name", "normalize-space(.//h4//text())")
        organizer_loader.add_xpath(
            "cover_url", './/*[contains(@class, "organizer-image")]//@style'
        )
        organizer_loader.add_xpath(
            "source_url", './/a[contains(text(), "Mais eventos")]/@href'
        )

        return dict(organizer_loader.load_item())
