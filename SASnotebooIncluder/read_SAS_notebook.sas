

%macro includeSASNotebook(path, print=0);

%local _tmp_ n maxLine rc;
%let _tmp_ = %sysfunc(datetime(),b8601dt.);
/*%put *&_tmp_.*;*/
%let n=32767;
%let maxLine=%sysevalf((1024**3)-1,int); /*1073741823*/
/*%put &maxLine.;*/

%let rc = %sysfunc(dosubl(%str(
options noMPRINT noSTIMER noMLOGIC noNOTES;

filename SNB_in  "%superq(path)";
filename SNB_out "%sysfunc(pathname(WORK))/&_tmp_..json.pp";

data _null_;
  rc = jsonpp('SNB_in', 'SNB_out');
run; 

filename selected "%sysfunc(pathname(WORK))/&_tmp_._1.txt";

data _null_;
infile SNB_out lrecl=&maxLine. dlm='0a0d'x TRUNCOVER;
  file selected lrecl=&maxLine.;
length x $ 64;
input x :$ @;
x_lag=lag(x);
if strip(x_lag) in (
'"language": "sas",',
'"language": "sql",',
'"language": "python",')
then do;
  i=1;
  input @i y :$char&n.. @; 
  if strip(y) ne '"value": "",' then 
    do;
      put x_lag @@;
      do while (y not = " ");
        put y $char&n.. +(-1) @@;
        i+&n.;
        input @i y :$char&n.. @;
      end;
      put;
    end;
end;
run;

filename incl "%sysfunc(pathname(WORK))/&_tmp_._2.txt";

data _null_2;
infile selected lrecl=&maxLine. dlm='0a0d'x TRUNCOVER;
  file incl lrecl=&maxLine.;

length x $ 64 lang $ 12 y y1 $ 1 y2 $ 2 y3 $ 3;
input x :$ @;
lang = strip(lowcase(scan(x,2,'" :"')));

put;
select;
  when(lang = 'python') do; i=37; put 'PROC PYTHON; /* added */' / 'SUBMIT;';         end;
  when(lang = 'sas')    do; i=34;                                                     end;
  when(lang = 'sql')    do; i=34; put 'PROC SQL; /* added */';                        end;
  otherwise             do; i=&maxLine.+1; putlog "WARNING: unknown language:" lang;  end;
end;

input @i y1 $char1. @i y2 $char2. @i y2 $char2. @(i-1) y3 $char3. @;
  do while (i<=&maxLine.);
    select; 
      when (y2='\\') do; y='\'; i+2;   end;
      when (y2='\"') do; y='"'; i+2;   end;
      when (y2='\/') do; y='/'; i+2;   end;
      when (y2='\n') do; y='0a'x; i+2; end;
      when (y2='\r') do; y='0d'x; i+2; end;
      when (y2='\b') do; y='08'x; i+2; end;
      when (y2='\f') do; y='0c'x; i+2; end;
      when (y2='\t') do; y='09'x; i+2; end;
      otherwise      do; y=y1; i+1;    end;
    end;
    put y $char1. @@;
    input @i y1 $char1. @i y2 $char2. @(i-1) y3 $char3. @;;
    if y2 = '",' and y3 NE '\",' then leave;
  end;

select;
  when(lang = 'python') do; put / 'ENDSUBMIT;' / 'QUIT;'; end;
  when(lang = 'sas')    do;                             end;
  when(lang = 'sql')    do; put / ';QUIT;';                end;
  otherwise             do; putlog "WARNING-";          end;
end;
put;
run;
)));

%if %superq(print)=1 %then
%do;
  data _null_;
    infile "%sysfunc(pathname(WORK))/&_tmp_._2.txt";
    input;
    putlog '>>' _infile_;
  run;
%end;
%else
%do;
  %include "%sysfunc(pathname(WORK))/&_tmp_._2.txt";
%end;

%mend includeSASNotebook;

options mprint ls=max ps=max;

/*
This prints out content of the file with code:

%includeSASNotebook(X:\tempStuff\SASnotebook_test1.sasnb, print=1);


This one includes the file:

%includeSASNotebook(X:\tempStuff\SASnotebook_test1.sasnb);

*/
