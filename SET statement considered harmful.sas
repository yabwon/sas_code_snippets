/***************************************************************************************************/
/***************************************************************************************************/
/***************************************************************************************************\

                              PharmaSUG 2025 - Paper AP-121
                             SET Statement Considered Harmful

 _______ _______ _______   _______ _______ _______ _______ _______ __   __ _______ __    _ _______   
|       |       |       | |       |       |   _   |       |       |  \_/  |       |  \  | |       |  
|  _____|    ___|_     _| |  _____|_     _|  |_|  |_     _|    ___|       |    ___|   \_| |_     _|  
| |_____|   |___  |   |   | |_____  |   | |       | |   | |   |___|       |   |___|       | |   |    
|_____  |    ___| |   |   |_____  | |   | |       | |   | |    ___|       |    ___|  _    | |   |    
 _____| |   |___  |   |    _____| | |   | |   _   | |   | |   |___| |\_/| |   |___| | \   | |   |    
|_______|_______| |___|   |_______| |___| |__| |__| |___| |_______|_|   |_|_______|_|  \__| |___|    
           _______ _______ __    _ _______ ___ ______  _______ ______   _______ ______                         
          |       |       |  \  | |       |   |      \|       |    _ | |       |      \                        
          |       |   _   |   \_| |  _____|   |  _    |    ___|   | || |    ___|  _    |                       
          |       |  | |  |       | |_____|   | | |   |   |___|   |_||_|   |___| | |   |                       
          |      _|  |_|  |  _    |_____  |   | |_|   |    ___|    __  |    ___| |_|   |                       
          |     |_|       | | \   |_____| |   |       |   |___|   |  | |   |___|       |                       
          |_______|_______|_|  \__|_______|___|______/|_______|___|  |_|_______|______/                        
                     __   __ _______ ______   __   __ _______ __   __ ___                                                
                    |  | |  |   _   |    _ | |  \_/  |       |  | |  |   |                                               
                    |  |_|  |  |_|  |   | || |       |    ___|  | |  |   |                                               
                    |       |       |   |_||_|       |   |___|  \_/  |   |                                               
                    |       |       |    __  |       |    ___|       |   |___                                            
                    |   _   |   _   |   |  | | |\_/| |   |   |       |       |                                           
                    |__| |__|__| |__|___|  |_|_|   |_|___|   |_______|_______|                                           

                                    by Bartosz Jabłoński

\***************************************************************************************************/
/***************************************************************************************************\

 "Toutes choses sont dites déjà; mais comme personne n’écoute, il faut toujours recommencer."
("Everything has been said before, but since nobody listens we have to keep going back and beginning 
  all over again.")

                                                                               André Gide

\***************************************************************************************************/


/* THE DATA */
options DLcreateDIR;
libname source "%sysfunc(pathname(work))/have";
filename source "%sysfunc(pathname(work))/have/have.txt";


data source.have;
  call streaminit(42);
  file source;
  do grp = 1 to 3333 by 2, 2 to 3333 by 2;
    length id $ 8;
    do id = "A","B","C","D","E","F","G","H","I","J","K","L","M",
            "N","O","P","Q","R","S","T","U","V","W","X","Y","Z";
      do number = 1 to rand("integer",17,42);
        obs+1;
        output;
        put grp id number obs;
      end;
    end;
  end;
run;



/* Case *************************************************/
/* "TROLLING IS A ART"                                  */

/* a troll */
data source.have;
  set source.have;
run;

/* solution */

/* NO CODE */

/* a rare case of no-code/low-code */
/* beating programming */



/* Case *************************************************/
/* "TWO BIRDS WITH ONE STONE"                           */

/* two birds... */
data work.have;
  SET source.have;
  drop obs;
run;

proc sort data=work.have;
  by id grp;
run;

/* ...one stone */
proc sort data=source.have(drop=obs) out=work.have;
  by id grp;
run;



/* Case *************************************************/
/* "IT MAKES MY BLOOD BOIL"                             */

/* "blood boiler" */
data work.have;
  SET work.have;
  format number ROMAN12.;
run;

/* "cooler" */
proc datasets lib=work noprint;
  modify have;
    format number ROMAN12.;  
  run;
quit;



/* Case *************************************************/
/* "CUTTING, SLASHING, AND SHREDDING"                   */

/* A */
/* silly */
data work.group_1;
  SET source.have;
  where grp=1;
run;
data work.group_2;
  SET source.have;
  where grp=2;
