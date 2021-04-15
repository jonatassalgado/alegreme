# -*- coding: utf-8 -*-
import scrapy
import base64
import json
import os
import random
import re

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

parse_event_script = """
    function main(splash, args)
        splash.private_mode_enabled = true
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 300
        splash:set_user_agent(tostring(args.ua))
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
                    ]], 60)
        end

        return splash:html()
    end
"""

parse_page_script = """
    function main(splash, args)
        splash.private_mode_enabled = true
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash:set_user_agent(tostring(args.ua))
        splash.resource_timeout = 300

        local num_scrolls = 10
        local scroll_delay = 2

        local scroll_to = splash:jsfunc("window.scrollTo")
        local get_body_height = splash:jsfunc(
            "function() {return document.body.scrollHeight;}"
        )
        assert(splash:go(splash.args.url))
        splash:wait(2)

        for _ = 1, num_scrolls do
            scroll_to(0, get_body_height())
            splash:wait(scroll_delay)
        end   

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
        'DEPTH_LIMIT': 2
    }

    allowed_domains = ['facebook.com']
    pages = ['opiniao.produtora',
            'nopalcors',
            'art.tattoopoa',
            'SerenataIluminada',
            'feiradajoao',
            'CCMQportoalegre',
            'agulha.poa',
            'vilaflorespoa',
            'cinemateca.capitolio',
            'InstitutoLing',
            'GoetheInstitutPortoAlegre',
            'ksacentro',
            'casacinepoa',
            'picnicculturalnomuseu',
            'noitedosmuseus',
            'CentroCulturalUFRGS',
            'mercadovintage',
            'prefpoa',
            'fundacaoiberecamargo',
            'margsmuseu',
            'gretacollective',
            'coletivoarruaca',
            'coletivoplano',
            'fennnnnda',
            'pepsionstageoficial',
            'auditorioaraujovianna',
            'ospabr',
            'teatrodobourboncountry',
            'sesccentro',
            'Bar.Ocidente',
            'comicconrs',
            'bibliotecapublicadoestadors',
            'somosMODAUT',
            'GoetheInstitutPortoAlegre',
            'tonaruamurb',
            'aerofeira',
            'acasacc',
            'ILEAUFRGS',
            'cumbianarua',
            'cccev.rs',
            'forroderuadeportoalegre',
            'ciarusticadeteatro',
            'feiramegusta',
            'MegaRevelRS',
            'viradasustentavelpoa',
            'feiramultipalco',
            'feiralamovida',
            'uxconferencebr',
            'ResultadosDigitais',
            'CODEESCOLA',
            'Uergs',
            'forumdaliberdade',
            'SindilojasPOA',
            'ligadesaudedesportiva',
            'centrodeeventospucrs',
            'revistajadore',
            'FestivaldaCervejaPOA',
            'mercadodepulgaspoa',
            'lojaprofana',
            'casadestemperados',
            'festaacabouchorare',
            'zonaexpfm',
            'gomarec',
            'darumT',
            'basepoas'
            ]

    # random.shuffle(pages)

    def start_requests(self):
        self.log("INITIALIZING...")
        self.log("UA: %s" % user_agents[0])
        yield SplashRequest(
            url='https://www.facebook.com/events/discovery/?city_id=264859',
            callback=self.parse_page,
            endpoint='execute',
            args={
            'timeout': 300,
            'lua_source': parse_page_script,
            'ua': user_agents[0]
            }
        )




    def parse_page(self, response):

        events_in_page = response.xpath('//*[contains(@class, "_7ty")]/@href')

        if not events_in_page:
            self.log("PAGE WITHOUT EVENTS")
        else:
            self.log("PAGE WITH " + str(len(events_in_page)) + " EVENTS")

        for event_link in events_in_page.extract():
            if event_link is not None:
                yield SplashRequest(
                    url=urljoin(response.url, event_link),
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
