LIBNAME surv 'C:\Users\Jessica\Box\McCowan Lab\Projects_Funded\SSD\SSD_Analyses_Current\Infant_Health\RawDatasets';

proc print data=surv.infsurvival;
run;

*Create categorized variables for the purose of plotting;
PROC FORMAT;
    VALUE groups
       1     = "Low"
       2     = "Middle"
       3 = "High";
RUN;
data survival_groups;
	set surv.infsurvival (keep = Animal_ID start stop strata D_D nonmother withmom_suckling d1act d2act);
	if nonmother < 41.17 then nonmother_group = 1;
	if (nonmother > 41.169 & nonmother < 52.51) then nonmother_group = 2;
	if nonmother > 52.511 then nonmother_group = 3;	
	if withmom_suckling < .4143 then SUmom_group = 1;
	if (withmom_suckling > .41429 & withmom_suckling < 0.63) then SUmom_group = 2;
	if withmom_suckling > 0.63 then SUmom_group =3;
	if d2act < -1.011785 then d2act_group = 1;
	if (d2act > -1.011786 & d2act < 0.631747) then d2act_group = 2;
	if d2act > 0.6317469 then d2act_group =3;
	label stop="Age in days";
	label nonmother_group="Time away from mom";
	label SUmom_group="Time with mom spent nursing";
	label d2act_group="Day 2 Activity Score";
	label strata = "Event";
	format nonmother_group groups. sumom_group groups. d2act_group groups.;
run;

/* Conditional model A based on https://stats.idre.ucla.edu/sas/faq/how-can-i-model-repeated-events-survival-analysis-in-proc-phreg/*/

proc phreg data=surv.infsurvival covs(aggregate) covm;
	class sex matriline;
	model (start stop)*D_D(0) =  parity_numlivebirths;
	*rankbydc = propoutranked*matdc;
	strata strata;
	id Animal_ID;
run;
/*tested propoutranked, matdc, rank*DC, matage, sex, ...no effect.  parity_numlivebirths marginal effect with higher parity associated with greater risk. 
For matriline, J & Q matrilines seem less likely to get diarrhea. non significant but higher than 1 hazard ration for B, D, &U.*/

proc phreg data=surv.infsurvival covs(aggregate) covm;
	class sex matriline;
	model (start stop)*D_D(0) =  confident nervous gentle vigilant ;
	strata strata;
	id Animal_ID;
run;

proc phreg data=surv.infsurvival covs(aggregate) covm;
	class sex matriline;
	model (start stop)*D_D(0) =  vigilant ;
	strata strata;
	id Animal_ID;
run; 
/* High vigilance predicts low diarrhea, no interactions with rank or DC*/

proc phreg data=surv.infsurvival covs(aggregate) covm;
	class sex matriline;
	model (start stop)*D_D(0) =  d1act d2act d1emo d2emo ;
	strata Strata;
	id Animal_ID;
run;

proc phreg data=surv.infsurvival covs(aggregate) covm;
	class sex matriline;
	model (start stop)*D_D(0) =  d1act d2act  ;
	strata Strata;
	id Animal_ID;
run;
/*Strong effect for low day 2 activity predicting greater incidence of diarrhea.  No effect for emotionality.  
Adding vigilance, vigilant effect disappears*/

proc corr data=surv.infsurvival;
	var matrank propoutranked nonmother d1act d2act withmom_suckling;
run;

proc corr data=surv.infsurvival;
	var  nonmother go pl ac in;
run;

proc corr data=surv.infsurvival;
	var  withmom_suckling su vc co pr;
run;

/* Explore MI Data*/
proc corr data=surv.infsurvival;
	var nonmother withmom_suckling nurturefactor aggressivefactor posengfactor distressfactor d1act d2act vigilant;
run;

proc corr data=surv.infsurvival;
	var nonmother withmom_suckling d1act d2act vigilant go pl ac in;
