Proc import datafile = "C:\Users\Jessica\Box\McCowan Lab\Projects_Funded\SSD\SSD_Analyses_Current\ANS\NC8_AllANS.csv"
	out = ANSdata dbms = csv replace;
	getnames = yes;
	datarow = 2;
run;

proc print data = ansdata;
run;
***************************************************************************
*Exploring Cohort and time differences in ANS measurements;

data ansdata2;
	set ansdata;
	if infBBA_HR < 120 then infBBA_HR = .;
run;	

proc anova data = ansdata2;
	class Cohort;
	model infBBA_HR = Cohort;
run;

proc anova data = ansdata2;
	class Cohort;
	model RU2018_HR = Cohort;
run;

proc anova data = ansdata2;
	class Cohort;
	model infBBA_RSA = Cohort;
run;

proc anova data = ansdata2;
	class Cohort;
	model RU2018_RSA = Cohort;
run;

proc anova data = ansdata2;
	class Cohort;
	model RU2018_PEP = Cohort;
run;

Proc import datafile = "C:\Users\Jessica\Box\McCowan Lab\Projects_Funded\SSD\SSD_Analyses_Current\ANS\NC8_AllANS_long.csv"
	out = ANSdata_long dbms = csv replace;
	getnames = yes;
	datarow = 2;
run;

proc print data = ansdata_long;
run;

data ansdata_long2;
	set ansdata_long;
	if HR < 120 then HR = .;
run;

proc anova data = ansdata_long2;
	class Cohort time;
	model HR = Cohort time Cohort*time;
	repeated time;
run;

proc print data=ansdata2;
run;

proc glm data = ansdata2;
	class Cohort;
	model infBBA_HR RU2018_HR = Cohort ;
	repeated time 2 (0 1)/printe;
	lsmeans  Cohort / out=means;
run;

proc print data=means;
run;

goptions reset=all;
symbol1 c=blue v=star h=.8 i=j;
symbol2 c=red v=dot h=.8 i=j;
axis1 order=(180 to 270 by 10) label=(a=90 'HR');
axis2 order = ('infBBA_HR' 'RU2018_HR') label=('Time') value=('inf' '2018');
proc gplot data=means;
  plot lsmean*_name_=Cohort/ vaxis = axis1 haxis = axis2;
  
run;
quit;

proc glm data = ansdata2;
	class Cohort;
	model infBBA_RSA RU2018_RSA = Cohort ;
	repeated time 2 (0 1)/printe;
	lsmeans  Cohort / out=means;
run;

goptions reset=all;
symbol1 c=blue v=star h=.8 i=j;
symbol2 c=red v=dot h=.8 i=j;
axis1 label=(a=90 'RSA');
axis2 order = ('infBBA_RSA' 'RU2018_RSA') label=('Time') value=('inf' '2018');
proc gplot data=means;
  plot lsmean*_name_=Cohort/ vaxis = axis1 haxis = axis2;
  
run;
quit;

proc glm data = ansdata2;
	model infBBA_HR YrBBA_HR RU2018_HR =  /nouni;
	repeated time 3 contrast(1)/ mean summary;
run;

proc print data=ansdata_long2;
run;

goptions reset=all;

proc gplot data=ansdata_long2;
  plot HR*time/ ;
  symbol1 c=blue v=star h=.8 i=rq;
run;
quit;

*Results suggest that awake and anesthetized HR and RSA are different.  
*Unclear if it is developmental or methodological.  
*Also, C2 HR at BBA is higher than C1, although no sign diff in 2018 and no diff in RSA
*No significant differences in HR, RSA or PEP at RU2018 despite C1 being 2.5 and C2 being 1.5.



****************************************************************************************
***Now checking to see what infant BBA measurements are associated with BBA awake ANS to see if similar 
patterns are present between BBA (infant or yearling) and anethetized ANS;
****************************************************************************************;

proc import datafile = "C:\Users\Jessica\Box\McCowan Lab\Projects_Funded\SSD\SSD_Analyses_Current\ANS\SSD_C1_ 2016_infant_SummarizedBBAdata_reducedDataset.csv"
	out = infBBA dbms = csv replace;
	getnames= yes;
	datarow = 2;
run;

proc print data=infBBA;
proc print data=ansdata;
run;

proc sort data = infBBA (drop = var37-var52 drop = _);
	by animid;
	where animid ne .;
run;

proc sort data = ansdata(rename=(MonkeyID = animid));
	by animid;
run; 

data allBBA;
	merge infBBA ansdata;
	by animid;
run;

proc print data=allBBA;
run;
