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



