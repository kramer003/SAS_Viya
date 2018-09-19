cas mysess;

/*configdir and jarpath must be on controller*/
caslib hivelib datasource=(srctype="hadoop" server="ccbu-hdp24-node1.aws.sas.com"
	dataTransferMode="serial"
	hadoopconfigdir="/viyafiles/ankram/hdp/conf"
	hadoopjarpath="/viyafiles/ankram/hdp/lib");
	
caslib _all_ assign;

/*Implicit SQL*/
proc fedsql sessref=mysess;
	create table public.hmeq_imp1 as
	select * 
	from hivelib.hmeq
	where bad=1
	limit 10;
quit;


/*View Schema*/
proc casutil;
	list files incaslib="hivelib";
run;

/*proc load*/
proc casutil;
	load casdata="hmeq"
	incaslib="hivelib"
	outcaslib="public"
	casout="hmeq_util";
run;


/*Implicit SQL*/
proc fedsql sessref=mysess;
	create table public.hmeq_imp1 as
	select * 
	from hivelib.hmeq
	where bad=1
	limit 10;
quit;

/*Explicit SQL*/
proc fedsql sessref=mysess;
create table casuser.hmeq_exp as
	select *
		from connection to hivelib
			(select * from hmeq
			 where bad=1
			 limit 10);
quit;

cas mysess terminate;