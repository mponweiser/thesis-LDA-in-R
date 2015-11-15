#! /usr/bin/python
"""
"""
from csv_unicode import *
import os.path
from optparse import OptionParser

def main(): 
    parser = OptionParser("usage: %prog [options] arg")
    parser.add_option("-f", "--file", dest="filename", help="read from")
    parser.add_option("-o", "--output", dest="output_filename", help="write to")
    parser.add_option("-d", "--check-dup", action="store_true", dest="check_duplicate_abstracts")
    parser.add_option("-s", "--skip-dup", action="store_true", dest="skip_duplicate_abstracts")
    parser.add_option("-m", "--missing-only", action="store_true", dest="download_missing_only")
    parser.add_option("-t", "--clean-titles", action="store_true", dest="clean_titles")
    parser.add_option("-c", "--clean-categories", action="store_true", dest="clean_categories")
    parser.add_option("-r", "--reorder-columns", action="store_true", dest="reorder_columns")
    parser.set_defaults(filename="scraped.csv",
                        output_filename="selected.csv",
                        check_duplicate_abstracts=False,
                        skip_duplicate_abstracts=False,
                        clean_titles=True,
                        clean_categories=True,
                        reorder_columns=True,
                        download_missing_only=False)
    (options, args) = parser.parse_args()
    if len(args) != 0: parser.error("incorrect number of arguments")

    url_base = "http://www.pnas.org"
    categories_major = [u"Biological Sciences", u"Physical Sciences", u"Social Sciences"]
    reader = UnicodeReader(open(options.filename, "rb"))
    firstline = next(reader)
    field = dict(zip(firstline, range(len(firstline))))

    writer = UnicodeWriter(open(options.output_filename, "wb")) #, delimiter="\t")

    # Add header line to output, always the same extra columns, regardless of options
    firstline = []
    for value in range(len(field)):
        for key in field:
            if field[key] == value:
                firstline.append(key)
    if options.reorder_columns==True:
        firstline=["category","category_minor","authors","title","year","volume","issue","pages","url_abstract","url_extract","url_fulltext","url_fullpdf"]
    writer.writerow(firstline + ["url_abstract_is_duplicate", "download_abstract", "download_fullpdf"])

    processed_abstract_fields = []
    url_abstract_duplicates = 0
    relevant_abstracts = 0
    relevant_fullpdfs = 0
    found_fullpdfs = 0
    found_abstracts = 0
    marked_abstracts = 0
    marked_fullpdfs = 0
    irrelevant_abstracts = 0
    irrelevant_fullpdfs = 0
    for row in reader:
        url_abstract = row[field['url_abstract']] 
        url_abstract_is_duplicate = ""
        download_abstract=""
        download_fullpdf=""
        # Clean manually some misformed major categories
        if options.clean_categories==True:
            if row[field['category']]==u"Biological Sciences: Biochemistry":
                row[field['category']]=u"Biological Sciences"
                row[field['category_minor']]=u"Biochemistry"
            if row[field['category']]==u"Biological Sciences: Biophysics":
                row[field['category']]=u"Biological Sciences"
                row[field['category_minor']]=u"Biophysics"
            if row[field['category']]==u"Biological Sciences: Evolution":
                row[field['category']]=u"Biological Sciences"
                row[field['category_minor']]=u"Evolution"
            if row[field['category']]==u"Evolution":
                row[field['category']]=u"Biological Sciences"
                row[field['category_minor']]=u"Evolution"
            if row[field['category']]==u"Immunology":
                row[field['category']]=u"Biological Sciences"
                row[field['category_minor']]=u"Immunology"
            if row[field['category']]==u"Physical Sciences: Chemistry":
                row[field['category']]=u"Physical Sciences"
                row[field['category_minor']]=u"Chemistry"
            if row[field['category']]==u"Physical Sciences: Geophysics":
                row[field['category']]=u"Physical Sciences"
                row[field['category_minor']]=u"Geophysics"

        ## (Research articles are not affected by duplicates)
        if options.check_duplicate_abstracts==True and url_abstract in processed_abstract_fields: #and row[field['category']] in categories_major :
            url_abstract_is_duplicate="yes"
            url_abstract_duplicates += 1

        ## if a line has no category_minor it is possible it will appear later with category_minor from a different section. If not, it won't be needed anyways
        if row[field['url_abstract']]!=u"" and row[field['category_minor']]!=u"": # could include major cat check here
            ## if no duplicate checking is active, this will always work
            if options.skip_duplicate_abstracts==True and url_abstract_is_duplicate=="yes": 
                pass
            else:
                download_abstract="yes"
                relevant_abstracts+=1

        ### Full PDFs for abstracts that lack a category
        if row[field['url_abstract']]!=u"" and row[field['category']]==u"Research Article" and row[field['url_fullpdf']]!=u"":
            if options.skip_duplicate_abstracts==True and url_abstract_is_duplicate=="yes": 
                pass
            else:
                download_abstract="yes"
                relevant_abstracts+=1
                download_fullpdf="yes"
                relevant_fullpdfs+=1

