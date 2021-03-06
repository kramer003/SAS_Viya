*************************************************************                      
* Program Purpose = Add contextual data to the results of an 
Association Analysis Node in Enterprise Miner*

* ADD THIS CODE TO THE "SAS CODE" NODE UNDER UTILITY IN 
ENTERPRISE MINER AND CONNECT IIT TO THE PROCEEDING ASSOCIATION
ANALYSIS NODE* 

* AUTHOR - ANDREW KRAMER
*************************************************************;
*************************************************************;

***********************************************************
* Fill in Macros according to their definition in your data*
***********************************************************;
%LET IDvar=ID; /*Insert the name for your ID Variable in EM*/
%LET Target=prodid; /*Insert variable name of target variable*/
%LET Quantity=AMT; /*Insert variable name of unit quantity purchased*/
%LET Price=SalePrice; /*Insert variable for unit sale price*/
%LET Cost=Asset; /*Insert variable name for unit cost to compaany*/


***********************************************************
* Code to extract the number of rules and a macrro variable 
to extract the left and right side rules from the Enterprise
Miner Association Analysis Node Output*
***********************************************************;
PROC SQL;
	SELECT count(_LHAND)
	INTO :rules
	FROM &EM_IMPORT_RULES;
QUIT;

PROC SQL;
	CREATE TABLE varlist AS
	SELECT _LHAND, _RHAND
	FROM &EM_IMPORT_RULES;
QUIT;

DATA _NULL_;
	SET VARLIST;
	id=_N_;
	CALL SYMPUT('ids'||left(put(id,20.)), _LHAND);
	CALL SYMPUT('idst'||left(put(id,20.)), _RHAND);
RUN;

***********************************************************
* This code creates an empty dataset to append Macro Results *
***********************************************************;
DATA dataset;
	SET varlist;
		IF &target eq " ";
		IF &target eq " " THEN DELETE;
	A=" ";
	KEEP A;
RUN;

***********************************************************
* This macro crawls the dataset and generates specific summary
statistics for all transactions, and creates special statistics
for the transactions that contain both SKUs in the Enterprise Miner Rules.
***********************************************************;
%MACRO DsCrawl;

	Data Nov00_Analyzed(DROP=subclass &target &Quantity &cost &price);
		SET &EM_IMPORT_TRANSACTION;
		BY &IDvar;
		IF FIRST.&IDvar THEN DO;
			TotalProfit=0;
			ProfitableTransaction=0;
			VariableInQuestionQty=0;
			VariableInQuestionQty2=0;
			BasketSize=0;
			UniqueItemsPur=0;
			VariableInQuestionProfit=0;
			VariableInQuestionProfit2=0;
		END;

	
		IF &target="&&ids&i" THEN DO;
			VariableInQuestionQty+&Quantity;
			VariableInQuestionProfit+(&price-&cost);
		END;


		IF &target = "&&idst&i" THEN DO;
			VariableInQuestionQty2+&Quantity;
			VariableInQuestionProfit2+(&price-&cost);
		END;


		TotalProfit+(&price-&cost);
		Basketsize+&Quantity;
		UniqueItemsPur+1;

		IF TotalProfit gt 0 THEN ProfitableTransaction=1;
			else ProfitableTransaction=0;

    	IF SUM(VariableInQuestionProfit, VariableInQuestionProfit2) gt 0 THEN ProfitableAssoc=1;
			else ProfitableAssoc=0;

		IF LAST.&IDvar and VariableInQuestionQty gt 0 AND VariableInQuestionQty2 gt 0;

		RUN;	

%MEND DsCrawl;

***********************************************************
* Macro to calculate summary statistics from the output of 
the %DSCRAWL Macro*
***********************************************************;
%MACRO ProfitTrans;
	PROC SQL;
		CREATE TABLE ProfitPerc AS
		SELECT SUM(profitableAssoc) AS profitable, (COUNT(profitableAssoc)-SUM(profitableAssoc)) AS NotProfitable,
			   (SUM(profitableAssoc)/COUNT(profitableAssoc)) AS PercentProfitable, SUM(VariableInQuestionProfit) AS VarOneProfit, 
               SUM(variableinquestionprofit2) AS VarTwoProfit, (SUM(variableinquestionprofit)+sum(variableinquestionprofit2)) AS AssociationProfit, 
			   SUM(TotalProfit) AS MBProfit
		FROM nov00_analyzed;
	QUIT;
%MEND ProfitTrans;

***********************************************************
* MACRO TO append the results from the ProfitTrans macro
to the empty dataset created above. Will create a dataset with
where the number of rows equals the number of rules form Enterprise Miner*
***********************************************************;
%Macro DatasetUse;
	DATA dataset;
	SET dataset ProfitPerc;
	RUN;
%MEND DatasetUse;

***********************************************************
* MACRO to create summary data for each iteration of the
DO loop in the %AllSubs macro below*
***********************************************************;
%MACRO REPORT;
	PROC MEANS DATA=Nov00_Analyzed MAXDEC=2;
		VAR TotalProfit VariableInQuestionQty VariableInQuestionQty2 BasketSize UniqueItemsPur 
			VariableInQuestionProfit VariableInQuestionProfit2;
		TITLE "Report for rule &i";
		CLASS ProfitableTransaction;
	RUN;

	PROC REPORT DATA=Nov00_Analyzed;
		COLUMN ProfitableTransaction Totalprofit;
		DEFINE ProfitableTransaction/Group;
		DEFINE TotalProfit/analysis SUM;
	RUN;
%MEND;

***********************************************************
* MACRO instructing the macros defined above to iterate i 
amount of times where i = the number of rules as defined in 
the Association Analysis Output*
***********************************************************;
%MACRO AllSubs;
	%DO i=1 %TO &rules; /*&number;/*&counts;*/
		%DsCrawl
		%ProfitTrans
		%DatasetUse
		%REPORT
	%END;
%MEND AllSubs;
%AllSubs

***********************************************************
*  Appended output produced by the Association Analysis node
with the defined summary statistics in this program*
***********************************************************;
DATA dataset2;
	MERGE &EM_IMPORT_RULES dataset;
	DROP A ITEM4 ITEM5 transpose SET_SIZE  _LHAND _RHAND ITEM1 ITEM2 ITEM3 index;
	FORMAT PercentProfitable 10.4 MBProfit varoneprofit vartwoprofit AssociationProfit dollar15.;
RUN;

PROC PRINT DATA=dataset2;
RUN;
