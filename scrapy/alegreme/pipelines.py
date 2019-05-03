# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://doc.scrapy.org/en/latest/topics/item-pipeline.html

import os
import json
import dateparser
import re
import time
import settings
from scrapy.exporters import JsonItemExporter

class AlegremePipeline(object):

    file = None

    def open_spider(self, spider):
        timestr = time.strftime("%Y%m%d-%H%M%S")
        self.file = open('/var/www/scrapy/data/events-' + timestr + '.json', 'wb')

        self.exporter = JsonItemExporter(self.file)
        self.exporter.start_exporting()


    def close_spider(self, spider):
        self.exporter.finish_exporting()
        self.file.close()


    def process_item(self, item, spider):
        if 'source_url' in item:
            item['source_url'] = re.search('([A-z].+/)\w+', item['source_url']).group(0)
            pass

        if 'organizers' not in item:
            item['organizers'] = item['organizers_fallback_a']
            pass

        if 'dates' in item:
            item['datetimes'] = []

            for index, date in enumerate(item['dates']):
                datetime = item['dates'][index] + ' ' + item['times'][index]

                item['datetimes'].insert(index, dateparser.parse(datetime))
                pass

        else:
            item['datetimes'][0] = dateparser.parse(item['datetimes'][0])

        self.exporter.export_item(item)
        return item
