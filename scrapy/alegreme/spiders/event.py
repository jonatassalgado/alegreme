# -*- coding: utf-8 -*-
import scrapy
import base64
import json
import os
import random

from urllib.parse import urljoin
from alegreme.items import Event
from scrapy_splash import SplashRequest
from scrapy.loader import ItemLoader

parse_event_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:set_custom_headers({
                            ['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/602.1 (KHTML, like Gecko) splash Version/9.0 Safari/602.1',
                            ['accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                            ['accept-language'] = 'en-US,en;q=0.9,pt;q=0.8'
                            })

        assert(splash:go(splash.args.url))

        assert(splash:wait(1))
        splash.scroll_position = {y=500}

        result, error = splash:wait_for_resume([[
            function main(splash) {
                var checkExist = setInterval(function() {
                    if (document.querySelector("._63ew").innerText) {
                        clearInterval(checkExist);
                                                splash.resume();
                    }
                }, 1000);
            }
        ]], 30)

        assert(splash:wait(0.5))

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
        splash.resource_timeout = 60
        splash:set_custom_headers({
                            ['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/602.1 (KHTML, like Gecko) splash Version/9.0 Safari/602.1',
                            ['accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                            ['accept-language'] = 'en-US,en;q=0.9,pt;q=0.8'
                            })

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

        return splash:html()
    end
"""

class EventSpider(scrapy.Spider):
    name = 'event'
    allowed_domains = ['facebook.com']
    start_urls = ['https://www.facebook.com/pg/SerenataIluminada/events',
                  'https://www.facebook.com/pg/CCMQportoalegre/events',
                  'https://www.facebook.com/pg/agulha.poa/events',
                  'https://www.facebook.com/pg/vilaflorespoa/events',
                  'https://www.facebook.com/pg/cinemateca.capitolio/events',
                  'https://www.facebook.com/pg/InstitutoLing/events',
                  'https://www.facebook.com/pg/GoetheInstitutPortoAlegre/events',
                  'https://www.facebook.com/pg/ksacentro/events',
                  'https://www.facebook.com/pg/casacinepoa/events',
                  'https://www.facebook.com/pg/picnicculturalnomuseu/events',
                  'https://www.facebook.com/pg/noitedosmuseus/events',
                  'https://www.facebook.com/pg/CentroCulturalUFRGS/events',
                  'https://www.facebook.com/pg/mercadovintage/events',
                  'https://www.facebook.com/pg/prefpoa/events',
                  'https://www.facebook.com/pg/fundacaoiberecamargo/events',
                  'https://www.facebook.com/pg/margsmuseu/events',
                  'https://www.facebook.com/pg/gretacollective/events',
                  'https://www.facebook.com/pg/coletivoarruaca/events',
                  'https://www.facebook.com/pg/coletivoplano/events',
                  'https://www.facebook.com/pg/baropiniao/events',
                  'https://www.facebook.com/pg/fennnnnda/events',
                  'https://www.facebook.com/pg/pepsionstageoficial/events',
                  'https://www.facebook.com/pg/auditorioaraujovianna/events',
                  'https://www.facebook.com/pg/ospabr/events',
                  'https://www.facebook.com/pg/teatrodobourboncountry/events',
                  'https://www.facebook.com/pg/sesccentro/events',
                  'https://www.facebook.com/pg/Bar.Ocidente/events',
                  'https://www.facebook.com/pg/comicconrs/events',
                  'https://www.facebook.com/pg/bibliotecapublicadoestadors/events',
                  'https://www.facebook.com/pg/somosMODAUT/events',
                  'https://www.facebook.com/pg/GoetheInstitutPortoAlegre/events',
                  'https://www.facebook.com/pg/tonaruamurb/events',
                  'https://www.facebook.com/pg/aerofeira/events/',
                  'https://www.facebook.com/pg/acasacc/events',
                  'https://www.facebook.com/pg/ILEAUFRGS/events',
                  'https://www.facebook.com/pg/cumbianarua/events',
                  'https://www.facebook.com/pg/cccev.rs/events',
                  'https://www.facebook.com/pg/forroderuadeportoalegre/events',
                  'https://www.facebook.com/pg/ciarusticadeteatro/events',
                  'https://www.facebook.com/pg/feiramegusta/events',
                  'https://www.facebook.com/pg/MegaRevelRS/events',
                  'https://www.facebook.com/pg/viradasustentavelpoa/events',
                  'https://www.facebook.com/pg/feiramultipalco/events',
                  'https://www.facebook.com/pg/feiralamovida/events',
                  'https://www.facebook.com/pg/uxconferencebr/events',
                  'https://www.facebook.com/pg/ResultadosDigitais/events',
                  'https://www.facebook.com/pg/CODEESCOLA/events',
                  'https://www.facebook.com/pg/Uergs/events',
                  'https://www.facebook.com/pg/forumdaliberdade/events',
                  'https://www.facebook.com/pg/SindilojasPOA/events',
                  'https://www.facebook.com/pg/ligadesaudedesportiva/events',
                  'https://www.facebook.com/pg/centrodeeventospucrs/events/']
    
    random.shuffle(start_urls)

    def start_requests(self):
        for url in self.start_urls:
            yield SplashRequest(
                url=url,
                callback=self.parse_page,
                endpoint='execute',
                args={
                'timeout': 90,
                'lua_source': parse_page_script,
                }
            )


    

    def parse_page(self, response):
       
        events_in_page = response.xpath('//*[contains(@id, "recurring_events_card")]//*[contains(@class, "_2l3f")]/a/@href | //*[@id="upcoming_events_card"]//*[contains(@class, "_4dmk")]/a/@href')

        for event_link in events_in_page.extract():
            if event_link is not None:
                yield SplashRequest(
                    url=urljoin(response.url, event_link),
                    callback=self.parse_event,
                    endpoint='execute',
                    args={
                    'timeout': 90,
                    'lua_source': parse_event_script,
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


        loader = ItemLoader(item=Event(), response=response)
        loader.add_xpath('name', '//title[1]/text()')
        loader.add_xpath('cover_url', '//*[contains(@class, "uiScaledImageContainer")]//*[contains(@class, "scaledImageFit")]/@src')
        loader.add_xpath('address', '//*[@id="event_summary"]//div[@class="_5xhp fsm fwn fcg"][1]/text()')
        loader.add_xpath('datetimes', '//*[@id="event_time_info"]//div[@class="_2ycp _5xhk"][1]/text()')
        loader.add_xpath('dates', '//*[@class="_4-u3"]//*[@class="_5x8v _5a4_ _5a5j"]/@title')
        loader.add_xpath('times', '//*[@class="_4-u3"]//*[@class="_62pa"]/text()')
        loader.add_xpath('place', '//*[@id="event_summary"]//a[@class="_5xhk"][1]/text()')
        loader.add_xpath('organizers', '//*[@class="_62hs _4-u3"]//*[@class="_hty"]//a/text()')
        loader.add_xpath('organizers_fallback_a', '//*[@class="_2xq3"]/text()')
        loader.add_xpath('description', '//*[@class="_63ew"]//span')
        loader.add_xpath('prices', '//*[@id="event_summary"]//*[@class="_20zc"]/text()')
        loader.add_xpath('categories', '//li[@class="_63ep _63eq"]/a/text()')
        loader.add_value('source_url', response.url)
        loader.load_item()

        event = loader.item
        self.log("EVENT CRAWLED: %s" % event)

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
