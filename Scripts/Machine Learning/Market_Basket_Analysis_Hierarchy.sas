cas mysess;

caslib ankram datasource=(srctype="path") path="/viyafiles/ankram/data" sessref=mysess notactive;
caslib _all_ assign;

/*Load Data*/
proc casutil;
	load casdata="nov00_sorted_v3.sas7bdat"
	incaslib="ankram"
	outcaslib="casuser"
	casout="november_baskets";
run;

/*Create Hierarchy*/
proc fedsql sessref=mysess;
	create table casuser.firstLevel AS
		select distinct t1.Prodid as Item,
		                t1.subclass as Category
		from casuser.November_Baskets t1;
quit;


proc casutil;
	save casdata="firstlevel"
	     incaslib="casuser"
	     outcaslib="casuser";
run;

/*Perform Analysis*/
proc mbanalysis data=casuser.november_baskets pctsupport=.5;
	customer id;
	target prodid;
	hierarchy data=casuser.firstLevel;
	output out=casuser.setmb 
	     outfreq=casuser.freqmb 
	     outrule=casuser.mba_rules;
run;

proc casutil;
	list tables incaslib="casuser";
run;

proc casutil;
	list tables incaslib="casuserhdfs";
run;


cas mysess terminate;
