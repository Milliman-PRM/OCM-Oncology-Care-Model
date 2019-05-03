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
libname in10 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Performance\FBQ10" ; *** locale of SAS reads. *** ;

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
%LET VERS = A ; *** A = without current quarter bene files   B = with current quarent bene files **** ;
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
Q1 Q2 Q3 Q4 Q5 Q6 Q7 Q8 Q9 Q10
%MEND QTRS ;
********************************************************************** ;
*** There should be a variable for each quarter available.  However, these flags are used
    solely for identifying whether we have claims in these quarters or not (for stacking) *** ;
%MACRO CQTRS ; 
C1 C2 C3 C4 C5 C6 C7 C8 C9 C10
%MEND CQTRS ;
********************************************************************** ;
*** ONE FOR EACH AVAILABLE QUARTER AFTER Q01 *** ;
		%MACRO INTERVALS ; 
		I2 = 3 ; I3 = 6 ; I4 = 9 ; I5 = 12 ; I6 = 15 ; I7 = 18 ; I8 = 21 ; I9 = 24 ; I10 = 27 ;
		%MEND INTERVALS ;
		%MACRO INVS ; 
		I2-I10 
		%MEND INVS ;
		%MACRO QIS_SETUP ; 
		V2 = 2 ; V3 = 3 ;  V4 = 4 ; V5 = 5 ; V6 = 6 ; v7 = 7 ; v8 = 8 ; v9 = 9 ; v10 = 10 ;
		%MEND ;
		%MACRO QIS ;
		V2-V10 ;
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
	proc sort data=in10.&fn._10 out=file10 ; by bene_id &clm. ;

	DATA STEP1 ;
		set file1(in=a) file2(in=b) file3(in=c) file4(in=d) file5(in=E) file6(in=f) file7(in=g) file8(in=h) file9(in=i) file10(in=j); 
		if a then qtr = 1 ;
		else if b then qtr = 2 ;
		else if c then qtr = 3 ;
		else if d then qtr = 4 ;
		else if e then qtr = 5 ;
		else if f then qtr = 6 ;
		else if g then qtr = 7 ;
		else if h then qtr = 8 ;
		else if i then qtr = 9 ;
		else if j then qtr = 10 ;
	proc sort data=step1 ; by bene_id &clm. descending qtr ;
	proc sort data=step1 out=uniq(keep = bene_id &clm.  qtr) nodupkey ; by bene_id &clm.  qtr ;

	proc sort data=step1 ; by bene_id &clm. qtr ;

	data step1a ;
		set uniq ; by bene_id &clm.  qtr ;
		if last.&clm.  ;

	data in10.&fn. ;
		merge step1(in=a) step1a(in=b) ; by bene_id &clm.  qtr ;
		if a and b ;

	%mend clmpull_A ;
********************************************************************** ;
********************************************************************** ;

%macro epi(dsid,att_avail) ;


************************************************************************** ;
*** Combination of Quarters. *** ;
************************************************************************** ;

proc sort data=in1.epi2_&dsid. out=epi_orig1 ; by bene_id ;

proc sort data=in2.epi_&dsid. out=epi_orig2 ; by bene_id ;

proc sort data=in3.epi_&dsid. out=epi_orig3 ; by bene_id ;

proc sort data=in4.epi_&dsid. out=epi_orig4 ; by bene_id ;

proc sort data=in5.epi_&dsid. out=epi_orig5(rename = (gender=sex)) ; by bene_id ;

proc sort data=in6.epi_&dsid. out=epi_orig6(rename = (gender=sex)) ; by bene_id ;

proc sort data=in7.epi_&dsid. out=epi_orig7(rename = (gender=sex)) ; by bene_id ;

proc sort data=in8.epi_&dsid. out=epi_orig8(rename = (gender=sex)) ; by bene_id ;

proc sort data=in9.epi_&dsid. out=epi_orig9(rename = (gender=sex)) ; by bene_id ;

%IF "&VERS." = "A" %THEN %DO ;
	data quarter10 ;
		set in10.dmehdr_&dsid._10(keep = bene_id)
			in10.hhahdr_&dsid._10(keep = bene_id)
			in10.hsphdr_&dsid._10(keep = bene_id)
			in10.iphdr_&dsid._10(keep = bene_id)
			in10.outhdr_&dsid._10(keep = bene_id)
			in10.pde_&dsid._10(keep = bene_id)
			in10.snfhdr_&dsid._10(keep = bene_id)
			in10.phyhdr_&dsid._10(keep = bene_id) ;

			proc sort data=quarter10 out=epi_orig10 nodupkey ;by bene_id ;
%END ;

%ELSE %DO ;
	proc sort data=in10.epi_&dsid. out=epi_orig10(rename = (gender=sex)) ; by bene_id ;
%end ;

data out.beneqtrs_&dsid.;
	merge epi_orig1(in=a keep=bene_id) 
		  epi_orig2(in=b keep=bene_id) 
		  epi_orig3(in=c keep=bene_id) 
		  epi_orig4(in=d keep=bene_id)
		  epi_orig5(in=e keep=bene_id)  
		  epi_orig6(in=f keep=bene_id)
		  epi_orig7(in=g keep=bene_id)
		  epi_orig8(in=h keep=bene_id)
		  epi_orig9(in=i keep=bene_id)
		  epi_orig10(in=j keep=bene_id)
;
	by bene_id ;
	q1 = 0 ; q2 = 0 ; q3 = 0 ; q4=0 ;q5=0 ; q6=0 ; q7=0 ; q8=0 ; q9=0 ; q10=0 ;
	if a then q1 = 1 ;
	if b then q2 = 1 ;
	if c then q3 = 1 ;
	if d then q4 = 1 ;
	if e then q5 = 1 ;
	if f then q6 = 1 ;
	if g then q7 = 1 ;
	if h then q8 = 1 ;
	if i then q9 = 1 ;
	if j then q10 = 1 ;

	c1 = q1 ;
	c2 = q2 ;
	c3 = q3 ;
	c4 = q4 ;
	c5 = q5 ;
	c6 = q6 ;
	c7 = q7 ;
	c8 = q8 ;
	c9 = q9 ;
	c10 = q10 ;
	if q2=1 and q1 = 0 then c1 = 1 ;
	if q3=1 and q2 = 0 then c2 = 1 ;
	if q4=1 and q3 = 0 then c3 = 1 ;
	if q5=1 and q4 = 0 then c4 = 1 ;
	if q6=1 and q5 = 0 then c5 = 1 ;
	if q7=1 and q6 = 0 then c6 = 1 ; 
	if q8=1 and q7 = 0 then c7 = 1 ;
	if q9=1 and q8 = 0 then c8 = 1 ;
	if q10=1 and q9 = 0 then c9 = 1 ;
	
