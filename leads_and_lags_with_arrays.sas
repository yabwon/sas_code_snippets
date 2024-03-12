
/*

How to use SAS arrays to emulate leads and lags functionality in data step?

Bartosz Jablonski (yabwon)

*/


/* data for tests */
data have;
  set sashelp.cars;
  keep make model invoice;
run;





/* preprocessing - get the number of observations in your data set */
data _null_;
  call symputX("nObs",nobs, "G");
  stop;
  set have nobs=nobs;
run;


/* 
Example 1.
find leads and lags in range from -3 to +3 from the current observation
*/
data want;

  /* array for Leads and Lags - loaded once, no sorting */
  array LL[0:&nObs.] _temporary_;
  do until (endLL);
    set have(keep=invoice) end=endLL curobs=curobsLL;
    LL[curobsLL]=invoice;
  end;

  do until (EOF);
    set have end=EOF curobs=curobs;

    /* array for "future and past" values */
    array values[-3:3];

    do i = lbound(values) to hbound(values); /* from -3 to +3 - a range of leads and lags to find */
      f=curobs+i; /* f = find */
      values[i] = LL[(0<f<=&nObs.)*f];
    end;

    /* your code goes here ... */

    output;
    call missing (of values[*]);
    drop i f;
  end;

stop;
run;



/* 
Example 2.
find a random lead or lag in range from -20 to +20 from the current observation
*/

data want2;

  /* array for Leads and Lags - loaded once, no sorting */
  array LL[0:&nObs.] _temporary_;
  do until (endLL);
    set have(keep=invoice) end=endLL curobs=curobsLL;
    LL[curobsLL]=invoice;
  end;

  do until (EOF);
    set have end=EOF curobs=curobs;

    /* random lead or lag */
    call streaminit(123);
    i = rand("integer",-20,20); /* random range of leads and lags to find */
    f=curobs+i; /* f = find */
    value = LL[(0<f<=&nObs.)*f];       

    /* your code goes here ... */

    output;
    call missing (value);
    drop f;
  end;

stop;
run;


/*
Example 3.
working with with macro wrappers
*/
%macro LLarray(LL,ds,var,nObs,type);
if _N_ = 1 then
  do;
    array &LL.[0:&nObs.] &type. _temporary_;
    do until (end&LL.);
      set &DS.(keep=&var.) end=end&LL. curobs=curobs&LL.;
      &LL.[curobs&LL.]=&var.;
    end;
  end;
%mend LLarray;

%macro LLfind(LL,f);
  &LL.[(0<(&f.)<=hbound(&LL.))*(&f.)]
%mend LLfind;

options mprint;
data want3;

  /* "declare" array for Leads and Lags */
  %LLarray(LL,have,invoice,&nObs.);

  /* read your data */
  set have curobs=curobs;

  /* find a random lead or lag */
  call streaminit(123);
  i = rand("integer",-20,20);
  value = %LLfind(LL, curobs+i);       

  /* your code goes here ... */

run;

/* works with character data too */

options mprint;
data want4;

  /* "declare" character array for Leads and Lags */
  %LLarray(LLC,have,model,&nObs.,$ 50);

  /* read your data */
  set have curobs=curobs;

  /* find a random lead or lag with character variable */
  call streaminit(123);
  i = rand("integer",-20,20);
  valueChar = %LLfind(LLC, curobs+i);       

  /* your code goes here ... */

run;

/* can be easiliy extended to multiple variables */

options mprint;
data want5;

  /* "declare" array for Leads and Lags */
  %LLarray(LLN,have,invoice,&nObs.);
  %LLarray(LLC,have,model,&nObs.,$ 50);

  /* read your data */
  set have curobs=curobs;

  /* find a random lead or lag for multiple variables */
  call streaminit(123);
  i = rand("integer",-20,20);
  valueNum = %LLfind(LLN, curobs+i);       
  valuechar = %LLfind(LLC, curobs+i);       

  /* your code goes here ... */

run;
