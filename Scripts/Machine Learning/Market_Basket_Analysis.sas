cas mysess;

caslib ankram datasource=(srctype="path") path="/viyafiles/ankram/data" sessref=mysess notactive;
caslib _all_ assign;

proc casutil;
	load casdata="nov00_sorted_v3.sas7bdat"
	incaslib="ankram"
	outcaslib="casuser"
	casout="november_baskets";
run;

/*Market Basket Analysis*/
proc mbanalysis data=casuser.november_baskets pctsup=.05;
idvariable=id;
run;


proc cas;
	loadactionset "rulemining";
	rulemining.mbanalysis /
	items=2
	idvariable="id"
	tgtvariable="prodid"
	table = {name = "november_baskets", caslib="casuser"}
	out = "fism3"
	suppct = .1;
run;

/*Frequent Item Set Mining*/
proc fism data=casuser.november_baskets pctsup=.05
var idvariable=id;
/*idvariable=id tgtVariable=Prodid;*/

run;

proc cas;
	loadactionset "rulemining";
	rulemining.fism /
	items=2
	idvariable="id"
	tgtvariable="prodid"
	table = {name = "november_baskets", caslib="casuser"}
	out = "fism3"
	suppct = .1;
run;

cas mysess terminate;
