%MACRO MISS_PCT ( DATA= 
        ,OUTDATA=) ;

   /*----------------------------------------------------------------------------*/
   /*----------Contents----------------------------------------------------------*/
   /*----------------------------------------------------------------------------*/
   proc contents data = &DATA 
     out  = tmp_meta_ms (keep = NAME LABEL VARNUM TYPE NOBS 
     rename = ( NAME   = _VARS_ VARNUM = _DORDER_ LABEL  = _LABEL_ ))  noprint;
   run;

    
   /*----------------------------------------------------------------------------*/
   /*---------get whole variablelst----------------------------------------------*/
   /*----------------------------------------------------------------------------*/
   data tmp_meta_ms;
     length _VARS_ $32. _LABEL_ $60. _VTYPE_ $3. _DORDER_ _AORDER_ 4. ;
     set tmp_meta_ms   END=eof;
     _AORDER_ = _N_ ;
     if type = 1 then do; _VTYPE_ = "NUM" ; end;
     else do; _VTYPE_ = "CHR" ; end;
     call symput('varlst_'||left(_n_), _VARS_);
     call symput('varlsttype_'||left(_n_), _VTYPE_);
     if eof then call symput("total_var", trim(left(put(_N_, 8.))));
     drop type ;
     label _VARS_   = "Variables"
		 _LABEL_  = "Variable Labels"
		 _VTYPE_  = "Variable Type (NUM/CHR)"
		 _DORDER_ = "Position Order of Variables in DataSet"
		 _AORDER_ = "Alpha Order of Variables in DataSet" ;
   run ;


   /*----------------------------------------------------------------------------*/
   /*----------get total_chrvaribals---------------------------------------------*/
   /*----------------------------------------------------------------------------*/
   proc sql noprint;
     select count(*) into : total_chr
     from tmp_meta_ms
     where _VTYPE_='CHR';
   quit;


   /*----------------------------------------------------------------------------*/
   /*----------define variablelst------------------------------------------------*/
   /*----------------------------------------------------------------------------*/
   proc format;
     value $ch_ms ' '='MISS_c' other='NMISS_c';
     value n_ms .='MISS_n' other='NMISS_n';
   run;

   /*----------------------------------------------------------------------------*/
   /*----------get number of nomiss and number of miss for each numeric var------*/
     ****out=miss_N (drop=_label_ rename=(_NAME_=_VARS_ col1=n ));
   /*----------------------------------------------------------------------------*/
   proc means data=&DATA noprint;
     var _numeric_;
     output out=miss_NT(drop=_freq_ _type_) n=;
   run;

   
   proc transpose data=miss_NT   
     out=miss_N (rename=(_NAME_=_VARS_ col1=n ));
   run;


   /*----------------------------------------------------------------------------*/
   /*----------get number of nomiss and number of miss for each char var---------*/
   /*note:this approach is good for small number of char variables in the dataset*/
   /*due to limit size of macro variable. 																			 */
   /*----------------------------------------------------------------------------*/

   *************************;
   ****generate select list ;
   ****used for proc sql    ;
   *************************;
   proc sql noprint;
     select 'count(' || trim(_VARS_) ||') as '|| trim(_VARS_) into :select_lst
       separated by ','
       from tmp_meta_ms 
       where trim(upcase(_VTYPE_))='CHR';
   quit;


   *************************;
   ****get count #of nomising; 
   ****for each char var    ;
   *************************;
   proc sql noprint;
     create table tt as
       select &select_lst
       from &DATA;
   quit;

   proc transpose data=tt   out=miss_C ( rename=(_NAME_=_VARS_ col1=n));



   /*----------------------------------------------------------------------------*/
   /*-----combine numeric and char dataset togather with contents table----------*/
   /*----------------------------------------------------------------------------*/
   proc sql noprint; 
      create table &OUTDATA as
      select a._VARS_, a._LABEL_, a._VTYPE_,a._DORDER_, a._AORDER_, a.NOBS, 
         b.n as NON_MISS, round((a.NOBS-b.n)/a.NOBS, .0001)*100 as MISS_PCT 
         from tmp_meta_ms a left join 
         ( select nu.n, nu._VARS_ from miss_N as nu  
						union select ch.n, ch._VARS_  from miss_C as ch ) b
         on  a._VARS_ = b._VARS_;
    quit;

%MEND  MISS_PCT ;

libname sclib "D:\MFJK\SAS\Project\SC\SCLIB";
%MISS_PCT (DATA= sclib.and_var
  		  ,OUTDATA=sclib.and_var_miss) ;
