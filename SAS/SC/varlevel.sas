%macro VarLevel(indsn=_last_, var=_all_ , outdsn=VarLevel );


ods listing close;

ods output nlevels=&outdsn;
proc freq data=&indsn nlevels ;
     tables &var/missing;
     run;
ods output close;

ods listing;
proc print data=&outdsn;
     run;

%mend VarLevel;
