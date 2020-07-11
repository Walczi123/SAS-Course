/*[ItSAS]Solution of Lab 9 by Patryk Walczak*/
/*TODO  9.1c)-h), 9.2-9.5*/

/*The database of the car rental company has the tables: customers (with the variable nr customer that identi?es
a customer in a unique way), rental (with the variable nr rental that identi?es a rental in a unique way), 
rental o?ces (with the variable nr place that identi?es a rental o?ce in a unique way), 
employees (with a variable nr employee that identi?es an employee in a unique way) 
and cars (with the variable nr car that identi?es a car in a unique way).*/

libname lab9 "C:\Users\patry\OneDrive\Desktop\SAS\lab 9\set";
libname lab8 "C:\Users\patry\OneDrive\Desktop\SAS\lab 8\set";
/* Exercise 9.1 */
/*(a) Find the rental o?ce with the largest number of rentals between January 1, 1999 and June 6, 1999*/
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

/*(b) Find the names of the clients who have been renting cars more than once and have rented an Opel at least once. */
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
/*(c) For each rental office pick those cars that have been rented between October 1, 1998 and 
December 31, 1998 (for each rental office list the cars in the ascending order with respect to the length of the rental). */
proc sql;
select nr_rent_office, nr_car, date_rent, date_return, input(date_return, yymmdd10.) - input(date_rent, yymmdd10.) as length
from lab9.rental
having input(date_return, yymmdd10.) > input("1998-10-01", yymmdd10.) and input(date_rent, yymmdd10.) < input("1998-12-31", yymmdd10.)
order by nr_rent_office,length
;
quit;
/*(d) Find the names of those clients that have rented cars more than once and each time have rented cars of different makes. */
proc sql;
select distinct name
from(
select r.nr_customer, r.nr_car, c.brand, num, num2, sum(num2) as sum
from(
select r.nr_customer, r.nr_car, c.brand, num, count(*) as num2
from (
select r.nr_customer, r.nr_car, c.brand, count(*) as num
from lab9.rental r
left join lab9.cars c on c.nr_car = r.nr_car 
group by r.nr_customer
)
group by r.nr_customer, c.brand
having num > 1 
)
group by r.nr_customer
having sum = num 
)
left join lab9.customers c on r.nr_customer = c.nr_customer
;
quit;
/*(e) Give the list of the employees that had not been involved in any car rental between October, 1999 and February, 2000. */
proc sql;
select nr_employee, name, surname
from lab9.employees
where nr_employee not in (
select nr_employee_rent
from lab9.rental
having (input(date_return, yymmdd10.) < input("2000-02-29", yymmdd10.) and input(date_return, yymmdd10.) > input("1999-10-01", yymmdd10.)) or
(input(date_rent, yymmdd10.) < input("2000-02-29", yymmdd10.) and input(date_rent, yymmdd10.) > input("1999-10-01", yymmdd10.))
 )
;
quit;

/*(f) For the rentals in which the pick-up and return of the car were made in different rental offices, */
/*find the names of the employees involved in the rentals. */
proc sql;
select nr_employee, name, surname
from lab9.employees
where nr_employee  in (
select nr_employee_rent as employee
from lab9.rental
having nr_rent_office ne nr_office_return and nr_office_return ^= ""
union all(
select nr_employee_return as employee , nr_employee_rent
from lab9.rental
having nr_rent_office ne nr_office_return and nr_office_return ^= ""
)
)
;
quit;
/*(g) Find the employee who had been hired before 1998 and produced the highest pro?t to the company in 1999. */
proc sql;
select nr_employee, name, surname, date_employment, sum
from(
select nr_employee, name, surname, date_employment
from lab9.employees
having input(date_employment, yymmdd10.) < input("1998-01-01", yymmdd10.)
)
left join(
select nr_employee_rent, sum(profit) as sum
from(
select nr_employee_rent, length, day_price, length*day_price as profit
from(
select nr_employee_rent, date_rent,date_return, input(date_return, yymmdd10.) - input(date_rent, yymmdd10.) as length, day_price
from lab9.rental
having  input(date_return, yymmdd10.) >= input("1999-01-01", yymmdd10.) and input(date_return, yymmdd10.) <= input("1999-12-31", yymmdd10.)
)
having length ne .
)
group by nr_employee_rent
) on nr_employee = nr_employee_rent
having sum = max(sum)
;
quit;
/*(h) Present history of the rentals of the car with the code 000003 (pick-ups dates, return dates, names of clients, costs of rentals).*/
proc sql;
select date_rent, date_return, name, length*day_price as cost
from (
select nr_car, date_rent, date_return, nr_customer, input(date_return, yymmdd10.) - input(date_rent, yymmdd10.) as length, day_price
from lab9.rental as r
having nr_car='000003'
)
left join lab9.customers c on c.nr_customer = r.nr_customer
;
quit;

/* Exercise 9.2 */
/*The data set measurements contains measurements made with instruments instrument in some days of January 2007. */
/*For each pair (instrument, date) from dates ?nd the closest (in time) measurement (the variable measurement) */
/*from the data set measurements.*/
proc sql;
select * , date - md as diff
from(
 select *
 from lab9.dates
 left join(
 select instrument as mi, date as md, measurement as mm
 from lab9.measurements
 )on instrument = mi 
  group by instrument, date
 having abs(date - md) = min(abs(date - md))
 )
 ;
quit;
/* Exercise 9.3 */
/* Solve Problem 2 from Lab 8 with PROC SQL*/
/* What is the average of sales from large computed only for the values of id that occur in the set small?*/
proc sql;
 select avg(sales)
 from lab8.large
 where id in (
  select id 
  from lab8.small
 )
 ;
quit;
/* Exercise 9.4 */
/*Write a query that imitates the following DATA STEP*/
data lab9.razem; 
 merge lab9.a(in = ina) lab9.b(in = inb); 
 by a b c; 
 if inb; 
 if inb and not ina then indyk=1; 
run;

proc sql;
select table_b.a, table_b.b, table_b.c, case when ina=1 then . else 1 end as indyk
from ((select a, b, c, 1 as ina from lab9.a as table_a)
	 full join
	  (select a, b, c, 1 as inb from lab9.b as table_b)
	 on table_a.a=table_b.a and table_a.b=table_b.b and table_a.c=table_b.c)
where inb=1;
quit;
/* Exercise 9.5 */
/*The data set students has the variable that identi?es students uniquely (id student) 
and the variable (id class) with the codes of the courses attended by students. 
For every student ?nd those other students that attend the courses from the list of her/his courses.*/
proc sql;
select distinct id_student, ids2
from ((select id_student, id_class from lab9.students)
	 left join
	  (select id_student as ids2, id_class as idc2 from lab9.students)
	 on id_class=idc2 )
	 where id_student ne ids2
	 ;
quit;