run;
data work.group_3;
  SET source.have;
  where grp=3;
run;

/* smarter */
data work.group_1 work.group_2 work.group_3;
  SET source.have;
  select(grp);
    when(1) output work.group_1;
    when(2) output work.group_2;
    when(3) output work.group_3;
    otherwise;
  end;
run;


/* B - bigger */
/* silly */
%macro test1();
  %local t1 t2;
  %let t1 = %sysfunc(datetime());
  %do i = 100 %to 300;
    data work.group1_&i.;
      SET source.have;
      where grp=&i.;
    run;
  %end;
  %let t2 = %sysfunc(datetime());
%put ######## %sysevalf(&t2. - &t1.) ##########;
%mend test1;
%test1()

/* smarter */
%macro test2();
  %local t1 t2;
  %let t1 = %sysfunc(datetime());
  data 
    %do i = 100 %to 300;
      work.group2_&i.
    %end;
    ;
    SET source.have;
    where grp in (%do i = 100 %to 300; &i. %end;);
    select(grp);
    %do i = 100 %to 300;
      when(&i.) output work.group2_&i. ;
    %end;
    otherwise;
    end;
  run;
  %let t2 = %sysfunc(datetime());
%put ######## %sysevalf(&t2. - &t1.) ##########;
%mend test2;
%test2()

/* C - another option */
/* silly */
data work.group_1;
  SET source.have;
  where grp in (1 2 3331 3332);
run;

data work.group_2;
  SET source.have;
  where "A"<id<"C" or "X"<id<"Z";
run;

/* smarter */
data work.group_1 work.group_2;
  SET source.have;

  if grp in (1 2 3331 3332) then
    output work.group_1;
  if "A"<id<"C" or "X"<id<"Z" then
    output work.group_2;
run;



/* Case *************************************************/
/* "THE FINAL (BACKWARD) COUNTDOWN"                     */

/* sloppy */
data work.have;
  SET source.have;
  n + 1;
run;
proc sort data=work.have out=work.have(drop=n);
  by descending n;
run;

/* smarter */
data work.have;
  do point = nobs to 1 by -1;
    SET source.have point=point nobs=nobs;
    output;
  end;
stop;
run;



/* Case *************************************************/
/* "DISENCHANTING"                                      */


/* sloppy */
proc import out=work.have(rename=(var1=grp var2=id var3=number var4=obs))
            datafile=source 
            dbms=dlm replace;
     delimiter='20'x; 
     getnames=no;
     datarow=1; 
run;

data work.have;
  SET work.have;
  number2 = number + 1000;
run;


/* sloppy - equivalent */
data work.have;
  infile source;
  INPUT grp id $ number obs;
run;

data work.have;
  SET work.have;
  number2 = number + 1000;
run;

/* smarter */
data work.have;
  infile source;
  INPUT grp id $ number obs;
  number2 = number + 1000;
run;



/* Case *************************************************/
/* "DISENCHANTING" AGAIN                                */

/* data */
data work.data1;
  SET source.have;
  where id ne "B";
  number2=number*number;
run;

data work.data2;
  SET source.have;
  where grp ne 17;
  number3=number + 17;
run;


/* wandering around */
data work.interimStep;
  MERGE work.data1 work.data2;
  by obs;
run;
data _null_;
  set work.interimStep END=_E_;
  sum + (number2 + number3);
  if _E_ then put sum;
run;

/* straight to the point */
data _null_;
  MERGE work.data1 work.data2 END=_E_;
  by obs;
  sum + (number2 + number3);
  if _E_ then put sum;
run;



/* Case *************************************************/
/* "DISENCHANTING" A BIT MORE                           */

/* data */
data work.data1;
  SET source.have;
  where id ne "B";
  number2=number*number;
run;

data work.data2;
  SET source.have;
  where grp ne 17;
  number3=number + 17;
run;

/* I/O waste */
data work.step1;
  MERGE source.have work.data1;
  by obs;
run;

data work.final;
  MERGE work.step1 work.data2;
  by obs;
run;

/* smarter */
data work.final;
  MERGE source.have work.data1 work.data2;
  by obs;
run;


/* Case *************************************************/
/* "NICE PIECE OF ABSOLUTELY USELESS STEP"              */

/* stream of consciousness */
data work.step1;
  SET source.have;
  where number > 20;
  number2=number*number;
  keep obs number2;
run;
data work.step2;
  SET source.have;
  where id NE "B";
  number3=number+17;
  keep obs number3;
