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



# Splash
is_docker = os.environ.get('IS_DOCKER')
splash_url = os.environ.get('SPLASH_URL')
public_ip = os.environ.get('PUBLIC_IP')
private_ip = os.environ.get('PRIVATE_IP')
home = os.environ.get('HOME')

SPLASH_URL = 'http://splash:8050'
SPLASH_USERNAME = 'alegreme'
SPLASH_PASS = 've97K8bCwNkNgQSqvMkYRryMG4MQuQGU'
IS_DOCKER = 'true'

PWD = '/var/www/scrapy/data'


# Crawl responsibly by identifying yourself (and your website) on the user-agent
#USER_AGENT = 'alegreme (+http://www.yourdomain.com)'

# Obey robots.txt rules
ROBOTSTXT_OBEY = False

# Configure maximum concurrent requests performed by Scrapy (default: 16)
CONCURRENT_REQUESTS = 2
CONCURRENT_ITEMS = 16

# Scrapy Proxy Pool
# https://github.com/rejoiceinhope/scrapy-proxy-pool
# PROXY_POOL_ENABLED = False
# PROXY_POOL_FILTER_CODE = 'br'


# Configure a delay for requests for the same website (default: 0)
# See https://doc.scrapy.org/en/latest/topics/settings.html#download-delay
# See also autothrottle settings and docs
# DOWNLOAD_DELAY = 2
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
   'scrapy_splash.SplashDeduplicateArgsMiddleware': 100,
}

# Enable or disable downloader middlewares
# See https://doc.scrapy.org/en/latest/topics/downloader-middleware.html
DOWNLOADER_MIDDLEWARES = {
#    'alegreme.middlewares.AlegremeDownloaderMiddleware': 543,
#    'scrapy_proxy_pool.middlewares.ProxyPoolMiddleware': 610,
#    'scrapy_proxy_pool.middlewares.BanDetectionMiddleware': 620,
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

# USER_AGENTS = [
#     ('Mozilla/5.0 (X11; Linux x86_64) '
#      'AppleWebKit/537.36 (KHTML, like Gecko) '
#      'Chrome/57.0.2987.110 '
#      'Safari/537.36'),  # chrome
#     ('Mozilla/5.0 (X11; Linux x86_64) '
#      'AppleWebKit/537.36 (KHTML, like Gecko) '
#      'Chrome/61.0.3163.79 '
#      'Safari/537.36'),  # chrome
#     ('Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:55.0) '
#      'Gecko/20100101 '
#      'Firefox/55.0')  # firefox
# ]

# DEPTH_LIMIT = 4
# CLOSESPIDER_ITEMCOUNT = 2
CLOSESPIDER_ERRORCOUNT = 50
CLOSESPIDER_PAGECOUNT = 150

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
AUTOTHROTTLE_START_DELAY = 3
# The maximum download delay to be set in case of high latencies
#AUTOTHROTTLE_MAX_DELAY = 120
# The average number of requests Scrapy should be sending in parallel to
# each remote server
AUTOTHROTTLE_TARGET_CONCURRENCY = 3.0
# Enable showing throttling stats for every response received:
# AUTOTHROTTLE_DEBUG = False

# Enable and configure HTTP caching (disabled by default)
# See https://doc.scrapy.org/en/latest/topics/downloader-middleware.html#httpcache-middleware-settings
HTTPCACHE_ENABLED = True
HTTPCACHE_EXPIRATION_SECS = 604800
HTTPCACHE_DIR = 'httpcache'
# Don't cache pages that throw an error
HTTPCACHE_IGNORE_HTTP_CODES = [503, 504, 505, 500, 400, 401, 402, 403, 404]


#HTTPCACHE_DIR = 'httpcache'
#HTTPCACHE_IGNORE_HTTP_CODES = []
HTTPCACHE_STORAGE = 'scrapy_splash.SplashAwareFSCacheStorage'
