#!/bin/bash
time scrapy crawl pnas --set FEED_FORMAT=csv --set FEED_URI=scraped.csv --set DOWNLOAD_DELAY=10
