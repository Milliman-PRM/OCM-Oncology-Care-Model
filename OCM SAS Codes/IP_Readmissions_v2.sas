**** Unplanned Readmission Logic **** ;
**** Source: 2018 All-Cause Hospital Wide Measure Updates and Specifications Report
	         Hospital-Level 30-Day Risk-Standardized Readmission Measure - Version 7.0 **** ;
%MACRO IPR(IN_FILE,time_per) ;

%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Additional_IP_Readmissions_Formats.sas" ;
*** Step 1: Identify index admissions *** ;
*** Remove if:  Discharged against medical advice, 
				Admitted for primary psychiatric diagnoses,
				Admitted for rehabilititation *** ;
*** Specs also indicate to remove if Admitted for medical treatment of
	cancer, but we are allowing *** ;

data index1 ;
	set &in_file. ;
	if READM_CAND_CASE  = 1 ;  	*** Identification of Short Term Acute and CAH stays for readmissions *** ;
*	if stus_cd = '07' then delete ;  *** Discharged against medical advice. *** ;

*** Step 2: Keep the latest billed admission for a case *** ;
proc sort data=index1 ; by bene_id EP_ID ip_case  ;
proc means data=index1 noprint MIN max ; by bene_id EP_ID ip_case ;
	var FROM_DT DSCHRGDT ;
	output out=i1 (drop = _type_ _freq_)
		   MIN(FROM_DT) = CASE_FROM_DT
		   max(DSCHRGDT) = case_discharge;

data index1a ;
	merge index1(in=a) i1(in=b) ; by bene_id EP_ID ip_case ;
	if a and b ;
	format case_discharge mmddyy10. ;
	if DSCHRGDT = case_discharge ;
	
proc sql ;
	create table index2 as
	select distinct bene_id, ep_id, ip_case, stus_cd, case_discharge, from_dt, CASE_from_dt, ICD_DGNS_CD1,ICD_DGNS_VRSN_CD1,
	ICD_DGNS_CD2, ICD_DGNS_VRSN_CD2, ICD_DGNS_CD3, ICD_DGNS_VRSN_CD3, ICD_DGNS_CD4,
	ICD_DGNS_VRSN_CD4, ICD_DGNS_CD5, ICD_DGNS_VRSN_CD5, ICD_DGNS_CD6, ICD_DGNS_VRSN_CD6,
	ICD_DGNS_CD7, ICD_DGNS_VRSN_CD7, ICD_DGNS_CD8, ICD_DGNS_VRSN_CD8, ICD_DGNS_CD9, 
	ICD_DGNS_VRSN_CD9, ICD_DGNS_CD10, ICD_DGNS_VRSN_CD10, ICD_DGNS_CD11, ICD_DGNS_VRSN_CD11,
	ICD_DGNS_CD12, ICD_DGNS_VRSN_CD12, ICD_DGNS_CD13, ICD_DGNS_VRSN_CD13, ICD_DGNS_CD14, ICD_DGNS_VRSN_CD14, 
	ICD_DGNS_CD15, ICD_DGNS_VRSN_CD15, ICD_DGNS_CD16, ICD_DGNS_VRSN_CD16, ICD_DGNS_CD17, ICD_DGNS_VRSN_CD17,
	ICD_DGNS_CD18, ICD_DGNS_VRSN_CD18, ICD_DGNS_CD19, ICD_DGNS_VRSN_CD19, ICD_DGNS_CD20, ICD_DGNS_VRSN_CD20,
	ICD_DGNS_CD21, ICD_DGNS_VRSN_CD21, ICD_DGNS_CD22, ICD_DGNS_VRSN_CD22, ICD_DGNS_CD23, ICD_DGNS_VRSN_CD23,
	ICD_DGNS_CD24, ICD_DGNS_VRSN_CD24, ICD_DGNS_CD25, ICD_DGNS_VRSN_CD25, ICD_PRCDR_CD1, ICD_PRCDR_VRSN_CD1,
	ICD_PRCDR_CD2, ICD_PRCDR_VRSN_CD2, ICD_PRCDR_CD3, ICD_PRCDR_VRSN_CD3, ICD_PRCDR_CD4, ICD_PRCDR_VRSN_CD4,
	ICD_PRCDR_CD5, ICD_PRCDR_VRSN_CD5, ICD_PRCDR_CD6, ICD_PRCDR_VRSN_CD6, ICD_PRCDR_CD7, ICD_PRCDR_VRSN_CD7,
	ICD_PRCDR_CD8, ICD_PRCDR_VRSN_CD8, ICD_PRCDR_CD9, ICD_PRCDR_VRSN_CD9, ICD_PRCDR_CD10, ICD_PRCDR_VRSN_CD10,
	ICD_PRCDR_CD11, ICD_PRCDR_VRSN_CD11, ICD_PRCDR_CD12, ICD_PRCDR_VRSN_CD12, ICD_PRCDR_CD13, ICD_PRCDR_VRSN_CD13,
	ICD_PRCDR_CD14, ICD_PRCDR_VRSN_CD14, ICD_PRCDR_CD15, ICD_PRCDR_VRSN_CD15, ICD_PRCDR_CD16, ICD_PRCDR_VRSN_CD16, 
	ICD_PRCDR_CD17, ICD_PRCDR_VRSN_CD17, ICD_PRCDR_CD18, ICD_PRCDR_VRSN_CD18, ICD_PRCDR_CD19, ICD_PRCDR_VRSN_CD19,
	ICD_PRCDR_CD20, ICD_PRCDR_VRSN_CD20, ICD_PRCDR_CD21, ICD_PRCDR_VRSN_CD21, ICD_PRCDR_CD22, ICD_PRCDR_VRSN_CD22,
	ICD_PRCDR_CD23, ICD_PRCDR_VRSN_CD23, ICD_PRCDR_CD24, ICD_PRCDR_VRSN_CD24, ICD_PRCDR_CD25, ICD_PRCDR_VRSN_CD25 
	from index1a ;

