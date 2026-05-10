/* From: SET statement considered harmful.sas
   Case: replacing PROC SQL left/right/inner JOIN with a single MERGE +
   IN= flags + SELECT/WHEN.

   The original sources ONE and TWO from a libname-backed file. Here we
   build a small synthetic ONE and TWO inline so the bundle is
   self-contained.                                                     */

data one;
  do obs = 1 to 5;
    x = obs * 10;
    output;
  end;
run;

data two;
  do obs = 3 to 7;
    y = obs * 100;
    output;
  end;
run;

/* Single pass over both datasets, IN= flags drive the routing. */
data only_in_one only_in_two one_and_two;
  merge one(in=o1) two(in=t2);
  by obs;
  select;
    when (o1 and not t2) output only_in_one;
    when (not o1 and t2) output only_in_two;
    when (o1 and t2)     output one_and_two;
    otherwise;
  end;
run;

proc print data=only_in_one noobs; title 'only in one (left anti-join)'; run;
proc print data=only_in_two noobs; title 'only in two (right anti-join)'; run;
proc print data=one_and_two noobs; title 'in both (inner join)'; run;