run ;

proc sort data=out.beneqtrs_&dsid. ; by bene_id ;


DATA EPI_ALL (DROP = CANCER_TYPE: COMMON_CANCER:) 
	 CANCERS1 (KEEP = BENE_ID CANCER_TYPEQ01 COMMON_CANCER_TYPEQ01)  
	 CANCERS2 (KEEP = BENE_ID CANCER_TYPEQ02 COMMON_CANCER_TYPEQ02)  
	 CANCERS3 (KEEP = BENE_ID CANCER_TYPEQ03 COMMON_CANCER_TYPEQ03)  
	 CANCERS4 (KEEP = BENE_ID CANCER_TYPEQ04 COMMON_CANCER_TYPEQ04)  
	 CANCERS5 (KEEP = BENE_ID CANCER_TYPEQ05 COMMON_CANCER_TYPEQ05)  
	 CANCERS6 (KEEP = BENE_ID CANCER_TYPEQ06 COMMON_CANCER_TYPEQ06)
	 CANCERS7 (KEEP = BENE_ID CANCER_TYPEQ07 COMMON_CANCER_TYPEQ07) 
	 CANCERS8 (KEEP = BENE_ID CANCER_TYPEQ08 COMMON_CANCER_TYPEQ08) 
	 CANCERS9 (KEEP = BENE_ID CANCER_TYPEQ09 COMMON_CANCER_TYPEQ09)  
	 %if "&vers." = "B" %then %do ;
	 CANCERS10 (KEEP = BENE_ID CANCER_TYPEQ10 COMMON_CANCER_TYPEQ10)  
	 %END ;
	;
	SET EPI_ORIG1(IN=A) EPI_ORIG2(IN=B) EPI_ORIG3(IN=C) EPI_ORIG4(IN=D)
		EPI_ORIG5(IN=E) EPI_ORIG6(IN=F) EPI_ORIG7(IN=G) EPI_ORIG8(IN=H) 
		EPI_ORIG9(IN=I)
		%if "&vers." = "B" %then %do ; EPI_ORIG10(IN=J) %END ; ;  

	FORMAT COMMON_CANCER_TYPEQ01-COMMON_CANCER_TYPEQ10 CANCER_TYPEQ01-CANCER_TYPEQ10 $100. ;

	**** Note to programmer: Arrays will need to be updated to reflect availability of quarters with data files. **** ;
	ARRAY VALZ (X) A B C D E F G H I J; 
	ARRAY RS (X) RISK_SCORE_Q01-RISK_SCORE_Q10  ;
	ARRAY RA (X) RISK_ADJ_FACTORQ01-RISK_ADJ_FACTORQ10 ;
	ARRAY INF (X) INFLATION_FACTORQ01-INFLATION_FACTORQ10 ;
	ARRAY HR (X) HIGH_RISKQ01-HIGH_RISKQ10 ;
	ARRAY AG (X) AGE_CATEGORYQ01-AGE_CATEGORYQ10 ;
	ARRAY DU (X) DUALQ01-DUALQ10 ;
	ARRAY DI (X) DIEDQ01-DIEDQ10 ;
	ARRAY QST (X) QTR_START_DATEQ01-QTR_START_DATEQ10 ;
	ARRAY CAN (X) CANCER_TYPEQ01-CANCER_TYPEQ10 ;
	ARRAY CC (X) COMMON_CANCER_TYPEQ01-COMMON_CANCER_TYPEQ10 ;
	ARRAY CF (X) CANCERS1-CANCERS10 ;

	%if "&vers." = "B" %then %do ;		
		DO X = 1 TO DIM(VALZ) ;
	%END ;
	%ELSE %DO ;
		DO X = 1 TO (DIM(VALZ)-1) ;
	%END ;		
			IF VALZ=1 THEN DO ;
				RS = RISK_SCORE + 0 ;
				RA = RISK_ADJ_FACTOR ;
				INF = INFLATION_FACTOR ;
				HR = HIGH_RISK ;
				AG = AGE_CATEGORY ;
				DU = DUAL ;
				DI = DIED ;
				QST = QTR_START_DATE ;
				CAN = CANCER_TYPE ;
				CC = COMMON_CANCER_TYPE ;
			END ;
		END ;
	
PROC SORT DATA=EPI_ALL ; BY BENE_ID QTR_START_DATE;
data epi_all2 ;
	merge epi_all(in=a) out.beneqtrs_&dsid.(in=b) ; by bene_id ;
	if a and b ;

PROC SORT DATA=EPI_ALL2 ; BY BENE_ID QTR_START_DATE ;

*** I. Capture characteristics from latest available benficiary file record *** ;
DATA LATEST_AVAIL(KEEP = BENE_ID BENE_HICN FIRST_NAME LAST_NAME	DOB CHEMO_DATE SEX RACE DOD ANY_HSP_CARE);
	SET EPI_ALL2 ; BY BENE_ID ;
	IF LAST.BENE_ID ;


*** II. Capture death related values at max across quarters *** ;
PROC MEANS DATA=EPI_ALL2 NOPRINT MAX ; BY BENE_ID ;
	VAR %QTRS %CQTRS HSP_30DAYS_ALL HSP_DAYS HOSPITAL_USE INTENSIVE_CARE_UNIT CHEMOTHERAPY PART_D_MM
		RISK_SCORE_Q: RISK_ADJ_FACTORQ: INFLATION_FACTORQ: HIGH_RISKQ: AGE_CATEGORYQ: DUALQ: DIEDQ: QTR_START_DATEQ: ;
	OUTPUT OUT=MAX_VALUES (DROP = _TYPE_ _FREQ_)
		MAX() = ;