*** Accounts for cases with varying ICD codes - using latest *** ;
proc sort data=index2 ; by bene_id ep_id ip_case from_dt ;
data index2 ;
	set index2 ; by bene_id ep_id ip_case from_dt;
	if last.ip_case ;

******************************************** ;
**** For Baseline/ICD9 process *** ;
******************************************** ;
%if "&time_per." = "bl" %then %do ;

*** Step 3: Assign CCs  - outputs file index3 *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Data from Other Sources\AHRQ CC\ICD9\Sample_SingleCCS_Diagnosis_Load_Pgm.sas";

%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Data from Other Sources\AHRQ CC\ICD9\Sample_SingleCCS_Procedures_Load_Pgm.sas";

*** Step4: Remove admissions for psych or rehab *** ;
data index4 ;
	set index3 ;
	*if CCS1 in (650,651,652,654,655,656,657,658,659,662,670) then delete ; *** See Table D1 - psych discharges *** ;
	if CCS1 = 254 then delete ; *** See Table D1 Flow Diagram - rehab discharges *** ;


*** Step 5: Flag admissions *** ;
data index5 /*INDEX_ADMISSIONS*/  ;
	set index4 ;
	SURGICAL_ADMISSION = 0 ;
	ONCOLOGY_ADMISSION = 0 ;
	CARDIORESP_ADMISSION = 0 ;
	CARIOVASC_ADMISSION = 0 ;
	NEURO_ADMISSION = 0 ;
	MED_ADMISSION = 0 ;
	TRANSPLANT_ADMISSION = 0 ;
	MAINTENANCE_ADMISSION = 0 ;
	PPLANNED_PROC = 0 ;
	PPLANNED_PRINC = 0 ;
	PLANNED_ADMISSION = 0 ;
	INDEX_ADMISSION = 0 ;
	MISS_COHORT = 0 ;

		*** See PR Tables IN *** ;
	array px (P) ICD_PRCDR_CD: ;
	ARRAY PCC (P ) PRCCS: ;
	DO P = 1 TO DIM(PX) ;
		*** Surgical Procedure *** ;
		If PCC in (1, 2, 3, 9, 10, 12, 13, 14, 15, 16, 17, 20, 21, 22, 23, 24, 26, 28,
					  30, 33, 36, 42, 43, 44, 49, 51, 52, 53, 55, 56, 59, 60, 66, 67, 72,
					  73, 74, 75, 78, 79, 80, 84, 85, 86, 89, 90, 94, 96, 99, 101, 103, 
					  104, 105, 106, 109, 112, 113, 114, 118, 119, 120, 121, 123, 124, 
					  125, 129, 131, 132, 133, 141, 142, 144, 145, 146, 147, 148, 150,
					  152, 153, 154, 157, 158, 160, 161, 162, 164, 166, 167, 172, 175,
					  176) THEN SURGICAL_ADMISSION = 1 ; *Source: V7.0 Table D.2 -- ICD-10-PCS Codes ;
		IF PCC IN (64, 105, 176) THEN TRANSPLANT_ADMISSION = 1 ; *** Source: V7.0 Table PR.1 - Always planned. *** ;
		IF PCC IN (1,3,5,9,10,12,33,36,38,40,43,44,45,49,51,52,53,55,56,59,66,67,74,78,79,84,
					  85,86,99,104,106,107,109,112,113,114,119,120,124,129,132,142,152,153,154,
					  158,159,166,167,172,175) THEN PPLANNED_PROC = 1 ; *** Source: V7.0 Table PR.3 - Potentially planned procedures. ** ;
		if PX IN ('301','3029','303','304','3174','346','3818','5503','5504','9426','9427') then 
					 PPLANNED_PROC = 1 ; *** Source: V5.0 Table PR.3 - Potentially planned procedures. ** ;
	END ;

	IF CCS1 IN (45, 254) THEN MAINTENANCE_ADMISSION = 1 ; *** Source: V7.0 Table PR. 2 - Always planned. - Includes maintenance chemo *** ;
		
	IF SURGICAL_ADMISSION NE 1 THEN DO ;

		IF CCS1 IN (11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
					   26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
					   41, 42, 43, 44, 45) THEN ONCOLOGY_ADMISSION = 1 ;  * Source: Table D.3 -- Oncology *** ;
		ELSE IF CCS1 IN (56, 103, 108, 122, 125, 127, 128, 131) THEN CARDIORESP_ADMISSION = 1 ;* Source: Table D.4 *** ;
		ELSE IF CCS1 IN (96, 97, 100, 101, 102, 104, 105, 106, 107, 114, 115, 116, 117,
							   213) THEN CARDIOVASC_ADMISSION = 1 ; * Source: Table D.5 *** ;
		ELSE IF CCS1 IN (78, 79, 80, 81, 82, 83, 85, 95, 109, 110, 111, 112, 113, 216, 227, 233)
									then NEURO_ADMISSION = 1 ;* Source: Table D.6 *** ;
		ELSE IF CCS1 IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 57,
							   58, 59, 60, 61, 62, 63, 64, 76, 77, 84, 86, 87, 88, 89, 90, 91, 92, 93,
							   94, 98, 99, 118, 119, 120, 121, 123, 124, 126, 129, 130, 132, 133, 134, 
							   135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 
							   149, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 
							   164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 175, 197, 198, 199, 200, 
							   201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 214, 215, 
							   217, 225, 226, 228, 229, 230, 231, 232, 234, 235, 236, 237, 238, 239,
							   240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 
							   255, 256, 257, 258, 259, 653, 660, 661, 663, 2617) THEN MED_ADMISSION = 1 ;* Source: Table D.7 *** ;
	END ;


	IF CCS1 IN (1,2,3,4,5,7,8,9,54,55,60,61,63,76,77,78,82,83,84,85,87,89,90,91,92,93,99,
					  102, 104, 107, 109, 112, 116, 118, 120, 122, 123, 124, 125, 126, 127, 
					  128, 129, 130, 131, 135, 137, 139, 140, 142, 145, 146, 148, 153, 154, 
					  157, 159, 165, 168, 172, 197, 198, 172, 197, 198, 226, 227, 229, 233,
					  234, 235, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 249, 250,
					  251, 252, 253, 259, 650, 651, 652, 653, 656, 658, 660, 661, 662, 663, 670)
			OR PUT(ICD_DGNS_CD1,$ACUTE_ICD9_DIAGCD.) = "Y" THEN PPLANNED_PRINC = 1 ; 
			*Source: V7.0 Table PR.4 for CCs and V5.0 Table PR.4 for Acute ICD9 Codes ;

	IF TRANSPLANT_ADMISSION = 1 OR MAINTENANCE_ADMISSION = 1 OR
		(PPLANNED_PROC=1 AND PPLANNED_PRINC NE 1) THEN PLANNED_ADMISSION = 1 ;

	if stus_cd NOTIN ('07','20') 
		and CCS1 NOTIN (650,651,652,654,655,656,657,658,659,662,670) then INDEX_ADMIT = 1 ;  *** removes patients who die in hospital and psych admits from index contention *** ;

	IF SUM(SURGICAL_ADMISSION, ONCOLOGY_ADMISSION, CARDIORESP_ADMISSION, CARDIOVASC_ADMISSION,
		   NEURO_ADMISSION, MED_ADMISSION) = 0 THEN MISS_COHORT = 1 ;

	OUTPUT INDEX5 ;
	/*IF INDEX_ADMISSION = 1 THEN OUTPUT INDEX_ADMISSIONS*/ ;
	/*IF PLANNED_ADMISSION NE 1 THEN OUTPUT READMIT_CAND*/ ;

	PROC FREQ DATA=INDEX5;
		WHERE INDEX_ADMISSION = 1 AND MISS_COHORT = 1 ;
			TABLES ccs1*prccs1/list missing ;
	TITLE "RECORDS MARKED AS INDEX ADMISSIONS NOT BEING ASSIGNED TO A SPECIALTY COHORT BASED ON CCS" ;
