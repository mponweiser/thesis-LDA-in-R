#! /usr/bin/python
#import os.path
#print os.path.supports_unicode_filenames
from time import sleep
from csv_unicode import *
import os
import sys
import pycurl
import codecs

def download_file_urllib(urlbase, urlpath, tofolder):
    from urllib2 import Request, urlopen
    filename = urlpath.split("/")[-1]
    if not os.path.exists(tofolder):
        os.makedirs(tofolder)
    # http://www.voidspace.org.uk/python/articles/urllib2.shtml#handling-exceptions
    req = Request(urlbase + urlpath)
    try:
        response = urlopen(req)
    except IOError, e:
        if hasattr(e, 'reason'):
            print urlbase+urlpath + ': We failed to reach a server.'
            print 'Reason: ', e.reason
        elif hasattr(e, 'code'):
            print urlbase+urlpath + ': The server couldn\'t fulfill the request.'
            print 'Error code: ', e.code
        return 1
    try:
        fileout = open(tofolder + "/" + filename, "wb")
        fileout.write(response.read())
        fileout.close
    except:
        print tofolder + filename + ": Error saving"
        return 1
    return 0

def download_file(url, tofolder, socks=False):
    filename = url.split("/")[-1]
    if not os.path.exists(tofolder):
        os.makedirs(tofolder)
    try:
        fileout = open(tofolder + "/" + filename, "wb")
    except:
        print tofolder +"/"+ filename + ": Error opening file for saving"
        return 1
    curl = pycurl.Curl()
    curl.setopt(pycurl.FOLLOWLOCATION, 1)
    curl.setopt(pycurl.MAXREDIRS, 5)
    curl.setopt(pycurl.CONNECTTIMEOUT, 30)
    curl.setopt(pycurl.TIMEOUT, 300)
    curl.setopt(pycurl.NOSIGNAL, 1)
    curl.setopt(pycurl.URL, url)
    curl.setopt(pycurl.WRITEDATA, fileout)
    if socks==True:
        curl.setopt(pycurl.PROXY, 'localhost')
        curl.setopt(pycurl.PROXYPORT, 8080)
        curl.setopt(pycurl.PROXYTYPE, pycurl.PROXYTYPE_SOCKS5)
    try:
 	curl.perform()
    except:
        print url+': Error downloading.'
 	import traceback
 	traceback.print_exc(file=sys.stderr)
 	sys.stderr.flush()
        return(1)
    curl.close()
    fileout.close()  
    return 0


def missing_loop(missinglist, filename, sockssupport):
    # the following is a loop that runs only if there were downloading errors.
    downloaded = 0
    missingloops = 1
    try:
        while missinglist != []:
            print "-"*40
            print "Retry loop", str(missingloops), " -", "Items missing:", len(missinglist)
            print "-"*40
            missinglist2 = []
            for missing in missinglist:
                sleep(1)
                if download_file(*missing, sockssupport)!= 0:
                    missinglist2.append(missing)
                else:
                    downloaded += 1
            # overwrite old list
            missinglist = missinglist2
            missingloops += 1
    except KeyboardInterrupt:
        for missing in missinglist:
            filemissing = open(filename ,"wb")
            filemissing.write(missing[0]+"\n")
            filemissing.close()
            print "Successfully downloaded:", downloaded
            print "Sill missing:", len(missinglist)
            print filename, "written!"
    return downloaded

def main(): 
    # more options?: verbose (Downloading...), different input file
    url_base = "http://www.pnas.org"
    interval = 10
    filename = "selected.csv"
    reader = UnicodeReader(open(filename, "rb"))
    firstline = next(reader)
    field = dict(zip(firstline, range(len(firstline))))
    sockssupport = False
    if "socks" in sys.argv:
        sockssupport=True

    downloaded = 0
    missinglist = []

    if "abstracts" in sys.argv:
        print "abstracts:"
        for row in reader:
            if row[field['download_abstract']]=="yes":
                print "Downloading:", row[field['url_abstract']], row[field['year']]
                if download_file(row[field['url_abstract']].encode("ascii"), row[field['year']], sockssupport)!= 0:
                    missinglist.append((row[field['url_abstract']], row[field['year']]))
                else:
                    downloaded += 1
                sleep(interval) # seconds
            #if downloaded == 3:
                #break
        print "="*40
        print "Successful downloads:", downloaded
        if missinglist != []:
            missingdownloaded = missing_loop(missinglist, "missing-abstracts.txt", sockssupport)
            print "Successful downloads in missing loop:", missingdownloaded

    elif "fullpdfs" in sys.argv:
        print "fullpdfs:"
        for row in reader:
            if row[field['download_fullpdf']]=="yes":
                url = row[field['url_fullpdf']].replace("+html","")
                print "Downloading:", url, row[field['year']]
                if download_file(url.encode("ascii"), row[field['year']], sockssupport)!= 0:
                    missinglist.append((url, row[field['year']]))
                else:
                    downloaded += 1
                sleep(interval) # seconds
            #if downloaded == 3:
            #    break
        print "="*40
        print "Successful downloads:", downloaded
        if missinglist != []:
            missingdownloaded = missing_loop(missinglist, "missing-fullpdf-res.txt", sockssupport)
            print "Successful downloads in missing loop:", missingdownloaded

    else:
        print "Fields in", filename, ":", field
        print
        print "Available arguments: 'fullpdfs' and/or 'abstracts' and/or 'socks'" 
        print "Socks support: ssh -D 8080 -v -N h0053049@login.wu.ac.at"

        #print "Test download:"
        #if download_file("http://www.pnas.org/content/98/26/14745.full.pdf", "test-curl") != 0:
        #    print "Error..."

if __name__== "__main__":
    main()
