cas mysess;

caslib ankram datasource=(srctype="path") path="/viyafiles/ankram/data" sessref=mysess;
libname local9 "/viyafiles/ankram/data";

caslib _all_ assign;

/*via cas*/
proc casutil;
	load data=local9.fs31hierarchy outcaslib="casuser" casout="fs31";
run;

proc autoreg data=casuser.fs31;
	model sales=date;
run;

/*through work (if sas7bdat)*/
proc autoreg data=local9.fs31hierarchy;
	model sales=date;
run;

cas mysess terminate;

/*reconcile data*/

/*ets*/
data work.outfor_top;
set mycaslib.outfor_top;
run;

proc sort data=outfor_top out=outfor_top_sorted;
by date;
run;


data work.outfor_parent;
set mycaslib.outfor_parent;
run;

proc sort data=outfor_parent out=outfor_parent_sorted;
by region date;
run;

/*Reconcile*/
 proc hpfreconcile disaggdata=outfor_parent_sorted
                     aggdata=outfor_top_sorted
                     direction=TD
                     outfor=lvl1recfor;
      id date interval=week;
      by region;
run;


