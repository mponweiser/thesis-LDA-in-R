# Scrapy settings for pnas project
#
# For simplicity, this file contains only the most important settings by
# default. All the other settings are documented here:
#
#     http://doc.scrapy.org/topics/settings.html
#
# Or you can copy and paste them from where they're defined in Scrapy:
# 
#     scrapy/conf/default_settings.py
#

BOT_NAME = 'pnas'
BOT_VERSION = '1.0'

SPIDER_MODULES = ['pnas.spiders']
NEWSPIDER_MODULE = 'pnas.spiders'
DEFAULT_ITEM_CLASS = 'pnas.items.PnasItem'
USER_AGENT = '%s/%s' % (BOT_NAME, BOT_VERSION)

DOWNLOAD_DELAY = 10 #0.25    # 250 ms of delay

