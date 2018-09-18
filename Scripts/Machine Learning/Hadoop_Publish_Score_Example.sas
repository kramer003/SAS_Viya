/*Connect to CAS*/
cas mysess;
caslib _all_ assign;

/*Publish to Hadoop*/ 
proc cas;                                                 
  session mysess;
  loadactionset "modelPublishing";
  action publishModelExternal submit / 
      modelName="telco_churn" /*Name you wan to give model in HDFS*/
      modelType="ds2" /*Datastep or ds2 score code*/
             externalOptions={
                 extType="hadoop",
                 	 /*Root directory on HDFS filesystem where models will be stored*/ 
                 modeldir="/user/ankram", 
                 	/*Jar file and config directory*/
                 classpath="/opt/sas/viya/config/data/hadoop/lib:/opt/sas/viya/config/data/hadoop/conf"  
                 
             }  
             
             /*Location of the ds2 program to publish*/ 
      programfile="/shared/users/ankram/Projects/In_db_blog/dmcas_epscorecode.sas" 
  	     /*ASTORE file referenced in ds2 program above*/
    storetables={{caslib="models", name="_DM14WVE7P6T7BH3HOB2W2IZPH_ast.sashdat"}};
run;
quit;

/*View "telco_churn" directory in HDFS*/
proc casutil;
	list files incaslib="casuserhdfs";
run;

/*View "looking_glass_v4" table in Hive*/
proc casutil;
	list files incaslib="hivelib";
run;

/*Score Model*/
proc cas;                                                
  session mysess;
  loadactionset "modelPublishing";
  action runModelExternal submit / 
      modelName="telco_churn"
      externalOptions={
          extType="hadoop", server="ccbu-hdp24-node1" /*Hive Server*/, 
          modelDir="/user/ankram", 
          classpath="/opt/sas/viya/config/data/hadoop/lib:/opt/sas/viya/config/data/hadoop/conf",
          inTable="looking_glass_v4" /*Name of table in Hive to score*/,
          outTable="looking_glass_v4_scored" /*Name to give scored table in Hive*/,
          forceOverwrite=true 
      }
	  ;
run;
quit;

/*View looking_glass_v4_scored table in Hive*/
proc casutil;
	list files incaslib="hivelib";
run;

/*Load looking_glass_v4_scored into CAS*/
proc casutil;
	load casdata="looking_glass_v4_scored"
	incaslib="hivelib"
	outcaslib="casuser"
	casout="looking_glass_v4_scored";
run;

/*Terminate Session*/
cas mysess terminate;
