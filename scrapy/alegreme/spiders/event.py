# -*- coding: utf-8 -*-
import scrapy
import random


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

parse_event_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:on_request(function(request)
            request:set_http2_enabled(true)
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

parse_events_page_script = """
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

parse_place_page_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:on_request(function(request)
            request:set_http2_enabled(true)
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
        splash.scroll_position = {y=3000} 
        assert(splash:wait(3))

        return splash:html()
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
        'CLOSESPIDER_PAGECOUNT': 200,
        'DEPTH_LIMIT': 1
    }

    allowed_domains = ['facebook.com']
    pages = [
            'https://www.facebook.com/pages/Opini%C3%A3o/119453431446021',
            'https://m.facebook.com/pg/araujoviannaoficial/events?ref=page_internal',
            'https://m.facebook.com/pg/SerenataIluminada/events?ref=page_internal',
            'https://m.facebook.com/pg/opiniao.produtora/events?ref=page_internal',
            'https://m.facebook.com/pg/casamundicultura/events?ref=page_internal',
            'https://m.facebook.com/pg/divinacomediapub/events?ref=page_internal',
            'https://m.facebook.com/pg/paraphabaiuca/events?ref=page_internal',
            'https://m.facebook.com/pg/Cabaretpoa/events?ref=page_internal',
            'https://m.facebook.com/pg/nopalcors/events?ref=page_internal',
            'https://m.facebook.com/pg/feiradajoao/events?ref=page_internal',
            'https://m.facebook.com/pg/CCMQportoalegre/events?ref=page_internal',
            'https://m.facebook.com/pg/agulha.poa/events?ref=page_internal',
            'https://m.facebook.com/pg/vilaflorespoa/events?ref=page_internal',
            'https://m.facebook.com/pg/cinemateca.capitolio/events?ref=page_internal',
            'https://m.facebook.com/pg/InstitutoLing/events?ref=page_internal',
            'https://m.facebook.com/pg/GoetheInstitutPortoAlegre/events?ref=page_internal',
            'https://m.facebook.com/pg/ksacentro/events?ref=page_internal',
            'https://m.facebook.com/pg/casacinepoa/events?ref=page_internal',
            'https://m.facebook.com/pg/picnicculturalnomuseu/events?ref=page_internal',
            'https://m.facebook.com/pg/noitedosmuseus/events?ref=page_internal',
            'https://m.facebook.com/pg/CentroCulturalUFRGS/events?ref=page_internal',
            'https://m.facebook.com/pg/mercadovintage/events?ref=page_internal',
            'https://m.facebook.com/pg/prefpoa/events?ref=page_internal',
            'https://m.facebook.com/pg/fundacaoiberecamargo/events?ref=page_internal',
            'https://m.facebook.com/pg/margsmuseu/events?ref=page_internal',
            'https://m.facebook.com/pg/gretacollective/events?ref=page_internal',
            'https://m.facebook.com/pg/coletivoarruaca/events?ref=page_internal',
            'https://m.facebook.com/pg/coletivoplano/events?ref=page_internal',
            'https://m.facebook.com/pg/baropiniao/events?ref=page_internal',
            'https://m.facebook.com/pg/fennnnnda/events?ref=page_internal',
            'https://m.facebook.com/pg/pepsionstageoficial/events?ref=page_internal',
            'https://m.facebook.com/pg/ospabr/events?ref=page_internal',
            'https://m.facebook.com/pg/animaleditora/events?ref=page_internal',
            'https://m.facebook.com/pg/teatrodobourboncountry/events?ref=page_internal',
            'https://m.facebook.com/pg/SescRS/events?ref=page_internal',
            'https://m.facebook.com/pg/Bar.Ocidente/events?ref=page_internal',
            'https://m.facebook.com/pg/comicconrs/events?ref=page_internal',
            'https://m.facebook.com/pg/bibliotecapublicadoestadors/events?ref=page_internal',
            'https://m.facebook.com/pg/somosMODAUT/events?ref=page_internal',
            'https://m.facebook.com/pg/GoetheInstitutPortoAlegre/events?ref=page_internal',
            'https://m.facebook.com/pg/tonaruamurb/events?ref=page_internal',
            'https://m.facebook.com/pg/aerofeira/events/?ref=page_internal/events?ref=page_internal',
            'https://m.facebook.com/pg/acasacc/events?ref=page_internal',
            'https://m.facebook.com/pg/ILEAUFRGS/events?ref=page_internal',
            'https://m.facebook.com/pg/cccev.rs/events?ref=page_internal',
            'https://m.facebook.com/pg/forroderuadeportoalegre/events?ref=page_internal',
            'https://m.facebook.com/pg/ciarusticadeteatro/events?ref=page_internal',
            'https://m.facebook.com/pg/feiramegusta/events?ref=page_internal',
            'https://m.facebook.com/pg/MegaRevelRS/events?ref=page_internal',
            'https://m.facebook.com/pg/viradasustentavelpoa/events?ref=page_internal',
            'https://m.facebook.com/pg/feiramultipalco/events?ref=page_internal',
            'https://m.facebook.com/pg/feiralamovida/events?ref=page_internal',
            'https://m.facebook.com/pg/uxconferencebr/events?ref=page_internal',
            'https://m.facebook.com/pg/ResultadosDigitais/events?ref=page_internal',
            'https://m.facebook.com/pg/CODEINTELIGENCIA/events?ref=page_internal',
            'https://m.facebook.com/pg/Uergs/events?ref=page_internal',
            'https://m.facebook.com/pg/forumdaliberdade/events?ref=page_internal',
            'https://m.facebook.com/pg/SindilojasPOA/events?ref=page_internal',
            'https://m.facebook.com/pg/ligadesaudedesportiva/events?ref=page_internal',
            'https://m.facebook.com/pg/centrodeeventospucrs/events?ref=page_internal',
            'https://m.facebook.com/pg/revistajadore/events?ref=page_internal',
            'https://m.facebook.com/pg/FestivaldaCervejaPOA/events?ref=page_internal',
            'https://m.facebook.com/pg/mercadodepulgaspoa/events?ref=page_internal',
            'https://m.facebook.com/pg/lojaprofana/events?ref=page_internal',
            'https://m.facebook.com/pg/studiodestemperados/events?ref=page_internal',
            'https://m.facebook.com/pg/festaacabouchorare/events?ref=page_internal',
            'https://m.facebook.com/pg/zonaexpfm/events?ref=page_internal',
            'https://m.facebook.com/pg/gomarec/events?ref=page_internal',
            'https://m.facebook.com/pg/darumT/events?ref=page_internal',
            'https://m.facebook.com/pg/basepoa/events?ref=page_internal'
            ]

    random.shuffle(pages)
    
    def start_requests(self):
        self.log("INITIALIZING...")
        self.log("UA: %s" % user_agents[0])

        for page in self.pages:
            yield SplashRequest(
                url=page,
                callback=self.parse_page,
                endpoint='execute',
                args={
                'timeout': 300,
                'lua_source': parse_events_page_script if 'm.facebook.com' in page else parse_place_page_script,
                'ua': user_agents[0]
                }
            )



    def parse_page(self, response):
        title_page = response.xpath('//title/text()').get()

        if 'm.facebook.com' in response.url:
            events_in_page = response.xpath('//*[contains(@class, "_5zma")]//*[contains(@class, "_5379")]/@href|//*[contains(@class, "_1ksp")][1]//@href')
        else:
            events_in_page = response.xpath('//a[contains(@href, "events/") and contains(@class, "profileLink")]/@href')

        if not events_in_page:
            self.log(str(title_page) + " PAGE WITHOUT EVENTS")
        else:
            self.log(str(title_page) + " PAGE WITH " + str(len(events_in_page)) + " EVENTS")

        for event_link in events_in_page.getall():
            if event_link is not None:
                yield SplashRequest(
                    url=urljoin('https://www.facebook.com/', urlparse(event_link).path),
                    callback=self.parse_event,
                    endpoint='execute',
                    args={
                    'timeout': 600,
                    'lua_source': parse_event_script,
                    'ua': user_agents[0]
                    }
                )
            else:
                pass


    def parse_event(self, response):
        event_loader = ItemLoader(item=Event(), response=response)
        event_loader.add_xpath('name', '//title[1]/text()')
        event_loader.add_xpath('cover_url', '//*[contains(@class, "uiScaledImageContainer")]//*[contains(@class, "scaledImageFit")]/@src')
        
        primary_address = event_loader.get_xpath('//*[@id="event_summary"]//*[contains(@class, "_5xhp fsm fwn fcg")][1]/text()')
        secondary_address = event_loader.get_xpath('string(//*[@id="event_summary"]//*[contains(@class, "_3xd0 _3slj")]//*[contains(@class, "_5xhk")])')
        event_loader.add_value('address', primary_address or secondary_address)
        
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
                    callback=self.parse_event,
                    endpoint='execute',
                    args={
                        'timeout': 600,
                        'lua_source': parse_event_script,
                        'ua': user_agents[0]
                    }
                )
                pass
            else:
                pass


    def parse_organizer_meta(self, response, organizer_el):
        organizer_loader = EventOrganizerLoader(selector=organizer_el)
        organizer_loader.add_xpath('name', './/*[contains(@class, "_50f7")]//text()')
        organizer_loader.add_xpath('cover_url', './/*[contains(@class, "_rw")]/@src')
        organizer_loader.add_xpath('source_url', './/*[contains(@class, "_ohe")]/@href')

        return dict(organizer_loader.load_item())
