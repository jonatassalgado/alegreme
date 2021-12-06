from alegreme.items import *


def get_address(value, loader_context):
    address = re.sub(r"\n|&amp|\xa0|&nbsp;", "", value)
    address = BeautifulSoup(address, "html.parser")
    address = address.get_text()
    address = str(address)
    return address.strip()
    
def get_date(value):
    return dateparser.parse(value, settings={'TIMEZONE': '-0300'})

def handle_image_url(value):
    image = re.search(r"(http.+)(?:.800w)", value)
    return image.group(1) if image else None

class EventEB(scrapy.Item):
    name = scrapy.Field(
        input_processor=MapCompose(clean_name), output_processor=TakeFirst()
    )
    cover_url = scrapy.Field( 
        input_processor=MapCompose(handle_image_url), output_processor=TakeFirst()
    )
    address = scrapy.Field(
         input_processor=MapCompose(get_address),
        output_processor=Join()
    )
    datetimes = scrapy.Field(input_processor=MapCompose(get_date))
    place_name = scrapy.Field(output_processor=TakeFirst())
    place_cover_url = scrapy.Field(
        output_processor=TakeFirst(),
    )
    description = scrapy.Field(
        input_processor=MapCompose(clean_description), output_processor=Join()
    )
    prices = scrapy.Field(input_processor=MapCompose(get_prices))
    ticket_url = scrapy.Field(
        input_processor=MapCompose(clean_facebook_url), output_processor=TakeFirst()
    )
    latitude = scrapy.Field(
        output_processor=TakeFirst()
    )
    longitude = scrapy.Field(
        output_processor=TakeFirst()
    )
    categories = scrapy.Field()
    organizers = scrapy.Field(input_processor=Identity())
    multiple_hours = scrapy.Field(output_processor=TakeFirst())
    deleted = scrapy.Field(output_processor=TakeFirst())
    source_url = scrapy.Field(
        input_processor=MapCompose(remove_url_params), output_processor=TakeFirst()
    )
    source_name = scrapy.Field()