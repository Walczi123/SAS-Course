/*[ItSAS]Solution of Lab 10 by Patryk Walczak*/
/*TODO  10.3-10.8*/

libname lab10 "C:\Users\patry\OneDrive\Desktop\SAS\lab 10\set";
libname lab8 "C:\Users\patry\OneDrive\Desktop\SAS\lab 8\set";

/* Exercise 10.1 */
/* (Table look-up III) Solve the problem 2 from Lab 8 using PROC FORMAT
 What is the average of sales from large computed only for the values of id that occur in the set small?*/
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
/* Exercise 10.2 */
/*Create a data set a with ?ve numerical variables z1,...,z5 and 50 observations. 
Make every element of a a random number from the normal distribution with the mean 100 and the variance 10. 
Next, basing on a, create a data set stat, with the variable stat and the variables z1,...,z5 
and with 55 observations. For the observations numbered n = 1,...,50, 
the variable stat should have (text) values Wn, and the variables z1,...,z5 should have exactly 
the same values as in the set a. For the observations numbered 51,...,55 
the variable stat should take the (text) values N,MIN,MAX,MEAN,STD, 
and the variables z1,...,z5 should take the values of those statistics for the variables z1,...,z5*/
data lab10.a;
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
output out=lab10.c;
run;

data lab10.stat;
array z(5);
set a c;
stat=catt('W',_N_);
if _stat_^="" then stat=_stat_;
keep z: stat;
run;
/* Exercise 10.3 */
/* Modify the data set stat from the previous problem to contain the values of quartiles, 
median and interquartile range for the variables z1,...,z5.*/
data lab10.a;
array z(5);
do i=1 to 50;
	do j=1 to 5;
		z(j)=100+sqrt(10)*rannor(0);
	end;
	output;
end;
keep z:;
run;

proc means data=lab10.a STACKODSOUTPUT N median q1 q3 qrange;
var z1 z2 z3 z4 z5;
ods output summary=lab10.ex3_1;
run;

proc transpose data=lab10.ex3_1
out=lab10.ex3_2(rename=(_NAME_= _stat_ COL1=z1 COL2=z2 COL3=z3 COL4=z4 COL5=z5));
run;


data lab10.ex3;
array z(5);
set lab10.a lab10.ex3_2;
stat=catt('W',_N_);
if _stat_^="" then stat=_stat_;
keep z: stat;
run;
/* Exercise 10.4 */
/*Write a code that create an informat reading strings like: 
January 22, 2001, October 3, 1956, and so on, as genuine SAS dates*/
/*Based on https://support.sas.com/resources/papers/proceedings/proceedings/sugi27/p101-27.pdf*/
data lab10.ex4;
retain fmtname "mondayyr" type "I";
do label = "19jun1998"d to "18may2001"d;
	start = put(label, worddate.);
	start = trim(left(start));
	output;
end;
run;

proc format cntlin=lab10.ex4;
run;

data null;
_txt = "January 22, 2000";
_sasformat = input(_txt, mondayyr.);
put _sasformat;
run;
/* Exercise 10.5 */
/*Based on the set grades create a data set averages with the average grades of each student for each course.*/
proc sort data=lab10.grades out=lab10.ex5_1;
by student code;
run;
proc means data=lab10.ex5_1 noprint;
by student code;
var grade;
output out=lab10.ex5(drop=_TYPE_ _FREQ_) mean=average;
run;
/* Exercise 10.6 */
/* The data set data has the variables: group, x and y. 
Find the group for which the (group) averages of x and y are closest to the global averages of x and y 
(global means computed for the whole set data).*/

proc sql;
select * 
from(
select aavgX, aavgY, avgX, avgY, group, aavgX - avgX + aavgY - avgY as diff 
from(
select AVG(x) as aavgX, AVG(y) as aavgY , 1 as ttmp
from lab10.data 
) join (
select AVG(x) as avgX, AVG(y) as avgY ,group ,1 as tmp
from lab10.data
group by group
) on ttmp = tmp
)
having abs(diff)=min(abs(diff))
;
quit;
/* Exercise 10.7 */
/* De?ne a format that displays numbers of the form m.n (m,n = 0,...,9) �in words�. 
An example: 2.8 should be formatted as two point eight.*/
proc fcmp outlib=lab10.functions.smd;
   function change(c) $;
   	  if c eq 0 then word = "zero ";
      if c eq 1 then word = "one ";
	  if c eq 2 then word = "two ";
	  if c eq 3 then word = "three ";
	  if c eq 4 then word = "four ";
	  if c eq 5 then word = "five ";
	  if c eq 6 then word = "six ";
	  if c eq 7 then word = "seven ";
	  if c eq 8 then word = "eight ";
	  if c eq 9 then word = "nine ";
	  if c eq . then word = "dot ";
	  return(word);
   endsub;

    function changeToWord(c) $;
		s1 = scan(c, 1, '.');
		s2 = scan(c, 2, '.');
		result = change(s1) || change('.') || change(s2);
	  return(result);
   endsub;
run;
options cmplib=(lab10.functions);
data _null_; 
   f=changeToWord(2.8);
   put f=; 
run;

/* Exercise 10.8 */
/* Define an outlier of the order a as any observation which lies outside of the range 
(med-a*Range,med + a*Range), 
where med and Range are the median and interquartile range respectively. 
Write a code that, for a given parameter alfa = 1 and any given data set with one numerical variable, 
will find all the outliers of the order a.*/
data lab10.ex8_1;
do i=1 to 50;
	do j=1 to 5;
		a=100+sqrt(10)*rannor(0);
	end;
	output;
end;
keep a;
run;

PROC MEANS Data=lab10.ex8_1 N Median QRange;
VAR a;
ods output summary=lab10.ex8_2 ;
RUN;

proc sql;
select a
from(
select *, 1 as ttmp
from lab10.ex8_1
) join (
select * ,1 as tmp
from lab10.ex8_2
) on ttmp = tmp
having a < a_Median - 1 * a_QRange or a > a_Median + 1 * a_QRange
;
quit;

