*********************************************************************** ;
********************** MEOS_ATTRIBUTION.SAS *************************** ;
**** MEOS will be attributed as follows:
	Due to the overlapping nature of the MEOS billing windows, at any given time there are up to 3 different performance periods a MEOs claim could be in reference to. But there is no place on the claim that signify which PP1 the MEOS claims are applied to. 
So to determine a valid MEOS claims, the OCM teams verifies three things have occurred:
	1. Verify there is a valid episode for the beneficiary 
	2. The Valid episode is attributed to the billing TIN 
	3. All other billing MEOS guideline have been followed. 

This is for demonstration purposed only. Final outcome may be different. 
Using the dates you provided, we are going to assume that we are reviewing data from the Initial Reconciliation of PP2. The MEOS Claims for DOS 2/1/17, 3/1/17, 4/1/17 5/1/17, 6/1/17, 7/1/17 could be for episodes in PP1, PP2 or PP3. 
Step 1. Did the beneficiary have an episode in PP1? If Yes, move to Step 2. If No, as is the case in your example, we will look for an episode in PP2 and indeed there is an valid episode so we can now move to Step 2. 
Step 2. Was the valid episode attributed to the billing TIN? If yes, then we go to Step 3. So we are going to assume the answer is yes and go to step 3. 
Step 3. Determine that all other MEOS billing criteria have been met. 

Is some cases, the MEOS claim is found to meet all the criteria but it is the 7th claim or high, then the methodology goes back to step 1 and looks for a valid episode in another performance period unless it is not possible that it could have an episode in another Performance Period. 

So if the beneficiary had a PP2 Episode and was attributed to your TIN and all criteria was met, then MEOS claims for 2/1/17, 3/1/17, 4/1/17 5/1/17, 6/1/17, 7/1/17 would be for PP2. 
If the patient triggered another episode on 7/2/17, the next MEOS that could be billed would be on 8/1/17 because two MEOS claims can not be billed for the same beneficiary in the same month.  *** ;
*********************************************************************** ;
 
%macro MEOS(infile,inepi,outPB,outMEOS) ;

data MEOS_pre &outPB. ;
	set &infile. ;
	IF HCPCS_CD = "G9678" then output MEOS_pre ;
	else output &outPB. ;
run;

*Create a unique index number for each MEOS claim;
PROC SORT DATA=MEOS_pre ; BY BENE_ID CLM_ID THRU_DT LINE_NUM ; run;
data MEOS;
	set MEOS_pre;
	by BENE_ID;
	retain MEOS_IDX;
	if first.BENE_ID then MEOS_IDX=1;
	else MEOS_IDX=MEOS_IDX+1;

	IDX = bene_id || MEOS_IDX ; 
	drop ep_id ;
run;

*Create a unique index number for each episode in order of date;
proc sort data=&inepi. out=MEOS_epis_pre; by BENE_ID EP_BEG EP_END ; run;
data MEOS_epis;
	set MEOS_epis_pre;
	by BENE_ID;
	retain MEOS_EPI_IDX;
	if first.BENE_ID then MEOS_EPI_IDX=1;
	else MEOS_EPI_IDX=MEOS_EPI_IDX+1;
run;

*** Join all potential meos claims to episode using 90 day window before and after *** ;
proc sql ;
	create table MEOS0 as
	select a.ep_id, a.ep_beg, a.ep_end, a.DOD , a.epi_tax_id, b.*, a.MEOS_EPI_IDX
	from MEOS_epis as a, MEOS as b 
	where a.bene_id = b.bene_id and
		  a.ep_beg-90 le EXPNSDT1 le a.ep_end+90 ;
quit ;

proc sort data=MEOS0; by bene_id MEOS_IDX MEOS_EPI_IDX; run;

data MEOS1;
	set MEOS0;
	by bene_id MEOS_IDX ;

	retain MEOS_EPI;

	if first.MEOS_IDX then MEOS_EPI=1;
	else MEOS_EPI=MEOS_EPI+1;
run;

proc sort data=MEOS1; by bene_id MEOS_EPI_IDX TAX_NUM MEOS_IDX ; run;
 
data MEOS2;
	set MEOS1;
	by bene_id MEOS_EPI_IDX TAX_NUM;

	retain TIN_MEOS_COUNT;

	if first.TAX_NUM then TIN_MEOS_COUNT=1;
	else TIN_MEOS_COUNT=TIN_MEOS_COUNT+1;
run;

