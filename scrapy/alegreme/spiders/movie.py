# -*- coding: utf-8 -*-
import scrapy
import base64
import json
import os
import random

from urllib.parse import urljoin
from alegreme.items import Movie, MovieOcurrenceLoader, MoviePlaceLoader, MovieLanguageLoader
from scrapy_splash import SplashRequest
from scrapy.loader import ItemLoader

search_movies_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:set_custom_headers({
                            ['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36',
                            ['accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                            ['accept-language'] = 'pt-BR,pt;q=0.9,pt;q=0.8'
                            })

        assert(splash:go(splash.args.url))

        assert(splash:wait(1))
        splash.scroll_position = {y=500}

        result, error = splash:wait_for_resume([[
            function main(splash) {
                var checkExist = setInterval(function() {
                    if (document.querySelector(".QagNAb").innerText) {
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


parse_movie_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:set_custom_headers({
                            ['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36',
                            ['accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                            ['accept-language'] = 'pt-BR,pt;q=0.9,pt;q=0.8'
                            })

        assert(splash:go(splash.args.url))

        assert(splash:wait(1))
        splash.scroll_position = {y=500}

        result, error = splash:wait_for_resume([[
            function main(splash) {
                var checkExist = setInterval(function() {
                    if (document.querySelector(".tb_c.tb_stc").innerText) {
                        clearInterval(checkExist);
                                                splash.resume();
                    }
                }, 2000);
            }
        ]], 30)

        assert(splash:wait(0.5))
        splash:runjs("window.close()")
        return splash:html()
    end
"""

parse_movie_cover_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:set_custom_headers({
                            ['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36',
                            ['accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                            ['accept-language'] = 'pt-BR,pt;q=0.9,pt;q=0.8'
                            })

        assert(splash:go(splash.args.url))

        assert(splash:wait(1))
        splash.scroll_position = {y=500}

        result, error = splash:wait_for_resume([[
            function main(splash) {
                var checkExist = setInterval(function() {
                    if (document.querySelectorAll(".irc_mi")[1].src !== "") {
                        clearInterval(checkExist);
                        splash.resume();
                    }
                }, 2000);
            }
        ]], 15)

        assert(splash:wait(1))
        splash:runjs("window.close()")
        return splash:html()
    end
"""

class MovieSpider(scrapy.Spider):
    http_user = 'jon'
    http_pass = 'password'

    name = 'movie'

    custom_settings = {
        'ITEM_PIPELINES': {
            'alegreme.pipelines.MoviePipeline': 400
        },
        'CLOSESPIDER_ITEMCOUNT': 2
    }

    allowed_domains = ['google.com']
    start_urls = ['https://www.google.com/search?q=filmes+porto+alegre+cinema']

    def start_requests(self):
        for url in self.start_urls:
            yield SplashRequest(
                url=url,
                callback=self.parse_movies,
                endpoint='execute',
                args={
                'timeout': 90,
                'lua_source': search_movies_script,
                }
            )


    def parse_movies(self, response):

        movie_links = response.xpath('//*[contains(@class, "MiPcId")]/@href')

        for movie_link in movie_links.extract():
            if movie_link is not None:
                yield SplashRequest(
                    url=urljoin(response.url, movie_link),
                    callback=self.parse_movie,
                    endpoint='execute',
                    args={
                        'lua_source': parse_movie_script,
                    }
                )


    def parse_movie(self, response):
        movie_container_el = response.xpath('(//*[contains(@class, "lr_container")])[1]')
        movie_right_card_el = response.xpath('(//*[contains(@class, "EyBRub")])[1]')
        movie_cover_link = response.xpath('//a[contains(@class, "bia")]/@href').get()

        loader = ItemLoader(item=Movie(), selector=movie_container_el)
        loader.add_xpath('name', './/*[contains(@class, "lr_c_h")]/span/text()')

        if movie_right_card_el is not None:
            loader.add_value('description', movie_right_card_el.xpath('.//*[contains(@class, "kno-rdesc")]/div/span/text()').get())
            loader.add_value('trailler', movie_right_card_el.xpath('.//*[contains(@class, "B1uW2d")]/@href').get())
            loader.add_value('genre', movie_right_card_el.xpath('.//*[contains(@class, "wwUB2c")]/span/text()').get())

        movie_dates_els = movie_container_el.xpath('.//*[contains(@class, "tb_c")]')
        for movie_date_el in movie_dates_els:
            loader.add_value('dates', self.parse_ocurrence_meta(response, movie_date_el))

        if movie_cover_link:
            yield SplashRequest(
                url=urljoin(response.url, movie_cover_link),
                callback=self.parse_cover_meta,
                dont_filter=True,
                meta={'loader': loader},
                endpoint='execute',
                args={
                    'lua_source': parse_movie_cover_script,
                }
            )
        else:
            yield loader.load_item()


    def parse_ocurrence_meta(self, response, movie_container):
        occurrence_loader = MovieOcurrenceLoader(selector=movie_container)
        occurrence_loader.add_xpath('date', './/*[contains(@class, "std-ds")]/@data-date')

        places_els = movie_container.xpath('.//*[contains(@class, "lr_c_fcb")]')
        for place_el in places_els:
            occurrence_loader.add_value('places', self.parse_place_meta(response, place_el))

        return dict(occurrence_loader.load_item())


    def parse_place_meta(self, response, place_el):
        place_loader = MoviePlaceLoader(selector=place_el)
        place_loader.add_xpath('name', './/*[contains(@class, "lr-s-din")]/text()')
        place_loader.add_value('address', urljoin(response.url, place_el.xpath('.//*[contains(@class, "ObBBIf")]/a/@href')[0].extract()))

        languages_els = place_el.xpath('.//*[contains(@class, "YHR1ce")]')
        for index, language_el in enumerate(languages_els):
            place_loader.add_value('languages', self.parse_language_meta(response, place_el, index))

        return dict(place_loader.load_item())

    def parse_language_meta(self, response, place_el, index):
        language_loader = MovieLanguageLoader()
        language_loader.add_value('name', place_el.xpath('.//*[contains(@class, "YHR1ce")]/text()')[index].extract())
        language_loader.add_value('screen_type', place_el.xpath('.//*[contains(@class, "lr_c_vn")]/text()')[index].extract())
        language_loader.add_value('times', place_el.xpath('.//*[contains(@class, "lr_c_s")]')[index].xpath('.//*[contains(@class, "std-ts")]/text()').extract())
        return dict(language_loader.load_item())

    def parse_cover_meta(self, response):
        loader = response.meta['loader']
        loader.add_value('cover', urljoin(response.url, response.xpath('.//*[contains(@class, "irc_mi")]/@src').get()))
        return loader.load_item()