%end ;

******************************************** ;
**** For ICD10 process *** ;
******************************************** ;

%if "&time_per." = "pp" %then %do ;

*** Step 3: Assign CCs  - outputs file index3 *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Data from Other Sources\AHRQ CC\ICD10\ICD10_Single_CCS_Load_Program.sas";

*Bring in additional formats (used in Step 5 below) ;

*** Step4: Remove admissions for psych or rehab *** ;
data index4 ;
	set index3 ;
	*if I10_DXCCS1 in (650,651,652,654,655,656,657,658,659,662,670) then delete ; *** See Table D1 - psych discharges *** ;
	if I10_DXCCS1 = 254 then delete ; *** See Table D1 Flow Diagram - rehab discharges *** ;

*** Step 5: Flag admissions *** ;
data index5 /*INDEX_ADMISSIONS*/  ;
	set index4 ;
	SURGICAL_ADMISSION = 0 ;
	ONCOLOGY_ADMISSION = 0 ;
	CARDIORESP_ADMISSION = 0 ;
	CARIOVASC_ADMISSION = 0 ;
	NEURO_ADMISSION = 0 ;
	MED_ADMISSION = 0 ;
	TRANSPLANT_ADMISSION = 0 ;
	MAINTENANCE_ADMISSION = 0 ;
	PPLANNED_PROC = 0 ;
	PPLANNED_PRINC = 0 ;
	PLANNED_ADMISSION = 0 ;
	INDEX_ADMISSION = 0 ;
	MISS_COHORT = 0 ;

		*** See PR Tables IN *** ;
	array px (P) ICD_PRCDR_CD: ;
	array vx (P) ICD_PRCDR_VRSN_CD: ;
	ARRAY PCC (P ) I10_PRCCS: ;
	DO P = 1 TO DIM(PX) ;
		*** Surgical Procedure *** ;
		if PUT(PX,$SURG_ICD10_PRCCD.) = "Y" THEN SURGICAL_ADMISSION = 1 ; *Source: Table D.2 -- ICD-10-PCS Codes ;
		If PCC in (1, 2, 3, 9, 10, 12, 13, 14, 15, 16, 17, 20, 21, 22, 23, 24, 26, 28,
					  30, 33, 36, 42, 43, 44, 49, 51, 52, 53, 55, 56, 59, 60, 66, 67, 72,
					  73, 74, 75, 78, 79, 80, 84, 85, 86, 89, 90, 94, 96, 99, 101, 103, 
					  104, 105, 106, 109, 112, 113, 114, 118, 119, 120, 121, 123, 124, 
					  125, 129, 131, 132, 133, 141, 142, 144, 145, 146, 147, 148, 150,
					  152, 153, 154, 157, 158, 160, 161, 162, 164, 166, 167, 172, 175,
					  176) THEN SURGICAL_ADMISSION = 1 ; *Source: Table D.2 -- ICD-10-PCS Codes ;
		IF PCC IN (64, 105, 176) THEN TRANSPLANT_ADMISSION = 1 ; *** Source: Table PR.1 - Always planned. *** ;
		IF PCC IN (1,3,5,9,10,12,33,36,38,40,43,44,45,49,51,52,53,55,56,59,66,67,74,78,79,84,
					  85,86,99,104,106,107,109,112,113,114,119,120,124,129,132,142,152,153,154,
					  158,159,166,167,172,175) THEN PPLANNED_PROC = 1 ; *** Source: Table PR.3 - Potentially planned procedures. ** ;
		if put(PX,$PPLANNED_ICD10_PRCCD.) = "Y" then PPLANNED_PROC = 1 ; *** Source: Table PR.3 - Potentially planned procedures. ** ;
	END ;


	IF I10_DXCCS1 IN (45, 254) THEN MAINTENANCE_ADMISSION = 1 ; *** Source: Table PR. 2 - Always planned. - Includes maintenance chemo *** ;

	*** See "D" tables *** ;
	*TG changes here ;
		
	IF SURGICAL_ADMISSION NE 1 THEN DO ;

		IF I10_DXCCS1 IN (11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 
					   26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
					   41, 42, 43, 44, 45) THEN ONCOLOGY_ADMISSION = 1 ;  * Source: Table D.3 -- Oncology *** ;
		ELSE IF I10_DXCCS1 IN (56, 103, 108, 122, 125, 127, 128, 131) THEN CARDIORESP_ADMISSION = 1 ;* Source: Table D.4 *** ;
		ELSE IF I10_DXCCS1 IN (96, 97, 100, 101, 102, 104, 105, 106, 107, 114, 115, 116, 117,
							   213) THEN CARDIOVASC_ADMISSION = 1 ; * Source: Table D.5 *** ;
		ELSE IF I10_DXCCS1 IN (78, 79, 80, 81, 82, 83, 85, 95, 109, 110, 111, 112, 113, 216, 227, 233)
									then NEURO_ADMISSION = 1 ;* Source: Table D.6 *** ;
		ELSE IF I10_DXCCS1 IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 57,
							   58, 59, 60, 61, 62, 63, 64, 76, 77, 84, 86, 87, 88, 89, 90, 91, 92, 93,
							   94, 98, 99, 118, 119, 120, 121, 123, 124, 126, 129, 130, 132, 133, 134, 
							   135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 
							   149, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 
							   164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 175, 197, 198, 199, 200, 
							   201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 214, 215, 
							   217, 225, 226, 228, 229, 230, 231, 232, 234, 235, 236, 237, 238, 239,
							   240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 
							   255, 256, 257, 258, 259, 653, 660, 661, 663, 2617) THEN MED_ADMISSION = 1 ;* Source: Table D.7 *** ;
	END ;


	IF I10_DXCCS1 IN (1,2,3,4,5,7,8,9,54,55,60,61,63,76,77,78,82,83,84,85,87,89,90,91,92,93,99,
					  102, 104, 107, 109, 112, 116, 118, 120, 122, 123, 124, 125, 126, 127, 
					  128, 129, 130, 131, 135, 137, 139, 140, 142, 145, 146, 148, 153, 154, 
					  157, 159, 165, 168, 172, 197, 198, 172, 197, 198, 226, 227, 229, 233,
					  234, 235, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 249, 250,
					  251, 252, 253, 259, 650, 651, 652, 653, 656, 658, 660, 661, 662, 663, 670)
			OR PUT(ICD_DGNS_CD1,$ACUTE_ICD10_DIAGCD.) = "Y" THEN PPLANNED_PRINC = 1 ; *Source: Table PR.4 -- ICD-10-CM Codes ;

	IF TRANSPLANT_ADMISSION = 1 OR MAINTENANCE_ADMISSION = 1 OR
		(PPLANNED_PROC=1 AND PPLANNED_PRINC NE 1) THEN PLANNED_ADMISSION = 1 ;

	if stus_cd NOTIN ('07','20') 
		and I10_DXCCS1 NOTIN (650,651,652,654,655,656,657,658,659,662,670) then INDEX_ADMIT = 1 ;  *** removes patients who die in hospital and psych admits from index contention *** ;

	IF SUM(SURGICAL_ADMISSION, ONCOLOGY_ADMISSION, CARDIORESP_ADMISSION, CARDIOVASC_ADMISSION,
		   NEURO_ADMISSION, MED_ADMISSION) = 0 THEN MISS_COHORT = 1 ;

	OUTPUT INDEX5 ;
	*IF INDEX_ADMISSION = 1 THEN OUTPUT INDEX_ADMISSIONS ;

