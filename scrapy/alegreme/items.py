# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# https://doc.scrapy.org/en/latest/topics/items.html
# See documentation in:

import scrapy
import re
import dateparser

from scrapy.loader.processors import Join, MapCompose, TakeFirst



def get_date(value):
    dates = re.search('([A-Z].+?:\d\d)', value)

    if dates:
        date = dates.group(0)
        return date
    else:
        return value


def get_time(value):
    times = re.search('(..:\d{2}.+?\w\w)', value)

    if times:
        start_time = times.group(0)
        return start_time
    else:
        return value


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
        output_processor=TakeFirst()
    )
    categories = scrapy.Field()
    organizers = scrapy.Field()
    organizers_fallback_a = scrapy.Field()
    pass
