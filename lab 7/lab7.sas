/* Exercise 7.3 */

/* PROC TRANSPOSE - rearranges columns and rows of SAS data set 
Most important options and statements in PROC TRANSPOSE:
VAR - selects variable to transpose
BY - expands transposed variables into groups
ID - tells SAS to use row values to name columns
IDLABEL - creates labels for the transposed variables
OUT= - names the output data set

Syntax:

proc transpose data=<data-set-name> out=<data-set-name>;
by <variable-list>;
id <variable-list>;
var <variable-list>;
idlabel <variable-list>;
run; 

Read more here:
https://documentation.sas.com/?docsetId=proc&docsetTarget=p1r2tjnp8ewe3sn1acnpnrs3xbad.htm&docsetVersion=9.4&locale=en
*/

proc transpose data=lab7.z out=ex7_3_1;
run;

proc sort data=ex7_3_1 out=ex7_3_2;
by _name_;
run;

proc transpose data=ex7_3_2 out=ex7_3(drop=_name_);
run;

/* Exercise 7.4 */

/* PROC SQL - this procedure allows to manipulate SAS data sets with SQL commands (there are also commands specific to SAS)

Syntax:

PROC SQL <options>;
<queries>
QUIT;

Each query should end with ;

If you do not know SQL language, you can learn more about it here:
https://www.w3schools.com/sql/default.asp

Basic SQL statements (in the order of writing):
SELECT - specifies columns to select, columns are separated by ','
FROM - specifies input data set, from which the data is selected
GROUP BY - groups data by specified variables separated by ','
WHERE - selects rows from the input data set, satisfying specified criteria, it is 
		impossible to use aggregated data values with this statement (e.g. you cannot use COUNT, SUM functions with this statement),
ORDER BY - orders rows by specified variables,
HAVING - filters rows of the output data set after execution of operations from above statements,
		it is possible to use aggregated data values with this statement

Note: WHERE and HAVING have similar role, WHERE is more efficient when it is possible and HAVING is more flexible


CREATE TABLE <table> AS - allows to create table
*/


*a;
proc sql;
/* Count the number of rows in each group */
select x,y,count(y) as number 
from lab7.a 
group by x,y
;

create table ex7_4a_1 as
select x,y
/*SQL allows to insert subqueries, like below - their output is used in main query */
from (select x,y,count(y) as number from lab7.a group by x,y) 
group by x
having number=max(number)
;

create table ex7_4a as
select x,y
from ex7_4a_1 tab 
/*equivalent: from ex7_4a_2 as tab  
'tab' is an alias of table 'ex7_4a_2' in the query */
group by x
having y=min(y)
;

quit;

*b;
proc sql;
create table ex7_4b as
select x,y
from (select x,y,count(y) as number from lab7.a group by x,y)
group by x
having number=max(number)
;
quit;

/* Homework */
/* Exercises: 7.1-7.2, 7.4 c)-h), 7.5-7.7 */
/* Hints:
7.1: Use arrays.
7.2: Use PROC TRANSPOSE, you will need to transform some variables before using it
7.4 c): SELECT DISTINCT can be useful
7.4 e): Try COUNT(DISTINCT variable)
7.4 h),7.5c): Results of subqueries can be used with HAVING statement
7.7 a): You can try CASE instruction, this point can be done also without it.
7.4-7.7: Provide solutions fully written in PROC SQL.

Number of rows and columns (r,c) in the output data sets (you can compare your answers with mine):
7.1: 10, 20
7.2: 100, 11
7.3: 1, 31 
7.4:
	a) 5, 2
 	b) 5, 2
 	c) 0, 1			--> test your code on different set!
 	d) 0, 1			--> test your code on different set!
 	e) 1, 1
 	f) 0, 1			--> test your code on different set!
 	g) 2, 1
 	h) 1, 1
7.5:
	a) 1, 1
	b) 0, 1			--> test your code on different set!
	c) 0, 1			--> test your code on different set!
7.6:
	a) 10, 2
	b) 1, 1
7.7:
	a) 1, 1
	b) 1, 1
*/