# -*- coding: utf-8 -*-
import scrapy
import base64
import json
import os

from urllib.parse import urljoin
from alegreme.items import Event
from scrapy_splash import SplashRequest
from scrapy.loader import ItemLoader



class EventSpider(scrapy.Spider):
    name = 'event'
    allowed_domains = ['facebook.com']
    start_urls = ['https://www.facebook.com/pg/SerenataIluminada/events',
                  'https://www.facebook.com/pg/cinemateca.capitolio/events',
                  'https://www.facebook.com/pg/ksacentro/events',
                  'https://www.facebook.com/pg/vilaflorespoa/events',
                  'https://www.facebook.com/pg/casacinepoa/events',
                  'https://www.facebook.com/pg/picnicculturalnomuseu/events',
                  'https://www.facebook.com/pg/noitedosmuseus/events',
                  'https://www.facebook.com/pg/CCMQportoalegre/events',
                  'https://www.facebook.com/pg/mercadovintage/events',
                  'https://www.facebook.com/pg/feiramegusta/events',
                  'https://www.facebook.com/pg/MegaRevelRS/events',
                  'https://www.facebook.com/pg/acasacc/events',
                  'https://www.facebook.com/pg/agulha.poa/events',
                  'https://www.facebook.com/pg/cumbianarua/events',
                  'https://www.facebook.com/pg/cccev.rs/events',
                  'https://www.facebook.com/pg/forroderuadeportoalegre/events',
                  'https://www.facebook.com/pg/fundacaoiberecamargo/events',
                  'https://www.facebook.com/pg/margsmuseu/events',
                  'https://www.facebook.com/pg/ciarusticadeteatro/events',
                  'https://www.facebook.com/pg/InstitutoLing/events',
                  'https://www.facebook.com/pg/GoetheInstitutPortoAlegre/events',
                  'https://www.facebook.com/pg/viradasustentavelpoa/events',
                  'https://www.facebook.com/pg/CentroCulturalUFRGS/events',
                  'https://www.facebook.com/pg/feiramultipalco/events',
                  'https://www.facebook.com/pg/feiralamovida/events',
                  'https://www.facebook.com/pg/gretacollective/events',
                  'https://www.facebook.com/pg/coletivoarruaca/events',
                  'https://www.facebook.com/pg/coletivoplano/events',
                  'https://www.facebook.com/pg/fennnnnda/events',
                  'https://www.facebook.com/pg/uxconferencebr/events',
                  'https://www.facebook.com/pg/ResultadosDigitais/events',
                  'https://www.facebook.com/pg/CODEESCOLA/events',
                  'https://www.facebook.com/pg/Uergs/events',
                  'https://www.facebook.com/pg/forumdaliberdade/events',
                  'https://www.facebook.com/pg/SindilojasPOA/events',
                  'https://www.facebook.com/pg/prefpoa/events',
                  'https://www.facebook.com/pg/centrodeeventospucrs/events/']

    def start_requests(self):
        for url in self.start_urls:
            yield SplashRequest(
                url=url,
                callback=self.parse_page,
                headers={
                    'user-agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/602.1 (KHTML, like Gecko) splash Version/9.0 Safari/602.1',
                    'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                    'accept-language': 'en-US,en;q=0.9,pt;q=0.8'
                    },
                args={
                'wait': 12,
                'html': 1,
                'images_enabled': 0
            })


    def parse_page(self, response):
        events_in_page = response.xpath('//*[contains(@id, "recurring_events_card")]//*[contains(@class, "_2l3f")]/a/@href | //*[@id="upcoming_events_card"]//*[contains(@class, "_4dmk")]/a/@href')

        for event_link in events_in_page.extract():
            if event_link is not None:
                yield SplashRequest(
                    url=urljoin(response.url, event_link),
                    callback=self.parse_event,
                    args={
                    'wait': 12,
                    'html': 1,
                    'images_enabled': 0
                    }
                )
                pass
            else:
                pass


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
                    args={
                    'wait': 12,
                    'html': 1,
                    'images_enabled': 0
                    }
                )
                pass
            else:
                pass
