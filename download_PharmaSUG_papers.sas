
/* if you don't have BasePlus package enabled, run this */
/* GET FRAMEWORK and BASEPLUS:

filename packages "/path/to/my/packages";        *<====== ADJUST THIS PATH;

****** get the SAS Packages Framework(SPF) ******;
filename SPFinit url "https://bit.ly/SPFinit";
%include SPFinit; 

****** install the SPF and basePlus ******;
%installPackage(SPFinit basePlus)


****** load basePlus ******;
%loadPackage(basePlus)

****** helo info about macros used in the process ******;
%helpPackage(basePlus,downloadFilesTo) 
%helpPackage(basePlus,libPath) 
*/


/* GET PROCEEDINGS:
*/
options msglevel=N;
%let year=2024;
%let path4proceedings=/Path/Wher/You/Want/Save/Proceedngs/;     *<====== ADJUST THIS PATH;

filename links URL "https://www.pharmasug.org/&YEAR.-proceedings.html";
options dlCreateDIr;
libname _ "&path4proceedings./PharmaSUG&YEAR.papers/";

data pdf;
  infile links;
  input;
  if find(_infile_, ".pdf", "it") AND find(_infile_, "href=", "it") then 
    do; 
      length pdf $ 1024;
      pdf = catx("/", "https://www.pharmasug.org/", scan(_infile_, 2, '"'));
      output;
      keep pdf;
    end;
run;

%downloadFilesTo(%libPath(_)/, DS=work.pdf, DSvar=pdf)
