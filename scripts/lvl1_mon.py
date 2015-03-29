#!/usr/bin/python2.7 -tt

import urllib, urllib2, cookielib, sys
from BeautifulSoup import BeautifulSoup as bs

#USER -> username
#PASS -> password

def Connect2Web(argv):
	print argv
	url1 = "http://"+argv+"/login.egi?adm_name=USER&adm_pwd=PASS"
	url2 = "http://"+argv+"/status/overview.asp"
	cj = cookielib.CookieJar()
	opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
	resp = opener.open(url1)
	resp = opener.open(url2)

	data = resp.read()
	soup = bs(data)
	
	print soup
	#num = []
	#for td in soup.findAll("div", { "class":"ob_tbl" }):
	#	num += td.findAll("tr")
	#	link = connection.find("td")
	#	num = link.text
	#	print num

	resp.close()


#Define a main() function that prints a litte greeting
def main(argv):
  	Connect2Web(argv)

# This is the standard boilerplate that calls the maun function.
if __name__ == '__main__':
	    main(sys.argv[1])
