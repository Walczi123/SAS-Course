libname lab9 '/folders/myfolders/SAS_eng2020/lab9';
libname lab8 '/folders/myfolders/SAS_eng2020/lab8';

/* Joining 2 tables in SQL - let us assume that we have two tables: A and B. Table A has column id_A, table B has column id_B.
These tables can have more columns. We want to join them on a common values of columns id_A and id_B. 
We have the following possibilities to join them:
- INNER JOIN (JOIN) - returns only records from tables A and B for which the match was found, example:
SELECT id_A,id_B
FROM A
INNER JOIN 
B
ON id_A=id_B
;
- LEFT JOIN - returns records returned by INNER JOIN 
				+ records from A for which the match with B was not found (in this case columns from the table B are missing), 
			example:
			
SELECT id_A,id_B
FROM A
LEFT JOIN 
B
ON id_A=id_B
;

- RIGHT JOIN - returns records returned by INNER JOIN
				 + records from B for which the match with A was not found (in this case columns from the table A are missing);
				 it is the same type of join as LEFT JOIN except the fact that roles of A and B are inverted, 
				 example:

SELECT id_A,id_B
FROM A
RIGHT JOIN 
B
ON id_A=id_B
;

- FULL JOIN - returns records returned by INNER JOIN
				+ records from A for which the match with B was not found (in this case columns from the table B are missing) 
				+ records from B for which the match with A was not found (in this case columns from the table A are missing), 
				example:

SELECT id_A,id_B
FROM A
RIGHT JOIN 
B
ON id_A=id_B
;

Note 1: When using above joins, ON statement is obligatory and this statement contains a logical condition indicating whether 
the match is found.

Note 2: If in above examples one of the keys is duplicated, the resulting table will also contain duplicate keys (it can happen
that the resulting table has much more rows than input tables).

Note 3: Most often used type of above joins in practice is LEFT JOIN: in most cases we have a situation where one table is the main one
and we want to append the information from some columns contained in auxiliary tables.

Note 4: It is worth to use table aliases when performing joins, e.g. like in exercise 9.1a):
lab9.rental_offices AS a
Then, if you want to refer to the column nr_place from lab9.rental_offices, you can write a.nr_place 
(or just nr_place, if the column with such name exists only in the lab9.rental_offices).

Note 5: Multiple join statements are allowed, in this case they are executed according to their order in the code, e.g.:
SELECT *
FROM
A 
LEFT JOIN B
ON A.id_A=B.id_B
LEFT JOIN C
ON A.id_A=C.id_C
;

More details about joins here:
https://www.w3schools.com/sql/sql_join.asp
https://www.w3schools.com/sql/sql_join_inner.asp
https://www.w3schools.com/sql/sql_join_left.asp
https://www.w3schools.com/sql/sql_join_right.asp
https://www.w3schools.com/sql/sql_join_full.asp
*/


/*Exercise 9.1*/
*a;
proc sql;
select * from(
select nr_place, count(nr_rental) as ncount
from lab9.rental_offices as a
left join
lab9.rental as b
on a.nr_place=b.nr_rent_office
where date_rent between "1/01/1996" and "6/6/1995"
group by nr_place
)
having ncount=max(ncount)
;
quit;

*b;
proc sql;
create table tab1 as
select a.nr_customer,a.surname, b.nr_rental, c.brand
from lab9.customers as a
left join 
lab9.rental as b
on a.nr_customer=b.nr_customer
left join
lab9.cars as c
on c.nr_car=b.nr_car
;

select distinct nr_customer,surname, count(nr_rental) as ncount, max(case when brand="OPEL" then 1 else 0 end) as opel
from tab1
group by nr_customer
having calculated ncount>1 and calculated opel=1
;
quit;

/*Homework: 9.1c)-h), 9.2-9.5 
All exercises in this homework shall be done ONLY in PROC SQL. DATA STEPs are not allowed.
*/
/*
Hints:
9.1c) SAS functions work in PROC SQL, e.g. you can use INPUT function to convert dates to numeric variables
9.1e) To find all employees, use UNION statement in PROC SQL, see notes at the end of this file
9.1g) Profit from renting one car is calculated as: 
(number of days the car was rent)x(day_price). 
For cars not returned profit should be equal 0.
9.4 UNION, INTERSECT, EXCEPT can be useful in this exercise, see notes at the end of this file

Expected number of rows in output data sets:
9.1a) 1
9.1b) 3
9.1c) 7
9.1d) 4
9.1e) 5
9.1f) 10
9.1g) 2
9.1h) 3
9.2 20
9.3 1
9.4 7
9.5 20
*/

/*
Other types of joins: self join - creates Cartesian product of two tables - every row of one table is matched with 
every row of second table (less efficient than previously presented joins), example:
SELECT *
FROM A,B
;

Set operations on data sets in SQL: they can be used to join tables by rows (not by columns like presented above). Important note:
columns in joined tables shall have the same: names, order and formats.
We have the following operators to join tables:
UNION - returns data set which rows are the union of rows of two data sets in sense of set theory (duplicated rows are removed)
UNION ALL - returns data set where rows from the second data set are appended to the first (duplicated rows are not removed)
INTERSECT - returns data set with common rows in both data sets (duplicated rows are removed)
EXCEPT - returns data set with rows existing in the first data set which do not exist in the second data set
Usage:
SELECT *
FROM A
UNION | UNION ALL | INTERSECT | EXCEPT
SELECT *
FROM B
;

More here:
https://www.techonthenet.com/sql/intersect.php
https://www.techonthenet.com/sql/union.php
https://www.techonthenet.com/sql/union_all.php
https://www.techonthenet.com/sql/except.php
*/