PROC SORT DATA=CANCERS1 ; BY BENE_ID ;
PROC SORT DATA=CANCERS2 ; BY BENE_ID ;
PROC SORT DATA=CANCERS3 ; BY BENE_ID ;
PROC SORT DATA=CANCERS4 ; BY BENE_ID ;
PROC SORT DATA=CANCERS5 ; BY BENE_ID ;
PROC SORT DATA=CANCERS6 ; BY BENE_ID ;
PROC SORT DATA=CANCERS7 ; BY BENE_ID ;
PROC SORT DATA=CANCERS8 ; BY BENE_ID ;
PROC SORT DATA=CANCERS9 ; BY BENE_ID ;
%if "&vers." = "B" %then %do ;
PROC SORT DATA=CANCERS10 ; BY BENE_ID ;
%end ;
DATA CANCERS ;
	MERGE CANCERS1(IN=A WHERE = (CANCER_TYPEQ01 NE "  "))
		  CANCERS2(IN=B WHERE = (CANCER_TYPEQ02 NE "  ")) 
		  CANCERS3(IN=C WHERE = (CANCER_TYPEQ03 NE "  ")) 
		  CANCERS4(IN=d WHERE = (CANCER_TYPEQ04 NE "  ")) 
		  CANCERS5(IN=E WHERE = (CANCER_TYPEQ05 NE "  "))
		  CANCERS6(IN=F WHERE = (CANCER_TYPEQ06 NE "  "))
		  CANCERS7(IN=G WHERE = (CANCER_TYPEQ07 NE "  "))  
		  CANCERS8(IN=H WHERE = (CANCER_TYPEQ08 NE "  "))  
		  CANCERS9(IN=I WHERE = (CANCER_TYPEQ09 NE "  "))  
		 %if "&vers." = "B" %then %do ;
		  CANCERS10(IN=J WHERE = (CANCER_TYPEQ10 NE "  ")) 
		 %end ;
		 ; BY BENE_ID ;
	IF A OR B OR C or d OR E OR F OR G OR H OR I %if "&vers." = "B" %then %do ;OR J %end ;;

data epi_combine BENES (KEEP = BENE_ID BENE_HICN FIRST_NAME LAST_NAME DOB %CQTRS) ;
	MERGE CANCERS(IN=A)
		  LATEST_AVAIL(IN=B)
		  MAX_VALUES(IN=C); BY BENE_ID ;
			IF A AND B AND C ;


************************************************************************************ ;
************************************************************************************ ;
***** Check Recon Episode File against true-up file. ***** ;
DATA RECON_ORIG  ;
	SET 
	%IF "&DSID." = "290_50202" %THEN %DO ;
		att1.epi&TU1._&dsid. (in=a)
		att1.EPI&TU1._567_50200 (in=a)
		att1.EPI&TU1._568_50201 (in=a)
	%END ;
	%ELSE %DO ;
		att1.EPI&TU1._&dsid. (in=a)
	%END ;
		att2.EPI&TU2._&dsid. (in=b) 
		att3.EPI&TU3._&dsid. (in=c) 
		; 

	if cancer_type in ('C47','C49') then cancer_type = 'C47 or C49';

	IF A THEN RECON_PP = 1 ;
	IF B THEN RECON_PP = 2 ;
	IF C THEN RECON_PP = 3 ;
RUN;
	


DATA ATT_TU ;
	Format MBI $11.;
	SET 
	%IF "&DSID." = "290_50202" %THEN %DO ;
		ATT1.ATT_PP&pp1.&version1._&dsid. (in=a)
		ATT1.ATT_PP&pp1.&version1._567_50200 (in=a) 
		ATT1.ATT_PP&pp1.&version1._568_50201 (in=a)
	%END ;
	%ELSE %DO ;
		ATT1.ATT_PP&pp1.&version1._&dsid. (in=a)
	%END ;
		ATT2.ATT_PP&pp2.&version2._&dsid. (in=b) 
		ATT3.ATT_PP&pp3.&version3._&dsid. (in=c)
		;

	if cancer_type_A in ('C47','C49') then cancer_type_A = 'C47 or C49';

	IF A THEN RECON_PP = 1 ;
	IF B THEN RECON_PP = 2 ;
	IF C THEN RECON_PP = 3 ;

	IF SEX = "F" THEN SEX = "2" ;
	ELSE SEX = "1" ;
RUN;

PROC SORT DATA=RECON_ORIG ; BY EP_ID RECON_PP ;
PROC SORT DATA=ATT_TU ; BY EP_ID RECON_PP ;


*** OVERLAP A,1,2 = Exact Match between Attribution and Recon Episode File *** ;
DATA DROPPEDA(DROP=CANCER_TYPE_A EP_BEG_A EP_END_A ATT_HICN) 	 
	 NEWA(DROP=CANCER_TYPE EP_BEG EP_END BENE_HICN) 
	 OVERLAPA(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID)
	 EPIA(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID)
	 CANCA(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID);
	MERGE RECON_ORIG(IN=A) ATT_TU(IN=B RENAME = (BENE_HICN = ATT_HICN)) ; BY EP_ID RECON_PP ;
	IF A AND B THEN DO ;
		IF EP_BEG NE EP_BEG_A THEN OUTPUT EPIA ;
		IF CANCER_TYPE NE CANCER_TYPE_A THEN OUTPUT CANCA ;
		OUTPUT OVERLAPA ;
	END ;
	ELSE IF A AND B=0 THEN OUTPUT DROPPEDA ;
	ELSE IF A=0 AND B THEN OUTPUT NEWA ;

	*** OVERLAP1,2,3 = Exact Match between Attribution and Recon Episode File *** ;
PROC SORT DATA=DROPPEDA ; BY BENE_ID EP_ID RECON_PP ;
DATA NEWA ; SET NEWA(RENAME = (ATT_HICN=BENE_HICN)) ;
PROC SORT DATA=NEWA ; BY BENE_ID EP_ID RECON_PP ;

