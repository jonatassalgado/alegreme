# -*- coding: utf-8 -*-
import scrapy
import base64
import json
import os
import random
# import shadow_useragent

from urllib.parse import urljoin
from alegreme.items import Event, EventOrganizer, EventOrganizerLoader
from scrapy_splash import SplashRequest
from scrapy.loader import ItemLoader

# ua = shadow_useragent.ShadowUserAgent()
# ua = ua.firefox

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
ua = user_agents[0]

parse_event_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 120
        splash:set_user_agent(tostring(args.ua))
        assert(splash:go(splash.args.url))
        assert(splash:wait(3))
        splash.scroll_position = {y=1000}

        local signupForm = splash:select('#login_form')

        if signupForm == nil then
            result, error = splash:wait_for_resume([[
                        function main(splash) {
                            var checkExist = setInterval(function() {
                                if (document.querySelector("._63ew").innerText && document.querySelector("._2ycp._5xhk").innerText && document.querySelector('._2xq3').innerText) {
                                    clearInterval(checkExist);
                                    splash.resume();
                                }
                            }, 1000);
                        }
                    ]], 60)
        end

        splash:runjs("window.close()")
        return splash:html()
    end
"""

parse_page_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 120
        splash:set_user_agent(tostring(args.ua))

        assert(splash:go(splash.args.url))

        assert(splash:wait(1))
        splash.scroll_position = {y=500}

        result, error = splash:wait_for_resume([[
        function main(splash) {
            var checkExist = setInterval(function() {
                if (document.querySelector(".upcoming_events_card").innerHTML) {
                    clearInterval(checkExist);
                     splash.resume();
                    }
                }, 1000);
            }
        ]], 30)

        assert(splash:wait(0.5))
        splash:runjs("window.close()")
        return splash:html()
    end
"""