run;

ods graphics on;
proc univariate data=surv.infsurvival;
	histogram nonmother;
	histogram withmom_suckling;
	histogram d2act;
run;
ods graphics off;


/* Now try adding mother-infant variables as predictors*/

*Check mother-infant state durations;
proc phreg data=surv.infsurvival covs(aggregate) covm ;
	model (start stop)*D_D(0) =  withmom_SUPerc nonmother d1act d2act/ ;
	withmom_SUPerc = withmom_suckling*100;
	strata Strata;
	id Animal_ID;
	*assess var = (withmom_suckling)/resample=1000 seed=603708000 crpanel;
	*BASELINE OUT = survout COVARIATES = survival_groups/alpha=0.05 rowID= SUmom_group group=nonmother_group;
run;


*  try some plotting stuff as described here: http://support.sas.com/documentation/cdl/en/statug/66859/HTML/default/viewer.htm#statug_phreg_examples08.htm ;
baseline covariates=Myeloma outdiff=Diff1 survival=_all_/diradj group=Frac;

ods graphics on;
ods graphics on /border=off imagename="Nonmother";
ods listing IMAGE_DPI=300 STYLE=pearl;
proc phreg data=survival_groups covs(aggregate) covm plots(overlay)=survival;
	class nonmother_group(order=internal);
	model (start stop)*D_D(0) =  withmom_suckling nonmother_group d1act d2act/ ;
	*withmom_SUPerc = withmom_suckling*100;
	strata Strata;
	id Animal_ID;
	*assess var = (withmom_suckling)/resample=1000 seed=603708000 crpanel;
	BASELINE COVARIATES = survival_groups survival=_all_/diradj group=nonmother_group;
run;

ods graphics on /border=off imagename="Nursing";
ods listing IMAGE_DPI=300 STYLE=pearl;
proc phreg data=survival_groups covs(aggregate) covm plots(overlay)=survival;
	class  sumom_group(order=internal);
	model (start stop)*D_D(0) =  SUmom_group nonmother d1act d2act/ ;
	*withmom_SUPerc = withmom_suckling*100;
	strata Strata;
	id Animal_ID;
	*assess var = (withmom_suckling)/resample=1000 seed=603708000 crpanel;
	BASELINE COVARIATES = survival_groups survival=_all_/diradj group=SUmom_group;
run;

ods graphics on /border=off imagename="Activity";
ods listing IMAGE_DPI=300 STYLE=pearl;
proc phreg data=survival_groups covs(aggregate) covm plots(overlay)=survival;
	class d2act_group(order=internal);
	model (start stop)*D_D(0) =  withmom_suckling nonmother d1act d2act_group/ ;
	*withmom_SUPerc = withmom_suckling*100;
	strata Strata;
	id Animal_ID;
	*assess var = (withmom_suckling)/resample=1000 seed=603708000 crpanel;
	BASELINE COVARIATES = survival_groups survival=_all_/diradj group=d2act_group;
run;


*Try adjective ratings and factors.  None are predictors.;
proc phreg data=surv.infsurvival covs(aggregate) covm ;
	model (start stop)*D_D(0) =  withmom_SUPerc nonmother nurturefactor aggressivefactor;
	withmom_SUPerc = withmom_suckling*100;
	*NMbySU = withmom_suckling*100*nonmother;
	strata Strata;
	id Animal_ID;
run;



proc phreg data=survival_groups covs(aggregate) covm ;
	model (start stop)*D_D(0) = nonmother withmom_suckling/ ;
	strata Strata;
	id Animal_ID;
	*assess var = (withmom_suckling)/resample=1000 seed=603708000 crpanel;
	*BASELINE OUT = survout COVARIATES = survival_groups/alpha=0.05 rowID= SUmom_group group=nonmother_group;
run;

