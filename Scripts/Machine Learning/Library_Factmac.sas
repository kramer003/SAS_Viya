cas mysess;
caslib _ALL_ assign;

proc casutil;
	load file="/viyafiles/ankram/data/book_rating.xlsx" outcaslib="casuser" casout="checkout";
run;

/*Train Factmac Engine*/
proc factmac data=CASUSER.CHECKOUT nfactors=10 learnstep=0.15 maxiter=100;
	target rating;
	input Name Title / level=nominal;
	output out=casuser.score_out1 copyvars=(rating);
	savestate rstore=casuser.factors_out;
	id Name Title;
run;

/*Make Recommendations for one user*/
%let var = '0182d81e1b5d9f779a102d6ce9b02866';
data casuser.user_rec;
    set casuser.checkout;
    by title;
    if first.title;
    name=&var;
   	keep name title;
run;

proc astore;
	score data=CASUSER.USER_REC out=casuser.recommend rstore=CASUSER.factors_out;
run;

/*See recommendations*/
proc print data=casuser.recommend(obs=5);
	var title;
	by P_rating;
run;

/*See top recommendations*/
proc fedsql sessref=mysess;
	create table casuser.book_recs AS
	select * from casuser.recommend
	order by P_rating desc
	limit 5;
quit;
run;



cas mysess terminate;

