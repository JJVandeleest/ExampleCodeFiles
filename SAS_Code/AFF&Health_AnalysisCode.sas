proc import datafile="C:\Users\Jessica\Box\McCowan Lab\Publications_Working\FemaleAffiliation_Health\AFF_Female_BiomarkersModels_Final.csv"
out = aff dbms = csv replace;
run;


Proc print data=aff;
run;

PROC FORMAT;
  VALUE  $RankLab "H" = "High"
				"M" = "Middle"
				"L" = "Low";
RUN;

data aff;
	set aff;
	label Cort = HCC (pg/mg)
		IL60 = IL-6
		TNFa0 = TNF-a
		eigenvectorweight = Weighted Political Eigenvector Centrality
		ffclosenessweight = Weighted Family/Friends Closeness Centrality
		informationweight = Weighted Political Information Centrality
		ranking = Rank;
	format ranking $RankLab.;
run;


**Run best models from paper to generate graphs**
**IL6;
proc glimmix data=aff method=laplace ic=q noreml;
	class cage;
	model IL60 = eigenvectorweight ffclosenessweight age /s dist=nb;
	random cage;
	store IL6;
run;

ods graphics on /border=off imagename="IL6" width= 3.25in height=3in;
ods listing IMAGE_DPI=600 STYLE=journal;
proc plm source = IL6;
*show all;
*effectplot slicefit(x = femaledc sliceby = sex) /clm ilink yrange = (30,140);
effectplot fit(x = eigenvectorweight) /clm ilink yrange = (0,100);
effectplot fit(x = ffclosenessweight) /clm ilink yrange = (0,100);
*effectplot slicefit(x = aggrrecM sliceby = sex) /clm ilink yrange = (30,140);
run;


**TNFa;
proc glimmix data=aff method=laplace ic=q noreml;
	class cage;
	model tnfa0 = eigenvectorweight ffclosenessweight ordergrp0 /s dist=nb;
	random cage;
	store TNFa;
run;

ods graphics on /border=off imagename="TNFa" width= 3.25in height=3in;
ods listing  IMAGE_DPI=600 STYLE=journal;
proc plm source = tnfa;
*show all;
*effectplot slicefit(x = femaledc sliceby = sex) /clm ilink yrange = (30,100);
effectplot fit(x = eigenvectorweight) /clm ilink yrange = (0,2000);
effectplot fit(x = ffclosenessweight) /clm ilink yrange = (0,2000);
*effectplot slicefit(x = aggrrecM sliceby = sex) /clm ilink yrange = (30,100);
run;


data aff2;
	set aff;
	if ranking = 'H' then ranking2 = 1;
	if ranking = 'M' then ranking2 = 2;
	if ranking = 'L' then ranking2 = 3;
run;


**HCC;
data aff2;
	set aff;
	if cort > 400 then cort = .;
	if ranking = 'H' then ranking2 = 1;
	if ranking = 'M' then ranking2 = 2;
	if ranking = 'L' then ranking2 = 3;
run;


proc glimmix data=aff2 method=laplace ic=q noreml;
	class cage ranking (ref = "High");
	model cort = ranking informationweight ffclosenessweight ranking*informationweight ranking*ffclosenessweight ordergrp0 /s dist=nb;
	random cage;
	store cort;
run;

ods graphics on /border=off imagename="Cort" width= 3.25in height=3in;
ods listing IMAGE_DPI=600 STYLE=journal;
proc plm source = cort;
*show all;
effectplot slicefit(x = informationweight sliceby = ranking) / ilink yrange = (25,150);
effectplot slicefit(x = ffclosenessweight sliceby = ranking) / ilink yrange = (25,150);
run;


******************running all grm analysis for new first section of results*********;
proc import datafile = "C:\Users\Jessica\Box\McCowan Lab\Publications_Working\FemaleAffiliation_Health\PolFFHDAllGrmDataOct2019_all.csv"
out = allgrm dbms = csv replace;
run;

data allgrm;
	set allgrm;
	label ranking = Rank;
	format ranking $RankLab.;
run;

proc print data=allgrm;
run;

proc corr data=allgrm;
	var allgrmbetweenness allgrmclusteringcoefficient age ordergrp0;
run;

proc glimmix data=allgrm method=laplace ic=q noreml;
	class cage ranking (ref = "High");
	model il60 = age allgrmbetweenness huddledegreefemaleweight/s cl dist=nb;
	random cage;
