%macro chisquare(string=, indsn=);

  %let word_cnt=%sysfunc(countw(%superq(string)));                                                                                      
  %do i = 1 %to &word_cnt;                                                                                                              
    %let var&i=%qscan(%superq(string),&i,%str( ));                                                                                      
    %put &&var&i;                                                                                                                       
  %end;  

  %do i = 1 %to &word_cnt;  

  ods output ParameterEstimates=est ModelBuildingSummary=order;
  proc logistic data=&indsn namelen=32;
  model &depvar=&&var&i/details;
  run;

  proc sql;
  create table chi_square&i as
  select variable, WaldChiSq, ProbChiSq
  from est  
  where variable<>"Intercept";
  quit;

  %end;  

  data var_chi_square;
  length variable $ 32;
  set 
  %do i = 1 %to &word_cnt;  
  chi_square&i
  %end; 
; 
run;

%mend;


/*start macro*/
%chisquare(string=sclib.android, indsn=ovr30)
