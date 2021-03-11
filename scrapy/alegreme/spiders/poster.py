# -*- coding: utf-8 -*-
import scrapy
import base64
import json
import os
import random
# import shadow_useragent

from urllib.parse import urljoin, urlencode
from alegreme.items import Poster, PosterMediaLoader, PosterOwnerLoader
from scrapy.loader import ItemLoader
from scrapy_splash import SplashRequest

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

parse_profile_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 120
        splash:set_user_agent(tostring(args.ua))
        splash:set_custom_headers({
              ["cache-control"] = "max-age=0",
              ["sec-ch-ua"] = "'Chromium';v='88', 'Google Chrome';v='88', ';Not A Brand';v='99'",
              ["sec-ch-ua-mobile"] = "?0",
              ["upgrade-insecure-requests"] = "1",
              ["accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
              ["sec-fetch-site"] = "same-origin",
              ["sec-fetch-mode"] = "navigate",
              ["sec-fetch-dest"] = "document",
              ["accept-language"] = "pt,en;q=0.9",
              ["cookie"] = "ig_did=D1AD10B5-D91C-479C-A7EC-CC595408D6EF; mid=X9wAxwALAAGv2A6q4uyAEsP0F7HL; ig_nrcb=1; fbm_124024574287414=base_domain=.instagram.com; csrftoken=JAKfsRhfC7XWENHgnHmhMNv5DFYQPYMN; ds_user_id=35455758; sessionid=35455758%3AiUtw0AEJvxh2Om%3A22; shbid=1210; shbts=1614775735.1368215; rur=PRN; fbsr_124024574287414=csQsdfEHNZSXddW33yH491VDCAlpNW9h04Dv9LwTQcs.eyJ1c2VyX2lkIjoiMTAwMDAwMzU3ODkxOTQ4IiwiY29kZSI6IkFRRDlOU2NfcXFWWTVhcS1GOUNBQ2xWMlJ4VmRYTW15d3p1OHJ3SWJZeHJENUtPZHFuU2ZCU213UHRNZkVwRjJyUllQX1BHRWtQSjJXYXBmYUFaQzBuODUwVWh1OG1yWHBxRjlzanRKaERzWHVaRHM0eUd1bXplM2VmVGYzTU5MaWhuU29VSDcyNmJYZWtST1VwVFRsZ2tEX0o5VHZXZ3NSZXNtRk9YX21MNXZUVW1FS01FanJaRlNUOVFjV09nZGpHY0dfN3NNY2lOVklKQ19ienB4bWp1X3IyaGJWX3FjMUVJQXhlcW5tZzhYdjNCTk5URXZPWUllOVM1Q0pNZFAyZlM0QkxvMlNTT2EwLVREdWhhUWFNUXI3dGNZTjc5STYxdmV1TWQ1T2oxTk1qUlJ1ME0wMVFMQk82Si1PU09fakVnVEdFM2VKTFhfSGdZRmROM1F2aEEyd0M0dFFla1ctNi1ENUZLRW1kR0JCUSIsIm9hdXRoX3Rva2VuIjoiRUFBQnd6TGl4bmpZQkFFR3A5RzVaQm1FeGVoaWhQbGpCUXBoTGRJcjhzZURQWkFSbDZxcUMwcHBUN25PZjRmNEd0QkZhSkdSUVFSMTMydzJVVGJyRmNwclMxTTh0N1JZWkJuMDhLU01wdlpBY0tuWkNlUnEybWQyQk5jRExBOThwelpCWkNiSXR4NVREaWg0cDZjaExvODYwbDM3Zmw1dG1mc0JCU2VyZWF3a2RoRlJ0WW9NUVBqN1lnaURKZWxEMGdZWkQiLCJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImlzc3VlZF9hdCI6MTYxNDk1ODc4M30"
            })
        assert(splash:go(splash.args.url))
        assert(splash:wait(15))

        return splash:html()
    end
"""

parse_poster_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 120
        splash:set_user_agent(tostring(args.ua))
        splash:set_custom_headers({
              ["cache-control"] = "max-age=0",
              ["sec-ch-ua"] = "'Chromium';v='88', 'Google Chrome';v='88', ';Not A Brand';v='99'",
              ["sec-ch-ua-mobile"] = "?0",
              ["upgrade-insecure-requests"] = "1",
              ["accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
              ["sec-fetch-site"] = "same-origin",
              ["sec-fetch-mode"] = "navigate",
              ["sec-fetch-dest"] = "document",
              ["accept-language"] = "pt,en;q=0.9",
              ["cookie"] = "ig_did=D1AD10B5-D91C-479C-A7EC-CC595408D6EF; mid=X9wAxwALAAGv2A6q4uyAEsP0F7HL; ig_nrcb=1; fbm_124024574287414=base_domain=.instagram.com; csrftoken=JAKfsRhfC7XWENHgnHmhMNv5DFYQPYMN; ds_user_id=35455758; sessionid=35455758%3AiUtw0AEJvxh2Om%3A22; shbid=1210; shbts=1614775735.1368215; rur=PRN; fbsr_124024574287414=csQsdfEHNZSXddW33yH491VDCAlpNW9h04Dv9LwTQcs.eyJ1c2VyX2lkIjoiMTAwMDAwMzU3ODkxOTQ4IiwiY29kZSI6IkFRRDlOU2NfcXFWWTVhcS1GOUNBQ2xWMlJ4VmRYTW15d3p1OHJ3SWJZeHJENUtPZHFuU2ZCU213UHRNZkVwRjJyUllQX1BHRWtQSjJXYXBmYUFaQzBuODUwVWh1OG1yWHBxRjlzanRKaERzWHVaRHM0eUd1bXplM2VmVGYzTU5MaWhuU29VSDcyNmJYZWtST1VwVFRsZ2tEX0o5VHZXZ3NSZXNtRk9YX21MNXZUVW1FS01FanJaRlNUOVFjV09nZGpHY0dfN3NNY2lOVklKQ19ienB4bWp1X3IyaGJWX3FjMUVJQXhlcW5tZzhYdjNCTk5URXZPWUllOVM1Q0pNZFAyZlM0QkxvMlNTT2EwLVREdWhhUWFNUXI3dGNZTjc5STYxdmV1TWQ1T2oxTk1qUlJ1ME0wMVFMQk82Si1PU09fakVnVEdFM2VKTFhfSGdZRmROM1F2aEEyd0M0dFFla1ctNi1ENUZLRW1kR0JCUSIsIm9hdXRoX3Rva2VuIjoiRUFBQnd6TGl4bmpZQkFFR3A5RzVaQm1FeGVoaWhQbGpCUXBoTGRJcjhzZURQWkFSbDZxcUMwcHBUN25PZjRmNEd0QkZhSkdSUVFSMTMydzJVVGJyRmNwclMxTTh0N1JZWkJuMDhLU01wdlpBY0tuWkNlUnEybWQyQk5jRExBOThwelpCWkNiSXR4NVREaWg0cDZjaExvODYwbDM3Zmw1dG1mc0JCU2VyZWF3a2RoRlJ0WW9NUVBqN1lnaURKZWxEMGdZWkQiLCJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImlzc3VlZF9hdCI6MTYxNDk1ODc4M30"
            })
        assert(splash:go(splash.args.url))
        assert(splash:wait(15))
        splash.scroll_position = {y=1000}

        return splash:html()
    end
"""

API = 'eaef109c-dac0-499d-b14c-826a17e18d30'

def get_url(url):
    payload = {'api_key': API, 'url': url, 'timeout': 10000, 'proxy': 'residential'}
    proxy_url = 'https://api.webscraping.ai/html?' + urlencode(payload)
    return proxy_url



class PosterSpider(scrapy.Spider):
    http_user = 'jon'
    http_pass = 'password'

    name = 'poster'

    custom_settings = {
        'ITEM_PIPELINES': {
            'alegreme.pipelines.PosterPipeline': 400
        },
        'CLOSESPIDER_ITEMCOUNT': 500,
        'DEPTH_LIMIT': 2
    }

    allowed_domains = ['www.instagram.com']
    start_urls = ['https://www.instagram.com/ksacentro/',
                  'https://www.instagram.com/opiniao/',
                  'https://www.instagram.com/espacocultural512/',
                  'https://www.instagram.com/ceubarearte/',
                  'https://www.instagram.com/ocidente/',
                  'https://www.instagram.com/venepubcafe/',
                  'https://www.instagram.com/vonteesebar/',
                  'https://www.instagram.com/agulha.poa/',
                  'https://www.instagram.com/justo741/',
                  'https://www.instagram.com/vilaflorespoa/',
                  'https://www.instagram.com/agridocecafe/',
                  'https://www.instagram.com/cinematecacapitolio/',
                  'https://www.instagram.com/fae.feiraecologica/',
                  'https://www.instagram.com/firma.bar/',
                  'https://www.instagram.com/coletivoplano/',
                  'https://www.instagram.com/coletivoarruaca/',
                  'https://www.instagram.com/ccmarioquintana/',
                  'https://www.instagram.com/coletivoturmalina/',
                  'https://www.instagram.com/coletivosauva/',
                  'https://www.instagram.com/museumargs/',
                  'https://www.instagram.com/fundacaoibere/',
                  'https://www.instagram.com/teatrosaopedro/',
                  'https://www.instagram.com/instituto.ling/',
                  'https://www.instagram.com/ospabr/']

    random.shuffle(start_urls)

    def start_requests(self):
        self.log("INITIALIZING...")
        self.log("UA: %s" % ua)
        for url in self.start_urls:
            yield SplashRequest(
                url=url,
                callback=self.parse_profile,
                endpoint='execute',
                args={
                'timeout': 120,
                'lua_source': parse_profile_script,
                'ua': ua
                }
            )


    def parse_profile(self, response):
        x = response.xpath("//script[starts-with(.,'window._sharedData')]/text()").get()
        json_string = x.strip().split('= ')[1][:-1]
        data = json.loads(json_string)['entry_data']['ProfilePage'][0]['graphql']['user']['edge_owner_to_timeline_media']['edges']
    
        if not data:
            self.log("PAGE WITHOUT POSTERS")

        for poster_data in data[:6]:
            if 'node' in poster_data:
                yield SplashRequest(
                    url=urljoin(response.url, f"/p/{poster_data['node']['shortcode']}"),
                    callback=self.parse_poster,
                    endpoint='execute',
                    args={
                    'timeout': 120,
                    'lua_source': parse_poster_script,
                    'ua': ua
                    }
                )
                pass
            else:
                pass


    def parse_poster(self, response):
        poster_loader = ItemLoader(item=Poster(), response=response)

        x = response.xpath("//script[starts-with(.,'window.__additionalDataLoaded')]/text()").get()
        json_string = x.strip().split(",", 1)[1][:-2]
        data = json.loads(json_string)['graphql']['shortcode_media']

        poster_loader.add_value('shortcode', data['shortcode'])
        poster_loader.add_value('caption', data['edge_media_to_caption']['edges'][0]['node']['text'])
        poster_loader.add_value('taken_at_timestamp', data['taken_at_timestamp'])
        poster_loader.add_value('source_url', response.url)
        poster_loader.add_value('location', data['location'])

        poster_loader.add_value('owner', self.parse_owner_meta(response, data['owner']))

        if 'edge_sidecar_to_children' in data:
            media_edges = data['edge_sidecar_to_children']['edges']
            for media in media_edges:
                poster_loader.add_value('media', self.parse_media_meta(response, media))
        if 'display_url' in data:
            poster_loader.add_value('media', self.parse_media_meta(response, data))

        poster_loader.load_item()
        poster = poster_loader.item
        yield poster
   

    def parse_media_meta(self, response, media):
        if 'node' in media:
            media_data = media['node']
        else:
            media_data = media

        poster_media_loader = PosterMediaLoader()
        poster_media_loader.add_value('is_video', media_data['is_video'])
        poster_media_loader.add_value('display_url', media_data['display_url'])
        if 'video_url' in media_data: poster_media_loader.add_value('video_url', media_data['video_url'])

        return dict(poster_media_loader.load_item())

    
    def parse_owner_meta(self, response, owner):
        poster_owner_loader = PosterOwnerLoader()
        poster_owner_loader.add_value('full_name', owner['full_name'])
        poster_owner_loader.add_value('profile_pic_url', owner['profile_pic_url'])
        poster_owner_loader.add_value('username', owner['username'])

        return dict(poster_owner_loader.load_item())