run;
/*data work.step3;
    SET source.have;
    where id > "X";
    number4=number**42;
    keep obs number4;
  run;*/
data work.final;
  MERGE source.have
        work.step1
        work.step2
      /*work.step3*/
  ;
  by obs;
run;

/* smart */
data work.final;
  SET source.have;

  if number > 20 then
    number2=number*number;

  if id NE "B" then
    number3=number+17;
  /*
  if id > "X" then
    number4=number**42;
  */
run;


/* Case *************************************************/
/* "DOING MORE BY DOING LESS"                           */

/* data */
data work.one;
  set source.have;
  where number > 20;
run;

data work.two;
  infile source;
  INPUT grp id $ number obs;
  if id ne "B";
run;

/* "classic" */
proc sql;
  create table only_in_one as
  select one.*
  FROM work.one
  left join
       work.two
  on one.obs = two.obs
  where two.obs is missing
  ;

  create table only_in_two as
  select two.*
  FROM work.one
  right join
       work.two
  on one.obs = two.obs
  where one.obs is missing
  ;

  create table one_and_two as
  select one.*
  FROM work.one
  inner join
       work.two
  on one.obs = two.obs
  ;
quit;

/* smarter */
data only_in_one only_in_two one_and_two;
  MERGE work.one(in=o1) work.two(in=t2);
  by obs;
  select;
    when(    o1 and not t2) output only_in_one;
    when(not o1 and     t2) output only_in_two;
    when(    o1 and     t2) output one_and_two;
    otherwise;
  end;
run;



/* Case *************************************************/
/* "DOING BY NOT DOING"                                 */

data work.one work.two;
  set source.have;
  if id NE "C" then output work.one;
               else output work.two;
run;

/* silly */
data work.one;
  set work.one work.two;
run;

/* smarter */
proc append base=work.one data=work.two;
run;

/* possibly even smarter */
data work.onetwo / view=work.onetwo;
  set work.one work.two;
run;



/* Case *************************************************/
/* "NO RAW MACRO LOOPS", PART 1.                        */

/* slow(); */
%macro slow();
  proc sql;
    select distinct id
    into :id_list separated by " "
    FROM source.have
    ;
    %let n = &SQLobs.;
  quit;

  %do i = 1 %to &n.;
    %let id = %scan(&id_list.,&i.);
    data subset;
      SET source.have;
      where id = "&id.";
    run;

    proc univariate data=subset;
      var number;
      output out=p pctlpre=P pctlpts=0 to 100;
    run;

    proc append base=pctl1 data=p;
    run;
  %end;
%mend slow;
%slow()

/* smarter */
proc univariate data=source.have;
  class id;
  var number;
  output out=pctl2 pctlpre=p pctlpts=0 to 100;
run;



/* Case *************************************************/
/* "NO RAW MACRO LOOPS", PART 2.                        */

/* data - dictionary */
data source.dict;
  array distr[9] $ 4 ("BERN" "CAUC" "EXPO" "F" "GAMM" "INTE" "LOGI" "T" "UNIF");
  array Npar[9]  $ 4 ("1"    "0"    "1"    "2" "1"    "2"    "2"    "1" "2"   );
  array ParA[9]  $ 4 ("0.5"  " "    "1"    "3" "42"   "0"    "0"    "1" "0"   );
  array ParB[9]  $ 4 (" "    " "    " "    "4" " "    "10"   "1"    " " "1"   );

  do i = 1 to 9;
    length id $ 8;
    id = char(distr[i],1);

    par="Distribution";
    val=distr[i]; output;
    par="Npar";
    val=Npar[i]; output;
    par="ParA";
    val=ParA[i];
    if val NE "" then output;
    par="ParB";
    val=ParB[i];
    if val NE "" then output;
    par="Threshold";
    val = put(i/10,3.1); output;
  end;
  keep id par val;
run;
proc print;
  by ID;
run;

/*
x = rand("Distribution", ParA, ParB) + Treshold;
*/

options fullstimer msglevel=I;
/* slow2 */
%let time=%sysfunc(datetime());
%macro slow2();
  proc sql;
    select distinct id
    into :id_list separated by " "
    FROM source.dict
    ;
    %let n = &SQLobs.;
  quit;

  %do i = 1 %to &n.;
    %let id = %scan(&id_list.,&i.);
    data dict;
      SET source.dict;
      where id = "&id.";
      call symputX(par,val);
    run;

    data tmp;
      SET source.have;
      where id = "&id.";
      x = rand("&Distribution."
              %if &Npar.>0 %then %do; ,&ParA. %end; 
              %if &Npar.>1 %then %do; ,&ParB. %end; 
              ) + &Threshold.;
    run;


    proc append base=work.result1 data=tmp;
    run;
  %end;
