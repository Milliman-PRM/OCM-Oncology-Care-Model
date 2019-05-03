********************************************************************** ;
		***** C001.5p_Performance Quarter Combo.sas ***** ;
********************************************************************** ;

libname in1 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Performance\FBQ01" ; *** locale of SAS reads. *** ;
libname in2 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Performance\FBQ02" ; *** locale of SAS reads. *** ;
libname in3 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Performance\FBQ03" ; *** locale of SAS reads. *** ;
libname in4 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Performance\FBQ04" ; *** locale of SAS reads. *** ;
libname in5 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Performance\FBQ05" ; *** locale of SAS reads. *** ;
libname in6 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Performance\FBQ06" ; *** locale of SAS reads. *** ;
libname in7 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Performance\FBQ07" ; *** locale of SAS reads. *** ;
libname in8 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Performance\FBQ08" ; *** locale of SAS reads. *** ;
libname in9 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Performance\FBQ09" ; *** locale of SAS reads. *** ;

	*** locale of attribution files.  *** ;
libname att1 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP1" ; 
libname att2 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP2" ;
libname att3 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP3" ;

	*** locale of RECONCILIATION  files.  *** ;
libname rec1 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP1" ;
libname rec2 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP2" ;
libname rec3 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP3" ;

libname out 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Performance" ;

options ls=132 ps=70 obs=max  minoperator ; run ;

********************************************************************** ;
%LET VERS = B ; *** A = without current quarter bene files   B = with current quarent bene files **** ;
********************************************************************** ;
	*** Attribution File Name Macro Variables *** ;
********************************************************************** ;

***Version variables refers to recon attribution files: TU variables refers to recon episode and claims files***;
%let pp1 = 1 ;
%let version1 = TrueUp2 ;
%let tu1 = 2 ; *** blank for initial, 1 for true-up 1, 2 for true-up 2 *** ;

%let pp2 = 2 ;
%let version2 = TrueUp1 ;
%let tu2 = 1 ; *** blank for initial, 1 for true-up 1, 2 for true-up 2 *** ;

%let pp3 = 3 ;
%let version3 = Initial ;
%let tu3 =  ; *** blank for initial, 1 for true-up 1, 2 for true-up 2 *** ;

RUN ;

%let trueup = 0 ; *** 1 when need to compare true-up file to prior version, else 0 (as in recon processing) *** ;
********************************************************************** ;
*** Qtrs with bene files available for processing *** ;
%MACRO QTRS ; 
Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9
%MEND QTRS ;
********************************************************************** ;
*** There should be a variable for each quarter available.  However, these flags are used
    solely for identifying whether we have claims in these quarters or not (for stacking) *** ;
%MACRO CQTRS ; 
C1 C2 C3 C4 C5 C6 C7 C8 C9
%MEND CQTRS ;
********************************************************************** ;
*** ONE FOR EACH AVAILABLE QUARTER AFTER Q01 *** ;
		%MACRO INTERVALS ; 
		I2 = 3 ; I3 = 6 ; I4 = 9 ; I5 = 12 ; I6 = 15 ; I7 = 18 ; I8 = 21 ; I9 = 24 ;
		%MEND INTERVALS ;
		%MACRO INVS ; 
		I2-I9 
		%MEND INVS ;
		%MACRO QIS_SETUP ; 
		V2 = 2 ; V3 = 3 ;  V4 = 4 ; V5 = 5 ; V6 = 6 ; v7 = 7 ; v8 = 8 ; v9 = 9 ;
		%MEND ;
		%MACRO QIS ;
		V2-V9 ;
		%MEND QIS ;
RUN ;

********************************************************************** ;
********************************************************************** ;
********************************************************************** ;
********************************************************************** ;
%macro clmpull_a(fn,clm) ;

proc sort data=in4.&fn._1 out=file1 ; by bene_id &clm. ;
proc sort data=in5.&fn._2 out=file2 ; by bene_id &clm. ;
proc sort data=in6.&fn._3 out=file3 ; by bene_id &clm. ;
proc sort data=in7.&fn._4 out=file4 ; by bene_id &clm. ;
proc sort data=in8.&fn._5 out=file5 ; by bene_id &clm. ;
proc sort data=in9.&fn._6 out=file6 ; by bene_id &clm. ;
proc sort data=in9.&fn._7 out=file7 ; by bene_id &clm. ;
proc sort data=in9.&fn._8 out=file8 ; by bene_id &clm. ;
proc sort data=in9.&fn._9 out=file9 ; by bene_id &clm. ;

