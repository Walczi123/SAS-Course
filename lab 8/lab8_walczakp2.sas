/*[ItSAS]Solution of Lab 8 by Patryk Walczak*/
/*TODO 8.1, 8.3, 8.4, 8.6, 8.7, 8.9*/

libname lab8 "C:\Users\patry\OneDrive\Desktop\SAS\lab 8\set";
/* Exercise 8.1 */
/* You are given two data sets: z1 and z2, both with a numerical variable x. 
Treating them as sequences (that is sets in which the order of elements matters), 
write a single DATA STEP that shows the number of di?ering elements in the sets, in the Log window*/
data lab8.ex1;
 retain diff 0; 
 set lab8.z1 end=end;
  set lab8.z2(rename=(x=x2));
   if x ne x2 then do;
    output;
	diff + 1;
   end;
 if end then do;
  put 'number of di?ering elements in the sets: ' diff;
 end;
run;
/* Exercise 8.2 */
/*(Table look-up I) What is the average of sales from large computed only for the values of id that occur in the set small?*/
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
/* Exercise 8.3 */
/*What is the average of the variable sales from the data set large computed only for the observations 
with the numbers listed in the data set numbers?*/
data lab8.ex3;
 set lab8.large end=end;
 retain row 0;
 row + 1;
 do i=1 to num;
  set lab8.numbers point=i nobs=num;
   if row eq nr then do;
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
/* Exercise8.4 */
/*Delete all the missing values from dots, that is transform dots into without dots*/
data lab8.ex4;
 array z [3,10] _temporary_;
 retain l1 0 l2 0 l3 0;
 set lab8.dots end=end;
 if z1 ne . then do;
  l1 + 1;
  z(1,l1) = z1;
 end;
 if z2 ne . then do;
  l2 + 1;
  z(2,l2) = z2;
 end;
 if z3 ne . then do;
  l3 + 1;
  z(3,l3) = z3;
 end;
 if end then do;
  do i = 1 to 10;
   res1 = z(1,i);
   res2 = z(2,i);
   res3 = z(3,i);
   output;
  end;
 end;
 keep res1 res2 res3;
run;
/* Exercise 8.5 */
/*Create a data set numbers with 50 arbitrary numerical observations (with one numerical variable). 
Write a single DATA STEP that will create (based on the data set numbers) the data set sums 
with one numerical variable sum and 46 observations. 
The i-th observation in sums should be the sum of observations from numbers numbered {i,...,i + 4}. */
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
/* Exercise 8.6 */
/* Write a single DATA STEP that acts as the following SQL query*/
proc sql noprint;
 create table lab8.aa as 
  select *, count(y) as licznik
  from lab8.a 
   group by x 
   having count(y)>5 
   ; 
quit;

data lab8.ex6_1;
 retain last;
 set lab8.a end=end;
 if x ne last then do;
  if l ne 0 then output;
  last = x;
  l = 1;
 end;
 else l+1;
 if end then output;
 keep last l;
run;

data lab8.ex6; 
 set lab8.a end=end;
 do i=1 to num;
  set lab8.ex6_1(rename=(last=x2)) point=i nobs=num;
   if x eq x2 and l > 5 then do;
    output;
   end;
 end;
 keep x y l;
run;

/* Exercise 8.7 */
/* Based on the data sets zb1,..., zb5 create a data set result that has the whole year 2007 in the variable date.*/
data lab8.ex7_1;
 set lab8.zb1 (in=a) lab8.zb2 (in=b) lab8.zb3 (in=c) lab8.zb4 (in=d) lab8.zb5 (in=e);
 if a=1 then y=1;
 if b=1 then y=2;
 if c=1 then y=3;
 if d=1 then y=4;
 if e=1 then y=5;
run;

proc sort data=lab8.ex7_1 out=lab8.ex7(drop=y);
by date y;
run;
/* Exercise 8.8 */
/* The data sets jan, feb and mar have two variables : person and result. 
Generate a data set with the most current results for every person 
(the names of the sets refer to the names of the months in which the measurements were taken).*/
data lab8.ex8_8_1;
set lab8.jan (in=wj) lab8.feb (in=wf) lab8.mar (in=wm);
if wj=1 then d=1;
if wf=1 then d=2;
if wm=1 then d=3;
run;

proc sort data=lab8.ex8_8_1 out=lab8.ex8_8_2;
by person d;
run;

data lab8.ex8_8;
set lab8.ex8_8_2;
by person;
if last.person then output;
keep person result;
run;
/* Exercise 8.9 */
/* The data sets zx and zy have single numerical variables (x and y respectively), 
and the set zxy has both x and y. Find the number of observations from zxy such that 
their values of x and y are equal to the values of x from zx and y from zy with the same observation number.*/
data lab8.ex9;
 set lab8.zxy end=end;
  set lab8.zx(rename=(x=x2));
   set lab8.zy(rename=(y=y2));
   row+1;
   if x eq x2 and y eq y2 then do;
	l+1;
	output;
   end;
 if end then do;
  put 'number of observations: ' l;
 end;
 drop l;
run;

/*From the hint the task is a little different, so I add the second solution.*/
data lab8.ex9_hint;
 retain bool 0;
 set lab8.zxy end=end;
  bool = 0;
  do i=1 to num;
   set lab8.zx(rename=(x=x2)) point=i nobs=num;
	do j=1 to num1;
     set lab8.zy(rename=(y=y2)) point=j nobs=num1;
	 if x eq x2 and y eq y2  and bool eq 0 then do;
	  bool + 1;
	  l+1;
	  output;
	 end;
    end;
   end;
 if end then do;
  put 'number of observations: ' l;
 end;
 drop bool l;
run;
/* Exercise 8.10 */
/* Use a single DATA STEP to update ?rst with the data from second. 
(If a given year and month are missing in both sets, they should not be placed in the updated set. 
If, for a given year and month, there is no data in ?rst (or in second), 
one should leave in the updated ?le the value of sales from second (?rst, respectively) - 
if it exists. If some year and month are present in both ?les, 
the value of sales from ?rst should be increased by the relevant value from second.) 
One can assume that both ?les are sorted in ascending order with respect to year and that the names of sets, 
and the names and types of variables are known.*/
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
