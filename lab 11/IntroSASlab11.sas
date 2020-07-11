libname lab11 '/folders/myfolders/SAS_eng2020/lab11';
option mprint;

/*
SAS macro programming - introduction:
In SAS there are tasks which are very repetitive and can be automated. We use macro programming for this purpose.
Macros and macro statements are executed before compilation phase in SAS by macro processor.

%LET statement - allows to create/modify macro variable (names are case insensitive), e.g.:
%LET A=5;
%LET b=some text;
%LET A=6;

To get the value of macro variable, we write & right before the name of macro variable, e.g.:

data test;
d=&a;
run;

If we execute all LET statements and above DATA STEP, we will obtain data set with d=6.
Note 1: expressions like: &macro_name are resolved with the highest priority in selected code fragments.
Note 2: macro variables can contain only text (but they are not necessarily interpreted as character variables in DATA STEPs).

It is possible to print directly any text in log with %PUT statement, e.g.:
%PUT A;		* prints in log 'A';
%PUT &A;	* prints value of A macrovariable, i.e. '6' (see Note 1 above);

%LET A=B;
%PUT &A;	* prints 'B';
%LET A=&B;
%PUT &A;	* prints 'some text' (see Note 1 above);

It is possible to create macro variables which names are dependent of other macro variable:
%LET C=1;
%LET A&C=2;		* creates macro variable A1 equal '2' ;

To get the value of A1 without hardcoding, you have to write:
&&A&C
Explanation:
0) &A&C would be resolved to: 'some text1', because &A == 'some text', &C == '1'
1) &&A&C is first resolved to &A1 (&'s are removed and if there it is a single & before some correct macro variable name,
it is replaced by the value of that macro variable),
2) &A1 is then resolved to '2'.

Note 3: '.' indicates the end of macro variable name in expressions starting with '&', e.g.:
%let lib=work;
%let table=test;

data &lib..&table; 		* it is resolved to data work.test; *   data &lib.&table;* would resolve to data worktest;
a=1;
run;
*/

/*
SAS macros - introduction:


Macro definition syntax:

%macro macro_name(<arguments_list>);
<macro code>
%mend;

List of macro arguments can be empty or it can contain several variables, e.g.
%macro mymacro1();
<macro code>
%mend;

%macro mymacro2(arg1,arg2);
<macro code>
%mend;

It is possible to assign default values to macro input arguments:
%macro mymacro3(arg1=1,arg2=,arg3);
<macro code>
%mend;

In above example, arg1 has default value 1, arg2 and arg3 both have default value empty. Macro will execute 
regardless the values of arguments.

Macro execution syntax (note: ';' sign is not needed):
%macro_name(<argument_i=value_i>)

Examples (for above macros):
%mymacro1()
%mymacro2(arg1=1,arg2=some text)
%mymacro2(1,some text)
%mymacro3(arg3=5) - equivalent to: %mymacro3(1,,5)
%mymacro3(arg1=2) - equivalent to: %mymacro3(2,,)
*/

/* SAS macros - loops - part 1
Loops and conditional expressions can be used only inside the macros.
%DO loop syntax (similar to syntax of DO loop in DATA STEP with few differences):

%DO iterator_name=start_iter %TO end_iter <%BY step_size>;
	<code>
%END;

start_iter - integer / macro expression resolving to integer
end_iter - integer / macro expression resolving to integer
iterator_name - name of created macro variable, which is used as an iterator of %DO loop 
step_size - integer (optional with %BY)

Examples:
%macro test();
	%do i=1 %to 5;
		%put i=&i;
	%end;
%mend;

%test()

%macro test();
%let a=1;
%let b=5;
	%do i=&a %to &b;
		%put i=&i;
	%end;
%mend;

%test()



*/



/*Exercise 11.1*/

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

%create(ab,4,5,7)

