%macro logistic(seed=, indsn=,training=, varlist=, class=,equfile=, t=, g=);

proc sort data=&indsn;
by customer_id;
run;

%do i=&seed %to %eval(&seed + 1000*(&t-1)) %by 1000;

data model_data;
set &indsn;
if ranuni(&i)<1-&training then lv_1="V"; else lv_1="L";
if lv_1='L' and lv="S"
then depv=&depvar;
/*%include "I:\sas_output_20161101\_meta_stage_1_cf.txt";*/
run;


ods output ParameterEstimates=est_&i ModelBuildingSummary=order;


proc logistic data=model_data namelen=32 
outest=equat
;
class &&class;
model depv=&&varlist 
/ selection=stepwise sle=0.01 sls=0.01  lackfit rsq stb;     
     output out=pred pred=pred;
run;

%if "&equfile"="" %then %do;
%end;
%else %do;
%writelog8(indsn=equat ,link=logit,odepv=depv, file=&equfile,logit=logit,score=phat);
%end;

proc contents data=est_&i;
run;

proc sql;
create table est_var_&i as
select distinct(variable) as variable
from est_&i
where variable^="Intercept";
quit;

proc sql;
select sum(case when lv="H" then 1 else 0 end) as sh into: sh
from &indsn;
quit;


proc rank data=pred out=p_testing_2 groups=&g;var pred;ranks ranking;run;


proc sql; 
create table p_testing_3 as 
select
ranking, count(ranking) as apps,sum(&depvar)/count(ranking) as actual_bad, 1-avg(pred) as pred_bad
from p_testing_2
%if &training=1 %then %do;
%end; 
%else 
%if &sh=0 %then %do;
where lv_1="V"
%end;
%else %do;
where lv='H'
%end;
group by 1;

goptions reset=all device=jpeg hsize=12in vsize=7in;

symbol1   interpol=join value=dot color=vibg width=1 height=1.5 pointlabel=(height=10pt );                                                                          
symbol2  interpol=join value=square color=depk width=1 height=1.5 pointlabel=(height=10pt); 


/* Define axis characteristics */     
axis1 minor=none offset=(6pct,6pct)
      label=("resp_rate"); 
axis2  order=(0 to 0.5 by 0.1) minor=none                                                                                               
      label=('Resp_Rate') offset=(0,2pct);                                                                                                              
axis3 order=(0 to 0.5 by 0.1) minor=none
      label=('pred_rate') offset=(0,2pct);

legend1 value=('Resp_Rate') label=none frame;
legend2 value=('pred_rate') label=none frame;

title "Response Rate  for ranking";

proc gplot data=p_testing_3; 
 format actual_bad percent7.2 pred_bad percent7.2; 
  plot  actual_bad*ranking=1  / overlay     
                                 legend=legend1 
                                 haxis=axis1                                                                                              
                                 vaxis=axis2;                                                                                             
  plot2 pred_bad*ranking=2 / overlay 
                                legend=legend2 
                                 haxis=axis1                                                                                              
                                 vaxis=axis3; 
 
run;       


%end;

data est_all;
length variable $ 32;
set
%do i=&seed %to %eval(&seed + 1000*(&t-1)) %by 1000;
est_var_&i
%end;
;
run;

proc sort data= est_all out=est_all_out;
by variable;
run;


data est_all_out;
set est_all_out;
by variable;
if first.variable then count=0; count+1;
run;


%mend;