run;

proc glimmix data=allgrm method=laplace ic=q noreml;
	class cage ranking (ref = "High");
	model il60 = age  allgrmclusteringcoefficient huddledegreefemaleweight/s cl dist=nb;
	random cage;
run;

proc glimmix data=allgrm method=laplace ic=q noreml;
	class cage ranking (ref = "High");
	model tnfa0 = age allgrmbetweennessweight huddledegreefemale/s cl dist=nb;
	random cage;
run;

data allgrm2;
	set allgrm;
	if cort > 400 then cort = .;
run;

proc univariate data=allgrm2;
	var cort;
	histogram cort/normal;
run;


proc glimmix data=allgrm2 method=laplace ic=q noreml;
	class cage ranking (ref = "High");
	model cort =huddledegreefemaleweight/s cl dist=nb;
	random cage;
run;



**********Editing GTL Language for figures in AFF paper******;
ods listing ;

/*EDITED CODE TO PRODUCE CUSTOMIZED MARGINAL PLOTS USING FIT COMMAND IN PROC PLM*/
proc template;                                                                
   link Stat.PLM.Graphics.FitPlot to Stat.Lmr.Graphics.FitPlot;               
   define statgraph Stat.Lmr.Graphics.FitPlot;     
      dynamic _NCOLS _NROWS _LIMITTEXT _LEGENDTITLE _YLABEL _SHORTYLABEL      
         _XLABEL _SHORTXLABEL _LONGXLABEL _XVAR _YVAR _XVAR_OBS _YVAR_OBS     
         _YVAR_OBS_VALUE _SMOOTH_OBS _SMOOTH_WEIGHT_OBS _TICKS _VIEWMIN       
         _VIEWMAX _VIEWMINTICK _VIEWMAXTICK _doSmooth _doOffset _doPlotbyTitle
         _doTitle2 _doAtTitle _doFixedAtTitle _TITLE _TITLE2 _PLOTBYTITLE     
         _ATTITLE _FIXEDATTITLE _OFFSET _TRANSPARENCY _YMIN _OBSNUM _UCL _LCL 
         _UCLM _LCLM _PREDICTED _PREDICTED_OBS _OBSLABEL _FREQ _WEIGHT        
         _DISTANCE _XVAR_OBS_DISPLAY _YVAR_OBS_DISPLAY _ID1 _ID2 _ID3 _ID4    
         _ID5 _YMAXREF _YMINREF _doWeight _doShowobs _doFringe _DEPTH         
         _ALPHALEVEL _RESPONSENAME _RESPONSELABEL _RESPONSEREF                
         _RESPONSEREFTITLE _RESPONSEVS _PREDLABEL _CONFLABEL _byline_         
         _bytitle_ _byfootnote_;                                              
      BeginGraph; 
		 *if (_DOPLOTBYTITLE)                                                  
            if (_DOTITLE2)                                                    
               entrytitle _TITLE " with " _TITLE2;                            
          *  else                                                              
               entrytitle _TITLE;                                             
          *  endif;                                                            
          *  entrytitle halign=center textattrs=GRAPHLABELTEXT _PLOTBYTITLE; 
         *else                                                                 
            entrytitle _TITLE;                                                
         *   if (_DOTITLE2)                                                    
               entrytitle halign=center textattrs=GRAPHVALUETEXT "With "      
                  _TITLE2;                                                    
         *   endif;                                                            
         *endif;                                                               
         *if (_DOATTITLE)                                                      
            entryfootnote halign=left textattrs=GRAPHVALUETEXT                
               "Fit computed at " _ATTITLE " " _FIXEDATTITLE;                 
         *else                                                                 
            if (_DOFIXEDATTITLE)                                              
               entryfootnote halign=left textattrs=GRAPHVALUETEXT             
                  "Fit computed at " _FIXEDATTITLE;                           
         *   endif;                                                            
         *endif;     
         layout overlay / yaxisopts=(gridDisplay=auto_off label=_YLABEL        
            shortlabel=_SHORTYLABEL linearopts=(
            tickvaluelist=_TICKS viewmin=_VIEWMIN viewmax=_VIEWMAX            
            thresholdmin=_VIEWMINTICK thresholdmax=_VIEWMAXTICK) LABELATTRS = 
			(family = "Arial" size = 9pt)) 
			xaxisopts=(gridDisplay=auto_off label=_XLABEL shortlabel=_SHORTXLABEL
			LABELATTRS = (family = "Arial" size = 9pt));       
            if (_DOOFFSET)                                                    
               scatterplot x=_XVAR_OBS y=_PREDICTED_OBS / yerrorlower=_LCL    
                  yerrorupper=_UCL name="PredictionLimits" LegendLabel=       
                  _PREDLABEL errorbarattrs=GRAPHPREDICTIONLIMITS markerattrs=(
                  size=0) rolename=(_tip1=_OBSNUM _tip2=_LCL _tip3=_UCL _tip4=
                  _LCLM _tip5=_UCLM _tip6=_WEIGHT _tip7=_FREQ _id1=_ID1 _id2= 
                  _ID2 _id3=_ID3 _id4=_ID4 _id5=_ID5) tip=(x y _tip1 _tip2    
                  _tip3 _tip4 _tip5 _tip6 _tip7 _id1 _id2 _id3 _id4 _id5);    
               scatterplot x=_XVAR_OBS y=_PREDICTED_OBS / yerrorlower=_LCLM   
                  yerrorupper=_UCLM name="ConfidenceLimits" LegendLabel=      
                  _CONFLABEL errorbarattrs=GRAPHCONFIDENCE markerattrs=(size=0
                  ) rolename=(_tip1=_OBSNUM _tip2=_LCL _tip3=_UCL _tip4=_LCLM 
                  _tip5=_UCLM _tip6=_WEIGHT _tip7=_FREQ _id1=_ID1 _id2=_ID2   
                  _id3=_ID3 _id4=_ID4 _id5=_ID5) tip=(x y _tip1 _tip2 _tip3   
                  _tip4 _tip5 _tip6 _tip7 _id1 _id2 _id3 _id4 _id5);          
               scatterplot x=_XVAR_OBS y=_PREDICTED_OBS / name="Fit"          
                  legendlabel="Fit" markerattrs=GRAPHFIT (symbol=             
                  GraphData1:markersymbol) markercolorgradient=_DISTANCE      
                  colormodel=TWOCOLORRAMP reversecolormodel=true primary=true 
                  freq=_FREQ tip=(x y yerrorlower yerrorupper);               
               if (_DOSHOWOBS)                                                
                  referenceline y=_YMAXREF;                                   
                  referenceline y=_YMINREF;                                   
                  scatterplot x=_XVAR_OBS_DISPLAY y=_YVAR_OBS_DISPLAY / name= 
                     "Observed" legendlabel="Observed" freq=_FREQ datalabel=  
                     _OBSLABEL markerattrs=GRAPHDATA2 markercolorgradient=    
                     _DISTANCE colormodel=TWOCOLORRAMP reversecolormodel=true 
                     rolename=(_tipx=_XVAR_OBS _tip1=_OBSNUM _tip2=_LCL _tip3=
                     _UCL _tip4=_LCLM _tip5=_UCLM _tip6=_WEIGHT _tip7=_FREQ   
                     _tipy=_YVAR_OBS_VALUE _id1=_ID1 _id2=_ID2 _id3=_ID3 _id4=
                     _ID4 _id5=_ID5) tip=(_tipx _tipy _tip1 _tip2 _tip3 _tip4 
                     _tip5 _tip6 _tip7 _id1 _id2 _id3 _id4 _id5)              
                     datatransparency=_DEPTH;                                 
               endif;                                                         
            else                                                              
               bandplot limitupper=_UCL limitlower=_LCL x=_XVAR / connectorder
                  =axis name="PredictionLimits" LegendLabel=_PREDLABEL        
                  outlineattrs=GRAPHPREDICTIONLIMITS datatransparency=        
                  _TRANSPARENCY display=(outline) rolename=(_tip3=_YVAR) tip=(
                  x _tip3 limitlower limitupper);                             
               bandplot limitupper=_UCLM limitlower=_LCLM x=_XVAR /           
                  connectorder=axis name="ConfidenceLimits" LegendLabel=      
                  _CONFLABEL outlineattrs=GRAPHCONFIDENCE fillattrs=          
                  GRAPHCONFIDENCE datatransparency=_TRANSPARENCY rolename=(   
                  _tip3=_YVAR) tip=(x _tip3 limitlower limitupper);           
               seriesplot x=_XVAR y=_YVAR / primary=true connectorder=xaxis   
                  name="Fit" LegendLabel="Fit" lineattrs=GRAPHFIT rolename=(  
                  _tip4=_LCL _tip5=_LCLM _tip6=_UCLM _tip7=_UCL) tip=(x y     
                  _tip5 _tip6 _tip4 _tip7);                                   
               if (_DOSHOWOBS)                                                
                  referenceline y=_YMAXREF;                                   
                  referenceline y=_YMINREF;                                   
                  scatterplot x=_XVAR_OBS_DISPLAY y=_YVAR_OBS_DISPLAY / name= 
                     "Observed" legendlabel="Observed" freq=_FREQ datalabel=  
                     _OBSLABEL markercolorgradient=_DISTANCE colormodel=      
                     TWOCOLORRAMP reversecolormodel=true rolename=(_tipx=     
                     _XVAR_OBS _tip1=_OBSNUM _tip2=_LCL _tip3=_UCL _tip4=_LCLM
                     _tip5=_UCLM _tip6=_WEIGHT _tip7=_FREQ _tipy=             
                     _YVAR_OBS_VALUE _id1=_ID1 _id2=_ID2 _id3=_ID3 _id4=_ID4  
                     _id5=_ID5) tip=(_tipx _tipy _tip1 _tip2 _tip3 _tip4 _tip5
                     _tip6 _tip7 _id1 _id2 _id3 _id4 _id5) datatransparency=  
                     _DEPTH;                                                  
               endif;                                                         
            endif;                                                            
            if (_DOFRINGE)                                                    
               fringeplot _XVAR_OBS_DISPLAY / rolename=(_tipx=_XVAR_OBS _tip1=
                  _OBSNUM _tip2=_LCL _tip3=_UCL _tip4=_LCLM _tip5=_UCLM _tip6=
                  _WEIGHT _tip7=_FREQ _tipy=_YVAR_OBS_VALUE _id1=_ID1 _id2=   
                  _ID2 _id3=_ID3 _id4=_ID4 _id5=_ID5) tip=(_tipx _tipy _tip1  
                  _tip2 _tip3 _tip4 _tip5 _tip6 _tip7 _id1 _id2 _id3 _id4 _id5
                  ) datatransparency=_DEPTH;                                  
            endif;                                                            
            if (_DOSMOOTH)                                                    
               if (_DOWEIGHT)                                                 
                  loessplot y=_SMOOTH_WEIGHT_OBS x=_XVAR_OBS / lineattrs=     
                     GRAPHFIT2 name="Loess" legendlabel="Loess" weight=_WEIGHT;                                                                            
               else                                                           
                  loessplot y=_SMOOTH_OBS x=_XVAR_OBS / lineattrs=GRAPHFIT2   
                     name="Loess" legendlabel="Loess";                        
               endif;                                                         
            endif;                                                            
            if (_DOSMOOTH)                                                    
               discretelegend "Observed" "Fit" "Loess" / location=outside     
                  title=_LEGENDTITLE;                                         
            else                                                              
               if (_DOOFFSET)                                                 
                  discretelegend "Observed" "Fit" / location=outside title=   
                     _LEGENDTITLE;                                            
               endif;                                                         
            endif;                                                            
         endlayout;                                                           
         if (_BYTITLE_)                                                       
            entrytitle _BYLINE_ / textattrs=GRAPHVALUETEXT;                   
         else                                                                 
            if (_BYFOOTNOTE_)                                                 
               entryfootnote halign=left _BYLINE_;                            
            endif;                                                            
         endif;                                                               
      EndGraph;                                                               
   end;                                                                       
