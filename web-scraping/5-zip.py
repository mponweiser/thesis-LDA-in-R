#! /usr/bin/python

from csv_unicode import *
import os.path
import sys # for args

category_merged_dict = {u"Agricultural Sciences":"Agricultural Sciences",
                        u"Anthropology":"Anthropology",
                        u"Applied Biological Sciences":"Applied Biological Sciences",
                        u"Applied Mathematics":"Applied Mathematics",
                        u"Applied Physical Sciences":"Applied Physical Sciences",
                        u"Astronomy":"Astronomy",
                        u"Biochemistry":"Biochemistry",
                        u"Biophysics":"Biophysics",
                        u"Botany":"Plant Biology", #!: only 1991, a few dozen
                        u"Cell Biology":"Cell Biology",
                        u"Chemistry":"Chemistry",
                        u"Computer Sciences":"Computer Sciences",
                        u"Developmental Biology":"Developmental Biology",
                        u"Ecology":"Ecology",
                        u"Economic Sciences":"Economic Sciences",
                        u"Engineering":"Engineering",
                        u"Evolution":"Evolution",
                        u"Genetics":"Genetics",
                        u"Geology":"Geology",
                        u"Geophysics":"Geophysics",
                        u"Immunology":"Immunology",
                        u"Mathematics":"Mathematics",
                        u"Medical Sciences":"Medical Sciences",
                        u"Molecular Biology":"Biochemistry", #! only one instance
                        u"Microbiology":"Microbiology",
                        u"Neurobiology":"Neurobiology",
                        u"Neurosciences":"Neurobiology",#! only one instance, 1994
                        u"Pharmacology":"Physiology/Pharmacology", #! see below
                        u"Physics":"Physics",
                        u"Physiology":"Physiology/Pharmacology",#! to account for category Phys/Pharm from 1991
                        u"Plant Biology":"Plant Biology",
                        u"Plant Sciences":"Plant Biology", #! one instance in 1992
                        u"Political Sciences":"Social Sciences", #! two instances in 1999
                        u"Population Biology":"Population Biology",
                        u"Psychology":"Psychology",
                        u"Social Sciences":"Social Sciences",
                        u"Statistics":"Statistics"}

