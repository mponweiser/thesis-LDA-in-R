from scrapy.spider import BaseSpider
from scrapy.http import Request
from pnas.items import PnasItem
from scrapy.selector import HtmlXPathSelector
from BeautifulSoup import BeautifulSoup

def soup_flatten(soup):
    # http://stackoverflow.com/questions/753052/strip-html-from-strings-in-python
    soupstring = "".join(soup.findAll(text=True))
    soupstring = soupstring.replace(u"\n",u" ")
    # remove whitespace : http://bytes.com/topic/python/answers/590441-how-strip-mulitiple-white-spaces
    soupstring = " ".join(soupstring.split())
    return soupstring

def html_flatten(selection):
    try:
        soup = BeautifulSoup(selection)
    except:
        return ""
    return soup_flatten(soup)

class PnasSpider(BaseSpider):
    name = "pnas"
    allowed_domains = ["www.pnas.org"]
    url_base = "http://www.pnas.org"
    start_urls = [url_base + "/content/by/year/" + str(year) for year in range(1991,2002)]

    # default parser for start_urls
    def parse(self, response):
        hxs = HtmlXPathSelector(response)
        issue_urls = hxs.select('//td[@class="proxy-archive-by-year-month"]/p/strong/a/@href').extract()
        for issue_url in issue_urls:
            yield Request(self.url_base + issue_url, callback = self.parse_issue)

    def parse_item(self, selection):
        item = PnasItem()
        if selection.select('.//h4') != []:
            item['title'] = html_flatten(selection.select('.//h4')[0].extract())
            # "From the Cover: "... see 2-select.py
            #titlestring = selection.select('.//h4/text()')[0].extract()
            #titlestring = titlestring.replace(u"\n",u" ")
            #titlestring = " ".join(titlestring.split())
            #item['title'] = titlestring
        authors = selection.select('.//ul[contains(@class,"cit-auth-list")]') 
        if authors != []:
            item['authors'] = html_flatten(authors[0].extract())

        if selection.select('.//a[@rel="full-text"]/@href') != []:
            item['url_fulltext'] = self.url_base + selection.select('.//a[@rel="full-text"]/@href')[0].extract()
        if selection.select('.//a[@rel="full-text.pdf"]/@href') != []:
            item['url_fullpdf'] = self.url_base + selection.select('.//a[@rel="full-text.pdf"]/@href')[0].extract()
        if selection.select('.//a[@rel="abstract"]/@href') != []:
            item['url_abstract'] = self.url_base + selection.select('.//a[@rel="abstract"]/@href')[0].extract()
        if selection.select('.//a[@rel="extract"]/@href') != []:
            item['url_extract'] = self.url_base + selection.select('.//a[@rel="extract"]/@href')[0].extract()

        if selection.select('.//span[@class="cit-print-date"]') != []:
            item['year'] = selection.select('.//span[@class="cit-print-date"]/text()')[0].extract().strip()
        if selection.select('.//span[@class="cit-vol"]') != []:
            item['volume'] = selection.select('.//span[@class="cit-vol"]/text()')[0].extract().strip()
        if selection.select('.//span[@class="cit-issue"]') != []:
            item['issue'] = selection.select('.//span[@class="cit-issue"]/text()')[0].extract().strip()
        if selection.select('.//span[@class="cit-pages"]') != []:
            item['pages'] = html_flatten(selection.select('.//span[@class="cit-pages"]')[0].extract())
        return item

    def parse_issue(self, response):
        hxs = HtmlXPathSelector(response)
        div1s = hxs.select('//div[contains(@class,"toc-level level1")]')

        # For each section that is headed by H2 (Commentaries, Physical Sciences,...)
        for div1 in div1s:
            # Get H2
            h2string = div1.select('h2/span/text()')[0].extract()

            # If we encounter a list immediately after H2, we are in a category without minor (Comments...)
            # and can expect the articles (as list items li)
            for li in div1.select('ul[@class="cit-list"]/li'):
                item = self.parse_item(li)
                item['category'] = h2string
                yield item

            # If we encounter the level2 div, we can expect H3 and then articles
            for div2 in div1.select('div[contains(@class,"toc-level level2")]'):
                if div2.select('h3/span/text()') != []:
                    h3string = div2.select('h3/span/text()')[0].extract() 

                for li in div2.select('ul[@class="cit-list"]/li'):
                    item = self.parse_item(li)
                    item['category'] = h2string
                    item['category_minor'] = h3string
                    yield item
