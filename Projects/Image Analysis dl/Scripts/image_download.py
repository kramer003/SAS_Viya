import json
import urllib.request
from bs4 import BeautifulSoup

base_url = 'http://www.opticomdataresearch.com/'
url = 'http://www.opticomdataresearch.com/mole-on-skin-npages.htm'
npages = 25 

def pull_images(base_url, url, npages, source):
	url= url.replace('npages', str(npages))

	request = urllib.request.urlopen(url).read()
	request_soup = BeautifulSoup(request,"lxml")
	images = request_soup.find_all('img')

	for i,image in enumerate(images):
		jpg = image['src']
		filename = "img_" + str(i+1) + "_pg" + str(npages) + "_" + source + ".jpg"
		if jpg.startswith('images'):
			if jpg.endswith('b.jpg'):
				pass
			else:
				urllib.request.urlretrieve(base_url + jpg, "C:/GTP/VIYA/Demo/image_dl_demo/images/" + source + '/' + filename)
		else:
			pass
#pull_images(base_url,url, npages, 'opticom')

def pull_images_multiple_pg(base_url, url, npages, source):
	for i in range(1,npages+1):
		print(i)
		pull_images(base_url,url, i, source)

#Parameters defined above	
pull_images_multiple_pg(base_url,url, npages, 'opticom')
