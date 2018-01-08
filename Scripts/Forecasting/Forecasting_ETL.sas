cas mysess;

caslib ankram datasource=(srctype="path") path="/viyafiles/ankram/data" sessref=mysess notactive;
caslib _all_ assign;

/*Load and prep store 1 data*/
proc casutil;
	load casdata="SAS_Forecasting study_store1.xlsx"
	incaslib="ankram"
	outcaslib="casuser"
	casout="store1_local"
	importoptions={filetype="excel"};
run;

data casuser.store1;
	set casuser.store1_local;
	vendor = 1;
	date=input(status_date,8.) -21916;
	format date mmddyy10.;
	if status_date ne "All";
	event="store1_event";
run;

/*Load and prep store 2 data*/
proc casutil;
	load casdata="SAS_Forecasting study_store2.xlsx"
	incaslib="ankram"
	outcaslib="casuser"
	casout="store2_local"
	importoptions={filetype="excel"};
run;

data casuser.store2;
	set casuser.store2_local;
	vendor = 1;
	date=input(status_date,8.) -21916;
	format date mmddyy10.;
	if status_date ne "All";
	event="store2_event";
run;

/*Merge data*/
data casuser.merged;
	set casuser.store1 casuser.store2;
run;

/*Generate time series*/
proc tsmodel data=CASUSER.MERGED seasonality=52 outarray=casuser.ts;
	by event;
	id date interval=WEEK setmissing=0 FORCEINPUTFORMAT;
	var sales / accumulate=total;
run;

data casuser.fakefield;
	date= '30dec2018'd;
	format date mmddyy10.;
	event="Pharma";
run;

data casuser.ts_updated;
	set casuser.ts casuser.fakefield;
run;

proc tsmodel data=CASUSER.ts_updated seasonality=52 outarray=casuser.ts_final;
	by event;
	id date interval=WEEK setmissing=missing FORCEINPUTFORMAT;
	var sales / accumulate=total;
run;

/*Load events*/
data casuser.store1_events;
	format date mmddyy10.;
	input event $ date mmddyy10. value;
datalines
;
IFSEC 06/15/2014 1
IFSEC 06/21/2015 1 
IFSEC 06/26/2016 1
IFSEC 06/18/2017 1
IFSEC 06/24/2018 1

;
run;

data casuser.store2_events;
	format date mmddyy10.;
	input event $ date mmddyy10. value;
datalines
;
Pharma 02/07/2016 1
Pharma 01/22/2017 1
Pharma 01/21/2018 1
;
run;

proc fedsql sessref=mysess;
	create table casuser.ts_complete{options replace=TRUE} as
	select t1.*,
	       t2.value as store1_flag,
	       t3.value as store2_flag
	from casuser.ts_final t1 
		left join casuser.store1_events t2 
				on t1.date=t2.date
		left join casuser.store2_events t3
				on t1.date=t3.date; 
quit;
run;

/*Save and promote data*/
data casuser.ts_complete_v1(promote=yes);
	set casuser.ts_complete;
	if pharma_flag = . then store1_flag = 0;
	if ifsec_flag = . then store2_flag = 0;
run;

proc casutil;
	save casdata="ts_complete_v1"
	incaslib="casuser"
	outcaslib="ankram";
run;

cas mysess terminate;