%mend slow2;
options noMprint;
%slow2()
%put >>> 1) %sysevalf(%sysfunc(datetime()) - &time.);

%let time=%sysfunc(datetime());
/* smarter */
proc transpose data=source.dict out=dict(drop=_:);
  by id;
  id par;
  var val;
run;

PROC SQL _method;
  create table work.result2 as
  select h.*
    , case when d.Npar="2" then rand(Distribution,input(ParA, best.),input(ParB, best.))
           when d.Npar="1" then rand(Distribution,input(ParA, best.))
           else                 rand(Distribution)
    end + input(Threshold, best.) as x
  from
    source.have as h
    join
    dict as d
  on h.id = d.id
  ;
QUIT;
%put >>> 2) %sysevalf(%sysfunc(datetime()) - &time.);

proc print data=dict;
run;



/* Case *************************************************/
/* "#HASH TABLE FOR HELP"                               */

/* standard */
proc sort data=source.have out=work.have;
  by id;
run;
data work.aggr;
  SET work.have;
  by id;
  if first.id then 
    do;
      maxN=number;
      minN=number;
    end;
  maxN = maxN max number;
  minN = minN min number;
  if last.id then 
    do; 
      range = maxN-minN;
      output;
    end;
  keep id range;
  retain maxN minN;
run;
data work.want;
  merge work.have work.aggr;
  by id;
  shift = number/range;
  drop range;
run;

/* with hash tables */
data work.want;
  declare hash H(ordered:"A");
  H.defineKey("id");
  H.defineData("id","maxN", "minN");
  H.defineDone();
  declare hiter I("H");

  declare hash D(multidata:"Y", ordered:"A");
  D.defineKey("id");
  D.defineData("grp","id","number","obs");
  D.defineDone();

  do until(_E_);
    SET source.have END=_E_; 
    
    D.add();

    shift = H.find();
    maxN = max(maxN,number);
    minN = min(minN,number);
    H.replace();
  end;

  do while(0=I.next());
    do while(D.do_over()=0);
      shift = number/(maxN-minN);
      output;
    end; 
  end;

stop;
drop maxN minN;
run;



/* Case *************************************************/
/* "NO RAW MACRO LOOPS", PART 2. - REVISITED            */
%let time=%sysfunc(datetime());
data work.result3;
if 1=_N_ then
  do;
    declare hash D();           declare hash I();
    D.defineKey("id", "par");   I.defineKey("id");
    D.defineData("val");
    D.defineDone();             I.defineDone();
    do until(_E_);
      SET source.dict end=_E_; /* one data read for 2 hash tables */
      if D.add() then stop; /* stop when dict has doubles */
      I.replace();
    end;
  end;

  SET source.have;
  by ID notsorted;

  if 0=I.check();

  if first.ID then
    do;
      array Dict[*] $ Distribution Npar ParA ParB Threshold; retain;
      call missing(of Dict[*]);
      do j=1 to Dim(Dict);
        if 0=D.find(key:id,key:vname(Dict[j])) then Dict[j] = val;
      end;
    end;

  select(Npar);
    when("2") x = rand(Distribution,input(ParA, best.),input(ParB, best.));
    when("1") x = rand(Distribution,input(ParA, best.));
    otherwise x = rand(Distribution);
  end; 
  x = x + input(Threshold, best.);

  drop par val j Distribution Npar ParA ParB Threshold;
run;
%put >>> 3) %sysevalf(%sysfunc(datetime()) - &time.);

/* one more check (not printed in the article) */
%let time=%sysfunc(datetime());
proc transpose data=source.dict out=dict2(drop=_:);
  by id;
  id par;
  var val;
run;

data work.result4;
if 1=_N_ then
  do;
    if 0 then set dict2;
    declare hash H(dataset:"dict2"); 
    H.defineKey("id");
    H.defineData(ALL:"Y");
    H.defineDone();
  end;

  set source.have;
  by ID notsorted;

  if 0=H.find();

  select(Npar);
    when("2") x = rand(Distribution,input(ParA, best.),input(ParB, best.));
    when("1") x = rand(Distribution,input(ParA, best.));
    otherwise x = rand(Distribution);
  end; 
  x = x + input(Threshold, best.);

  drop Distribution Npar ParA ParB Threshold;
