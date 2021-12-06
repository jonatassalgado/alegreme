# -*- coding: utf-8 -*-

# Scrapy settings for alegreme project
#
# For simplicity, this file contains only settings considered important or
# commonly used. You can find more settings consulting the documentation:
#
#     https://doc.scrapy.org/en/latest/topics/settings.html
#     https://doc.scrapy.org/en/latest/topics/downloader-middleware.html
#     https://doc.scrapy.org/en/latest/topics/spider-middleware.html

import os

BOT_NAME = 'alegreme'

SPIDER_MODULES = ['alegreme.spiders']
NEWSPIDER_MODULE = 'alegreme.spiders'


SPLASH_USERNAME = 'alegreme'
SPLASH_URL = 'https://724980c0dcd02d8fda535068339fb6fbebf437d6a9.sa.ngrok.io'
PWD = '/var/www/scrapy/data'
SPLASH_PASS = 've97K8bCwNkNgQSqvMkYRryMG4MQuQGU'
IS_DOCKER = 'true'

# Crawl responsibly by identifying yourself (and your website) on the user-agent
#USER_AGENT = 'alegreme (+http://www.yourdomain.com)'

# Obey robots.txt rules
ROBOTSTXT_OBEY = False

# Configure maximum concurrent requests performed by Scrapy (default: 16)
CONCURRENT_REQUESTS = 8
# CONCURRENT_ITEMS = 50

# Scrapy Proxy Pool
# https://github.com/rejoiceinhope/scrapy-proxy-pool
# PROXY_POOL_ENABLED = False
# PROXY_POOL_FILTER_CODE = 'br'


# Configure a delay for requests for the same website (default: 0)
# See https://doc.scrapy.org/en/latest/topics/settings.html#download-delay
# See also autothrottle settings and docs
DOWNLOAD_DELAY = 3
# The download delay setting will honor only one of:
# CONCURRENT_REQUESTS_PER_DOMAIN = 8
# CONCURRENT_REQUESTS_PER_IP = 8

# Disable cookies (enabled by default)
# COOKIES_ENABLED = False

# Disable Telnet Console (enabled by default)
#TELNETCONSOLE_ENABLED = False

# Override the default request headers:
#DEFAULT_REQUEST_HEADERS = {
#   'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
#   'Accept-Language': 'en',
#}

# Enable or disable spider middlewares
# See https://doc.scrapy.org/en/latest/topics/spider-middleware.html
SPIDER_MIDDLEWARES = {
   # 'alegreme.middlewares.AlegremeSpiderMiddleware': 543,
   'alegreme.middlewares.DomainDepthMiddleware': 900,
   'scrapy.spidermiddlewares.depth.DepthMiddleware': None,
   'scrapy_splash.SplashDeduplicateArgsMiddleware': 100,
}

# Enable or disable downloader middlewares
# See https://doc.scrapy.org/en/latest/topics/downloader-middleware.html
DOWNLOADER_MIDDLEWARES = {
#   'alegreme.middlewares.AlegremeDownloaderMiddleware': 543,
#   'scrapy_proxy_pool.middlewares.ProxyPoolMiddleware': 610,
#   'scrapy_proxy_pool.middlewares.BanDetectionMiddleware': 620,
    'scrapy_splash.SplashCookiesMiddleware': 723,
    'scrapy_splash.SplashMiddleware': 725,
    'scrapy.downloadermiddlewares.httpcompression.HttpCompressionMiddleware': 810
}

DUPEFILTER_CLASS = 'scrapy_splash.SplashAwareDupeFilter'
RETRY_TIMES = 1

# DOWNLOADER_MIDDLEWARES.update({
#     'scrapy.downloadermiddlewares.useragent.UserAgentMiddleware': None,
#     'scrapy_useragents.downloadermiddlewares.useragents.UserAgentsMiddleware': 500,
# })


# DEPTH_LIMIT = 4
# CLOSESPIDER_ITEMCOUNT = 2
CLOSESPIDER_ERRORCOUNT = 50
CLOSESPIDER_PAGECOUNT = 500

# Enable or disable extensions
# See https://doc.scrapy.org/en/latest/topics/extensions.html
#EXTENSIONS = {
#    'scrapy.extensions.telnet.TelnetConsole': None,
#}

# Configure item pipelines
# See https://doc.scrapy.org/en/latest/topics/item-pipeline.html
# ITEM_PIPELINES = {
#    'alegreme.pipelines.AlegremePipeline': 300,
# }

LOG_ENABLED = True
LOG_FILE = '/var/www/scrapy/log/output.log'

if os.environ.get('ENV') == 'production':
    LOG_LEVEL = 'DEBUG'
else:
    LOG_LEVEL = 'DEBUG'

COOKIES_DEBUG = False

# Enable and configure the AutoThrottle extension (disabled by default)
# See https://doc.scrapy.org/en/latest/topics/autothrottle.html
AUTOTHROTTLE_ENABLED = True
# The initial download delay
AUTOTHROTTLE_START_DELAY = 10
# The maximum download delay to be set in case of high latencies
AUTOTHROTTLE_MAX_DELAY = 30
# The average number of requests Scrapy should be sending in parallel to
# each remote server
# AUTOTHROTTLE_TARGET_CONCURRENCY = 2.0
# Enable showing throttling stats for every response received:
# AUTOTHROTTLE_DEBUG = False

# Enable and configure HTTP caching (disabled by default)
# See https://doc.scrapy.org/en/latest/topics/downloader-middleware.html#httpcache-middleware-settings
HTTPCACHE_ENABLED = True
HTTPCACHE_EXPIRATION_SECS = 10800
# HTTPCACHE_DIR = 'httpcache'
# Don't cache pages that throw an error
HTTPCACHE_IGNORE_HTTP_CODES = [503, 504, 505, 500, 400, 401, 402, 403, 404]
# HTTPCACHE_STORAGE = 'scrapy_splash.SplashAwareFSCacheStorage'
