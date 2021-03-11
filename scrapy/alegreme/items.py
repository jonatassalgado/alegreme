# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# https://doc.scrapy.org/en/latest/topics/items.html
# See documentation in:

import scrapy
import re
import dateparser

from scrapy.loader import ItemLoader
from itemloaders.processors import Join, MapCompose, TakeFirst, Identity
from urllib.parse import unquote, urljoin, urlparse
from bs4 import BeautifulSoup



def get_date(value):
    datetimes = re.findall('\d{4}-\d{2}-\d{2}\w+:\d+:\w+-\w+:\w+', value)
    parsed_datetimes = []
    if datetimes:
        for datetime in datetimes:
            parsed_datetimes.append(dateparser.parse(datetime, settings={'TIMEZONE': '-0300'}))

    return parsed_datetimes

def clean_description(value):
    description = re.sub(r'http(s|):\/\/l.facebook?.+?u=', '', value)
    description = re.sub(r';h=.+?(?=")', '', description)
    description = re.sub(r'target="_blank"', '', description)
    description = re.sub(r'data-lynx-mode="hover"', '', description)
    description = re.sub(r'&amp', '', description)
    description = re.sub(r'<(\/|)span>', '', description)
    description = unquote(description)
    description = BeautifulSoup(description, 'html.parser')
    hashtags = description.select("a[href*=hashtag]")
    for hashtag in hashtags:
        hashtag.decompose()

    return str(description)


def remove_url_params(value):
    return urljoin(value, urlparse(value).path)


def clean_facebook_url(value):
    url = re.sub(r'http(s|):\/\/l.facebook?.+?u=', '', value)
    url = re.sub(r'&h=\w+', '', url)
    return unquote(url)


def get_prices(value):
    prices = re.findall(r'(\d|\d{2}|\d{3}|\d{4})\b', value)
    return prices


def parse_date(value):
    date = re.sub(r'(seg|ter|qua|qui|sex|sáb|dom)', '', value)
    return dateparser.parse(date).date()


def get_image_url_from_style(value):
    url = re.search('http(s|):\/\/.+?(?=\))', value)
    return url.group(0)



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
    source_url = scrapy.Field(
        input_processor=MapCompose(remove_url_params),
        output_processor=TakeFirst()
    )
    place_name = scrapy.Field(
        output_processor=TakeFirst()
    )
    place_cover_url = scrapy.Field(
        input_processor=MapCompose(get_image_url_from_style),
        output_processor=TakeFirst()
    )
    description = scrapy.Field(
        input_processor=MapCompose(clean_description),
        output_processor=TakeFirst()
    )
    prices = scrapy.Field(
        input_processor=MapCompose(get_prices)
    )
    ticket_url = scrapy.Field(
        input_processor=MapCompose(clean_facebook_url),
        output_processor=TakeFirst()
    )
    categories = scrapy.Field()
    organizers = scrapy.Field(
        input_processor=Identity()
    )
    deleted = scrapy.Field(
        output_processor=TakeFirst()
    )


class EventOrganizer(scrapy.Item):
    cover_url = scrapy.Field(
        output_processor=TakeFirst()
    )
    name = scrapy.Field(
        output_processor=TakeFirst()
    )
    source_url = scrapy.Field(
        input_processor=MapCompose(remove_url_params),
        output_processor=TakeFirst()
    )

class EventOrganizerLoader(ItemLoader):
    default_item_class=EventOrganizer


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


class Poster(scrapy.Item):
    shortcode = scrapy.Field(
        output_processor=TakeFirst()
    )
    media = scrapy.Field(
        input_processor=Identity()
    )
    caption = scrapy.Field(
        output_processor=TakeFirst()
    )
    taken_at_timestamp = scrapy.Field(
        output_processor=TakeFirst()
    )
    source_url = scrapy.Field(
        input_processor=MapCompose(remove_url_params),
        output_processor=TakeFirst()
    )
    location = scrapy.Field(
        output_processor=TakeFirst()
    )
    owner = scrapy.Field(
        input_processor=Identity()
    )
    
class PosterMedia(scrapy.Item):
    is_video = scrapy.Field(
        output_processor=TakeFirst()
    )
    display_url = scrapy.Field(
        output_processor=TakeFirst()
    )
    video_url = scrapy.Field(
        output_processor=TakeFirst()
    )

class PosterMediaLoader(ItemLoader):
    default_item_class=PosterMedia

class PosterOwner(scrapy.Item):
    full_name = scrapy.Field(
        output_processor=TakeFirst()
    )
    profile_pic_url = scrapy.Field(
        output_processor=TakeFirst()
    )
    username = scrapy.Field(
        output_processor=TakeFirst()
    )

class PosterOwnerLoader(ItemLoader):
    default_item_class=PosterOwner