#! /usr/bin/python
from csv_unicode import *

"""
Create a separate categories.csv, for deciding which categories to merge.
Not needed for a regular run of the scraper.
"""

def main(): 
    categories_major = [u"Biological Sciences", u"Physical Sciences", u"Social Sciences"]

    filename = "meta.csv"
    reader = UnicodeReader(open(filename, "rb"))
    firstline = next(reader)
    field = dict(zip(firstline, range(len(firstline))))
    firstline = []
    for value in range(len(field)):
        for key in field:
            if field[key] == value:
                firstline.append(key)

    categories={}
    for year in range(1991,2002):
        categories[str(year)]=[]

    for row in reader:
        if row[field["category_fullpdf"]]!=u"":
            categories[row[field['year']]].append(row[field["category_fullpdf"]])
        if row[field["category_minor"]]!=u"":
            categories[row[field['year']]].append(row[field["category_minor"]]+" ("+row[field["category"]]+")")
    writer = UnicodeWriter(open("categories.csv", "wb")) #, delimiter="\t")
    writer.writerow(["year", "category"])
    for year in categories:
        for cat in set(categories[year]):
            print year,cat
            writer.writerow([year, cat])

if __name__== "__main__":
    main()
