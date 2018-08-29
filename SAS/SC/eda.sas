%include "D:\MFJK\SAS\Project\SC\BASE\miss_pct.sas";
%include "D:\MFJK\SAS\Project\SC\BASE\varlevel.sas";
%include "D:\MFJK\SAS\Project\SC\BASE\pmeta.sas";


%MACRO metadat9( DATA        = _LAST_
        , OUTMETA     = _META_
        ,   SAMPLE    = Yes 
        ,     EXACT_N = 100000
        ,     EXCLUDE = 
        ,   weight    =
        ,   freq      =
        ,output_xls = ./meta_output.xls
        ) ;

/*-------*
| Clean |
*-------*/
%macro clean (datasets) ;
	proc datasets nolist nowarn ;
		 delete &datasets ;
		 quit ;
	run ;
%mend  clean ;

%let blank=%str();

/*-----------------------------*
| Pull an exact Random Sample |
*-----------------------------*/
/*------------------------------------*
| process exclusive list frmm Sample |
*------------------------------------*/
%if %substr(%upcase(%left( &SAMPLE )),1,1) eq Y %then   /* SAMPLE */
	%do ;
		data _null_;
			set &DATA end=last;
			if last then
			call symput ('t_n', _N_);
		run;

		data  _SAMPLE_  ( compress=yes drop=needed left )    ;
			retain  needed &EXACT_N left      ;
			if  _n_  = 1 then left = %eval(&t_n)    ;
			set  &DATA       ; /* analysis dataset */
			if  ranuni (12345) <= ( needed/left ) then
			do ;
				output ;
				needed = needed - 1 ;
			end ;
			left = left - 1 ;
			if needed = 0 then stop ;
		run ;
  %end ; /* sample loop */

%else %do ;
	data _SAMPLE_  ;
	 set &DATA ;
	run ;
%end ; /* No sample loop */


%if &EXCLUDE ne %nrbquote(&blank) %then %do; 
	data _SAMPLE_;
		set _SAMPLE_(drop=&EXCLUDE);
	run ;
