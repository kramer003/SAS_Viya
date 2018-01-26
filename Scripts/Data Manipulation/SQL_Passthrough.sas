cas mysess;
caslib _all_ assign;

proc fedsql sessref=mysess;
	create table casuser.test as
	select *
	from hadoop.ankram_hmeq;
quit;
