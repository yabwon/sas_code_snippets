

/* assumming there is a file with the following macro 

%macro getVars();
%put This is macro from SASAutos;
%put It returns 42;
42 
%mend getVars;

in the 'R:\test_sas_autos' directory

*/

/* start sasautos */
options 
MAUTOSOURCE
MRECALL 
APPEND=(sasautos='R:\test_sas_autos')
;

%put %getVars(); /*this is from SASAUTOS */


/* enable framework */
filename packages "C:\SAS_WORK\SAS_PACKAGES";
%include packages(SPFinit.sas);

/* load particular package */
%LoadPackage(BasePlus)

%put %getVars(sashelp.class); /* macro from the package */

%unLoadPackage(BasePlus)


%put %getVars(); /*this is from SASAUTOS again */
