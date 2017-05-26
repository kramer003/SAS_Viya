from swat import *

# Connect to the session
cashost='racesx12069.demo.sas.com'
casport=5570
casauth='U:\.authinfo_w12_race'

s = CAS(cashost, casport, authinfo=casauth, caslib="casuser")

#Load sas dataset into memory
indata='movie_reviews'
s.loadTable(caslib='DemoData', path=indata+'.sas7bdat', casout={'name':indata});

#Save data as sas file and csv
s.table.save(caslib='DemoData', name='movie_reviews_hdat', table=indata)
s.table.save(caslib='DemoData', name='movie_reviews.csv', table=indata)


#load both datasets into memory
indata='movie_reviews_hdat'
indata2='movie_reviews'

s.loadTable(caslib='DemoData', path=indata+'.sashdat', casout=indata + '2');
s.loadTable(caslib='DemoData', path=indata2+'.csv', casout=indata2+'2');
