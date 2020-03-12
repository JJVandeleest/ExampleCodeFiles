proc import datafile = "C:\Users\Jessica\Box\McCowan Lab\Projects_Funded\SSD\SSD_Analyses_Current\Infant_Health\\RawDatasets\SurvivalAnalysisDataset_Repeated_v2.csv"
	out=survival dbms = csv replace;
	getnames = y;
	datarow = 2;
run;

proc print data=survival;
run;

*Two data sets depending on whether it's reasonable to model third event (small N).  So far both sets yield very similar results so choosing survival3 to maximize sample;
data survival3;	
	set survival;
	if Strata <4;
run;

/*
data survival2;	
	set survival;
	if Strata <3;
run;
*/

proc sort data = survival3;
	by Animal_ID;
run;


/* Add in mother-infant relationship data*/
proc import datafile = "C:\Users\Jessica\Box\McCowan Lab\Projects_Funded\SSD\SSD_Analyses_Current\Infant_Health\RawDatasets\MI_Durations_020819.csv"
	out = MI dbms = csv replace;
	getnames = y;
	datarow = 2;
run;

proc sort data=MI;
	by AnimalID;
run;

proc print data = MI;
run;

*Average behavior durations across first six months;
/*
proc means data = MI noprint;
	by AnimalID;
	var SU VC CO PR GO PL AC IN nonmother withmom_suckling;
	where month < 7;
	output out = MI_mos1_6 mean=  ;
run;

proc print data = MI_mos1_6;
run;
*/

*Limited variation in average durations for months 1-6 likely due to 
high levels of maternal care required for all animals in months 1&2.  
Examine variation in maternal behavior in months 3-6 instead.  Use this.;

proc means data = MI noprint;
	by AnimalID;
	var SU VC CO PR GO PL AC IN nonmother withmom_suckling;
	where (month < 7 & month > 2);
	output out = MI_mos3_6 mean=  ;
run;

proc print data = MI_mos3_6;
run;

proc univariate data = mi_mos3_6;
	var nonmother;
run;

proc sort data = MI_mos3_6;
	by AnimalID;
run;


* Import adjective data and add to the file;
proc import datafile = "C:\Users\Jessica\Box\McCowan Lab\Projects_Funded\SSD\SSD_Analyses_Current\Infant_Health\RawDatasets\MI_Cohort 1 Adjectives_02.18.19.csv"
	out = Adj_C1 dbms = csv replace;
	getnames = y;
	datarow = 2;
run;

proc import datafile = "C:\Users\Jessica\Box\McCowan Lab\Projects_Funded\SSD\SSD_Analyses_Current\Infant_Health\RawDatasets\MI_Cohort 2 Adjectives_02.18.19.csv"
	out = Adj_C2 dbms = csv replace;
	getnames = y;
	datarow = 2;
run;

data Adj_all;
	set Adj_C1 Adj_C2;
run;

proc sort data=Adj_all;	
	by Animal_ID;
run;

proc means data = Adj_all noprint;
	by Animal_ID month;
	var abusiveaggressive active affiliative aggressive calmrelaxed confident conflictual depressed fearful indifferent nervous nurture playful protective relaxed restrictive tense;
	where (month < 7 & month > 2);
	output out = Adj_mos mean=  ;
run;

proc means data= Adj_mos noprint;
	by Animal_ID;
	var abusiveaggressive active affiliative aggressive calmrelaxed confident conflictual depressed fearful indifferent nervous nurture playful protective relaxed restrictive tense;
	output out = Adj_summarized mean = ;
run;

proc means data= Adj_mos ;
	*by Animal_ID;
	var abusiveaggressive active affiliative aggressive calmrelaxed confident conflictual depressed fearful indifferent nervous nurture playful protective relaxed restrictive tense;
	*output out = Adj_summarized mean = ;
run;

proc corr data=adj_mos;
	var abusiveaggressive active affiliative aggressive calmrelaxed confident conflictual depressed fearful indifferent nervous nurture playful protective relaxed restrictive tense;
run;

Proc stdize data=Adj_summarized out=stdzadj method=std;
	var abusiveaggressive active affiliative aggressive calmrelaxed confident conflictual depressed fearful indifferent nervous nurture playful protective relaxed restrictive tense;
run;

proc print data = stdzadj;
run;

proc factor data=stdzadj simple rotate=oblimin;
	var abusiveaggressive active affiliative aggressive calmrelaxed confident conflictual depressed fearful indifferent nervous nurture playful protective relaxed restrictive tense;
