# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/topics/items.html

from scrapy.item import Item, Field

class PnasItem(Item):
    # define the fields for your item here like:
    category = Field()
    category_minor = Field()
    authors = Field()
    title = Field()
    year = Field()
    volume = Field()
    issue = Field()
    pages = Field()
    url_abstract = Field()
    url_extract = Field()
    url_fulltext = Field()
    url_fullpdf = Field()