run;                                       

/*EDIT TEMPLATE FOR multiline PLOT*/
proc template;
source Stat.Lmr.Graphics.slicefitplot;
define statgraph Stat.Lmr.Graphics.Slicefitplot;
   dynamic _NCOLS _NROWS _LIMITTEXT _YLABEL _SHORTYLABEL _XLABEL _SHORTXLABEL _LONGXLABEL _doShowobs
      _doOffset _TICKS _VIEWMIN _VIEWMAX _VIEWMINTICK _VIEWMAXTICK _doPlotbyTitle _doTitle2
      _doAtTitle _doFixedAtTitle _TITLE _TITLE2 _PLOTBYTITLE _ATTITLE _FIXEDATTITLE _LEGENDTITLE
      _OFFSET _TRANSPARENCY _YMIN _XVAR _YVAR _UCL _LCL _UCLM _LCLM _PREDICTED _GROUP _INDEX
      _XVAR_OBS _YVAR_OBS _YVAR_OBS_VALUE _PREDICTED_OBS _XVAR_OBS_DISPLAY _YVAR_OBS_DISPLAY _FREQ
      _WEIGHT _OBSNUM _OBSLABEL _ID1 _ID2 _ID3 _ID4 _ID5 _TIP_Y _YMAXREF _YMINREF _DISPLAYMISSINGG
      _doShowobsNogroup _doFringe _DEPTH _ALPHALEVEL _RESPONSENAME _RESPONSELABEL _RESPONSEREF
      _RESPONSEREFTITLE _RESPONSEVS _PREDLABEL _CONFLABEL _LEGENDTITLELABEL _byline_ _bytitle_
      _byfootnote_;
   BeginGraph;
      /*if (_DOPLOTBYTITLE)
         if (_DOTITLE2)
            entrytitle _TITLE " with " _TITLE2;
         else
            entrytitle _TITLE;
         endif;
         entrytitle halign=center textattrs=GRAPHLABELTEXT _PLOTBYTITLE;
      else
         entrytitle _TITLE;
         if (_DOTITLE2)
            entrytitle halign=center textattrs=GRAPHVALUETEXT "With " _TITLE2;
         endif;
      endif;
      if (_DOATTITLE)
         entryfootnote halign=left textattrs=GRAPHVALUETEXT "Fit computed at " _ATTITLE " "
            _FIXEDATTITLE;
      else
         if (_DOFIXEDATTITLE)
            entryfootnote halign=left textattrs=GRAPHVALUETEXT "Fit computed at " _FIXEDATTITLE;
         endif;
      endif;*/
      layout overlay / yaxisopts=(gridDisplay=auto_off label=_YLABEL shortlabel=_SHORTYLABEL 
		linearopts=(tickvaluelist=_TICKS viewmin=_VIEWMIN viewmax=_VIEWMAX
         thresholdmin=_VIEWMINTICK thresholdmax=_VIEWMAXTICK) LABELATTRS = (family = "Arial" size = 9pt)) 
		xaxisopts=(gridDisplay=auto_off label= _XLABEL shortlabel=_SHORTXLABEL 
		LABELATTRS = (family = "Arial" size = 9pt));
         if (_DOOFFSET)
            scatterplot x=_XVAR_OBS y=_PREDICTED_OBS / yerrorlower=_LCL yerrorupper=_UCL name=
               "PredictionLimits" LegendLabel=_PREDLABEL group=_GROUP index=_INDEX
               includemissinggroup=_DISPLAYMISSINGG markerattrs=(size=0) rolename=(_tip1=_OBSNUM
               _tip2=_LCL _tip3=_UCL _tip4=_LCLM _tip5=_UCLM _tip6=_WEIGHT _tip7=_FREQ _id1=_ID1 _id2
               =_ID2 _id3=_ID3 _id4=_ID4 _id5=_ID5) tip=(group x y _tip1 _tip2 _tip3 _tip4 _tip5
               _tip6 _tip7 _id1 _id2 _id3 _id4 _id5);
            scatterplot x=_XVAR_OBS y=_PREDICTED_OBS / yerrorlower=_LCLM yerrorupper=_UCLM name=
               "ConfidenceLimits" LegendLabel=_CONFLABEL group=_GROUP index=_INDEX
               includemissinggroup=_DISPLAYMISSINGG markerattrs=(size=0) rolename=(_tip1=_OBSNUM
               _tip2=_LCL _tip3=_UCL _tip4=_LCLM _tip5=_UCLM _tip6=_WEIGHT _tip7=_FREQ _id1=_ID1 _id2
               =_ID2 _id3=_ID3 _id4=_ID4 _id5=_ID5) tip=(group x y _tip1 _tip2 _tip3 _tip4 _tip5
               _tip6 _tip7 _id1 _id2 _id3 _id4 _id5);
            scatterplot x=_XVAR_OBS y=_PREDICTED_OBS / name="Fit" legendlabel="Fit" group=_GROUP
               index=_INDEX includemissinggroup=_DISPLAYMISSINGG primary=true freq=_FREQ tip=(group x
               y yerrorlower yerrorupper);
         else
            bandplot limitupper=_UCL limitlower=_LCL x=_XVAR / connectorder=axis name=
               "PredictionLimits" LegendLabel=_PREDLABEL group=_GROUP index=_INDEX
               includemissinggroup=_DISPLAYMISSINGG datatransparency=_TRANSPARENCY display=(outline)
               rolename=(_tip3=_YVAR) tip=(group x _tip3 limitlower limitupper);
            bandplot limitupper=_UCLM limitlower=_LCLM x=_XVAR / connectorder=axis name=
               "ConfidenceLimits" LegendLabel=_CONFLABEL group=_GROUP index=_INDEX
               includemissinggroup=_DISPLAYMISSINGG datatransparency=_TRANSPARENCY rolename=(_tip3=
               _YVAR) tip=(group x _tip3 limitlower limitupper);
            seriesplot x=_XVAR y=_YVAR / primary=true connectorder=xaxis name="Fit" LegendLabel="Fit"
               group=_GROUP index=_INDEX includemissinggroup=_DISPLAYMISSINGG rolename=(_tip4=_LCL
               _tip5=_LCLM _tip6=_UCLM _tip7=_UCL) tip=(group x y _tip5 _tip6 _tip4 _tip7);
         endif;
         if (_DOSHOWOBS)
            referenceline y=_YMAXREF;
            referenceline y=_YMINREF;
            scatterplot x=_XVAR_OBS_DISPLAY y=_YVAR_OBS_DISPLAY / name="Observed" legendlabel=
               "Observed" group=_GROUP index=_INDEX includemissinggroup=_DISPLAYMISSINGG freq=_FREQ
               datalabel=_OBSLABEL rolename=(_tipx=_XVAR_OBS _tip1=_OBSNUM _tip2=_LCL _tip3=_UCL
               _tip4=_LCLM _tip5=_UCLM _tip6=_WEIGHT _tip7=_FREQ _tipy=_TIP_Y _id1=_ID1 _id2=_ID2
               _id3=_ID3 _id4=_ID4 _id5=_ID5) tip=(group _tipx _tipy _tip1 _tip2 _tip3 _tip4 _tip5
               _tip6 _tip7 _id1 _id2 _id3 _id4 _id5) datatransparency=_DEPTH;
         endif;
         if (_DOSHOWOBSNOGROUP)
            referenceline y=_YMAXREF;
            referenceline y=_YMINREF;
            scatterplot x=_XVAR_OBS_DISPLAY y=_YVAR_OBS_DISPLAY / name="Observed" legendlabel=
               "Observed" freq=_FREQ datalabel=_OBSLABEL rolename=(_tipx=_XVAR_OBS _tip1=_OBSNUM
               _tip2=_LCL _tip3=_UCL _tip4=_LCLM _tip5=_UCLM _tip6=_WEIGHT _tip7=_FREQ _tipy=_TIP_Y
               _id1=_ID1 _id2=_ID2 _id3=_ID3 _id4=_ID4 _id5=_ID5) tip=(_tipx _tipy _tip1 _tip2 _tip3
               _tip4 _tip5 _tip6 _tip7 _id1 _id2 _id3 _id4 _id5) datatransparency=_DEPTH;
         endif;
         if (_DOFRINGE)
            fringeplot _XVAR_OBS_DISPLAY / rolename=(_tipx=_XVAR_OBS _tip1=_OBSNUM _tip2=_LCL _tip3=
               _UCL _tip4=_LCLM _tip5=_UCLM _tip6=_WEIGHT _tip7=_FREQ _tipy=_TIP_Y _id1=_ID1 _id2=
               _ID2 _id3=_ID3 _id4=_ID4 _id5=_ID5) tip=(_tipx _tipy _tip1 _tip2 _tip3 _tip4 _tip5
               _tip6 _tip7 _id1 _id2 _id3 _id4 _id5) datatransparency=_DEPTH;
         endif;
         if (_DOSHOWOBS)
            if (_DOOFFSET)
               discretelegend "Fit" / title=_LEGENDTITLE location=inside autoalign = (topright topleft) across=1;
            else
               mergedlegend "Observed" "Fit" / location=outside title=_LEGENDTITLE across=1;
            endif;
         else
            discretelegend "Observed" "Fit" / location=inside title=_LEGENDTITLE autoalign = (topright topleft) across=1;
         endif;
      endlayout;
      if (_BYTITLE_)
         entrytitle _BYLINE_ / textattrs=GRAPHVALUETEXT;
      else
         if (_BYFOOTNOTE_)
            entryfootnote halign=left _BYLINE_;
         endif;
      endif;
   EndGraph;
end;