DATA STEP1 ;
	set file1(in=a) file2(in=b) file3(in=c) file4(in=d) file5(in=E) file6(in=f) file7(in=g) file8(in=h) file9(in=i); 
	if a then qtr = 1 ;
	else if b then qtr = 2 ;
	else if c then qtr = 3 ;
	else if d then qtr = 4 ;
	else if e then qtr = 5 ;
	else if f then qtr = 6 ;
	else if g then qtr = 7 ;
	else if h then qtr = 8 ;
	else if i then qtr = 9 ;
proc sort data=step1 ; by bene_id &clm. descending qtr ;
proc sort data=step1 out=uniq(keep = bene_id &clm.  qtr) nodupkey ; by bene_id &clm.  qtr ;

proc sort data=step1 ; by bene_id &clm. qtr ;

data step1a ;
	set uniq ; by bene_id &clm.  qtr ;
	if last.&clm.  ;

data in9.&fn. ;
	merge step1(in=a) step1a(in=b) ; by bene_id &clm.  qtr ;
	if a and b ;

%mend clmpull_A ;

%macro clm_pull(infile,infile2,dt) ;

data rec;
	set 
	%if "&dsid." = "290_50202" %then %do ;
		att1.&infile.&tu1._&dsid.
		att1.&infile.&tu1._567_50200
		att1.&infile.&tu1._568_50201 
	%end ;
	%else %do ;
		att1.&infile.&tu1._&dsid. 
	%end ;
	att2.&infile.&tu2._&dsid. 	
	att3.&infile.&tu3._&dsid. 	
	;
run ;

PROC SORT DATA=rec ; BY EP_ID ;

data &infile.2_chk ;
	merge rec(in=a) recon_overlap2(in=b) ; by ep_id ;
	if a and b ;
	*if EP_BEG_A LE &dt. LE EP_END_A ;

PROC SORT DATA=&INFILE.2_chk(keep=ep_id bene_id clm_id) nodupkey ; BY EP_ID BENE_ID CLM_ID ;
PROC SORT DATA=&INFILE.2_CHK OUT=&INFILE.2_PERF_CHK(KEEP = BENE_ID CLM_ID) NODUPKEY  ; BY BENE_ID CLM_ID ;


	proc sql ;
		create table &infile._chk as
		select distinct a.bene_id, a.clm_id 
		from in9.&infile2._&dsid. as a full join &INFILE.2_PERF_CHK AS B
		on a.bene_id=b.bene_id AND A.CLM_ID = B.CLM_ID
		WHERE B.CLM_ID IS NULL  ;
	quit ;

%mend clm_pull ;

%MACRO LINE_PULL(infile,infile2,hdr) ;

proc sort data=in9.&infile2._&dsid. out = lines ; by bene_id clm_id ;
data &infile. ;
	merge lines(in=a) &hdr._chk(in=b) ; by bene_id clm_id  ;
	if a and b ;


data rec1;
	set 
	%if "&dsid." = "290_50202" %then %do ;
		att1.&infile.&tu1._&dsid.
		att1.&infile.&tu1._567_50200
		att1.&infile.&tu1._568_50201 
	%end ;
	%else %do ;
		att1.&infile.&tu1._&dsid. 
	%end ;
	att2.&infile.&tu2._&dsid. 	
	att3.&infile.&tu3._&dsid. 	
	;
run ;

PROC SORT DATA=rec1 ; BY EP_ID ;

data &infile.2 ;
	merge rec1(in=a) recon_overlap2(in=b) ; by ep_id ;
	if a and b ;

data out.&infile2._wrecon_&dsid. ;
	set &infile. &infile.2 ;

%mend line_pull ;
********************************************************************** ;
********************************************************************** ;

%macro epi(dsid,att_avail) ;

%clmpull_a(outval_&dsid.,clm_id) ; run ;

*%clm_pull(outhdr,outhdr,FROM_DT) ; run ;

*%LINE_PULL(outval,outval,outHDR) ; run ;

%mend epi ;
********************************************************************** ;
********************************************************************** ;
****** %macro epi(dsid,ATT_AVAIL) ;
****** ATT_AVAIL: 1 = Using an attribution TRUE-UP file.  0 = Not using an attribution TRUE-UP file. 
********************************************************************** ;
********************************************************************** ;

%epi(255_50179,0) ; run ;
%epi(257_50195,0) ; run ;
%epi(278_50193,0) ; run ;
%epi(280_50115,0) ; run ;
%epi(290_50202,0) ; run ;
%epi(396_50258,0) ; run ;
%epi(401_50228,0) ; run ; 
%epi(459_50243,0) ; run ;
%epi(468_50227,0) ; run ; 
%epi(480_50185,0) ; run ;
%epi(523_50330,0) ; run ;
%epi(137_50136,0) ; run ; 

