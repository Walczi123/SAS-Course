/*[ItSAS]Solution of Lab 7 by Patryk Walczak*/
/*TODO 7.1, 7.2, 7.4c)-h), 7.5, 7.6, 7.7*/

 libname lab7 "C:\Users\patry\OneDrive\Desktop\SAS\lab 7\set";

/* Exercise 7.1 */
/*Create a data set with 10 numerical variables z1,...,z10 and 20 observations. Then transpose it without using PROC TRANSPOSE.*/
data lab7.ex1_1;
 array val(10) val1-val10;
 do i=1 to 20;
  do j=1 to 10;
   val(j)=rand("Integer", 1, 10);
  end;
  output;
 end;
 drop i j;
run;

data lab7.ex1;
 set lab7.ex1_1 end=last;
 array tmp [10,20] _temporary_;
 array val(10) val1-val10;
 retain j;
 j+1; 
 do i=1 to 10;
  tmp(i,j) = val(i);
 end;
 if last then do;
  array result(20) res1-res20 (20*0);
  do i=1 to 10;
   do k=1 to 20;
	result(k) = tmp(i,k);
   end;
   output;
  end;
 end;
 drop val1-val10 i j k;
run;
/* Exercise 7.2 */
/*Transform the data set z1 into z2.*/
proc transpose data=lab7.z1 out=lab7.ex2(drop=_NAME_);
 by art;
 id dat;
run;
/* Exercise 7.3 */
/*7.3 Order alphabetically the variables in the data set z.*/
proc transpose data=lab7.z out=work.z;
run;

proc sort data=work.z out=work.z_s;
 by _NAME_;
run;

proc transpose data=work.z_s out=work.z_s_t(drop=_NAME_);
 id _NAME_;
run;
/* Exercise 7.4 */
/*7.4 The data set a has the variables x and y.
(a) For every value of x ?nd the most frequently appearing values of the variable y (do not care for ex-aequo situations, if they appear – just pick any of the most frequent values of y). 
(b) For every value of x list all the most frequent values of the variable y. 
(c) Find all such values of x for which there exists exactly one smallest y. 
(d) Find all such values of x for which there are no repeating values of the variable y. 
(e) Find all such values of x that have the largest number of distinct values of y. 
(f) Find all values of the variable x for which the values of y form the set {1,...,n} for some n ?N. 
(g) Find all such x for which the distinct values of y form the set {1,...,n} for some n ?N. 
(h) Find such values of y that correspond to at least half of the values of x that appear in the data set a.*/

/*a*/
proc sql;
 select x,y
 from(
	 select * 
	 from (
	  select x,y,count(*) as count1 
	  from lab7.a
	  group by x,y
	 )
	 having count1=max(count1)
  )
  group by x
  having min(y)=y
  ;
quit;
/*b*/
proc sql;
 select * 
 from (
  select x,y,count(*) as count1 
  from lab7.a
  group by x,y
 )
 having count1=max(count1)
 ;
quit;
/*c Find all such values of x for which there exists exactly one smallest y.*/
proc sql;
 select x,y
 from(
  select x,y,min(y)as min_y
  from lab7.a
  group by x
  having y=min(y)
  )
  having(count(y))=1
  ;
quit;
/*d Find all such values of x for which there are no repeating values of the variable y. */
proc sql;
 select x,y,count_
 from(
  select x,y,count(*) as count_
  from lab7.a
  group by x,y
  )
  group by x
  having(max(count_)=1)
  ;
quit;
/*e Find all such values of x that have the largest number of distinct values of y. */
proc sql;
select x
from(
 select x,count(*) as cnt
 from(
  select x,y,count(*) as count_
  from lab7.a
  group by x,y
  )
  group by x
 )
 having(cnt=max(cnt))
 ;
quit;
/*f Find all values of the variable x for which the values of y form the set {1,...,n} for some n ?N. */
proc sql;
select x,y,count_Y,count(*) as count_a
from(
select x,y,count_Y
from(
select x,y, count(*) as count_y
from(
select distinct x,y
  from lab7.a
  )
  group by x
  )
  having y<=2 and y>0 /*2 is N*/
  )
group by x
having count_a = count_Y and count_a = 2/*2 is N*/
  ;
quit;
/*g Find all such x for which the distinct values of y form the set {1,...,n} for some n ?N.*/
proc sql;
select distinct x
from(
	select x,y,count(*) as c
	from(
		  select distinct x,y
		  from lab7.a
		  having y>0 and y<=2 /* 2 is N*/
	  )
	  group by x
  )
  where(c = 2)/* 2 is N*/
  ;
quit;
/*h Find such values of y that correspond to at least half of the values of x that appear in the data set a.*/
proc sql;
select distinct y
from(
select y,x,count(*) as _count_y
from(
	 select distinct y,x
	 from lab7.a
 )
 group by y
 )
cross join(
select count(*) as diff_x
from(
  select  distinct x
  from lab7.a
  )
  )
  having _count_y > diff_x/2
  ;
quit;

/* Exercise 7.5 */
/*The data set z3 has two variables id, year and sales. 
• Find all values of id that did not appear before 1993. */
proc sql;
select id
from(
select id,SUM(CASE WHEN sum_ THEN 1 ELSE 0 END) as s
from(
  select id,year,SUM(CASE WHEN year<1993 THEN 1 ELSE 0 END) as sum_
  from lab7.z3
  group by id,year
  )
  group by id
  )
  having s = 0
  ;
quit;
/*• Find all values of id that appeared both in the first and in the last year. */
proc sql;
select id
from(
select id,count(*) as c
from(
  select id,year
  from lab7.z3
  having year = min(year) or year = max(year)
  )
  group by id
  )
  having c = 2
  ;
quit;
/*• Find all values of id that were present in every year. */
proc sql;
 select id, _count_year, _years_
from (
  select distinct id,year, count(*) as _count_year
  from lab7.z3
  group by id
  ) as id
  cross join(
 select count(*) as _years_
 from(
  select distinct year
  from lab7.z3
  )
  ) as _years_
  having _years_ = _count_year
  ;
quit;
/* Exercise 7.6 */
/*The data set b has the variables a1,x1,a2,x2.
a) Treating a1 and a2 as grouping variables, for each group formed by a1 pick such values of x1 
that are between the smallest and the largest value of x2 in the same group formed by a2.*/
proc sql;
select a1,x1,a2,minX2,maxX2
from(
select a1,x1
from lab7.b
group by a1
)
cross join(
select a2,x2,min(x2) as minX2,max(x2) as maxX2
from lab7.b
group by a2
)
group by a1
having x1>minX2 and x1<maxX2
;
quit;

/*(b) Identify the name of the group that appears b most frequently.*/
proc sql outobs=1;
select name1,(count_1 + count_2) as _sum_
from(
select a1 as name1,count(*) as count_1
from lab7.b
group by a1
)
cross join(
select a2 as name2,count(*) as count_2
from lab7.b
group by a2
)
having name1=name2
order by _sum_ desc
;
quit;
/* Exercise 7.7 */
/* With a single SQL query, based on the data set c:*/
/*(a) Find the month in which r2 has the largest number of missing values, */
proc sql outobs=1;
  select month(day) as _month_, SUM(CASE WHEN r2 =. THEN 1 ELSE 0 END) as _sum_
  from lab7.c
  group by _month_
  order by _sum_ desc
   ;
quit; 
/*(b) Find the month in which the values of r1 are most scattered*/
proc sql outobs=1;
  select  month(day) as _month_, (max(r1)-min(r1)) as diff
  from lab7.c
  group by _month_
  order by diff desc
  ;
quit;
