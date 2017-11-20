cas mysess;

caslib _all_ assign;

proc casutil;
	load file="/viyafiles/ankram/data/ViyaLIVE_HUB_combined_final.csv"
		outcaslib="casuser"
		casout="hub_text_andrew"
		promote;
run;


proc textmine data=CASUSER.HUB_TEXT_ANDREW;
	var text;
	doc_id id;
	parse;
	svd max_k=25 numlabels=5 outdocpro=casuser.projection outtopics=casuser.topics 
		svds=_tmpcas_._svds_;
run;

ods graphics / reset imagemap;
title3 'Scree Plot';

proc sgplot data=_tmpcas_._svds_;
	vline _id_ / response=s nostatlabel stat=Mean markers;
	xaxis label='Topic';
	yaxis grid label='Singular Value';
run;


cas mysess terminate;