proc sql;
	create table MEOS3 as
	select bene_id, MEOS_IDX, count(*) as MEOS_FREQ
	from MEOS2
	group by bene_id, MEOS_IDX;
quit;

proc sql;
	create table MEOS4 as
	select a.*, b.MEOS_FREQ
	from MEOS2 as a left join MEOS3 as b
	on a.bene_id=b.bene_id and a.MEOS_IDX=b.MEOS_IDX;
quit;

data MEOS_EPI1 MEOS5;
	set MEOS4;

	if MEOS_EPI_IDX=1 then do;
		if MEOS_EPI=1 then do;
			if MEOS_FREQ=1 OR TIN_MEOS_COUNT<=6 then output MEOS_EPI1;
		end;
	end;
	else output MEOS5;
run;

proc sql;
	create table MEOS6 as
	select a.*
	from MEOS5 as a
	where a.IDX not in (select distinct IDX from MEOS_EPI1);
quit;

proc sort data=MEOS6; by bene_id MEOS_EPI_IDX TAX_NUM MEOS_IDX ; run;

data MEOS7;
	set MEOS6 (drop=TIN_MEOS_COUNT MEOS_FREQ);
	by bene_id MEOS_EPI_IDX TAX_NUM;

	retain TIN_MEOS_COUNT;

	if first.TAX_NUM then TIN_MEOS_COUNT=1;
	else TIN_MEOS_COUNT=TIN_MEOS_COUNT+1;
run;

proc sql;
	create table MEOS8 as
	select bene_id, MEOS_IDX, count(*) as MEOS_FREQ
	from MEOS7
	group by bene_id, MEOS_IDX;
quit;

proc sql;
	create table MEOS9 as
	select a.*, b.MEOS_FREQ
	from MEOS7 as a left join MEOS8 as b
	on a.bene_id=b.bene_id and a.MEOS_IDX=b.MEOS_IDX;
quit;

data MEOS_EPI2 MEOS10;
	set MEOS9;

	if MEOS_EPI_IDX=2 then do;
		if MEOS_FREQ=1 OR TIN_MEOS_COUNT<=6 then output MEOS_EPI2;
	end;
	else output MEOS10;
run;

proc sql;
	create table MEOS11 as
	select a.*
	from MEOS10 as a
	where a.IDX not in (select distinct IDX from MEOS_EPI2);
quit;

proc sort data=MEOS11; by bene_id MEOS_EPI_IDX TAX_NUM MEOS_IDX ; run;

data MEOS12;
	set MEOS11 (drop=TIN_MEOS_COUNT MEOS_FREQ);
	by bene_id MEOS_EPI_IDX TAX_NUM;

	retain TIN_MEOS_COUNT;

	if first.TAX_NUM then TIN_MEOS_COUNT=1;
	else TIN_MEOS_COUNT=TIN_MEOS_COUNT+1;
run;

proc sql;
	create table MEOS13 as
	select bene_id, MEOS_IDX, count(*) as MEOS_FREQ
	from MEOS12
	group by bene_id, MEOS_IDX;
quit;

proc sql;
	create table MEOS14 as
	select a.*, b.MEOS_FREQ
	from MEOS12 as a left join MEOS13 as b
	on a.bene_id=b.bene_id and a.MEOS_IDX=b.MEOS_IDX;
quit;

data MEOS_EPI3 MEOS15;
	set MEOS14;

	if MEOS_EPI_IDX=3 then do;
		if MEOS_FREQ=1 OR TIN_MEOS_COUNT<=6 then output MEOS_EPI3;
	end;
	else output MEOS15;
run;

proc sql;
	create table MEOS16 as
	select a.*
	from MEOS15 as a
	where a.IDX not in (select distinct IDX from MEOS_EPI3);
quit;

proc sort data=MEOS16; by bene_id MEOS_EPI_IDX TAX_NUM MEOS_IDX ; run;

data MEOS17;
	set MEOS16 (drop=TIN_MEOS_COUNT MEOS_FREQ);
	by bene_id MEOS_EPI_IDX TAX_NUM;

	retain TIN_MEOS_COUNT;

	if first.TAX_NUM then TIN_MEOS_COUNT=1;
	else TIN_MEOS_COUNT=TIN_MEOS_COUNT+1;
run;

proc sql;
	create table MEOS18 as
	select bene_id, MEOS_IDX, count(*) as MEOS_FREQ
	from MEOS17
	group by bene_id, MEOS_IDX;
quit;

