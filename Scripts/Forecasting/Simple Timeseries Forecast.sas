/*Connect to server and load data*/
cas;
libname mycaslib cas caslib="DemoData";
libname local "/opt/sasinside/DemoData";

proc casutil;
	load data=local.reg2_gbtoys casout="toys" outcaslib="DemoData";
run;


/*single time series*/
/* automatic model generation, selection and forecasting using the ATSM package
	in TSMODEL
*/

proc tsmodel data   = mycaslib.toys
             outobj = (
                       outFor  = mycaslib.outFor /* output object tied to the outfor table in the caslib*/
                       outEst  = mycaslib.outEst
                       outStat = mycaslib.outStat
                       );
    id date interval=week;
    var units/acc=sum;
    var pctpromo/acc=avg;
    
    *use the ATSM package;
    require atsm;
    submit;
        *declare ATSM objects;
        declare object dataFrame(tsdf);
        declare object my_diag(diagnose);
        declare object my_diagSpec(diagspec);
        declare object forecast(foreng);
        declare object outFor(outfor); /* output object is declared, and tied to a type */
        declare object outEst(outest);
        declare object outStat(outstat);

        *setup dependent and independent variables;
        rc = dataFrame.initialize();
        rc = dataFrame.addY(units);
        rc = dataFrame.addX(pctpromo);

		*setup time series diagnose specifications;
       	rc = my_diagSpec.open();
        rc = my_diagSpec.setArimax('identify', 'both');
        rc = my_diagSpec.setEsm('method', 'best');
        rc = my_diagSpec.close();

		*diagnose time series and generate the candidate model
			 specifications;
        rc = my_diag.initialize(dataFrame);
        rc = my_diag.setSpec(my_diagSpec);
        rc = my_diag.run();

		*run model selection and generate forecasts;
        rc = forecast.initialize(my_diag);
        rc = forecast.setOption('lead', 12, 'holdoutpct', 0.1);
        rc = forecast.run();

		*collect forecast results;
        rc = outFor.collect(forecast);
        rc = outEst.collect(forecast);
        rc = outStat.collect(forecast);
    endsubmit;
run;


/* create a histogram of rmse for all 17 forecast models */

proc sgplot data=mycaslib.outstat;
histogram rmse;
run;



proc sgplot data=mycaslib.outfor;
               band x=date lower=lower upper=upper;
               series x=date y= predict;
               scatter x=date y=actual;
               /* flag the last observation on the response (sale) in the series */
               refline '04JAN04'd / axis=x lineattrs=(color=red);
run;
