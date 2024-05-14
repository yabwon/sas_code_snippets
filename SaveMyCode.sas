%Macro SaveMyCode_Start(path,file);
%put NOTE:[&sysmacroname] =====================================;
%if %superq(path)= %then
  %let path=%sysfunc(pathname(work));
%if %superq(file)= %then
  %let file=dump.txt;
%if %superq(path)=ALL %then
  %do;
    %let CARDS4=;
    %put NOTE- Running all file;
  %end;
%else
  %do;
    %put NOTE- Saving code to:;
    %put NOTE- &path./&file.;
    %let CARDS4=CARDS4;
    DATA _NULL_;
      FILE "&path./&file." LRECL=2048;
      INFILE CARDS4;
      INPUT;
      PUT _INFILE_;
  %end;
%Mend SaveMyCode_Start;


%Macro SaveMyCode_End();
RUN;
%put NOTE:[&sysmacroname] =====================================;
%Mend SaveMyCode_End;

/* Example: */
/*
%SaveMyCode_Start(ALL)
&CARDS4.;

data _test_code_saver;
  set sashelp.class;
run;


;;;;
%SaveMyCode_End()
*/
