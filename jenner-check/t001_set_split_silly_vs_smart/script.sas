/* From: SET statement considered harmful.sas
   Case: "CUTTING, SLASHING, AND SHREDDING" (Part A)

   The original sources HAVE from a libname-backed file. Here we build a
   small synthetic HAVE inline so the bundle is self-contained.        */

data have;
  do grp = 1 to 3;
    do id = "A","B","C","D","E";
      do number = 1 to 2;
        obs+1;
        output;
      end;
    end;
  end;
run;

/* "silly" approach — three separate WHERE passes (three full reads) */
data work.silly_1;
  set have;
  where grp=1;
run;
data work.silly_2;
  set have;
  where grp=2;
run;
data work.silly_3;
  set have;
  where grp=3;
run;

/* "smart" approach — single pass through HAVE, three OUTPUT targets   */
data work.smart_1 work.smart_2 work.smart_3;
  set have;
  select(grp);
    when(1) output work.smart_1;
    when(2) output work.smart_2;
    when(3) output work.smart_3;
    otherwise;
  end;
run;

proc print data=work.silly_1 noobs; title "silly_1 (grp=1)"; run;
proc print data=work.smart_1 noobs; title "smart_1 (grp=1) - same content, single pass"; run;
proc print data=work.smart_2 noobs; title "smart_2 (grp=2)"; run;
proc print data=work.smart_3 noobs; title "smart_3 (grp=3)"; run;
