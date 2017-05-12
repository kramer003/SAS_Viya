/*Define a CAS library*/
%let caslib=public;
libname mycaslib cas caslib=&caslib;

/*define Local library*/
libname DemoData '/opt/sasinside/DemoData';

/*Dataset*/
%let raw               = bank;

/*Load sas7bdat into CAS - datastep*/
%if not %sysfunc(exist(mycaslib.&raw)) %then %do;
  data mycaslib.bank_old;
  	set DemoData.&raw;
  run;
%end;

/*load sas7bdat into CAS - proc casutil*/ 
proc casutil;
    load data=DemoData.&raw OUTCASLIB="&caslib" casout="bank_new";
run;

/*partition data*/
proc partition data=mycaslib.bank_new partind samppct=70 seed=12345;
	output out=mycaslib.bank_partition;
run;


/*save a dataset as sashdat*/
proc casutil;
	save casdata="bank_partition" incaslib="&caslib" casout="test_save" outcaslib="DemoData" replace;
run;

/*save as a csv*/
proc casutil;
	save casdata="bank_partition" incaslib="&caslib" casout="test_save.csv" outcaslib="DemoData" replace;
run;

/*load data*/
proc casutil;
 load file="/opt/sasinside/DemoData/test_save.sashdat" casout="hello_hdat" outcaslib="&caslib" promote;
run;

proc casutil;
 load file="/opt/sasinside/DemoData/test_save.csv" casout="hello_csv" outcaslib="&caslib" promote;
run;

proc print data=mycaslib.hello_csv(obs=10);
run;

/*Drop a table*/
proc casutil;
   droptable casdata="hello_csv" incaslib="&caslib" quiet;
run;

/*Verify dropped*/
proc print data=mycaslib.hello_csv(obs=10);
run;

/*See on all disc files in local DemoData*/
proc casutil;
list files incaslib="DemoData" ;
run;

/*See all sashdat files in directory associated with caslib*/
proc casutil;
list files incaslib="&caslib" ;
run;

/*See in-memory files*/
proc casutil;
list tables incaslib="&caslib";
run;