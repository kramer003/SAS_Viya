cas mysess;
caslib ankram datasource=(srctype="path") path="/viyafiles/ankram/Data" sessref=mysess;

libname cas_p cas caslib=casuser;


proc casutil;
load casdata="foods_prepped1.csv" incaslib="ankram" outcaslib="casuser" casout="foods";
run;

/*Clean  up data*/
data cas_p.foods2;
set cas_p.foods;
            
            datetm=time + "01jan1970 0:0:0"dt ;
                   Format datetm datetime. ;
                   
            date=datepart(datetm);
            	format date mmddyy10.;

            weekday=weekday(date);
            
            month=substr(put(date, mmddyy10.),1,2);
            
run;
    
/*Run FactMac*/
/*To avoid long run time, I previously performed auto tuning on the same data with Python API*/
/*I will  run the returned parameters here*/
proc factmac data=CAS_P.FOODS2 nfactors=20 learnstep=0.2 maxiter=80 
		outmodel=cas_p.factors;
	target score;
	input productId userId month / level=nominal;
run;

/*subset to item factors only*/
data cas_p.factors(replace=YES);
	set cas_p.factors;
	if variable="productId";
run;


/*Cluster the factors*/
/*Chooses 57*/
proc kclus data=CAS_P.FACTORS distance=euclidean noc=abc(minclusters=10) 
		maxclusters=20 outstat=cas_p.cluster_stats;
	input Factor1 Factor2 Factor3 Factor4 Factor5 Factor6 Factor7 Factor8 Factor9 
		Factor10 Factor11 Factor12 Factor13 Factor14 Factor15 Factor16 Factor17 
		Factor18 Factor19 Factor20 / level=interval;
	score out=cas_p.clusters copyvars=(_all_);
	ods output ABCStats=work._abc_stats_;
run;

proc sgplot data=work._abc_stats_;
	vline K / response=Gap lineattrs=(thickness=5) nostatlabel;
	yaxis grid;
	label K='Number of Clusters' Gap='Gap Statistic';
run;

proc delete data=work._abc_stats_;
run;

/*Item most representative of each cluster (Minimum distance)*/
proc fedsql sessref=mysess;
CREATE TABLE casuser.item_cluster_rep{options replace=TRUE} AS
	SELECT _cluster_id_,
	       Min(_distance_) AS min_distance,
	       MAX(level) AS productId 
	FROM casuser.clusters
	GROUP BY _cluster_id_;
quit;

/*Frequency of reviews for these items*/
proc fedsql sessref=mysess;
CREATE TABLE casuser.test1{options replace=TRUE} AS
	SELECT t1.productid, 
		   count(*) AS frequency,
		   avg(t1.score) AS Bias,
		   max(t2._cluster_id_) AS cluster
	FROM casuser.foods2 t1 
	INNER JOIN casuser.item_cluster_rep t2
	ON t1.productid=t2.productid
	GROUP BY t1.productId
	ORDER BY frequency DESC, bias DESC
	limit 57;
quit;

/*Most frequent reviews for all items*/
proc fedsql sessref=mysess;
CREATE TABLE casuser.test2 AS
	SELECT productid, 
		   count(*) AS frequency,
		   max(cluster) AS cluster
	FROM casuser.foods2
	GROUP BY productId
	ORDER BY frequency DESC
	limit 100;
quit;


cas mysess terminate;
