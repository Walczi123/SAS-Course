/*[ItSAS]Solution of Lab 6 by Patryk Walczak*/
/*TODO :6.2, 6.4, 6.6-6.10*/

libname lab6 "C:\Users\patry\OneDrive\Desktop\SAS\lab 6\set";

/* Exercise 6.1 */
/*Create a data set with (only) such observations from the data set A 
that their numbers are listed in the first row of A*/

data lab6.ex1;
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

/* Exercise 6.2 */
/*The i-th row of the data set tree contains the numbers of the ascendants */
/*of the i-th vertex in a binary tree. */
/*Pick a random path in the tree (starting from the root, i.e. the vertex number 1).*/
data lab6.ex2;
 u=1;
 set lab6.tree point=u; 
 do while(u^=.);
  way = rand("Uniform");
  current = u;
  output;
  if left ne . or right ne . then do;
   if way < 0.5 and left ne . then u = left;
   else u = right;
  end;
  else u =.;
  set lab6.tree point = u;
 end;
 stop;
run;

/* Exercise 6.3 */
/* First read the contents of IntroSASlab06_intro.sas file, where INFILE and INPUT statements 
are explained in detail */

data lab6.ex6_3_1;
infile "C:\Users\patry\OneDrive\Desktop\SAS\lab 6\set\p1.txt" dlm="x" missover;
input id height weight sex $ age name $;
run;

data lab6.ex6_3_2;
infile "C:\Users\patry\OneDrive\Desktop\SAS\lab 6\set\p2.txt" missover;
input id 1 height 2-4 weight 5-6 sex $ 7 age 8-9 name $;
run;

/* INFORMAT statement - specifies how the input data is formatted, read more in documentation */

data lab6.ex6_3_3;
informat id 1. name $16. salary comma9.2 date yymmdd8.; 
format salary comma9.2 date yymmdd8.;
infile "C:\Users\patry\OneDrive\Desktop\SAS\lab 6\set\p3.txt" missover;
input id name $ & salary :comma9.2 date yymmdd8.;
run;

data lab6.ex6_3_4;
informat name $8. surname $10. number 4.;
infile "C:\Users\patry\OneDrive\Desktop\SAS\lab 6\set\p4.txt";
input name $ / surname $ / number;
run;

/* Exercise 6.4 */
/*The text file experiment.txt contains some data which describa a number of repeated experiments.*/
/*The rows finishing with the word START (STOP) denote the beginning (the end, respectively)*/
/*of an experiment. All the other rows contain some unimportant data from some intermediate*/
/*phases of the experiments. Create a data set with the duration times (counted in days) of */
/*consecutive experiments.*/

data lab6.ex4;
 infile "C:\Users\patry\OneDrive\Desktop\SAS\lab 6\set\experiment.txt" missover;
 input date yymmdd10. number phase $;
 retain start stop experiment;
 if( phase eq "START") then start=date;
 if( phase eq "STOP") then stop=date;
 if ( stop ne . and stop > start) then do;
   duration = stop - start;
   experiment + 1;
   output;
 end;
 keep duration experiment;
run;

/* Exercise 6.5 */
/*Write a data step that reads the text file fileB.txt into the data set B.*/

data lab6.ex5;
 format date ddmmyy10.;
 infile "C:\Users\patry\OneDrive\Desktop\SAS\lab 6\set\fileB.txt" missover;
 input date ddmmyy10. @"r1" r1 @1 @"r2" r2 @1 @"r3" r3 @1 @"r4" r4;
run;

/* Exercise 6.6 */
/* Write a data step that reads the text file fileC.txt into the data set C.*/

data lab6.ex6;
 informat id 1. _people $char9. amount1 comma7. amount2 comma7. _date ddmmyy10.;
 format _date ddmmyy10.;
 format date ddmmyy10.;
 infile "C:\Users\patry\OneDrive\Desktop\SAS\lab 6\set\fileC.txt" missover;
 input id _people amount1 amount2 _date;
 retain date;
 if _date ne . then date = _date;
 amount = amount1;
 person = scan(_people,1,'/');
 output;
 amount = amount2;
 person = scan(_people,2,'/');
 output;
 drop _people _date amount1 amount2;
