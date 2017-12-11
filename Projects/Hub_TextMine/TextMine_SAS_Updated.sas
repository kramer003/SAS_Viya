cas mysess;

caslib _all_ assign;
libname sas9 "/viyafiles/ankram/data/";

/*Load prepped hub data*/
proc casutil;
	load file="/viyafiles/ankram/data/ViyaLIVE_HUB_combined_final.csv"
		outcaslib="casuser"
		casout="hub_text_andrew_studio";
run;

/*Load gtp members for stop list*/
proc casutil;
	load file="/viyafiles/ankram/data/stoplist_gtp.csv"
		outcaslib="casuser"
		casout="stoplist_gtp"
		importoptions=(filetype="csv" varchars="FALSE");
run;

/*Create combined stop list*/
data casuser.engstop_final;
	set casuser.stoplist_gtp sas9.engstop;
run;

/*save data*/
/*
caslib ankram datasource=(srctype="path") path="/viyafiles/ankram/data" sessref=mysess;

proc casutil;
save casdata="engstop_final"
	incaslib="casuser"
	outcaslib="ankram"
	casout="engstop_hubtext_andrew";
run;


/*Promote data*/
/*
proc casutil;
	promote casdata="engstop_final"
	incaslib="casuser"
	casout="stoplist_hubtext_andrew"
	outcaslib="public";
run;
*/

caslib ankram datasource=(srctype="path") path="/viyafiles/ankram/data" sessref=mysess;
proc casutil;
	load casdata="engstop_hubtext_andrew.sashdat"
	incaslib="ankram"
	outcaslib="public"
	casout="stoplist_hubtext_andrew"
	promote;
run;

/*Create two datasets for viya live or general hub*/
data public.updated_hub_text_viya_general(promote=YES);
	set public.updated_hub_andrew;
	if source='viya_hub';
run;

data public.updatedhub_text_viya_live;
	set public.hub_data_final_1127;
	if source ne 'viya_hub';
run;

/*Analysis*/
proc textmine data=PUBLIC.UPDATEDHUB_TEXT_VIYA_live;
	var complete_text3;
	doc_id id;
	parse stop=PUBLIC.STOPLIST_HUBTEXT_ANDREW outterms=casuser.terms;
	svd k=30 numlabels=5 outtopics=casuser.topics svds=casuser.svds_ outdocpro=casuser.projections ;
run;

ods graphics / reset imagemap;
title3 'Scree Plot';

proc sgplot data=casuser.svds_;
	vline _id_ / response=s nostatlabel stat=Mean markers;
	xaxis label='Topic';
	yaxis grid label='Singular Value';
run;

proc delete data=_tmpcas_._svds_;
run;

proc varclus data=CASUSER.PROJECTIONS hierarchy plots;
	var COL1 COL2 COL3 COL4 COL5 COL6 COL7 COL8 COL9 COL10 COL11 COL12 COL13 COL14 
		COL15 COL16 COL17 COL18 COL19 COL20 COL21 COL22 COL23 COL24 COL25 COL26 COL27 
		COL28 COL29 COL30;
run;

cas mysess terminate;