run;

proc factor data=stdzadj simple rotate=oblimin;
	var abusiveaggressive  aggressive calmrelaxed conflictual indifferent nurture protective restrictive tense;
run;

proc factor data=stdzadj simple rotate=oblimin;
	var  active affiliative confident depressed fearful nervous playful relaxed ;
run;

data adj_mos_rev;
	set adj_mos;
	revnerv = 8-nervous;
	revind = 8-indifferent;
	revrelax = 8-relaxed;
	revconf = 8-confident;
	revconfl = 8-conflictual;
run;
/* Check reliability of factors produced with all adjectives run together.  Factors 1-2 great, 3 is ok, 4 & 5 are bad.*/
proc corr data = adj_mos alpha;
var active affiliative playful confident indifferent;
run;

proc corr data = adj_mos_rev alpha;
var calmrelaxed nurture relaxed revnerv;
run;

proc corr data = adj_mos alpha;
var abusiveaggressive aggressive tense conflictual;
run;

proc corr data = adj_mos alpha;
var fearful protective;
run;

proc corr data = adj_mos alpha;
var restrictive confident;
run;

/*Check reliability of scales using mother-infant adjectives only.  Factor 1 is good, 2 is iffy, 3 is bad*/
proc corr data = adj_mos_rev alpha;
var calmrelaxed revind nurture revconfl;
run;

proc corr data = adj_mos alpha;
var abusiveaggressive aggressive tense conflictual;
run;

proc corr data = adj_mos_rev alpha;
var restrictive conflictual protective revind;
run;

/*Check reliability of scales using infant adjectives only.  Factor 1 is good, factors 2&3 are not.*/
proc corr data = adj_mos_rev alpha;
var active affiliative playful;
run;

proc corr data = adj_mos_rev alpha;
var fearful nervous revrelax;
run;

proc corr data = adj_mos_rev alpha;
var depressed revconf fearful;
run;

/* Calculate new factor scores to use in analysis to represent nurtuting & abusive for M-I adjectives 
and positive engagement & distress for infants as I did in my dissertation.*/

data factors;
	set stdzadj;
	NurtureFactor = calmrelaxed + (-1*indifferent) + nurture + (-1*conflictual);
	AggressiveFactor = abusiveaggressive + aggressive + tense;
	PosEngFactor = active + affiliative + playful;
	Distressfactor = nervous + fearful + (-1*relaxed);
run;

proc print data=factors;
run;

Proc stdize data=factors out=factorsStd method=std;
	var nurturefactor aggressivefactor posengfactor distressfactor;
run;

proc print data=factorsstd;
run;

*Merge Datasets;
data survival3_MIAdj_mos3_6;
	merge survival3 MI_mos3_6(rename=(AnimalID = Animal_ID)) Adj_summarized factorsstd(drop = abusiveaggressive 
	active affiliative aggressive calmrelaxed confident conflictual depressed fearful indifferent nervous nurture playful protective relaxed restrictive tense);
	by Animal_ID;
	where Animal_ID >0;
run;

proc print data = survival3_MIAdj_mos3_6;
run;

* Save the resulting dataset for use in analysis;
LIBNAME surv 'C:\Users\Jessica\Box\McCowan Lab\Projects_Funded\SSD\SSD_Analyses_Current\Infant_Health\RawDatasets';
data surv.infsurvival;
	set survival3_MIAdj_mos3_6;
run;


/* Creating growth dataset from morphometrics */
proc import datafile = "C:\Users\Jessica\Box\McCowan Lab\Projects_Funded\SSD\SSD_Analyses_Current\Infant_Health\\RawDatasets\SSD_Morphometric Data Compiled.csv"
	out=growth dbms = csv replace;
	getnames = y;
	datarow = 2;
run;

proc print data= growth;
run;
* Extracting the variables names for reference;
proc contents data = growth
          noprint
          out = data_info
               (keep = name varnum);
run;

* sort "data_info" by "varnum";
* export the sorted data set with the name "variable_names", and keep just the "name" column;
proc sort data = data_info
     out = variable_names(keep = name);
     by varnum;
run;

* view the list of variables;
proc print data = variable_names
          noobs;
run;