def main(): 
    url_base = "http://www.pnas.org"
    filename = "selected.csv"
    reader = UnicodeReader(open(filename, "rb"))
    firstline = next(reader)
    field = dict(zip(firstline, range(len(firstline))))
    categories_major = [u"Biological Sciences", u"Physical Sciences", u"Social Sciences"]

    writer = UnicodeWriter(open("meta.csv", "wb")) #, delimiter="\t")

    ## Will: in CSV: .abstract.txt Location
    # category, keywords
    # option to ignore all lines that have no abstract.txt available
    # checks to show if all research articles now have a category

    ### All relevant abstracts
    notselected = 0
    processed_abstract_fields = []
    output_list = []
    duplicate_abstracts = 0
    downloads_selected=0
    lines_written=0

    if len(sys.argv) == 1:
        print "Available arguments:"
        print "'all' ......... process all input lines."
        print "'skiperrors'... only return complete metadata."; exit(1)
        print "Warnings are also stored in the resulting file."
    elif len(sys.argv) == 2 and "all" in sys.argv: errorlineskip = 0
    elif len(sys.argv) == 2 and "skiperrors" in sys.argv: errorlineskip = 1
    else: print "Wrong argument"; exit(1)
    print "Remember to previously run ./2-select.py without -m flag to ensure that all relevant abstracts are tagged for download!"

    firstline = []
    for value in range(len(field)):
        for key in field:
            if field[key] == value:
                firstline.append(key)
    writer.writerow(firstline + ["abstract_local_path", "local_fullpdf_path", "category_fullpdf", "category_abstract_1_major", "category_abstract_1_minor", "category_abstract_2_major", "category_abstract_2_minor","category_merged", "keywords", "warning"])

    for row in reader:
        add_local_abstract_path = ""
        add_local_fullpdf_path = ""
        add_category_fullpdf = ""
        add_keywords = ""
        add_warning = ""
        add_category_abstract_1_major=""
        add_category_abstract_1_minor=""
        add_category_abstract_2_major=""
        add_category_abstract_2_minor=""
        add_category_merged =""
        url_abstract = row[field['url_abstract']] 

        if url_abstract!="" and url_abstract in processed_abstract_fields:
            add_warning += "CSV: duplicate abstract path, "
            duplicate_abstracts += 1
            if errorlineskip: continue
        processed_abstract_fields.append(url_abstract)
        if url_abstract=="": add_warning+= "CSV: Empty url_abstract, "

        ## Only lines that were previously selected
        if row[field["download_abstract"]] == u"yes":
            downloads_selected+=1
            abstract_filename = url_abstract.split("/")[-1]
            base_filename = abstract_filename.split(".")[0]
            local_base_path = row[field['year']]+"/"+base_filename
            local_abstracttxt_path = row[field['year']]+"/"+abstract_filename+".txt"

            if os.path.isfile(local_abstracttxt_path):
                if os.path.getsize(local_abstracttxt_path)==0:
                    add_warning += "FILE: .abstract.txt is empty, "
                    if errorlineskip: continue
                else:
                    add_local_abstract_path = local_abstracttxt_path
                    add_warning += "FILE: OK: .abstract.txt, "
            else:
                add_warning += "FILE: .abstract.txt not found, "
                if errorlineskip: continue

            ## get pdf path 
            local_meta_path = local_base_path + ".full.pdf"
            if os.path.isfile(local_meta_path):
                add_local_fullpdf_path = local_meta_path

            ## get .category
            local_meta_path = local_base_path + ".full.category"
            if os.path.isfile(local_meta_path):
                metafile = open(local_meta_path, "rb")
                add_category_fullpdf = unicode(metafile.readline().strip())
                metafile.close()

            ## get .keywords
            local_meta_path = local_base_path + ".abstract.keywords"
            if os.path.isfile(local_meta_path):
                metafile = codecs.open(local_meta_path, "rb", encoding='utf-8')
                add_keywords = metafile.readline()
                add_keywords = add_keywords.replace(u"\u2016","|")
                metafile.close()

            ## get .categories from abstract
            local_meta_path = local_base_path + ".abstract.categories"
            if os.path.isfile(local_meta_path):
                cat_reader = UnicodeReader(open(local_meta_path, "rb"))
                linesread=0
                for line in cat_reader:
                    if line[0] in categories_major:
                        if linesread==0:
                            add_category_abstract_1_major=line[0]
                            add_category_abstract_1_minor=line[1]
                        if linesread==1:
                            add_category_abstract_2_major=line[0]
                            add_category_abstract_2_minor=line[1]
                    linesread+=1

        #else:

        ### Some more general checks
        #""" 
        if row[field['category']] in categories_major:
            ## generate merged categories
            if row[field['category_minor']]!="":
                add_category_merged = category_merged_dict[row[field['category_minor']]]
            else:
                add_warning += "META: no minor category, "
                if errorlineskip: continue
        elif row[field["category"]]=="Research Article":
            if add_category_fullpdf in [u"Colloquium Paper",u"Commentary",u"Review",u"Symposium Paper"]:
                add_warning += "META: 'Research article': irrelevant add_category_fullpdf, "
                if errorlineskip: continue
            else:
                if add_category_fullpdf!="":
                    add_category_merged = category_merged_dict[add_category_fullpdf]
                else:
                    add_warning += "META: 'Research article': empty add_category_fullpdf, "
                    if errorlineskip: continue
        ## very few cases for 2000, Special Feature, Research Article that have second categories in abstract
        elif row[field["category"]]!="" and row[field["category_minor"]]!="" and \
            add_category_abstract_1_major=="" and add_category_abstract_1_minor=="" and \
            add_category_abstract_2_major in categories_major:
                add_category_merged = category_merged_dict[add_category_abstract_2_minor]
                
        else:
            add_warning += "META: no category details, "
            if errorlineskip: continue

        if row[field["download_abstract"]] == u"":
            add_warning += "CSV: not selected for download, "
            notselected += 1
            if errorlineskip: continue
        #"""
        writer.writerow(row + [add_local_abstract_path, add_local_fullpdf_path, add_category_fullpdf,
                               add_category_abstract_1_major, add_category_abstract_1_minor,
                               add_category_abstract_2_major, add_category_abstract_2_minor,
                               add_category_merged, add_keywords, add_warning])
        lines_written+=1

    print "-"*80
    print "Errors resulted in skipping a line:", errorlineskip and "yes, only good data is saved to .csv" or "no, all warnings can be read in .csv output"
    print "Duplicate url_abstract:", duplicate_abstracts, errorlineskip and "(skipped)" or "(not skipped)"
    print "Lines with unique url_abstract:", len(processed_abstract_fields), errorlineskip and "." or "(including empty)"
    print "Abstracts originally selected for download:", downloads_selected, "(including 'Research Articles')"
    print "Output: lines written:", lines_written
    # print "Lines that were not selected for download:", notselected, errorlineskip and "(skipped, but full meta available (from previous scraping), including empty url_abstract)" or "(complement to selected)"

    print "-"*80

if __name__== "__main__":
    main()