DATA DROPPED1(DROP=CANCER_TYPE_A EP_BEG_A EP_END_A ATT_HICN) 	 NEW1(DROP=CANCER_TYPE EP_BEG EP_END ATT_HICN) 
	 OVERLAP1(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID)
	 EPI1(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID)
	 CANC1(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID);
	MERGE DROPPEDA(IN=A) NEWA(IN=B) ; BY BENE_ID EP_ID RECON_PP ;
	IF A AND B THEN DO ;
		ATT_HICN = BENE_HICN ;
		IF EP_BEG NE EP_BEG_A THEN OUTPUT EPI1 ;
		IF CANCER_TYPE NE CANCER_TYPE_A THEN OUTPUT CANC1 ;
		OUTPUT OVERLAP1 ;
	END ;
	ELSE IF A AND B=0 THEN OUTPUT DROPPED1 ;
	ELSE IF A=0 AND B THEN OUTPUT NEW1 ;

*** Check for HICN changes *** ;
PROC SORT DATA=DROPPED1 ; BY FIRST_NAME LAST_NAME  DOB EP_ID RECON_PP ;
PROC SORT DATA=NEW1 ; BY FIRST_NAME LAST_NAME DOB EP_ID RECON_PP ;

DATA DROPPED2(DROP=CANCER_TYPE_A EP_BEG_A ATT_HICN) NEW2 (DROP = CANCER_TYPE EP_BEG )
	 OVERLAP2(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID) 
	 EPI2(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID) 
	 CANC2(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID) ;
	 MERGE DROPPED1(IN=A) NEW1(IN=B RENAME=(BENE_HICN=ATT_HICN)) ;BY FIRST_NAME LAST_NAME  DOB EP_ID RECON_PP ;
	IF A AND B THEN DO ;
		IF EP_BEG NE EP_BEG_A THEN OUTPUT EPI2 ;
		IF CANCER_TYPE NE CANCER_TYPE_A THEN OUTPUT CANC2 ;
		OUTPUT OVERLAP2 ;
	END ;
	ELSE IF A AND B=0 THEN OUTPUT DROPPED2 ;
	ELSE IF A=0 AND B THEN DO ; BENE_HICN = ATT_HICN ; OUTPUT NEW2 ; END ;

*** Check for Episode changes *** ;
*** Overlap3,4 will indicate beneficiary has an episode in both - but episode has changed *** ;
PROC SORT DATA=DROPPED2 ; BY BENE_ID RECON_PP ;
PROC SORT DATA=NEW2 ; BY BENE_ID RECON_PP ;

DATA DROPPED3(DROP = EP_BEG_A CANCER_TYPE_A ATT_HICN) NEW3(DROP = CANCER_TYPE EP_BEG BENE_HICN)
	 OVERLAP3(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID)
	 EPI3(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID)
	 CANC3(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID);
	 MERGE DROPPED2(IN=A) NEW2(IN=B) ; BY BENE_ID RECON_PP ;
	 IF A AND B THEN DO ;
	 	ATT_HICN = BENE_HICN ;
	 	IF EP_BEG NE EP_BEG_A THEN OUTPUT EPI3 ;
		IF CANCER_TYPE NE CANCER_TYPE_A THEN OUTPUT CANC3 ;
		OUTPUT OVERLAP3 ;
	 END ;
	 ELSE IF A AND B=0 THEN OUTPUT DROPPED3 ;
	 ELSE IF A=0 AND B THEN OUTPUT NEW3 ;
RUN;


 *** Check for HICN changes *** ;
PROC SORT DATA=DROPPED3 ; BY BENE_ID RECON_PP ;
PROC SORT DATA=NEW3 ; BY BENE_ID RECON_PP ;

*** DROPPED will include final list of recon episodes with NO match in attribution file. *** ;
*** NEW will include final list of attribution files new as compared to recon file. *** ;

DATA DROPPED(DROP = EP_BEG_A CANCER_TYPE_A ATT_HICN) 
	 NEW(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID)
	 OVERLAP4(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID) 
	 EPI4(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID) 
	 CANC4(KEEP = BENE_ID BENE_HICN ATT_HICN EP_ID) ;
	 MERGE DROPPED3(IN=A) NEW3(IN=B) ; BY BENE_ID RECON_PP ;
	 IF A AND B THEN DO ;
	 	IF EP_BEG NE EP_BEG_A THEN OUTPUT EPI4 ;
		IF CANCER_TYPE NE CANCER_TYPE_A THEN OUTPUT CANC4 ;
		OUTPUT OVERLAP4 ;
	 END ;
	 ELSE IF A AND B=0 THEN OUTPUT DROPPED ;
	 ELSE IF A=0 AND B THEN OUTPUT NEW ;
RUN ;

************************************************************ ;
*** Only use latest attribution files for override. ******** ;


DATA recon ;

%IF "&ATT_AVAIL." = "1" %THEN %DO ;
	SET 
	%IF "&DSID." = "290_50202" %THEN %DO ;
		att1.ATT_PP&pp1.&version1._&dsid.(in=a)
		att1.ATT_PP&pp1.&version1._567_50200 (in=a)
		att1.ATT_PP&pp1.&version1._568_50201 (in=a)
	%END ;
	%ELSE %DO ;
		att1.ATT_PP&pp1.&version1._&dsid.(in=a)
	%END ;
		att2.ATT_pp&pp2.&version2._&dsid.(in=b) 
		att3.ATT_pp&pp3.&version3._&dsid.(in=c) 
		;

	if cancer_type_A in ('C47','C49') then cancer_type_A = 'C47 or C49';

	EP_ID_A = EP_ID ;
	end_use = ep_end_A ;

%END ;

%ELSE %DO ;
	SET 
	%IF "&DSID." = "290_50202" %THEN %DO ;
		att1.EPI&tu1._&dsid. (in=a)
		att1.EPI&tu1._567_50200 (in=a)
		att1.EPI&tu1._568_50201 (in=a)
	%END ;
	%ELSE %DO ;
		att1.EPI&tu1._&dsid. (in=a)
	%END ;
		att2.EPI&tu2._&dsid. (in=b)
		att3.EPI&tu3._&dsid. (in=c)
		;

	if cancer_type in ('C47','C49') then cancer_type = 'C47 or C49';

	EP_ID_A = EP_ID ;
	FORMAT EP_BEG_A EP_END_A END_USE MMDDYY10. ;
	EP_BEG_A = EP_BEG ;
	EP_END_A = EP_END ;
	CANCER_TYPE_A = CANCER_TYPE ;
	END_USE = EP_END ;
	IF DOD NE . THEN END_USE = DOD ;
	DROP EP_ID EP_BEG EP_END CANCER_TYPE ;
