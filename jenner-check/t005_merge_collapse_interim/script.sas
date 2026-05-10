/* From: SET statement considered harmful.sas
   Case: "DISENCHANTING" - the wandering-vs-straight MERGE pattern.

   "Wandering" stages an intermediate MERGE dataset, then a second
   DATA step iterates the interim and computes a sum. "Straight" folds
   the work into the MERGE itself, removing one full dataset I/O.

   The original sources HAVE from a libname-backed file. Here we ship
   a small synthetic HAVE inline so the bundle is self-contained.     */

data have;
  do obs = 1 to 5;
    grp = obs;
    length id $ 1;
    if obs in (1,3,5) then id = "A";
    else id = "B";
    number = obs * 10;
    output;
  end;
run;

data data1;
  set have;
  where id ne "B";
  number2 = number * number;
run;

data data2;
  set have;
  where grp ne 17;
  number3 = number + 17;
run;

/* "wandering around" — interim MERGE dataset, then a second DATA step
   reads it back and sums. */
data interim;
  merge data1 data2;
  by obs;
run;
data _null_;
  set interim end=eof;
  sum + (number2 + number3);
  if eof then put 'wandering: sum=' sum;
run;

/* "straight to the point" — fold the work into the MERGE itself.
   Same final number, one fewer dataset materialised. */
data _null_;
  merge data1 data2 end=eof;
  by obs;
  sum + (number2 + number3);
  if eof then put 'straight: sum=' sum;
run;
