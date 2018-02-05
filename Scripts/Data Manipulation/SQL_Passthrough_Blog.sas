cas mysess;
caslib _all_ assign;

/*Implicit passthroughs*/
proc fedsql sessref=mysess;
	create table casuser.test1 as
	select *
	from hadoop.va_service_detail;
quit;

proc fedsql sessref=mysess;
	create table casuser.test2 as
	select *
	from hadoop.va_member_detail;
quit;

/*40gb table*/
proc fedsql sessref=mysess;
	create table casuser.test3 as
	select t1.*,
		   t2.city,
		   t2.gender_cd,
		   t2.mbr_address,
		   t2.race_cd,
		   t2.year_of_birth_no
	from hadoop.va_service_detail t1
		inner join hadoop.va_member_detail t2
		on t1.consistent_member_id = t2.consistent_member_id
	where member_death_dt is not null
		and condition_cd = 'CAD';
quit;
		



/*Paralle load*/
proc casutil;
	load casdata="va_service_detail" 
	incaslib="hadoop" 
	outcaslib="casuser" 
	casout="va_service_detail";
run;

/*Parallel write back*/
proc casutil;
	load casdata="va_member_detail" 
	incaslib="hadoop" 
	outcaslib="casuser" 
	casout="va_member_detail";
run;

proc fedsql sessref=mysess;
	create table casuser.test4 as
	select t1.*,
		   t2.city,
		   t2.gender_cd,
		   t2.mbr_address,
		   t2.race_cd,
		   t2.year_of_birth_no
	from casuser.va_service_detail t1
		inner join casuser.va_member_detail t2
		on t1.consistent_member_id = t2.consistent_member_id
	where member_death_dt is not null
		and condition_cd = 'CAD';
quit;

cas mysess terminate;
