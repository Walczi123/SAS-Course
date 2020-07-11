libname lab6 '/folders/myfolders/SAS_eng2020/lab6';

/* Exercise 6.1. */

/* POINT=variable option in SET statement: 
specifies a temporary variable whose numeric value determines which observation is read. 
POINT= causes the SET statement to use random (direct) access to read a SAS data set.

Important note 1: when you use POINT option, you need to use STOP statement which breaks 
the execution of DATA STEP. 
Otherwise DATA STEP would not end.

Important note 2: _N_ is an iteration count of a DATA STEP and not the observation number 
of the last observation that was read.

Read more about POINT option here:
https://documentation.sas.com/?docsetId=lestmtsref&docsetTarget=p00hxg3x8lwivcn1f0e9axziw57y.htm&docsetVersion=3.1&locale=en#n19qtk2v7izsqen1n0am0e5wq268
*/

data ex6_1;
u=1;
set lab6.a point=u;
array numbers(10) k1-k10;
array num_tmp(10) _temporary_;
do i=1 to 10;
	num_tmp(i)=numbers(i);
end;
i=1;
u=num_tmp(i);
do while(u^=.);
	set lab6.a point=u;
	i+1;
	u=num_tmp(i);
	output;
end;
stop;
keep k:;
run;
































/* Exercise 6.3 */

/* First read the contents of IntroSASlab06_intro.sas file, where INFILE and INPUT statements 
are explained in detail */

data ex6_3_1;
infile "/folders/myfolders/SAS_eng2020/lab6/p1.txt" dlm="x" missover;
input id height weight sex $ age name $;
run;

data ex6_3_2;
infile "/folders/myfolders/SAS_eng2020/lab6/p2.txt" missover;
input id 1 height 2-4 weight 5-6 sex $ 7 age 8-9 name $;
run;

/* INFORMAT statement - specifies how the input data is formatted, read more in documentation */

data ex6_3_3;
informat id 1. name $16. salary comma9.2 date yymmdd8.; 
format salary comma9.2 date yymmdd8.;
infile "/folders/myfolders/SAS_eng2020/lab6/p3.txt" missover;
input id name $ & salary :comma9.2 date yymmdd8.;
run;

data ex6_3_4;
informat name $8. surname $10. number 4.;
infile "/folders/myfolders/SAS_eng2020/lab6/p4.txt";
input name $ / surname $ / number;
run;






























/* Exercise 6.5 */

data ex6_5;
format date ddmmyy10.;
infile "/folders/myfolders/SAS_eng2020/lab6/fileB.txt" missover;
input date ddmmyy10. @"r1" r1 @1 @"r2" r2 @1 @"r3" r3 @1 @"r4" r4;
run;

































/* Exercise 6.2 */

/* Homework */
/* Hint: When we use POINT option, value of the variable created by this option can be 
copied to another variable */

/* Exercise 6.4 */

/* Homework */

/* Exercise 6.6 */

/* Homework */
/* Hint: similar to ex. 6.3, part with p3.txt */

/* Exercise 6.7. */

/* Homework */
/* Hint: use @ and DO WHILE loop */

/* Exercise 6.8 */

/* Homework */
/* Hint: read more about # in the documentation of INPUT statement 
(this opearator allows to control line pointer):
https://documentation.sas.com/?docsetId=lestmtsref&docsetTarget=n0oaql83drile0n141pdacojq97s.htm&docsetVersion=9.4&locale=en
*/

/* Exercise 6.9. */

/* Homework */
/* Hint: check in documentation DLM option of INFILE statement */

/* Exercise 6.10 */

/* Homework */
/* Hint 1: check in documentation TRUNCOVER option of INFILE statement */
/* Hint 2: LBOUND(array), HBOUND(array) - functions returning first and last index of an array */

