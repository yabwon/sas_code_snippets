

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
,vn /* variable to convert, best32. is used, 
       currently only one variable at a time! */
);
  %local i j tmp id rc TYPE1 TYPE2 TYPE3 INDEX;
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
          %let rc = %sysfunc(doSubL(%str(
            proc contents data = &ds. noprint out2=&tmp.(keep=libname member recreate);
            run;
          ))); 
        %end;
      %let id = %sysfunc(close(&id.));
    %end;
    );
    retain 
      %do i=&&&tmp.LBOUND. %to &&&tmp.HBOUND.;
        %if %UPCASE(%&tmp.(&i.))=%UPCASE(&vn.) %then
          %do;
            %let j=&i.;
            %&tmp.(&i.)  &tmp.
            %let rc = %sysfunc(doSubL(%str(
                      data _null_;
                        set &ds.(keep=%&tmp.(&i.));
                        call symputX("TYPE1", ifc(upcase(VTYPE(%&tmp.(&i.)))="C","IN", " ") ,"L");
                        call symputX("TYPE2", ifc(upcase(VTYPE(%&tmp.(&i.)))="C","??", " ") ,"L");
                        call symputX("TYPE3", quote(VLABEL(%&tmp.(&i.)),"'") ,"L");
                        rc=sleep(0.2,1);
                        stop;
                      run; 
                      )));
          %end;
        %else %&tmp.(&i.) ;
      %end;
    ;
    set &ds.;

    %if (&j.) %then
      %do;
        &tmp.=&TYPE1.put(%&tmp.(&j.), &TYPE2. best32.);
        drop %&tmp.(&j.);
        rename &tmp. = %&tmp.(&j.);
        label &tmp. = &TYPE3.;
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

============================================================================ */
