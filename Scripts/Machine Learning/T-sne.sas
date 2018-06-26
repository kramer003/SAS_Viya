cas mysess;
caslib _all_ assign;



data casuser.iris; 
set sashelp.iris; 
id=_n_; 
run;

proc tsne data = casuser.iris 
nDimensions = 2
perplexity = 5 
learningRate = 100
 maxIters = 500;
 input SepalLength SepalWidth PetalLength PetalWidth; 
 output out = casuser.tsne_out copyvars=(id species);
 run;
 
proc sgplot data=casuser.tsne_out; 
title "Iris embedding";
 title1 "Scatter plot of iris embedding";
 scatter x=_DIM_1_ y=_DIM_2_ / group=species markerattrs=(symbol=CircleFilled);
 run;
