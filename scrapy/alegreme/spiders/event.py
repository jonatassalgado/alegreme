# -*- coding: utf-8 -*-
import scrapy
import random
import json

from urllib.parse import urljoin, urlparse
from alegreme.items import Event, EventOrganizerLoader
from scrapy_splash import SplashRequest
from scrapy.loader import ItemLoader
from alegreme.services.proxy_service import ProxyService

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
  "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Safari/537.36"
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
            ["user-agent"] = tostring(args.ua),
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
            ["user-agent"] = tostring(args.ua),
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
                ["user-agent"] = tostring(args.ua),
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
            ["user-agent"] = tostring(args.ua),
            ["cache-control"] = "no-cache",
            ["upgrade-insecure-requests"] = "1",
            ["accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
            ["accept-enconding"] = "gzip, deflate, br",
            ["cookie"] = '_ga=GA1.3.869050002.1628010327; _gid=GA1.3.492902586.1628010327; _gat_gtag_UA_24958859_7=1; _gcl_au=1.1.1359478704.1628010328; _gat_UA-24958859-7=1; __trf.src=encoded_eyJmaXJzdF9zZXNzaW9uIjp7InZhbHVlIjoiaHR0cHM6Ly9zaXRlLmJpbGV0by5zeW1wbGEuY29tLmJyLyIsImV4dHJhX3BhcmFtcyI6e319LCJjdXJyZW50X3Nlc3Npb24iOnsidmFsdWUiOiJodHRwczovL3NpdGUuYmlsZXRvLnN5bXBsYS5jb20uYnIvIiwiZXh0cmFfcGFyYW1zIjp7fX0sImNyZWF0ZWRfYXQiOjE2MjgwMTAzMjc4MzN9; _fbp=fb.2.1628010328029.603235374; pxcts=004519b1-f47d-11eb-a0d6-efe0bc58b32f; _pxvid=0044cbfc-f47d-11eb-901e-0242ac120008; _pxde=510301da31c3d21fda909e7a04ed23a7f3810f3cf793ceba71391ab8fdbeb530:eyJ0aW1lc3RhbXAiOjE2MjgwMTAzMjg2NDB9; rdtrk={"id":"912f7e43-4c07-4156-a0a4-794f6ee97c1f"}'
        })

        assert(splash:go(splash.args.url))
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



