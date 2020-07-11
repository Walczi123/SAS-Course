/*[ItSAS]Solution of Lab 11 by Patryk Walczak*/
/*TODO  11.3-11.7, 11.9*/

libname lab11 "C:\Users\patry\OneDrive\Desktop\SAS\lab 11\set";

/* Exercise 11.1 */
/* Write a macro %create(pre?x,N,k,l) that creates N data sets with the names pre?x1,...,pre?xN. 
Each data set should have k variables and l observations from the uniform distribution on (-1,1).*/
%macro create(prefix,N,k,l);
%do u=1 %to &N;
	data &prefix&u;
	%do j=1 %to &l;
		%do i=1 %to &k;
		x&i=2*ranuni(0)-1;
		%end;
		output;
	%end;
	run;
%end;
%mend;

%create(a,1,1,50)
/* Exercise 11.2 */
/* Write a macro %count(set,variables,n) which for every variable from the data set set will ?nd 
the number of observations larger than the number n.*/

%macro count(set,variables,n);
%let x=%scan(&variables,1);
%let i=1;
	%do %while(&x ne );
		data _null_;
		set &set end=end_flag;
		if &x>&n then i+1;
		if end_flag then put "There are " i "observations of variable &x greater than &n";
		run;		
		%let i=%eval(&i+1);	*(without %eval we would have i="i+1");
		%let x=%scan(&zmienne,&i);
	%end; 
%mend;

%count(Ab1,x1,0)

/* Exercise 11.3 */
/* Transform the data set dots into no dots. (That is, remove the missing values for every variable in dots.)*/

%macro transform_col(set, index);
data tmp;
set lab11.&set;
array arr[*] _ALL_;
if arr[&index] ne . then do;
	z&index=arr[&index];
	output;
end;
keep z&index;
run;
%mend;

%macro transform(set);
%transform_col(&set, 1);
data my_no_dots;
set tmp;
run;
%do i=1 %to 54;
	%transform_col(&set, &i);
	data my_no_dots;
	merge my_no_dots tmp;
	run;
%end;
%mend;

%transform_col(Dots, 1);
%transform(Dots);

/* Exercise 11.4 */
/*Assume that a data set a contains one numerical variable and 50 observations. 
Write a macro that creates a data set averages with one variable and 50 observarions. 
The ith observation in average should be the average of the observations from a numbered {i,...,50}. 
The problem should be solved in two ways: 
(a) one can merge a number of copies of a (with appropriately shifted observations), */
data ex_4;
do i=1 to 50;
 a = rand("Integer", 1, 10);
 output;
end;
drop i;
run;

%macro avg(set,number);
data tmp;
set &set end=end;
retain index 0;
index + 1;
if index>=&number then do;
	count+1;
	sum+a;
end;
if end then do; 
	average=sum/count;
	output;
end;
keep average;
run;
%mend;

%macro ex_11_4_1(set);
%avg(&set,1);
data averages;
set tmp;
run;
%do i=2 %to 50; /*i powinno byc od 2*/
	%avg(&set,&i);
	data averages;
	set averages tmp; 
	run;
%end;
%mend;
%ex_11_4_1(ex_4);

/*(b) one can transpose the set a (and count the averages from the relevant columns).*/
proc transpose data=ex_4 out=ex_4_2(drop=_name_);
run;

%macro ex_11_4_2(set);
data averages_2;
set &set;
array arr[*] Col:;
do i = 1 to 50;
	do j = i to 50;
		c+1;
		sum+arr[j];
	end;
	average=sum/c;
	output;
	sum=0;
	c=0;
end;
keep average;
run;
%mend;

%ex_11_4_2(ex_4_2);

/* Exercise 11.5 */
/* Write a macro that returns the number of words in a given macrovariable and 
a macro that writes each word from a given macrovariable into a separate macrovariable*/
%macro ex_11_5_1(words);
%let i=1;
%let word=%scan(&words,&i);
	%do %while(&word ne );
		%let i=%eval(&i+1);
		%let word=%scan(&words,&i);		
	%end; 
	%let i=%eval(&i-1);
&i
%mend;

%let reuslt = %ex_11_5_1(wrod1 word2 word3 word3);
%put &=reuslt;

