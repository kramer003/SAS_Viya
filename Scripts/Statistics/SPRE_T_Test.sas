/*T test using the SPRE in SAS Viya*/

cas mysess;

caslib _all_ assign;

data casuser.read1;
      input score @@;
      datalines;
   40   47   52   26   19
   25   35   39   26   48
   14   22   42   34   33
   18   15   29   41   44
   51   43   27   46   28
   49   31   28   54   45
   40   47   52   19   25 
   35   35   35   14   34 
   33   41   27   46
   ;
run;

/*Test is significant at the .05 significance level (.0063 < .05)*/
/*We can conclude that the mean score is different from 30*/
proc ttest data=CASUSER.READ1 sides=2 h0=30 plots(showh0);
	var score;
run;
