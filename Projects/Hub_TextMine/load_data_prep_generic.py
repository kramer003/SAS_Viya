import pandas as pd


fin = open('C:/GTP/Programming/roadshow_text/raw_data/updated/hub_2179_nov20.csv', encoding='utf-8')
fout = open('C:/GTP/Programming/roadshow_text/prepped_data/hub_2179_nov20_prep.csv', 'w', encoding='utf-8')


line2=""
y=0 
for i,line in enumerate(fin):
	line=line.strip()

	if i==0:
		fout.write("text" + "\n")	

	else:
		if "/2017," in line:
				
			if y>0:
				line2=''.join(["\"",line2,"\""])
				line2=line2.replace(',',' ')
				fout.write(line2 + "\n")

			line2=line
			y=y+1

		else:
			line2=' '.join([line2,line])

#print(line2)
line2=line2.replace(',',' ')
fout.write(line2 + "\n")
		