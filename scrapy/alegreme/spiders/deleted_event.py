# -*- coding: utf-8 -*-
import scrapy
import base64
import json
import os
import random
import requests
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

        local signinText = splash:select('._585r._50f4')

        if signinText == nil then
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

class DeletedEventSpider(scrapy.Spider):
    http_user = 'alegreme'
    http_pass = 've97K8bCwNkNgQSqvMkYRryMG4MQuQGU'

    name = 'deleted_event'

    custom_settings = {
        'ITEM_PIPELINES': {
            'alegreme.pipelines.DeletedEventPipeline': 400
        },
        'CLOSESPIDER_ITEMCOUNT': 100,
        'DEPTH_LIMIT': 2
    }

    allowed_domains = ['facebook.com']
    active_events = requests.get(url="http://" + os.environ.get('DOMAIN') + "/api/events.json")
    start_urls = []

    for item in active_events.json()['items']:
        start_urls.append(item['source'])

    random.shuffle(start_urls)


    def start_requests(self):
        self.log("INITIALIZING...")
        self.log(self.start_urls)
        self.log("UA: %s" % ua)
        for url in self.start_urls:
            yield SplashRequest(
                url=url,
                callback=self.parse_event,
                endpoint='execute',
                args={
                'timeout': 200,
                'lua_source': parse_event_script,
                'ua': ua
                }
            )



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
        else:
            event_loader.add_value('deleted', 'false')
            event_loader.add_value('source_url', response.url)
            event_loader.load_item()
            event = event_loader.item
            self.log("EVENT ATIVO: %s" % event)
            yield event