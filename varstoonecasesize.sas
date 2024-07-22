/* varstoonecasesize.sas */

/*
The %VarsToOneCaseSize() macro requires: 
  the BasePlus(at least 1.43.0) package and 
  the macroArray package.


%loadPackageS(BasePlus(1.43.0), macroArray)

%helpPackage(basePlus, '%getVars()')
%helpPackage(macroArray, '%do_over()')
%helpPackage(macroArray, '%deleteMacArray()')
*/

%macro VarsToOneCaseSize(
 lib
,ds
,case=L /* L U */
) / minoperator;
%if %sysfunc(exist(&lib..&ds.)) %then
  %do;
    %local pattern;
    %put **&case.**;
    %if %superq(case) IN (u U) %then
      %do;
        %let case=UPCASE;
        %let pattern=[a-z]+;
      %end;
    %else
      %do;
        %let case=lowcase; 
        %let pattern=[A-Z]+;
      %end;
    %put **&case.**&pattern.**;

    %getVars(&lib..&ds.,mcArray=___vars,pattern=&pattern.,ignoreCases=0)

    %if %SYMGLOBL(___varsN) %then
      %do;
        %if &___varsN. %then
          %do;
            PROC DATASETS LIB=&lib. NOLIST NOWARN;
            MODIFY &ds.;
              RENAME
                %do_over(___vars,phrase=%nrstr(
                  %___vars(&_I_.)=%&case.(%___vars(&_I_.))
                ))
              ;;;;
              RUN;
            QUIT;
          %end;
      %end;
    %deleteMacArray(___vars, macarray=Y)
  %end;
%mend VarsToOneCaseSize;


data class;
set sashelp.class;
run;
proc print data=class(obs=3);
run;

options mprint;
%VarsToOneCaseSize(work,class) /* all to lowcase */


proc print data=class(obs=3);
run;

options mprint;
%VarsToOneCaseSize(work,class) /* no update done */

proc print data=class(obs=3);
run;

options mprint;
%VarsToOneCaseSize(work,class,case=U) /* all to upcase */

proc print data=class(obs=3);
run;


/*###################################################*/

/* Macro above overcome the following issue too */
/*
options nofullstimer;
resetline;
data test;
  a=42;
run;

PROC DATASETS LIB=work NOLIST NOWARN;
MODIFY test;
  RENAME
    a=a      %* keep lower case - gives an error ;
  ;;;;
  RUN;
QUIT;

PROC DATASETS LIB=work NOLIST NOWARN;
MODIFY test;
  RENAME
    a=A     %* change to upper case - no error ;
  ;;;;
  RUN;
QUIT;

data test2;
  set test;
  rename a=a; %* no error in data step ;
run;
*/

