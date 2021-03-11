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
import os.path
from scrapy.exporters import JsonLinesItemExporter
from scrapy.utils.project import get_project_settings


class EventPipeline(object):

    file = None

    def open_spider(self, spider):
        settings = get_project_settings()
        timestr = time.strftime("%Y%m%d-%H%M%S")
        pwd = settings.get('PWD')
        file_path = pwd + '/scraped/events-' + timestr + '.jsonl'

        try:
            if os.path.isdir(pwd + '/scraped'):
                print("The directory /scraped already exists")
            else:
                os.makedirs(pwd + '/scraped')
        except IOError as exception:
            raise IOError('%s: %s' % (path, exception.strerror))

        try:
            self.file = open(file_path, 'wb')
        except IOError:
            self.file = open(file_path, 'w+')

        self.exporter = JsonLinesItemExporter(self.file)
        self.exporter.start_exporting()


    def close_spider(self, spider):
        self.exporter.finish_exporting()
        self.file.close()


    def process_item(self, item, spider):
        self.exporter.export_item(item)
        return item


class DeletedEventPipeline(object):

    file = None

    def open_spider(self, spider):
        settings = get_project_settings()
        timestr = time.strftime("%Y%m%d-%H%M%S")
        pwd = settings.get('PWD')
        file_path = pwd + '/scraped/deleted-events-' + timestr + '.jsonl'

        try:
            if os.path.isdir(pwd + '/scraped'):
                print("The directory /scraped already exists")
            else:
                os.makedirs(pwd + '/scraped')
        except IOError as exception:
            raise IOError('%s: %s' % (path, exception.strerror))

        try:
            self.file = open(file_path, 'wb')
        except IOError:
            self.file = open(file_path, 'w+')

        self.exporter = JsonLinesItemExporter(self.file)
        self.exporter.start_exporting()


    def close_spider(self, spider):
        self.exporter.finish_exporting()
        self.file.close()


    def process_item(self, item, spider):
        self.exporter.export_item(item)
        return item


class MoviePipeline(object):

    file = None

    def open_spider(self, spider):
        settings = get_project_settings()
        timestr = time.strftime("%Y%m%d-%H%M%S")
        pwd = settings.get('PWD')
        file_path = pwd + '/scraped/movies-' + timestr + '.jsonl'

        try:
            if os.path.isdir(pwd + '/scraped'):
                print("The directory /scraped already exists")
            else:
                os.makedirs(pwd + '/scraped')
        except IOError as exception:
            raise IOError('%s: %s' % (path, exception.strerror))

        try:
            self.file = open(file_path, 'wb')
        except IOError:
            self.file = open(file_path, 'w+')

        self.exporter = JsonLinesItemExporter(self.file)
        self.exporter.start_exporting()


    def close_spider(self, spider):
        self.exporter.finish_exporting()
        self.file.close()


    def process_item(self, item, spider):
        self.exporter.export_item(item)
        return item


class PosterPipeline(object):

    file = None

    def open_spider(self, spider):
        settings = get_project_settings()
        timestr = time.strftime("%Y%m%d-%H%M%S")
        pwd = settings.get('PWD')
        file_path = pwd + '/scraped/posters-' + timestr + '.jsonl'

        try:
            if os.path.isdir(pwd + '/scraped'):
                print("The directory /scraped already exists.")
                print("Continue...")
            else:
                os.makedirs(pwd + '/scraped')
        except IOError as exception:
            raise IOError('%s: %s' % (path, exception.strerror))

        try:
            self.file = open(file_path, 'wb')
        except IOError:
            self.file = open(file_path, 'w+')

        self.exporter = JsonLinesItemExporter(self.file)
        self.exporter.start_exporting()


    def close_spider(self, spider):
        self.exporter.finish_exporting()
        self.file.close()


    def process_item(self, item, spider):
        self.exporter.export_item(item)
        return item