proc sql;
	create table MEOS19 as
	select a.*, b.MEOS_FREQ
	from MEOS17 as a left join MEOS18 as b
	on a.bene_id=b.bene_id and a.MEOS_IDX=b.MEOS_IDX;
quit;

data MEOS_EPI4 MEOS20;
	set MEOS19;

	if MEOS_EPI_IDX=4 then do;
		if MEOS_FREQ=1 OR TIN_MEOS_COUNT<=6 then output MEOS_EPI4;
	end;
	else output MEOS20;
run;

proc sql;
	create table MEOS21 as
	select a.*
	from MEOS20 as a
	where a.IDX not in (select distinct IDX from MEOS_EPI4);
quit;

proc sort data=MEOS21; by bene_id MEOS_EPI_IDX TAX_NUM MEOS_IDX ; run;

data MEOS22;
	set MEOS21 (drop=TIN_MEOS_COUNT MEOS_FREQ);
	by bene_id MEOS_EPI_IDX TAX_NUM;

	retain TIN_MEOS_COUNT;

	if first.TAX_NUM then TIN_MEOS_COUNT=1;
	else TIN_MEOS_COUNT=TIN_MEOS_COUNT+1;
run;

proc sql;
	create table MEOS23 as
	select bene_id, MEOS_IDX, count(*) as MEOS_FREQ
	from MEOS22
	group by bene_id, MEOS_IDX;
quit;

proc sql;
	create table MEOS24 as
	select a.*, b.MEOS_FREQ
	from MEOS22 as a left join MEOS23 as b
	on a.bene_id=b.bene_id and a.MEOS_IDX=b.MEOS_IDX;
quit;

data MEOS_EPI5 MEOS25;
	set MEOS24;

	if MEOS_EPI_IDX=5 then do;
		if MEOS_FREQ=1 OR TIN_MEOS_COUNT<=6 then output MEOS_EPI5;
	end;
	else output MEOS25;
run;

proc sql;
	create table MEOS26 as
	select a.*
	from MEOS25 as a
	where a.IDX not in (select distinct IDX from MEOS_EPI5);
quit;

proc sort data=MEOS26; by bene_id MEOS_EPI_IDX TAX_NUM MEOS_IDX ; run;

data MEOS27;
	set MEOS26 (drop=TIN_MEOS_COUNT MEOS_FREQ);
	by bene_id MEOS_EPI_IDX TAX_NUM;

	retain TIN_MEOS_COUNT;

	if first.TAX_NUM then TIN_MEOS_COUNT=1;
	else TIN_MEOS_COUNT=TIN_MEOS_COUNT+1;
run;

proc sql;
	create table MEOS28 as
	select bene_id, MEOS_IDX, count(*) as MEOS_FREQ
	from MEOS27
	group by bene_id, MEOS_IDX;
quit;

proc sql;
	create table MEOS29 as
	select a.*, b.MEOS_FREQ
	from MEOS27 as a left join MEOS28 as b
	on a.bene_id=b.bene_id and a.MEOS_IDX=b.MEOS_IDX;
quit;

data MEOS_EPI6 MEOS30;
	set MEOS29;

	if MEOS_EPI_IDX=6 then do;
		if MEOS_FREQ=1 OR TIN_MEOS_COUNT<=6 then output MEOS_EPI6;
	end;
	else output MEOS30;
run;

proc sql;
	create table MEOS31 as
	select a.*
	from MEOS30 as a
	where a.IDX not in (select distinct IDX from MEOS_EPI6);
quit;

proc sort data=MEOS31; by bene_id MEOS_EPI_IDX TAX_NUM MEOS_IDX ; run;

data MEOS32;
	set MEOS31 (drop=TIN_MEOS_COUNT MEOS_FREQ);
	by bene_id MEOS_EPI_IDX TAX_NUM;

	retain TIN_MEOS_COUNT;

	if first.TAX_NUM then TIN_MEOS_COUNT=1;
	else TIN_MEOS_COUNT=TIN_MEOS_COUNT+1;
run;

proc sql;
	create table MEOS33 as
	select bene_id, MEOS_IDX, count(*) as MEOS_FREQ
	from MEOS32
	group by bene_id, MEOS_IDX;
quit;

proc sql;
	create table MEOS34 as
	select a.*, b.MEOS_FREQ
	from MEOS32 as a left join MEOS33 as b
	on a.bene_id=b.bene_id and a.MEOS_IDX=b.MEOS_IDX;
quit;

