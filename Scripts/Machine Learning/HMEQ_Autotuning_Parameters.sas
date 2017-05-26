/*SAS VIYA Demo*/

*--------------------------------------------- Setup and Initialize --------------------------------------------------------;
/*Define a local library*/
libname DemoData '/opt/sasinside/DemoData';

/* Define a CAS engine libref for CAS in-memory data tables */
libname mycaslib cas caslib=casuser;

/* Load the data in-memory for analysis */
%if not %sysfunc(exist(mycaslib.hmeq_part)) %then %do;
  data MYCASLIB.hmeq;
    set DemoData.hmeq;
  run;	
%end;


proc partition data=MYCASLIB.HMEQ partind samppct=70 seed=12345;
	output out=MYCASLIB.HMEQ_PART;
run;

ods noproctitle;

proc forest data=MYCASLIB.HMEQ_PART seed=12345;
	partition role=_PartInd_ (validate='0');
	target BAD / level=nominal;
	input LOAN MORTDUE VALUE YOJ DEROG DELINQ CLAGE NINQ CLNO DEBTINC / 
		level=interval;
	input REASON JOB / level=nominal;
	autotune tuningparameters=(vars_to_try(init=4) ) maxtime=%sysevalf(1*60);
	ods output VariableImportance=Work._Forest_VarImp_;
run;

proc sgplot data=Work._Forest_VarImp_;
	title3 'Variable Importance';
	hbar variable / response=importance nostatlabel categoryorder=respdesc;
run;

title3;

proc delete data=Work._Forest_VarImp_;
run;


