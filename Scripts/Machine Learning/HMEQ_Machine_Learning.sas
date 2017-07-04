*This code was written by Jesse Luebbert, Global Technology Practice;


*--------------------------------------------- Setup and Initialize --------------------------------------------------------;

/* Create a SAS libref to machine learning sample data library */
libname locallib "/viyafiles/ankram/Data";

/* Define a CAS engine libref for CAS in-memory data tables */
libname mycaslib cas caslib=casuser;

/* Load the data in-memory for analysis */
%if not %sysfunc(exist(mycaslib.hmeq)) %then %do;
  data mycaslib.hmeq;
    set locallib.hmeq;
  run;	
%end;


*-----------------------------------------Data Exploration and Preparation--------------------------------------------------;

/*************************************/
/* Get a table of summary statistics */
/*************************************/
proc cardinality data=MYCASLIB.HMEQ maxlevels=100 outcard=mycaslib.summ 
		out=MYCASLIB.levelDetailTemp;
run;
proc print data=mycaslib.summ label;
	var _varname_ _type_ _rlevel_ _more_ _cardinality_ _nmiss_ _min_ _max_ _mean_ _stddev_ _skewness_ _kurtosis_;
	title 'Variable Summary';
run;
proc delete data=MYCASLIB.levelDetailTemp;
run;

/*******************************************************************/
/* Explore the distribution of the variables relative to the target*/
/*******************************************************************/
proc sgplot data=MYCASLIB.HMEQ;
	title "Explore Variable Distributions";
	vbox LOAN / category=BAD group=JOB grouporder=Data name='Box';
	xaxis fitpolicy=splitrotate;
	yaxis grid;
run;

/*****************************************/
/* Look into the missing value situation */
/*****************************************/
proc sgplot data=MYCASLIB.SUMM;
	title "Examine Missing Values";
	vbar _VARNAME_ / response=_NMISS_ fillattrs=(color=CX27a5b6) stat=Mean name='Bar';
	yaxis grid;
run;

/*************************/
/* Impute missing values */
/*************************/
proc varimpute data=MYCASLIB.HMEQ;
	input CLAGE MORTDUE / ctech=mean;
	input VALUE DELINQ CLNO / ctech=median;
	input NINQ DEROG / ctech=random;
	input DEBTINC YOJ / ctech=value cvalues=50,100;
	output out=MYCASLIB.HMEQ_PREPPED copyvars=(_all_);
run;

/******************************************************/
/* Look into the skewness of the numerical attributes */
/******************************************************/
proc sgplot data=MYCASLIB.HMEQ;
    title "Variable Breakdown";
	histogram LOAN / fillattrs=(color=CX53c544);
	yaxis grid;
run;

/*************************************/
/* Transform the necessary variables */
/*************************************/
data MYCASLIB.HMEQ;
	set MYCASLIB.HMEQ;
	inv2_LOAN=1 / LOAN**2;
run;

/*************************************************************/
/* Partition the Data into a 70/30 Training/Validation Split */
/*************************************************************/
title 'Partition the Dataset';
proc partition data=MYCASLIB.HMEQ_PREPPED partind samppct=70 seed=12345;
	output out=MYCASLIB.HMEQ_PART;
run;


*----------------------------------------------------- Model Building -------------------------------------------------------;

/*****************/
/* RANDOM FOREST */
/*****************/
title 'Random Forest';
proc forest data=MYCASLIB.HMEQ_PART ntrees=50 intervalbins=20 minleafsize=5 
            outmodel=mycaslib.forest_model;
  input LOAN MORTDUE VALUE YOJ DEROG DELINQ CLAGE NINQ CLNO DEBTINC / level = interval;
  input REASON JOB / level = nominal;
  target BAD / level=nominal;
  partition rolevar=_partind_(train='1' validate='0');
run;
/* Score the data using the generated RF model                          */
proc forest data=MYCASLIB.HMEQ_PART inmodel=mycaslib.forest_model noprint;
  output out=mycaslib._scored_RF copyvars=(_ALL_);
run;


/******************************/
/* GRADIENT BOOSTING MACHINES */
/******************************/
title 'Gradient Boosting';
proc gradboost data=MYCASLIB.HMEQ_PART ntrees=10 intervalbins=20 maxdepth=5 
               outmodel=mycaslib.gb_model;
  input LOAN MORTDUE VALUE YOJ DEROG DELINQ CLAGE NINQ CLNO DEBTINC / level = interval;
  input REASON JOB / level = nominal;
  target BAD / level=nominal;
  partition rolevar=_partind_(train='1' validate='0');
run;
/* Score the data using the generated GBM model                         */
proc gradboost  data=MYCASLIB.HMEQ_PART inmodel=mycaslib.gb_model noprint;
  output out=mycaslib._scored_GB copyvars=(_ALL_);
run;


