/* From: SET statement considered harmful.sas
   Case: "IT MAKES MY BLOOD BOIL" - applying a display format.

   The lesson: a DATA step that only changes display metadata still
   reads and rewrites every row. PROC DATASETS MODIFY only updates
   the descriptor, so it is O(1) regardless of dataset size.

   The original sources HAVE from a libname-backed file. Here we ship
   a small inline HAVE so the bundle is self-contained.               */

data have;
  length id $ 1;
  input id $ number;
  datalines;
A 1
B 2
C 3
;
run;

/* "blood boiler" — a full DATA-step pass that only adds a display
   format, not a single value changes. */
data have;
  set have;
  format number ROMAN12.;
run;

/* "cooler" — PROC DATASETS MODIFY updates only the descriptor.
   No rows are read.                                                  */
proc datasets lib=work nolist;
  modify have;
    format number ROMAN12.;
  run;
quit;

proc print data=have noobs; title "same result, very different cost"; run;
