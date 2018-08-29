
**** print meta univariate analysis ; **** metadsn= parameter is required !!! ;

/*DEFINE  NLEVELS / SUM FORMAT= BEST9. WIDTH=8   SPACING=2   RIGHT "# of Cats" ;
*/

%macro pmeta9(metadsn=meta);

options ls=160 ps=65;
title2 "Univariate Analysis for data=&metadsn";
PROC REPORT DATA=&metadsn   SPLIT="/" ;

COLUMN  ( _VARS_  _VTYPE_ MISS_PCT _LEVELS_ _MEAN_ _STD_ _MODE_
          _MIN_ _P1_ _P5_  _P10_  _Q1_ _MEDIAN_  _Q3_ _P90_  _P95_ _P99_ _MAX_
        ) ;

DEFINE  _VARS_   / DISPLAY FORMAT= $32.  WIDTH=32   SPACING=1 LEFT  "Variable" ;
DEFINE  _VTYPE_  / DISPLAY FORMAT= $3.  WIDTH=5   SPACING=1 LEFT  "VType" ;
DEFINE  MISS_PCT   / SUM FORMAT=   4.1  WIDTH=4   SPACING=2   RIGHT '% Miss' ;

DEFINE  _LEVELS_ / SUM FORMAT= BEST9. WIDTH=8   SPACING=2   RIGHT "# of Cats" ;
DEFINE  _MEAN_   / SUM FORMAT=   7.3  WIDTH=8   SPACING=2   RIGHT "Mean" ;
DEFINE  _STD_    / SUM FORMAT=   7.2  WIDTH=8   SPACING=2   RIGHT "STD" ;


DEFINE  _MIN_    / SUM FORMAT= BEST9. WIDTH=8   SPACING=2   RIGHT "Min" ;
DEFINE  _P1_     / SUM FORMAT= BEST9. WIDTH=8   SPACING=2   RIGHT '1st %tile' ;
DEFINE  _P5_     / SUM FORMAT= BEST9. WIDTH=8   SPACING=2   RIGHT '5th %tile' ;
DEFINE  _P10_     / SUM FORMAT= BEST9. WIDTH=8   SPACING=2   RIGHT '10th %tile' ;
DEFINE  _Q1_     / SUM FORMAT= BEST9. WIDTH=8   SPACING=2   RIGHT '25th %tile';
DEFINE  _MEDIAN_ / SUM FORMAT= BEST9. WIDTH=8   SPACING=2   RIGHT "Median" ;
DEFINE  _MODE_   / SUM FORMAT= BEST9. WIDTH=8   SPACING=2   RIGHT "Mode" ;
DEFINE  _Q3_     / SUM FORMAT= BEST9. WIDTH=8   SPACING=2   RIGHT '75th %tile' ;
DEFINE  _P90_    / SUM FORMAT= BEST9. WIDTH=8   SPACING=2   RIGHT '90th %tile' ;
DEFINE  _P95_    / SUM FORMAT= BEST9. WIDTH=8   SPACING=2   RIGHT '95th %tile' ;
DEFINE  _P99_    / SUM FORMAT= BEST9. WIDTH=8   SPACING=2   RIGHT '99th %tile' ;
DEFINE  _MAX_    / SUM FORMAT= BEST9. WIDTH=8   SPACING=2   RIGHT "Max" ;

RUN ;

%mend pmeta9;