/* Macro functions in SAS
(full list here:  https://documentation.sas.com/?docsetId=mcrolref&docsetTarget=p0a17zv6igdg7jn1e7r6sm0l0gtk.htm&docsetVersion=9.4&locale=en)
%SCAN(text,n) - returns n-th word in a given text, it is also possible to define delimiters differently, 
	see https://documentation.sas.com/?docsetId=mcrolref&docsetTarget=p1nhhymw6gxixvn1johcfl6kaygw.htm&docsetVersion=9.4&locale=en
%SUBSTR(text,start,length) - returns substring of a given text, starting at index start (numbering starts from 1) and of given length,
	more details here: https://documentation.sas.com/?docsetId=mcrolref&docsetTarget=n0nq1hkovbu54en1h78i6ci7gz51.htm&docsetVersion=9.4&locale=en
%LENGTH(text) - returns number of characters in a given text
%INDEX(text, string) - searches text for the first occurrence of string and returns the position of its first character. 
	If string is not found, the function returns 0
	see: https://documentation.sas.com/?docsetId=mcrolref&docsetTarget=p1oqafzmrka91un13k8xwap0xv47.htm&docsetVersion=9.4&locale=en
See also definitions of %QSCAN, %QSUBSTR in above links, they can be useful to solve some of the exercises.

Examples:
%SCAN(some text,1) 			*returns 'some';
%SUBSTR(some text,2,4)		*returns 'ome ';
%LENGTH(some text)			*returns '9';
%INDEX(some text,t)			*returns '5';

To see results in log, use %PUT statement, e.g.
%PUT %SCAN(some text,1);

%EVAL(expression) - evaluates integer arithmetic or logical expressions,
	read more here: https://documentation.sas.com/?docsetId=mcrolref&docsetTarget=n07pr39df9k7m3n1w3x1q09iewta.htm&docsetVersion=9.4&locale=en
%SYSEVALF(expression <,conversion_type>) - evaluates arithmetic and logical expressions using floating-point arithmetic,
	read more here: https://documentation.sas.com/?docsetId=mcrolref&docsetTarget=p1d9ypna2tpt16n1xam57kuffcpt.htm&docsetVersion=9.4&locale=en
%SYSFUNC(function(argument(s))<, format>) - executes SAS function or the function written by user and applies a format to the result (format is optional),
	read more here: https://documentation.sas.com/?docsetId=mcrolref&docsetTarget=p1o13d7wb2zfcnn19s5ssl2zdxvi.htm&docsetVersion=9.4&locale=en

Examples:
%LET I=5;
%EVAL(I+2)		*error;
%EVAL(&I+2)		*returns '7';
%EVAL(&I/2)		*returns '2';
%EVAL(&I+2.5)	*error - %EVAL accepts only integers;
%EVAL(&I=5)		*returns '1';
%EVAL(&I=6)		*returns '0';

%SYSEVALF(&I/2) 	*returns '2.5';
%SYSEVALF(&I+2.5)	*returns '7.5';

%SYSFUNC(substr(some text,2,4))		*returns 'ome ', note that quotes "" ('') are not needed here;
%SYSFUNC(countw(some text))			*returns '2', function COUNTW is useful to count number of words in a string;
 */

/*
Other macro loops in SAS:
%DO %WHILE - executes the code inside as long as the condition is satisfied
More here: https://documentation.sas.com/?docsetId=mcrolref&docsetTarget=p0kqh50asw98oyn18n5motyx4bpz.htm&docsetVersion=9.4&locale=en
Syntax:

%DO %WHILE(condition);
	<code>
%END;

%DO %UNTIL - executes the code inside until the condition is satisfied
More here: https://documentation.sas.com/?docsetId=mcrolref&docsetTarget=p1838snxda3yvhn1o0jg6bnv5xyw.htm&docsetVersion=9.4&locale=en
Syntax:
%DO %UNTIL(condition);
	<code>
%END;
*/

/* Macro conditional statements 

Read more here: https://documentation.sas.com/?docsetId=mcrolref&docsetTarget=n18fij8dqsue9pn1lp8436e5mvb7.htm&docsetVersion=9.4&locale=en

%IF condition %THEN statement;

%IF condition %THEN %DO;
	<code>
%END; 

%IF condition %THEN %DO;
	<code>
%END;
%ELSE %DO;
	<some other code>
%END;

Note: Condition must resolve to integer.
*/

/*Exercise 11.2*/
%macro count(set,variables,n);
%let x=%scan(&variables,1);
%let i=1;
	%do %while(&x ne );
		data _null_;
		set &set end=end_flag;
		if &x>&n then i+1;
		if end_flag then put "There are" i "observations of variable &x greater than &n";
		run;
		
		%let i=%eval(&i+1);	*(without %eval we would have i="i+1");
		%let x=%scan(&zmienne,&i);
	%end; 
%mend;

%count(a1,x1 x2,-1)

/*Exercise  11.8*/
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

/* Homework:
Exercises 11.3-11.7, 11.9
Deadline: May 31th 2020

Hint:
11.3: CALL SYMPUT can be useful - it allows to assign a value to the macro variable in DATA STEP
Example:
data a;
b=1;
run;

data _null_;
set a;
call symput('macro_var',b);
run;

In above DATA STEP new macro variable macro_var is created and its value is '1'.
Read more here:
https://documentation.sas.com/?docsetId=mcrolref&docsetTarget=p09y28i2d1kn8qn1p1icxchz37p3.htm&docsetVersion=9.4&locale=en 

SAS options for macro debugging:
option mprint;		*displays the SAS statements that are generated by macro execution;
option mlogic;		*causes the macro processor to trace its execution and to write the trace information to the SAS log;

To turn off these options, write:
option nomprint;
option nomlogic;
*/