%end ; /* for exculde */



  %MISS_PCT ( DATA=_SAMPLE_
    , OUTDATA = &OUTMETA)

  %VarLevel(indsn=_SAMPLE_, var=_all_ , outdsn=tmp_level)
	/* xwu mark April/13/2007 the varname NLEVELS  should change to*/
	/* _LEVELS_ in order to be consistent with edacat macro */

  options notes ;

	proc sort data = &OUTMETA ; by _DORDER_ ; run ;

      data _NULL_ ;
       set &OUTMETA (where=(compress(upcase( _VTYPE_ )) eq "NUM")) end=eof ;

       _NUM_ + 1 ;
       call symput("NUM"||trim(left(put( _NUM_, best. ))),trim( _VARS_ ))   ;
       if eof then call symput('_NNUMS_',trim(left(put( _NUM_, best. ))))   ;
      run ;

      %macro NumerVar ;
       %do _i_ = 1 %to &_NNUMS_ ;
         &&NUM&_i_
       %end ;
      %mend  NumerVar ;


      /* proc univariate for some of the univariate information */
      proc univariate  data=_SAMPLE_  noprint ;
         var %NumerVar ;
         %if %length ( &freq   ) ne 0 %then %str( freq   &FREQ   ; ) ;
         %if %length ( &weight ) ne 0 %then %str( weight &WEIGHT ; ) ;

         output out = _mean_       mean      = %NumerVar ;
         output out = _std_        std       = %NumerVar ;
         output out = _min_        min       = %NumerVar ;
         output out = _max_        max       = %NumerVar ;
         output out = _range_      range     = %NumerVar ;
         output out = _var_        var       = %NumerVar ;
         output out = _cv_         cv        = %NumerVar ;
         output out = _skew_       skewness  = %NumerVar ;
         output out = _kurto_      kurtosis  = %NumerVar ;

         output out = _p1_         p1        = %NumerVar ;
         output out = _p5_         p5        = %NumerVar ;
         output out = _p10_        p10       = %NumerVar ;
         output out = _q1_         q1        = %NumerVar ;
         output out = _median_     median    = %NumerVar ;
         output out = _mode_       mode      = %NumerVar ;
         output out = _q3_         q3        = %NumerVar ;

         output out = _p90_        p90       = %NumerVar ;
         output out = _p95_        p95       = %NumerVar ;
         output out = _p99_        p99       = %NumerVar ;
         output out = _qrange_     qrange    = %NumerVar ;
         output out = _msign_      msign     = %NumerVar ;
         output out = _normal_     normal    = %NumerVar ;
         output out = _probn_      probn     = %NumerVar ;

      run ;

      data _STATS_ ;
         set _mean_     _std_     _var_      _cv_
           _min_      _p1_       _p5_      _p10_      _q1_
          _median_    _mode_      _q3_       _p90_ _p95_
           _p99_     _max_  _qrange_   _range_
           _skew_   _kurto_   _msign_  _normal_   _probn_ ;
      run ;

      %clean(
           _mean_     _std_     _var_      _cv_
           _min_      _p1_       _p5_      _p10_      _q1_
          _median_    _mode_      _q3_       _p90_ _p95_
           _p99_     _max_  _qrange_   _range_
           _skew_   _kurto_   _msign_  _normal_   _probn_ ) ;


      proc transpose data = _STATS_
          out  = _STATS_ (drop  = _LABEL_
              rename=( _name_ =     _VARS_
                  col1   =     _mean_
                  col2   =      _std_
                  col3   =      _var_
                  col4   =       _cv_
                  col5   =      _min_
                  col6   =       _p1_
                  col7   =       _p5_
                  col8   =       _p10_
                  col9   =       _q1_
                  col10   =   _median_
                  col11  =     _mode_
                  col12  =       _q3_
                  col13  =      _p90_
                  col14  =      _p95_
                  col15  =      _p99_
                  col16  =      _max_
                  col17  =   _qrange_
                  col18  =    _range_
                  col19  =     _skew_
                  col20  =    _kurto_
                  col21  =    _msign_
                  col22  =   _normal_
                  col23  =    _probn_ )) ;

       run ;

      /*-------*
       | Merge |
       *-------*/

      proc sort  data = _STATS_   ; by _VARS_ ; run ;
      proc sort  data = &OUTMETA  ; by _VARS_ ; run ;
      proc sort  data = tmp_level(rename=(TableVar=_VARS_ NLEVELS=_LEVELS_) ) ; by _VARS_ ; run ;
				/* xwu mark April/13/2007 the varname NLEVELS  should change to*/
				/* _LEVELS_ in order to be consistent with edacat macro */


      data &OUTMETA ;
         merge &OUTMETA (in=_a_) 
				 _STATS_ (in=_b_) 
				 tmp_level(in=_c_ ) ;
         by _VARS_ ;
         if _a_ ;
         label _mean_     = "Mean"
            _std_      = "Standard Deviation"
            _var_      = "Variance"
            _cv_       = "Coefficient of Variation"
            _min_      = "Minimum"
            _p1_       = "1st percentile"
            _p5_       = "5th percentile"
            _p10_       = "10th percentile"
            _q1_       = "25th percentile"
            _median_   = "50th percentile-Median"
            _mode_     = "Most Frequent Value"
            _q3_       = "75th percentile"
            _p90_      = "90th percentile"
            _p95_      = "95th percentile"
            _p99_      = "99th percentile"
            _max_      = "Maximum"
            _qrange_   = "Quartile Range(75th-25th percentile)"
            _range_    = "Range-Min to Max"
            _skew_     = "Skewness"
            _kurto_    = "Kurtosis"
            _msign_    = "Sign"
            _normal_   = "Test of Normality"
            _miss_   = "#of miss/#of obs %"
            _probn_    = "Prob for Normal(lt .1 then Non-Nor)" ;
      run ;

      proc delete data = _STATS_ ; run ;
      proc delete data = tmp_level ; run ;


   proc sort  data = &OUTMETA out = &OUTMETA ; by _AORDER_ ; run ;




%goto NORMAL ;

%QUIT:

      %put  ERROR:     Message from METADATA Macro:                        ;
      %put  ERROR:                                                         ;
      %put  ERROR:     +-------------------------------------------------+ ;
      %put  ERROR:     | PROGRAM HALTED.  OBSERVE THE WARNING MESSAGES   | ;
      %put  ERROR:     | ABOVE AND RERUN WITH CORRECTIONS.               | ;
      %put  ERROR:     +-------------------------------------------------+ ;


%NORMAL:

      %put NOTE: ;
      %put NOTE: ;
      %put NOTE:       +-------------------------------------------------+ ;
      %put NOTE:       | TO PRINT THE OUTPUT ON A SINGLE LANDSCAPE PAGE, | ;
      %put NOTE:       | SAVE THE FILE AND USE THE FOLLOWING COMMAND AT  | ;
      %put NOTE:       | THE UNIX PROMPT:           a2ps -F4.4 filename  | ;
      %put NOTE:       +-------------------------------------------------+ ;
      %put NOTE: ;
      %put NOTE: ;


/*if user did not use output_xls = ./meta_output.xls then use default*/
/*if user use output_xls = nothing then did not output xls      */
/*if user use output_xls = somthing then output somthing.xls     */

   proc contents data= &outmeta; run;


%if %length(&output_xls) > 0 %then %do;
 filename MSfile "&output_xls";
 ods html body=MSfile style=SASDOCPRINTER;
   %pmeta9(metadsn=&outmeta)
 ods html close;
%end;

%MEND metadat9 ;


/*start macro*/

%metadat9( DATA        = sclib.android
        , OUTMETA     = sclib.android_var
        ,   SAMPLE    = Yes 
        ,     EXACT_N = 100000
        ,     EXCLUDE = 
        ,   weight    =
        ,   freq      =
        ,output_xls = ./meta_output.xls
        ) ;
