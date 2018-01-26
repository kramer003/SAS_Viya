cas mysess;
caslib _all_ assign;

/*Connect to hive
caslib hvlib sessref=mysess 
  dataSource=(srctype='hadoop',
              dataTransferMode='parallel',
              server='gtpviyaea22.unx.sas.com',
              username='ankram'
              hadoopJarPath="/opt/hadoop/lib",
              hadoopConfigDir="/opt/hadoop/conf",
              schema="hive");
*/

/*See files in hive caslib*/
proc casutil;
	list files incaslib="Hadoop";
run;

/*Load hive*/
/*dbmswhere is pushed down to hive*/
proc casutil;
	load casdata="ankram_hmeq" 
	incaslib="hadoop" 
	outcaslib="casuser" 
	casout="HMEQ_Hive"
	Options=(dbmswhere="bad=1");
run;

proc casutil;
	load casdata="ankram_hmeq" 
	incaslib="hadoop" 
	outcaslib="casuser" 
	casout="HMEQ_Hive1";
run;

/*Load hdfs*/
/*Where is not pushed down to hdfs*/
proc casutil;
	load casdata="HMEQ.csv" 
	incaslib="casuserhdfs" 
	outcaslib="casuser" 
	casout="HMEQ_HDFS"
	where="bad=1";
run;

/*load data*/
proc casutil;
	load file="/viyafiles/ankram/data/CCE_promoter_score_analytics.sas7bdat" 
	outcaslib="casuser" 
	casout="CCE_promoter_score_analytics";
run;

/*save to hive*/
proc casutil;
	save casdata="CCE_promoter_score_analytics" 
	incaslib="casuser" 
	outcaslib="hadoop" 
	casout="CCE_promoter_score_analytics"
	replace;
run;

/*save to hdfs*/
proc casutil;
	save casdata="CCE_promoter_score_analytics" 
	incaslib="casuser" 
	outcaslib="casuserhdfs" 
	casout="CCE_promoter_score_analytics";
run;

/*Load hive*/
/*dbmswhere is pushed down to hive*/
proc casutil;
	load casdata="CCE_promoter_score_analytics" 
	incaslib="hadoop" 
	outcaslib="casuser" 
	casout="cce_test"
	Options=(dbmswhere="pro_ind=1");
run;

proc casutil;
	load casdata="CCE_promoter_score_analytics" 
	incaslib="hadoop" 
	outcaslib="casuser" 
	casout="cce_test1";
run;

/*Load hdfs*/
/*where is not pushed down to hdfs. It is filtered in CAS*/
proc casutil;
	load casdata="CCE_promoter_score_analytics" 
	incaslib="hadoop" 
	outcaslib="casuser" 
	casout="cce_test2"
	where="mfg_name='Apple'";
run;


              
cas mysess terminate;
