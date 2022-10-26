libname ordetail "/shared-data/orion/ordetail";
proc cimport file="/shared-data/orion/ordetail.cpt" lib=ordetail;
run;

%macro removefmt(table=);
	proc datasets lib=ordetail memtype=data;
	   modify &table;
	     attrib _all_ format=;
	run;
	quit;
%mend;

proc contents data=ordetail._all_ out=tables;
run;

proc sort nodupkey data=tables(keep=memname);
	by memname;
run;

data _null_;
	set tables;
	call execute('%removefmt(table='!!memname!!');');
run;


/* Order_item and orders is too large. Create a sample Order Items */
%let numobs=80;
proc sql;
	create table Order_Date as
	select distinct Order_Date 
	from ORDETAIL.ORDERS 
	order by Order_Date desc;
quit;

proc sql;
	create table Order_Date_max as
	select distinct Order_Date 
	from Order_Date(obs=&numobs); 
quit;

proc sql;
	create table Order_ID_sample as
	select distinct Order_ID
	from ORDETAIL.ORDERS
	where Order_Date in (select distinct Order_Date from Order_Date_max);
quit;

proc sql;
	delete from ORDETAIL.ORDERS 
	where Order_ID not in (select Order_ID from Order_ID_sample);
quit;
data ORDETAIL.ORDERS;
	set ORDETAIL.ORDERS;
run; 

proc sql;
	delete from ORDETAIL.ORDER_ITEM
	where Order_ID not in (select Order_ID from Order_ID_sample);
quit;
data ORDETAIL.ORDER_ITEM;
	set ORDETAIL.ORDER_ITEM;
run; 