run;


/* Exercise 6.7 */
/*Write a data step that reads the text file fileD.txt into the data set D.*/

data lab6.ex7;
 infile "C:\Users\patry\OneDrive\Desktop\SAS\lab 6\set\fileD.txt" missover;
 input id $ x k $ @;
 do while(k ne 'k');
		input x k $@;
 end;
 input;
 keep id x;
run;

/* Exercise 6.8 */
/*Read from the text file p.txt into a data set only the rows with */
/*numbers listed in the first row of the text file*/

data lab6.ex8;
 infile "C:\Users\patry\OneDrive\Desktop\SAS\lab 6\set\p.txt" missover;
 input number1-number10;
 array read(10);
 retain row read;
 row+1;
 if row eq 1 then do;
  read(1)=number1;
  read(2)=number2;
  read(3)=number3;
  read(4)=number4;
  read(5)=number5;
  read(6)=number6;
  read(7)=number7;
  read(8)=number8;
  read(9)=number9;
  read(10)=number10;
 end;
 else do;
  do i = 1 to 10;
   if row eq read(i) then output;
  end;
 end;
 keep number1-number10;
run;

/* Exercise 6.9 */
/*From each line of the text file gaps.txt read the first three non-missing values into a data sets.*/
/*(The selection should be done while reading the values from the text file.)*/

data lab6.ex9;
 array numbers(3) k1-k3;
 infile "C:\Users\patry\OneDrive\Desktop\SAS\lab 6\set\gaps.txt" missover;
 input x @;
 n=1;
 do while(n<4);
  if x ne . then do;
   numbers(n)=x;
   n+1;
  end;
  input x @;
 end;
 input;
 drop n x;
run;

/* Exercise 6.10 */
/*The text file blocks.txt has an unknown number of four-rows blocks that start from the numbers:*/
/*2004, 2005, 2006 or 2007. Create a data set with four variables (r2004 - r2007) */
/*that is a transposition of the data from the text file blocks.txt.*/

data lab6.ex10;
 infile "C:\Users\patry\OneDrive\Desktop\SAS\lab 6\set\blocks.txt" missover;
 input year n1-n12;
 array number(12) _temporary_;
 array y2004(36);
 array y2005(36);
 array y2006(36);
 array y2007(36);
 retain l y2004 y2005 y2006 y2007 x4 x5 x6 x7;
 l+1;
 if l eq 1 then do;
  x4 = 1;
  x5 = 1;
  x6 = 1;
  x7 = 1;
 end;
 number(1)=n1;
 number(2)=n2;
 number(3)=n3;
 number(4)=n4;
 number(5)=n5;
 number(6)=n6;
 number(7)=n7;
 number(8)=n8;
 number(9)=n9;
 number(10)=n10;
 number(11)=n11;
 number(12)=n12;
 if year = 2004 then do;
  do i=1 to 12;
   if number(i) ne . then do;
    y2004(x4) = number(i);
	x4+1;
   end;
  end;
  end;
  if year = 2005 then do;
  do i=1 to 12;
   if number(i) ne . then do;
    y2005(x5) = number(i);
	x5+1;
   end;
  end;
  end;
  if year = 2006 then do;
  do i=1 to 12;
   if number(i) ne . then do;
    y2006(x6) = number(i);
	x6+1;
   end;
  end;
  end;
  if year = 2007 then do;
  do i=1 to 12;
   if number(i) ne . then do;
    y2007(x7) = number(i);
	x7+1;
   end;
  end;
 end;
 if l eq 12 then do;
  do i=1 to 36;
   r2004 = y2004(i);
   r2005 = y2005(i);
   r2006 = y2006(i);
   r2007 = y2007(i);
   output;
  end;
 end;
 keep r2004 r2005 r2006 r2007;
 run;
