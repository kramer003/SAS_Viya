cas mysess;

caslib _all_ assign;

proc casutil;
	load file="/viyafiles/ankram/data/va_service_detail.sas7bdat"
	outcaslib="public"
	casout="va_service_detail"
	promote;
run;

proc casutil;
	load file="/viyafiles/ankram/data/va_member_table_geo.sas7bdat"
	outcaslib="public"
	casout="va_member_table_geo"
	promote;
run;

proc casutil;
	load file="/viyafiles/ankram/data/CCE_promoter_score_analytics.sas7bdat"
	outcaslib="public"
	casout="cce_promoter_score_analytics"
	promote;
run;

/*
proc casutil;
	load file="/viyafiles/ankram/data/hmeq.sas7bdat"
	outcaslib="public"
	casout="hmeq"
	promote;
run;
*/

cas mysess terminate;
