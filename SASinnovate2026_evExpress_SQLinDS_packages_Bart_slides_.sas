/*********************************************************************************

Code for:
          "SQLinDS and evExpress packages a tribute to my sas rock-stars!"
by
           Bartosz Jablonski, yabwon(@)gmail.com
at 
           the SAS Users Day
during
           SAS Innovate 2026

*********************************************************************************/


/* installation: ****************************************

filename packages "/path/to/my/packages";

filename SPFinit url "https://bit.ly/SPFinit";
%include SPFinit; 

%installPackage(SPFinit SQLinDS evExpress)

*[only one time]*****************************************/

/* loading: *********************************************

filename packages "/path/to/my/packages";
%include packages(SPFinit.sas);

%loadPackage(SQLinDS)
%loadPackage(evExpress)

*[at session start]**************************************/


/* help  notes: *****************************************

%helpPackage(SQLinDS,'%SQL()')

%helpPackage(evExpress,'%evExpressDS()')
%helpPackage(evExpress,'evExpress()')

*[during the session]************************************/


data LEFT;
input X $ A B;
cards;
A 1 2
A 3 4
B 5 6
B 7 8
;
run;

data RIGHT;
input X $ C D;
cards;
A 10 20
B 30 40
B 50 60
C 70 80
;
run;

data want;
  set %SQL(
   SELECT * FROM left 
   NATURAL FULL JOIN right
  );
  T=sum(of _NUMERIC_);
  keep X _NUMERIC_;
run;

proc print;
run;

/********************************************************/

data 
  t1 (keep=name height)
  t2 (keep=name weight)
  t3 (keep=name age)
;
  set sashelp.class;
  output t1;

  if mod(_N_,2)=0 then output t2;
                  else output t3;
run;

filename f "/some/path/file.txt";

data want;
  file f dsd;
  set %SQL(
   SELECT "test" as t, t1.*, t2.weight , t3.age 
    FROM t1 
    left join t2
    on t1.name=t2.name
    left join t3
    on t1.name=t3.name
   ORDER BY t1.name
  );

put (_ALL_) (+0);
run;

proc print;
run;

/********************************************************/


data have;
  infile cards4 dlm='&\';
  input code : $ 32. x y c : $ 1.;
cards4;
(x > 1) and c="A"	& 3 &	11 & A \\
x < 1 and (9 < y < 13)	& -3 &	17 & B \\
x < 1 or (81 < y*y)	& 3 &	11 & C \\
(3 - sqrt(x+y))	& 5 &	11 & D \\
12 + sum(of x--y)	& 3 &	9 & E \\
sin(x)**2 + cos(x)**2 &	-3	& 11 & F \\ 
;;;;
run;

proc print;
run;


resetline;
%evExpressDS(have,exp=code,want=work.want)

proc print;
run;


resetline;
data want;
  set have 
    curobs=curobs 
    indsname=indsname;

  value = evExpress(code, indsname, curobs);
run;

proc print;
run;


/********************************************************/


/* test on bigger data */
data have2;
  do i= 1 to 1000; drop i;
    do point = 1 to nobs;
      set have point=point nobs=nobs;
      output;
    end;
  end;
stop;
run;

resetline;
%evExpressDS(have2,exp=code,want=work.want2A)

/*
proc print;
run;
*/

resetline;
data want2;
  set have2 
    curobs=curobs 
    indsname=indsname;

  value = evExpress(code, indsname, curobs);
run;

/*
proc print;
run;
*/

/********************************************************/
