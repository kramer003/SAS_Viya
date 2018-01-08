cas mysess;

caslib _all_ assign;

data casuser.iris;
   set sashelp.iris;
run;

/*Simple Network*/
proc bnet data=casuser.iris numbin=3 structure=Naive maxparents=1
         prescreening=0 varselect=0
         outnetwork=casuser.network;
     target Species;
     input PetalWidth PetalLength SepalLength SepalWidth/level=interval;
 run;
 
/*Advanced with hmeq*/
proc casutil;
	load file="/viyafiles/ankram/data/hmeq.sas7bdat"
	outcaslib="casuser"
	casout="hmeq";
run;

/*Partition data train 1 validation 0*/
proc partition data=casuser.hmeq partind samppct=70 seed=12345;	
	output out=casuser.hmeq_part;
run;

/*Choose best model amount structure (NAIVE TAN PC MB) and variable selection (Y/N)*/
proc bnet data=casuser.hmeq_part numbin=10 alpha=0.05
          structure=Naive TAN PC MB varselect=0 1 bestmodel
          outnetwork=casuser.network;
     target bad;
     input job reason/level=nominal;
     input clage clno debtinc delinq 
           derog loan mortdue ninq value yoj/level=interval;
     partition rolevar= _PartInd_ (TRAIN='1' VALIDATE='0');
     output out=casuser.hmeq_scored copyvars=(_ALL_);
     ods output nobs=nobs fitstatistics=fit validinfo=validinfo;
 run;
 
 
data casuser.incorrect;
	set casuser.hmeq_scored;
	if i_bad ne bad;
	where _partind_=0 and _warn_ is null;
run;
