import lxml.html
from lxml import etree
import urllib
import codecs
# make HTTP request to site
page = urllib.urlopen("https://ta.wiktionary.org/wiki/%E0%AE%AA%E0%AE%AF%E0%AE%A9%E0%AE%B0%E0%AF%8D_%E0%AE%AA%E0%AF%87%E0%AE%9A%E0%AF%8D%E0%AE%9A%E0%AF%81:Info-farmer/Tamil_Lexicon/%E0%AE%95%E0%AE%A3%E0%AF%8D%E0%AE%9F%E0%AE%B1%E0%AE%BF%E0%AE%AF_%E0%AE%B5%E0%AF%87%E0%AE%A3%E0%AF%8D%E0%AE%9F%E0%AE%BF%E0%AE%AF%E0%AE%A9")
# read the downloaded page
doc = lxml.html.document_fromstring(page.read().decode('utf-8'))

links = doc.xpath("//a[contains(@class,'new')]")
with codecs.open("op.txt", "w", "utf-8-sig") as op:
	for link in links:
		tilde = etree.Element("p")
		tilde.text = "~"
		link.insert(1, tilde)
		t = lxml.html.tostring(link, method="text", encoding=unicode).replace("~ ", "~", 1) + '\n'
		op.write(t)
