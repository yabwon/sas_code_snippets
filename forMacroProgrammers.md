# Bart's thoughts on macro programming

*[Draft, 2026-03-30] I drafted this in 15 minutes, if you think there are points to add - let me know.*

*[Fixes, 2026-03-31] I've fixed some spellings, bugs, and added some more examples.*

These are some of my thoughts/opinions about macro programming in SAS. 
I have some experience with the subject, so I thought I'll share.
These are just "*an*" opinions, you don't have to agree ;-)

---

### General thoughts on macro programming (not-sorted):

0) Read about macro programming (always cross-check with the documentation, even if you are experienced [especially!], there is a lot to learn!)

1) Everything is text! Everything!

2) The code (macro) and the data (text) are intertwined, so it makes it harder to separate (in contraru to DATA steps and data sets.)

3) Macro programs are **text**, not code, generators (!!!)

4) One text is replaced by another, regardles it is macro variable or macro program. Macro progrma gives you more flexibility (conditional, loops, etc.), but both can be tricky to use.

5) Macro is not always the best solution, if you can do your work with a DATA/PROC step, do it that way (DATA steps are compiled, so faster [compare DS and macro loops]).

6) No macro quoting wins macro quoting (go with K.I.S.S. principle). 

7) Macro programming has separate timing, before DATA steps compilation and execution. 

8) Steps (data and proc, queries) are boundaries and triggers of macro processing stages.

9) Pure macro code is harder to get but worth it.

10) Indirect referencing (`&&`) is easier than it looks and than people say it is. Bad news, there is no other way but learnign if you want to learn "advanced macro programming".

11) Practice - good macro code emerges from practice and experience, practice and experience comes from sh*ty macro code...

12) Always save your code before run, bugy macro can hang your SAS session.

13) If you are inexperienced SASer - start simple (first running 4GL, then macro variables, and the last go with the macro envelope). It will get easier with time and practice.

### `Do`s and `don't`s on macro programming (not-sorted):

1) Do not put definition of a macro inside definition of another macro (unless this is the purpose [rare exceptions confirm the rule])!
  ~~~sas
    /* this one sleeps in my sasautos */
    %macro myMacro();
      %put This is my little macro;
    %mend myMacro;
    
    %myMacro()
    
    /* this one I've got from someone */
    %macro someoneelseMacro();
      %macro myMacro();
        %put Hell is waiting;
      %mend myMacro;
    
      data A;
        x = 42;
      run;
    
      %myMacro()
    
      proc print data=a;
      run;
    %mend someoneelseMacro;
    
    %someoneelseMacro()
    
    %myMacro() /* !?!?! */
    
    /* there is a separate place in hell waiting for a programmer writing this way */
  ~~~

2) Do keep macro variables inside a macro local (unless global is the purpose [exception confirms the rule]). With no `%local` statement, depending on session setup, the same macro will behave differently:
    ~~~sas
    %macro A();
      %let x=42;
      %put inside: &=x.;
    %mend A;
    ~~~
    
    The following call to A creates local `x`:
    ~~~sas
    %A()
    ~~~
    (that's how macro variables creation is designed).
   
    But if there exists global `x`, its value will will be overwritten:
    ~~~sas
    %let x = I am global;
    %A()
    %put outside: &=x.;
    ~~~
    (that's also how macro variables creation is designed).

    With `%local` both above calls will be the same (local variable will be created):
    ~~~sas
      /* use local macro variables */
      %macro A();
        %local x;
        %let x=43;
        %put inside: &=x.;
      %mend A;
    ~~~
    But also, don't go to far ;-)
    ~~~sas
      /* don't go too far */
      %macro A(x=44);
        %put inside: &=x.;
      %mend A;
    ~~~
    Playing code-golf is cool, but not on production.

4) Don't use open code `%if-%then-%else`. If you really need outside-of-macro conditionals, use `%sysfunc(ifc(<condition>, text when true, text when false))`.

5) The `call symputX()` wins `call symput()`.

6) The `%include` is not a macro language; BTW. when you decide to use `%include` inside a macro, remember that if you change the file then the included content change between calls.

7) **Do read** Art Carpenter's book! Really! (Google for "Carpenter's Complete Guide to the SAS Macro Language, Third Edition")

8) I your macro changes SAS session options, then restore those changed options to their original values at the end of the macro. Leaving options unrestored is like using a toilet without flushing...

9) Always execute input checks, e.g., if a boolean indicator is really 0/1, if an input data set really exists, etc. If they are not OK, throw an error/warning message AND gracefully terminate the macro.