%END ;
	
	IF A THEN RECON_PP = 1 ;
	IF B THEN RECON_PP = 2 ;
	IF C THEN RECON_PP = 3 ;

	ATT_HICN = BENE_HICN ;

	FIRST_END = MDY(9,30,2016) ;
	%INTERVALS ;
	%QIS_SETUP ;

	ARRAY DTS (Z) EP_BEG_A END_USE ;
	ARRAY VARZ (Z) QS QE ;

	ARRAY IV (Y) %INVS  ;
	ARRAY VALZ (Y) %QIS ;

	DO Z = 1 TO DIM (DTS) ;
		IF DTS LE FIRST_END THEN VARZ = 1 ;
		DO Y=1 TO DIM(IV) WHILE (VARZ = .);
			IF DTS LE INTNX('MONTH',FIRST_END,IV,'E') THEN VARZ = VALZ ;
		END ;
	END ;

%IF "&ATT_AVAIL." = "1" %THEN %DO ;
	PROC SORT DATA=RECON ; BY BENE_ID ;
	PROC SORT DATA=BENES OUT=UNIQ_BEN NODUPKEY ; BY BENE_ID ;
	PROC SORT DATA=DROPPED ; BY BENE_ID ;

PROC SORT DATA=RECON_ORIG OUT=RECON_ORIG2 NODUPKEY ; BY BENE_ID ;
DATA DROP_FINAL NOB_D;
	MERGE DROPPED(IN=A) RECON_ORIG2(IN=B KEEP=BENE_HICN BENE_ID DOB) ; 
	BY BENE_ID ;
	IF A THEN OUTPUT DROP_FINAL;
	IF A AND B=0 THEN OUTPUT NOB_D ; *** SHOULD HAVE 0 RECORDS !!! *** ;

DATA RECON_P  NOB ;
	MERGE RECON(IN=A) UNIQ_BEN(IN=B KEEP=BENE_HICN BENE_ID DOB) RECON_ORIG2(IN=B KEEP=BENE_HICN BENE_ID DOB); 
	BY BENE_ID ;
	IF A AND B=0 THEN DO;
		MISS_BENEID = 1 ;
		OUTPUT NOB ; 
	END ;	
	IF A AND B THEN OUTPUT RECON_P ;
RUN;
PROC SORT DATA=RECON_ORIG2 ; BY FIRST_NAME LAST_NAME DOB ;
PROC SORT DATA=UNIQ_BEN  ; BY FIRST_NAME LAST_NAME DOB ;
PROC SORT DATA=NOB ; BY FIRST_NAME LAST_NAME DOB ;
DATA NOB2 NOB_STILL ;
	MERGE NOB(IN=A) 
		  UNIQ_BEN(IN=B KEEP=BENE_ID FIRST_NAME LAST_NAME DOB ) 
		  RECON_ORIG2(IN=B KEEP = BENE_ID FIRST_NAME LAST_NAME DOB ) ; 
	BY FIRST_NAME LAST_NAME DOB ;
	IF A AND B THEN MISS_BENEID = . ;
	IF A THEN OUTPUT NOB2 ;
	IF A AND B=0 THEN OUTPUT NOB_STILL ;
RUN;

DATA RECON ;
	SET RECON_P NOB2 ;

PROC PRINT DATA=NOB ;
TITLE "&DSID.: ATTRIBUTION EPISODES MISSING A BENE_ID" ; RUN ;
%END ;

%else %do ;
	data recon ;  set recon ; ep_id = ep_id_a ;  MISS_BENEID = . ; run;
	data drop_final; set _null_; run;
%end ;

%MACRO REATT(fn) ;
	DATA &fn. ;
		SET &fn. ;
		IF ATT_HICN = ' ' THEN ATT_HICN = BENE_HICN ;
	PROC SORT DATA=&fn. ; BY BENE_ID EP_ID ;
%MEND ;
%REATT(RECON) ; 
%REATT(OVERLAPA) ; %REATT(OVERLAP1) ; %REATT(OVERLAP2) ; %REATT(OVERLAP3) ; %REATT(OVERLAP4) ; 
%REATT(EPIA) ; %REATT(EPI1) ; %REATT(EPI2) ; %REATT(EPI3) ; %REATT(EPI4) ; 	
%REATT(CANCA) ; %REATT(CANC1) ; %REATT(CANC2) ; %REATT(CANC3) ; %REATT(CANC4) ; 	
%REATT(NEW) ;

DATA RECON ;
	MERGE RECON(IN=A) 
	NEW(IN=B) 
	OVERLAPA (IN=C) OVERLAP1(IN=C) OVERLAP2(IN=C)
	OVERLAP3(IN=F) OVERLAP4(IN=F)
	CANCA (IN=D) CANC1(IN=D) CANC2(IN=D) CANC3(IN=D) CANC4(IN=D)
	EPIA (IN=E) EPI1(IN=E) EPI2(IN=E) EPI3(IN=E) EPI4(IN=E) ; BY BENE_ID EP_ID ;
	IF A ;
	IF A AND B THEN NEW_ATT = 1 ; ELSE NEW_ATT =  0 ;
	IF A AND C THEN EM = 1 ; ELSE EM=0 ;
	IF A AND F THEN DO ;
		OL_CHECK = 1 ;
	END ;
	ATT_CANC_MATCH_CMS = D ;
	ATT_EPI_PERD_MATCH_CMS = E ;
	if new_att = 1 then do ;
		ATT_CANC_MATCH_CMS = 2 ;
		ATT_EPI_PERD_MATCH_CMS = 2 ;
	end ;
	IF BENE_HICN = "  " THEN BENE_HICN = ATT_HICN ;

*** Capturing DOD for attribution true-up records. *** ;
PROC SORT DATA=RECON_ORIG OUT=RO(KEEP = BENE_ID BENE_HICN DOD) ; BY BENE_ID ;
PROC MEANS DATA=RO NOPRINT MAX ; BY BENE_ID ; VAR DOD ;
	OUTPUT OUT=RO_DOD(DROP = _TYPE_ _fREQ_)
		   MAX() = DOD ;

