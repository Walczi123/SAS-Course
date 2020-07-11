libname lab12 '/folders/myfolders/SAS_eng2020/lab12';

/*
Reminder from previous laboratories:
CALL SYMPUT allows to assign a value to the macro variable in DATA STEP
Example:
data a;
b=1;
run;

data _null_;
set a;
call symput('macro_var',b);
run;

Useful tricks:
1) It is possible to assign number of observations in the data set to macro variable:
data _null_;
set a nobs=n_obs;
call symput('n_obs',n_obs);
stop;
run;

2) Name of first argument in CALL SYMPUT can depend on another variable/macro variable:
data _null_;
i=1;
call symput('var'||left(i),10);
run;

*/

/*Exercise 12.1*/

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
do i=1 to 23;
	x=i*i;
	output;
end;
run;

%ex12_1(a,5)

/* Homework:
Exercises 12.2-12.8
*/