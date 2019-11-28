# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# https://doc.scrapy.org/en/latest/topics/items.html
# See documentation in:

import scrapy
import re
import dateparser

from scrapy.loader import ItemLoader
from scrapy.loader.processors import Join, MapCompose, TakeFirst, Identity
from urllib.parse import unquote



def get_date(value):
    dates = re.search('([A-Z].+?:\d{2}.+?\w{2})', value)

    if dates:
        date = dates.group(0)
        return date
    else:
        return value


def get_time(value):
    times = re.search('(..:\d{2}.+?\w{2})', value)

    if times:
        start_time = times.group(0)
        return start_time
    else:
        return value

def clean_description(value):
    description = re.sub(r'http(s|):\/\/l.facebook?.+?u=', '', value)
    description = re.sub(r';h=.+?(?=")', '', description)
    description = re.sub(r'target="_blank"', '', description)
    description = re.sub(r'data-lynx-mode="hover"', '', description)
    description = re.sub(r'&amp', '', description)
    return unquote(description)


def get_prices(value):
    prices = re.findall(r'(\d|\d{2}|\d{3}|\d{4})\b', value)
    return prices


def parse_date(value):
    date = re.sub(r'(seg|ter|qua|qui|sex|sáb|dom)', '', value)
    return dateparser.parse(date).date()




class Event(scrapy.Item):
    name = scrapy.Field(
        output_processor=TakeFirst()
    )
    cover_url = scrapy.Field(
        output_processor=TakeFirst()
    )
    address = scrapy.Field(
        output_processor=TakeFirst()
    )
    datetimes = scrapy.Field(
        input_processor=MapCompose(get_date)
    )
    dates = scrapy.Field(
        input_processor=MapCompose(get_date)
    )
    times = scrapy.Field(
        input_processor=MapCompose(get_time)
    )
    source_url = scrapy.Field(
        output_processor=TakeFirst()
    )
    place = scrapy.Field(
        output_processor=TakeFirst()
    )
    description = scrapy.Field(
        input_processor=MapCompose(clean_description),
        output_processor=TakeFirst()
    )
    prices = scrapy.Field(
        input_processor=MapCompose(get_prices)
    )
    categories = scrapy.Field()
    organizers = scrapy.Field()
    organizers_fallback_a = scrapy.Field()
    pass


class Movie(scrapy.Item):
    name = scrapy.Field(
        output_processor=TakeFirst()
    )
    description = scrapy.Field(
        output_processor=TakeFirst()
    )
    cover = scrapy.Field(
        output_processor=TakeFirst()
    )
    trailler = scrapy.Field(
        output_processor=TakeFirst()
    )
    genre = scrapy.Field(
        output_processor=TakeFirst()
    )
    dates = scrapy.Field(
        input_processor=Identity()
    )


class MovieOcurrence(scrapy.Item):
    date = scrapy.Field(
        input_processor=MapCompose(parse_date),
        output_processor=TakeFirst()
    )
    places = scrapy.Field(
        input_processor=Identity()
    )

class MovieOcurrenceLoader(ItemLoader):
    default_item_class=MovieOcurrence


class MoviePlace(scrapy.Item):
    name = scrapy.Field(
        output_processor=TakeFirst()
    )
    address = scrapy.Field(
        output_processor=TakeFirst()
    )
    languages = scrapy.Field(
        input_processor=Identity()
    )

class MoviePlaceLoader(ItemLoader):
    default_item_class=MoviePlace


class MovieLanguage(scrapy.Item):
    name = scrapy.Field(
        output_processor=TakeFirst()
    )
    screen_type = scrapy.Field(
        output_processor=TakeFirst()
    )
    times = scrapy.Field()

class MovieLanguageLoader(ItemLoader):
    default_item_class=MovieLanguage