%end ;


*** Step 6: Identify index admits w unplanned readmit *** ;

*DATA INDEX_ADMISSIONS ; *SET INDEX_ADMISSIONS ;
DATA index5 ; SET index5;
	DAY30 = INTNX('DAY',case_discharge,30,'SAME') ;

	*** As per 2.2.2 in 2018 methodology document, If the first readmission after discharge is planned, 
	any subsequent unplanned readmission is not considered in the outcome for that index admission
	because the unplanned readmission could be related to care provided during the intervening
	planned readmission rather than during the index admission. *** ;
	*** Only allows immediately following admission to be reviewed for an event. *** ;

*PROC SORT DATA=INDEX_ADMISSIONS ; 
PROC SORT DATA=INDEX5 ; BY BENE_ID EP_ID FROM_DT ;

DATA INDEX_FINAL READ1(KEEP = BENE_ID EP_ID READMIT_CASE) ;
	SET /*INDEX_ADMISSIONS*/ INDEX5 ; BY BENE_ID EP_ID FROM_DT ;
	
	IF FIRST.EP_ID THEN DO ;
		PREV_CASE = IP_CASE ;
		PREV30 = DAY30 ;
		PREV_IDX = INDEX_ADMIT ;
		UNPLANNED_READMIT_FLAG =  0 ;
	END ;
	ELSE DO ;
		IF PREV_IDX = 1 AND FROM_DT LE PREV30 THEN DO ;
			IF PLANNED_ADMISSION NE 1 THEN DO ;
				UNPLANNED_READMIT_FLAG = 1 ;
				READMIT_CASE = PREV_CASE ;
			END ;
			ELSE UNPLANNED_READMIT_FLAG = 0 ;
		END ;
		ELSE DO ;
			UNPLANNED_READMIT_FLAG = 0 ;
		END ;
			PREV_CASE = IP_CASE ;
			PREV30 = DAY30 ;
			PREV_IDX = INDEX_ADMIT ;
	END ;

	RETAIN PREV_CASE PREV30 PREV_IDX ;	

	IF UNPLANNED_READMIT_FLAG = 1 THEN OUTPUT READ1 ;
	OUTPUT INDEX_FINAL ;

PROC SQL ;
	CREATE TABLE IPR_FINAL AS 
	SELECT A.*, 
		   CASE WHEN B.READMIT_CASE IS NULL then 0 ELSE 1 end AS HAS_READMISSION 
	FROM INDEX_final AS A LEFT JOIN READ1 AS B
	ON A.BENE_ID=B.BENE_ID AND
	   A.EP_ID=B.EP_ID AND
	   A.IP_CASE = B.READMIT_CASE ;
QUIT ;

PROC SORT DATA=IPR_FINAL ; BY BENE_ID EP_ID IP_CASE ;

%MEND IPR ;

RUN ;
