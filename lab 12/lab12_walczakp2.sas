/*[ItSAS]Solution of Lab 12 by Patryk Walczak*/
/*TODO  12.2-12.8*/

libname lab12 "C:\Users\patry\OneDrive\Desktop\SAS\lab 12\set";

/*
Reminder from previous laboratories:
CALL SYMPUT allows to assign a value to the macro variable in DATA STEP
Example:*/
data a;
b=1;
run;

data _null_;
set a;
call symput('macro_var',b);
run;

/*Useful tricks:*/
/*1) It is possible to assign number of observations in the data set to macro variable:*/
data _null_;
set a nobs=n_obs;
call symput('n_obs',n_obs);
stop;
run;

/*2) Name of first argument in CALL SYMPUT can depend on another variable/macro variable:*/
data _null_;
i=1;
call symput('var'||left(i),10);
run;

/* Exercise 12.1 */
/*Write a macro that divides any given data set into sets that have at most n observations.*/
option mprint;

%macro ex12_1(set, n);
data _null_;
set &set nobs=n_obs;
call symput('n_obs',n_obs);
stop;
run;

%let u=%sysfunc(ceil(%sysevalf(&n_obs/&n)));
%let p=1;
%do i=1 %to &u;
	data &set&i;
		%do k=1 %to &n;
		%if &p<=&n_obs %then %do;
			a=&p;
			set &set point=a;
			output;
			%let p=%eval(&p+1);
		%end;
		%end;
		stop;
	run;
%end;
%mend;

data a;
do i=1 to 7;
	x=i*i;
	output;
end;
keep x;
run;

%ex12_1(a,5)

/* Exercise 12.2 */
/*Write a macro with two parameters id and sets that ?nds for a given id the most current value of the variable x in the data
  sets sets. (The parameter sets may contain any number of set names separated by spaces.) 
  If the given id does not exist in the given sets, the macro should generate an appropriate message in the Log window. 
  (For testing purposes one can use the sets a0236 � a0962.)*/

%macro ex12_2(_id, sets);
%let i=1; 
%let value=. ; 
%let cdate='01JAN1960'd;
%let set=%scan(&sets,&i);
	%do %while(&set ne );
		data tmp_12_2;
		set lab12.&set;
		if _n_=1 then cdate='01JAN1960'd;
		if id=&_id then do;
			if(intck("day",cdate,date)>0 ) then do;
				cdate = date;
				value = x;
				output;
			end;
		end;
		retain cdate;
		run;
		data _null_;
		set tmp_12_2;
		call symput("cdate",cdate);
		call symput("value",value);
		run;
		%let i=%eval(&i+1);
		%let set=%scan(&sets,&i);		
	%end; 
%if &cdate eq '01JAN1960'd %then %do;
	%put 'There was no element with that id';
%end;
%else %do;
	%put &_id &value;
%end;
%mend;

%ex12_2(0002, A0236);

/* Exercise 12.3 */
/*Write a macro that for a given data set and a given numerical variable from the set will create a new format. 
  For example, if in the set there exists the numerical variable x with the values {0.1,3,100}, 
  then the created format should display numbers from the interval (-8,0.1) as ,,I�, numbers from (0.1,3] as ,,II�, 
  numbers from (3,100] as ,,III� and numbers from (100,+8) as ,,IV�. */

data dataset3;
x=0;
output;
x=1;
output;
x=6;
output;
x=30;
output;
x=110;
output;
run;

%macro ex12_3(set);
data _null_;
set &set nobs=n_obs;
call symput('n_obs',n_obs);
stop;
run;

data _null_;
set &set;
i = _N_;
call symput('val'||left(i), x);
run;

%let i=1;
proc format;
value ex12_3_my_format
-9999 - &val1 = %sysfunc(putn(1,roman.))
%do %while (&i < &n_obs);
%let k = %eval(&i+1);
&&val&i-&&val&k = %sysfunc(putn(&k,roman.))
%let i = %eval(&i+1);
%end;
%let l = %eval(&i+1);
&&val&i - 9999 = %sysfunc(putn(&l,roman.))
;
run;
%mend;

%ex12_3(dataset3);
/* Exercise 12.4 */
/*Write a macro that removes from any given data set all the numerical variables that have at least one missing value.*/
data dataset4;
x=0;
y=77;
a=2;
output;
x=1;
a=6;
output;
x=.;
a=2;
output;
x=30;
a=3;
output;
x=110;
a=7;
output;
run;

%macro ex12_4(set);
proc transpose data=&set out=ex12_4_1;
run;
data ex12_4_2;
	set ex12_4_1;
	isnull=0;
	array arr[*] _NUMERIC_;
	do i=1 to dim(arr);
		if arr[i]=. then do;
			isnull=1; 
		end;
	end;
	if isnull=0 then do;
		output;
	end;
	drop isnull i;
run;
proc transpose data=ex12_4_2 out=ex12_4(drop=_name_);
run;
%mend;

%ex12_4(dataset4);
/* Exercise 12.5 */
/*Write a macro %division(set,var) that divides a given data set zbior into as many sets as
  there are distinct values of the variable var. 
  The ith output set should be named zi and it should contain only such observations 
  from set for which var takes the ith of its values.*/
data dataset5;
x=1;
y=1;
output;
y=2;
output;
x=15;
output;
y=1;
output;
x=3;
y=3;
output;
x=1;
y=14;
output;
run;

%macro ex12_5(set,var);
data _null_;
set &set nobs=n_obs;
call symput('n_obs',n_obs);
stop;
run;
%let k=0;
%do a=1 %to &n_obs;
	%let flag=0;
	data _null_;
	set &set(firstobs=&a obs=&a);
	call symput('v',&var);
	run;
	%do i=1 %to &k;
		%if &&val&i=&v %then %do;
			%let flag=1;
		%end;
	%end;
	%if &flag=0 %then %do;
		%let k=%eval(&k+1);
		%let val&k=&v;
	%end;
%end;
%do i=1 %to &k;
	data z&i;
	set &set;
	if &var=&&val&i then output;
	drop k;
	run;
%end;
%mend;

%ex12_5(dataset5,x);
/* Exercise 12.6 */
/*Write a macro that for given: a data set, a numerical variable and a number n, 
  counts the value of the empirical distribution of the variable at the points x1,...,xn, where x1 and xn are the smallest 
  and the largest values of the variable in the set. 
  The distances between the consecutive points xi and xi+1 should be equal for all i.*/
%macro ex12_6();
%mend;
/* Exercise 12.7 */
/*Assume that a data set z with the text variable set and the numerical variable var is given; 
  every observation from z contains the name of variable (var) that should be removed from the set set. 
  Write a macro that reads the set z and the sets listed in z, removes the relevant variables from the listed sets and puts them, 
  side by side, into a single new data set.*/
%macro ex12_7();
%mend;
/* Exercise 12.8 */
/*Write a macro that, for a given data set set and a given integer k, 
  will create the set of all k-element combinations of elements of set.*/
%macro ex12_8(set, k);
data _null_;
set &set nobs=n_obs;
call symput('n_obs',n_obs);
stop;
run;

%let count=%sysfunc(comb(&n_obs,&k));
%mend

%ex12_8(a, 2);