/******************/
/* NEURAL NETWORK */
/******************/
title 'Neural Network';
proc nnet data=MYCASLIB.HMEQ_PART;
  target BAD / level=nom;
  input IM_CLAGE IM_CLNO IM_DEBTINC IM_DELINQ IM_DEROG IM_MORTDUE IM_NINQ IM_VALUE IM_YOJ / level=int;
  input REASON JOB / level=nom;
  hidden 5;
  train outmodel=mycaslib.nnet_model;
  partition rolevar=_partind_(train='1' validate='0');
  ods exclude OptIterHistory;
run;
/* Score the data using the generated NN model                          */
proc nnet data=MYCASLIB.HMEQ_PART inmodel=mycaslib.nnet_model noprint;
  output out=mycaslib._scored_NN copyvars=(_ALL_);
run;


/**************************/
/* SUPPORT VECTOR MACHINE */
/**************************/
title 'Support Vector Machine';
proc svmachine data=MYCASLIB.HMEQ_PART(where=(_partind_=1));
  kernel polynom / deg=2;
  target BAD;
  input IM_CLAGE IM_CLNO IM_DEBTINC IM_DELINQ IM_DEROG IM_MORTDUE IM_NINQ IM_VALUE IM_YOJ / level=interval;
  input REASON JOB / level=nominal;
  savestate rstore=mycaslib.svm_astore_model;
  ods exclude IterHistory;
run;
/* Score data using ASTORE code generated for the SVM model             */
proc astore;
  score data=MYCASLIB.HMEQ_PART out=mycaslib._scored_SVM 
        rstore=mycaslib.svm_astore_model copyvars=(BAD 	_partind_);
run;


*---------------------------------------- Model Assessment ------------------------------------------------;

/**********/
/* Assess */
/**********/
%macro assess_model(prefix=, var_evt=, var_nevt=);
  proc assess data=mycaslib._scored_&prefix.;
    input &var_evt.;
    target BAD / level=nominal event='1';
    fitstat pvar=&var_nevt. / pevent='0';
    by _partind_;
  
    ods output
      fitstat=&prefix._fitstat 
      rocinfo=&prefix._rocinfo 
      liftinfo=&prefix._liftinfo;
run;
%mend assess_model;
ods exclude all;
%assess_model(prefix=RF, var_evt=p_BAD1, var_nevt=p_BAD0);
%assess_model(prefix=SVM, var_evt=p_BAD1, var_nevt=p_BAD0);
%assess_model(prefix=GB, var_evt=p_BAD1, var_nevt=p_BAD0);
%assess_model(prefix=NN, var_evt=p_BAD1, var_nevt=p_BAD0);
ods exclude none;


/*************************************/
/* Gather information for Validation */
/*************************************/
ods graphics on;
data all_rocinfo;
  set SVM_rocinfo(keep=sensitivity fpr c _partind_ in=s where=(_partind_=0))
      GB_rocinfo(keep=sensitivity fpr c _partind_ in=g where=(_partind_=0))
      NN_rocinfo(keep=sensitivity fpr c _partind_ in=n where=(_partind_=0))
      RF_rocinfo(keep=sensitivity fpr c _partind_ in=f where=(_partind_=0));
  length model $ 16;
  select;
    when (s) model='SVM';
    when (f) model='Forest';
    when (g) model='GradientBoosting';
    when (n) model='NeuralNetwork';
  end;
run;
data all_liftinfo;
  set SVM_liftinfo(keep=depth lift cumlift _partind_ in=s where=(_partind_=0))
      GB_liftinfo(keep=depth lift cumlift _partind_ in=g where=(_partind_=0))
      NN_liftinfo(keep=depth lift cumlift _partind_ in=n where=(_partind_=0))
      RF_liftinfo(keep=depth lift cumlift _partind_ in=f where=(_partind_=0));
  length model $ 16;
  select;
    when (s) model='SVM';
    when (f) model='Forest';
    when (g) model='GradientBoosting';
    when (n) model='NeuralNetwork';
  end;
run;

/* Print AUC (Area Under the ROC Curve) */
title "AUC (using validation data) ";
proc sql;
  select distinct model, c from all_rocinfo order by c desc;
quit;

/*******************/
/* Draw ROC Charts */ 
/*******************/        
proc sgplot data=all_rocinfo aspect=1;
  title "ROC Curve (using validation data)";
  xaxis values=(0 to 1 by 0.25) grid offsetmin=.05 offsetmax=.05 label='False Positive Rate'; 
  yaxis values=(0 to 1 by 0.25) grid offsetmin=.05 offsetmax=.05 label='True Positive Rate';
  lineparm x=0 y=0 slope=1 / transparency=.7;
  series x=fpr y=sensitivity / group=model;
run;

/********************/
/* Draw Lift Charts */ 
/********************/        
proc sgplot data=all_liftinfo; 
  title "Lift Chart (using validation data)";
  yaxis label=' ' grid;
  series x=depth y=lift / group=model markers markerattrs=(symbol=circlefilled);
run;

title;
ods graphics off;
