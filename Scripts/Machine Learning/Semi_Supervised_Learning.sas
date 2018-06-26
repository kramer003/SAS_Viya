cas mysess;

caslib _all_ assign;

proc casutil;
list files incaslib="public";
run;

proc casutil;
load casdata="HMEQ.sashdat"
incaslib="public"
outcaslib="casuser"
casout="hmeq";
run;

/*Requires complete cases of independent variables*/
data casuser.hmeq;
set casuser.hmeq; 
*if cmiss(of _all_) then delete; 
if cmiss(of loan mortdue value yoj derog delinq clage ninq clno debtinc) then delete;
run;



/*unlabeled data*/
data casuser.unlabel(drop=bad); 
set casuser.hmeq(obs=3000); 
run;

/*Labeled data*/
data casuser.label; 
set casuser.hmeq(obs=200);
run;


proc SEMISUPLEARN data= casuser.unlabel 
label = casuser.label 
gamma = 1000; 
input loan mortdue value yoj derog delinq clage ninq clno debtinc; 
output out = casuser.out copyvars=(_all_); 
target bad;
run;

cas mysess terminate;