10) Use `symget("variable")` instead `"&variable."` to pass values to DATA steps (smaller chance than a "wrong" input will break your code). 

11) Use the dot! I.e., write `&variable.` instead `&variable`.

12) Write every input parameter in a separate line:
  ```sas
  %macro ABC(
      x
    , y
    , u=
    , v=
  );
  ```
  It's easier to read, maintain, comment, or comment out.

12) Always define macro with parenthesis:
  ```sas
  %macro ABC();
    data _null_; run;
  %mend ABC;
  ```
  even if it has no arguments, you may want to add them later and parenthesis makes it easier.

13) Reduce (or eliminate) situations where you define macro variables used inside a macro outside the macro. Use parameters and pass those values as parameters (that will enforce "locality").

14) Never(!) call a macro with a semicolon at the end! (Bad: `%ABC;`)

15) Always(!) call a macro with parenthesis at the end! (Good: `%ABC()`)

16) Write the code in readable way (make the text look nice to read, there is already a lot of `&%&%&%`-fluff there)
    
    Example of "ugly" programming:
    ~~~~sas
      %let ds = A;
      %let var = x;
    
      %macro uglyAsHell;
      %put This is my bad programming;
      data &ds;&var=42;run;
      %mend uglyAsHell;
    
      %uglyAsHell;
    ~~~~
    Better way to write it (using 12, 13, 14, 15, and 16):
    ~~~~sas
      %macro aBitBetter(ds,var);
        %put This is my better programming;
      
        data &ds;
         &var=42;
        run;
      %mend aBitBetter;
      
      %aBitBetter(A,x)
    ~~~~

17) Use short lines (max 100-120 characters).

18) Cut it to pieces, short programs maintain better, read easier, and can be reused. LEGO bricks approach.

19) Read "*IS THIS MACRO PARAMETER BLANK?*" article by Chang Y. Chung. and John King, link: https://support.sas.com/resources/papers/proceedings09/022-2009.pdf

20) The `resolve()` function can resolve a lot of problems.

21) Try to anticipate (I know it's hard job) how it can be generalized. For example instead this:
    ~~~sas
      %macro A();
        data _null_;
          x=42;
          call symputX('x',x,"L");
        run;
      
        %put ERROR: 1) &=x.;
        %put ERROR: 2) &=x.;
        %put ERROR: 3) &=x.;
      %mend A;
      
      %A()
    ~~~
    try this:
    ~~~sas
      %macro A(em=%upcase(error));
        data _null_;
          x=42;
          call symputX('x',x,"L");
        run;
      
        %put &em.: 1) &=x.;
        %put &em.: 2) &=x.;
        %put &em.: 3) &=x.;
      %mend A;
      
      %A()
      
      %A(em=NOTE)
      
      %A(em=ECHO)    
    ~~~

22) Do not afraid to write plain: `%put ERROR: ... ;` instead something like: `%put %str(E)RROR: ... ;`... If your log checker catches line of code like that as an error then the log checker wrong, not you. 

These are rules I'm trying to write with. This doesn't mean I'm "fanatic" about them. Sometimes, if need be, even me (the one who preaches here) don't comply.  

One more shameless plug: use SAS packages for sharing your code. :-)

---

### Bibliography:

Those are some of resources I've used to learn and to build my opinions on. The list is not exhaustive.

Don H and Art C. old `sascommunities.org` article:
https://web.archive.org/web/20191017191057/http://www.sascommunity.org/wiki/Macro_Programming_Best_Practices:_Styles%2C_Guidelines_and_Conventions_Including_the_Rationale_Behind_Them
pdf file with printed version of the page: https://pages.mini.pw.edu.pl/~jablonskib/SASpublic/MacroProgrammingBestPractices_from_sasCommunity.pdf

Kurt B. Maxims:
https://communities.sas.com/t5/SAS-Communities-Library/Maxims-of-Maximally-Efficient-SAS-Programmers/ta-p/352068

SAS Documentation:
https://documentation.sas.com/doc/en/pgmsascdc/v_073/mcrolref/p04s69a9d2x7cnn1iukqe9zn4bo5.htm

Frank DiIorio's NESUG paper:
https://www.lexjansen.com/nesug/nesug08/ff/ff11.pdf

Susan O-Conor's NESUG paper:
https://www.lexjansen.com/nesug/nesug99/bt/bt185.pdf

---

For sure there is more! Google it. ;-)

---
