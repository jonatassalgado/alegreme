# -*- coding: utf-8 -*-

# Define here the models for your spider middleware
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/spider-middleware.html

import logging
from scrapy import signals
from scrapy.http import Request
import tldextract

logger = logging.getLogger(__name__)

class AlegremeSpiderMiddleware(object):
    # Not all methods need to be defined. If a method is not defined,
    # scrapy acts as if the spider middleware does not modify the
    # passed objects.

    @classmethod
    def from_crawler(cls, crawler):
        # This method is used by Scrapy to create your spiders.
        s = cls()
        crawler.signals.connect(s.spider_opened, signal=signals.spider_opened)
        return s

    def process_spider_input(self, response, spider):
        # Called for each response that goes through the spider
        # middleware and into the spider.

        # Should return None or raise an exception.
        return None

    def process_spider_output(self, response, result, spider):
        # Called with the results returned from the Spider, after
        # it has processed the response.

        # Must return an iterable of Request, dict or Item objects.
        for i in result:
            yield i

    def process_spider_exception(self, response, exception, spider):
        # Called when a spider or process_spider_input() method
        # (from other spider middleware) raises an exception.

        # Should return either None or an iterable of Response, dict
        # or Item objects.
        pass

    def process_start_requests(self, start_requests, spider):
        # Called with the start requests of the spider, and works
        # similarly to the process_spider_output() method, except
        # that it doesn’t have a response associated.

        # Must return only requests (not items).
        for r in start_requests:
            yield r

    def spider_opened(self, spider):
        spider.logger.info('Spider opened: %s' % spider.name)


class AlegremeDownloaderMiddleware(object):
    # Not all methods need to be defined. If a method is not defined,
    # scrapy acts as if the downloader middleware does not modify the
    # passed objects.

    @classmethod
    def from_crawler(cls, crawler):
        # This method is used by Scrapy to create your spiders.
        s = cls()
        crawler.signals.connect(s.spider_opened, signal=signals.spider_opened)
        return s

    def process_request(self, request, spider):
        # Called for each request that goes through the downloader
        # middleware.

        # Must either:
        # - return None: continue processing this request
        # - or return a Response object
        # - or return a Request object
        # - or raise IgnoreRequest: process_exception() methods of
        #   installed downloader middleware will be called
        return None

    def process_response(self, request, response, spider):
        # Called with the response returned from the downloader.

        # Must either;
        # - return a Response object
        # - return a Request object
        # - or raise IgnoreRequest
        return response

    def process_exception(self, request, exception, spider):
        # Called when a download handler or a process_request()
        # (from other downloader middleware) raises an exception.

        # Must either:
        # - return None: continue processing this exception
        # - return a Response object: stops process_exception() chain
        # - return a Request object: stops process_exception() chain
        pass

    def spider_opened(self, spider):
        spider.logger.info('Spider opened: %s' % spider.name)


# https://stackoverflow.com/questions/27805952/scrapy-set-depth-limit-per-allowed-domains
class DomainDepthMiddleware:
    def __init__(self, domain_depths, default_depth):
        self.domain_depths = domain_depths
        self.default_depth = default_depth

    @classmethod
    def from_crawler(cls, crawler):
        settings = crawler.settings
        domain_depths = settings.getdict('DOMAIN_DEPTHS', default={})
        default_depth = settings.getint('DEPTH_LIMIT', 1)

        return cls(domain_depths, default_depth)
    
    def process_spider_output(self, response, result, spider):
        def _filter(request):
            if isinstance(request, Request):
                # get max depth per domain
                domain = tldextract.extract(request.url).registered_domain
                maxdepth = self.domain_depths.get(domain, self.default_depth)
                depth = response.meta.get('depth', 0) + 1
                request.meta['depth'] = depth

                if maxdepth and depth > maxdepth:
                    logger.debug(
                        "Ignoring link (depth > %(maxdepth)d): %(requrl)s ",
                        {'maxdepth': maxdepth, 'requrl': request.url},
                        extra={'spider': spider}
                    )
                    return False
                
            return True

        # base case (depth=0)
        if 'depth' not in response.meta:
            response.meta['depth'] = 0

        return (r for r in result or () if _filter(r))


    
