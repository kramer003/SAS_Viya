cas mysess;

caslib ankram datasource=(srctype="path") path="/viyafiles/ankram/data" sessref=mysess notactive;
caslib _all_ assign;

proc casutil;
	load casdata="nov00_sorted_v3.sas7bdat"
	incaslib="ankram"
	outcaslib="casuser"
	casout="november_baskets";
run;

proc mbanalysis data=casuser.november_baskets pctsupport=.05;
customer id;
target prodid;
output out=casuser.setmb outfreq=casuser.freqmb outrule=casuser.mba_rules;
run;

proc fedsql sessref=mysess;
create table casuser.mba_network as
	select t1.item as t1_item,
		   t1.count as item_count,
		   t1.support as item_support,
	       t2.*
	from casuser.FREQMB t1 inner join casuser.mba_rules t2
	on t1.item=t2.item1;

	
create table casuser.mba_network2 as
	select t1.item as t1_item,
		   t1.count as item_count,
		   t1.support as item_support,
	       t2.*
	from casuser.FREQMB t1 inner join casuser.mba_rules t2
	on t1.item=t2.item2
	;
quit;

data casuser.mba_network_final;
	set casuser.mba_network casuser.mba_network2;
run;

proc casutil;
save casdata="mba_network" 
incaslib="casuser"
outcaslib="casuser";
run;

proc casutil;
save casdata="mba_network" 
incaslib="casuser"
outcaslib="ankram";
run;

proc casutil;
promote casdata="mba_network"
incaslib="casuser";
run;


cas mysess terminate;