#        if url_abstract_is_duplicate=="":
#            if row[field['url_abstract']]!=u"" and row[field['category_minor']]!=u"": # could include major cat check here
#                download_abstract="yes"
#                relevant_abstracts+=1
#             What is with items that have no url_abstract? ignore, for categories_major these are only a few
#             irrelevant inaugural articles etc.

            ## Full PDFs for abstracts that lack a category
#            if row[field['category']]==u"Research Article" and row[field['url_abstract']]!=u"" and row[field['url_fullpdf']]!=u"":
#                download_abstract="yes"
#                relevant_abstracts+=1
#                download_fullpdf="yes"
#                relevant_fullpdfs+=1

        if options.download_missing_only==True:
            abstract_filename = url_abstract.split("/")[-1]
            base_filename = abstract_filename.split(".")[0]
            local_base_path = row[field['year']]+"/"+base_filename
            local_path = row[field['year']]+"/"+abstract_filename
            if os.path.isfile(local_path) and os.path.getsize(local_path)!=0:
                if download_abstract=="" and url_abstract_is_duplicate=="":
                    irrelevant_abstracts+=1
                    #print local_path, url_abstract
                download_abstract=""
                found_abstracts+=1
            local_path = row[field['year']]+"/"+base_filename+".full.pdf"
            if os.path.isfile(local_path) and os.path.getsize(local_path)!=0:
                if download_fullpdf=="" and url_abstract_is_duplicate=="": irrelevant_fullpdfs+=1
                download_fullpdf=""
                found_fullpdfs+=1

        if options.clean_titles==True:
            row[field['title']] = row[field['title']].replace("From the Cover: ","")
            row[field['title']] = row[field['title']].replace("From the Academy: ","")
            row[field['title']] = row[field['title']].replace("Inaugural Article: ","")
            row[field['title']] = row[field['title']].replace("Colloquium Paper: ","")
            row[field['title']] = row[field['title']].replace("Special Feature: ","")
            row[field['title']] = row[field['title']].replace("From the Cover: ","")

        if download_abstract=="yes": marked_abstracts+=1
        if download_fullpdf=="yes": marked_fullpdfs+=1
        rows_additional =[url_abstract_is_duplicate, download_abstract, download_fullpdf]
        if options.reorder_columns==True:
            row = [row[index] for index in [field[name] for name in firstline]]
        writer.writerow(row + rows_additional)

        if options.check_duplicate_abstracts==True and url_abstract!=u"": processed_abstract_fields.append(url_abstract)

    if options.check_duplicate_abstracts==True: print "Duplicate url_abstract entries:", url_abstract_duplicates
    print ".abstract: relevant: %5d, found: %5d, found but irrelevant: %5d, marked for download: %5d" % (relevant_abstracts, found_abstracts, irrelevant_abstracts, marked_abstracts)
    print ".fullpdf:  relevant: %5d, found: %5d, found but irrelevant: %5d, marked for download: %5d" % (relevant_fullpdfs, found_fullpdfs, irrelevant_fullpdfs, marked_fullpdfs)
    print "Irrelevant files (non-duplicate): leftovers from other scrapers or manual download selection" 
    print "Relevant files: these include Research articles with unknown category. Some files will later be recognized as irrelevant (5-zip.py)." 

if __name__== "__main__":
    main()