PROC SORT DATA=RECON ; BY BENE_ID ; 
DATA RECON ;
	MERGE RECON(IN=A) RO_DOD(IN=B) ; BY BENE_ID ;
	IF A ;

DATA OUT.REC_TU_FLAGS_&DSID.(KEEP = BENE_ID BENE_HICN EP_ID IN_RECON ATT_CANC_MATCH_CMS RECON_PP ATT_EPI_PERD_MATCH_CMS);
	SET RECON ;
	IF RECON_PP in (1,2,3) THEN DO ;
		IN_RECON = 1 ;
		IF NEW_ATT = 1 THEN IN_RECON = 2 ; *** New attributed bene/episode to practice  *** ;
		IF OL_CHECK=1 THEN IN_RECON = 3 ; *** Bene in prior and current attribution, under different episodes  *** ;
	END ;


******************************************************************************************** ;
******************************************************************************************** ;
**** Check for Stacking Logic **** ;
***1.	If a reconciliation episode appears in all PQF quarterly data expected 
		(based on episode start and end date) – use PQF.
   2.	Else if beneficiary/episode appears in some BUT NOT ALL expected PDF quarterly data - 
		use the reconciliation data only.
   3.	Else if beneficiary/episode does NOT appear in PQF at all - use the reconciliation data only.
   4.	If a PP1 episode does not appear in the reconciliation data, continue to use available 
		data from PQF.  These episodes will continue to be flagged as non-attributable.
   5.	For each episode in PP1, we will set up the flag RECON_PP1_FLAG which will have values 
		1-4 that correlate with which of the above 4 steps applied.  0 would indicate that the 
		episode is not PP1.  *** ;
******************************************************************************************** ;

PROC SORT DATA=RECON ; BY BENE_ID ;
*** Note to programmer - there will need to be a separate RECON_OVERLAP for each PP reconciliation file 
	as a beneficiary will have multiple episodes as we add performance periods.  **** ;
DATA out.RECON_OVERLAP_PP1_&DSID. RECON_OVERLAP_PP2_&DSID. RECON_OVERLAP_PP3_&DSID.
	 RECON_ALONE  RECON_OVERLAP ;
	 MERGE RECON(IN=A WHERE=(MISS_BENEID NE 1)) 
		   BENES (IN=B DROP=DOB) ; BY BENE_ID ;
	IF A ;
	IF A THEN IN_RECON = 1 ;
	IF A AND NEW_ATT = 1 THEN IN_RECON = 2 ; *** New attributed bene/episode to practice  *** ;
	IF A AND OL_CHECK=1 THEN IN_RECON = 3 ; *** Bene in prior and current attribution, under different episodes  *** ;

	IF A AND B=0 AND RECON_PP in (1,2,3) THEN RECON_PP1_FLAG = 3 ; *** Use Reconciliation period data. *** ;

	*** Coded only for time periods reflected in available reconciliation claims data. *** ;
	*** Also only applies to episodes that match from current true-up to recon. *** ;
	IF A AND B AND RECON_PP = 1 THEN DO ;
		IF QS = 1 THEN DO ;
			IF C1 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF C2 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF QE = 3 AND C3 NE 1 THEN RECON_PP1_FLAG = 2 ;*** Use Reconciliation period data. *** ;
		END ;
		IF QS = 2 THEN DO ;
			IF C2 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF C3 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;		
			ELSE IF QE = 4 AND C4 NE 1 THEN RECON_PP1_FLAG = 2 ;*** Use Reconciliation period data. *** ;
		END ;
		IF QS = 3 THEN DO ;
			IF C3 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF C4 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF QE = 5 AND C5 NE 1 THEN RECON_PP1_FLAG = 2 ;*** Use Reconciliation period data. *** ;
		END ;
	END ;
	IF A AND B AND RECON_PP = 2 THEN DO ;
		IF QS = 3 THEN DO ;
			IF C3 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF C4 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF QE = 5 AND C5 NE 1 THEN RECON_PP1_FLAG = 2 ;*** Use Reconciliation period data. *** ;
		END ;
		IF QS = 4 THEN DO ;
			IF C4 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF C5 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;		
			ELSE IF QE = 6 AND C6 NE 1 THEN RECON_PP1_FLAG = 2 ;*** Use Reconciliation period data. *** ;
		END ;
		IF QS = 5 THEN DO ;
			IF C5 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF C6 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF QE = 7 AND C7 NE 1 THEN RECON_PP1_FLAG = 2 ;*** Use Reconciliation period data. *** ;
		END ;
	END ;
	IF A AND B AND RECON_PP = 3 THEN DO ;
		IF QS = 5 THEN DO ;
			IF C5 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF C6 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF QE = 7 AND C7 NE 1 THEN RECON_PP1_FLAG = 2 ;*** Use Reconciliation period data. *** ;
		END ;
		IF QS = 6 THEN DO ;
			IF C6 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF C7 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;		
			ELSE IF QE = 8 AND C8 NE 1 THEN RECON_PP1_FLAG = 2 ;*** Use Reconciliation period data. *** ;
		END ;
		IF QS = 7 THEN DO ;
			IF C7 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF C8 NE 1 THEN RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;
			ELSE IF QE = 9 AND C9 NE 1 THEN RECON_PP1_FLAG = 2 ;*** Use Reconciliation period data. *** ;
		END ;
	END ;

	IF IN_RECON = 3 THEN RECON_PP1_FLAG = 1 ;
	IF RECON_PP1_FLAG = . THEN RECON_PP1_FLAG = 1 ;  *** Use Performance period data. *** ;


	IF RECON_PP1_FLAG in (2,3) THEN OUTPUT RECON_OVERLAP ;
	IF RECON_PP1_FLAG = 3 THEN OUTPUT RECON_ALONE ;

	IF RECON_PP = 1 THEN OUTPUT out.RECON_OVERLAP_PP1_&DSID.  ;
	IF RECON_PP = 2 THEN OUTPUT RECON_OVERLAP_PP2_&DSID.  ;
	IF RECON_PP = 3 THEN OUTPUT RECON_OVERLAP_PP3_&DSID.  ;
