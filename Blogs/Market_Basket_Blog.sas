cas mysess nworkers=1;

caslib ankram datasource=(srctype="path") path="/viyafiles/ankram/data" sessref=mysess notactive;
caslib _all_ assign;

/*Load Data*/
proc casutil;
	load casdata="assocs.sas7bdat"
	incaslib="ankram"
	outcaslib="casuser"
	casout="assocs";
run;

/*Perform Analysis*/
proc mbanalysis data=casuser.assocs pctsupport=1;
	customer customer;
	target product;
	output out=casuser.setmb 
		outfreq=casuser.freqmb 
		outrule=casuser.mba_rules;
run;


/*Prepare rules for visualization*/
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
			   t1.support as item_support	   
		from casuser.FREQMB t1 inner join casuser.mba_rules t2
			on t1.item=t2.item2
		;
quit;

data casuser.mba_network_final;
	set casuser.mba_network casuser.mba_network2;
run;

/*promote data*/
proc casutil;
	promote casdata="mba_network_final"
	incaslib="casuser"
	casout="mba_assocs_network";
run;

/*Save data*/
proc casutil;
	save casdata="mba_assocs_network"
	incaslib="casuserhdfs"
	outcaslib="casuserhdfs"
	casout="MBA_ASSOCS_NETWORK"
	replace;
run;

cas mysess terminate;