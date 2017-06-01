/*Connect to server and load data*/
/*This program shows how to perform a reconciliation of a hierarchy in Viya Visual Forecasting*/
/*We will generate a forecast at each level of the hierarchy below and then reconcilie middle out*/
/*Hierarchy*/

/*
Overall
Region 
Region + Type 
*/


/*Connect to server and load data*/
cas;
libname mycaslib cas caslib="DemoData";
libname local "/opt/sasinside/DemoData";

proc casutil;
	load data=local.fs31hierarchy casout="fs31" outcaslib="DemoData";
run;

/*can aggregate data with tsmodel. Wont use here, but I aggregated yearly just for an example*/
proc tsmodel data   = mycaslib.fs31 out=mycaslib.fs31_test;

    by region type;
    id date interval=year;
    var baseprice /acc = avg;
    var promotion/acc = max;
    var sales/acc = sum;
run;

/*Model top of hierarchy - overall sales*/
proc tsmodel data   = mycaslib.fs31
             outobj = (
                       outFor  = mycaslib.outFor_top /* output object tied to the outfor table in the caslib*/
                       outEst  = mycaslib.outEst_top
                       outStat = mycaslib.outStat_top
                       );
    id date interval=week;
    var baseprice /acc = avg;
    var promotion/acc = max;
    var sales/acc = sum;

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
        rc = dataFrame.addY(sales);
        rc = dataFrame.addX(promotion);
        rc = dataFrame.addX(baseprice);

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

/*Plot MAPE and Accuracy*/
proc sgplot data=mycaslib.outstat_top;
	histogram mape;
run;

proc sgplot data=mycaslib.outfor_top;
               band x=date lower=lower upper=upper;
               series x=date y= predict;
               scatter x=date y=actual;
               /* flag the last observation on the response (sale) in the series */
               *refline '01DEC02'd / axis=x lineattrs=(color=red);
run;


/*Model middle level of hierarchy - region*/
proc tsmodel data   = mycaslib.fs31
             outobj = (
                       outFor  = mycaslib.outFor_parent /* output object tied to the outfor table in the caslib*/
                       outEst  = mycaslib.outEst_parent
                       outStat = mycaslib.outStat_parent
                       );
    by region;
    id date interval=week;
    var baseprice /acc = avg;
    var promotion/acc = max;
    var sales/acc = sum;

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
        rc = dataFrame.addY(sales);
        rc = dataFrame.addX(promotion);
        rc = dataFrame.addX(baseprice);

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

/* Plot MAPE and accuracy*/
proc sgplot data=mycaslib.outstat_parent;
histogram mape;
run;



proc sgplot data=mycaslib.outfor_parent (where=(region='reg1'));
               band x=date lower=lower upper=upper;
               series x=date y= predict;
               scatter x=date y=actual;
               /* flag the last observation on the response (sale) in the series */
               *refline '01DEC02'd / axis=x lineattrs=(color=red);
run;


/*Model lower level of hierarchy - region and type*/
proc tsmodel data   = mycaslib.fs31
             outobj = (
                       outFor  = mycaslib.outFor_child /* output object tied to the outfor table in the caslib*/
                       outEst  = mycaslib.outEst_child
                       outStat = mycaslib.outStat_child
                       );
    by region type;
    id date interval=week;
    var baseprice /acc = avg;
    var promotion/acc = max;
    var sales/acc = sum;

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
        rc = dataFrame.addY(sales);
        rc = dataFrame.addX(promotion);
        rc = dataFrame.addX(baseprice);

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

/* Plot MAPE and error*/
proc sgplot data=mycaslib.outstat_child;
histogram mape;
run;
proc sgplot data=mycaslib.outfor_child (where=(region='reg1' 
                              and type='tblre'));
               band x=date lower=lower upper=upper;
               series x=date y= predict;
               scatter x=date y=actual;
               /* flag the last observation on the response (sale) in the series */
               *refline '01DEC02'd / axis=x lineattrs=(color=red);
run;

/*Reconcilie forecast middle out*/

/*Top down forecast for region to region and type*/
proc cas;
	loadactionset "tsReconcile";
	tsReconcile.reconcileTwoLevels/
	parentTable={name="outfor_parent", caslib="DemoData"}
	childTable={name="outfor_child", caslib="DemoData", groupBy={"region","type"}}
	casOut={name="reconciled1", caslib="DemoData", replace=True}
	direction="td"
	disaggMethod="prop"
	timeId="Date";
run;

/*Use Aggregate to ensure reconciliation works. Aka sum of lowest level forecast (Region and Type) equals the Region Forecast*/
proc cas;
aggregation.aggregate /
table = {name="reconciled1", caslib="DemoData" groupBy={"region", "date"}}
varSpecs={{AGG="SUMMARY", name="predict", summarySubset="sum"}}
casout={name='test_reconciliation', caslib="DemoData"};
run;
quit;


/*Forecast bottom up to get reconcilied forecast for top level of forecast, overall sales*/
proc tsmodel data   = mycaslib.outfor_parent out=mycaslib.outfor_total1;
    id date interval=week;
    var predict /acc = sum;
    var actual/acc = sum;
run;

/*Graph final overall prediction*/
proc sgplot data=mycaslib.outfor_total1 ;
               series x=date y= predict;
               scatter x=date y=actual;
               /* flag the last observation on the response (sale) in the series */
               *refline '01DEC02'd / axis=x lineattrs=(color=red);
run;
