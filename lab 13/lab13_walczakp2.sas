/*[ItSAS]Solution of Lab 13 by Patryk Walczak*/
/*TODO  13.1-13.9 (except 13.5)*/

libname lab13 "C:\Users\patry\OneDrive\Desktop\SAS\lab 13\set";

/* Exercise 13.1 */
/*Write a macro that will replace (in a given data set having only numerical variables ) n randomly picked elements 
  with the missing values.*/
%macro ex13_1(set, n_);
proc sql noprint;
select count(*)
into :i
from sashelp.gas
;
quit;

%put &i;
%put "lalala";
%mend;

data b;
x=1;
y=2;
output;
x=.;
y=4;
output;
y=.;
output;
x=7;
y=2;
output;
x=10;
y=.;
output;
run;

%ex13_1(b, 3);
/* Exercise 13.2 */
/*Write a macro with the two parameters numofvars and numofgrps that will create a random data set 
with the variables v 1–v numofvars with the values in the set A={A1,A2,...,Anumofgrps}. 
The set A should be a subset to the set of value for every variable. Furthermore, 
the values of every variable should be ordered in the invcreasing order, like in the set Gen 3 6 which can serve as an example .*/
%macro ex13_2(numofvars, numofgrps);
%do i=1 %to &numofvars;
/*	%let v&i.a1 = (1 + floor((&numofgrps)*rand("uniform")));*/
	%let v&i.a1 = %sysfunc(ceil(%sysfunc(ranuni(0))*&numofgrps));
	%do j=2 %to &numofgrps;
/*		%let v&i.a&j = (1 + floor((&numofgrps)*rand("uniform")));*/
		%let v&i.a&j = %sysfunc(ceil(%sysfunc(ranuni(0))*&numofgrps));
	%end;
%end;
data ex13_2;
/*array diff[&numofvars] diff1-diff&numofvars;*/
/*array res[&numofvars] res1-res&numofvars;*/
retain diff1-diff&numofvars res1-res&numofvars;
%do i=1 %to &numofvars;
/*	format var&i 8.;*/
	var&i = "A_1";
%end;
%do i=1 %to &numofvars;
	%let diff&i = &&v&i.a1 - 1;
%end;
%do i=1 %to &numofvars;
	%let res&i = 1;
%end;
output;
%let end = 0 ;
%do %while(&end eq 0);
	%do i=1 %to &numofvars;		
		%if &&diff&i eq 0 and &&res&i ne &numofgrps %then %do;
			%let res&i = %eval(&&res&i + 1);
			%let l = &&res&i;
			%let diff&i = %eval(&&v&i.a&l - 1);
		%end;
		%else %do;
			%let diff&i = %eval(&&diff&i - 1);
		%end;
	%end;
	%do i=1 %to &numofvars;
		%let t = 0;
		%do %while(&t < &&res&i);
			%let t = %eval(&t + 1);
		%end;
		var&i = "A_&t";
	%end;
	output;
	%let a = 0;
	%do i=1 %to &numofvars;
		%put &&res&i &i &a;
		%if &&res&i eq &numofgrps %then %do;
			%let a = %eval(&a + 1);
		%end;
	%end;
	%if &a eq &numofvars %then %let end = %eval(&end + 1);
%end;
run;
%mend;

%ex13_2(3, 6);
/* Exercise 13.3 */
/*How to check whether there exists a global macrovariable with a given name?*/
%macro create_global();
%global my;
%mend;
%create_global();

%macro ex13_3(var);
%let i = %symexist(&var);
%if &i eq 0 %then %put 'NO';
%else %put 'YES';
%mend;

%ex13_3(my);
/* Exercise 13.4 */
/*Write a macro that will ﬁnd the maximum of all numerical variables from all data sets from a given library.*/
%macro ex13_4(sets);
%mend;

%ex13_4(Work);
/* Exercise 13.5 */
/*Write a macro that will remove from a given data set all variables with the names ending with a given letter.*/
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
/* Exercise 13.6 */
/*Write a macro with the two parameters lib and dir that will export (as text ﬁles) 
all SAS data sets from the library lib into the directory dir. 
The names of the text ﬁles (with the extension txt) should be identical with the names of the relevant data sets. 
(Hint: one might to use PROC EXPORT.)*/
%macro ex13_6();
%mend;
/* Exercise 13.7 */
/*Write a macro %howmany(lib,group,val) that will ﬁnd all data sets from the library lib 
that contain the pair of numerical variables group and val, 
and will write to the Log window the value (or values) of the variable group 
that is associated with the largest number of distinct values of the variable val in the found sets. 
(We assume that in there can exist some data sets in the library lib without the given pair of variables group and val.)*/
%macro ex13_7();
%mend;
/* Exercise 13.8 */
/*Assume that some library has only the sets that contain at least one common variable 
(they can also have some non-common variables). Write a macro (with the name of the library being the only parameter of the macro) 
that sorts all the sets from the library with respect to the key consisting of all the common variables 
(i.e. variables that occur in all sets). The variables in the key should appear in the alphabetical order.*/
%macro ex13_8();
%mend;
/* Exercise 13.9 */
/*Write a macro with the parameter lib that creates a data set in which the names of variables are the names of all the variables
that occur in data sets from the library lib. The values of the variables should be the names of the data sets in
which the variables occur.*/
%macro ex13_9();
%mend;
