libname test1 'C:\ISDS7024\Test1';

Data maxloan;
set test1.maxloan;
run;

data dummy;
set maxloan;
dummy=1;
run;

proc boxplot data=dummy;
plot ccavg*dummy/
CAXES=BLACK
		CFRAME=GRAY
		ctext=BLACK 
		cboxes=BLACK 
		cboxfill=BLUE
		idcolor=BLUE
		boxstyle=schematicid
		WAXIS=1
		haxis=axis1;
run;

proc univariate data=maxloan;
var ccavg;
run;

data DummysDeleted;
set maxloan;
if age>200 | ccavg > 60 | income > 200 | yrswmortgage>60;
run;

proc print data=dummysdeleted;
title1 'Univariate outliers';
run;

data DummysNoOutlier;
set maxloan;
if age>200 | ccavg > 60 | income > 200 | yrswmortgage>60 then delete;
run;

proc sgscatter data=dummysnooutlier;
matrix maxloan ccavg income yrswmortgage age;
title 'bivariate relationships';
run;

proc corr data=dummysnooutlier;
var  maxloan ccavg income yrswmortgage age;
title 'correlations';
run;

proc reg data = dummysnooutlier;
model maxloan = ccavg income age/scorr2 vif influence ;
output out = dummysNoOUtlier_2 rstudent=student cookd=cd h=leverage;
run;

proc print data=dummysnooutlier_2(obs=5);
run;

data RegDeleted_Outliers;
set dummysnooutlier_2;
/*if (cd>.2) | (abs(student)>2 and leverage>.04) then delete; */
if abs(student)>2 | cd>.2 then delete;
run;

proc print data=regdeleted_outliers;
title 'deleted outliers';
run;

proc reg data=regdeleted_outliers;
model maxloan=income/partial;
run;
