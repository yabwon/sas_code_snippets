/* From: SET statement considered harmful.sas
   Case: "#HASH TABLE FOR HELP" - the standard (non-hash) approach.

   Two-pass aggregation: first compute per-id range using BY-group
   FIRST./LAST. + RETAIN, then MERGE the per-row data with the
   per-group aggregate to derive a normalised shift = number/range.

   The original sources HAVE from a libname-backed file. Here we ship
   a small inline HAVE with three IDs so the bundle is self-contained. */

data have;
  length id $ 1;
  input id $ number;
  datalines;
A 12
A 5
A 18
A 9
A 14
B 30
B 22
B 35
B 28
B 33
C 50
C 45
C 60
C 48
C 55
;
run;

proc sort data=have; by id; run;

/* Pass 1 — per-id min/max/range, one output per BY-group */
data aggr;
  set have;
  by id;
  retain maxN minN;
  if first.id then do;
    maxN = number;
    minN = number;
  end;
  maxN = max(maxN, number);
  minN = min(minN, number);
  if last.id then do;
    range = maxN - minN;
    output;
  end;
  keep id range;
run;

/* Pass 2 — merge per-row data with per-group aggregate */
data want;
  merge have aggr;
  by id;
  if range > 0 then shift = number / range;
  drop range;
run;

proc print data=aggr noobs; title 'per-id range (aggregate)'; run;
proc print data=want(obs=10) noobs; title 'merged back: shift = number / range'; run;
