libname lab10 '/folders/myfolders/SAS_eng2020/lab10';
libname lab8 '/folders/myfolders/SAS_eng2020/lab8';

/* Exercise 10.1 */
/* 
We will solve this problem by using data set with dictionary.
This data set should have 3 columns:
fmtname - name of created format in PROC FORMAT
start - values which we want to format
label - formatted value from the column start

Then we have to create format in PROC FORMAT with CNTLIN option which uses dictionary to create format.

At the end, we convert id to character with md. format.
*/

data tmp;
set lab8.small;
fmtname='md';
start=id;
label='small';
keep fmtname start label;
run;

proc format cntlin=tmp;
run;

proc means data=lab8.large;
var sales;
where put(id, md.)='small';
run;

/* Exercise 10.2*/

/* Here we use PROC MEANS to calculate number of observations, minimum, maximum, mean and standard deviation
We use statement OUTPUT to output those statistics.
It is possible to output other statistics,
e.g. 
OUTPUT OUT=output_set q1=q1 ;
OUTPUT OUT=output_set q1= /autoname ;
Read more here about PROC MEANS:
https://documentation.sas.com/?docsetId=proc&docsetVersion=9.4&docsetTarget=n1qnc9bddfvhzqn105kqitnf29cp.htm&locale=en
Read more here about OUTPUT statement:
https://documentation.sas.com/?docsetId=proc&docsetVersion=9.4&docsetTarget=p04vbvpcjg2vrjn1v8wyf0daypfi.htm&locale=en
*/

data a;
array z(5);
do i=1 to 50;
	do j=1 to 5;
		z(j)=100+sqrt(10)*rannor(0);
	end;
	output;
end;
keep z:;
run;

proc means data=a N mean max min std noprint;
output out=c;
run;

data stat;
array z(5);
set a c;
stat=catt('W',_N_);
if _stat_^="" then stat=_stat_;
keep z: stat;
run;

/* Homework:
Exercises 10.3-10.8
Deadline: May 24th 2020 23:59
Hints:
10.3: read more about OUTPUT statement in PROC MEANS
10.4: read the documentation of PROC FORMAT: 
	https://documentation.sas.com/?docsetId=proc&docsetVersion=9.4&docsetTarget=n1c16dxnndwfzyn14o1kb8a4312m.htm&locale=en
	and this paper:
	https://support.sas.com/resources/papers/proceedings/proceedings/sugi27/p101-27.pdf
10.5: PROC MEANS + PROC TRANSPOSE can be useful
10.7: Define your own function with PROC FCMP and create new format based on it, example is here:
https://documentation.sas.com/?docsetId=proc&docsetTarget=p1gg77jyhc9s42n1f1vjyx2hsg8b.htm&docsetVersion=9.4&locale=en
*/