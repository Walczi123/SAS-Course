libname lab8 '/folders/myfolders/SAS_eng2020/lab8';

/* Exercise 8.2 */
/* Two things to note in this exercise:
1) There is no STOP statement in this DATA STEP although we use POINT option in the SET statement. STOP statement is not needed - we have
another SET statement at the beginning of the DATA STEP and SAS will stop execution of this DATA STEP when it reach the end of set LARGE.
2) NUM variable is used although it was not defined before - in standard situation we would have an error here, however it has assigned value 
in the compilation phase with NOBS option in SET statement (NUM is equal number of rows in the set SMALL). 
*/

data ex8_2;
set lab8.large end=end;
do i=1 to num;
	set lab8.small(rename=(id=id1)) point=i nobs=num;
	if id1=id then do;
		k+1;
		mean+sales;
	end; 
end;
if end then do;
	mean=mean/k;
	output;
end;
keep mean;
run;

/* Exercise 8.5 */
/* There are some functions in SAS which allow to operate on variable lists like SUM, MEAN, MAX, MIN, ...
These functions even allow to operate on arrays, e.g. 
sum(of arr(*))
where arr is an array.
*/ 


data numbers;
do i=1 to 50;
	u=floor(5*ranuni(0));
	output;
end;
keep u;
run;

/* 1st method - without POINT option*/
data sums;
set numbers;
array tmp(5) _temporary_;
if _n_<=dim(tmp) then tmp(_n_)=u;
else do;
	do i=1 to dim(tmp)-1;
		tmp(i)=tmp(i+1);
	end;
	tmp(dim(tmp))=u;
end;

if _n_>=dim(tmp) then do;
	sum=sum(of tmp(*));
	output;
end;

keep sum;
run;

/* 2nd method - with POINT option*/
data sums;
array xx(5) x1-x5;
do i=1 to 50;
	set numbers point=i;
	if i<=5 then do;
		xx(i)=u;
		sum=sum(of x1-x5);
	end;
	else do;
		sum=sum-xx(1);
		do j=1 to 4;
			xx(j)=xx(j+1);
		end;
		xx(dim(xx))=u;
		sum+u;
	end;
	if i>=dim(xx) then output;
end;
keep sum;
stop;
run;

/* Exercise 8.8 */
/* 
It is possible to read multiple sets with one SET statement, eg.:
SET set1 set2 set3;
In this situation SAS will read whole data set set1. When it reaches end of set1 in DATA SET loop, it starts reading set2.
When SAS reaches end of set2, it starts reading of set3. Thus, the resulting data set has number of rows which is a sum of rows of sets
set1, set2 and set3. 
When you read multiple data sets with one SET statement, IN option can be useful. It creates temporary flag to determine,
from which data set the observation was read */

data ex8_8_1;
set lab8.jan (in=wj) lab8.feb (in=wf) lab8.mar (in=wm);
if wj=1 then d=1;
if wf=1 then d=2;
if wm=1 then d=3;
run;

proc sort data=ex8_8_1 out=ex8_8_2;
by person d;
run;

data ex8_8;
set ex8_8_2;
by person;
if last.person then output;
keep person result;
run;

/*  Exercise 8.10 */
/* In this exercise we use MERGE statement to join tables FIRST and SECOND by YEAR.
Note: always remember to sort tables before when using BY statement, which is used here to merge both tables.

Note 2: Variable lists can be also created for all months, like below: Jan--Dec - SAS takes all columns from Jan to Dec,
	it is also possible to take all numeric or character variables by writing Jan-numeric-Dec or Jan-character-Dec. Read more here:
	https://documentation.sas.com/?docsetId=lrcon&docsetTarget=p0wphcpsfgx6o7n1sjtqzizp1n39.htm&docsetVersion=9.4&locale=en#n1dg3poi3joxh3n1tec2e293spdy
*/ 
 
data ex8_10; 
merge lab8.first lab8.second; 
by year;
array t(*) Jan--Dec; 
array sales_arr(12) _temporary_;

if first.year then do;
	do i=1 to 12;
		sales_arr(i)=t(i);
	end;
end;
sales_arr(month)=sum(sales_arr(month),sales);
if last.year then do;
	do i=1 to 12;
		month=i;
		sales=sales_arr(i);
		if sales^=. then output;
		sales_arr(i)=.;
	end;
end;
keep year month sales;
run;

/* Homework:
Exercises: 8.1, 8.3, 8.4, 8.6, 8.7, 8.9
Do not use PROC SQL - these exercises are meant for you to train your skills in DATA STEP processing.
Hints:
8.1: Compare first row of set z1 with first row of z2, then compare second rows, ... - there should be 95 rows with different values
8.3: Set NUMBERS contains row numbers which should be read from the set LARGE. Result should be 52.52
8.4: Assume that you know the number of observations of the data set DOTS. Two dimensional temporary array can be useful here. 
	Output data has 10 rows.
8.6: BY statement and POINT option of SET statement are useful here
8.7: Easier version of 8.8
8.9: Answer: 9 observations. You should compare every obervation from ZXY with every observation from ZX and with every obsevation from ZY.
	For example: row 1 from ZXY is not counted because x=3 and this value cannot be found in the whole ZX data set.
		Row 2 from ZXY is counted, because x=4 is found in ZX and y=8 is found in ZY.
*/