class EventSpider(scrapy.Spider):
    http_user = 'alegreme'
    http_pass = 've97K8bCwNkNgQSqvMkYRryMG4MQuQGU'

    name = 'event'

    custom_settings = {
        'ITEM_PIPELINES': {
            'alegreme.pipelines.EventPipeline': 400
        },
        'CLOSESPIDER_ITEMCOUNT': 100,
        'CLOSESPIDER_PAGECOUNT': 300,
        'DEPTH_LIMIT': 3,
        'DOMAIN_DEPTHS': {'facebook.com': 1, 'sympla.com.br': 3}
    }

    allowed_domains = ['facebook.com', 'sympla.com.br']
    facebook_pages = [
            'https://m.facebook.com/pages/Opini%C3%A3o/119453431446021',
            'https://m.facebook.com/BrickDeDesapegos',
            'https://m.facebook.com/revolucao.mar',
            'https://m.facebook.com/AIMEC.Poa',
            'https://m.facebook.com/Espaco373',
            'https://m.facebook.com/zaffari',
            'https://m.facebook.com/profisomprodutora',
            'https://m.facebook.com/araujoviannaoficial',
            'https://m.facebook.com/SerenataIluminada',
            'https://m.facebook.com/opiniao.produtora',
            'https://m.facebook.com/casamundicultura',
            'https://m.facebook.com/divinacomediapub',
            'https://m.facebook.com/paraphabaiuca',
            'https://m.facebook.com/Cabaretpoa',
            'https://m.facebook.com/nopalcors',
            'https://m.facebook.com/feiradajoao',
            'https://m.facebook.com/CCMQportoalegre',
            'https://m.facebook.com/agulha.poa',
            'https://m.facebook.com/vilaflorespoa',
            'https://m.facebook.com/cinemateca.capitolio',
            'https://m.facebook.com/InstitutoLing',
            'https://m.facebook.com/GoetheInstitutPortoAlegre',
            'https://m.facebook.com/ksacentro',
            'https://m.facebook.com/casacinepoa',
            'https://m.facebook.com/picnicculturalnomuseu',
            'https://m.facebook.com/noitedosmuseus',
            'https://m.facebook.com/CentroCulturalUFRGS',
            'https://m.facebook.com/mercadovintage',
            'https://m.facebook.com/prefpoa',
            'https://m.facebook.com/fundacaoiberecamargo',
            'https://m.facebook.com/margsmuseu',
            'https://m.facebook.com/gretacollective',
            'https://m.facebook.com/coletivoarruaca',
            'https://m.facebook.com/coletivoplano',
            'https://m.facebook.com/baropiniao',
            'https://m.facebook.com/fennnnnda',
            'https://m.facebook.com/pepsionstageoficial',
            'https://m.facebook.com/ospabr',
            'https://m.facebook.com/animaleditora',
            'https://m.facebook.com/teatrodobourboncountry',
            'https://m.facebook.com/SescRS',
            'https://m.facebook.com/Bar.Ocidente',
            'https://m.facebook.com/comicconrs',
            'https://m.facebook.com/bibliotecapublicadoestadors',
            'https://m.facebook.com/somosMODAUT',
            'https://m.facebook.com/GoetheInstitutPortoAlegre',
            'https://m.facebook.com/tonaruamurb',
            'https://m.facebook.com/aerofeira',
            'https://m.facebook.com/acasacc',
            'https://m.facebook.com/ILEAUFRGS',
            'https://m.facebook.com/cccev.rs',
            'https://m.facebook.com/forroderuadeportoalegre',
            'https://m.facebook.com/ciarusticadeteatro',
            'https://m.facebook.com/feiramegusta',
            'https://m.facebook.com/MegaRevelRS',
            'https://m.facebook.com/viradasustentavelpoa',
            'https://m.facebook.com/feiramultipalco',
            'https://m.facebook.com/feiralamovida',
            'https://m.facebook.com/uxconferencebr',
            'https://m.facebook.com/ResultadosDigitais',
            'https://m.facebook.com/CODEINTELIGENCIA',
            'https://m.facebook.com/Uergs',
            'https://m.facebook.com/forumdaliberdade',
            'https://m.facebook.com/SindilojasPOA',
            'https://m.facebook.com/ligadesaudedesportiva',
            'https://m.facebook.com/centrodeeventospucrs',
            'https://m.facebook.com/revistajadore',
            'https://m.facebook.com/FestivaldaCervejaPOA',
            'https://m.facebook.com/mercadodepulgaspoa',
            'https://m.facebook.com/lojaprofana',
            'https://m.facebook.com/studiodestemperados',
            'https://m.facebook.com/festaacabouchorare',
            'https://m.facebook.com/zonaexpfm',
            'https://m.facebook.com/gomarec',
            'https://m.facebook.com/darumT',
            'https://m.facebook.com/basepoa'
            ]
    
    sympla_pages = ['https://site.bileto.sympla.com.br/farolsantanderpoa']

    random.shuffle(facebook_pages)
    random.shuffle(sympla_pages)
    
    def start_requests(self):
        self.log("INITIALIZING...")
        self.log("UA: %s" % user_agents[0])

        yield SplashRequest(
            url='https://m.facebook.com/events/discovery/?city_id=264859',
            callback=self.parse_facebook_page,
            endpoint='execute',
            args={
            'timeout': 300,
            'lua_source': parse_facebook_place_page_script,
            'ua': user_agents[0]
            }
        )
        
        for page in self.sympla_pages:
            yield SplashRequest(
                url=page,
                callback=self.parse_sympla_iframe,
                endpoint='execute',
                args={
                'timeout': 300,
                'lua_source': parse_sympla_events_page_script,
                'ua': user_agents[0]
                }
            )


    def parse_facebook_page(self, response):
        title_page = response.xpath('//title/text()').get()

        events_in_page = response.xpath('//a[contains(@href, "events/") and contains(@class, "_49z0")]/@href')

        if not events_in_page:
            self.log(str(title_page) + " PAGE WITHOUT EVENTS")
        else:
            self.log(str(title_page) + " PAGE WITH " + str(len(events_in_page)) + " EVENTS")

        for event_link in events_in_page.getall():
            if event_link is not None:
                yield SplashRequest(
                    url=urljoin('https://www.facebook.com/', urlparse(event_link).path),
                    callback=self.parse_facebook_event,
                    endpoint='execute',
                    args={
                    'timeout': 600,
                    'lua_source': parse_facebook_event_script,
                    'ua': user_agents[0]
                    }
                )
            else:
                pass
    


    def parse_facebook_event(self, response):
        event_loader = ItemLoader(item=Event(), response=response)
        event_loader.add_xpath('name', '//title[1]/text()')
        event_loader.add_xpath('cover_url', '//*[contains(@class, "uiScaledImageContainer")]//*[contains(@class, "scaledImageFit")]/@src')
        
        primary_address = event_loader.get_xpath('//*[@id="event_summary"]//u[contains(text(), "pin")]/ancestor::tr//*[contains(@class, "_5xhp")]/text()')
        secondary_address = event_loader.get_xpath('string(//*[@id="event_summary"]//*[contains(@class, "_3xd0 _3slj")]//*[contains(@class, "_5xhk")])')
        tertiary_address = event_loader.get_xpath('//*[@id="event_summary"]//*[contains(@class, "_3xd0 _3slj")]//*[contains(@class, "_5xhk")]/text()')
        event_loader.add_value('address', primary_address or secondary_address or tertiary_address)
        
        event_loader.add_xpath('datetimes', '//*[@id="event_time_info"]//div[@class="_2ycp _5xhk"][1]/@content')
        event_loader.add_xpath('place_name', '//*[@id="event_summary"]//*[contains(@class, "_3xd0 _3slj")]//*[contains(@class, "_5xhk")]/text()')
        event_loader.add_xpath('place_cover_url', '//*[contains(@class, "_2xr0")]/@style')
        event_loader.add_xpath('ticket_url', '//*[contains(@data-testid, "event_ticket")]/a/@href')
        event_loader.add_xpath('latitude', '//*[@id="event_summary"]//*[contains(@ajaxify, "latitude")]/@ajaxify')
        event_loader.add_xpath('longitude', '//*[@id="event_summary"]//*[contains(@ajaxify, "longitude")]/@ajaxify')

        organizers_els = response.xpath('//*[contains(@class, "_6-i")]/li')
        if organizers_els:
            for organizer_el in organizers_els:
                event_loader.add_value('organizers', self.parse_organizer_meta(response, organizer_el))

        event_loader.add_xpath('description', '//*[@class="_63ew"]//span')
        event_loader.add_xpath('prices', '//*[@class="_63ew"]//span/text()')
        event_loader.add_xpath('categories', '//li[@class="_63ep _63eq"]/a/text()')
        event_loader.add_value('source_url', response.url)
        event_loader.load_item()

        yield event_loader.load_item()

        related_events_links = response.xpath('//div[@id="event_related_events"]//div[contains(@class, "SuggestionItem")]/a/@href')

        for event_link in related_events_links.getall():
            if event_link is not None:
                
                yield SplashRequest(
                    url=urljoin(response.url, urlparse(event_link).path),
                    callback=self.parse_facebook_event,
                    endpoint='execute',
                    args={
                        'timeout': 600,
                        'lua_source': parse_facebook_event_script,
                        'ua': user_agents[0]
                    }
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
                endpoint='execute',
                args={
                'timeout': 600,
                'lua_source': parse_sympla_events_page_script,
                'ua': user_agents[0]
                }
            )
        else:
            pass

    
    def parse_sympla_page(self, response):
        title_page = response.xpath('//title/text()').get()

        events_in_page = response.xpath('//a[contains(@class, "sympla-card w-inline-block")]/@href')

        if not events_in_page:
            self.log(str(title_page) + " PAGE WITHOUT EVENTS")
        else:
            self.log(str(title_page) + " PAGE WITH " + str(len(events_in_page)) + " EVENTS")

        for event_link in events_in_page.getall():
            if event_link is not None:
                yield SplashRequest(
                    url=event_link,
                    callback=self.parse_sympla_api_event,
                    endpoint='execute',
                    args={
                    'timeout': 600,
                    'lua_source': parse_sympla_event_api_script,
                    'ua': user_agents[0]
                    }
                )
            else:
                pass



    def parse_sympla_api_event(self, response):
        if 'api_key' in response.data: 
            api_key = response.data['api_key']
            api_url = response.data['api_url']

            self.log("API KEY: " + api_key)
            self.log("API URL: " + api_url)

            yield scrapy.Request(api_url, 
                            callback=self.parse_sympla_event,
                            cb_kwargs=dict(source_url=response.url),
                            headers={
                                'x-api-key': api_key,
                                'user-agent': user_agents[0]
                            })
        else:
            pass
       



    def parse_sympla_event(self, response, source_url):
        body = json.loads(response.body)
        event_loader = ItemLoader(item=Event())

        event_loader.add_value('name', body['data']['name'])
        event_loader.add_value('cover_url', body['data']['notification_image'])
        event_loader.add_value('address', body['data']['venue']['locale']['address'])
        event_loader.add_value('place_name', body['data']['venue']['name'])
        
        if 'exhibitions' in body['data']:
            event_loader.add_value('datetimes',  list(map(lambda item: item['local_date_time'], body['data']['exhibitions']['items'])))
            event_loader.add_value('multiple_hours', 'true')

        elif 'presentations' in body['data']:
            event_loader.add_value('datetimes',  list(map(lambda item: item['presentation_local_date_time'], body['data']['presentations']['items'])))
            event_loader.add_value('multiple_hours', 'false')
            #if len(body['data']['presentations']['items']) > 1:
            #    event_loader.add_value('multiple_hours', 'true')
            #else:
            #    event_loader.add_value('multiple_hours', 'false')

        else:
            event_loader.add_value('datetimes',  [])

        event_loader.add_value('ticket_url', source_url)
        
        event_loader.add_value('latitude', str(body['data']['venue']['locale']['lat']))
        event_loader.add_value('longitude', str(body['data']['venue']['locale']['lon']))

        organizer_loader = EventOrganizerLoader()
        organizer_loader.add_value('name',  body['data']['venue']['name'])
        event_loader.add_value('organizers', dict(organizer_loader.load_item()))

        event_loader.add_value('description', body['data']['description']['raw'])
        event_loader.add_value('prices', body['data']['description']['raw'])
        event_loader.add_value('source_url', source_url)
        
        return event_loader.load_item()



    def parse_organizer_meta(self, response, organizer_el):
        organizer_loader = EventOrganizerLoader(selector=organizer_el)
        organizer_loader.add_xpath('name', './/*[contains(@class, "_50f7")]//text()')
        organizer_loader.add_xpath('cover_url', './/*[contains(@class, "_rw")]/@src')
        organizer_loader.add_xpath('source_url', './/*[contains(@class, "_ohe")]/@href')

        return dict(organizer_loader.load_item())
