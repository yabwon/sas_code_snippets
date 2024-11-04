
/* REQUIRES: BasePlus package */
/* REQUIRES: macroArray package */


/* Enable SPF and load packages:

  filename packages "/path/for/packages";
  %inslude packages (SPFinit.sas)

  %loadPackage(basePlus)
  %loadPackage(macroArray)
*/



/*
  %helpPackage(basePlus,getVars)
  %helpPackage(macroArray,deletemacarray)
*/

/* convertn2c.sas */
/* Macro converts a variable in "Numeric <-> Character" fassion
   and keeps variable original position in the data set 
*/
%macro convertN2C(
 ds /* data sets name */
,vn /* space-separated list of variables to convert, 
       best32. is used by default, */
)/minoperator;
  %local i j tmp id rc INDEX;
  %let j=0;
  %let tmp = _N2CorC2N_%sysfunc(datetime(),B8601dt15.)_;
  %getVars(&ds.
          ,mcArray=&tmp.) /* from BasePlus */

  data &ds.( /* keep data set LABEL and COMPRESSION */
    %let id = %sysfunc(open(&ds.));
    %if (&id.) %then %do;
      label = %sysfunc(quote(%sysfunc(ATTRC(&id.,LABEL))))
      compress = %sysfunc(quote(%sysfunc(ATTRC(&id.,COMPRESS))))

      /* keep data set INDEXes, if exist */
      %let INDEX = %sysfunc(ATTRN(&id.,INDEX));
      %if (&index.) %then
        %do;
          %let rc = %sysfunc(doSubL(%str( options nonotes nomprint nosymbolgen nomlogic;
            proc contents data = &ds. noprint out2=&tmp.(keep=libname member recreate);
            run;
          ))); 
        %end;
      %let id = %sysfunc(close(&id.));
    %end;
    );
    retain 
      %do i=&&&tmp.LBOUND. %to &&&tmp.HBOUND.;
        %if %UPCASE(%&tmp.(&i.)) IN (%UPCASE(&vn.)) %then
          %do;
            %let j=&j. &i.;
            %&tmp.(&i.)  &tmp.&i.
            %local TYPE&i._1 TYPE&i._2 TYPE&i._3;
            %let rc = %sysfunc(doSubL(%str( options nonotes nomprint nosymbolgen nomlogic;
                      data _null_;
                        set &ds.(keep=%&tmp.(&i.));
                        call symputX("TYPE&i._1", ifc(upcase(VTYPE(%&tmp.(&i.)))="C","IN", " ") ,"L");
                        call symputX("TYPE&i._2", ifc(upcase(VTYPE(%&tmp.(&i.)))="C","??", " ") ,"L");
                        call symputX("TYPE&i._3", quote(VLABEL(%&tmp.(&i.)),"'") ,"L");
                        rc=sleep(0.05,1);
                        stop;
                      run; 
                      )));
          %end;
        %else %&tmp.(&i.) ;
      %end;
    ;
    set &ds.;

    %do i=&&&tmp.LBOUND. %to &&&tmp.HBOUND.;
      %if &i. IN (&j.) %then
        %do;
          &tmp.&i.=&&TYPE&i._1.put(%&tmp.(&i.), &&TYPE&i._2. best32.);
          drop %&tmp.(&i.);
          rename &tmp.&i. = %&tmp.(&i.);
          label &tmp.&i. = &&TYPE&i._3.;
        %end;
    %end;
  run;

  %if (&index.) %then
  %do;
    data _null_;
      set &tmp. END=_E_;
      if 1=_N_ then
        call execute(cat(
          'proc datasets lib=', Libname, ' noprint; modify ', member, ';'));
      call execute(recreate);      
      if 1=_E_ then
        call execute('run; quit;');
    run;
    proc delete data=&tmp.;
    run;
  %end;


  /*%put _user_;*/
  %deleteMacArray(&tmp., macarray=Y)  /* from MacroArray */
  /*%put _user_;*/
%mend convertN2C;



/* EXAMPLE 1 */
/* ============================================================================

data class(label="Test Label 1" compress=yes index=(name wh=(height weight)));
  set sashelp.class;
  label age = 'Variable with age and has %percents and &amps in it!!'
        sex = "Variable with sex";
  ;
run;

proc contents data=class;
run;

options MPRINT;
%convertN2C(class, age)

ods select variables;
proc contents data=class;
run;

options MPRINT;
%convertN2C(class, age)

ods select variables;
proc contents data=class;
run;

ods select all;


%convertN2C(NO_DATA_SET, age)

%convertN2C(class, NO_VARIABLE)

============================================================================ */


/* EXAMPLE 2 */
/* ============================================================================

data class2(label="Test Label 1" compress=yes index=(name wh=(height weight)));
  set sashelp.class;
  label age = 'Variable with age and has %percents and &amps in it!!'
        sex = "Variable with sex"
        weight = "Weight, but not in kilograms.";
  ;
run;

proc contents data=class2;
run;

options MPRINT;
%convertN2C(class2, age weight)

ods select variables;
proc contents data=class2;
run;

options MPRINT;
%convertN2C(class2, weight age XXX)

ods select variables;
proc contents data=class2;
run;

ods select all;

============================================================================ */
