# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# https://doc.scrapy.org/en/latest/topics/items.html
# See documentation in:

import scrapy
import re
import dateparser

from scrapy.loader.processors import Join, MapCompose, TakeFirst
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

def get_description(value):
    description = re.sub(r'http(s|):\/\/l.facebook?.+?u=', '', value)
    description = re.sub(r';h=.+?(?=")', '', description)
    description = re.sub(r'target="_blank"', '', description)
    description = re.sub(r'data-lynx-mode="hover"', '', description)
    description = re.sub(r'&amp', '', description)
    return unquote(description)


def get_price(value):
    price = re.findall(r'(\d|\d{2}|\d{3}|\d{4})\b', value)
    return price


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
        input_processor=MapCompose(get_description)
    )
    price = scrapy.Field(
        input_processor=MapCompose(get_price)
    )
    categories = scrapy.Field()
    organizers = scrapy.Field()
    organizers_fallback_a = scrapy.Field()
    pass
