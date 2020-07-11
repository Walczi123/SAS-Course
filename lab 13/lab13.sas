/*
SAS - dictionary tables:
Dicrionary tables are SAS views which contain information on data sets, libraries, macros and external files 
that are in use or available in the current SAS session. 
A dictionary table also contains the settings for SAS system options that are currently in effect. 

Most important dictionary tables:
dictionary.columns - contains information about columns in each dataset
dictionary.dictionaries - contains columns descriptions of dictionary tables
dictionary.members - contains information about datasets in each library
dictionary.formats - contains information about formats 
dictionary.macros - contains values of all macro variables

More information about dictionary tables can be found here:
https://support.sas.com/resources/papers/proceedings/proceedings/sugi29/237-29.pdf
*/

/* Creating macrovariables in PROC SQL 

INTO statement in SQL query allows to create macrovariables. Names of created macrovariables have to be preceded by ':'.

Basic examples 

Example 1: Creating 1 macrovariable:

proc sql noprint;
select count(*)
into :n
from sashelp.gas
;
quit;

%put &n;

Example 2: Creating multiple macrovariables (1 macrovariable per row):

proc sql noprint;
select EqRatio
into :x1-:x171
from sashelp.gas
;
quit;

%put &x1 &x2;

proc sql noprint;
select EqRatio
into :y1-:y2
from sashelp.gas
;
quit;

%put &y1;
%put &y3;

Macrovariable SYSMAXLONG can be useful (this macrovariable contains the maximum long integer value):
proc sql noprint;
select EqRatio
into :y1-:y&sysmaxlong
from sashelp.gas
;
quit;

Example 3: Creating one macro variables with concatenated rows:
proc sql noprint;
select feedcls
into :y separated by ', '
from sashelp.feeder
;
quit;

Read more here about INTO statement: 
https://documentation.sas.com/?docsetId=sqlproc&docsetTarget=n1tupenuhmu1j0n19d3curl9igt4.htm&docsetVersion=9.4&locale=en

*/

/* Exercise 13.5 */



%macro ex13_5(set,letter);
%let bib=%upcase(%scan(&set,1,'.'));
%let zb=%upcase(%scan(&set,2,'.'));
proc sql noprint;
select name
into :to_del separated by ' '
from dictionary.columns
where libname="&bib" and memname="&zb" and substr(name,length(name),1)="&letter"
;

data ex13_5;
set &set;
drop &to_del;
run;

%mend;

data a;
do x_y=1 to 10;
c_y=2*x_y;
y=5;
x=2*c_y+y;
output;
end;
run;

%ex13_5(work.a,y);

