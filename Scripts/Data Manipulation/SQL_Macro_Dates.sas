cas mysess;
caslib ankram datasource=(srctype="path") path="/viyafiles/ankram/data" sessref=mysess notactive;
caslib _all_ assign;

proc casutil;
	load file="/viyafiles/ankram/data/CCE_promoter_score_analytics.sas7bdat" 
	outcaslib="casuser"
	casout="cce_promoter";
run;

/*todays date*/
proc fedsql sessref=mysess;
	create table casuser.current_date as
		select *
		from casuser.cce_promoter
		where rate_plan_dt < today();
quit;

/*filter*/
proc fedsql sessref=mysess;
	create table casuser.filter_date as
		select *
		from casuser.cce_promoter
		where rate_plan_dt < date'2011-05-27';
		
quit;	


/*With macro*/
%let dt = date;
%let dt2=2011-05-27;
%put %tslit(&dt2.);

proc fedsql sessref=mysess;
	create table casuser.filter_date1 as
		select *
		from casuser.cce_promoter
		where rate_plan_dt < date %tslit(&dt2);	
quit;	

/*data step*/
data casuser.test2;
set casuser.cce_promoter;
if rate_plan_dt<'27may2011'd;
run;

/*Where clause*/
proc casutil;
	load casdata="CCE_promoter_score_analytics.sashdat" 
	incaslib="ankram"
	outcaslib="casuser"
	casout="cce_promoter1"
	where= "rate_plan_dt<'27may2011'd";
run;

/*Where clause with Macro*/
proc casutil;
	load casdata="CCE_promoter_score_analytics.sashdat" 
	incaslib="ankram"
	outcaslib="casuser"
	casout="cce_promoter3"
	where= "rate_plan_dt< %tslit(&dt2)d;";
run;

	
cas mysess terminate;