RUN;

proc sql;
	create table RECON_OVERLAP_PP2_FIX as
	select a.*, coalesce(b.bene_hicn,'') as BENE_HICN_FIX
	from RECON_OVERLAP_PP2_&DSID. as a left join benes as b
	on a.bene_id=b.bene_id;
QUIT;

DATA out.RECON_OVERLAP_PP2_&DSID. (DROP=BENE_HICN_FIX) ;
	set RECON_OVERLAP_PP2_FIX ;
	IF BENE_HICN = '' THEN BENE_HICN = BENE_HICN_FIX ;
RUN;

proc sql;
	create table RECON_OVERLAP_PP3_FIX as
	select a.*, coalesce(b.bene_hicn,'') as BENE_HICN_FIX
	from RECON_OVERLAP_PP3_&DSID. as a left join benes as b
	on a.bene_id=b.bene_id;
QUIT;

DATA out.RECON_OVERLAP_PP3_&DSID. (DROP=BENE_HICN_FIX) ;
	set RECON_OVERLAP_PP3_FIX ;
	IF BENE_HICN = '' THEN BENE_HICN = BENE_HICN_FIX ;
RUN;

PROC SORT DATA=EPI_COMBINE ; BY BENE_ID  ;

DATA RECON_BENES ;
	SET OUT.RECON_OVERLAP_PP1_&DSID. (KEEP=BENE_ID BENE_HICN ) 
		OUT.RECON_OVERLAP_PP2_&DSID. (KEEP=BENE_ID BENE_HICN ) 
		OUT.RECON_OVERLAP_PP3_&DSID. (KEEP=BENE_ID BENE_HICN ) ;
PROC SORT DATA=RECON_BENES NODUPKEY ; BY BENE_ID ; 
RUN;

DATA OUT.EPI_COMBINE_&VERS._&DSID.;
	MERGE EPI_COMBINE(IN=A) 
		  RECON_BENES (IN=B) ;
	/*
		  out.RECON_OVERLAP_PP1_&DSID.(IN=B keep = BENE_ID EP_ID_A EP_BEG_A CANCER_TYPE_A RECON_PP1_FLAG in_recon) 
		  out.RECON_OVERLAP_PP2_&DSID.(IN=B keep = BENE_ID EP_ID_A EP_BEG_A CANCER_TYPE_A RECON_PP1_FLAG in_recon) ;
	*/
	BY BENE_ID ;
	IF A OR B ;
	IF A AND B = 0 THEN RECON_PP1_FLAG = 4 ; *** No reconciliation records available for PQF entry*** ;
RUN;

data dupl_chk ;
	set OUT.EPI_COMBINE_&VERS._&DSID. ; by bene_id ;
	if first.bene_id=0 or last.bene_id=0 then output ; run;

%if "&trueup." = "1" %then %do ;
DATA OUT.EPI_DROPPED_&VERS._&DSID. ;
	SET DROP_FINAL ;
			RECON_PP1_FLAG = 2 ; *** Use Reconciliation period data. *** ;	
			IN_RECON = 4 ; *** Episode in former attribution/recon file but dropped from current. *** ;
%end ;

*** Create BENE_ID to BENE_HICN crosswalk for merge with trigger claims **** ;
*** Note to programmer:  Will need to update file to include attribution file once we 
    need to combine the recon files with an attribution file. *** ;
PROC SORT DATA=	OUT.EPI_COMBINE_&VERS._&DSID. ; BY BENE_ID ;
PROC SORT DATA=	out.EPI_COMBINE_&VERS._&DSID. OUT=OUT.BENE_CW_&DSID.(KEEP=BENE_ID BENE_HICN) NODUPKEY ; BY BENE_ID BENE_HICN ;

******************************************************* ;
***** Consolidating claims files ********************** ;
***** Capture claim from latest quarter provided. ***** ;
******************************************************* ;

	*** Pulling unique claims for beneficiaries *** ;
%IF "&VERS." = "A" %THEN %DO ;
			%clmpull_a(dmehdr_&dsid.,clm_id) ; run ;
			%clmpull_a(dmeline_&dsid.,clm_id) ; run ;
			%clmpull_a(hhahdr_&dsid.,clm_id) ; run ;
			%clmpull_a(hharev_&dsid.,clm_id) ; run ;
			%clmpull_a(hsphdr_&dsid.,clm_id) ; run ;
			%clmpull_a(hsprev_&dsid.,clm_id) ; run ;
			%clmpull_a(iphdr_&dsid.,clm_id) ; run ;
			%clmpull_a(inprev_&dsid.,clm_id) ; run ;
			%clmpull_a(inpval_&dsid.,clm_id) ; run ;
			%clmpull_a(outhdr_&dsid.,clm_id) ; run ;
			%clmpull_a(outrev_&dsid.,clm_id) ; run ;
			%clmpull_a(outval_&dsid.,clm_id) ; run ;
			%clmpull_a(snfhdr_&dsid.,clm_id) ; run ;
			%clmpull_a(snfrev_&dsid.,clm_id) ; run ;
			%clmpull_a(phyhdr_&dsid.,clm_id) ; run ;
			%clmpull_a(phyline_&dsid.,clm_id) ; run ;
			%clmpull_a(pde_&dsid.,pde_id) ; run ;
%END ;
********************************************************************************************** ;
********************************************************************************************** ;
			************* Screening Claims in Stacking Logic ********************** ;
********************************************************************************************** ;
********************************************************************************************** ;


**** Step 1: Remove performance period data for episodes where we default to claims provided in recon data **** ;
	**** Based on Recon Date screen logic applied for PP1,PP2 - will need to be updated for PP3 **** ;

*** Note to programmer - there will need to be a separate SQL join for each reconciliation file as a beneficiary will
	have multiple episodes as we add performance periods.  **** ;

data rchk1 rchk2 rchk3 ;
	set recon_overlap ;
	if recon_pp = 1 then output rchk1 ;
	if recon_pp = 2 then output rchk2 ;
	if recon_pp = 3 then output rchk3 ;
run; 

data recon_overlap2(keep=ep_id ep_beg_a ep_end_a) ;
	set RECON_OVERLAP DROP_FINAL ;
	ep_id = ep_id_a ;