data MorphSummarized;
	set growth;
	rename Weight_1_BBA = Weight_1
	Weight_2_RU1__kg_ = Weight_2
	Weight_3_RU2__kg_ = Weight_3
	Weight_4_RU3__kg_ = Weight_4
	Weight_5_RU4__kg_ = Weight_5
	Weight_6_RU5__kg_ = Weight_6
	Weight_7_RU6__kg_ = Weight_7;
	CR_1 = (Crown_Rump_1_BBA_1__cm_+Crown_Rump_1_BBA_2__cm_)/2;
	CR_3 = (Crown_Rump_3_RU2_1__cm_+Crown_Rump_3_RU2_2__cm_)/2;
	CR_4 = (Crown_Rump_4_RU3_1__cm_+Crown_Rump_4_RU3_2__cm_)/2;
	CR_5 = (Crown_Rump_5_RU4_1__cm_+Crown_Rump_5_RU4_2__cm_)/2;
	CR_6 = (Crown_Rump_6_RU5_1__cm_+Crown_Rump_6_RU5_2__cm_)/2;
	CR_7 = (Crown_Rump_7_RU6_1__cm_+Crown_Rump_7_RU6_2__cm_)/2;
	HC_1 = (Head_Circ_1_BBA_1__cm_+VAR10)/2;
	HC_3 = (Head_Circ_3_RU2_1__cm_+Head_Circ_3_RU2_2__cm_)/2;
	HC_4 = (Head_Circ_4_RU3_1__cm_+Head_Circ_4_RU3_2__cm_)/2;
	HC_5 = (Head_Circ_5_RU4_1__cm_+Head_Circ_5_RU4_2__cm_)/2;
	HC_6 = (Head_Circ_6_RU5_1__cm_+Head_Circ_6_RU5_2__cm_)/2;
	HC_7 = (Head_Circ_7_RU6_1__cm_+Head_Circ_7_RU6_2__cm_)/2;
	Age_1 = Date_1-Birth_Date;
	Age_2 = Date_2 - Birth_Date;
	Age_3 = Date_3 - Birth_Date;
	Age_4 = Date_4 - Birth_Date;
	Age_5 = Date_5 - Birth_Date;
	Age_6 = Date_6 - Birth_Date;
	Age_7 = Date_7 - Birth_Date;	
	BMI_1 = Weight_1_BBA/CR_1;
	BMI_3 = Weight_3_RU2__kg_ /CR_3;
	BMI_4 = Weight_4_RU3__kg_/CR_4;
	BMI_5 = Weight_5_RU4__kg_/CR_5;
	BMI_6 = Weight_6_RU5__kg_/CR_6;
	BMI_7 = Weight_7_RU6__kg_/CR_7;
run;

proc print data=morphsummarized;
run;

data surv.GrowthData;
	set morphsummarized (Keep = Animal_ID Animal_Name Birth_date  age_1 age_2 age_3 age_4 age_5 age_6 age_7 
	Weight_1 weight_2 weight_3 weight_4 weight_5 weight_6 weight_7
	cr_1 cr_3 cr_4 cr_5 cr_6 cr_7 hc_1 hc_3 hc_4 hc_5 hc_6 hc_7 bmi_1 bmi_3 bmi_4 bmi_5 bmi_6 bmi_7);
run;

proc print data=surv.GrowthData;
run;

*Reshape growth dataset to long format for analysis.;

data surv.growthlong;
	set surv.growthdata;

	array Aage(1:7) age_1-age_7;
	array aweight(1:7) weight_1-weight_7;
	array aCR(1:7) CR_1-CR_7;
	array aHC(1:7) HC_1-HC_7;
	array aBMI(1:7) BMI_1-BMI_7;

	do time = 1 to 7;
		age = aage(time);
		weight = aweight(time);
		CR = acr(time);
		HC = aHC(time);
		BMI = aBMI(time);
		output;
	end;

	drop age_1-age_7 weight_1-weight_7 CR_1-CR_7 HC_1-HC_7 BMI_1-BMI_7;

run;

proc print data=surv.growthlong;
run;

* find the max number of hospitalizations for each kid;
proc sort data=survival;
	by Animal_ID;
run;

proc means data = survival noprint;
	by Animal_ID;
	var D_D;
	where Animal_ID > 0;
	output out = numhosp sum=  ;
run;

proc print data=numhosp;
run;

data surv.FullGrowthdata_long;
	merge surv.growthlong numhosp(rename=(D_D = NumHosp)) surv.infsurvival(keep = Animal_ID sex matriline propoutranked matdc parity_numlivebirths 
	su ac pl nonmother withmom_suckling nurturefactor aggressivefactor posengfactor distressfactor);
	by Animal_ID;
	where Animal_ID >0;
run;

proc print data=FullGrowthdata_long;
run;