run;
%put >>> 4) %sysevalf(%sysfunc(datetime()) - &time.);







/* Case *************************************************/
/* "ONE STEP TO RULE THEM ALL"                          */

/* multiple steps in SQL */
proc sql _method;
create table work.sql_dist_number as
select distinct number
from source.have 
;
create table work.sql_dist_id as
select distinct id
from source.have 
;
create table work.sql_dist_grp as
select distinct grp
from source.have 
;

create table all_possible_cross_S as
select * 
from work.sql_dist_number
   , work.sql_dist_id 
   , work.sql_dist_grp
;
quit;

/* one step (silly - not in the paricle) */
data all_possible_cross_H;
  declare hash H1(dataset:"source.have(keep=number)", ordered:"A");
  H1.defineKey("number");
  H1.defineDone();
  declare hiter i1("H1");

  declare hash H2(dataset:"source.have(keep=id)", ordered:"A");
  H2.defineKey("id");
  H2.defineDone();
  declare hiter i2("H2");

  declare hash H3(dataset:"source.have(keep=grp)", ordered:"A");
  H3.defineKey("grp");
  H3.defineDone();
  declare hiter i3("H3");

  if 0 then
    set source.have(keep=number id grp);

  do while(0=i1.next());
    do while(0=i2.next());
      do while(0=i3.next());
        output;
      end; 
    end;
  end;

  /*
  H1.output(dataset:"hash_dist_number");
  H2.output(dataset:"hash_dist_id");
  H3.output(dataset:"hash_dist_grp");
  */
stop;
run;

/* one step (smart) */
data all_possible_cross_H;
  declare hash H1(ordered:"A");
  H1.defineKey("number");
  H1.defineDone();
  declare hiter i1("H1");

  declare hash H2(ordered:"A");
  H2.defineKey("id");
  H2.defineDone();
  declare hiter i2("H2");

  declare hash H3(ordered:"A");
  H3.defineKey("grp");
  H3.defineDone();
  declare hiter i3("H3");

  do until(_E_);
    set source.have(keep=number id grp) end=_E_;
    H1.ref();
    H2.ref();
    H3.ref();
  end;

  do while(0=i1.next());
    do while(0=i2.next());
      do while(0=i3.next());
        output;
      end; 
    end;
  end;

  /*
  H1.output(dataset:"hash_dist_number");
  H2.output(dataset:"hash_dist_id");
  H3.output(dataset:"hash_dist_grp");
  */
stop;
run;

/* challenger in SQL */
proc sql _method;
create table all_possible_cross_S2 as
select * 
from (select distinct number from source.have)
   , (select distinct id from source.have)
   , (select distinct grp from source.have)
;
quit;



/* Case *************************************************/
/* "I HAVE SEEN THIS BEFORE"                            */

/* fires, let's prepare data for this example */
data _null_;
  declare hash H1();
  H1.defineKey("number");
  H1.defineData("number", "number_text");
  H1.defineDone();

  declare hash H2();
  H2.defineKey("id");
  H2.defineData("id", "id_text");
  H2.defineDone();

  declare hash H3();
  H3.defineKey("grp");
  H3.defineData("grp", "grp_text");
  H3.defineDone();

  do until(_E_);
    set source.have(keep=number id grp) 
        end=_E_;

    length number_text $ 64 id_text $ 32 grp_text $ 16;
    number_text = put(number, words64.);
    id_text = repeat(strip(id),31);
    grp_text = put(grp, roman16.);

    H1.ref();
    H2.ref();
    H3.ref();
  end;

  H1.output(dataset:"work.number_data");
  H2.output(dataset:"work.id_data");
  H3.output(dataset:"work.grp_data");
stop;
run;
proc contents data=work.number_data;
run;
proc contents data=work.id_data;
run;
proc contents data=work.grp_data;
run;



/* 1 - Merge and sort */
proc sort data = number_data
          out = number_data_sort;
  by number;
run;
proc sort data = id_data
          out = id_data_sort;
  by id;
run;
proc sort data = grp_data
          out = grp_data_sort;
  by grp;
run;
proc sort data = source.have
          out = have_by_grp;
  by grp;
run;
data have_1;
  merge have_by_grp grp_data_sort;
  by grp;
