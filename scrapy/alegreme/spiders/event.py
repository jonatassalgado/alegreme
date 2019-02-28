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
    start_urls = ['https://www.facebook.com/events/560795694396186',
                  'https://www.facebook.com/events/400025397235588',
                  'https://www.facebook.com/events/313565609288915',
                  'https://www.facebook.com/events/373799036764008',
                  'https://www.facebook.com/events/413168566085862']

    def start_requests(self):
        for url in self.start_urls:
            yield SplashRequest(
                url=url,
                callback=self.parse,
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

    def parse(self, response):

        # dates = response.xpath('//*[@class="_4-u3"]//*[@class="_5x8v _5a4_ _5a5j"]/@title')
        # times = response.xpath('//*[@class="_4-u3"]//*[@class="_62pa"]/text()')

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
        loader.add_xpath('description', '//*[@class="_63ew"]//span/text()')
        loader.add_xpath('categories', '//li[@class="_63ep _63eq"]/a/text()')
        loader.add_value('event_url', response.url)


        loader.load_item()

        event = loader.item
        self.log("EVENT CRAWLED: %s" % event)

        yield event

        # if 'address' in event and "Porto Alegre" in event['address']:
            # yield event
        # else:
            # pass


        related_events_links = response.xpath('//div[@id="event_related_events"]//div[contains(@class, "SuggestionItem")]/a/@href')

        for event_link in related_events_links.extract():
            if event_link is not None:
                yield SplashRequest(
                    url=urljoin(response.url, event_link),
                    callback=self.parse,
                    args={
                    'wait': 12,
                    'html': 1,
                    'images_enabled': 0
                    }
                )
                pass
            else:
                pass
