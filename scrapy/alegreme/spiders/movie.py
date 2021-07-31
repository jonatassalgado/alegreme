# -*- coding: utf-8 -*-
import scrapy
import re
import logging

from unidecode import unidecode
from urllib.parse import urljoin
from alegreme.items import Movie, MovieOcurrenceLoader, MoviePlaceLoader, MovieLanguageLoader
from scrapy_splash import SplashRequest
from scrapy.loader import ItemLoader
from itemloaders.processors import TakeFirst

search_movies_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.js_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:on_request(function(request)
            if string.find(request.url, ".css") ~= nil or 
               string.find(request.url, ".woff2") ~= nil then
                request.abort()
            end
        end)
        splash:set_custom_headers({
                            ['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36',
                            ['accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                            ['accept-language'] = 'pt-BR,pt;q=0.9,pt;q=0.8'
                            })

        assert(splash:go(splash.args.url))

        assert(splash:wait(1))
        splash.scroll_position = {y=500}
        assert(splash:wait(3))

        result, error = splash:wait_for_resume([[
            function main(splash) {
                var checkExist = setInterval(function() {
                    if (document.querySelector(".klitem").innerHTML && document.querySelector(".kno-rdesc").innerHTML) {
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


parse_movie_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:on_request(function(request)
            if string.find(request.url, ".css") ~= nil or 
               string.find(request.url, ".woff2") ~= nil then
                request.abort()
            end
        end)

        splash:set_custom_headers({
                            ['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36',
                            ['accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                            ['accept-language'] = 'pt-BR,pt;q=0.9,pt;q=0.8'
                            })

        assert(splash:go(splash.args.url))

        assert(splash:wait(1))
        splash.scroll_position = {y=500}
        assert(splash:wait(3))

        result, error = splash:wait_for_resume([[
            function main(splash) {
                var checkExist = setInterval(function() {
                    if (document.querySelector(".tb_c.tb_stc").innerText && document.querySelector(".kno-rdesc").innerHTML) {
                        clearInterval(checkExist);
                        splash.resume();
                    }
                }, 2000);
            }
        ]], 30)

        assert(splash:wait(3))
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
        splash:on_request(function(request)
            if string.find(request.url, ".css") ~= nil or 
               string.find(request.url, ".woff2") ~= nil then
                request.abort()
            end
        end)

        splash:set_custom_headers({
                            ['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36',
                            ['accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                            ['accept-language'] = 'pt-BR,pt;q=0.9,pt;q=0.8'
                            })

        assert(splash:go(splash.args.url))

        splash.scroll_position = {y=200}

        result, error = splash:wait_for_resume([[
            function main(splash) {
                var checkExist = setInterval(function() {
                    if (document.querySelector('.tile--img__media')) {
                        clearInterval(checkExist);
                        splash.resume();
                    }
                }, 2000);
            }
        ]], 30)

        local cover = splash:select('.tile--img__media')
        cover:mouse_click()

        result, error = splash:wait_for_resume([[
            function main(splash) {
                var checkExist = setInterval(function() {
                    if (document.querySelector('.detail__pane .c-detail__desc .c-detail__btn').innerText) {
                        clearInterval(checkExist);
                        splash.resume();
                    }
                }, 2000);
            }
        ]], 30)

        return splash:html()
    end
"""

parse_imdb_rating_script = """
    function main(splash, args)
        splash.private_mode_enabled = false
        splash.images_enabled = false
        splash.plugins_enabled = false
        splash.html5_media_enabled = false
        splash.media_source_enabled = false
        splash.resource_timeout = 60
        splash:on_request(function(request)
            if string.find(request.url, ".css") ~= nil or 
               string.find(request.url, ".js") ~= nil or
               string.find(request.url, "doubleclick") ~= nil or
               string.find(request.url, "images-amazon") ~= nil or
               string.find(request.url, "media-amazon") ~= nil or
               string.find(request.url, "moatads") ~= nil or
               string.find(request.url, ".woff2") ~= nil then
                request.abort()
            end
        end)

        splash:set_custom_headers({
                            ['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36',
                            })

        assert(splash:go(splash.args.url))
        
        assert(splash:wait(0.5))
        splash.scroll_position = {y=150}

        result, error = splash:wait_for_resume([[
            function main(splash) {
                var checkExist = setInterval(function() {
                    if (document.querySelector(".result_text a").innerHTML) {
                        clearInterval(checkExist);
                        splash.resume();
                    }
                }, 1000);
            }
        ]], 30)

       
        local first_result = splash:select('.result_text a')
	    first_result:mouse_click()
        
        assert(splash:wait(3))

        result, error = splash:wait_for_resume([[
            function main(splash) {
                var checkExist = setInterval(function() {
                    if (document.querySelector('span[class*="AggregateRatingButton__RatingScore"]').innerText) {
                        clearInterval(checkExist);
                        splash.resume();
                    }
                }, 1000);
            }
        ]], 30)

        return splash:html()
    end
"""

class MovieSpider(scrapy.Spider):
    http_user = 'alegreme'
    http_pass = 've97K8bCwNkNgQSqvMkYRryMG4MQuQGU'

    name = 'movie'

    custom_settings = {
        'ITEM_PIPELINES': {
            'alegreme.pipelines.MoviePipeline': 400
        },
        'CLOSESPIDER_ITEMCOUNT': 50,
        'CLOSESPIDER_PAGECOUNT': 70
    }

    allowed_domains = ['google.com']
    start_urls = ['https://www.google.com/search?q=cinema+porto+alegre+programação']

    def start_requests(self):
        for url in self.start_urls:
            yield SplashRequest(
                url=url,
                callback=self.parse_movies,
                endpoint='execute',
                args={
                'timeout': 300,
                'lua_source': search_movies_script,
            }
        )

    def parse_movies(self, response):

        movie_links = response.xpath('//*[contains(@class, "BVG0Nb")]/@href')

        self.log("PAGE WITH " + str(len(movie_links)) + " MOVIES")

        for movie_link in movie_links.getall():
            if movie_link is not None:
                yield SplashRequest(
                    url=urljoin(response.url, movie_link),
                    callback=self.parse_movie,
                    endpoint='execute',
                    args={
                        'timeout': 300,
                        'lua_source': parse_movie_script,
                    }
                )


    def parse_movie(self, response):
        movie_container_el = response.xpath('(//*[contains(@class, "fjnsEe")])[1]')
        movie_right_card_el = response.xpath('(//*[contains(@class, "kp-wholepage")])[1]')

        loader = ItemLoader(item=Movie(), selector=movie_container_el)
        loader.add_xpath('name', './/*[contains(@class, "lr_c_h")]/span/text()')


        if movie_right_card_el is not None:
            loader.add_value('description', movie_right_card_el.xpath('substring-after(string(.//*[contains(@class, "kno-rdesc")]), "Descrição")').get())
            loader.add_value('trailer', movie_right_card_el.xpath('.//*[contains(@class, "B1uW2d")]/@href').get())
            loader.add_value('genres', movie_right_card_el.xpath('.//*[contains(@class, "wwUB2c")]/span/text()').get())
            loader.add_value('year', movie_right_card_el.xpath('.//*[contains(@class, "wwUB2c")]/span/text()').get())
            loader.add_value('age_rating', movie_right_card_el.xpath('.//*[contains(@class, "zqhAOd")]/text()').get())
            # loader.add_value('rating', movie_right_card_el.xpath('.//*[contains(@class, "TVtOme")]/text()').get())
            loader.add_value('cast', movie_right_card_el.xpath('.//*[contains(@data-attrid, "film:cast")]//*[contains(@class, "rOVRL")]/text()').getall())

        movie_dates_els = movie_container_el.xpath('.//*[contains(@class, "tb_c")]')
        for movie_date_el in movie_dates_els:
            loader.add_value('screenings', self.parse_ocurrence_meta(response, movie_date_el))
        
        movie_name = loader.get_xpath('.//*[contains(@class, "lr_c_h")]/span/text()', TakeFirst())
        
        if movie_name:
            movie_cover_link = "https://duckduckgo.com/?q=" + unidecode(movie_name.replace(" ", "+").lower()) + "+filme&iax=images&ia=images&iaf=layout%3ATall"
            if movie_cover_link is not None:
                yield SplashRequest(
                    url=movie_cover_link,
                    callback=self.parse_cover_meta,
                    dont_filter=True,
                    meta={
                        'loader': loader, 
                        'movie_container_el': movie_container_el
                    },
                    endpoint='execute',
                    args={
                        'timeout': 300,
                        'lua_source': parse_movie_cover_script,
                    }
                )
            else:
                logging.log(logging.WARNING, "Sem link de imagem")
                pass
        else:
            logging.log(logging.WARNING, "Sem nome coletado")
            pass


    def parse_ocurrence_meta(self, response, movie_container):
        occurrence_loader = MovieOcurrenceLoader(selector=movie_container)
        occurrence_loader.add_xpath('date', './/*[contains(@class, "std-ds")]/@data-date')

        places_els = movie_container.xpath('.//*[contains(@class, "lr_c_fcb")]')
        for place_el in places_els:
            occurrence_loader.add_value('places', self.parse_place_meta(response, place_el))

        return dict(occurrence_loader.load_item())


    def parse_place_meta(self, response, place_el):
        place_loader = MoviePlaceLoader(selector=place_el)
        place_loader.add_xpath('google_id', './@data-tm')
        place_loader.add_xpath('name', './/*[contains(@class, "lr-s-din")]/text()')
        place_loader.add_value('google_maps', urljoin(response.url, place_el.xpath('.//*[contains(@class, "ObBBIf")]/a/@href')[0].get()))

        languages_els = place_el.xpath('.//*[contains(@class, "YHR1ce")]')

        if languages_els:
            for index, language_el in enumerate(languages_els):
                place_loader.add_value('languages', self.parse_language_meta(response, place_el, index))

        else:
            place_loader.add_value('languages', self.parse_language_meta(response, place_el, 0))

        return dict(place_loader.load_item())

    def parse_language_meta(self, response, place_el, index):
        language_loader = MovieLanguageLoader()
        language_loader.add_value('name', place_el.xpath('.//*[contains(@class, "YHR1ce")]/text()')[index].get()) if place_el.xpath('.//*[contains(@class, "YHR1ce")]/text()') else None
        language_loader.add_value('screen_type', place_el.xpath('.//*[contains(@class, "lr_c_vn")]/text()')[index].get()) if place_el.xpath('.//*[contains(@class, "YHR1ce")]/text()') else None
        language_loader.add_value('times', place_el.xpath('.//*[contains(@class, "lr_c_s")]')[index].xpath('.//*[contains(@class, "lr_c_fce")]//text()').get()) if place_el.xpath('.//*[contains(@class, "lr_c_s")]') else None
        return dict(language_loader.load_item())

    def parse_cover_meta(self, response):
        loader = response.meta['loader']
        movie_container_el = response.meta['movie_container_el']
        
        loader.selector = response
        loader.add_xpath('cover', './/*[contains(@class, "js-image-detail-link")]/@href')

        movie_imdb_search_link = "https://www.imdb.com/find?q=" + re.sub(r'(\s(e|&|para|as|se|do|a|à)\s)|(:\s|,\s|\.\s|\s-\s|!)', ' ', unidecode(movie_container_el.xpath('.//*[contains(@class, "lr_c_h")]/span/text()').get().replace(" ", "+").lower())) + "&ref_=nv_sr_sm"

        if movie_imdb_search_link is not None:
            return SplashRequest(
                url=movie_imdb_search_link,
                callback=self.parse_imdb_rating_meta,
                dont_filter=True,
                meta={'loader': loader},
                endpoint='execute',
                args={
                    'timeout': 300,
                    'lua_source': parse_imdb_rating_script,
                }
            )
        else:
            return loader.load_item()

    def parse_imdb_rating_meta(self, response):
        loader = response.meta['loader']
        loader.selector = response
        loader.add_xpath('rating', '(//*[contains(@class, "AggregateRatingButton__RatingScore")]/text())[1]')
        return loader.load_item()