proc sort data=recon_overlap2 nodupkey ; by ep_id ;
run;

data rec ;
	set 
	%if "&dsid." = "290_50202" %then %do ; 
		att1.pde&tu1._&dsid. 
		att1.pde&tu1._567_50200
		att1.pde&tu1._568_50201 
	%end ;
	%else %do ;
		att1.pde&tu1._&dsid.
	%end;
    att2.pde&tu2._&dsid.
    att3.pde&tu3._&dsid.
	;
run ;

proc sort data=rec ; by ep_id ;
data pde2 ;
	merge rec(in=a) recon_overlap2(in=b) ; by ep_id ;
	if a and b ;

	proc sort data=pde2 out=pde_chk(keep = bene_id pde_id) nodupkey ; by bene_id pde_id ;

	proc sql ;
		create table pde1 as
		select a.* 
		from in9.pde_&dsid. as a full join pde_chk AS B
		on a.bene_id=b.bene_id and a.pde_id=b.pde_id
		WHERE B.pde_ID IS NULL ;
	quit ;


data out.pde_wrecon_&dsid. ;
	set pde1 pde2 ;

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
		from in10.&infile2._&dsid. as a full join &INFILE.2_PERF_CHK AS B
		on a.bene_id=b.bene_id AND A.CLM_ID = B.CLM_ID
		WHERE B.CLM_ID IS NULL  ;
	quit ;

%mend clm_pull ;


**** Date screens are applied on these files.  All data for claims identified in this screen will be captured. *** ;
%clm_pull(dmehdr,dmehdr,FROM_DT) ; run ;
%clm_pull(phymeoshdr,phyhdr,FROM_DT) ; run ;
%clm_pull(hhahdr,hhahdr,FROM_DT) ; run ;
%clm_pull(hsphdr,hsphdr,FROM_DT) ; run ;
%clm_pull(iphdr,iphdr,ADMSN_DT) ; run ;
%clm_pull(snfhdr,snfhdr,ADMSN_DT) ; run ;
%clm_pull(outhdr,outhdr,FROM_DT) ; run ;


%MACRO LINE_PULL(infile,infile2,hdr) ;

proc sort data=in10.&infile2._&dsid. out = lines ; by bene_id clm_id ;
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
%LINE_PULL(dmeline,dmeline,dmeHDR) ; run ;
%LINE_PULL(dmehdr,dmehdr,dmeHDR) ; run ;
%LINE_PULL(phymeoshdr,phyhdr,phymeosHDR) ; run ;
%LINE_PULL(phymeosline,phyline,phymeosHDR) ; run ;
%LINE_PULL(outhdr,outhdr,outHDR) ; run ;
%LINE_PULL(outrev,outrev,outHDR) ; run ;
%LINE_PULL(outval,outval,outHDR) ; run ;
%LINE_PULL(hhahdr,hhahdr,hhahdr) ; run ;
%LINE_PULL(snfhdr,snfhdr,snfhdr) ; run ;
%LINE_PULL(hsphdr,hsphdr,hsphdr) ; run ;
%LINE_PULL(hsprev,hsprev,hsphdr) ; run ;
%LINE_PULL(iphdr,iphdr,iphdr) ; run ;
%LINE_PULL(inpval,inpval,iphdr) ; run ;
%LINE_PULL(inprev,inprev,iphdr) ; run ;


***Create a master HICN to MBI list;
data mbi_bene_&dsid.;
	set out.beneqtrs_&dsid. (keep=bene_id);
run;

data mbi_epi_&dsid.;
	set epi_orig10 (keep=bene_id bene_mbi)
		epi_orig9 (keep=bene_id bene_mbi)
		epi_orig8 (keep=bene_id bene_mbi)
		;
	if bene_mbi ^= '';
	proc sort nodupkey; by bene_id;
run;

data mbi_att_&dsid.;
	SET 
	%IF "&DSID." = "290_50202" %THEN %DO ;
		ATT1.ATT_PP&pp1.&version1._&dsid. (keep=bene_id mbi)
		ATT1.ATT_PP&pp1.&version1._567_50200 (keep=bene_id mbi)
		ATT1.ATT_PP&pp1.&version1._568_50201 (keep=bene_id mbi)
	%END ;
	%ELSE %DO ;
		ATT1.ATT_PP&pp1.&version1._&dsid. (keep=bene_id mbi)
	%END ;
	ATT2.ATT_PP&pp2.&version2._&dsid. (keep=bene_id mbi)
	ATT3.ATT_PP&pp3.&version3._&dsid. (keep=bene_id mbi)
	;

	if mbi ^= '';
	proc sort nodupkey; by bene_id;
run;

proc sql;
	create table out.mbi_beneid_&dsid. as
	select a.*, coalesce(b.bene_mbi,c.mbi,'') as BENE_MBI
	from mbi_bene_&dsid. as a 
		left join mbi_epi_&dsid. as b
			on a.bene_id=b.bene_id
		left join mbi_att_&dsid. as c
			on a.bene_id=c.bene_id;
quit;

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


/*
NOTE: There were 327 observations read from the data set WORK.EPI_COMBINE2.
NOTE: There were 3 observations read from the data set WORK.RECON_ALONE.
NOTE: The data set OUT.EPI_COMBINE_B_401_50228

proc contents data=epi_combine2 ; run ;
data check ;
	set epi_combine2 ; by bene_id ;
	if first.bene_id=0 or last.bene_id=0 ;
run ;
data check2 ;
	set OUT.EPI_COMBINE_B_401_50228 ; by bene_id ;
	if first.bene_id=0 or last.bene_id=0 ;
run ;

proc print data=recon_alone ; where bene_id = '15872438' ; run ;
proc print data=check2 ; run ;

data check2 ;
	merge out.RECON_OVERlAP_PP1_401_50228(in=a)
		  out.RECON_OVERlAP_PP2_401_50228 (in=b) ; by bene_id ;
	if a and b then output check2 ;
run ;

proc print data=check2 (obs=10) ; run ;

proc print data=out.recon_overlap_pp1_401_50228 ;
	where bene_id = '100050202' ; run ;
proc print data=out.recon_overlap_pp2_401_50228 ;
	where bene_id = '100050202' ; run ;