run;
proc sort data = have_1
          out = have_by_id;
  by id;
run;
data have_2;
  merge have_by_id id_data_sort;
  by id;
run;
proc sort data = have_2
          out = have_by_number;
  by number;
run;
data have_3;
  merge have_by_number number_data_sort;
  by number;
run;
proc sort data = have_3
          out = combined_DS;
  by obs;
run;



/* 2 - SQL */
proc sql _method;
  create table combined_SQL as
  select 
    h.*,
    n.number_text, 
    i.id_text, 
    g.grp_text
  from 
    source.have as h
  left join
    number_data as n
    on h.number=n.number

  left join
    id_data as i
    on h.id=i.id

  left join
    grp_data as g
    on h.grp=g.grp

  order by obs;
quit;

/* 3 - hash tables */
data combined_hash;
  if 0 then set work.number_data work.id_data work.grp_data; 

  declare hash H1(dataset:"work.number_data");
  H1.defineKey("number");
  H1.defineData("number_text");
  H1.defineDone();

  declare hash H2(dataset:"work.id_data");
  H2.defineKey("id");
  H2.defineData("id_text");
  H2.defineDone();

  declare hash H3(dataset:"work.grp_data");
  H3.defineKey("grp");
  H3.defineData("grp_text");
  H3.defineDone();

  do until(_E_);
    set source.have
        end=_E_;

    if H1.find() then number_text="";
    if H2.find() then id_text="";
    if H3.find() then grp_text="";
    output;
  end;
stop;
run;





/* Case XXX ****************************************************/
/* not published in the article, some experiments on indexing  */

/* BASE engine */
/* order and index HAVE data set */
proc sort data=source.have 
          out=work.have(index=(id grp));
  by id grp;
run;

/* SPDE engine */
options DLcreateDIR;
libname s BASE "%sysfunc(pathname(work))/spde";
libname s SPDE "%sysfunc(pathname(work))/spde";
proc sort data=source.have 
          out=s.have(index=(id grp));
  by id grp;
run;

options msglevel=i fullstimer;

/* subsetting */
data _null_A;
  set work.have;
  where grp = 42;
run;

data _null_B;
  set s.have;
  where grp = 42;
run;


/* subsetting with OR condition */
data _null_1;
  set work.have;
  where id = "Y" OR grp = 42;
run;

data _null_2;
  set s.have;
  where id = "Y" OR grp = 42;
run;


/* experiment form the SGF 2019 article: 
   "Use advantage of INDEXes even if WHERE clause contains OR condition"
    by Bartosz Jablonski    
    https://support.sas.com/resources/papers/proceedings19/3722-2019.pdf
*/
/*
data _null_;
  do until(_E1_);
    set work.have end=_E1_;
    where id = "Y";
  end;

  do until(_E2_);
    set work.have end=_E2_;
    where grp = 42;
  end;
run; 

data _null_3;
  declare hash C();
  C.defineKey('curobs');
  C.defineDone();

  do until(_E1_);
    set work.have end=_E1_ curobs=curobs;
    where id = "Y";
    C.add();
    output;
  end;

  do until(_E2_);
    set work.have end=_E2_ curobs=curobs;
    where grp = 42;
    if C.check() then output;
  end;
stop;
run; 

data _null_4;
  declare hash C();
  C.defineKey('curobs');
  C.defineDone();

  do until(_E1_);
    set work.have end=_E1_ curobs=curobs;
    where grp = 42;
    C.add();
    output;
  end;

  do until(_E2_);
    set work.have end=_E2_ curobs=curobs;
    where id = "Y";
    if C.check() then output;
  end;
stop;
run; 


data _null_5;
  array C[2555488] _temporary_;

  do until(_E1_);
    set work.have end=_E1_ curobs=curobs;
    where grp = 42;
    C[curobs]=1;
    output;
  end;

  do until(_E2_);
    set work.have end=_E2_ curobs=curobs;
    where id = "Y";
    if not C[curobs]=1 then output;
  end;
stop;
run; 



*/



/**************************** THE END ****************************/

/*
%put %sysevalf(428297.68/2193.15);
%put %sysevalf(455876.00/29696.00);
*/


/* why even quick/merge sorting is expensive? */
data _null_;
  do e = 1 to 10;
    n=10**e;
    logn=log2(n);
    nlogn=n*logn;
    put @1 e= @6 n=20. @22 nlogn= 20.2 @46 "times slower: " logn 7.1;
  end;
run;
