cas mysess;
caslib _all_ assign;

/*Training=0;Validation=0*/
proc partition data=PUBLIC.HMEQ_PREP partind samppct=70;
	by BAD;
	output out=PUBLIC.HMEQ_PREP_STRAT;
run;

/*Autotune*/
proc forest data=PUBLIC.HMEQ_PREP_STRAT;
	partition role=_PartInd_ (validate='0');
	target BAD / level=nominal;
	input MORTGAGE_DUE LOAN VALUE YOJ DEROG DELINQ CLAGE NINQ CLNO DEBTINC / 
		level=interval;
	input REASON JOB / level=nominal;
	autotune tuningparameters=(ntrees maxdepth inbagfraction vars_to_try(init=12) 
		) maxtime=%sysevalf(1*60);
	ods output VariableImportance=Work._Forest_VarImp_;
run;

/*Variable Importance Plots*/
proc sgplot data=Work._Forest_VarImp_;
	title3 'Variable Importance';
	hbar variable / response=importance nostatlabel categoryorder=respdesc;
run;



cas mysess terminate;