******************************************************************************************************************************
**Since results are almost identical for each strata, can I run the model without that treating each incidence as independent??;
data infsurv2;
	set surv.infsurvival;
	start2 = 0;
	stop2 = stop-start;
run;

proc print data=infsurv2;
run;

proc phreg data=infsurv2 covs(aggregate) covm ;
	model (start2 stop2)*D_D(0) =  withmom_SUPerc nonmother d1act d2act/ ;
	withmom_SUPerc = withmom_suckling*100;
	id Animal_ID;
	*assess var = (withmom_suckling)/resample=1000 seed=603708000 crpanel;
	*BASELINE OUT = survout COVARIATES = survival_groups/alpha=0.05 rowID= SUmom_group group=nonmother_group;
run;

*Create categorized variables for the purose of plotting;
data survival_groups2;
	set infsurv2 (keep = Animal_ID start2 stop2 D_D nonmother withmom_suckling);
	if nonmother < 41.17 then nonmother_group = 1;
	if (nonmother > 41.169 & nonmother < 52.51) then nonmother_group = 2;
	if nonmother > 52.511 then nonmother_group = 3;	
	if withmom_suckling < .4143 then SUmom_group = 1;
	if (withmom_suckling > .41429 & withmom_suckling < 0.63) then SUmom_group = 2;
	if withmom_suckling > 0.63 then SUmom_group =3;
run;

ods graphics on;
proc phreg data=survival_groups2 covs(aggregate) covm plots(overlay=group)=mcf;
	class nonmother_group SUmom_group;
	model (start2 stop2)*D_D(0) =   nonmother_group SUmom_group/ risklimits;
	id Animal_ID;
	*assess var = (withmom_suckling)/resample=1000 seed=603708000 crpanel;
	BASELINE OUT = survout COVARIATES = survival_groups2/alpha=0.05 rowID= SUmom_group group=nonmother_group;
run;
ods graphics off;

**********************************************************************************************************************************
*Plots suggest that for low time away from mom no subjects have low suckling and for high time away from mom, no one has high suckling (range restriction).  
Perhaps this is artifically creating results in the model.;
ods graphics on;
proc phreg data=survival_groups covs(aggregate) covm plots(overlay=group)=mcf;
	class nonmother_group SUmom_group;
	model (start stop)*D_D(0) =   nonmother_group SUmom_group/ risklimits;
	strata Strata;
	id Animal_ID;
	*assess var = (withmom_suckling)/resample=1000 seed=603708000 crpanel;
	BASELINE OUT = survout COVARIATES = survival_groups/alpha=0.05 rowID= SUmom_group group=nonmother_group;
run;
ods graphics off;



/* Plots and diagnostics*/
/* Is the shape of the survival curve similar for the three strata being tested*/
proc lifetest data = surv.infsurvival outsurv=surv1;
	time stop*D_D(0);
	strata strata;
run;


/***********************************************************************************/
/*Now modeling if diarrhea incidence can predict growth from morphometrics         */
/***********************************************************************************/
proc print data=surv.FullGrowthdata_long;
run;


/*Best model so far for BMI*/
proc mixed data=surv.FullGrowthdata_long covtest noclprint method=ml;
	class sex matriline;
	model bmi = time posengfactor propoutranked nurturefactor numhosp/s;
	*random  intercept time;
	repeated /sub=animal_ID type = ar(1);
run;

proc print data=surv.FullGrowthdata_long;
run;


/*Modeling Crown-rump length*/
proc mixed data=surv.FullGrowthdata_long covtest noclprint method=ml;
	class sex matriline;
	model cr = time numhosp aggressivefactor/s;
	*random  intercept time;
	repeated /sub=animal_ID type = ar(1);
run;


/*Modeling head circumference*/
proc mixed data=surv.FullGrowthdata_long covtest noclprint method=ml;
	class sex matriline;
	model hc = time propoutranked nurturefactor/s;
	*random  intercept time;
	repeated /sub=animal_ID type = ar(1);
run;