class EventSpider(scrapy.Spider):
    http_user = 'jon'
    http_pass = 'password'

    name = 'event'

    custom_settings = {
        'ITEM_PIPELINES': {
            'alegreme.pipelines.EventPipeline': 400
        },
        'CLOSESPIDER_ITEMCOUNT': 100,
        'DEPTH_LIMIT': 2
    }

    allowed_domains = ['facebook.com']
    start_urls = ['https://www.facebook.com/SerenataIluminada/events',
                  'https://www.facebook.com/feiradajoao/events',
                  'https://www.facebook.com/CCMQportoalegre/events',
                  'https://www.facebook.com/agulha.poa/events',
                  'https://www.facebook.com/vilaflorespoa/events',
                  'https://www.facebook.com/cinemateca.capitolio/events',
                  'https://www.facebook.com/InstitutoLing/events',
                  'https://www.facebook.com/GoetheInstitutPortoAlegre/events',
                  'https://www.facebook.com/ksacentro/events',
                  'https://www.facebook.com/casacinepoa/events',
                  'https://www.facebook.com/picnicculturalnomuseu/events',
                  'https://www.facebook.com/noitedosmuseus/events',
                  'https://www.facebook.com/CentroCulturalUFRGS/events',
                  'https://www.facebook.com/mercadovintage/events',
                  'https://www.facebook.com/prefpoa/events',
                  'https://www.facebook.com/fundacaoiberecamargo/events',
                  'https://www.facebook.com/margsmuseu/events',
                  'https://www.facebook.com/gretacollective/events',
                  'https://www.facebook.com/coletivoarruaca/events',
                  'https://www.facebook.com/coletivoplano/events',
                  'https://www.facebook.com/baropiniao/events',
                  'https://www.facebook.com/fennnnnda/events',
                  'https://www.facebook.com/pepsionstageoficial/events',
                  'https://www.facebook.com/auditorioaraujovianna/events',
                  'https://www.facebook.com/ospabr/events',
                  'https://www.facebook.com/teatrodobourboncountry/events',
                  'https://www.facebook.com/sesccentro/events',
                  'https://www.facebook.com/Bar.Ocidente/events',
                  'https://www.facebook.com/comicconrs/events',
                  'https://www.facebook.com/bibliotecapublicadoestadors/events',
                  'https://www.facebook.com/somosMODAUT/events',
                  'https://www.facebook.com/GoetheInstitutPortoAlegre/events',
                  'https://www.facebook.com/tonaruamurb/events',
                  'https://www.facebook.com/aerofeira/events/',
                  'https://www.facebook.com/acasacc/events',
                  'https://www.facebook.com/ILEAUFRGS/events',
                  'https://www.facebook.com/cumbianarua/events',
                  'https://www.facebook.com/cccev.rs/events',
                  'https://www.facebook.com/forroderuadeportoalegre/events',
                  'https://www.facebook.com/ciarusticadeteatro/events',
                  'https://www.facebook.com/feiramegusta/events',
                  'https://www.facebook.com/MegaRevelRS/events',
                  'https://www.facebook.com/viradasustentavelpoa/events',
                  'https://www.facebook.com/feiramultipalco/events',
                  'https://www.facebook.com/feiralamovida/events',
                  'https://www.facebook.com/uxconferencebr/events',
                  'https://www.facebook.com/ResultadosDigitais/events',
                  'https://www.facebook.com/CODEESCOLA/events',
                  'https://www.facebook.com/Uergs/events',
                  'https://www.facebook.com/forumdaliberdade/events',
                  'https://www.facebook.com/SindilojasPOA/events',
                  'https://www.facebook.com/ligadesaudedesportiva/events',
                  'https://www.facebook.com/centrodeeventospucrs/events',
                  'https://www.facebook.com/revistajadore/events',
                  'https://www.facebook.com/FestivaldaCervejaPOA/events',
                  'https://www.facebook.com/mercadodepulgaspoa/events',
                  'https://www.facebook.com/lojaprofana/events',
                  'https://www.facebook.com/casadestemperados/events',
                  'https://www.facebook.com/festaacabouchorare/events',
                  'https://www.facebook.com/zonaexpfm/events',
                  'https://www.facebook.com/gomarec/events',
                  'https://www.facebook.com/darumT/events',
                  'https://www.facebook.com/basepoa/events'
                  ]

    random.shuffle(start_urls)

    def start_requests(self):
        self.log("INITIALIZING...")
        self.log("UA: %s" % ua)
        for url in self.start_urls:
            yield SplashRequest(
                url=url,
                callback=self.parse_page,
                endpoint='execute',
                args={
                'timeout': 120,
                'lua_source': parse_page_script,
                'ua': ua
                }
            )




    def parse_page(self, response):

        events_in_page = response.xpath('//*[contains(@id, "upcoming_events_card")]//*[contains(@class, "_4dmk")]//@href')

        if not events_in_page:
            self.log("PAGE WITHOUT EVENTS")

        for event_link in events_in_page.extract():
            if event_link is not None:
                yield SplashRequest(
                    url=urljoin(response.url, event_link),
                    callback=self.parse_event,
                    endpoint='execute',
                    args={
                    'timeout': 600,
                    'lua_source': parse_event_script,
                    'ua': ua
                    }
                )
                pass
            else:
                pass


    # def parse_result(self, response):
    #     imgdata = base64.b64decode(response.data['png'])
    #     filename = 'some_image.png'
    #     with open(filename, 'wb') as f:
    #         f.write(imgdata)


    def parse_event(self, response):
        event_loader = ItemLoader(item=Event(), response=response)

        sign_in_form = response.xpath('//*[contains(@class, "_585r _50f4") and contains(., "You must log in to continue")]')
        if sign_in_form:
            event_loader.add_value('deleted', 'true')
            event_loader.add_value('source_url', response.url)
            event_loader.load_item()
            event = event_loader.item
            self.log("EVENT DELETED: %s" % event)
            yield event
            return

        event_loader.add_xpath('name', '//title[1]/text()')
        event_loader.add_xpath('cover_url', '//*[contains(@class, "uiScaledImageContainer")]//*[contains(@class, "scaledImageFit")]/@src')
        event_loader.add_xpath('address', '//*[@id="event_summary"]//div[@class="_5xhp fsm fwn fcg"][1]/text()')
        event_loader.add_xpath('datetimes', '//*[@id="event_time_info"]//div[@class="_2ycp _5xhk"][1]/@content')
        event_loader.add_xpath('place_name', '//*[@id="event_summary"]//a[@class="_5xhk"][1]/text()')
        event_loader.add_xpath('place_cover_url', '//*[contains(@class, "_2xr0")]/@style')
        event_loader.add_xpath('ticket_url', '//*[contains(@data-testid, "event_ticket")]/a/@href')

        organizers_els = response.xpath('//*[contains(@class, "_6-i")]/li')
        if organizers_els:
            for organizer_el in organizers_els:
                event_loader.add_value('organizers', self.parse_organizer_meta(response, organizer_el))

        event_loader.add_xpath('description', '//*[@class="_63ew"]//span')
        event_loader.add_xpath('prices', '//*[@id="event_summary"]//*[@class="_20zc"]/text()')
        event_loader.add_xpath('categories', '//li[@class="_63ep _63eq"]/a/text()')
        event_loader.add_value('source_url', response.url)
        event_loader.load_item()

        event = event_loader.item
        self.log("EVENT SCRAPED: %s" % event)

        if 'address' in event and "Porto Alegre" in event['address']:
            yield event
        else:
            pass


        related_events_links = response.xpath('//div[@id="event_related_events"]//div[contains(@class, "SuggestionItem")]/a/@href')

        for event_link in related_events_links.extract():
            if event_link is not None:
                yield SplashRequest(
                    url=urljoin(response.url, event_link),
                     callback=self.parse_event,
                    endpoint='execute',
                    args={
                        'lua_source': parse_event_script,
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