data MEOS_EPI7 MEOS35;
	set MEOS34;

	if MEOS_EPI_IDX=7 then do;
		if MEOS_FREQ=1 OR TIN_MEOS_COUNT<=6 then output MEOS_EPI7;
	end;
	else output MEOS35;
run;

proc sql;
	create table MEOS36 as
	select a.*
	from MEOS35 as a
	where a.IDX not in (select distinct IDX from MEOS_EPI7);
quit;

proc sort data=MEOS36; by bene_id MEOS_EPI_IDX TAX_NUM MEOS_IDX ; run;

data MEOS37;
	set MEOS36 (drop=TIN_MEOS_COUNT MEOS_FREQ);
	by bene_id MEOS_EPI_IDX TAX_NUM;

	retain TIN_MEOS_COUNT;

	if first.TAX_NUM then TIN_MEOS_COUNT=1;
	else TIN_MEOS_COUNT=TIN_MEOS_COUNT+1;
run;

proc sql;
	create table MEOS38 as
	select bene_id, MEOS_IDX, count(*) as MEOS_FREQ
	from MEOS37
	group by bene_id, MEOS_IDX;
quit;

proc sql;
	create table MEOS39 as
	select a.*, b.MEOS_FREQ
	from MEOS37 as a left join MEOS38 as b
	on a.bene_id=b.bene_id and a.MEOS_IDX=b.MEOS_IDX;
quit;

data MEOS_EPI8 MEOS40;
	set MEOS39;

	if MEOS_EPI_IDX=8 then do;
		if MEOS_FREQ=1 OR TIN_MEOS_COUNT<=6 then output MEOS_EPI8;
	end;
	else output MEOS40;
run;

proc sql;
	create table MEOS41 as
	select a.*
	from MEOS40 as a
	where a.IDX not in (select distinct IDX from MEOS_EPI8);
quit;

proc sort data=MEOS41; by bene_id MEOS_EPI_IDX TAX_NUM MEOS_IDX ; run;

data MEOS42;
	set MEOS41 (drop=TIN_MEOS_COUNT MEOS_FREQ);
	by bene_id MEOS_EPI_IDX TAX_NUM;

	retain TIN_MEOS_COUNT;

	if first.TAX_NUM then TIN_MEOS_COUNT=1;
	else TIN_MEOS_COUNT=TIN_MEOS_COUNT+1;
run;

proc sql;
	create table MEOS43 as
	select bene_id, MEOS_IDX, count(*) as MEOS_FREQ
	from MEOS42
	group by bene_id, MEOS_IDX;
quit;

proc sql;
	create table MEOS44 as
	select a.*, b.MEOS_FREQ
	from MEOS42 as a left join MEOS43 as b
	on a.bene_id=b.bene_id and a.MEOS_IDX=b.MEOS_IDX;
quit;

data MEOS_EPI9 MEOS45;
	set MEOS44;

	if MEOS_EPI_IDX=9 then do;
		if MEOS_FREQ=1 OR TIN_MEOS_COUNT<=6 then output MEOS_EPI9;
	end;
	else output MEOS45;
run;


proc sql;
	create table MEOS_EPI10 as
	select a.*
	from MEOS45 as a
	where a.IDX not in (select distinct IDX from MEOS_EPI9);
quit;


proc sql;
	create table MEOS_NOATT as
	select a.*
	from MEOS as a 
	where a.IDX not in (select distinct IDX from MEOS0);
quit;
	

DATA &outMEOS. ;
	SET MEOS_EPI1(IN=A) MEOS_EPI2(IN=A) MEOS_EPI3(IN=A) 
		MEOS_EPI4(IN=A) MEOS_EPI5(IN=A) MEOS_EPI6(IN=A)
		MEOS_EPI7(IN=A) MEOS_EPI8(IN=A) MEOS_EPI9(IN=A)
		MEOS_EPI10(IN=A) MEOS_NOATT(IN=B) ;
	MEOS_PAYMENT = 1 ;
	IF A THEN MEOS_ATT = 1 ;
	ELSE MEOS_ATT = 0 ;
	drop MEOS_IDX MEOS_EPI_IDX MEOS_EPI TIN_MEOS_COUNT MEOS_FREQ IDX ;
RUN ;


***Checks
	1) MEOS obs in = MEOS obs out
	2) All claims in MEOS1 gets assigned an episode
	3) Match # of observations to run with previous logic
		-Small number should switch episodes
***;

%MEND MEOS ;