%macro ex_11_5_2(words);
%let i = %ex_11_5_1(&words);
%put &i;
%let j=1;
%local result;
%let word=%scan(&words,&j);
	%do %while(&word ne );
		%let result=&result &word;
		%let j=%eval(&j+1);
		%let word=%scan(&words,&j);		
	%end; 
&result;
%mend;

%let reuslt = %ex_11_5_2(wrod1 word2 word3);
%put &=reuslt;
/* Exercise 11.6 */
/*Write a macro that computes the value of n! (the macro should not contain any DATA STEP).*/
%macro factorial(n);
%let res=1;
%do i=2 %to &n;
	%let res = %eval(&res * &i);
%end;
%put The factorial result of &n  is equal &res;
%mend;

%factorial(9);

/* Exercise 11.7 */
/*Write a macro that depends on two parameters names and chars and shows in the Log window all the words from a given string names 
that do not contain the characters listed in the parameter chars.*/
%macro ex11_7(names,chars);
%let i=1;
%let name=%scan(&names,&i);
	%do %while(&name ne );
		%let j=1;
		%let c=0;
		%let char=%scan(&chars,&j);
		%do %while(&char ne );
		 	%let c=%eval(&c+%index(&name,&char));
			%let j=%eval(&j+1);
			%let char=%scan(&chars,&j);
		%end;
		%if &c = 0 %then %put &name;  
		%let i=%eval(&i+1);
		%let name=%scan(&names,&i);		
	%end; 
%mend;

%ex11_7(Patryk Ala Bartek Marcin Ania, P );

/* Exercise 11.8 */
/* Generate N macrovariables named z1,..,zN so as to have a randomly chosen capital letter as the value of each macrovariable. 
(Clearly, it may happen that the values of distinct macrovariables are identical.) 
Show in the Log window all the macrovariables with distinct values.*/
%macro ex11_8_1(N);
%let letters=ABCDEFGHIJKLMNOPQRSTUVWXYZ;
%let len=%length(&letters);
%let v=0;
%do i=1 %to &N;
	%let v=%sysfunc(ranuni(0));
	%let v=%sysevalf(&len*&v);
	%let v=%sysfunc(ceil(&v));
	%let z&i=%qsubstr(&letters,&v,1);
	%put z&i.=&&z&i;
%end;
%mend;

%ex11_8_1(4);

%macro ex11_8_2(N);
%let letters=ABCDEFGHIJKLMNOPQRSTUVWXYZ;
%let len=%length(&letters);
%let v=0;
%do i=1 %to &N;
	%let v=%sysfunc(ranuni(0));
	%let v=%sysevalf(&len*&v);
	%let v=%sysfunc(ceil(&v));
	%let z&i=%qsubstr(&letters,&v,1);
%end;
%do i=1 %to &N;
	%let flag=0;
	%do j=1 %to &N;
		%let u=%eval(&&z&i=&&z&j);
		%if &u=1 %then %let flag=%eval(&flag+1);
	%end; 
	%if &flag<2 %then %put z&i.=&&z&i;
%end;
%mend;

%ex11_8_2(15);

%macro ex11_8_3(N);
%let letters=ABCDEFGHIJKLMNOPQRSTUVWXYZ;
%let len=%length(&letters);
%let v=0;
%do i=1 %to &N;
	%let z&i=1;
	%let flag=0;
	%do %while (&&z&i=1 or &flag=0);
		%let v=%sysfunc(ranuni(0));
		%let v=%sysevalf(&len*&v);
		%let v=%sysfunc(ceil(&v));
		%let z&i=%qsubstr(&letters,&v,1);
		%let flag=1;
		%do j=1 %to %eval(&i-1);
			%if %eval(&&z&i=&&z&j) %then %let flag=0;
		%end;
	%end;
	%put z&i=&&z&i;
%end;
%mend;

%ex11_8_3(15);

/* Exercise 11.9 */
/*Write a macro %comb(n,k) that creates for given n,k ?N a data set combinations with k variables and n kobservations. 
The rows of combinations should contain k-element combinations of the set {1,...,n} .*/

/*Combination without repetition*/
%macro comb(n,k);
%let count=%sysfunc(comb(&n,&k));
data comb_set;
array combination[&n];
do i=1 to &n;
	combination[i]=i;
end;
do j=1 to &count;
	call allcomb(j,&k,of combination[*]);
	output;
end;
keep combination1-combination&k;
run;
%mend;

%comb(3,2)
