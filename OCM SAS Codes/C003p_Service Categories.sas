********************************************************************** ;
		***** C003p_Service_Categories.sas ***** ;
********************************************************************** ;

	*** locale of attribution/reconciliation files.  *** ;
libname att 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP1" ; 
libname att2 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP2" ;
libname att3 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP3" ;
libname att4 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP4" ;

	*** locale of RECONCILIATION  files.  *** ;
libname rec1 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP1" ;
libname rec2 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP2" ;
libname rec3 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP3" ;


libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Performance" ;
libname outfinal "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Performance\May19" ;
options ls=132 ps=70 obs=MAX nomprint mlogic; run ;


********************************************************************** ;
********************************************************************** ;
*** Initiating therapy lists *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats PP2.sas" ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats PP3.sas" ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats PP4.sas" ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats PP5.sas" ;
*** Cancer diagnosis code lists *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Cancer Formats PP3.sas" ;
*** Cancer assignment macro  *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Cancer Diagnoses_5.sas" ;
*** Bene level Quality Metrics *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_AHRQ.sas" ;
*** Novel Therapy *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Novel Therapy.sas" ;
*** Service Categories *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Service_Categories_v2.sas" ;
*** Inpatient Allowed Amount Calculation Needs *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000 - CMMI - Formats - Hemophilia Clotting Factors.sas" ; 
run ;
*** Predictive Model Variable Development  *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Predict_Flags PP2.sas" ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Predict_Flags PP3.sas" ;
*** MEOS Payments  *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_MEOS PAYMENTS_v3.sas" ; 
*** For chemo-sensitive override *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Breast_Hormonal.sas" ; run ;
*** For unplanned readmission identification *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\IP_Readmissions_v2.sas" ; run ;

********************************************************************** ;
********************************************************************** ;
%let vers = A ; *** indicates A(latest qtr claims only) vs B processing(all qtrs epi files received) *** ;
%let bl = p5&vers. ; *** performance period of latest bene file received *** ; 
********************************************************************** ;
	*** Attribution File/Recon File Name Macro Variables *** ;
***Version variables refers to recon attribution files: TU variables refers to recon episode and claims files***;
%let pp1 = 1 ;
%let version1 = TrueUp2 ;
%let tu1 = 1 ; *** blank for initial, 1 for true-up 1, 2 for true-up 2 *** ;
%let pp2 = 2 ;
%let version2 = TrueUp2 ;
%let tu2 =  ; *** blank for initial, 1 for true-up 1, 2 for true-up 2 *** ;
%let pp3 = 3 ;
%let version3 = TrueUp1 ;
%let tu3 =  ; *** blank for initial, 1 for true-up 1, 2 for true-up 2 *** ;
%let pp4 = 4 ;
%let version4 = initial ;
%let tu4 =  ; *** blank for initial, 1 for true-up 1, 2 for true-up 2 *** ;
********************************************************************** ;
********************************************************************** ;
RUN ;

*** Note if CMS starts to provide beneficiary data with the early quarterly claims submission,
	then use of latest_qtr should be removed from derivation of DIED_MILLIMAN. *** ;
%let latest_qtr = mdy(10,1,2018) ; *** beginning of latest available quarter *** ;
%let sd = mdy(7,1,2016) ;
%let potential = mdy(7,1,2018) ;  *** date of latest episode begin date included in attribution/recon files. *** ;

%LET USE_ATT = 1 ; *** 1 = Attribution Page Update.  0 = Recon Page Update. *** ;

run ;

********************************************************************** ;
********************************************************************** ;

%MACRO EPISODE_PERIOD ;
	***** Assigning episode to time period. ***** ;
	if ep_beg < MDY(1,2,2017) then EPISODE_PERIOD = "PP1" ;
	ELSE IF EP_BEG < MDY(7,2,2017) THEN EPISODE_PERIOD = "PP2" ;
	ELSE IF EP_BEG < MDY(1,2,2018) THEN EPISODE_PERIOD = "PP3" ;
	ELSE IF EP_BEG < MDY(7,2,2018) THEN EPISODE_PERIOD = "PP4";
	ELSE EPISODE_PERIOD = "PP5" ;
%MEND ;

********************************************************************** ;
********************************************************************** ;

%MACRO JAN2017 ;

**** Episode Start Date Specific Cancers **** ;
	**** Episode Start Date Specific Cancers **** ;
	if ep_beg le mdy(1,1,2017) then do ;
	SEC_LYMPH=0 ; SEC_MN_NOS=0 ; SEC_MN_RESPDIG=0 ; SEC_MN_NEUROEND=0 ;
	end ;
	If ep_beg le mdy(7,1,2017) then do ;
	THROMBO=0 ; OSTEO=0 ; MYELO=0 ; POLY_VERA=0 ; CHRONIC_MYELO=0 ;
	END ;


	*** HAS_CANCER SHOULD MATCH DERIVATION IN 000_CANCER_DIAGNOSIS MACRO *** ;
has_cancer = max(ACUTE_LEUKEMIA,ANAL,BLADDER,BREAST,CHRONIC_LEUKEMIA, CNS, ENDOCRINE, 
				 FEMALEGU, GASTRO_ESOPHAGEAL, HEADNECK, INTESTINAL, KIDNEY, LIVER, LUNG, LYMPHOMA,
				 MALIGNANT_MELANOMA, MULT_MYELOMA, OVARIAN, PANCREATIC, PROSTATE, 
				 ATYPICAL_LEUKEMIA, INSITU_BREAST, INSITU_CERVIX, INSITU_RESP, 
				 INSITU_OES, INSITU_NOS_DIG, INSITU_NOS_GEN, INSITU_OTH, INSITU_SKIN, CHRONIC_LEUKEMIA_U,
				 CHRONIC_M_LEUKEMIA, KAPOSI, LEUKEMIA_NOS, LYMPHOID_LEUKEMIA, MN_ABDOMEN, MN_LIMB, MN_BONE_NOS,
				 MN_HEART, MN_LLIMB, MN_OTH_DIG, MN_FEM, MN_OTH,  MN_PELVIS, MN_MALE, MN_NERVES, MN_PLACENTA,
				 MN_RP, MN_TESTIS, MN_THORAX, MN_THYMUS, MN_ULIMB, MN_NOS, MDS, MERKEL, MONO_LEUKEMIA,
				 MYELOID_LEUKEMIA, OTHER_SKIN, OTHER_LYMPH, OTHER_LLEUK, OTH_MONOLEUK, OTH_MYELEUK,
				 OTH_SPELEUK,ACUTE_PAN, JM_LEUK, INSITU_MELANOMA, SEC_LYMPH, SEC_MN_NOS, SEC_MN_RESPDIG,
				 SEC_MN_NEUROEND, THROMBO, OSTEO, MYELO, POLY_VERA, CHRONIC_MYELO) ;

%MEND JAN2017 ;

%macro cancer_remap(canc) ;	
	*** Some CMS Cancer Types set to ICD10 *** ;
	if &CANC. = 'C26' then &CANC. = 'Malignant neoplasm of other and ill-defined digestive organs' ;
	if &CANC. = 'C37' then &CANC. = "Malignant neoplasm of thymus" ;
	if &CANC. = 'C38' then &CANC. = "Malignant neoplasm of heart, mediastinum and pleura" ;
	if &CANC. = 'C40' then &CANC. = "Malignant neoplasm of bone and articular cartilage of limbs" ;
	if &CANC. = 'C41' then &CANC. = "Malignant neoplasm of bone and articular cartilage of sites NOS" ;
	if &CANC. = 'C44' then &CANC. = "Other and unspecified malignant neoplasm of skin" ;
	if &CANC. = 'C46' then &CANC. = "Kaposi's Sarcoma" ;
	if &CANC. = 'C48' then &CANC. = "Malignant neoplasm of retroperitoneum and peritoneum" ;
	if &CANC. = 'C47 or C49' then &CANC. = "Malignant neoplasm of peripheral nerves, autonomic nervous system" ;
	if &CANC. = 'C49' then &CANC. = "Malignant neoplasm of peripheral nerves, autonomic nervous system" ;
	if &CANC. = 'C4A' then &CANC. = "Merkel cell carcinoma" ;
	if &CANC. = 'C57' then &CANC. = "Malignant neoplasm of other and unspecified female genital organs" ;
	if &CANC. = 'C60 or C63' then &CANC. = "Malignant neoplasm of penis, other, and unspecific male organs" ;
	if &CANC. = 'C62' then &CANC. = "Malignant neoplasm of testis" ;
	if &CANC. = 'C76.1' then &CANC. = "Malignant neoplasm of thorax" ; 
	if &CANC. = 'C76.2' then &CANC. = "Malignant neoplasm of abdomen" ; 
	if &CANC. = 'C76.8' then &CANC. = "Malignant neoplasm of other specified ill-defined sites" ; 
	if &CANC. = 'C77' then &CANC. = "Secondary and unspecified malignant neoplasm of lymph nodes" ;
	if &CANC. = 'C78' then &CANC. = "Secondary malignant neoplasm of resp and digestive organs" ;
	if &CANC. = 'C79' then &CANC. = "Secondary malignant neoplasm of other and unspecified sites" ;
	if &CANC. = 'C7B' then &CANC. = "Secondary neuroendocrine tumors" ;
	if &CANC. = 'C80' then &CANC. = "Malignant neoplasm NOS" ;
	if &CANC. = 'C91.z' then &CANC. = "Other lymphoid leukemia" ;
	if &CANC. = 'C91.9' then &CANC. = "Lymphoid Leukemia, unspecified" ;
	IF &CANC. = 'C92.2' THEN &CANC. = "Atypical chronic myeloid leukemia, BCR/ABL negative" ;
	if &CANC. = 'C92.9' then &CANC. = 'Myeloid leukemia, unspecified';
	if &CANC. = 'C92.z' then &CANC. = 'Other myeloid leukemia';
	if &CANC. = 'C93.1' then &CANC. = 'Chronic myelomonocytic leukemia' ;
	IF &CANC. = 'C93.9' THEN &CANC. = "Monocytic Leukemia, unspecified" ;
	if &CANC. = 'C95.1' then &CANC. = 'Chronic leukemia of unspecified cell type' ;
	if &CANC. = 'C95.9' then &CANC. = 'Leukemia, unspecified' ;
	if &CANC. = 'C96' then &CANC. = "Malignant neoplasm of lymphoid, hematopoietic NOS" ;
	IF &CANC. = 'D00' THEN &CANC. = "Carcinoma in situ of oral cavity, esophagus and stomach" ;
	if &CANC. = 'D02' then &CANC. = 'Carcinoma in situ of middle ear and respiratory system' ;
	if &CANC. = 'D03' then &CANC. = 'Melanoma in situ' ;
	if &CANC. = 'D04' then &CANC. = 'Carcinoma in situ of skin' ;
	if &CANC. = 'D05' then &CANC. = 'Carcinoma in situ of breast' ;
	if &CANC. = 'D07' then &CANC. = 'Carcinoma in situ of other and NOS genital organs' ;
	if &CANC. = 'C76.3' then &CANC. = "Malignant neoplasm of pelvis" ;
	if &CANC. = 'D09' then &CANC. = 'Carcinoma in situ of other and unspecified sites' ;
	if &CANC. = 'D45' then &CANC. = 'Polycythemia vera' ; 
	if &CANC. = 'D47.3' then &CANC. = 'Essential (hemorrhagic) thrombocythemia' ;
	if &CANC. = 'D47.4' then &CANC. = 'Osteomyelofibrosis' ;
	if &CANC. = 'D75.81' then &CANC. = 'Myelofibrosis' ;

	*** cancer type change to conform with MA labeling logic. *** ;
	if &CANC. = "Carcinoma in situ of other and unspecified genital organs" then 
	   &CANC. = "Carcinoma in situ of other and NOS genital organs"  	   ;
	if 	   &CANC. in 
			("Malignant neoplasm of peripheral nerves, autonomic nervous system, and other and connective soft tis",
			 "Malignant neoplasm of peripheral nerves, autonomic nervous system, and other and connective soft tissue") then 
		   &CANC. = "Malignant neoplasm of peripheral nerves, autonomic nervous system"   ;
	if &CANC. = "Myeloid leukemia, unspecified" then &CANC. = "Myeloid Leukemia, NOS"  ;
	if &canc. = "Malignant neoplasm of lymphoid, hematopoietic NOS" then
	   &canc. = "Other and unspecified malignant neoplasms of lymphoid, hematopoietic and related tissue" ;

	if &CANC. = "Secondary and unspecified malignant neoplasm of lymph nodes" then
	   &CANC. = "Secondary malignant neoplasm of lymph nodes" ;

	IF &CANC. = "Carcinoma in situ of other and unspecified sites" THEN
	   &CANC. = "Carcinoma in situ of other and NOS sites" ;

	if &CANC. = "Juvenile myelomonocytic leukemia"  then
	   &CANC. = "JUV Myelomonocytic Leukemia" ;

	if &CANC. = "Essential (hemorrhagic) thrombocythemia "  then
	   &CANC. = "Essential thrombocythemia" ;

	if &CANC. = "Carcinoma in situ of oral cavity, esophagus and stomach" then
	   &CANC. = "Carcinoma in situ of oral cavity, esophagus, stomach" ;

	if &CANC. = "Monocytic Leukemia, unspecified" then 
	   &CANC. = "Monocytic Leukemia, NOS" ;


%mend cancer_remap ;


%macro sc(ds,id) ; 


*** For End of Life Metrics *** ;
proc sort data=out.epi_prelim_&bl._&ds. OUT=EPI_DOD (KEEP = BENE_ID EP_ID DOD EP_BEG EP_END epi_tax_id EPI_ATT_TIN CANCER_TYPE_MILLIMAN) ; BY BENE_ID ;

**************************************************************************************
*************************** IP COST MODEL LOGIC **************************************
**************************************************************************************;

PROC SORT DATA=out.check_ipop_&bl._&ds. OUT=IPOP ; BY BENE_ID EP_ID CLM_ID ;
PROC MEANS DATA=IPOP NOPRINT MAX ; BY BENE_ID EP_ID CLM_ID ;
	VAR BMT_ALLOGENEIC BMT_AUTOLOGOUS
		/*BMT_ALLOGENEIC_AK BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL
		BMT_AUTOLOGOUS_AK BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL*/
		ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY 
		LIVER_SURGERY LUNG_SURGERY OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY  
		dxANAL_SURGERY dxBLADDER_SURGERY dxBREAST_SURGERY dxFEMALEGU_SURGERY dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY 
		dxLIVER_SURGERY dxLUNG_SURGERY dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY  
;
	OUTPUT OUT=IPOP_FLAGS (DROP = _TYPE_ _FREQ_)
		   MAX() = ;

%macro IP ;

DATA ICU(DROP=EP_ID) ;
	SET out.inpatient_&bl._&ds. ;
	IF REV_CNTR IN ('0200','0201','0202','0203','0204','0206','0207','0208','0209') THEN ICU = 1 ;
	IF REV_CNTR IN ('0450','0451','0452','0453','0454','0455','0456','0457','0458','0459','0981') THEN DO ;
		IP_ER = 1 ; 
		IF (('70000' LE HCPCS_CD LE '89999') OR
		   HCPCS_CD  IN ('G0106','G0120','G0122','G0130','G0202','G0204','G0206','G0219','G0235','G0252','G0255','G0288','G0389','S8035',
		   				 'S8037','S8040','S8042','S8080','S8085','S8092','S9024')) THEN IP_ER = 0 ;
	END ;
	IF REV_CNTR = '0762' OR
	   (REV_CNTR = '0760' AND HCPCS_CD = 'G0378' AND REV_UNIT GE 8) THEN DO ;
	   IP_OBS = 1 ;
	END ;
run;	

PROC SQL ;
	CREATE TABLE ICU2 AS
	SELECT A.*, B.* 
	FROM EPI_DOD AS A, ICU AS B
	WHERE A.BENE_ID = B.BENE_ID AND
		  A.EP_BEG LE ADMSN_DT LE A.EP_END ;
quit ;
		
PROC SORT DATA=ICU2 ; BY BENE_ID EP_ID CLM_ID ;
PROC MEANS DATA=ICU2 NOPRINT MAX ; BY BENE_ID EP_ID CLM_ID ;
	VAR ICU IP_ER IP_OBS ;
	OUTPUT OUT=ICU_FLAGS (DROP = _TYPE_ _FREQ_)
		   MAX() = ;

data iphdr_clean ;
	MERGE ICU2(IN=A DROP=ICU) ICU_FLAGS(IN=B) ; by bene_id ep_id clm_id ;
	IF A AND B ;
	if first.clm_id THEN OUTPUT ;
	
PROC SORT DATA=IPHDR_CLEAN ; BY BENE_ID EP_ID CLM_ID ;

data SC_ip_&bl._&ds. ;
	MERGE IPHDR_CLEAN(IN=A WHERE = (NOPAY_CD = "  ")) 
		  IPOP_FLAGS ;
	BY BENE_ID EP_ID CLM_ID ;
	if a ;

	if missing(DED_AMT) then DED_AMT = 0;
	if missing(COIN_AMT) then COIN_AMT = 0;
	if missing(BLDDEDAM) then BLDDEDAM = 0;
	allowed = sum(PMT_AMT,(PER_DIEM*UTIL_DAY)) ; 
	if CLM_STD_PYMT_AMT = . then CLM_STD_PYMT_AMT=allowed ;

	**** Initializing Service Category **** ;
	FORMAT Service_CAT $50.; length Service_CAT $50. ; 
	Service_CAT = "    " ;

		%canc_init ; /*chemosens1 = 0 ; chemosens2 = 0 ;*/


		ARRAY v (I) ICD_DGNS_VRSN_CD1 ;
		ARRAY d (I) ICD_DGNS_CD1 ;
		DO I = 1 TO 1 ;
			%CANCERTYPE(v, d) ;
			D3 = SUBSTR(left(d),1,3) ;
			D4 = SUBSTR(left(d),1,4) ;
			D5 = SUBSTR(left(d),1,5) ;
			D6 = SUBSTR(left(d),1,6) ;
			D7 = SUBSTR(left(d),1,7) ;
			/*
			if v = "9" and put(d,$Chemo_Sens_ICD9_.) = "Y" then chemosens1 = 1 ;
			if v = "0" then do ;
				if put(D3,$Chemo_Sens_ICD10_3_.) = "Y" then chemosens1 = 1 ;
				if put(D4,$Chemo_Sens_ICD10_4_.) = "Y" then chemosens1 = 1 ;
				if put(D5,$Chemo_Sens_ICD10_5_.) = "Y" then chemosens1 = 1 ;
				if put(D6,$Chemo_Sens_ICD10_6_.) = "Y" then chemosens1 = 1 ;
				if put(D7,$Chemo_Sens_ICD10_7_.) = "Y" then chemosens1 = 1 ;
			end ;*/
		END ;
		%JAN2017 ;
		has_cancer_primary = has_cancer ;

		%canc_init ; has_cancer = 0 ;

		ARRAY v2 (l) ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD25 ;
		ARRAY d2 (l) ICD_DGNS_CD1-ICD_DGNS_CD25 ;
		DO l = 1 TO dim(d2) ;
			%CANCERTYPE(v2, d2) ;
			D3 = SUBSTR(left(d2),1,3) ;
			D4 = SUBSTR(left(d2),1,4) ;
			D5 = SUBSTR(left(d2),1,5) ;
			D6 = SUBSTR(left(d2),1,6) ;
			D7 = SUBSTR(left(d2),1,7) ;
			/*
			if v2 = "9" and put(d2,$Chemo_Sens_ICD9_.) = "Y" then chemosens2 = 1 ;
			if v2 = "0" then do ;
				if put(D3,$Chemo_Sens_ICD10_3_.) = "Y" then chemosens2 = 1 ;
				if put(D4,$Chemo_Sens_ICD10_4_.) = "Y" then chemosens2 = 1 ;
				if put(D5,$Chemo_Sens_ICD10_5_.) = "Y" then chemosens2 = 1 ;
				if put(D6,$Chemo_Sens_ICD10_6_.) = "Y" then chemosens2 = 1 ;
				if put(D7,$Chemo_Sens_ICD10_7_.) = "Y" then chemosens2 = 1 ;
			end ;
			*/
		END ;
		%JAN2017 ;

	

	if substr(provider,3,1) in ('R','T') then SERVICE_CAT = "Inpatient: Other" ;
	else if anyalpha(substr(provider,3,4)) = 0 and '3025' <= substr(provider,3,4) and substr(provider,3,4) <= '3099' then SERVICE_CAT = "Inpatient: Other" ;
	ELSE if DRG_CD in ('945','946') then SERVICE_CAT='Inpatient: Other';
	if '2000' <= substr(provider,3,4) and substr(provider,3,4) <= '2299' then SERVICE_CAT='Inpatient: Other';

	**** Surgical Admissions consider cancer if has cancer diagnosis code in primary position *** ;
	if service_cat = "  "  then do;
		if put(drg_cd,$All_Surg_DRG.) = 'Y' then do ;
			SERVICE_CAT = "Inpatient Surgical: Non-Cancer" ;
			if has_cancer_primary = 1  then SERVICE_CAT = "Inpatient Surgical: Cancer" ;
		end;
		IF PUT(DRG_CD,$All_Surg_DRG_nodx.) = 'Y' THEN SERVICE_CAT = "Inpatient Surgical: Cancer" ;
		if PUT(DRG_CD,$All_Surg_DRG_anydx.) = 'Y' then do ;
			SERVICE_CAT = "Inpatient Surgical: Non-Cancer" ;
			If HAS_CANCER = 1 then SERVICE_CAT = "Inpatient Surgical: Cancer" ;
		end;
	end ;

	**** Medical Admissions considered chemo-sensitive if 
			(1) has chemo sensitive diagnosis code in primary position OR
			(2) has chemo sensitive diagnosis code in secondary position and cancer diagnosis in primary position OR
		 	(2) reports an IP chemotherapy MSDRG *** ;
	if service_cat = "  "  then do;
				/*if chemosens1 = 1 then SERVICE_CAT = "Inpatient Medical: Chemo Sensitive" ;
				else if chemosens2 = 1 and has_cancer_primary = 1 then SERVICE_CAT = "Inpatient Medical: Chemo Sensitive" ;
				else*/ if put(drg_cd,$Chemo_Sens_DRG_new.) = "Y" then SERVICE_CAT = "Inpatient Medical: Potentially Chemo Related" ;
				else SERVICE_CAT = "Inpatient Medical: Other" ;
	end ;


		**** Flags  to Develop Benficiary File Variables *** ;
		IP_CAH = 0 ; IP_CHEMO_ADMIN = 0 ; 
		IF ('0001' LE SUBSTR(PROVIDER,3,4) LE '0879') OR 
		   ('1300' LE SUBSTR(PROVIDER,3,4) LE '1399') THEN IP_CAH = 1 ;
	*** Identification of Short Term Acute and CAH stays for readmissions *** ;
	if ('0001' le substr(provider,3,4) le '0879') or
	   ('1300' le substr(provider,3,4) le '1399') then readm_cand = 1 ;
	else readm_cand = 0 ;

		IF PRNCPAL_DGNS_CD IN ('V5811', 'V5812', 'Z5111', 'Z5112') THEN IP_CHEMO_ADMIN = 1 ; *** Source: OCM ticket 787031 - with file attached OCM-1+Measure+Specifications *** ;

		if CANCER_TYPE_MILLIMAN = "Acute Leukemia" then IP_BMT_AK = MAX(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;
	    if CANCER_TYPE_MILLIMAN = "Lymphoma" THEN IP_BMT_L = MAX( BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;
		if CANCER_TYPE_MILLIMAN = "Multiple Myeloma" THEN IP_BMT_MM = MAX(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;
	    if CANCER_TYPE_MILLIMAN = "MDS" THEN IP_BMT_MDS = MAX(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;
	    IF CANCER_TYPE_MILLIMAN = "Chronic Leukemia" THEN IP_BMT_CL = MAX(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;

		if CANCER_TYPE_MILLIMAN ne "Breast Cancer" and dxBreast_surgery = 0 then BREAST_SURGERY = 0 ;
		if CANCER_TYPE_MILLIMAN ne "Anal Cancer" and dxAnal_surgery = 0 then ANAL_SURGERY = 0 ;
		if CANCER_TYPE_MILLIMAN ne "Liver Cancer" and dxLiver_surgery = 0 then LIVER_SURGERY = 0 ;
		if CANCER_TYPE_MILLIMAN ne "Lung Cancer" and dxLung_surgery = 0 then LUNG_SURGERY = 0 ;
		if CANCER_TYPE_MILLIMAN ne "Bladder Cancer" and dxBladder_surgery = 0 then BLADDER_SURGERY = 0 ;
		if CANCER_TYPE_MILLIMAN ne "Female GU Cancer other than Ovary" and dxFemalegu_surgery = 0 then FEMALEGU_SURGERY = 0 ;
		if CANCER_TYPE_MILLIMAN ne "Gastro/Esophageal Cancer" and dxGastro_surgery = 0 then GASTRO_SURGERY = 0 ;
		if CANCER_TYPE_MILLIMAN ne "Head and Neck Cancer" and dxHeadNeck_surgery = 0 then HEADNECK_SURGERY = 0 ;
		if CANCER_TYPE_MILLIMAN ne "Small Intestine / Colorectal Cancer" and dxIntestinal_surgery = 0 then INTESTINAL_SURGERY = 0 ;
		if CANCER_TYPE_MILLIMAN ne "Ovarian Cancer" and dxOvarian_surgery = 0 then OVARIAN_SURGERY = 0 ;
		if CANCER_TYPE_MILLIMAN ne "Prostate Cancer" and dxProstate_surgery = 0 then PROSTATE_SURGERY = 0 ;
		if CANCER_TYPE_MILLIMAN ne "Pancreatic Cancer" and dxPancreatic_surgery = 0 then PANCREATIC_SURGERY = 0 ;
		if CANCER_TYPE_MILLIMAN ne "Kidney Cancer" and dxKidney_surgery = 0 then KIDNEY_SURGERY = 0 ;

		SIP_ANAL = ANAL_SURGERY ;
		SIP_BLADDER = BLADDER_SURGERY ;
		SIP_BREAST = BREAST_SURGERY ;
		SIP_FEMALEGU = FEMALEGU_SURGERY ;
		SIP_KIDNEY = KIDNEY_SURGERY ;
		SIP_GASTRO = GASTRO_SURGERY ;
		SIP_HN = HEADNECK_SURGERY ;
		SIP_INT = INTESTINAL_SURGERY ;
		SIP_LIVER = LIVER_SURGERY ;
		SIP_LUNG = LUNG_SURGERY ;
		SIP_OVARIAN = OVARIAN_SURGERY ;
		SIP_PROSTATE = PROSTATE_SURGERY ;
		SIP_PANCREATIC = PANCREATIC_SURGERY ;
		***************************************************** ;

		** For Ambulatory Sensitive Admissions - Reference Documentation for each Condition found in H:\OCM - Oncology Care Model\98 - Documentation\Documentation from Other Sources ** ;
		** DRG to MDC Crosswalk found in HCG Code Sets ** ;
		** Admissions for Ambulatory Care Sensitive Conditions (ACSCs). These are conditions for which appropriate ambulatory care can prevent or reduce 
		   the need for hospitalization. Claims included in this measure met the criteria for the conditions listed below. The criteria for these conditions come from Version 6.0 
			of the Prevention Quality Indicators Technical Specifications Updates, although the baseline feedback reports used Version 5.0, which was the most recent version 
			available at the time the baseline reports were being produced. 
			o Diabetes short-term complications
			o Perforated appendix
			o Diabetes long-term complications
			o COPD or asthma in older adults
			o Hypertension
			o Heart failure
			o Dehydration
			o Bacterial pneumonia
			o Urinary tract infection
			o Uncontrolled diabetes
			o Asthma in younger adults
			o Lower-extremity amputation among patients with diabetes ** ;
		IP_DIABSTC = 0 ; IP_PERF = 0 ; IP_DIABLTC = 0 ; IP_COPD = 0 ; IP_HYPER = 0 ; IP_HF = 0 ; IP_DEHY = 0 ; 
		IP_PNEU = 0 ; IP_UTI = 0 ; IP_DIABUN = 0 ; IP_ASTHMA = 0 ; IP_LOWER = 0 ; IP_CF = 0 ; IP_CKD = 0 ; 
		IP_CARDIAC = 0 ; IP_DIALYSIS = 0 ;  IP_DEHY2 = 0 ; IP_RENAL = 0 ; IP_SICKLE = 0 ; IP_IMMUNO = 0 ; 
		IP_KIDNEY = 0 ; IP_CYSYTIC = 0 ; IP_D= 0 ; IP_LP = 0 ; IP_TRAUMA = 0 ; 
		car_t = 0;

		ARRAY dv3a (x) ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD25 ;
		ARRAY d3a  (x) ICD_DGNS_CD1-ICD_DGNS_CD25 ;
		ARRAY PV3  (x) ICD_PRCDR_VRSN_CD1-ICD_PRCDR_VRSN_CD25 ;
		ARRAY P3   (x) ICD_PRCDR_CD1-ICD_PRCDR_CD25 ;
		DO x = 1 TO dim(dv3a) ;
			if dv3a = "0" then do ;	
				if substr(d3a,1,4) in ('K352','K353') then IP_PERF = 1 ;
				IF D3a IN ('E840','Q322','E8411','Q323','E8419','Q324','E848','Q330','E849','Q331','J8483','Q332','J84841','Q333','J84842','Q334',
						  'J84843','Q335','J84848','Q336','P270','Q338','P271','Q339','P278','Q340','P279','Q341','Q254','Q348','Q311','Q349',
						  'Q312','Q390','Q313','Q391','Q315','Q392','Q318','Q393','Q319','Q394','Q320','Q893','Q321') THEN IP_CF = 1 ;
				IF D3a IN ('I129','I1310') THEN IP_CKD = 1 ;
				IF D3a IN ('E860','E869','E861') THEN IP_DEHY2 = 1 ;
				IF D3a IN ('I120','N185','I1311','N186','I132') THEN IP_RENAL = 1 ;
				IF D3a IN ('D5700','D5740','D5701','D57411','D5702','D57412','D571','D57419','D5720','D5780',
						  'D57211','D57811','D57212','D57812','D57219','D57819') THEN IP_SICKLE = 1 ;
				IF PUT(D3a,$IMMUNOD.) = "Y" THEN IP_IMMUNO = 1 ;
				IF D3a IN ('N110','Q6232','N111','Q6239','N118','Q624','N119','Q625','N1370','Q6260','N1371',
						  'Q6261','N13721','Q6262','N13722','Q6263','N13729','Q6269','N13731','Q627','N13732',
						  'Q628','N13729','Q630','N139','Q631','Q600','Q532','Q601','Q633','Q602','Q638','Q603',
						  'Q639','Q604','Q6410','Q605','Q6411','Q606','Q6412','Q6100','Q6419','Q6101','Q642',
						  'Q6102','Q6431','Q6111','Q6432','Q6119','Q6433','Q612','Q6439','Q613','Q645','Q614',
						  'Q646','Q615','Q6470','Q618','Q6471','Q619','Q6472','Q620','Q6473','Q6210','Q6474',
						  'Q6211','Q6475','Q6212','Q6479','Q622','Q648','Q6231','Q649') THEN IP_KIDNEY = 1 ;
				IF D3a IN ('E1010','E1144','E1011','E1149','E1021','E1151','E1022','E1152','E1029','E1159','E10311','E11610'
						  'E10319','E11618','E10321','E11620','E10329','E11621','E10331','E11622','E10339','E11628',
						  'E10341','E11630','E10349','E11638','E10351','E11641','E10359','E11649','E1036','E1165',
						  'E1039','E1169','E1040','E118','E1041','E119','E1042','E1300','E1043','E1301','E1044',
						  'E1310','E1049','E1311','E1051','E1321','E1052','E1322','E1059','E1329','E10610','E13311',
						  'E10618','E13319','E10620','E13321','E10621','E13329','E10622','E13331','E10628','E13339',
						  'E10630','E13341','E10638','E13349','E10641','E13351','E10641','E13351','E10649','E13359',
						  'E1065','E1336','E1069','E1339','E108','E1340','E109','E1341','E1100','E1342','E1101','E1343',
						  'E1121','E1344','E1122','E1349','E1129','E1351','E11311','E1352','E11319','E1359','E11321',
						  'E13610','E11329','E13618','E11331','E13620','E11339','E13621','E11341','E13622','E11349',
						  'E13628','E11351','E13630','E11359','E13638','E1136','E13641','E1139','E13649','E1140',
						  'E1365','E1141','E1369','E1142','E138','E1143','E139') THEN IP_D = 1 ;
				if d3a in ('S78011A','S98011A','S78012A','S98012A','S78019A','S98019A','S78021A','S98021A','S78022A',
						  'S98022A','S78029A','S98029A','S78111A','S98111A','S78112A','S98112A','S78119A','S98119A',
						  'S78121A','S98121A','S78122A','S98122A','S78129A','S98129A','S78911A','S98131A','S78912A',
						  'S98132A','S78919A','S98139A','S78921A','S98141A','S78922A','S98142A','S78929A','S98149A',
						  'S78929A','S98149A','S88011A','S98211A','S88012A','S98212A','S88019A','S98219A','S88021A',
						  'S98221A','S88022A','S98222A','S88029A','S98229A','S88111A','S98311A','S88112A','S98312A',
						  'S88119A','S98319A','S88121A','S98321A','S88122A','S98322A','S88129A','S98329A','S88911A',
						  'S98911A','S88912A','S98912A','S88919A','S98919A','S88921A','S98921A','S88922A','S98922A',
						  'S88929A','S98929A') THEN IP_TRAUMA = 1 ;
			END ;

			if pv3 = "0" then do ;
				IF P3 IN ('03170AD','031709F','03170AF','03170JD','031209D','03170JF','031209F','03170KD','03120AD',
						  '03170KF','03120AF','03170ZD','03120JD','03170ZF','03120JF','031809D','03120KD','031809F',
						  '03120KF','03180AD','03120ZD','03180AF','03120ZF','03180AF','03120ZF','03180JD','031309D',
						  '03180JF','031309F','03180KD','03031AD','03180KF','03130AF','03180ZD','03130JD','03180ZF',
						  '03130JF','031909F','03130KD','03190AF','03130KF','03190JF','03130ZD','03190KF','03130ZF',
						  '03190ZF','031409D','031A09F','031409F','031A0AF','03140AD','031A0JF','03140AF','031A0KF',
						  '03140JD','031A0ZF','03140JF','031B09F','03140KD','031B0AF','03140KF','031B0JF','03140ZD',
						  '031B0KF','031509D','031C0AF','03150AD','031C0JF','03150AF','031C0KF','03150JD','031C0ZF',
						  '03150JF','03PY07Z','03150KD','03PY0JZ','03150KF','03PY0KZ','03150ZD','03PY37Z','03150ZF',
						  '03PY3JZ','031609D','03PY3KZ','031609F','03PY47Z','03160AD','03PY4JZ','03160AF','03PY4KZ',
						  '03160JD','03WY0JZ','03160JF','03EY3JZ','03160KD','03WY4JZ','03160KF','03WYXJZ','03160ZD',
						  '05HY33Z','03160ZF','06HY33Z','031709D') THEN IP_DIALYSIS = 1 ;		
				IF PUT(P3,$CARDIAC.) = "Y" THEN IP_CARDIAC = 1 ;
				IF PUT(P3,$IMMUNOP.) = "Y" THEN IP_IMMUNO = 1 ;
				IF P3 IN ('0Y620ZZ','0Y6M0Z5','0Y630ZZ','0Y6M0Z6','0Y640ZZ','0Y6M0Z7','0Y670ZZ','0Y6M0Z8','0Y680ZZ','0Y6M0Z9',
						  '0Y6C0Z1','0Y6M0ZB','0Y6C0Z2','0Y6M0ZC','0Y6C0Z3','0Y6M0ZD','0Y6D0Z1','0Y6M0ZF','0Y6D0Z2','0Y6N0Z0',
						  '0Y6D0Z3','0Y6N0Z4','0Y6F0ZZ','0Y6N0Z5','0Y6G0ZZ','0Y6N0Z6','0Y6H0Z1','0Y6N0Z7','0Y6H0Z2','0Y6N0Z8',
						  '0Y6H0Z3','0Y6N0Z9','0Y6J0Z1','0Y6N0ZB','0Y6J0Z2','0Y6N0ZC','0Y6J0Z3','0Y6N0ZD','0Y6M0Z0','0Y6N0ZF',
						  '0Y6M0Z4') THEN IP_LP = 1 ;
				IF P3 in ('XW033C3','XW043C3') then car_t=1;
			end ;

		END ;

		*** Ages 18 and older. *** ;
		if PRNCPAL_DGNS_CD in ('E1010','E1011','E10641','E1065','E1100','E1101','E11641','E1165') and SRC_ADMS NOTIN ('4','5','6') THEN IP_DIABSTC = 1;
	    if SRC_ADMS IN ('4','5','6') or DRG_CD in ('775','765','766','767','768','769','770','774','776','777','778','779','780','781','782') then IP_PERF = 0 ;
		if PRNCPAL_DGNS_CD in ('E1021','E1121','E1022','E1122','E1029','E1129','E10311','E11311','E10319','E11319','E10321','E11321','E10329','E11329',
							   'E10331','E11331','E10339','E11339','E10341','E11341','E10349','E11349','E10351','E11351','E10359','E11359','E1036','E1136',
							   'E1039','E1139','E1040','E1140','E1041','E1141','E1042','E1142','E1043','E1143','E1044','E1144','E1049','E1149',
							   'E1051','E1151','E1052','E1152','E1059','E1159','E10610','E11610','E10618','E11618','E10620','E11620','E10621','E11621',
							   'E10622','E11622','E10628','E11628','E10630','E11630','E10638','E11638','E1069','E1169','E108','E118') AND
							   SRC_ADMS NOTIN ('4','5','6') THEN IP_DIABLTC = 1;
		IF (IP_DIALYSIS = 1 AND IP_CKD = 1) OR IP_CARDIAC = 1 THEN HYPER_EXCL = 1 ;
		if PRNCPAL_DGNS_CD in ('I10','I129','I119','I310') AND 
		   SRC_ADMS NOTIN ('4','5','6') AND HYPER_EXCL NE 1 THEN IP_HYPER = 1;
		if PRNCPAL_DGNS_CD in ('I0981','I5030','I110','I5031','I130','I5032','I132','I5033','I501','I5040',
							   '5020','I5041','I5021','I042','I5022','I5043','I5023','I509') AND 
			SRC_ADMS NOTIN ('4','5','6') and IP_CARDIAC NE 1 THEN IP_HF = 1 ;
		if (PRNCPAL_DGNS_CD in ('E860','E861','E869') OR
			(PRNCPAL_DGNS_CD in ('E870','A080','A0839','A0811','A084','A0819','A088','A082','A09','A0831','K5289',
								 'A0832','K529','N170','N179','N171','N19','N172','N990','N178') AND IP_DEHY2 = 1) ) AND 
			SRC_ADMS NOTIN ('4','5','6') and IP_RENAL NE 1 THEN IP_DEHY = 1 ;
		if PRNCPAL_DGNS_CD in ('J13','J159','J14','J160','J15211','J168','J15212','J168','J15212','J180','J153','J181',
							   'J154','J188','J157','J189') AND
			SRC_ADMS NOTIN ('4','5','6') AND IP_SICKLE NE 1 AND IP_IMMUNO NE 1 THEN IP_PNEU = 1 ;
		if PRNCPAL_DGNS_CD in ('N10','N2885','N119','N2886','N12','N3000','N151','N3001','N159','N3090','N16',
							   'N3091','N2884','N390') AND
			SRC_ADMS NOTIN ('4','5','6') AND IP_KIDNEY NE 1 AND IP_IMMUNO NE 1 THEN IP_UTI = 1 ;
		if PRNCPAL_DGNS_CD in ('E1065','E10649','E1165','E11649') AND SRC_ADMS NOTIN ('4','5','6') THEN IP_DIABUN = 1 ;

		IF IP_D = 1 AND IP_LP = 1 THEN IP_LOWER = 1 ;
		if SRC_ADMS IN ('4','5','6') or DRG_CD in ('775','765','766','767','768','769','770','774','776','777','778','779','780','781','782') OR 
			IP_TRAUMA = 1 THEN IP_LOWER = 0 ;


		*** Ages 40 and older. *** ;
		if PRNCPAL_DGNS_CD in ('J410','J439','J411','J440','J418','J441','J42','J449','J430','J470','J431','J471','J432','J479','J438',
							   'J4521','J4552','J4522','J45901','J4531','J45902','J4532','J45990','J4541','J45991','J4542','J45998','J4551')  AND
			SRC_ADMS NOTIN ('4','5','6') AND IP_CF = 0 THEN IP_COPD = 1 ;

		*** Ages 18-39. *** ;
		if PRNCPAL_DGNS_CD in ('J4521','J4552','J4522','J45901','J4531','J45902','J4532','J45990','J4541','J45991','J4542',
							   'J45998','J4551') AND 
			SRC_ADMS NOTIN ('4','5','6') AND IP_CF NE 1 THEN IP_ASTHMA = 1 ;

				*** End of Life variables *** ;
		FORMAT WIN_30_DOD MMDDYY10. ;
		WIN_30_DOD = INTNX('DAY',DOD,-29,'SAME') ;
		*** 6/2: As per OCM Ticket Number 799812 - inpatient metrics are screened by admit date, not discharge date. *** ;
		IF IP_CAH = 1 THEN DO ;
			IF (WIN_30_DOD LE ADMSN_DT LE DOD) THEN IP_ALLCAUSE_30 = 1 ; 
		END;
		*** 6/2: As per OCM Ticket Number 799812 - inpatient metrics are screened by admit date, not discharge date. *** ;
		IF ICU = 1 THEN DO ;
			IF (WIN_30_DOD LE ADMSN_DT LE DOD) THEN IP_ICU_30 = 1 ; 
		END ;
		IF DOD NE . AND IP_ALLCAUSE_30 NE 1 THEN IP_ALLCAUSE_30 = 0 ;
		IF DOD NE . AND IP_ICU_30 NE 1 THEN IP_ICU_30 = 0 ;

		*** Premier Request: Death in Hospital *** ;
		if IP_CAH = 1 AND ((ADMSN_DT LE DOD LE DSCHRGDT) OR STUS_CD = "20") then died_in_hosp = 1 ;

		******************************************************* ;


		DROP I L;
		DROP HAS_CANCER %canc_flags BMT_ALLOGENEIC BMT_AUTOLOGOUS
			 /*BMT_ALLOGENEIC_AK BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL
			 BMT_AUTOLOGOUS_AK BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL*/
			 ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
			 OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY 
			 dxANAL_SURGERY dxBLADDER_SURGERY dxBREAST_SURGERY dxFEMALEGU_SURGERY dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY dxLIVER_SURGERY dxLUNG_SURGERY
			 dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY 
			  DOD;
run;

**** Identification of Continuous Stays **** ;
*** As per OCM, claims are considered as belonging to the same stay if they have the same beneficiary ID
	and date of admission.  Singular admissions include stays that overlay with other stays, or are transfers.
	Transfers are defined as a discharge from one acute hospitalization to another acute hospitalization
	on the same day, where the discharge date of one hospitalization equals the admission date on another
	acute hospitalization **** ;


*** Step I1: Identify acute hospitalizations *** ;
DATA ACUTE NONACUTE ;
	SET SC_ip_&bl._&ds. ;
	IF IP_CAH = 1 THEN OUTPUT ACUTE ; 
	ELSE OUTPUT NONACUTE ;

*** Step I2: Identify nested stays and transfers *** ;
PROC SORT DATA =ACUTE ; BY BENE_ID EP_ID ADMSN_DT DSCHRGDT ;

DATA ACUTE2 ;
	SET ACUTE ; BY BENE_ID EP_ID ADMSN_DT ;
	FORMAT PREV_ADM  PREV_DIS MMDDYY10. ;
	IF DSCHRGDT = . THEN DSCHRGDT = THRU_DT ;
	IF FIRST.EP_ID  THEN DO ;
		IP_CASE = 1 ;
		PREV_IP = IP_CASE ;
		PREV_ADM = ADMSN_DT ;
		PREV_DIS = DSCHRGDT ;
	END ;
	ELSE DO ;
		IF PREV_ADM LE ADMSN_DT LE PREV_DIS THEN IP_CASE = PREV_IP ; *** nested/overlapping stays *** ;
		ELSE IF PREV_DIS = ADMSN_DT THEN IP_CASE = PREV_IP ; *** transfers *** ;
		ELSE IP_CASE=SUM(PREV_IP,1) ;
		PREV_IP = IP_CASE ;
		PREV_ADM = ADMSN_DT ;
		PREV_DIS = DSCHRGDT ;
	END ;

	RETAIN PREV_IP PREV_ADM PREV_DIS;

*** Step I3: Assign nonacute stays to case number *** ;
PROC SORT DATA=NONACUTE ; BY BENE_ID EP_ID CLM_ID ;
DATA NONACUTE2 ;
	SET NONACUTE ; BY BENE_ID EP_ID CLM_ID ;
	FORMAT PREV_ADM  PREV_DIS MMDDYY10. ;
	IF DSCHRGDT = . THEN DSCHRGDT = THRU_DT ;
	IF FIRST.EP_ID THEN DO ;
		IP_CASE = 10001 ;
		PREV_CASE = IP_CASE ;
		PREV_ADM = ADMSN_DT ;
		PREV_DIS = DSCHRGDT ;
		PREV_CLM = CLM_ID ;
	END ;
	ELSE DO ;
		IF PREV_ADM LE ADMSN_DT LE PREV_DIS THEN IP_CASE = PREV_CASE ; *** nested/overlapping stays *** ;
		ELSE IF PREV_DIS = ADMSN_DT THEN IP_CASE = PREV_CASE ; *** transfers *** ;
		ELSE IF CLM_ID = PREV_CLM THEN IP_CASE = PREV_CASE ;
		ELSE IP_CASE = SUM(PREV_CASE,1) ;
		PREV_CASE = IP_CASE ;
		PREV_ADM = ADMSN_DT ;
		PREV_DIS = DSCHRGDT ;
		PREV_CLM = CLM_ID ;
	END ;

	RETAIN PREV_CASE PREV_CLM PREV_ADM PREV_DIS;
	

*** Step I4: Set flags by case *** ;
*** Per OCM Ticket response 798221: Inpatient expenditure amounts are assigned on a claim basis using the ADMSN_DT. If a transfer or 
    overlapping/nested hospitalization has an ADMSN_DT within the quarter, then its expenditures are included in the Inpatient categories.
	The combined inpatient stay would be counted in both utilization categories. This applies to any of the variations on the inpatient 
	admissions utilization measure. If one claim of the combined stay satisfies the criteria for the admissions measure, then the entire 
	stay is considered to satisfy the criteria. If multiple criteria are met, then the stay is counted in the multiple utilization categories. *** ;
DATA ALL ; SET ACUTE2 NONACUTE2 ;
proc sort data=all ; by bene_id  EP_ID IP_CASE ;
proc means data=all noprint max ; by bene_id EP_ID ip_case ;
	var ip_cah ip_chemo_admin IP_DIABSTC IP_PERF IP_DIABLTC IP_COPD IP_HYPER IP_HF IP_DEHY 
		IP_PNEU IP_UTI IP_DIABUN IP_ASTHMA IP_LOWER IP_CF IP_CKD 
		IP_CARDIAC IP_DIALYSIS  IP_DEHY2 IP_RENAL IP_SICKLE IP_IMMUNO 
		IP_KIDNEY IP_CYSYTIC IP_D IP_LP IP_TRAUMA IP_ALLCAUSE_30 IP_ICU_30
		IP_BMT_AK IP_BMT_L IP_BMT_MM IP_BMT_MDS IP_BMT_CL SIP_ANAL SIP_BLADDER SIP_BREAST SIP_FEMALEGU 
		SIP_GASTRO SIP_HN SIP_INT SIP_LIVER SIP_LUNG SIP_OVARIAN SIP_PROSTATE SIP_PANCREATIC SIP_KIDNEY IP_ER 
		READM_CAND;
	output out=case_level (drop = _type_ _freq_)
		   max() =  ip_cah_case ip_chemo_admin_case IP_DIABSTC_case IP_PERF_case IP_DIABLTC_case 
					IP_COPD_case IP_HYPER_case IP_HF_case IP_DEHY_case IP_PNEU_case IP_UTI_case 
					IP_DIABUN_case IP_ASTHMA_case IP_LOWER_case IP_CF_case IP_CKD_case 
					IP_CARDIAC_case IP_DIALYSIS_case  IP_DEHY2_case IP_RENAL_case IP_SICKLE_case 
					IP_IMMUNO_case IP_KIDNEY_case IP_CYSYTIC_case IP_D_case IP_LP_case IP_TRAUMA_case 
					IP_ALLCAUSE_30_case IP_ICU_30_case IP_BMT_AK_case IP_BMT_L_case IP_BMT_MM_case 
					IP_BMT_MDS_case IP_BMT_CL_case SIP_ANAL_case SIP_BLADDER_case SIP_BREAST_case SIP_FEMALEGU_case 
					SIP_GASTRO_case SIP_HN_case SIP_INT_case SIP_LIVER_case SIP_LUNG_case SIP_OVARIAN_case
					SIP_PROSTATE_case SIP_PANCREATIC_case SIP_KIDNEY_CASE IP_ER_CASE READM_CAND_CASE ;


DATA INPATIENT1  ;
	merge ALL(in=a) 
           case_level(in=b) ; 
		   BY BENE_ID EP_ID IP_CASE ;
PROC SORT DATA=INPATIENT1 ; BY BENE_ID EP_ID CLM_ID ;

DATA INPATIENT2 ; 
	SET INPATIENT1 ; BY BENE_ID EP_ID CLM_ID ;
	IF FIRST.CLM_ID THEN IP_LOS = UTIL_DAY ;

*** Step I5: Identify Index and Readmissions. *** ;
*** IPR MACRO outputs file IPR_FINAL - which will contain index and readmit flags to merge back onto final file. *** ;
*** First macro variable is input file from previous date step.
	Second macro variable is time period of analysis - bl for baseline, pp for performance period. *** ;
%IPR(INPATIENT2,pp);

PROC FREQ DATA=IPR_FINAL ; 
	TABLES HAS_READMISSION UNPLANNED_READMIT_FLAG ;
TITLE "&DS. - Check that count of admissions with a readmission match count of number of readmissions - OUTPUT OF IP_READMISSIONS" ; run ;

*** Step I6: Create final file. *** ;

PROC SORT DATA=INPATIENT2 ; BY BENE_ID EP_ID IP_CASE ADMSN_DT DSCHRGDT;

DATA ip_combine ; 
	MERGE INPATIENT2(IN=A) IPR_FINAL(IN=B) ; BY BENE_ID EP_ID IP_CASE ;
	if a ;
	IF B=0 THEN DO ;
		INDEX_ADMIT = 0 ;
		UNPLANNED_READMIT_FLAG = 0 ;
	END ;

DATA OUTFINAL.SC_ip_&bl._&ds. ; 
	set ip_combine ;  BY BENE_ID EP_ID IP_CASE ;

	*** Only assigning latest claim of a case to HAS_READMISSION - all other lines in flagged case = 9 **** ;
	*** Only assigning earliest claim of a case to UNPLANNED_READMIT_FLAG - all other lines in flagged case = 9 **** ;
	IF FIRST.IP_CASE THEN DO ;
		READM_COUNT = UNPLANNED_READMIT_FLAG ;
		INDEX_COUNT = INDEX_ADMIT;
		IF LAST.IP_CASE NE 1 AND INDEX_ADMIT = 1 THEN DO ;
			HAS_READMISSION = 9 ;
			INDEX_ADMIT = 9 ;
		END ;
		FIRST_CASE = 1 ;
	END ;
	ELSE IF LAST.IP_CASE THEN DO ;
		IF FIRST.IP_CASE NE 1 THEN UNPLANNED_READMIT_FLAG = 9 ;
		LAST_CASE = 1 ;
	END ;
	ELSE DO ;
		IF INDEX_ADMIT = 1 THEN DO ;
			HAS_READMISSION = 9 ;
			INDEX_ADMIT = 9 ;
		END ;
		UNPLANNED_READMIT_FLAG = 9 ;
	END ;

	IF INDEX_ADMIT NOTIN (1,9) THEN HAS_READMISSION = . ;
	IF IP_CAH NE 1 THEN DO ;
		HAS_READMISSION = . ;
		INDEX_ADMIT = . ;
		UNPLANNED_READMIT_FLAG = . ;
	END ;


PROC FREQ DATA=OUTFINAL.SC_ip_&bl._&ds. ;
	TABLES HAS_READMISSION UNPLANNED_READMIT_FLAG ;
TITLE "&DS. - Check that count of admissions with a readmission match count of number of readmissions - AFTER MERGE WITH CLAIMS FILE" ; run ;


%mend IP ;


**************************************************************************************
*************************** OP COST MODEL LOGIC ***************************************
***************************************************************************************;
%MACRO OP ;

PROC SQL ;
	CREATE TABLE OUTPATIENT AS
	SELECT A.*, B. *
	FROM EPI_DOD AS A, out.OUTPATIENT_&bl._&ds. AS B
	WHERE A.BENE_ID = B.BENE_ID AND
	      A.EP_BEG LE REV_DT LE A.EP_END ;
QUIT ;

**** Identify ER claims **** ;
data er clms ;
	set OUTPATIENT(WHERE = (NOPAY_CD = "  ")) ;
	if 	REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 ; 
	*ALLOWED =SUM(REVPMT,PTNTRESP);
	ALLOWED = REVPMT ;
	IF CLM_REV_STD_PYMT_AMT = . THEN CLM_REV_STD_PYMT_AMT = ALLOWED ;
	**** Initializing Service Category **** ;
	FORMAT SERVICE_CAT $50.; length SERVICE_CAT $50. ; 
	SERVICE_CAT = "    " ;

			OP_CAH = 0 ; 
		IF ('0001' LE SUBSTR(PROVIDER,3,4) LE '0879') OR 
		   ('1300' LE SUBSTR(PROVIDER,3,4) LE '1399') THEN OP_CAH = 1 ;

	*** 5/10/17 - remove lines where rev_cntr = 0001 *** ;
	if rev_cntr = "0001" then delete ;

		%canc_init ; /*chemosens1 = 0 ; chemosens2 = 0 ;*/
		ARRAY v (I) ICD_DGNS_VRSN_CD1 ;
		ARRAY d (I) ICD_DGNS_CD1 ;
		DO I = 1 TO 1 ;
			%CANCERTYPE(v, d) ;
			D3 = SUBSTR(left(d),1,3) ;
			D4 = SUBSTR(left(d),1,4) ;
			D5 = SUBSTR(left(d),1,5) ;
			D6 = SUBSTR(left(d),1,6) ;
			D7 = SUBSTR(left(d),1,7) ;
			/*
			if v = "9" and put(d,$Chemo_Sens_ICD9_.) = "Y" then chemosens1 = 1 ;
			if v = "0" then do ;
				if put(D3,$Chemo_Sens_ICD10_3_.) = "Y" then chemosens1 = 1 ;
				if put(D4,$Chemo_Sens_ICD10_4_.) = "Y" then chemosens1 = 1 ;
				if put(D5,$Chemo_Sens_ICD10_5_.) = "Y" then chemosens1 = 1 ;
				if put(D6,$Chemo_Sens_ICD10_6_.) = "Y" then chemosens1 = 1 ;
				if put(D7,$Chemo_Sens_ICD10_7_.) = "Y" then chemosens1 = 1 ;
			end ;*/
		END ;
		%JAN2017 ;
		has_cancer_primary = has_cancer ;

		ARRAY v2 (l) ICD_DGNS_VRSN_CD2-ICD_DGNS_VRSN_CD25 ;
		ARRAY d2 (l) ICD_DGNS_CD2-ICD_DGNS_CD25 ;
		DO l = 1 TO DIM(D2);
			D3 = SUBSTR(left(d2),1,3) ;
			D4 = SUBSTR(left(d2),1,4) ;
			D5 = SUBSTR(left(d2),1,5) ;
			D6 = SUBSTR(left(d2),1,6) ;
			D7 = SUBSTR(left(d2),1,7) ;
			/*
			if v2 = "9" and put(d2,$Chemo_Sens_ICD9_.) = "Y" then chemosens2 = 1 ;
			if v2 = "0" then do ;
				if put(D3,$Chemo_Sens_ICD10_3_.) = "Y" then chemosens2 = 1 ;
				if put(D4,$Chemo_Sens_ICD10_4_.) = "Y" then chemosens2 = 1 ;
				if put(D5,$Chemo_Sens_ICD10_5_.) = "Y" then chemosens2 = 1 ;
				if put(D6,$Chemo_Sens_ICD10_6_.) = "Y" then chemosens2 = 1 ;
				if put(D7,$Chemo_Sens_ICD10_7_.) = "Y" then chemosens2 = 1 ;
			end ;*/
		END ;
		DROP I L;
		DROP HAS_CANCER %canc_flags ;

		*** 5/31/17 - Using OCM identification of ED and OBS, Not Milliman algorithm *** ;
		er_pre=0 ; OBS_PRE=0 ; ER_CHEM_PRE = 0 ; OBS_CHEM_PRE = 0 ; 
				IF '0450' LE REV_CNTR LE '0459' OR REV_CNTR = '0981' THEN DO ;
						IF REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 THEN DO ;
							ER_pre = 1 ;
							IF "70000" LE HCPCS_CD LE "89999" OR 
							    HCPCS_CD IN ('G0106','G0120','G0122','G0130','G0202','G0204','G0206','G0219',
											 'G0235','G0252','G0255','G0288','G0389','S8035','S8037','S8040',
											 'S8042','S8080','S8085','S8092','S9024') THEN ER_pre = 0 ;
						END ;
				END ;
	   
				IF REV_CNTR = '0762' OR
				  (REV_CNTR = '0760' AND HCPCS_CD = "G0378" AND REV_UNIT GE 8) THEN DO ;
						IF REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 THEN DO ;
							OBS_PRE = 1 ;
				  	END ;
				END ;

		*if ER_pre = 1 AND (CHEMOSENS1 =1 OR (CHEMOSENS2 = 1 AND HAS_CANCER_PRIMARY = 1 )) then ER_Chem_pre = 1;
		*if OBS_pre = 1 AND (CHEMOSENS1 =1 OR (CHEMOSENS2 = 1 AND HAS_CANCER_PRIMARY = 1 )) then OBS_Chem_pre = 1;


	if (er_Pre = 1 or obs_pre = 1 )  then output er;
	output clms ;

run ;

proc sort data=er ; by bene_id EP_ID clm_id thru_dt rev_dt;
proc means data=er noprint max ; by bene_id EP_ID clm_id thru_dt  rev_dt;
	var er_pre obs_pre  /*er_chem_pre obs_chem_pre*/ ;
	output out=erclms (drop = _type_ _freq_)
		   max() = ;
run ;

proc sort data=clms ; by bene_id EP_ID clm_id thru_dt rev_dt; 

data OP1 ;
	merge clms(in=a drop=er_pre obs_pre /*er_chem_pre obs_chem_pre*/ )	
		  erclms(in=b keep=bene_id ep_id clm_id thru_dt rev_dt er_pre obs_pre /*er_chem_pre obs_chem_pre*/ ) ; 
	by bene_id EP_ID clm_id thru_dt rev_dt;
	if a ;
	if a  and b then er_claim = 1 ; 
	else er_claim = 0 ;
run;

proc sort data=out.outhdr_wrecon_&ds. OUT=op_h ; by  EP_ID BENE_ID CLM_ID ; run ;
proc sort data=out.outval_wrecon_&ds. (where=(val_cd='17')) OUT=op_v ; by  EP_ID BENE_ID CLM_ID ; run ;

data OP_val;
		merge op_h(in=a) op_v(in=b) ; 
		by  EP_ID BENE_ID CLM_ID ; 
		if a and b ;
		drop ep_id;
run;
proc sql ;
    create table OP_val2 as
    select b.*, a.*
    from epi_dod as a, OP_val as b
    where a.BENE_ID=b.BENE_ID and
          a.ep_beg le B.FROM_DT le a.ep_end ;
quit ;
data OP3;
	format rev_cntr $20. ;
	set OP_val2;

	REV_DT = FROM_DT;
	rev_cntr = 'Outpatient Outlier';
	ALLOWED = VAL_AMT ;
    CLM_REV_STD_PYMT_AMT = CLM_STD_OUTLIER_PYMT_AMT ;
	IF CLM_REV_STD_PYMT_AMT = . THEN CLM_REV_STD_PYMT_AMT = ALLOWED ;
run;

data outfinal.SC_op_&bl._&ds. ;
	format rev_cntr $20. ;
	set OP1	
		OP3 ; 

		***  5/4/17: Chemotherapy, Drug and Rad Once Assignments Overrides any other Non-IP assignment. *** ;

		BLAD_LR = 0 ; PROST_CAST = 0 ; BLAD_OTH = 0 ; PROST_OTH = 0 ;
		IF PUT(HCPCS_CD,$Bladder_LR_HCPCS.) = "Y" THEN BLAD_LR = 1 ;
		IF PUT(HCPCS_CD,$Prostate_CS_HCPCS.) = "Y" THEN PROST_CAST = 1 ;

		if (rev_dt lt mdy(1,2,2017) and put(HCPCS_CD,$Chemo_J.) = "Y") or
   		   (mdy(1,2,2017) le rev_dt le mdy(7,1,2017) and put(HCPCS_CD,$Chemo_J2p.) = "Y")    or
   		   (mdy(7,2,2017) le rev_dt and put(HCPCS_CD,$Chemo_J3p.) = "Y")  or
		   (mdy(1,2,2018) le rev_dt and put(HCPCS_CD,$Chemo_J4p.) = "Y")  or
		   (mdy(7,2,2018) le rev_dt and put(HCPCS_CD,$Chemo_J5p.) = "Y")  then DO ;
			SERVICE_CAT = 'Chemotherapy Drugs (Part B)';
			IF BLAD_LR NE 1 THEN BLAD_OTH = 1 ;
			IF PROST_CAST NE 1 THEN PROST_OTH = 1 ;
		BC_Hormonal = 0 ;
		Nonhormonal = 1 ; 
		END ;
		*** Chemotherapy Categories *** ;
		else if put(hcpcs_cd,$anti.) = 'Y' then SERVICE_CAT = 'Anti-emetics' ;
		**************************************************************** ;
		else if put(hcpcs_cd,$chemo_admin.) = 'Y' then SERVICE_CAT = 'Chemotherapy Administration';
		else if put(rev_cntr,$addl_rev_chemo_admin.) = "Y" then SERVICE_CAT = 'Chemotherapy Administration';
		else if put(hcpcs_cd,$Hemat_agents_J.) = 'Y' then SERVICE_CAT = 'Hematopoietic Agents';
		ELSE IF PUT(HCPCS_CD,$adjuncts_hcpcs.) = 'Y' THEN SERVICE_CAT = 'Chemotherapy Adjuncts' ;

		else if put(hcpcs_cd,$RAD_ONC.) = 'Y' then SERVICE_CAT = 'Radiation Oncology';
		else if PUT(rev_cntr,$RAD_ONC_REV.) = 'Y'  then SERVICE_CAT = 'Radiation Oncology';

		else if er_claim = 1 then do ;
			*if sum(obs_chem_pre,er_chem_pre) > 0 then SERVICE_CAT = "Emergency: Chemo Sensitive" ;
			*else if sum(obs_pre,er_pre) > 0 then SERVICE_CAT = "Emergency: Non-Chemo Sensitive" ;
			IF SUM(OBS_PRE, ER_PRE) > 0 THEN SERVICE_CAT = "Emergency Department" ;
		end ;

	car_t = 0;
	if hcpcs_cd in ('Q2040','Q2041') then car_t = 1;


	if SERVICE_CAT = '' then do ;

		if put(hcpcs_cd,$OP_CS.) = 'Y' and has_cancer_primary=1 then SERVICE_CAT = "Outpatient Surgery: Cancer";
		else if hcpcs_cd = "  " and put(rev_cntr,$ADDL_SURG_REV_OPS.)  = "Y"  and has_cancer_primary=1 then SERVICE_CAT = "Outpatient Surgery: Cancer";
		else if put(hcpcs_cd,$P11_HCPCS.) = 'Y' then SERVICE_CAT = "Outpatient Surgery: Non-Cancer" ;
		else if hcpcs_cd = "  " and put(rev_cntr,$ADDL_SURG_REV_OPS.)  = "Y"  then SERVICE_CAT = "Outpatient Surgery: Non-Cancer" ;

		ElSE IF HCPCS_CD IN ("J9212","J9215","J9600") then service_cat = 'Other Drugs and Administration';

			*** Radiology/Lab Categories *** ;
			else if put(hcpcs_cd,$RAD_HTI.) = 'Y' then SERVICE_CAT = 'Radiology: High Tech (MRI, CT, PET)';
			else if put(rev_cntr,$rad_hti_rev.) = 'Y' then SERVICE_CAT = 'Radiology: High Tech (MRI, CT, PET)';
			else if substr(hcpcs_cd,1,1) = '7' and hcpcs_cd notin ('78267','78268') then  SERVICE_CAT = 'Radiology: Other';
			else if put(hcpcs_cd,$P55_CPTS.) = 'Y' then SERVICE_CAT = 'Radiology: Other';
			else if put(rev_cntr,$rad_other_rev.) = 'Y' then SERVICE_CAT = 'Radiology: Other';
			else if put(hcpcs_cd,$lab_cpt.) = 'Y' OR SUBSTR(hcpcs_cd,1,1) = '8' then SERVICE_CAT = 'Lab';
			else if put(rev_cntr,$lab_rev.) = 'Y' then SERVICE_CAT = 'Lab';
			*** Anesthesia not for surgery presumed to be for radiology/lab procedure. *** ;
			else if put(rev_cntr,$ane_rev.) = 'Y' then SERVICE_CAT = 'Radiology: Other'; 
			else if put(hcpcs_cd,$P13_HCPCS.) = 'Y' then SERVICE_CAT = "Radiology: Other" ;		

			*** Catch-All Categories *** ;
			else if put(hcpcs_cd,$p34_cpt.) = 'Y' then SERVICE_CAT = 'Other Drugs and Administration';
			else if put(rev_cntr,$p34_rev.) = "Y" then SERVICE_CAT = 'Other Drugs and Administration';
			else SERVICE_CAT = 'Outpatient: Other'; 
		end ;

%MEND OP ;


**************************************************************************************
************************** PB,DME COST MODEL LOGIC ***********************************
************************************************************************************** ;

%MACRO pb ;

%MEOS(out.phyline_wrecon_&ds.,epi_dod,out.phyline_lmeos_&ds.,out.meos_&ds.) ;
**** Note to analyst: Check that the records counts of the work file MEOS are the same as
     out.meos_&ds.  We should not lose any MEOS claims in this process. **** ;

DATA LINES ;
	set out.phyline_lmeos_&ds.(in=p) out.dmeline_wrecon_&ds.(in=d)  ;
		if p then prof = 1 ; 
		if d then dme = 1 ;


proc sql ;
	create table lines2 as 
	select a.*, b.*
	from epi_dod as a, lines as b
	where a.bene_id=b.bene_id and
		  a.ep_beg le expnsdt1 le a.ep_end ;
quit ;


**** Identify ER claims **** ;
data er clms ;
	
	set lines2 out.meos_&ds. ;

	if LALOWCHG > 0 ;  *** REMOVAL OF DENIED CLAIMS **** ;

	*allowed = LALOWCHG;
	allowed = LINEPMT ;
	IF CLM_LINE_STD_PYMT_AMT = . THEN CLM_LINE_STD_PYMT_AMT = ALLOWED ;
	**** Initializing Service Category **** ;
	FORMAT SERVICE_CAT $50.; length SERVICE_CAT $50. ; 
	SERVICE_CAT = "    " ;

		er_pre=0 ; OBS_PRE=0 ; UC_PRE=0 ; 
		if put(HCPCS_CD,$ER_CPT.) = 'Y' then ER_pre = 1;
		if put(hcpcs_cd,$OBS_CPT.) = 'Y' then OBS_pre = 1 ;
		if put(hcpcs_cd,$UC.) = 'Y' then UC_pre = 1 ;

	if er_Pre = 1 or obs_pre = 1 or uc_pre = 1 then output er;
	output clms ;

run ;

proc sort data=er ; by bene_id ep_id clm_id thru_dt EXPNSDT1 ;
proc means data=er noprint max ; by bene_id ep_id clm_id thru_dt EXPNSDT1 ;
	var er_pre obs_pre uc_pre ;
	output out=erclms (drop = _type_ _freq_)
		   max() = ;
run ;

*** 5/5/17: Identify unique ED dates of service to roll radiology claims occurring on same day into Professional: Emergency *** ;
proc sort data=er out=er_dos(keep=ep_id bene_id EXPNSDT1) nodupkey ; by bene_id ep_id EXPNSDT1 ;

**** Identify OP Surgical claims **** ;
proc sort data=clms ; by bene_id ep_id EXPNSDT1;
data clms2 ;
	merge clms(in=a) er_dos(in=b) ; by bene_id ep_id EXPNSDT1;
	if a ;
	format er_date mmddyy10. ;
	if a and b then er_date = expnsdt1 ;

proc sort data=clms2 ; by bene_id ep_id clm_id thru_dt EXPNSDT1;
data outfinal.SC_pb_&bl._&ds.  ;
	merge clms2(in=a drop=er_pre obs_pre uc_pre)	
		  erclms(in=b keep=bene_id ep_id clm_id thru_dt EXPNSDT1 er_pre obs_pre uc_pre) ; 
	by bene_id ep_id clm_id thru_dt EXPNSDT1;
	if a ;

	%canc_init ;
	%CANCERTYPE(LINE_ICD_DGNS_VRSN_CD, LINE_ICD_DGNS_CD) ;
	%JAN2017 ;

	***  5/4/17: Chemotherapy, Drug and Rad Once Assignments Overrides any other Non-IP assignment. *** ;

	BLAD_LR = 0 ; PROST_CAST = 0 ; BLAD_OTH = 0 ; PROST_OTH = 0 ;
	IF PUT(HCPCS_CD,$Bladder_LR_HCPCS.) = "Y" THEN BLAD_LR = 1 ;
	IF PUT(HCPCS_CD,$Prostate_CS_HCPCS.) = "Y" THEN PROST_CAST = 1 ;
	if (expnsdt1 le mdy(1,1,2017) and put(HCPCS_CD,$Chemo_J.) = "Y") or
	   (mdy(1,2,2017) le expnsdt1 le mdy(7,1,2017) and put(HCPCS_CD,$Chemo_J2p.) = "Y") or
	   (expnsdt1 ge mdy(7,2,2017) and put(HCPCS_CD,$Chemo_J3p.) = "Y") 		or 
	   (expnsdt1 ge mdy(1,2,2018) and put(HCPCS_CD,$Chemo_J4p.) = "Y") 	    or		
	   (expnsdt1 ge mdy(7,2,2018) and put(HCPCS_CD,$Chemo_J5p.) = "Y") 	then DO ;		
		SERVICE_CAT = 'Chemotherapy Drugs (Part B)';
		IF BLAD_LR NE 1 THEN BLAD_OTH = 1 ;
		IF PROST_CAST NE 1 THEN PROST_OTH = 1 ;
		BC_Hormonal = 0 ;
		Nonhormonal = 1 ; 
	END ;


	*** Chemotherapy Categories *** ;
	else if put(hcpcs_cd,$anti.) = 'Y' then SERVICE_CAT = 'Anti-emetics' ;
	else if put(hcpcs_cd,$chemo_admin.) = 'Y' then SERVICE_CAT = 'Chemotherapy Administration';
	else if put(hcpcs_cd,$Hemat_agents_J.) = 'Y' then SERVICE_CAT = 'Hematopoietic Agents';
	ELSE IF PUT(HCPCS_CD,$adjuncts_hcpcs.) = 'Y' THEN SERVICE_CAT = 'Chemotherapy Adjuncts' ;

	else if put(hcpcs_cd,$RAD_ONC.) = 'Y' then SERVICE_CAT = 'Radiation Oncology';

	ELSE if a and b then SERVICE_CAT = "Professional: Emergency" ;

	if SERVICE_CAT = '' then do ;

			if plcsrvc = '21' then SERVICE_CAT = "Professional: Inpatient" ;
			else if put(hcpcs_cd,$P11_HCPCS.) = 'Y' then SERVICE_CAT = "Professional: Surgery" ;		
			else if put(hcpcs_cd,$P13_HCPCS.) = 'Y' then SERVICE_CAT = "Professional: Anesthesia" ;
			else if HAS_CANCER = 1 and HCPCS_CD in ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215') then do;
				if TAX_NUM = EPI_ATT_TIN THEN SERVICE_CAT = 'Professional: Qualifying E&M Visits at Attrib TIN' ;	
				else SERVICE_CAT = 'Professional: Qualifying E&M Visits at Other TINs' ;
			end;	
			else if put(hcpcs_cd,$P32_CPTS.) = 'Y' then SERVICE_CAT = "Professional: Office Visit" ;		

			ElSE IF HCPCS_CD IN ("J9212","J9215","J9600") then service_cat = 'Other Drugs and Administration';

			*** Radiology/Lab Categories *** ;
			else if put(hcpcs_cd,$RAD_HTI.) = 'Y' then SERVICE_CAT = 'Radiology: High Tech (MRI, CT, PET)';
			else if substr(hcpcs_cd,1,1) = '7' and hcpcs_cd notin ('78267','78268') then  SERVICE_CAT = 'Radiology: Other';
			else if put(hcpcs_cd,$P55_CPTS.) = 'Y' then SERVICE_CAT = 'Radiology: Other';
			else if put(hcpcs_cd,$lab_cpt.) = 'Y' OR SUBSTR(hcpcs_cd,1,1) = '8' then SERVICE_CAT = 'Lab';

			*** Catch-All Categories *** ;
			else if DME = 1 then SERVICE_CAT = "DME" ;
			else if put(hcpcs_cd,$p34_cpt.) = 'Y' then SERVICE_CAT = 'Other Drugs and Administration';
			else SERVICE_CAT = 'Professional: Other'; 
	end ;

	*** Reassign radiology claims occurring on same day as ED visit to Professional: Emergency *** ;
	if expnsdt1 = er_date and service_cat in ("Radiology: High Tech (MRI, CT, PET)","Radiology: Other") then service_cat = "Professional: Emergency" ;

run ;
%mend pb ;

**************************************************************************************
********************* File Based Assignments, Part D *********************************
************************************************************************************** ;
%macro oth ;

DATA SNF1 ;
	SET out.SNFHDR_wrecon_&ds. ;

proc sql ;
	create table snf2 as
	select a.*, b.*
	from epi_dod as a, snf1 as b
	where a.bene_id=b.bene_id and
		  ep_beg le ADMSN_DT le ep_end ;
quit ;

*** 5/4/2017 - Updated to roll SNF claims up to admission, not  claim level. *** ;
DATA SNF_CLAIMS ;
	set SNF2 (where = (nopay_cd="  ")) ;
	ADMIT_ID = BENE_ID||PROVIDER||ADMSN_DT ;
	DROP DOD EP_BEG EP_END ;
	IF CLM_STD_PYMT_AMT = . THEN CLM_STD_PYMT_AMT = PMT_AMT ;

PROC SORT DATA=SNF_CLAIMS ; BY BENE_ID EP_ID ADMIT_ID THRU_DT ;

DATA SNF_CHARS(DROP = UTIL_DAY PMT_AMT CLM_STD_PYMT_AMT DSCHRGDT)  ;
	SET SNF_CLAIMS ; BY BENE_ID EP_ID ADMIT_ID THRU_DT ;
	IF LAST.ADMIT_ID ;
PROC MEANS DATA=SNF_CLAIMS NOPRINT MAX SUM ; BY BENE_ID EP_ID ADMIT_ID ;
	VAR DSCHRGDT UTIL_DAY PMT_AMT CLM_STD_PYMT_AMT;
	OUTPUT OUT=SNF_CLAIMS2 (DROP = _tYPE_ _FREQ_)
		   MAX(DSCHRGDT) = 
		   SUM(UTIL_DAY PMT_AMT CLM_STD_PYMT_AMT) = ;

data outfinal.SC_snf_&bl._&ds. ;
	MERGE SNF_CHARS(IN=A) SNF_CLAIMS2(IN=B) ; BY BENE_ID EP_ID ADMIT_ID ;
	IF A AND B ;
	FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
	SERVICE_CAT = "SNF" ;
	*ALLOWED = sum(PMT_AMT, DED_AMT, COIN_AMT, BLDDEDAM);
	ALLOWED = PMT_AMT ;
	IF FIRST.ADMIT_ID THEN SNF_COUNT = 1 ;

 DATA HHA ;
	set out.hhahdr_wrecon_&ds.(where = (nopay_cd="  ")) ;

PROC SQL ;
	CREATE TABLE HHA2 AS
	SELECT A.*, B.*
	FROM EPI_DOD AS A, HHA AS B
	WHERE A.BENE_ID = B.BENE_ID AND
		  EP_BEG LE FROM_DT LE EP_END ;
QUIT ; 

data outfinal.SC_hha_&bl._&ds. ;
	SET HHA2 ;
	FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
	SERVICE_CAT = "Home Health" ;
	ALLOWED = PMT_AMT ;
	HH_COUNT = VISITCNT ;
	IF CLM_STD_PYMT_AMT = . THEN CLM_STD_PYMT_AMT = ALLOWED ;

*********************************************************************** ;
	**************** Hospice Metrics *************** ;
*********************************************************************** ;

*** 5/15/17 Capturing Facility and Non-Facility Flags **** ;
data HSPCODES ;
	SET out.hspREV_wrecon_&ds.  ;
	IF HCPCS_CD IN ('Q5003','Q5004','Q5005','Q5006','Q5007','Q5008','Q5010',
					'Q5001','Q5002') ;
	IF HCPCS_CD IN ('Q5003','Q5004','Q5005','Q5006','Q5007','Q5008','Q5010') THEN HSP_FAC = 1 ;
	ELSE HSP_FAC = 0 ;

	IF HCPCS_CD IN ('Q5001','Q5002') THEN HSP_HOME = 1 ; ELSE HSP_HOME = 0 ;

PROC SQL ;
	CREATE TABLE HSPCODES_A  AS
	SELECT A.*, B.*
	FROM EPI_DOD AS A, HSPCODES AS B
	WHERE A.BENE_ID=B.BENE_ID AND
	EP_BEG LE REV_DT LE EP_END ;
QUIT ;

DATA HSPCODES2 ;
	SET HSPCODES_A ;
		FORMAT WIN_30_DOD MMDDYY10. ; 
		WIN_30_DOD = INTNX('DAY',DOD, -29, 'SAME') ;
			IF (WIN_30_DOD LE REV_DT LE DOD) THEN DO ;
			    HOSP_30DAYS = 1 ;
				HSP_FAC_30 = HSP_FAC ;
				HSP_HOME_30 = HSP_HOME ;
			END ;

PROC SORT DATA=HSPCODES2 ; BY BENE_ID EP_ID CLM_ID THRU_DT ;

PROC MEANS DATA=HSPCODES2 NOPRINT MAX ; by bene_id EP_ID CLM_ID THRU_DT ;
	VAR HOSP_30DAYS HSP_FAC HSP_HOME HSP_FAC_30 HSP_HOME_30 ;
	OUTPUT OUT=HSP_FLAGS (DROP = _TYPE_ _FREQ_)
		   MAX() = ;

DATA HOSP1 ;
	SET out.HSPHDR_wrecon_&DS.   ;

PROC SQL ;
	CREATE TABLE HOSP1_A AS
	SELECT A.*, B. *
	FROM EPI_DOD AS A, HOSP1 AS B
	WHERE A.BENE_ID=B.BENE_ID AND
		  EP_BEG LE FROM_DT LE EP_END ;
QUIT ;

PROC SORT DATA=hosp1_A ; by bene_id EP_ID clm_id thru_dt ;
data hosp2  ;
	merge hosp1_a(in=a) hsp_flags(IN=B) ; by bene_id EP_ID clm_id thru_dt ;
	IF A ;
	IF A AND B=0 THEN DO ;
		HSP_FAC=0 ; HSP_HOME = 0 ;
	END ;
	IF NOPAY_CD = "  " ;
		ANY_HSP_BOTH = 0 ; ANY_HSP_FAC = 0 ; ANY_HSP_HOME = 0 ; ANY_HSP_UNK = 0 ;
		IF HOSP_30DAYS = 1 THEN DO ;
				IF HSP_FAC_30 = 1 AND HSP_HOME_30 = 1 THEN ANY_HSP_BOTH = 1 ;
				ELSE IF HSP_FAC_30 = 1 THEN ANY_HSP_FAC = 1 ;
				ELSE IF HSP_HOME_30 = 1 THEN ANY_HSP_HOME = 1 ; 
				ELSE ANY_HSP_UNK = 1 ;
	END ;


**** 5/15/17: Looking at care in 90, 30, and 3 days within date of death  ****** ;
	IF DOD NE . AND FROM_DT GE EP_BEG THEN DO ;
		FORMAT WIN_90_DOD WIN_30_DOD MMDDYY10. ; 
		WIN_90_DOD = INTNX('DAY',DOD, -89, 'SAME') ;
		WIN_30_DOD = INTNX('DAY',DOD, -29, 'SAME') ;
			IF (WIN_90_DOD LE FROM_DT LE DOD) OR
			   (WIN_90_DOD LE THRU_DT LE DOD)	THEN DO ;
				HOSP_DAYS_90 = SUM((THRU_DT - MAX(FROM_DT,WIN_90_DOD)),1) ;
			END ; 
	end ;
	*** Standardized amount only provided on header *** ;
	IF FIRST.CLM_ID THEN STD_PAY = CLM_STD_PYMT_AMT ; 

*** 5/4/2017 - Updated to roll Hospice claims up to period, not  claim level. *** ;
PROC SORT DATA=hosp2 OUT=HOSPICE ; BY BENE_ID EP_ID PROVIDER FROM_DT THRU_DT ;

DATA  HOSPICE2;
	SET HOSPICE ; BY BENE_ID EP_ID PROVIDER FROM_DT THRU_DT ;
	FORMAT PREV_THRU MMDDYY10. ;
	IF FIRST.PROVIDER THEN DO ; STAY = 1 ; PREV_THRU = THRU_DT ; END ;
	ELSE DO ;
		IF PREV_THRU NE . AND 0 LE (FROM_DT-PREV_THRU) LE 1 THEN STAY =STAY ;
		ELSE STAY = SUM(STAY,1) ;
		PREV_THRU = THRU_DT ;
	END ;
	RETAIN PREV_THRU STAY ; 

	FAC_PMT_AMT = PMT_AMT * HSP_FAC ;
	HOME_PMT_AMT = PMT_AMT * HSP_HOME ;
	IF HSP_FAC = 1 AND HSP_HOME = 1 THEN DO ;
		FAC_PMT_AMT = 0 ; HOME_PMT_AMT = 0 ; BOTH_PMT_AMT = PMT_AMT ; 
	END ;

	IF std_pay = . THEN std_pay = PMT_AMT ;

PROC SORT DATA=HOSPICE2 ; BY BENE_ID EP_ID PROVIDER STAY FROM_DT THRU_DT ;

DATA HSP_CHAR(DROP = PMT_AMT STD_PAY FROM_DT ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME ANY_HSP_UNK HOSP_30DAYS
					 FAC_PMT_AMT HOME_PMT_AMT BOTH_PMT_AMT HOSP_DAYS_90 EP_BEG EP_END ) ;
	SET HOSPICE2 ;BY BENE_ID EP_ID PROVIDER STAY ;
	IF LAST.STAY ;

PROC MEANS DATA =HOSPICE2 NOPRINT MIN MAX SUM ; BY BENE_ID EP_ID PROVIDER STAY ;
	VAR FROM_DT ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME ANY_HSP_UNK HOSP_30DAYS
		PMT_AMT STD_PAY FAC_PMT_AMT HOME_PMT_AMT BOTH_PMT_AMT HOSP_DAYS_90 ;
	OUTPUT OUT=HSP_CLAIMS (DROP = _TYPE_ _FREQ_)
		   min(FROM_DT) = 
		   MAX(ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME ANY_HSP_UNK HOSP_30DAYS) = 
		   SUM(PMT_AMT STD_PAY FAC_PMT_AMT HOME_PMT_AMT BOTH_PMT_AMT HOSP_DAYS_90) = ;
data SC_hsp_&bl._&ds. ;
	MERGE HSP_CHAR(IN=A) HSP_CLAIMS(IN=B) ; BY BENE_ID EP_ID PROVIDER stay ;
	IF A AND B ;
	FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
	SERVICE_CAT = "Hospice" ;
	ALLOWED = PMT_AMT ;
	CLM_STD_PYMT_AMT = STD_PAY ; DROP STD_PAY ;

**** Accounting for same day transfers for day counts **** ;
proc sort data=SC_hsp_&bl._&ds. ; by bene_id EP_ID FROM_DT THRU_DT ;
DATA outfinal.SC_hsp_&bl._&ds. ;
	SET SC_hsp_&bl._&ds. ;by bene_id EP_ID FROM_DT THRU_DT ;
	IF FIRST.ep_ID THEN DO ;
		PT = THRU_DT ;
	END ;
	ELSE DO ;
		IF FROM_DT = PT THEN DO ;
			HOSP_DAYS_90 = HOSP_DAYS_90-1 ;
			CHANGED = 1 ;
		END ;
		PT = THRU_DT ;
	END ;
	RETAIN PT ;

*** This measure needs to be flagged after roll up has occurred. *** ;
*** OCM-3 SPECS: Hospice stays are identified in the Medicare Enrollment Data Base (EDB) by:
1. Beneficiary has at least one Hospice record in the Medicare EDB AND
2. Most recent Hospice End Date is blank OR most recent Hospice End Date = Date of Death AND
3. Date of Death minus Most Recent Hospice Beginning Date = 3.*** ;
PROC SORT DATA=outfinal.SC_hsp_&bl._&ds. OUT=sch; BY BENE_ID EP_ID FROM_DT ;
DATA LATEST ;
	SET SCH ; BY BENE_ID EP_ID FROM_DT ;
	IF LAST.EP_ID AND DOD NE . ;
	IF (THRU_DT = . OR THRU_DT GE DOD) AND  (DOD-FROM_DT GE 3) THEN HOSP_3DAY = 1 ;
	ELSE HOSP_3DAY = 0 ;

PROC SORT DATA=LATEST ; BY BENE_ID EP_ID ;
PROC MEANS DATA=LATEST NOPRINT MAX ; BY BENE_ID EP_ID ;
	VAR HOSP_3DAY ;
	OUTPUT OUT=OCM3(DROP = _TYPE_ _FREQ_)
		   Max() = ;

data pde ;
	set out.pde_wrecon_&ds.   ;
	FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
	SERVICE_CAT = "Other Drugs and Administration" ;
	ndc10 = substr(prod_srvc_id,1,10) ;
	ndc9 = substr(prod_srvc_id,1,9) ;
	ndc8 = substr(prod_srvc_id,1,8) ;


	BLAD_LR = 0 ; BLAD_OTH = 0 ; PROST_CAST = 0 ; PROST_OTH = 0 ;
	IF PUT(NDC9,$Bladder_LR_NDC.) = "Y" THEN BLAD_LR = 1 ;
	IF PUT(NDC9,$Prostate_CS_NDC.) = "Y" THEN PROST_CAST = 1 ;
	if (srvc_dt le mdy(1,1,2017) and (put(NDC9, $Chemo_NDC.) = "Y" or NDC8 = '00780645')) or 
	   (mdy(1,2,2017) le srvc_dt le mdy(7,1,2017) and put(NDC9, $Chemo_NDC2p.) = "Y" ) or 
	   (mdy(7,2,2017) le srvc_dt and put(NDC9, $Chemo_NDC3p.) = "Y" ) or
	   (mdy(1,2,2018) le srvc_dt and put(NDC9, $Chemo_NDC4p.) = "Y" ) or
	   (mdy(7,2,2018) le srvc_dt and put(NDC9, $Chemo_NDC5p.) = "Y" )then DO ;
			SERVICE_CAT = 'Chemotherapy Drugs (Part D)' ;
			IF BLAD_LR NE 1 THEN BLAD_OTH = 1 ;
			IF PROST_CAST NE 1 THEN PROST_OTH = 1 ;
			if put(NDC9, $Hormonal_breast_NDC.) = "Y" then BC_Hormonal = 1 ; else BC_Hormonal = 0 ;
			if put(NDC9, $Hormonal_breast_NDC.) = "N" then Nonhormonal = 1 ; else Nonhormonal = 0 ;
	END ;
	else if put(prod_srvc_id,$adjuncts.) = "Y" then SERVICE_CAT = 'Chemotherapy Adjuncts' ;
	else if put(prod_srvc_id,$hem_ndcs.) = "Y" then SERVICE_CAT = 'Hematopoietic Agents' ;
	else if put(prod_srvc_id,$anti_ndcs.) = "Y" then SERVICE_CAT = 'Anti-emetics' ;

	*** As per PP, Gross Drug Cost: TOT_RX_CST_AMT should be kept on the output file in case we want to summarize. **** ;
	ALLOWED = SUM(LICS_AMT,(.8*GDC_ABV_OOPT_AMT)) ;

run ;


proc sql ;
	create table outfinal.SC_pde_&bl._&ds. as
	select a.*, b.* 
	from epi_dod as a, pde as b
	where a.bene_id = b.bene_id and
	  	  ep_beg le srvc_dt le ep_end ;
quit ;


%mend oth ;

		   
**************************************************************************** ;
**************************************************************************** ;
**************************************************************************** ;

%IP ;
%OP ; 
%PB ;
%oth ;*** Note: OCM3 is created in this macro so will always need to be run. *** ;


**************************************************************************** ;
***************** Creating Episode Level Flags ***************************** ;
**************************************************************************** ;

proc sort data=out.epi_prelim_&bl._&ds. 
	out=epi_ct(keep = bene_id ep_beg ep_end ep_id DOB DOD CANCER_TYPE CANCER_TYPE_MILLIMAN ) ; by BENE_ID ep_id ;



data ALL_CLAIMS_&bl._&DS.(drop=ep_beg ep_end DOD) ;
	format rev_cntr $20. ;
	set outfinal.SC_ip_&bl._&ds.(IN=G)
		outfinal.SC_OP_&bl._&ds.(IN=A) 
		outfinal.SC_PB_&bl._&ds. (IN=B)
		outfinal.SC_PDE_&bl._&ds.(IN=C)
		outfinal.SC_hsp_&bl._&ds.(IN=D)
		outfinal.SC_hha_&bl._&ds(IN=E)
		outfinal.SC_snf_&bl._&ds.(IN=F);
		OCM_ID = "&id." ;

		CLAIM_ID = CLM_ID ;


		IF B THEN SRC = "PB/DME" ;
		IF G THEN SRC = "IP" ;
		IF A THEN SRC = "OP" ;
		IF C THEN SRC = "PD" ;
		IF D THEN SRC = "HSP" ;
		IF E THEN SRC = "HHA" ;
		IF F THEN SRC = "SNF" ;

		FORMAT START_DATE END_DATE ADMIT_DT DSCHRG_DT PART_D_SERVICE_DATE MMDDYY10. ;
		IF G OR F THEN DO ;
				  START_DATE = ADMSN_DT ;
				  END_DATE = DSCHRGDT ;
		END ;
		ELSE IF D OR E THEN DO ; 
				  START_DATE = FROM_DT ; 
				  END_DATE = THRU_DT ;
		END ;

		ELSE IF A THEN DO ;
				  START_DATE = REV_DT ;
				  END_DATE = REV_DT ;
		END ;

		ELSE IF B THEN DO ;
					START_DATE = EXPNSDT1 ;
					END_DATE = EXPNSDT1 ;
		END ;

		IF G OR F THEN DO ;
				ADMIT_DT = ADMSN_DT ;
				DSCHRG_DT = DSCHRGDT ;

		END ;
		*** 5/4/17: LOS to use UTIL_DAY when available. *** ;
		if B OR A OR C OR D OR E THEN LOS = MAX((END_DATE-START_DATE),1) ;
		IF G OR F THEN LOS = UTIL_DAY ;

		IF G OR A OR D OR E OR F THEN PRVDR_NUM = PROVIDER ;
		*** AT_NPI already in data *** ;
		*** OP_NPI already in data *** ;
		*** DRG_CD already in data *** ;
		*** PRFNPI already in data *** ;
		IF DME = 1 THEN PRFNPI = SUP_NPI ;
		ADMIT_DIAG_CD = ADMTG_DGNS_CD ;
		PRINCIPAL_DIAG_CD = PRNCPAL_DGNS_CD ;
		IF B THEN PRINCIPAL_DIAG_CD = LINE_ICD_DGNS_CD ;
		PROCEDURE_CD_VER = ICD_PRCDR_VRSN_CD1 ;
		PROCEDURE_CD = ICD_PRCDR_CD1 ;
		IF C THEN DO ;
			NDC = PROD_SRVC_ID ;
			PART_D_SERVICE_DATE = SRVC_DT ;
			DAYS_SUPPLY = DAYS_SUPLY_NUM ;
		END ;
		FORMAT DATE_SCREEN MMDDYY10. ;
		DATE_SCREEN = MAX(START_DATE,PART_D_SERVICE_DATE) ;


*** Identifying castration sensitive prostate and breast cancer with hormonal treatment only for override of 
	IP chemo sensitive. *** ;
proc sort data=ALL_CLAIMS_&bl._&DS. ; by bene_id ep_id ;
proc means data=ALL_CLAIMS_&bl._&DS. noprint max ; by bene_id ep_id ;
	var BC_Hormonal Nonhormonal PROST_CAST PROST_OTH car_t;
	output out=flagmems (drop = _type_ _freq_)
		   max() = ;

data cs_or (keep = bene_id ep_id override_flag) ;
	merge flagmems epi_dod(keep= bene_id ep_id cancer_type_milliman); by bene_id ep_id ;
	override_flag = 0 ;
	if bc_hormonal = 1 and nonhormonal = 0 and cancer_type_milliman = "Breast Cancer" then override_flag = 1 ;
	if prost_cast = 1 and prost_oth = 0 and cancer_type_milliman = "Prostate Cancer" then override_flag = 1 ;


data t0  ;
	merge ALL_CLAIMS_&bl._&DS.(in=a ) epi_ct(in=b) cs_or; by bene_id EP_ID ;
	if (a and b) or (a and MEOS_PAYMENT = 1);
		  ** Identifying mock episode start and end date. Removes members where died before performance period** ;
		  if ep_end ge ep_beg;

		AGE = INT((EP_BEG-dob)/365.25) ;

		*** FLAGS MOVED FROM 002 PROGRAM 8/2017 *** ;
		IF SRC = "IP" THEN IPU = 1 ;
		IF SRC = "OP" THEN OPU = 1;
		IF SRC = "HSP" THEN HSPU = 1 ;
		IF SRC = "HHA" THEN HHU=1 ;
		IF SRC = "SNF" THEN SNFU=1;
		IF SRC = "PB/DME" THEN PBU = 1 ;
		******************************************* ;

		*** Generation of standardized payment summaries *** ;
		IF SRC IN ("IP","SNF","HHA","HSP") THEN STD_PAY = CLM_STD_PYMT_AMT/.98 ;
		ELSE IF SRC IN ("OP") THEN STD_PAY = CLM_REV_STD_PYMT_AMT/.98 ;
		ELSE IF SRC = "PB/DME" THEN STD_PAY = CLM_LINE_STD_PYMT_AMT/.98 ;
		ELSE STD_PAY = ALLOWED ;


		**** Added 1/8/18 - Removal of facility lines with $0 Paid, with a revenue code but
			 no procedure code. **** ;
		IF SRC notin ("IP","PB/DME") AND ALLOWED = 0 AND HCPCS_CD = "  " AND REV_CNTR NE "  " THEN DELETE ;
		IF HCPCS_CD IN ('85025','36415','80053','80048','85027','96368','J7050','A9270','J7040',
						'96376','96361') AND ALLOWED = 0 THEN DELETE ;



		*** Novel Therapy Flag *** ;
			FORMAT NOVEL_THERAPY $3. ;
			LENGTH NOVEL_THERAPY $3. ;
			NOVEL_THERAPY = "NO" ;
			*IF IDENDC NE "  " THEN NDC9 = SUBSTR(IDENDC,1,9) ;	*** Outpatient revenue NDC indicator *** ;
			*IF LNNDCCD NE " " THEN NDC9 = SUBSTR(LNNDCCD,1,9) ; *** DME NDC indicator *** ;
			IF PROD_SRVC_ID NE " " THEN NDC9 = SUBSTR(PROD_SRVC_ID,1,9) ;
			%NT ;
run;

%NT_COMBO ;

data t5 ;
	merge t0(in=a) t2(in=b) ; by bene_id ep_id ;
	if a ;
	if a and b and  NOVEL_THERAPYe = "YES" then do ;
		%NT2 ;
	end ;
run;

data ALL_CLAIMS2 OCM2_CHK  radonc chemo_partb I1  ;
	set t5 ;

		** Breaking out chemotherapy into types ** ;
		if SERVICE_CAT = 'Chemotherapy Drugs (Part B)' then do ;
			output chemo_partb ;
			if START_DATE ge mdy(7,2,2018) then CPB_CAT = put(HCPCS_CD,$Chemo_J_cat5p.) ;
			else if START_DATE ge mdy(1,2,2018) then CPB_CAT = put(HCPCS_CD,$Chemo_J_cat4p.) ;
			else if START_DATE ge mdy(7,2,2017) then CPB_CAT = put(HCPCS_CD,$Chemo_J_cat3p.) ;
			else CPB_CAT = put(HCPCS_CD,$Chemo_J_cat2p.) ;
			IF CPB_CAT = "N" then CPB_CAT = "Other" ;
			SERVICE_CAT = 'Part B Chemo: '||left(CPB_CAT) ;
		end ;

		if SERVICE_CAT = 'Chemotherapy Drugs (Part D)' then do ;
			if PART_D_SERVICE_DATE ge mdy(7,2,2018) then CPD_CAT = put(NDC9,$Chemo_NDC_cat5p.) ;
			else if PART_D_SERVICE_DATE ge mdy(1,2,2018) then CPD_CAT = put(NDC9,$Chemo_NDC_cat4p.) ;
			else if PART_D_SERVICE_DATE ge mdy(7,2,2017) then CPD_CAT = put(NDC9,$Chemo_NDC_cat3p.) ;
			else CPD_CAT = put(NDC9,$Chemo_NDC_cat2p.) ;
			IF NDC8 = '00780645' THEN CPD_CAT = 'Biologic' ;
			if NDC10 = '5024291701' THEN CPD_CAT = 'Biologic' ;
			IF CPD_CAT = "N" then CPD_CAT = "Other" ;
			SERVICE_CAT = 'Part D Chemo: '||left(CPD_CAT) ;
		end ;

		** Breaking out Rad HT into types ** ;
		IF SERVICE_CAT = "Radiology: High Tech (MRI, CT, PET)" THEN DO ;
			RAD_CAT = put(hcpcs_cd,$Rad_HTI_CAT.) ;
			if RAD_CAT = "N" then RAD_CAT = put(rev_cntr,$Rad_HTI_REVCAT.) ;
			if RAD_CAT = "MRI" then SERVICE_CAT = "Radiology: MRI" ;
			else if RAD_CAT = "CT" then SERVICE_CAT = "Radiology: CT" ;
			else SERVICE_CAT = "Radiology: PET" ;
		end ;

		** Overriding Chemo-Sensitive Flag for HT Only Breast Cancer and CS Prostate Cancer. ** ;
		if override_flag = 1 and service_cat = "Inpatient Medical: Potentially Chemo Related" then
							     service_cat = "Inpatient Medical: Other" ;

			
		format LABEL2 LABEL3 $100. ; length LABEL2 LABEL3 $100. ;
		LABEL2 = SERVICE_CAT ;
		LABEL3 = SERVICE_CAT ;

		FORMAT LABEL1 $50. ; LENGTH LABEL1 $50. ; 
		if service_cat in ("Inpatient: Other","Inpatient Surgical: Cancer",
						  "Inpatient Surgical: Non-Cancer","Inpatient Medical: Potentially Chemo Related",
						  "Inpatient Medical: Other","Emergency Department",
						  "Outpatient Surgery: Cancer", "Outpatient Surgery: Non-Cancer",'Outpatient: Other',
						  "SNF","Home Health","Hospice") then LABEL1 = "Facilities" ;
		else if service_cat in ("Other Drugs and Administration",'Chemotherapy Administration',
							    'Chemotherapy Adjuncts','Hematopoietic Agents','Anti-emetics')
			 OR SUBSTR(SERVICE_CAT,1,12) in ('Part B Chemo','Part D Chemo') then LABEL1 = 'Drugs' ;
		else if service_cat in ('Radiation Oncology','Radiology: MRI','Radiology: CT','Radiology: PET',
								'Radiology: Other','Lab') then LABEL1 = 'Radiation & Lab' ;
		else LABEL1 = 'Professional' ;


		**** Added 12/5/17 - for Reconciliation Page **** ;
		MEOS_COUNT = 0 ; MEOS = 0 ; MEOS_COUNT_OTH = 0 ; MEOS_OTH = 0 ;
		IF HCPCS_CD = "G9678" AND ALLOWED NE 0 THEN do ;
			IF TAX_NUM IN (&ATT_TIN.) THEN DO ;
				MEOS = 1 ;
				MEOS_COUNT = 1 ;
				MEOS_ALLOWED = ALLOWED ;
				MEOS_STD_PAY = STD_PAY ;
				LABEL2 = "Professional: MEOS - Your Practice" ;
				LABEL3 = "Professional: MEOS - Your Practice" ;
			END ;
			ELSE DO ;
				MEOS_OTH = 1 ;
				MEOS_COUNT_OTH = 1 ;
				MEOS_ALLOWED_OTH = ALLOWED ;
				MEOS_STD_PAY_OTH = STD_PAY ;
				LABEL2 = "Professional: MEOS - All Other Practices" ;
				LABEL3 = "Professional: MEOS - All Other Practices" ;
			END ;
		END ;

		else do ;
		IF CPD_CAT NE "  " THEN do ;
			PART_D_CHEMO=1 ;
			IF NOVEL_THERAPY = "YES" THEN DO ;
				LABEL3 = "Part D Chemo: Novel Therapy" ;
				NT_DALL = ALLOWED ;
				NT_DSTD = STD_PAY ;
				NT_D = 1 ;
			END ;

			if service_cat = "Part D Chemo: Cytotoxic" then PART_D_CHEMO_CYTO = 1 ;
			else if service_cat = "Part D Chemo: Biologic" then PART_D_CHEMO_BIO = 1 ;
			else if service_cat = "Part D Chemo: Hormonal" then PART_D_CHEMO_HARM = 1 ;
			else if service_cat = "Part D Chemo: Other" then PART_D_CHEMO_OTH = 1 ;

		END ;

		IF CPB_CAT NE "  " THEN DO ;
			PART_B_CHEMO=1 ;
			IF NOVEL_THERAPY = "YES" THEN DO ;
				LABEL3 = "Part B Chemo: Novel Therapy" ;
				NT_BALL = ALLOWED ;
				NT_BSTD = STD_PAY ;
				NT_B = 1 ;
			END ;
			if service_cat = "Part B Chemo: Cytotoxic" then PART_B_CHEMO_CYTO = 1 ;
			else if service_cat = "Part B Chemo: Biologic" then PART_B_CHEMO_BIO = 1 ;
			else if service_cat = "Part B Chemo: Hormonal" then PART_B_CHEMO_HARM = 1 ;
			else if service_cat = "Part B Chemo: Other" then PART_B_CHEMO_OTH = 1 ;
		end ;

		

		if SERVICE_CAT = "Radiology: MRI" THEN RAD_MRI = 1 ;
		if SERVICE_CAT = "Radiology: CT" THEN RAD_CT = 1 ;
		IF SERVICE_CAT = "Radiology: PET" THEN RAD_PET = 1 ;
		RAD_HT = MAX(0,RAD_MRI,RAD_CT,RAD_PET) ;
	


		if service_cat = "Inpatient: Other" then IPoth = 1  ;
		if service_cat = "Inpatient Surgical: Cancer" then IPSCan = 1 ;
		if service_cat = "Inpatient Surgical: Non-Cancer" then IPSNCan = 1 ;
		if service_cat = "Inpatient Medical: Potentially Chemo Related" then IPMedCS = 1 ;
		if service_cat = "Inpatient Medical: Other" then IPMedNCS = 1 ;
		if SERVICE_CAT = "Emergency Department" then FAC_ER_Chemo = 1 ;
		*if SERVICE_CAT = "Emergency: Non-Chemo Sensitive" then FAC_ER_NonChemo = 1 ;
		if SERVICE_CAT = "Outpatient Surgery: Cancer" then FAC_OPSURG_CANC = 1 ;
		if SERVICE_CAT = "Outpatient Surgery: Non-Cancer" then FAC_OPSURG_NONCANC = 1 ;
		if SERVICE_CAT = 'Anti-emetics' then ANTIEMETICS = 1 ;
		if SERVICE_CAT = 'Chemotherapy Administration' then CHEMO_ADMIN = 1 ;						  
		if SERVICE_CAT = 'Hematopoietic Agents' then HEMATO = 1 ;
		if SERVICE_CAT = 'Radiation Oncology' then RAD_ONC = 1 ;
		if SERVICE_CAT = 'Radiology: Other' then RAD_OTH = 1 ;
		if SERVICE_CAT = 'Lab' then LAB = 1;
		if SERVICE_CAT = 'Other Drugs and Administration' then OTH_DRUG = 1 ; 
		if SERVICE_CAT = 'Outpatient: Other' then OP_OTH = 1 ; 
		if SERVICE_CAT = 'Chemotherapy Adjuncts' then CHEMO_ADJUNCTS = 1 ;
		if SERVICE_CAT = "Professional: Emergency" then PROF_ER = 1 ;
		IF SERVICE_CAT = "Professional: Emergency Chemo Sens" then PROF_ER_CS = 1 ;
		if SERVICE_CAT = "Professional: Inpatient"  then PROF_IP = 1 ;
		if SERVICE_CAT = "Professional: Surgery"  then PROF_SURG = 1 ;		
		if SERVICE_CAT = "Professional: Anesthesia" then PROF_ANES = 1 ;		
		if SERVICE_CAT = "Professional: Office Visit"  then PROF_OV = 1 ;
		if SERVICE_CAT = 'Professional: Qualifying E&M Visits at Attrib TIN'  then EM_ATT_VISIT = 1 ;	
		if SERVICE_CAT = 'Professional: Qualifying E&M Visits at Other TINs'  then EM_OTH_VISIT = 1 ;
		if SERVICE_CAT = "DME"  then DME = 1 ;
		if SERVICE_CAT = 'Professional: Other' then PROF_OTH = 1; 
		IF SERVICE_CAT = 'Other' then OTHER = 1 ;
		IF SERVICE_CAT = 'Hospice' then HOSPICE = 1 ;
		end ;

		*** Beneficiary file fields *** ;
		IF SRC = "IP" THEN DO ;
			if cancer_type_milliman ne "Breast Cancer" then SIP_BREAST = 0 ;
			if cancer_type_milliman ne "Anal Cancer" then SIP_ANAL = 0 ;
			if cancer_type_milliman ne "Liver Cancer" then SIP_LIVER = 0 ;
			if cancer_type_milliman ne "Kidney Cancer" then SIP_KIDNEY = 0 ;
			if cancer_type_milliman ne "Lung Cancer" then SIP_LUNG = 0 ;
			if cancer_type_milliman ne "Bladder Cancer" then SIP_BLADDER = 0 ;
			if cancer_type_milliman ne "Female GU Cancer other than Ovary" then SIP_FEMALEGU = 0 ;
			if cancer_type_milliman ne "Gastro/Esophageal Cancer" then SIP_GASTRO = 0 ;
			if cancer_type_milliman ne "Head and Neck Cancer" then SIP_HN = 0 ;
			if cancer_type_milliman ne "Small Intestine / Colorectal Cancer" then SIP_INT = 0 ;
			if cancer_type_milliman ne "Ovarian Cancer" then SIP_OVARIAN = 0 ;
			if cancer_type_milliman ne "Prostate Cancer" then SIP_PROSTATE = 0 ;
			if cancer_type_milliman ne "Pancreatic Cancer" then SIP_PANCREATIC = 0 ;
			if cancer_type_milliman ne "Acute Leukemia" then IP_BMT_AK = 0 ;
			if cancer_type_milliman ne "Lymphoma" then IP_BMT_L = 0 ;
			if cancer_type_milliman ne "Multiple Myeloma" then IP_BMT_MM = 0 ;
			if cancer_type_milliman ne "MDS" then IP_BMT_MDS = 0  ;
			if cancer_type_milliman ne "Chronic Leukemia" then IP_BMT_CL = 0  ;

			ARRAY VAZ (O) INP_ADMSNS_MILLIMAN INP_EX_MILLIMAN INP_AMB_MILLIMAN;
				DO O = 1 TO DIM(VAZ);
					VAZ = 0 ;
				END ;
			IF IP_CAH = 1 THEN INP_ADMSNS_MILLIMAN = ALLOWED ;
			IF SUM(IP_CHEMO_ADMIN, IP_BMT_AK, IP_BMT_L, IP_BMT_MM, IP_BMT_MDS, IP_BMT_CL, SIP_BREAST,SIP_ANAL,SIP_LIVER, 
				   SIP_LUNG, SIP_BLADDER, SIP_FEMALEGU,SIP_GASTRO, SIP_HN, SIP_INT, SIP_OVARIAN, SIP_PROSTATE, 
				   SIP_PANCREATIC, SIP_KIDNEY) GE 1 THEN EX1 = 0 ; ELSE EX1 = 1 ;
			IF IP_CAH NE 1 THEN EX1 = 0 ;
			INP_EXP_MILLIMAN = ALLOWED*EX1*IP_CAH ;


			IF AGE LT 18 THEN DO ;
					IP_DIABSTC = 0; IP_PERF = 0 ; IP_DIABLTC = 0 ; IP_HYPER = 0 ; IP_HF = 0 ;  IP_DEHY = 0 ;
					IP_PNEU = 0 ; IP_UTI = 0 ; IP_DIABUN = 0 ; IP_LOWER = 0 ;
			END ;

			IF AGE LT 40 THEN IP_COPD = 0 ;
			IF AGE LT 18 OR AGE GT 39 THEN IP_ASTHMA = 0 ;

			ACSC = MAX(IP_DIABSTC, IP_PERF, IP_DIABLTC, IP_COPD, IP_HYPER, IP_HF, IP_DEHY, IP_PNEU, 
					   IP_UTI, IP_DIABUN, IP_ASTHMA, IP_LOWER) ;
			INP_AMB_MILLIMAN = ALLOWED*ACSC ;
			** Case level flags to be used for utilization metrics ** ;
			ACSC_case = MAX(IP_DIABSTC_case, IP_PERF_case, IP_DIABLTC_case, IP_COPD_case, IP_HYPER_case, IP_HF_case, 
							IP_DEHY_case, IP_PNEU_case, IP_UTI_case, IP_DIABUN_case, IP_ASTHMA_case, IP_LOWER_case) ;

		END ;

		IF SRC = "OP" THEN DO ;
			EX1 = 0 ;
				*** Add 1 day to include the day of DOD *** ;
			WIN_30_DOD = INTNX('DAY',DOD,-29,'SAME') ;
			** Observation Stays within window of 30 days of death ** ;
			IF OP_CAH = 1 and 
			   (REV_CNTR = '0762' OR
			   (REV_CNTR = '0760' AND HCPCS_CD = "G0738" AND REV_UNIT GE 8)) THEN DO ;
					IF (WIN_30_DOD LE REV_DT LE DOD) THEN OP_ALLCAUSE_30 = 1 ; 
			END ;

				*** OCM2 - Identification of ED/OBS Visits *** ;
				IF '0450' LE REV_CNTR LE '0459' OR REV_CNTR = '0981' THEN DO ;
						IF REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 THEN DO ;
							ED_OCM2 = 1 ;
							IF "70000" LE HCPCS_CD LE "89999" OR 
							    HCPCS_CD IN ('G0106','G0120','G0122','G0130','G0202','G0204','G0206','G0219',
											 'G0235','G0252','G0255','G0288','G0389','S8035','S8037','S8040',
											 'S8042','S8080','S8085','S8092','S9024') THEN ED_OCM2 = 0 ;
						END ;
				END ;
	   
				IF REV_CNTR = '0762' OR
				  (REV_CNTR = '0760' AND HCPCS_CD = "G0378" AND REV_UNIT GE 8) THEN DO ;
						IF REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 THEN DO ;
							OBS_OCM2 = 1 ;
				  		END ;
				END ;
		END ;
			
		IF SRC = "HSP" THEN DO ;
			HSP_PMT_AMT = ALLOWED ;
			HSP_STD_AMT = STD_PAY ;
			ANYHOSP = 1 ;
		END ;


		********************************** ;
		********************************** ;
		*** Creating Summary allowed amounts for Episode File **** ;
		IF LABEL2 IN ('Part B Chemo: Cytotoxic','Part B Chemo: Biologic','Part B Chemo: Hormonal',
		  			  'Part B Chemo: Other')  THEN DO ;
					CHEMOPB_ALLOWED = ALLOWED ;
					CHEMOPB_STD = STD_PAY ;
					END ;

		IF LABEL2 IN ('Part D Chemo: Cytotoxic','Part D Chemo: Biologic','Part D Chemo: Hormonal',
					  'Part D Chemo: Other') THEN DO ;
					CHEMOPD_ALLOWED = ALLOWED ;
					CHEMOPD_STD = STD_PAY ;
					END ;

		IF LABEL2 = 'Anti-emetics' then DO ;
					ANTIEMETICS_ALLOWED = ALLOWED ;
					ANTIEMETICS_STD = STD_PAY ;
					END ;

		IF LABEL2 = 'Hematopoietic Agents' THEN DO ;
					HEMATOPOIETIC_ALLOWED = ALLOWED ;
					HEMATOPOIETIC_STD = STD_PAY ;
					END ;

		IF LABEL2 in  ('Chemotherapy Administration','Other Drugs and Administration','Chemotherapy Adjuncts') 
					THEN DO ;
					OTHRX_ALLOWED = ALLOWED ;
					OTHRX_STD = STD_PAY ;
					END ;

		IF LABEL1 = 'Radiation & Lab' THEN DO ;
					RADLAB_ALLOWED = ALLOWED ;
					RADLAB_STD = STD_PAY ;
					END ;

		IF LABEL1 = 'Professional' THEN DO ;
					PROF_ALLOWED = ALLOWED ;
					PROF_STD = STD_PAY ;
					END ;

		IF LABEL2 IN ('Inpatient Medical: Other','Inpatient Medical: Potentially Chemo Related',
					  'Inpatient Surgical: Cancer','Inpatient Surgical: Non-Cancer','Inpatient: Other')
				THEN DO ;
					IP_ALLOWED = ALLOWED ;
					IP_STD = STD_PAY ;
					END ;

		IF LABEL2 IN ('Emergency Department') THEN DO;
					ER_ALLOWED = ALLOWED ;
					ER_STD = STD_PAY ;
					END ;

		IF LABEL2 IN ('Outpatient Surgery: Cancer','Outpatient Surgery: Non-Cancer','Outpatient: Other')
			THEN DO ;
					OP_ALLOWED = ALLOWED ;
					OP_STD = STD_PAY ;
					END ;

		IF LABEL2 = 'Hospice' THEN DO ;
					HOSPICE_ALLOWED = ALLOWED ;
					HOSPICE_STD = STD_PAY ;
					END ;

		IF LABEL2 = 'SNF' THEN DO ;
					SNF_ALLOWED = ALLOWED ;
					SNF_STD = STD_PAY ;
					END ;

		IF LABEL2 = 'Home Health' THEN DO ;
					HH_ALLOWED = ALLOWED ;
					HH_STD = STD_PAY ;
					END ;

		********************************** ;
		
		IF DOD NE . THEN DO ;
				*** Add 1 day to include the day of DOD *** ;
				WIN_14_DOD = INTNX('DAY',DOD,-13,'SAME') ;
				IF (WIN_14_DOD LE DATE_SCREEN LE DOD) AND
				   (CPB_CAT NE "   " OR CPD_CAT NE "  ") THEN CHEMO_DEATH14 = 1 ;
		END ;


		*** 2/5: Creating Part B Units_Dose Field **** ;
		IF LABEL2 IN ('Part B Chemo: Cytotoxic','Part B Chemo: Biologic','Part B Chemo: Hormonal',
		  			  'Part B Chemo: Other','Hematopoietic Agents','Anti-emetics',"Other Drugs and Administration",
					  'Chemotherapy Administration','Chemotherapy Adjuncts') THEN DO ;
			IF SRC = "OP" THEN UNITS_DOSE = REV_UNIT ;
			IF SRC = "PB/DME" THEN UNITS_DOSE = SRVC_CNT ;
		END ;


		CANCER_EM = 0 ; EM_ATT = 0 ; 
		if SRC = "PB/DME" and 
		   HCPCS_CD in ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215') and 
		   has_cancer = 1 then do ;
		   		cancer_em = 1 ;
				if TAX_NUM = EPI_ATT_TIN THEN EM_ATT = 1 ;
		END ;
		IF EM_ATT = 1 THEN EM_ATT_TAX = CANCER_EM ;
		ELSE EM_NONATT_TAX =CANCER_EM ;

		if er_claim = 1 then do ;
			ER_DOW = WEEKDAY(DATE_SCREEN) ;
			IF ER_DOW IN (1,7) THEN ER_WEEKEND = 1 ;
			ELSE ER_WEEKEND = 0 ;
		END ;

		********************************** ;
			
		if SERVICE_CAT = 'Radiation Oncology' then output radonc ;
		IF ED_OCM2 =1 OR OBS_OCM2 = 1 THEN OUTPUT OCM2_CHK ;
		IF SRC = "IP" THEN OUTPUT I1 ;
		output ALL_CLAIMS2  ;

*** OCM2 - Seeing whether ED and OBS led to admission *** ;

PROC SQL ;
	CREATE TABLE WADMIT AS
	SELECT A.BENE_ID, A.EP_ID, A.CLM_ID, A.ED_OCM2, A.OBS_OCM2, A.THRU_DT
	FROM OCM2_CHK AS A, out.inpatient_&bl._&ds. AS B 
	WHERE A.BENE_ID = B.BENE_ID AND A.THRU_DT = B.ADMSN_DT ;

PROC SORT DATA=WADMIT ; BY BENE_ID EP_ID CLM_ID THRU_DT ;
PROC MEANS DATA=WADMIT NOPRINT MAX ; BY BENE_ID EP_ID CLM_ID THRU_DT ;
	VAR ED_OCM2 OBS_OCM2 ;
	OUTPUT OUT=WADMIT2 (DROP=_TYPE_ _FREQ_)
		   MAX() = ;

PROC SORT DATA=OCM2_CHK ; BY BENE_ID EP_ID CLM_ID THRU_DT ;
PROC SORT DATA=ALL_CLAIMS2 ; BY BENE_ID EP_ID CLM_ID THRU_DT ;

	DATA O2 ;
	MERGE OCM2_CHK(IN=A) WADMIT2(IN=B DROP=ED_OCM2 OBS_OCM2) ; BY BENE_ID EP_ID CLM_ID THRU_DT ;
	IF A ;
	IF A AND B THEN RESULT_IN_ADMIT = 1 ;
			   ELSE RESULT_IN_ADMIT = 0 ;


PROC MEANS DATA=O2 NOPRINT MAX ; BY BENE_ID EP_ID CLM_ID THRU_DT ;
	VAR ED_OCM2 OBS_OCM2 RESULT_IN_ADMIT ;
	OUTPUT OUT=EDOBS (DROP = _TYPE_ _FREQ_)
		   MAX() = ;


DATA ALL_CLAIMS3 ;
	MERGE ALL_CLAIMS2(IN=A) EDOBS(IN=B) ; BY BENE_ID EP_ID CLM_ID THRU_DT ;
	IF A ;

PROC SORT DATA=ALL_CLAIMS3 ; BY BENE_ID EP_ID CLM_ID THRU_DT FROM_DT REV_DT ;
DATA ALL_CLAIMS3 ;
	SET ALL_CLAIMS3 ;BY BENE_ID EP_ID CLM_ID THRU_DT FROM_DT REV_DT ;
	*** For ED and OBS service counts *** ;
	*** Assigns ER_WEEKEND value TO THAT OF first line ON CLAIM *** ;

	IF FIRST.CLM_ID THEN CLM_COUNT = 1 ;

	IF FIRST.REV_DT THEN DO ;
		ER_CLM_COUNT_FLAG = 1 ;
		PREV_ERW = ER_WEEKEND ;
	END ;
	ELSE DO ;
		ER_WEEKEND = PREV_ERW ;
	END ;
	RETAIN PREV_ERW ;

	*** Added 1/8/18 - Creates distinct count of ED visits on weekend *** ;
	ER_WEEKEND_COUNT = ER_WEEKEND*ER_CLM_COUNT_FLAG ;

	IF SUM(ED_OCM2,OBS_OCM2) > 0 THEN DO ;
		IF RESULT_IN_ADMIT NE 1 THEN DO ;
			OCM2 = 1 ;
			IF OBS_OCM2 = 1 THEN DO ;
				OBS_STAYS = ALLOWED ;
				OBS_STAYS_UTIL = CLM_COUNT ;
			END ;
			IF ED_OCM2 = 1 AND OBS_OCM2 = 1 THEN DO ;
				OBS_ER = ALLOWED ;
				OBS_ER_UTIL = CLM_COUNT ;
			END ;
			IF ED_OCM2 NE 1 AND OBS_OCM2 = 1 THEN DO ;
				OBS_NO_ER = ALLOWED ;
				OBS_NO_ER_UTIL = CLM_COUNT ;
			END ;
			IF ED_OCM2 = 1 AND OBS_OCM2 NE 1 THEN DO ;
				ER_NO_AD_OBS = ALLOWED ;
				ER_NO_AD_OBS_UTIL = CLM_COUNT ;
			END ;
		END ;
		*** Include outpatient records resulting in admissions in beneficiary file expenditure variables. *** ;
		IF RESULT_IN_ADMIT = 1 THEN DO ;
			ER_OBS_AD = ALLOWED ;
			IF ED_OCM2 = 1 AND OBS_OCM2 NE 1 THEN ER_AD = ALLOWED ;
			IF ED_OCM2 NE 1 AND OBS_OCM2 = 1 THEN OBS_AD = ALLOWED ;
			IF ED_OCM2 = 1 AND OBS_OCM2 = 1 THEN ER_AND_OBS_AD = ALLOWED ;
		END ;

			IF ED_OCM2 = 1 THEN DO ;
				IF RESULT_IN_ADMIT = 1 THEN ER_LEADING_TO_IP = 1 ;
				ELSE ER_LEADING_TO_IP = 0 ;
			END ;
		
	END ;
			
PROC SORT DATA=ALL_CLAIMS3 ; BY bene_id  EP_ID ;


*** Gets at number of radiation oncology days for episode level file. *** ;

DATA RADONC ;
	SET RADONC ;
	RO_DATE = START_DATE ;
	FORMAT RO_DATE MMDDYY10. ;
PROC SORT DATA=RADONC NODUPKEY ; BY bene_id EP_ID RO_DATE ;
DATA RADONC ; SET RADONC ; ROC = 1 ;
PROC MEANS DATA=RADONC NOPRINT SUM MIN MAX ; BY bene_id EP_ID ;
	VAR ROC RO_DATE ;
	OUTPUT OUT=ROC_ONC_DAYS(DROP = _TYPE_ _FREQ_)
		   SUM(ROC) = ROC_ONC_DAYS
		   MIN(RO_DATE) = RO_START 
		   MAX(RO_DATE) = RO_END ;
DATA ROC_ONC_DAYS ; SET ROC_ONC_DAYS ; FORMAT RO_START RO_END MMDDYY10. ;  RAD_ONC_LENGTH = SUM(RO_END-RO_START,1) ;

*** Gets at number of chemo part b days and length of part b chemo for episode level file. *** ;
DATA CHEMO_PARTB ;
	SET CHEMO_PARTB ;
	FORMAT TRIGGER_DATE MMDDYY10. ;
	TRIGGER_DATE = expnsdt1 ;
	IF TRIGGER_DATE = . THEN TRIGGER_DATE = rev_dt ;
	TRIGGER = 1 ;

PROC SORT DATA=CHEMO_PARTB NODUPKEY; BY bene_id EP_ID TRIGGER_DATE  ;
PROC MEANS DATA=CHEMO_PARTB NOPRINT MIN MAX SUM ; BY bene_id EP_ID  ;
	VAR TRIGGER TRIGGER_DATE ;
	OUTPUT OUT=PB_DATES(DROP = _TYPE_ _FREQ_)
		   SUM(TRIGGER) = CHEMO_DAYS_PARTB 
		   MIN(TRIGGER_DATE) = FIRST_PARTB
		   MAX(TRIGGER_DATE) = LAST_PARTB ;
DATA PB_DATES ;
	SET PB_DATES ;
	CHEMO_LENGTH_PARTB = SUM(1,LAST_PARTB-FIRST_PARTB) ;

*** Count unique dates of service for ED *** ;
DATA CLMS_OTH EDCLMS ;
	SET ALL_CLAIMS3 ;
	IF SERVICE_CAT in ("Emergency Department") THEN OUTPUT EDCLMS ;
	ELSE OUTPUT CLMS_OTH  ;

proc sort data=EDCLMS ; by bene_id EP_ID REV_DT ;

DATA EDCLMS  ;
	SET EDCLMS ; BY bene_ID EP_ID rev_dt ;
	if first.REV_DT then ER_COUNT = 1 ;
	else ER_COUNT = 0 ;

DATA IP OTHER ;
	SET CLMs_OTH(IN=A) EDCLMS ;
	IF A THEN ER_COUNT = 0 ;
	IF SRC = "IP" THEN OUTPUT IP ;
	ELSE OUTPUT OTHER ;

*** CAPTURE ADMIT COUNT AND ED/OBS FLAGS FROM OP FILE AFTER SCREEN FOR IN EPISODE ADMISSIONS HAS BEEN APPLIED *** ;
PROC SORT DATA=IP ; BY BENE_ID EP_ID CLM_ID ;
PROC SORT DATA=WADMIT ; BY BENE_ID EP_ID CLM_ID  ;
DATA wadmit_a ;
	merge wadmit(in=a) ip(in=b keep = bene_id ep_id ip_case CLM_ID) ; BY BENE_ID EP_ID CLM_ID ;
	IF A ;
PROC SORT DATA=WADMIT_A ; BY BENE_ID EP_ID IP_CASE ;
PROC MEANS DATA=WADMIT_A NOPRINT MAX ; BY BENE_ID EP_ID IP_CASE ;
	VAR ED_OCM2 OBS_OCM2 ;
	OUTPUT OUT=PRE_ADMIT (DROP =_TYPE_ _FREQ_)
		   MAX () = ;

PROC SORT DATA=IP ; BY BENE_ID EP_ID IP_CASE ;

DATA /*READM_TEST OTH_IP*/ IP2;
	MERGE IP(IN=A) PRE_ADMIT(IN=B) ; BY BENE_ID EP_ID IP_CASE ;
	IF A ;
		
		IF SUM(ED_OCM2, OBS_OCM2, IP_ER, IP_OBS ) > 0 THEN ER_OBS_AD = ALLOWED ;
		IF SUM(ED_OCM2,IP_ER) > 0 AND SUM(OBS_OCM2,IP_OBS) < 1 THEN ER_AD = ALLOWED ;
		IF SUM(ED_OCM2,IP_ER) < 1 AND SUM(IP_OBS,OBS_OCM2) > 0 THEN OBS_AD = ALLOWED ;
		IF SUM(ED_OCM2,IP_ER) > 0 AND SUM(IP_OBS,OBS_OCM2) > 0 THEN ER_AND_OBS_AD = ALLOWED ;
		IF SUM(ED_OCM2,IP_ER) < 1 AND SUM(IP_OBS,OBS_OCM2) < 1 THEN NO_ER_NO_OBS_AD = ALLOWED ;
		*** Beneficiary file utilization fields *** ;
			IF FIRST.IP_CASE THEN ADMIT_COUNT = 1 ;
			ELSE ADMIT_COUNT = 0 ;
			INP_ADMSNS_UTIL = ADMIT_COUNT*IP_CAH_CASE ;
			INP_EX_UTIL = ADMIT_COUNT*IP_CAH_case*EX1 ;
			INP_AMB_UTIL = ADMIT_COUNT*ACSC_case ;
			IF IP_ER = 1 OR IP_OBS = 1 THEN ER_OBS_AD_UTIL = ADMIT_COUNT ;
			IF IP_ER = 1 AND IP_OBS NE 1 THEN ER_AD_UTIL  = ADMIT_COUNT  ;
			IF IP_ER NE 1 AND IP_OBS = 1 THEN OBS_AD_UTIL = ADMIT_COUNT ;
			IF IP_ER = 1 AND IP_OBS = 1 THEN ER_AND_OBS_AD_UTIL = ADMIT_COUNT ;
			IF IP_ER NE 1 AND IP_OBS NE 1 THEN NO_ER_NO_OBS_AD_UTIL = ADMIT_COUNT ;
			IF IP_ER_CASE = 1 THEN ADM_FROM_ER_UTIL = ADMIT_COUNT ;

			READMIT_FLAG = 0 ;
			READ_COUNT = 0 ;
			*IF READM_CAND_CASE = 1 THEN OUTPUT READM_TEST ;
			*ELSE OUTPUT OTH_IP ;
run ;
/*
PROC SORT DATA=READM_TEST ; BY BENE_ID EP_ID IP_CASE ;
PROC MEANS DATA=READM_TEST NOPRINT MIN MAX ; BY BENE_ID EP_ID IP_CASE ;
	VAR ADMSN_DT DSCHRGDT ;	
	OUTPUT OUT=CASE_LEVEL(DROP=_TYPE_ _FREQ_)
		   MIN(ADMSN_DT) = 
		   MAX(DSCHRGDT) = ;

PROC SORT DATA=CASE_LEVEL ; BY BENE_ID EP_ID ADMSN_DT DSCHRGDT ;
DATA FLAGS_READM ;
	SET CASE_LEVEL ; BY BENE_ID EP_ID ;
	IF FIRST.EP_ID THEN DO ;
		PREV_DSCH = DSCHRGDT ;
		READ = 0 ;
	END ;
	ELSE DO ;
		IF ADMSN_DT LE SUM(PREV_DSCH+1,29) THEN DO ;
			READ = 1 ;
		END ;
		ELSE DO ;
			READ = 0 ;
		END ;
		PREV_DSCH = DSCHRGDT ;
	END ;

	RETAIN PREV_DSCH ;

PROC SORT DATA=FLAGS_READM ; BY BENE_ID EP_ID IP_CASE ;

DATA READ_FINAL ;
	MERGE READM_TEST(IN=A) FLAGS_READM(IN=B) ; BY BENE_ID EP_ID IP_CASE ;
	IF A ;
	IF A AND B THEN DO ;
		READMIT_FLAG = READ ;
		IF FIRST.IP_CASE THEN READ_COUNT = READ ;
	END ;

*/
DATA outfinal.ALL_CLAIMS_&bl._&DS. MEOS_CLAIMS  ;
	SET /*READ_FINAL OTH_IP*/ ip2 OTHER ;
	format TaxNum_TIN $32.;
	if tax_num in (&att_tin.) then TaxNum_TIN = 'Your TIN (' || strip(tax_num) || ')';
	else TaxNum_TIN = 'Other TIN (' || strip(tax_num) || ')';
	IF MEOS_PAYMENT = 1 THEN OUTPUT MEOS_CLAIMS ;
	IF MEOS_PAYMENT NE 1 OR
	   (MEOS_PAYMENT = 1 AND MEOS_ATT = 1) 
		THEN OUTPUT outfinal.ALL_CLAIMS_&bl._&DS. ;
run ;

PROC SORT DATA=outfinal.ALL_CLAIMS_&bl._&DS.  OUT= CLMS_ALL ; BY bene_ID EP_ID ;


proc means data=clms_all  noprint max sum ; by bene_id  EP_ID ;
	var IPU OPU HSPU HHU SNFU PBU IPOTH IPSCAN IPSNCAN IPMEDCS IPMEDNCS  FAC_ER_CHEMO /*FAC_ER_NONCHEMO*/ FAC_OPSURG_NONCANC
		FAC_OPSURG_CANC ANTIEMETICS CHEMO_ADMIN HEMATO RAD_ONC RAD_HT RAD_OTH LAB OTH_DRUG CHEMO_ADJUNCTS OP_OTH
		PROF_ER PROF_ER_CS PROF_IP PROF_SURG PROF_ANES PROF_OV EM_ATT_VISIT EM_OTH_VISIT DME PROF_OTH HOSPICE OTHER PART_D_CHEMO PART_B_CHEMO 
		PART_B_CHEMO_CYTO PART_D_CHEMO_CYTO PART_B_CHEMO_BIO PART_D_CHEMO_BIO PART_B_CHEMO_HARM 
		PART_D_CHEMO_HARM PART_B_CHEMO_OTH PART_D_CHEMO_OTH RAD_MRI RAD_CT RAD_PET NT_D NT_B 
		ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME ANY_HSP_UNK EX1 IP_ALLCAUSE_30 IP_ICU_30 CHEMO_DEATH14 ANYHOSP 
		OP_ALLCAUSE_30 ED_OCM2 OBS_OCM2 OCM2 HOSP_30DAYS  DIED_IN_HOSP IP_CAH
		ER_WEEKEND CANCER_EM MEOS MEOS_OTH	ADMIT_COUNT ER_COUNT SNF_COUNT HH_COUNT 
		CHEMOPB_ALLOWED CHEMOPD_ALLOWED ANTIEMETICS_ALLOWED
		HEMATOPOIETIC_ALLOWED OTHRX_ALLOWED RADLAB_ALLOWED  PROF_ALLOWED IP_ALLOWED ER_ALLOWED
		OP_ALLOWED HOSPICE_ALLOWED SNF_ALLOWED HH_ALLOWED IP_LOS ADM_FROM_ER_UTIL 
		BLAD_LR BLAD_OTH PROST_CAST PROST_OTH 
		NT_DALL NT_BALL allowed TOT_RX_CST_AMT 
		INP_ADMSNS_MILLIMAN INP_EXP_MILLIMAN ER_COUNT INP_AMB_MILLIMAN
		HSP_PMT_AMT FAC_PMT_AMT HOME_PMT_AMT BOTH_PMT_AMT   HOSP_DAYS_90 
		ER_OBS_AD ER_AD OBS_AD ER_AND_OBS_AD NO_ER_NO_OBS_AD  OBS_STAYS OBS_ER OBS_NO_ER ER_NO_AD_OBS
		INP_ADMSNS_UTIL INP_EX_UTIL INP_AMB_UTIL 
		ER_OBS_AD_UTIL OBS_AD_UTIL ER_AND_OBS_AD_UTIL NO_ER_NO_OBS_AD_UTIL  
		OBS_STAYS_UTIL OBS_ER_UTIL OBS_NO_ER_UTIL ER_NO_AD_OBS_UTIL 
		MEOS_COUNT MEOS_COUNT_OTH MEOS_ALLOWED MEOS_ALLOWED_OTH EM_ATT_TAX EM_NONATT_TAX 
		ER_WEEKEND_COUNT  READ_COUNT 
		CHEMOPB_std CHEMOPD_std ANTIEMETICS_std
		HEMATOPOIETIC_std OTHRX_std RADLAB_std  PROF_std IP_std ER_std
		OP_std HOSPICE_std SNF_std HH_std 
		NT_DSTD NT_BSTD STD_PAY MEOS_STD_pay MEOS_STD_PAY_OTH 
		bc_hormonal nonhormonal READM_COUNT INDEX_COUNT  
		car_t;

	output out=EPI_FLAGS_OP (drop = _type_ _freq_)
		   max(IPU OPU HSPU HHU SNFU PBU IPOTH IPSCAN IPSNCAN IPMEDCS IPMEDNCS  FAC_ER_CHEMO 
			   /*FAC_ER_NONCHEMO*/  FAC_OPSURG_NONCANC FAC_OPSURG_CANC 
			   ANTIEMETICS CHEMO_ADMIN HEMATO RAD_ONC RAD_HT RAD_OTH LAB OTH_DRUG CHEMO_ADJUNCTS OP_OTH
			   PROF_ER PROF_ER_CS PROF_IP PROF_SURG PROF_ANES PROF_OV EM_ATT_VISIT EM_OTH_VISIT DME PROF_OTH HOSPICE OTHER PART_D_CHEMO PART_B_CHEMO
			   	PART_B_CHEMO_CYTO PART_D_CHEMO_CYTO PART_B_CHEMO_BIO PART_D_CHEMO_BIO PART_B_CHEMO_HARM 
				PART_D_CHEMO_HARM PART_B_CHEMO_OTH PART_D_CHEMO_OTH RAD_MRI RAD_CT RAD_PET NT_D NT_B 
				ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME ANY_HSP_UNK EX1 IP_ALLCAUSE_30 IP_ICU_30 CHEMO_DEATH14
				ANYHOSP OP_ALLCAUSE_30 OCM2 HOSP_30DAYS DIED_IN_HOSP IP_CAH
				ER_WEEKEND CANCER_EM MEOS MEOS_OTH BLAD_LR BLAD_OTH PROST_CAST PROST_OTH 
				bc_hormonal nonhormonal
				car_t) =				

			sum(NT_DALL NT_BALL allowed TOT_RX_CST_AMT INP_ADMSNS_MILLIMAN INP_EXP_MILLIMAN ER_COUNT INP_AMB_MILLIMAN
				HSP_PMT_AMT FAC_PMT_AMT HOME_PMT_AMT BOTH_PMT_AMT HOSP_DAYS_90 
				ER_OBS_AD ER_AD OBS_AD ER_AND_OBS_AD NO_ER_NO_OBS_AD OBS_STAYS OBS_ER OBS_NO_ER ER_NO_AD_OBS
				INP_ADMSNS_UTIL INP_EX_UTIL INP_AMB_UTIL 
				ER_OBS_AD_UTIL OBS_AD_UTIL ER_AND_OBS_AD_UTIL NO_ER_NO_OBS_AD_UTIL  
				OBS_STAYS_UTIL OBS_ER_UTIL OBS_NO_ER_UTIL ER_NO_AD_OBS_UTIL ADM_FROM_ER_UTIL 
				ADMIT_COUNT SNF_COUNT HH_COUNT CHEMOPB_ALLOWED CHEMOPD_ALLOWED ANTIEMETICS_ALLOWED
				HEMATOPOIETIC_ALLOWED OTHRX_ALLOWED RADLAB_ALLOWED  PROF_ALLOWED IP_ALLOWED ER_ALLOWED
				OP_ALLOWED HOSPICE_ALLOWED SNF_ALLOWED HH_ALLOWED IP_LOS  				
				MEOS_COUNT MEOS_COUNT_OTH MEOS_ALLOWED MEOS_ALLOWED_OTH 
				
				ER_WEEKEND_COUNT EM_ATT_TAX EM_NONATT_TAX  READ_COUNT
				CHEMOPB_std CHEMOPD_std ANTIEMETICS_std
				HEMATOPOIETIC_std OTHRX_std RADLAB_std  PROF_std IP_std ER_std
				OP_std HOSPICE_std SNF_std HH_std 
				NT_DSTD NT_BSTD STD_PAY MEOS_STD_PAY MEOS_STD_PAY_OTH READM_COUNT INDEX_COUNT) =  
			sum(EM_ATT_VISIT EM_OTH_VISIT) = EM_ATT_VISIT_CHK EM_OTH_VISIT_CHK ;
run ;
**************************************************************************** ;
****************** Creating final episode INTERFACE file. ****************** ;
**************************************************************************** ;

DATA PULL_RECON NOT ;
	SET out.epi_prelim_&bl._&ds. ;
	IF RECON_PP NOT IN (1,2,3) AND ATTRIBUTE_FLAG NE "D" THEN IN_RECON = . ;
	if recon_pp not in (1,2,3) then do ;
		ATT_CANC_MATCH_CMS = . ; ATT_EPI_PERD_MATCH_CMS = . ;
	end ;
	IF IN_RECON IN (4,1) AND ATT_CANC_MATCH_CMS NE 1 AND ATT_EPI_PERD_MATCH_CMS NE 1 THEN OUTPUT PULL_RECON ;
	ELSE OUTPUT NOT ;

PROC SORT DATA=PULL_RECON ; BY BENE_ID EP_ID_A ;

PROC FREQ DATA=PULL_RECON ; 
	TABLES IN_RECON*ATTRIBUTE_FLAG/LIST MISSING ;
TITLE "BEFORE_FOR PULL RECON" ; RUN ;
	
data rec(drop = ep_beg ep_end ep_length recon_elig ) ;
	%IF "&DS." = "290_50202" %THEN %DO ;
	SET REC1.EPIATT&TU1._&ds._PP1(rename = (ep_id=ep_id_a cancer_type=cancer_type_a )) 
		REC1.EPIATT&TU1._567_50200_PP1(rename = (ep_id=ep_id_a cancer_type=cancer_type_a )) 
		REC1.EPIATT&TU1._568_50201_PP1(rename = (ep_id=ep_id_a cancer_type=cancer_type_a )) 
		REC2.EPIATT&TU2._&ds._PP2(rename = (ep_id=ep_id_a cancer_type=cancer_type_a )) 
		REC3.EPIATT&TU3._&ds._PP3(rename = (ep_id=ep_id_a cancer_type=cancer_type_a )) ;
	%END ;
	%ELSE %DO ;
	SET REC1.EPIATT&tu1._&ds._PP1(rename = (ep_id=ep_id_a cancer_type=cancer_type_a ))
		REC2.EPIATT&tu2._&ds._PP2(rename = (ep_id=ep_id_a cancer_type=cancer_type_a ))
		REC3.EPIATT&tu3._&ds._PP3(rename = (ep_id=ep_id_a cancer_type=cancer_type_a ));
	%END ;
run ;

proc sort data=rec ; by bene_id ep_id_A ;

DATA EPI_A(DROP=RECON_ELIG) ;
	MERGE PULL_RECON(IN=A) REC(IN=B) ; BY BENE_ID EP_ID_A ;
	IF A ;
DATA EPI_A2 ;
	SET EPI_A NOT ;

PROC SORT DATA=EPI_A2 ; BY BENE_ID EP_ID ;
run ;

DATA EPIPRE ;
	merge epi_A2(in=a RENAME=(EPI_TAX_ID=TAX EPI_NPI_ID=ENI COMMON_CANCER_TYPE=CCTYPE epi_counter=ec )) 
			EPI_FLAGS_OP ROC_ONC_DAYS PB_DATES OCM3 ; by bene_id EP_ID ;
	IF A ;

	EP_ID_CMS = EP_ID_A ;
	FORMAT CANCER_TYPE $100. qtr_start_date mmddyy10.;
	COMMON_CANCER_TYPE = CCTYPE+0 ;

	OCM_ID = "&id." ;
	AGE = INT((EP_BEG-dob)/365.25) ;

	if ep_end ge ep_beg ; *** removes patients dying before performance period. ;

	*** Assigning QTR_START_DATE to reflect EP_BEG *** ;
		if EP_BEG GE MDY(7,1,2018) THEN QTR_START_DATE = &LATEST_QTR.  ;
		ELSE if EP_BEG GE MDY(4,1,2018) THEN QTR_START_DATE = QTR_START_DATEQ08  ;
		ELSE if EP_BEG GE MDY(1,1,2018) THEN QTR_START_DATE = QTR_START_DATEQ07  ;
		ELSE if EP_BEG GE MDY(10,1,2017) THEN QTR_START_DATE = QTR_START_DATEQ06  ;
		ELSE if EP_BEG GE MDY(7,1,2017) THEN QTR_START_DATE = QTR_START_DATEQ05  ;
		ELSE if EP_BEG GE MDY(4,1,2017) THEN QTR_START_DATE = QTR_START_DATEQ04 ;
		else if EP_BEG GE MDY(1,1,2017) THEN QTR_START_DATE = QTR_START_DATEQ03 ;
		ELSE IF EP_BEG GE MDY(10,1,2016) THEN QTR_START_DATE = QTR_START_DATEQ02 ;
		ELSE QTR_START_DATE = QTR_START_DATEQ01 ;	

	format EPI_COUNTER $50. ; length EPI_COUNTER $50. ;
	EPI_COUNTER = "Performance Episode "||COMPRESS(ec,' ') ;
	IF ATTRIBUTE_FLAG = "D" THEN EPI_COUNTER = "NOT APPLICABLE" ;

	*** Statement only needed for A program *** ;
	%IF "&VERS." = "A" %THEN %DO ;
		IF CANCER_TYPE = "  " THEN CANCER_TYPE = "UNKNOWN" ;
	%END ;
	
	FORMAT CHEMO_UTIL_TYPE $26. ;
	LENGTH CHEMO_UTIL_TYPE $26. ;
	IF PART_D_CHEMO = 1 AND PART_B_CHEMO = 1 then CHEMO_UTIL_TYPE = "Part B and Part D" ;
	ELSE IF PART_D_CHEMO = 1 then CHEMO_UTIL_TYPE = "Part D" ;
	ELSE IF PART_B_CHEMO = 1 then CHEMO_UTIL_TYPE = "Part B" ;
	ELSE CHEMO_UTIL_TYPE = "Chemo Type NA" ;

	** PB_DATES merges in fields CHEMO_DATS_PARTB and CHEMO_LENGTH_PARTB ** ;
	** RAD_ONC_DAYS merges in fields RAD_ONC_DATS and RAD_ONC_LENGTH ** ;

	** MOVED FROM 002 PROGRAM ** ;
	IP_UTIL = MAX(0,IPU) ;
	SNF_UTIL = MAX(0,SNFU) ;
	OP_UTIL = MAX(0,OPU) ;
	HH_UTIL = MAX(0,HHU) ;
	HSP_UTIL = MAX(0,HSPU) ;
	FAC_UTIL = MAX(IP_UTIL, OP_UTIL, SNF_UTIL, HH_UTIL, HSP_UTIL) ;
	PROF_UTIL = MAX(0,PBU) ;
	***************************** ;
	
	IP_MED_CHEMO_UTIL = MAX(0,IPMEDCS) ;
	IP_MED_NON_CHEMO_UTIL = MAX(0,IPMEDNCS) ;
	IP_SURG_CHEMO_UTIL = MAX(0,IPSCAN) ;
	IP_SURG_NON_CHEMO_UTIL = MAX(0,IPSNCAN) ;
	IP_OTHER_UTIL = MAX(0,IPOTH) ;
	**** Added 10/25/17 **** ;
	IP_FROM_ED_UTIL = MAX(0,ADM_FROM_ER_UTIL) ;
	**** Added 1/8/18 **** ;
	IF ADM_FROM_ER_UTIL > 0 THEN IP_FROM_ED = 1 ;
	ELSE IP_FROM_ED = 0 ;

	*** ;
	ER_UG_OBS_UTIL = MAX(0,FAC_ER_CHEMO) ;
	*ER_UG_OBS_UTIL = MAX(ER_CHEMO_UTIL, ER_NON_CHEMO_UTIL) ;
	*ER_CHEMO_UTIL = MAX(0,FAC_ER_CHEMO) ;
	*ER_NON_CHEMO_UTIL = MAX(0, FAC_ER_NONCHEMO) ;

	ER_VISITS_MILLIMAN = MAX(0, ER_COUNT) ;
	OUT_SURG_CANCER_UTIL = MAX(0,FAC_OPSURG_CANC) ;
	OUT_SURG_NONCANCER_UTIL = MAX(0,FAC_OPSURG_NONCANC) ;
	ANTI_EMETICS_UTIL = MAX(0,ANTIEMETICS) ;
	HEMOTAPOETIC_UTIL = MAX(0,HEMATO) ;
	OTHER_DRUGS_UTIL = MAX(0,OTH_DRUG) ;
	CHEMO_ADJ_UTIL = MAX(0,CHEMO_ADJUNCTS) ;
	CHEMO_ADMIN_UTIL = MAX(0, CHEMO_ADMIN) ;
	RAD_HTECH_UTIL = MAX(0,RAD_HT) ;
	RAD_MRI_UTIL = MAX(0,RAD_MRI) ;
	RAD_CT_UTIL = MAX(0,RAD_CT) ;
	RAD_PET_UTIL = MAX(0, RAD_PET) ;
	RAD_OTHER_UTIL = MAX(0,RAD_OTH) ;
	LAB_UTIL = MAX(0,LAB) ;
	PROF_IP_UTIL = MAX(0,PROF_IP) ;
	PROF_ANESTHESIA_UTIL = MAX(0,PROF_ANES) ;
	PROF_SURGERY_UTIL = MAX(0,PROF_SURG) ;
	PROF_ER_UTIL = MAX(0,PROF_ER) ;
	PROF_ER_CS_UTIL = MAX(0,PROF_ER_CS) ;
	PROF_OFFICE_UTIL = MAX(0,PROF_OV) ;
	EM_ATT_VISIT_UTIL = MAX(0,EM_ATT_VISIT) ;
	EM_OTH_VISIT_UTIL = MAX(0,EM_OTH_VISIT) ;
	EM_ATT_VISIT_UTIL_CHK = MAX(0,EM_ATT_VISIT_CHK) ;
	EM_OTH_VISIT_UTIL_CHK = MAX(0,EM_OTH_VISIT_CHK) ;
	PROF_OTHER_UTIL = MAX(0,PROF_OTH) ;
	DME_UTIL = MAX(0, DME) ;
	OUT_OTHER_UTIL = MAX(0,OP_OTH) ;
	OTHER_UTIL = MAX(0, OTHER) ;
	CHEMO_D_UTIL = MAX(0,PART_D_CHEMO) ;
	CHEMO_B_UTIL = MAX(0,PART_B_CHEMO) ;
	CHEMO_D_CYTO_UTIL = MAX(0,PART_D_CHEMO_CYTO) ;
	CHEMO_B_CYTO_UTIL = MAX(0,PART_B_CHEMO_CYTO) ;
	CHEMO_D_BIO_UTIL = MAX(0,PART_D_CHEMO_BIO) ;
	CHEMO_B_BIO_UTIL = MAX(0,PART_B_CHEMO_BIO) ;
	CHEMO_D_HARM_UTIL = MAX(0,PART_D_CHEMO_HARM) ;
	CHEMO_B_HARM_UTIL = MAX(0,PART_B_CHEMO_HARM) ;
	CHEMO_D_OTH_UTIL = MAX(0,PART_D_CHEMO_OTH) ;
	CHEMO_B_OTH_UTIL = MAX(0,PART_B_CHEMO_OTH) ;
	MEOS_UTIL = MAX(0,MEOS) ;
	MEOS_OTH_UTIL = MAX(0,MEOS_OTH) ;
	
	OUT_SURG_UTIL = MAX(OUT_SURG_CANCER_UTIL, OUT_SURG_NONCANCER_UTIL) ;
	OP_UTIL = MAX(OUT_SURG_UTIL, OUT_OTHER_UTIL) ;
	DRUG_UTIL = MAX(ANTI_EMETICS_UTIL,HEMOTAPOETIC_UTIL,OTHER_DRUGS_UTIL, 
				    CHEMO_ADJ_UTIL,CHEMO_ADMIN_UTIL, CHEMO_D_UTIL, CHEMO_B_UTIL);
	CHEMO_ADMIN_UTIL = MAX(0, CHEMO_ADMIN) ;
	
	RAD_ONC_UTIL = MAX(0,RAD_ONC) ;
	RAD_ONC_DAYS = MAX(0,ROC_ONC_DAYS) ;

	FORMAT PATIENT_NAME $50. ;   LENGTH PATIENT_NAME $50. ;
	IF LAST_NAME NE "  " THEN PATIENT_NAME = PROPCASE(COMPRESS(LAST_NAME,' '))||', '||PROPCASE(COMPRESS(FIRST_NAME,' ')) ;	
	ELSE PATIENT_NAME = "UNKNOWN" ;
	IF SEX IN ("M","1") THEN PATIENT_SEX = 1  ;
	ELSE IF SEX in ("F","2" ) THEN PATIENT_SEX = 2 ;
	ELSE PATIENT_SEX = 0 ;

	ALLOWED_MILLIMAN = ALLOWED ;
	ACTUAL_EXP_STD_MILLIMAN = STD_PAY ;
	
	EPI_TAX_ID = TAX ;
	EPI_NPI_ID = ENI ;
	BASELINE_PRICE_MILLIMAN = 0 ;

	*** PREDICTIVE MODEL VARIABLES ** ;
	*** NEW NOVEL THERAPY FLAGS *** ;
	NOVEL_THER_UTIL = MAX(0,NT_D, NT_B) ;
	NOVEL_THER_B_UTIL = MAX(0, NT_B) ;
	NOVEL_THER_D_UTIL = MAX(0, NT_D) ;
	NOVEL_THER_B_ALLOWED = NT_BALL ;
	NOVEL_THER_D_ALLOWED = NT_DALL ;
	NOVEL_THER_B_STD =NT_BSTD ;  
	NOVEL_THER_D_STD = NT_DSTD ;
	NOVEL_THER_ALLOWED = SUM(NT_BALL,NT_DALL) ;
	NOVEL_THER_STD = SUM(NT_BSTD, NT_DSTD) ;

	IF ALL_TOS = 0 THEN REMOVE_0 = 1 ;
	ELSE REMOVE_0 = 0 ;
	**** Fields to create from interim beneficiary file. **** ;

	*** Reassign Bene Variable Field Values if episode end not correlated with quarter of death. *** ;
	IF DOD NE . AND EP_END < DOD THEN DO ;
		DIED = 0 ;
		ANY_HSP_CARE = . ;
		HSP_30DAYS_ALL = . ;
		HSP_DAYS = . ;
		HOSPITAL_USE = . ;
		INTENSIVE_CARE_UNIT = . ;
		CHEMOTHERAPY = . ;
	END ;

	IF CANCER_EM = 1 THEN EMERGE_NOEM = 0 ;
	ELSE EMERGE_NOEM = 1 ;

	*** Rename of Utilization Fields provided by beneficiary file to indicate from this file and not calc by Milliman *** ;
	array bene1 (z) EM_VISITS EM_VISITS_ALL ALL_TOS INP_ADMSNS INP_EX UNPLANNED_READ ER_OBS_AD ER_AD OBS_AD 
					ER_AND_OBS_AD NO_ER_NO_OBS_AD OBS_STAYS OBS_ER OBS_NO_ER ER_NO_AD_OBS R_ONC PHY_SRVC PHY_ONC 
					PHY_OTH ANC_TOT ANC_LAB_TOT ANC_LAB_ADV ANC_LAB_OTHER ANC_IMAG_TOT ANC_IMAG_ADV 
					ANC_IMAG_OTH OUT_OTHER HHA SNF LTC IRF HSP_TOT HSP_FAC HSP_HOME HSP_BOTH DME_NO_DRUGS PD_TOT 
					PD_PTB_PHYDME PD_PTB_OUT PD_PTD_ALL OTHER ALL_TOS_ADJ INP_ADMSNS_ADJ INP_EX_ADJ 
					UNPLANNED_READ_ADJ ER_OBS_AD_ADJ ER_AD_ADJ OBS_AD_ADJ ER_AND_OBS_AD_ADJ NO_ER_NO_OBS_AD_ADJ 
					OBS_STAYS_ADJ OBS_ER_ADJ OBS_NO_ER_ADJ ER_NO_AD_OBS_ADJ R_ONC_ADJ PHY_SRVC_ADJ PHY_ONC_ADJ 
					PHY_OTH_ADJ ANC_TOT_ADJ ANC_LAB_TOT_ADJ ANC_LAB_ADV_ADJ ANC_LAB_OTHER_ADJ ANC_IMAG_TOT_ADJ 
					ANC_IMAG_ADV_ADJ ANC_IMAG_OTH_ADJ OUT_OTHER_ADJ HHA_ADJ SNF_ADJ LTC_ADJ IRF_ADJ HSP_TOT_ADJ 
					HSP_FAC_ADJ HSP_HOME_ADJ HSP_BOTH_ADJ DME_NO_DRUGS_ADJ PD_TOT_ADJ PD_PTB_PHYDME_ADJ PD_PTB_OUT_ADJ 
					PD_PTD_ALL_ADJ OTHER_ADJ RISK_ADJ_FACTOR INFLATION_FACTOR INP_ADMSNS_UTIL INP_EX_UTIL 
					UNPLANNED_READ_UTIL ER_OBS_AD_UTIL ER_AD_UTIL OBS_AD_UTIL ER_AND_OBS_AD_UTIL 
					NO_ER_NO_OBS_AD_UTIL OBS_STAYS_UTIL OBS_ER_UTIL OBS_NO_ER_UTIL ER_NO_AD_OBS_UTIL R_ONC_UTIL 
					PHY_SRVC_UTIL PHY_ONC_UTIL PHY_OTH_UTIL ANC_LAB_TOT_UTIL ANC_LAB_ADV_UTIL ANC_LAB_OTHER_UTIL 
					ANC_IMAG_TOT_UTIL ANC_IMAG_ADV_UTIL ANC_IMAG_OTH_UTIL HHA_UTIL SNF_UTIL LTC_UTIL IRF_UTIL 
					HSP_UTIL DIED HSP_30DAYS_ALL ANY_HSP_CARE HSP_DAYS HOSPITAL_USE INTENSIVE_CARE_UNIT CHEMOTHERAPY  
					BR_KADYCLA BR_AVASTIN BR_AFINITOR BR_NEULASTA BR_PERJATA BR_HEPCEPTIN PR_ZYTIGA	PR_JEVTANA
					PR_XTANDI PR_PROVENGE LU_GILOTRIF LU_TECENTRIQ LU_AVASTIN LU_TARCEVA LU_OPDIVO LU_ABRAXANE
					LU_NEULASTA	LU_KEYTRUDA LU_ALIMTA LY_TREANDA LY_VELCADE LY_IMBRUVICA LY_REVLIMID LY_OPDIVO
					LY_NEULASTA LY_KEYTRUDA	LY_RITUXAN IC_AVASTIN IC_XELODA IC_ERBITUX IC_VECTIBIX IC_NEULASTA
					IC_KEYTRUDA IC_ZALTRAP MU_VELCADE MU_KYPROLIS MU_DARZALEX MU_REVLIMID BL_TECENTRIQ 
					BL_OPDIVO HN_ERBITUX HN_OPDIVO HN_KEYTRUDA MA_COTELLIC MA_TAFINLAR MA_YERVOY MA_OPDIVO
					MA_KEYTRUDA MA_MEKINIST MA_ZELBORAF BR_ABRAXANE BR_IBRANCE  ;

	array bene2 (z) EM_VISITS_BENE EM_VISITS_ALL_BENE ALL_TOS_BENE INP_ADMSNS_BENE INP_EX_BENE 
					UNPLANNED_READ_BENE ER_OBS_AD_BENE ER_AD_BENE OBS_AD_BENE ER_AND_OBS_AD_BENE 
					NO_ER_NO_OBS_AD_BENE OBS_STAYS_BENE OBS_ER_BENE OBS_NO_ER_BENE ER_NO_AD_OBS_BENE R_ONC_BENE 
					PHY_SRVC_BENE PHY_ONC_BENE PHY_OTH_BENE ANC_TOT_BENE ANC_LAB_TOT_BENE 
					ANC_LAB_ADV_BENE ANC_LAB_OTHER_BENE ANC_IMAG_TOT_BENE ANC_IMAG_ADV_BENE ANC_IMAG_OTH_BENE 
					OUT_OTHER_BENE HHA_BENE SNF_BENE LTC_BENE IRF_BENE HSP_TOT_BENE HSP_FAC_BENE 
					HSP_HOME_BENE HSP_BOTH_BENE DME_NO_DRUGS_BENE PD_TOT_BENE PD_PTB_PHYDME_BENE PD_PTB_OUT_BENE 
					PD_PTD_ALL_BENE OTHER_BENE ALL_TOS_ADJ_BENE INP_ADMSNS_ADJ_BENE INP_EX_ADJ_BENE 
					UNPLANNED_READ_ADJ_BENE ER_OBS_AD_ADJ_BENE ER_AD_ADJ_BENE OBS_AD_ADJ_BENE 
					ER_AND_OBS_AD_ADJ_BENE NO_ER_NO_OBS_AD_ADJ_BENE OBS_STAYS_ADJ_BENE OBS_ER_ADJ_BENE 
					OBS_NO_ER_ADJ_BENE ER_NO_AD_OBS_ADJ_BENE R_ONC_ADJ_BENE PHY_SRVC_ADJ_BENE PHY_ONC_ADJ_BENE 
					PHY_OTH_ADJ_BENE ANC_TOT_ADJ_BENE ANC_LAB_TOT_ADJ_BENE ANC_LAB_ADV_ADJ_BENE 
					ANC_LAB_OTHER_ADJ_BENE ANC_IMAG_TOT_ADJ_BENE ANC_IMAG_ADV_ADJ_BENE ANC_IMAG_OTH_ADJ_BENE 
					OUT_OTHER_ADJ_BENE HHA_ADJ_BENE SNF_ADJ_BENE LTC_ADJ_BENE IRF_ADJ_BENE 
					HSP_TOT_ADJ_BENE HSP_FAC_ADJ_BENE HSP_HOME_ADJ_BENE HSP_BOTH_ADJ_BENE DME_NO_DRUGS_ADJ_BENE 
					PD_TOT_ADJ_BENE PD_PTB_PHYDME_ADJ_BENE PD_PTB_OUT_ADJ_BENE PD_PTD_ALL_ADJ_BENE 
					OTHER_ADJ_BENE RISK_ADJ_FACTOR_BENE INFLATION_FACTOR_BENE 
					INP_ADMSNS_UTIL_BENE INP_EX_UTIL_BENE 
					UNPLANNED_READ_UTIL_BENE ER_OBS_AD_UTIL_BENE 
					ER_AD_UTIL_BENE OBS_AD_UTIL_BENE ER_AND_OBS_AD_UTIL_BENE NO_ER_NO_OBS_AD_UTIL_BENE 
					OBS_STAYS_UTIL_BENE OBS_ER_UTIL_BENE OBS_NO_ER_UTIL_BENE ER_NO_AD_OBS_UTIL_BENE 
					R_ONC_UTIL_BENE PHY_SRVC_UTIL_BENE PHY_ONC_UTIL_BENE PHY_OTH_UTIL_BENE ANC_LAB_TOT_UTIL_BENE 
					ANC_LAB_ADV_UTIL_BENE ANC_LAB_OTHER_UTIL_BENE ANC_IMAG_TOT_UTIL_BENE 
					ANC_IMAG_ADV_UTIL_BENE ANC_IMAG_OTH_UTIL_BENE HHA_UTIL_BENE SNF_UTIL_BENE LTC_UTIL_BENE 
					IRF_UTIL_BENE HSP_UTIL_BENE DIED_BENE HSP_30DAYS_ALL_BENE ANY_HSP_CARE_BENE 
					HSP_DAYS_BENE HOSPITAL_USE_BENE INTENSIVE_CARE_UNIT_BENE CHEMOTHERAPY_BENE  
					BR_KADYCLA_BENE BR_AVASTIN_BENE BR_AFINITOR_BENE BR_NEULASTA_BENE BR_PERJATA_BENE 
					BR_HEPCEPTIN_BENE PR_ZYTIGA_BENE PR_JEVTANA_BENE PR_XTANDI_BENE PR_PROVENGE_BENE 
				    LU_GILOTRIF_BENE LU_TECENTRIQ_BENE LU_AVASTIN_BENE LU_TARCEVA_BENE LU_OPDIVO_BENE LU_ABRAXANE_BENE
					LU_NEULASTA_BENE	LU_KEYTRUDA_BENE LU_ALIMTA_BENE LY_TREANDA_BENE LY_VELCADE_BENE 
					LY_IMBRUVICA_BENE LY_REVLIMID_BENE LY_OPDIVO_BENE LY_NEULASTA_BENE LY_KEYTRUDA_BENE	
					LY_RITUXAN_BENE IC_AVASTIN_BENE IC_XELODA_BENE IC_ERBITUX_BENE IC_VECTIBIX_BENE IC_NEULASTA_BENE
					IC_KEYTRUDA_BENE IC_ZALTRAP_BENE MU_VELCADE_BENE MU_KYPROLIS_BENE MU_DARZALEX_BENE MU_REVLIMID_BENE 
					BL_TECENTRIQ_BENE BL_OPDIVO_BENE HN_ERBITUX_BENE HN_OPDIVO_BENE HN_KEYTRUDA_BENE MA_COTELLIC_BENE
					MA_TAFINLAR_BENE MA_YERVOY_BENE MA_OPDIVO_BENE MA_KEYTRUDA_BENE MA_MEKINIST_BENE MA_ZELBORAF_BENE
					BR_ABRAXANE_BENE BR_IBRANCE_BENE ;

	do z = 1 to dim(bene1) ;
		bene2 = bene1 ;
	end ;

	*** Milliman Beneficiary Fields *** ;
	*** ALready included: INP_ADMSNS_MILLIMAN INP_EXP_MILLIMAN INP_AMB_MILLIMAN *** ;
	INP_ADMSNS_MILLIMAN = ROUND(MAX(0,INP_ADMSNS_MILLIMAN),.01) ;
	INP_EXP_MILLIMAN = ROUND(MAX(0,INP_EXP_MILLIMAN),.01) ;
	*INP_AMB_MILLIMAN = ROUND(MAX(0,INP_AMB_MILLIMAN),.01) ;
	OBS_STAYS_MILLIMAN = ROUND(MAX(0,OBS_STAYS),.01) ;
	ER_OBS_AD_MILLIMAN = ROUND(MAX(0,ER_OBS_AD),.01) ;
	ER_AD_MILLIMAN = ROUND(MAX(0,ER_AD),.01) ;
	OBS_AD_MILLIMAN = ROUND(MAX(0,OBS_AD),.01) ;
	ER_AND_OBS_AD_MILLIMAN = ROUND(MAX(0,ER_AND_OBS_AD),.01) ;
	NO_ER_NO_OBS_AD_MILLIMAN = ROUND(MAX(0,NO_ER_NO_OBS_AD),.01) ;
	OBS_STAYS_MILLIMAN = ROUND(MAX(0,OBS_STAYS),.01) ;
	OBS_ER_MILLIMAN = ROUND(MAX(OBS_ER,0),.01) ;
	OBS_NO_ER_MILLIMAN = ROUND(MAX(OBS_NO_ER,0),.01) ;
	ER_NO_AD_OBS_MILLIMAN = ROUND(MAX(ER_NO_AD_OBS,0),.01) ;

	INP_ADMSNS_UTIL_MILL = MAX(INP_ADMSNS_UTIL,0) ;
	INP_EX_UTIL_MILL = MAX(0,INP_EX_UTIL) ;
	*INP_AMB_UTIL_MILL = MAX(0,INP_AMB_UTIL ) ;
	ER_OBS_AD_UTIL_MILL = MAX(0,ER_OBS_AD_UTIL) ;
	ER_AD_UTIL_MILL = MAX(0,ER_AD_UTIL) ;
	OBS_AD_UTIL_MILL = MAX(OBS_AD_UTIL,0) ;
	ER_AND_OBS_AD_UTIL_MILL = MAX(ER_AND_OBS_AD_UTIL,0) ;
	NO_ER_NO_OBS_AD_UTIL_MILL = MAX(0,NO_ER_NO_OBS_AD_UTIL) ;
	OBS_STAYS_UTIL_MILL = MAX(0,OBS_STAYS_UTIL) ;
	OBS_ER_UTIL_MILL = MAX(0,OBS_ER_UTIL) ;
	OBS_NO_ER_UTIL_MILL = MAX(0, OBS_NO_ER_UTIL) ;
	ER_NO_AD_OBS_UTIL_MILL = MAX(0,ER_NO_AD_OBS_UTIL_MILL) ;

	INDEX_ADMIT_COUNT = MAX(0,INDEX_COUNT) ;
	READMISSION_COUNT = MAX(0,READM_COUNT) ;


%IF "&VERS." = "A" %THEN %DO ;
	IF DOD NE . AND EP_BEG LE DOD LE EP_END AND EP_BEG < &LATEST_QTR. THEN DO ;
%END ;
%ELSE %DO ;
	IF DOD NE . AND EP_BEG LE DOD LE EP_END THEN DO ;
%END;
			DIED_MILLIMAN = 1 ;
	END ;
	ELSE DIED_MILLIMAN = 0 ;


		HSP_TOT_MILLIMAN = MAX(0,HSP_PMT_AMT) ;
		HSP_FAC_MILLIMAN = MAX(0,FAC_PMT_AMT) ;
		HSP_HOME_MILLIMAN = MAX(0,HOME_PMT_AMT) ;
		HSP_BOTH_MILLIMAN = MAX(0,BOTH_PMT_AMT) ;

	IF DIED_MILLIMAN = 1 THEN DO ;
		HSP_UTIL_MILLIMAN = MAX(0, HOSPICE) ;
		HSP_30DAYS_ALL_MILLIMAN = MAX(0,HOSP_30DAYS) ;
		IF ANY_HSP_BOTH = 1 OR (ANY_HSP_FAC = 1 AND ANY_HSP_HOME = 1) THEN ANY_HSP_CARE_MILLIMAN = 3 ;
			ELSE IF ANY_HSP_FAC = 1 THEN ANY_HSP_CARE_MILLIMAN = 2 ;
			ELSE IF ANY_HSP_HOME = 1 THEN ANY_HSP_CARE_MILLIMAN = 1 ;
			ELSE IF ANY_HSP_UNK = 1 THEN ANY_HSP_CARE_MILLIMAN = 0 ;
		HSP_DAYS_MILLIMAN = MAX(0,HOSP_DAYS_90) ;
		*** As per OCM ticket 799809 - only IP services are included in HOSPITAL_USE *** ;
		HOSPITAL_USE_MILLIMAN = MAX(0,IP_ALLCAUSE_30) ;
		ICU_MILLIMAN = MAX(0,IP_ICU_30) ;
		CHEMOTHERAPY_MILLIMAN = MAX(0,CHEMO_DEATH14) ;
		OCM3 = MAX(0,HOSP_3DAY) ;
	DIED_IN_HOSP = MAX(0,DIED_IN_HOSP) ; 
	END ;


	*** OCM Quality Measures *** ;
	OCM1 = MAX(0,EX1) ;
	** episodes with emergency department (ED) visits or observation stays that did not result in a hospitalization ** ;
	OCM2 = MAX(0,OCM2) ;


	**** End of Life Values should be missing if DOD is missing **** ;
	IF DIED_MILLIMAN NE 1 THEN DO ;
			HSP_30DAYS_ALL_MILLIMAN = . ;
			ANY_HSP_CARE_MILLIMAN = . ;
			HSP_DAYS_MILLIMAN = . ;
			HOSPITAL_USE_MILLIMAN = . ;
			ICU_MILLIMAN = . ;
			CHEMOTHERAPY_MILLIMAN = . ;
			HOSP_3DAY = . ;
			DIED_IN_HOSP = . ;
	END ;

	**** Hospice metrics should only have a value when episode has hospice **** ;
	IF ANYHOSP NE 1 THEN DO ;
		ANY_HSP_CARE_MILLIMAN = . ;
	END ;

	ER_WEEKEND = MAX(0,ER_WEEKEND) ;
	ER_WEEKEND_COUNT = MAX(0,ER_WEEKEND_COUNT) ;
	INDEX_COUNT = MAX(0,INDEX_COUNT) ;
	READ_COUNT = MAX(0,READ_COUNT) ;

	**** Attribute Flag - 
		1. Perfomance Period Match for Attributable Episodes  *** ;
		if ep_beg < mdy(10,1,2016) and q1 = 0 and q2=0 and attribute_flag notin ("0","D") then perform_not_match = 1 ;
		else if ep_beg>mdy(9,30,2016) and ep_beg < mdy(1,2,2017) and  q2 = 0 and q3=0 and attribute_flag notin ("0","D") then perform_not_match = 1 ;
        else if ep_beg>mdy(12,31,2016) and ep_beg < mdy(4,2,2017) and  q3 = 0 and q4=0 and attribute_flag notin ("0","D") then perform_not_match = 1 ;
		else if ep_beg>mdy(3,31,2017) and ep_beg < mdy(7,2,2017) and  q4 = 0 and q5=0 and attribute_flag notin ("0","D") then perform_not_match = 1 ;
		else if ep_beg>mdy(6,30,2017) and ep_beg < mdy(10,2,2017) and  q5 = 0 and q6=0 and attribute_flag notin ("0","D") then perform_not_match = 1 ;
		else if ep_beg>mdy(9,30,2017) and ep_beg < mdy(1,2,2018) and  q6 = 0 and q7=0 and attribute_flag notin ("0","D") then perform_not_match = 1 ;

		*** 2. Potentially Attributable Episodes  *** ;
	if ep_beg gt &potential. and attribute_flag = "0" then attribute_flag = "4" ;

	MEOS_COUNT = MAX(0,MEOS_COUNT) ;
	MEOS_COUNT_OTH = MAX(0, MEOS_COUNT_OTH) ;

	FORMAT M_EPI_SOURCE_FINAL $10. ; LENGTH M_EPI_SOURCE_FINAL $10. ; 
	M_EPI_SOURCE = MAX(0, M_EPI_SOURCE) ;
	IF M_EPI_SOURCE = 0 then M_EPI_SOURCE_FINAL = "UNKNOWN" ;
	ELSE IF M_EPI_SOURCE = 4 THEN M_EPI_SOURCE_FINAL = "PART D" ;
	ELSE M_EPI_SOURCE_FINAL = "PART B" ;

	IF EPI_ATT_TIN in (&ATT_TIN.) THEN EPI_TIN_MATCH = 1 ;
	ELSE EPI_TIN_MATCH = 0 ;
	

	IF MISSING(EM_ATT_TAX) THEN EM_ATT_TAX = '0' ;
	IF MISSING(EM_NONATT_TAX) THEN EM_NONATT_TAX = '0' ;

	%EPISODE_PERIOD ;

	**** BASELINE/PP3 PROSTATE AND BLADDER DISTINCTIONS **** ;
	IF MDY(7,2,2017) LE EP_BEG THEN DO ;
		IF CANCER_TYPE_MILLIMAN = "Breast Cancer" THEN DO ;
			IF bc_hormonal = 1 AND nonhormonal = 0 THEN DO ;
				CANCER_TYPE_MILLIMAN = "Breast Cancer - Low Risk" ;
				if cancer_type = "Breast Cancer" then cancer_type = "Breast Cancer - Low Risk" ;
			end ;
			ELSE DO ;
				CANCER_TYPE_MILLIMAN = "Breast Cancer - High Risk" ;
				if cancer_type = "Breast Cancer" then cancer_type = "Breast Cancer - High Risk" ;
			END ;
		END ;

		IF CANCER_TYPE_MILLIMAN = "Bladder Cancer" THEN DO ; 	
			IF BLAD_LR = 1 AND BLAD_OTH = 0 THEN DO ;
				CANCER_TYPE_MILLIMAN = "Bladder Cancer - Low Risk" ;
				if cancer_TYPE = "Bladder Cancer" then cancer_type = "Bladder Cancer - Low Risk" ;
			end ;
			ELSE DO ;
				CANCER_TYPE_MILLIMAN = "Bladder Cancer - High Risk" ;
				if cancer_TYPE = "Bladder Cancer" then cancer_type = "Bladder Cancer - High Risk" ;
			END ;
		END ;

		IF CANCER_TYPE_MILLIMAN = "Prostate Cancer" then do ;
			IF PROST_CAST = 1 AND PROST_OTH = 0 THEN DO ;
				CANCER_TYPE_MILLIMAN = "Prostate Cancer - Low Intensity" ;
				IF CANCER_TYPE = "Prostate Cancer" then cancer_type = "Prostate Cancer - Low Intensity" ;
			end ;
			ELSE DO ;
				CANCER_TYPE_MILLIMAN = "Prostate Cancer - High Intensity" ;
				if cancer_TYPE = "Prostate Cancer" then cancer_type = "Prostate Cancer - High Intensity" ;
			END ;
		END ;

		IF car_t = 1 then do ;
			CANCER_TYPE_MILLIMAN = "CAR-T" ;
			cancer_type = "CAR-T" ;
		END ;
	END ;

	IF CANCER_TYPE_MILLIMAN = "  " THEN CANCER_TYPE_MILLIMAN = CANCER_TYPE ;

	IF CANCER_TYPE_MILLIMAN IN ('Acute Leukemia','Anal Cancer','Bladder Cancer','Breast Cancer','Chronic Leukemia',
									'CNS Tumor','Intestinal Cancer','Endocrine Tumor','Female GU Cancer other than Ovary',
									'Gastro/Esophageal Cancer','Head and Neck Cancer','Kidney Cancer','Liver Cancer',
									'Lung Cancer','Lymphoma','Malignant Melanoma','MDS','Multiple Myeloma',
									'Ovarian Cancer','Pancreatic Cancer','Prostate Cancer',"Bladder Cancer - Low Risk",
									"Bladder Cancer - High Risk","Prostate Cancer - Low Intensity",
									"Prostate Cancer - High Intensity","Small Intestine / Colorectal Cancer",
									"Breast Cancer - Low Risk","Breast Cancer - High Risk") THEN RECON_ELIG_MILLIMAN = "1" ;
	ELSE RECON_ELIG_MILLIMAN = "0" ;
	IF CANCER_TYPE IN ('Acute Leukemia','Anal Cancer','Bladder Cancer','Breast Cancer','Chronic Leukemia',
									'CNS Tumor','Intestinal Cancer','Endocrine Tumor','Female GU Cancer other than Ovary',
									'Gastro/Esophageal Cancer','Head and Neck Cancer','Kidney Cancer','Liver Cancer',
									'Lung Cancer','Lymphoma','Malignant Melanoma','MDS','Multiple Myeloma',
									'Ovarian Cancer','Pancreatic Cancer','Prostate Cancer',"Bladder Cancer - Low Risk",
									"Bladder Cancer - High Risk","Prostate Cancer - Low Intensity",
									"Prostate Cancer - High Intensity","Small Intestine / Colorectal Cancer",
								    "Breast Cancer - Low Risk","Breast Cancer - High Risk") THEN RECON_ELIG = "1" ;
	ELSE RECON_ELIG = "0" ;


run ;

%if "&use_att." = "1" %then %do ;
DATA ATT ;
	SET &ATT. ;

proc sql;
	create table epipre2 as
	select a.*, b.EM_VISIT_FOR_CANC
	from epipre as a left join ATT as b
	ON A.BENE_ID=B.BENE_ID AND A.EP_BEG_A=B.EP_BEG_A ;
QUIT ;

DATA EPIPRE2 ;
	SET EPIPRE2 ;
	EM_ATT_TAX_M = EM_ATT_TAX ;
	IF EM_VISIT_FOR_CANC NE . AND EM_ATT_TAX NE EM_VISIT_FOR_CANC THEN EM_ATT_TAX_M =  EM_VISIT_FOR_CANC;
%end ;

%ELSE %DO ;
DATA EPIPRE2 ;
	SET EPIPRE ;
	EM_ATT_TAX_M = EM_ATT_TAX ;

%END ;	
	
 
data outfinal.episode_Interface_&bl._&ds. outfinal.episode_emerge_&bl._&ds. ;
	retain OCM_ID BENE_ID BENE_HICN FIRST_NAME LAST_NAME PATIENT_NAME SEX 
		   PATIENT_SEX DOB AGE DOD EP_ID EPI_COUNTER EP_BEG EP_END EP_LENGTH
		   CANCER_TYPE QTR_START_DATE CHEMO_DATE RISK_SCORE  HIGH_RISK 
		   COMMON_CANCER_TYPE AGE_CATEGORY RACE DUAL 
		   CANCER_TYPE_MILLIMAN SURGERY_MILLIMAN CLINICAL_TRIAL_MILLIMAN 
		   PTD_CHEMO_MILLIMAN ACTUAL_EXP_BENE ALLOWED_MILLIMAN BASELINE_PRICE_MILLIMAN IP_UTIL OP_UTIL SNF_UTIL
		   HH_UTIL HSP_UTIL FAC_UTIL CHEMO_D_UTIL CHEMO_B_UTIL PROF_UTIL DRUG_UTIL RAD_ONC_UTIL
		   CHEMO_DAYS_PARTB	RAD_ONC_DAYS CHEMO_LENGTH_PARTB RAD_ONC_LENGTH IP_MED_CHEMO_UTIL
		   IP_MED_NON_CHEMO_UTIL IP_SURG_CHEMO_UTIL IP_SURG_NON_CHEMO_UTIL IP_OTHER_UTIL
		   /*ER_CHEMO_UTIL ER_NON_CHEMO_UTIL*/ OUT_SURG_CANCER_UTIL OUT_SURG_NONCANCER_UTIL ANTI_EMETICS_UTIL
		   HEMOTAPOETIC_UTIL OTHER_DRUGS_UTIL CHEMO_ADMIN_UTIL RAD_HTECH_UTIL RAD_OTHER_UTIL
		   LAB_UTIL PROF_IP_UTIL PROF_SURGERY_UTIL PROF_ANESTHESIA_UTIL PROF_OTHER_UTIL DME_UTIL OTHER_UTIL
		   ER_UG_OBS_UTIL OUT_SURG_UTIL OUT_OTHER_UTIL OP_UTIL PROF_OFFICE_UTIL EM_ATT_VISIT_UTIL EM_OTH_VISIT_UTIL PROF_ER_UTIL 
		   OTHER_UTIL CHEMO_ADJ_UTIL
		   CHEMO_D_CYTO_UTIL CHEMO_B_CYTO_UTIL CHEMO_D_BIO_UTIL CHEMO_B_BIO_UTIL CHEMO_D_HARM_UTIL 
		   CHEMO_B_HARM_UTIL CHEMO_D_OTH_UTIL CHEMO_B_OTH_UTIL CHEMO_UTIL_TYPE RAD_MRI_UTIL RAD_CT_UTIL 
		   RAD_PET_UTIL EPI_TAX_ID EPI_NPI_ID EPI_ATT_TIN

					EM_VISITS_BENE EM_VISITS_ALL_BENE ALL_TOS_BENE INP_ADMSNS_BENE INP_EX_BENE 
					UNPLANNED_READ_BENE ER_OBS_AD_BENE ER_AD_BENE OBS_AD_BENE ER_AND_OBS_AD_BENE 
					NO_ER_NO_OBS_AD_BENE OBS_STAYS_BENE OBS_ER_BENE OBS_NO_ER_BENE ER_NO_AD_OBS_BENE R_ONC_BENE 
					PHY_SRVC_BENE PHY_ONC_BENE PHY_OTH_BENE ANC_TOT_BENE ANC_LAB_TOT_BENE 
					ANC_LAB_ADV_BENE ANC_LAB_OTHER_BENE ANC_IMAG_TOT_BENE ANC_IMAG_ADV_BENE ANC_IMAG_OTH_BENE 
					OUT_OTHER_BENE HHA_BENE SNF_BENE LTC_BENE IRF_BENE HSP_TOT_BENE HSP_FAC_BENE 
					HSP_HOME_BENE HSP_BOTH_BENE DME_NO_DRUGS_BENE PD_TOT_BENE PD_PTB_PHYDME_BENE PD_PTB_OUT_BENE 
					PD_PTD_ALL_BENE OTHER_BENE ALL_TOS_ADJ_BENE INP_ADMSNS_ADJ_BENE INP_EX_ADJ_BENE 
					 UNPLANNED_READ_ADJ_BENE ER_OBS_AD_ADJ_BENE ER_AD_ADJ_BENE OBS_AD_ADJ_BENE 
					ER_AND_OBS_AD_ADJ_BENE NO_ER_NO_OBS_AD_ADJ_BENE OBS_STAYS_ADJ_BENE OBS_ER_ADJ_BENE 
					OBS_NO_ER_ADJ_BENE ER_NO_AD_OBS_ADJ_BENE R_ONC_ADJ_BENE PHY_SRVC_ADJ_BENE PHY_ONC_ADJ_BENE 
					PHY_OTH_ADJ_BENE ANC_TOT_ADJ_BENE ANC_LAB_TOT_ADJ_BENE ANC_LAB_ADV_ADJ_BENE 
					ANC_LAB_OTHER_ADJ_BENE ANC_IMAG_TOT_ADJ_BENE ANC_IMAG_ADV_ADJ_BENE ANC_IMAG_OTH_ADJ_BENE 
					OUT_OTHER_ADJ_BENE HHA_ADJ_BENE SNF_ADJ_BENE LTC_ADJ_BENE IRF_ADJ_BENE 
					HSP_TOT_ADJ_BENE HSP_FAC_ADJ_BENE HSP_HOME_ADJ_BENE HSP_BOTH_ADJ_BENE DME_NO_DRUGS_ADJ_BENE 
					PD_TOT_ADJ_BENE PD_PTB_PHYDME_ADJ_BENE PD_PTB_OUT_ADJ_BENE PD_PTD_ALL_ADJ_BENE 
					OTHER_ADJ_BENE RISK_ADJ_FACTOR_BENE INFLATION_FACTOR_BENE INP_ADMSNS_UTIL_BENE INP_EX_UTIL_BENE 
					UNPLANNED_READ_UTIL_BENE ER_OBS_AD_UTIL_BENE 
					ER_AD_UTIL_BENE OBS_AD_UTIL_BENE ER_AND_OBS_AD_UTIL_BENE NO_ER_NO_OBS_AD_UTIL_BENE 
					OBS_STAYS_UTIL_BENE OBS_ER_UTIL_BENE OBS_NO_ER_UTIL_BENE ER_NO_AD_OBS_UTIL_BENE 
					R_ONC_UTIL_BENE PHY_SRVC_UTIL_BENE PHY_ONC_UTIL_BENE PHY_OTH_UTIL_BENE ANC_LAB_TOT_UTIL_BENE 
					ANC_LAB_ADV_UTIL_BENE ANC_LAB_OTHER_UTIL_BENE ANC_IMAG_TOT_UTIL_BENE 
					ANC_IMAG_ADV_UTIL_BENE ANC_IMAG_OTH_UTIL_BENE HHA_UTIL_BENE SNF_UTIL_BENE LTC_UTIL_BENE 
					IRF_UTIL_BENE HSP_UTIL_BENE DIED_BENE HSP_30DAYS_ALL_BENE ANY_HSP_CARE_BENE 
					HSP_DAYS_BENE HOSPITAL_USE_BENE INTENSIVE_CARE_UNIT_BENE CHEMOTHERAPY_BENE 
					BR_KADYCLA_BENE BR_AVASTIN_BENE BR_AFINITOR_BENE BR_NEULASTA_BENE BR_PERJATA_BENE 
					BR_HEPCEPTIN_BENE PR_ZYTIGA_BENE PR_JEVTANA_BENE PR_XTANDI_BENE PR_PROVENGE_BENE 
				    LU_GILOTRIF_BENE LU_TECENTRIQ_BENE LU_AVASTIN_BENE LU_TARCEVA_BENE LU_OPDIVO_BENE LU_ABRAXANE_BENE
					LU_NEULASTA_BENE	LU_KEYTRUDA_BENE LU_ALIMTA_BENE LY_TREANDA_BENE LY_VELCADE_BENE 
					LY_IMBRUVICA_BENE LY_REVLIMID_BENE LY_OPDIVO_BENE LY_NEULASTA_BENE LY_KEYTRUDA_BENE	
					LY_RITUXAN_BENE IC_AVASTIN_BENE IC_XELODA_BENE IC_ERBITUX_BENE IC_VECTIBIX_BENE IC_NEULASTA_BENE
					IC_KEYTRUDA_BENE IC_ZALTRAP_BENE MU_VELCADE_BENE MU_KYPROLIS_BENE MU_DARZALEX_BENE MU_REVLIMID_BENE 
					BL_TECENTRIQ_BENE BL_OPDIVO_BENE HN_ERBITUX_BENE HN_OPDIVO_BENE HN_KEYTRUDA_BENE MA_COTELLIC_BENE
					MA_TAFINLAR_BENE MA_YERVOY_BENE MA_OPDIVO_BENE MA_KEYTRUDA_BENE MA_MEKINIST_BENE MA_ZELBORAF_BENE
					BR_ABRAXANE_BENE BR_IBRANCE_BENE PART_D_MM CHEMO_IN_PP BMT_MILLIMAN

			NOVEL_THER_UTIL NOVEL_THER_B_UTIL NOVEL_THER_D_UTIL NOVEL_THER_B_ALLOWED NOVEL_THER_D_ALLOWED 
			NOVEL_THER_ALLOWED DIED_MILLIMAN
			INP_ADMSNS_MILLIMAN INP_EXP_MILLIMAN REMOVE_0 ER_VISITS_MILLIMAN 
			HSP_TOT_MILLIMAN HSP_FAC_MILLIMAN HSP_HOME_MILLIMAN HSP_BOTH_MILLIMAN 
			HSP_30DAYS_ALL_MILLIMAN ANY_HSP_CARE_MILLIMAN HSP_DAYS_MILLIMAN  HOSPITAL_USE_MILLIMAN
			ICU_MILLIMAN CHEMOTHERAPY_MILLIMAN  OCM1 OCM2 OCM3 DIED_IN_HOSP

			ER_OBS_AD_MILLIMAN ER_AD_MILLIMAN OBS_AD_MILLIMAN ER_AND_OBS_AD_MILLIMAN NO_ER_NO_OBS_AD_MILLIMAN 
			OBS_STAYS_MILLIMAN OBS_ER_MILLIMAN OBS_NO_ER_MILLIMAN ER_NO_AD_OBS_MILLIMAN
			INP_ADMSNS_UTIL_MILL INP_EX_UTIL_MILL ER_OBS_AD_UTIL_MILL ER_AD_UTIL_MILL 
			OBS_AD_UTIL_MILL ER_AND_OBS_AD_UTIL_MILL NO_ER_NO_OBS_AD_UTIL_MILL OBS_STAYS_UTIL_MILL 
			OBS_ER_UTIL_MILL OBS_NO_ER_UTIL_MILL ER_NO_AD_OBS_UTIL_MILL DATA_COVERAGE
			IP_FROM_ED_UTIL IP_FROM_ED EMERGE_NOCHEMO EMERGE_NOEM

			SNF_COUNT HH_COUNT ER_COUNT ADMIT_COUNT CHEMOPB_ALLOWED CHEMOPD_ALLOWED ANTIEMETICS_ALLOWED
			HEMATOPOIETIC_ALLOWED OTHRX_ALLOWED RADLAB_ALLOWED  PROF_ALLOWED IP_ALLOWED ER_ALLOWED
			OP_ALLOWED HOSPICE_ALLOWED IP_LOS SNF_ALLOWED HH_ALLOWED 
			MEOS_COUNT MEOS_COUNT_OTH MEOS_ALLOWED MEOS_ALLOWED_OTH Q1 Q2 Q3 Q4 Q5 ATTRIBUTE_FLAG perform_not_match
			ER_WEEKEND ER_WEEKEND_COUNT EM_ATT_TAX EM_NONATT_TAX EM_ATT_TAX_M M_EPI_SOURCE_FINAL EPI_TIN_MATCH
			MEOS_UTIL MEOS_OTH_UTIL INDEX_COUNT READ_COUNT 

 			EPISODE_PERIOD EP_ID_CMS NOVEL_THER_B_STD NOVEL_THER_D_STD NOVEL_THER_STD MEOS_STD_PAY MEOS_STD_PAY_OTH 
			CHEMOPB_std CHEMOPD_std ANTIEMETICS_std HEMATOPOIETIC_std OTHRX_std RADLAB_std  
			PROF_std IP_std ER_std OP_std HOSPICE_std SNF_std HH_std ACTUAL_EXP_STD_MILLIMAN 

			ZIPCODE DUAL_PTD_LIS INST RADIATION HCC_GRP HRR_REL_COST SURGERY CLINICAL_TRIAL BMT CLEAN_PD
			PTD_CHEMO ACTUAL_EXP BASELINE_PRICE EXPERIENCE_ADJ ACTUAL_EXP_UNADJ LOW_RISK_BLAD
			CAST_SENS_PROS MBI BENCHMARK_PRICE TARGET_PRICE OCM_DISCOUNT_ACO NOVEL_THERAPIES
			NUM_OCM1 NUM_OCM2 NUM_OCM3 DEN_OCM3 EXP_ALL_SERVICES RECON_PP1_FLAG 

			RECON_ELIG RECON_ELIG_MILLIMAN 

			RECON_PP IN_RECON ATT_EPI_PERD_MATCH_CMS ATT_CANC_MATCH_CMS

			INDEX_ADMIT_COUNT READMISSION_COUNT 
			EM_ATT_VISIT_UTIL_CHK EM_OTH_VISIT_UTIL_CHK;

	SET EPIPRE2 ;

	KEEP OCM_ID BENE_ID BENE_HICN FIRST_NAME LAST_NAME PATIENT_NAME SEX 
		   PATIENT_SEX DOB AGE DOD EP_ID EPI_COUNTER EP_BEG EP_END EP_LENGTH
		   CANCER_TYPE QTR_START_DATE CHEMO_DATE RISK_SCORE HIGH_RISK COMMON_CANCER_TYPE AGE_CATEGORY RACE DUAL 
			CANCER_TYPE_MILLIMAN RADIATION_MILLIMAN SURGERY_MILLIMAN CLINICAL_TRIAL_MILLIMAN 
		   PTD_CHEMO_MILLIMAN ACTUAL_EXP_BENE ALLOWED_MILLIMAN BASELINE_PRICE_MILLIMAN IP_UTIL OP_UTIL SNF_UTIL
		   HH_UTIL HSP_UTIL FAC_UTIL CHEMO_D_UTIL CHEMO_B_UTIL PROF_UTIL DRUG_UTIL RAD_ONC_UTIL
		   CHEMO_DAYS_PARTB	RAD_ONC_DAYS CHEMO_LENGTH_PARTB RAD_ONC_LENGTH IP_MED_CHEMO_UTIL
		   IP_MED_NON_CHEMO_UTIL IP_SURG_CHEMO_UTIL IP_SURG_NON_CHEMO_UTIL IP_OTHER_UTIL
		   /*ER_CHEMO_UTIL ER_NON_CHEMO_UTIL*/ OUT_SURG_CANCER_UTIL OUT_SURG_NONCANCER_UTIL ANTI_EMETICS_UTIL
		   HEMOTAPOETIC_UTIL OTHER_DRUGS_UTIL CHEMO_ADMIN_UTIL RAD_HTECH_UTIL RAD_OTHER_UTIL
		   LAB_UTIL PROF_IP_UTIL PROF_SURGERY_UTIL PROF_ANESTHESIA_UTIL PROF_OTHER_UTIL DME_UTIL OTHER_UTIL
		   ER_UG_OBS_UTIL OUT_SURG_UTIL OUT_OTHER_UTIL OP_UTIL PROF_OFFICE_UTIL EM_ATT_VISIT_UTIL EM_OTH_VISIT_UTIL PROF_ER_UTIL 
		   OTHER_UTIL  CHEMO_ADJ_UTIL
		   CHEMO_D_CYTO_UTIL CHEMO_B_CYTO_UTIL CHEMO_D_BIO_UTIL CHEMO_B_BIO_UTIL CHEMO_D_HARM_UTIL 
		   CHEMO_B_HARM_UTIL CHEMO_D_OTH_UTIL CHEMO_B_OTH_UTIL CHEMO_UTIL_TYPE 		   
		   RAD_MRI_UTIL RAD_CT_UTIL RAD_PET_UTIL EPI_TAX_ID EPI_NPI_ID EPI_ATT_TIN 

					EM_VISITS_BENE EM_VISITS_ALL_BENE ALL_TOS_BENE INP_ADMSNS_BENE INP_EX_BENE 
					UNPLANNED_READ_BENE ER_OBS_AD_BENE ER_AD_BENE OBS_AD_BENE ER_AND_OBS_AD_BENE 
					NO_ER_NO_OBS_AD_BENE OBS_STAYS_BENE OBS_ER_BENE OBS_NO_ER_BENE ER_NO_AD_OBS_BENE R_ONC_BENE 
					PHY_SRVC_BENE PHY_ONC_BENE PHY_OTH_BENE ANC_TOT_BENE ANC_LAB_TOT_BENE 
					ANC_LAB_ADV_BENE ANC_LAB_OTHER_BENE ANC_IMAG_TOT_BENE ANC_IMAG_ADV_BENE ANC_IMAG_OTH_BENE 
					OUT_OTHER_BENE HHA_BENE SNF_BENE LTC_BENE IRF_BENE HSP_TOT_BENE HSP_FAC_BENE 
					HSP_HOME_BENE HSP_BOTH_BENE DME_NO_DRUGS_BENE PD_TOT_BENE PD_PTB_PHYDME_BENE PD_PTB_OUT_BENE 
					PD_PTD_ALL_BENE OTHER_BENE ALL_TOS_ADJ_BENE INP_ADMSNS_ADJ_BENE INP_EX_ADJ_BENE 
					UNPLANNED_READ_ADJ_BENE ER_OBS_AD_ADJ_BENE ER_AD_ADJ_BENE OBS_AD_ADJ_BENE 
					ER_AND_OBS_AD_ADJ_BENE NO_ER_NO_OBS_AD_ADJ_BENE OBS_STAYS_ADJ_BENE OBS_ER_ADJ_BENE 
					OBS_NO_ER_ADJ_BENE ER_NO_AD_OBS_ADJ_BENE R_ONC_ADJ_BENE PHY_SRVC_ADJ_BENE PHY_ONC_ADJ_BENE 
					PHY_OTH_ADJ_BENE ANC_TOT_ADJ_BENE ANC_LAB_TOT_ADJ_BENE ANC_LAB_ADV_ADJ_BENE 
					ANC_LAB_OTHER_ADJ_BENE ANC_IMAG_TOT_ADJ_BENE ANC_IMAG_ADV_ADJ_BENE ANC_IMAG_OTH_ADJ_BENE 
					OUT_OTHER_ADJ_BENE HHA_ADJ_BENE SNF_ADJ_BENE LTC_ADJ_BENE IRF_ADJ_BENE 
					HSP_TOT_ADJ_BENE HSP_FAC_ADJ_BENE HSP_HOME_ADJ_BENE HSP_BOTH_ADJ_BENE DME_NO_DRUGS_ADJ_BENE 
					PD_TOT_ADJ_BENE PD_PTB_PHYDME_ADJ_BENE PD_PTB_OUT_ADJ_BENE PD_PTD_ALL_ADJ_BENE 
					OTHER_ADJ_BENE RISK_ADJ_FACTOR_BENE  INFLATION_FACTOR_BENE INP_ADMSNS_UTIL_BENE INP_EX_UTIL_BENE 
					UNPLANNED_READ_UTIL_BENE ER_OBS_AD_UTIL_BENE 
					ER_AD_UTIL_BENE OBS_AD_UTIL_BENE ER_AND_OBS_AD_UTIL_BENE NO_ER_NO_OBS_AD_UTIL_BENE 
					OBS_STAYS_UTIL_BENE OBS_ER_UTIL_BENE OBS_NO_ER_UTIL_BENE ER_NO_AD_OBS_UTIL_BENE 
				R_ONC_UTIL_BENE PHY_SRVC_UTIL_BENE PHY_ONC_UTIL_BENE PHY_OTH_UTIL_BENE ANC_LAB_TOT_UTIL_BENE 
					ANC_LAB_ADV_UTIL_BENE ANC_LAB_OTHER_UTIL_BENE ANC_IMAG_TOT_UTIL_BENE 
					ANC_IMAG_ADV_UTIL_BENE ANC_IMAG_OTH_UTIL_BENE HHA_UTIL_BENE SNF_UTIL_BENE LTC_UTIL_BENE 
					IRF_UTIL_BENE HSP_UTIL_BENE DIED_BENE HSP_30DAYS_ALL_BENE ANY_HSP_CARE_BENE 
					HSP_DAYS_BENE HOSPITAL_USE_BENE INTENSIVE_CARE_UNIT_BENE CHEMOTHERAPY_BENE 
					BR_KADYCLA_BENE BR_AVASTIN_BENE BR_AFINITOR_BENE BR_NEULASTA_BENE BR_PERJATA_BENE 
					BR_HEPCEPTIN_BENE PR_ZYTIGA_BENE PR_JEVTANA_BENE PR_XTANDI_BENE PR_PROVENGE_BENE 
				    LU_GILOTRIF_BENE LU_TECENTRIQ_BENE LU_AVASTIN_BENE LU_TARCEVA_BENE LU_OPDIVO_BENE LU_ABRAXANE_BENE
					LU_NEULASTA_BENE	LU_KEYTRUDA_BENE LU_ALIMTA_BENE LY_TREANDA_BENE LY_VELCADE_BENE 
					LY_IMBRUVICA_BENE LY_REVLIMID_BENE LY_OPDIVO_BENE LY_NEULASTA_BENE LY_KEYTRUDA_BENE	
					LY_RITUXAN_BENE IC_AVASTIN_BENE IC_XELODA_BENE IC_ERBITUX_BENE IC_VECTIBIX_BENE IC_NEULASTA_BENE
					IC_KEYTRUDA_BENE IC_ZALTRAP_BENE MU_VELCADE_BENE MU_KYPROLIS_BENE MU_DARZALEX_BENE MU_REVLIMID_BENE 
					BL_TECENTRIQ_BENE BL_OPDIVO_BENE HN_ERBITUX_BENE HN_OPDIVO_BENE HN_KEYTRUDA_BENE MA_COTELLIC_BENE
					MA_TAFINLAR_BENE MA_YERVOY_BENE MA_OPDIVO_BENE MA_KEYTRUDA_BENE MA_MEKINIST_BENE MA_ZELBORAF_BENE
					BR_ABRAXANE_BENE BR_IBRANCE_BENE PART_D_MM CHEMO_IN_PP BMT_MILLIMAN

			NOVEL_THER_UTIL NOVEL_THER_B_UTIL NOVEL_THER_D_UTIL NOVEL_THER_B_ALLOWED NOVEL_THER_D_ALLOWED 
			NOVEL_THER_ALLOWED DIED_MILLIMAN

			INP_ADMSNS_MILLIMAN INP_EXP_MILLIMAN REMOVE_0 ER_VISITS_MILLIMAN 
			HSP_TOT_MILLIMAN HSP_FAC_MILLIMAN HSP_HOME_MILLIMAN HSP_BOTH_MILLIMAN 
			HSP_30DAYS_ALL_MILLIMAN ANY_HSP_CARE_MILLIMAN HSP_DAYS_MILLIMAN HOSPITAL_USE_MILLIMAN 
			ICU_MILLIMAN CHEMOTHERAPY_MILLIMAN OCM1 OCM2 OCM3 DIED_IN_HOSP

			ER_OBS_AD_MILLIMAN ER_AD_MILLIMAN OBS_AD_MILLIMAN ER_AND_OBS_AD_MILLIMAN NO_ER_NO_OBS_AD_MILLIMAN 
			OBS_STAYS_MILLIMAN OBS_ER_MILLIMAN OBS_NO_ER_MILLIMAN ER_NO_AD_OBS_MILLIMAN
			INP_ADMSNS_UTIL_MILL INP_EX_UTIL_MILL ER_OBS_AD_UTIL_MILL ER_AD_UTIL_MILL 
			OBS_AD_UTIL_MILL ER_AND_OBS_AD_UTIL_MILL NO_ER_NO_OBS_AD_UTIL_MILL  DATA_COVERAGE
			IP_FROM_ED_UTIL IP_FROM_ED EMERGE_NOCHEMO EMERGE_NOEM

			SNF_COUNT HH_COUNT ER_COUNT ADMIT_COUNT CHEMOPB_ALLOWED CHEMOPD_ALLOWED ANTIEMETICS_ALLOWED			
			HEMATOPOIETIC_ALLOWED OTHRX_ALLOWED RADLAB_ALLOWED  PROF_ALLOWED IP_ALLOWED ER_ALLOWED
			OP_ALLOWED HOSPICE_ALLOWED IP_LOS EMERGE_NOCHEMO EMERGE_NOEM IP_FROM_ED_UTIL SNF_ALLOWED HH_ALLOWED 	
			MEOS_COUNT MEOS_COUNT_OTH MEOS_ALLOWED MEOS_ALLOWED_OTH Q1 Q2 Q3 Q4 Q5 ATTRIBUTE_FLAG perform_not_match
			ER_WEEKEND ER_WEEKEND_COUNT EM_ATT_TAX EM_NONATT_TAX EM_ATT_TAX_M M_EPI_SOURCE_FINAL EPI_TIN_MATCH
			MEOS_UTIL MEOS_OTH_UTIL INDEX_COUNT READ_COUNT 

 			EPISODE_PERIOD EP_ID_CMS NOVEL_THER_B_STD NOVEL_THER_D_STD NOVEL_THER_STD MEOS_STD_PAY MEOS_STD_PAY_OTH 
			CHEMOPB_std CHEMOPD_std ANTIEMETICS_std HEMATOPOIETIC_std OTHRX_std RADLAB_std  
			PROF_std IP_std ER_std OP_std HOSPICE_std SNF_std HH_std ACTUAL_EXP_STD_MILLIMAN 

			ZIPCODE DUAL_PTD_LIS INST RADIATION HCC_GRP HRR_REL_COST SURGERY CLINICAL_TRIAL BMT CLEAN_PD
			PTD_CHEMO ACTUAL_EXP BASELINE_PRICE EXPERIENCE_ADJ ACTUAL_EXP_UNADJ LOW_RISK_BLAD
			CAST_SENS_PROS MBI BENCHMARK_PRICE TARGET_PRICE OCM_DISCOUNT_ACO NOVEL_THERAPIES
			NUM_OCM1 NUM_OCM2 NUM_OCM3 DEN_OCM3 EXP_ALL_SERVICES RECON_PP1_FLAG

			RECON_ELIG RECON_ELIG_MILLIMAN 
			RECON_PP IN_RECON ATT_EPI_PERD_MATCH_CMS ATT_CANC_MATCH_CMS

			INDEX_ADMIT_COUNT READMISSION_COUNT
			EM_ATT_VISIT_UTIL_CHK EM_OTH_VISIT_UTIL_CHK;	

			IF CHEMO_IN_PP = 0 AND ATTRIBUTE_FLAG in  ("0","4") and in_recon ne 4 THEN OUTPUT outfinal.episode_emerge_&bl._&ds. ;
			ELSE OUTPUT outfinal.episode_Interface_&bl._&ds. ;

proc sort data = outfinal.ALL_CLAIMS_&bl._&DS. ; by ep_id ;
proc sort data = outfinal.episode_emerge_&bl._&ds. ; by ep_id ;
proc sort data = outfinal.episode_Interface_&bl._&ds. ; by ep_id ;

DATA outfinal.CLAIMS_Interface_&bl._&ds  outfinal.CLAIMS_Emerge_&bl._&ds  ;	
	RETAIN OCM_ID EP_ID CLAIM_ID START_DATE END_DATE NOVEL_THERAPY PRVDR_NUM ADMIT_DT DSCHRG_DT
		   AT_NPI OP_NPI DRG_CD ADMIT_DIAG_CD PRINCIPAL_DIAG_CD PROCEDURE_CD LOS STUS_CD VISITCNT 
		   HCFASPCL PRFNPI HCPCS_CD NDC REV_CNTR PRSCRBR_ID PART_D_SERVICE_DATE FILL_NUM DAYS_SUPPLY LABEL1
		   LABEL2 ALLOWED TOT_RX_CST_AMT LABEL3 NOVEL_THERAPY ER_WEEKEND ER_WEEKEND_COUNT IP_ER_CASE 
		   INDEX_ADMIT READMIT_FLAG INDEX_COUNT READ_COUNT UNITS_DOSE STD_PAY INDEX_ADMIT UNPLANNED_READMIT_FLAG HAS_READMISSION IP_CASE 
		   TAX_NUM TAXNUM_TIN ;
	MERGE outfinal.ALL_CLAIMS_&bl._&DS.(IN=A) 
		  outfinal.episode_emerge_&bl._&ds. (IN=B KEEP=EP_ID) 
		  outfinal.episode_Interface_&bl._&ds.(in=c KEEP=EP_ID); BY EP_ID ;
	KEEP OCM_ID EP_ID CLAIM_ID START_DATE END_DATE NOVEL_THERAPY PRVDR_NUM ADMIT_DT DSCHRG_DT
		   AT_NPI OP_NPI DRG_CD ADMIT_DIAG_CD PRINCIPAL_DIAG_CD PROCEDURE_CD LOS STUS_CD VISITCNT 
		   HCFASPCL PRFNPI HCPCS_CD NDC REV_CNTR PRSCRBR_ID PART_D_SERVICE_DATE FILL_NUM DAYS_SUPPLY LABEL1
		   LABEL2 ALLOWED TOT_RX_CST_AMT LABEL3 NOVEL_THERAPY ER_WEEKEND ER_WEEKEND_COUNT IP_ER_CASE 
		   INDEX_ADMIT READMIT_FLAG INDEX_COUNT READ_COUNT UNITS_DOSE STD_PAY INDEX_ADMIT UNPLANNED_READMIT_FLAG HAS_READMISSION IP_CASE
		   TAX_NUM TAXNUM_TIN ;
	IF A AND B=0 and C THEN OUTPUT outfinal.CLAIMS_Interface_&bl._&ds ;
	ELSE if A AND B AND C=0 THEN OUTPUT outfinal.CLAIMS_Emerge_&bl._&ds  ;
run ;

*** removes episodes with 0 claims (moved from check_pp macro) *** ;
proc sort data=outfinal.episode_Interface_&bl._&ds out = e ; by ep_id ;
proc sort data=outfinal.ALL_CLAIMS_&bl._&ds out = c ; by ep_id ;
data check2 ;
	merge e(in=a) c(in=b) ; by ep_id ;
	if a and b=0 then output ; 

data outfinal.episode_Interface_&bl._&ds ;
	merge e(in=a) check2(in=b keep=ep_id) ; by ep_id ;
	if a and b=0 ;

data incomplete ;
	SET EPIPRE2 ;
	if first_name = "  " and last_name = "  " ;
run ;

************************************************************************************************************* ;
************************* MEOS FILES ************************************************************************ ;
************************************************************************************************************* ;

DATA outfinal.Claims_MEOS_&bl._&ds   ;	
	RETAIN OCM_ID BENE_ID EP_ID CLAIM_ID START_DATE END_DATE NOVEL_THERAPY PRVDR_NUM ADMIT_DT DSCHRG_DT
		   AT_NPI OP_NPI DRG_CD ADMIT_DIAG_CD PRINCIPAL_DIAG_CD PROCEDURE_CD LOS STUS_CD VISITCNT 
		   HCFASPCL PRFNPI HCPCS_CD NDC REV_CNTR PRSCRBR_ID PART_D_SERVICE_DATE FILL_NUM DAYS_SUPPLY LABEL1
		   LABEL2 ALLOWED TOT_RX_CST_AMT LABEL3 NOVEL_THERAPY ER_WEEKEND ER_WEEKEND_COUNT IP_ER_CASE 
		   INDEX_ADMIT READMIT_FLAG INDEX_COUNT READ_COUNT UNITS_DOSE STD_PAY MEOS_ATT MEOS_COUNT MEOS_ALLOWED MEOS_STD_PAY 
		   MEOS_COUNT_OTH MEOS_ALLOWED_OTH MEOS_STD_PAY_OTH MEOS INDEX_ADMIT UNPLANNED_READMIT_FLAG HAS_READMISSION IP_CASE
		   TAX_NUM TAXNUM_TIN ;
	SET MEOS_CLAIMS ;
	KEEP OCM_ID BENE_ID EP_ID CLAIM_ID START_DATE END_DATE NOVEL_THERAPY PRVDR_NUM ADMIT_DT DSCHRG_DT
		   AT_NPI OP_NPI DRG_CD ADMIT_DIAG_CD PRINCIPAL_DIAG_CD PROCEDURE_CD LOS STUS_CD VISITCNT 
		   HCFASPCL PRFNPI HCPCS_CD NDC REV_CNTR PRSCRBR_ID PART_D_SERVICE_DATE FILL_NUM DAYS_SUPPLY LABEL1
		   LABEL2 ALLOWED TOT_RX_CST_AMT LABEL3 NOVEL_THERAPY ER_WEEKEND ER_WEEKEND_COUNT IP_ER_CASE 
		   INDEX_ADMIT READMIT_FLAG INDEX_COUNT READ_COUNT UNITS_DOSE STD_PAY MEOS_ATT MEOS_COUNT MEOS_ALLOWED MEOS_STD_PAY 
		   MEOS_COUNT_OTH MEOS_ALLOWED_OTH MEOS_STD_PAY_OTH MEOS_OTH INDEX_ADMIT UNPLANNED_READMIT_FLAG HAS_READMISSION IP_CASE
		   TAX_NUM TAXNUM_TIN ;

proc sort data=meos_claims ; by bene_id ep_id  ;
proc means data=meos_claims noprint sum MAX; by bene_id ep_id ;
	var MEOS_COUNT 	   MEOS_ALLOWED 	MEOS_STD_PAY  MEOS 
		MEOS_COUNT_OTH MEOS_ALLOWED_OTH MEOS_STD_PAY_OTH  MEOS_OTH;
	output out=meos_summary(drop = _type_ _freq_)
		   sum(MEOS_COUNT 	   MEOS_ALLOWED 	MEOS_STD_PAY  
			   MEOS_COUNT_OTH MEOS_ALLOWED_OTH MEOS_STD_PAY_OTH) = 
		   MAX(MEOS MEOS_OTH) = ;

DATA MEOS_SUMMARY ;
	SET MEOS_SUMMARY ;
	MEOS_UTIL = MAX(0,MEOS) ;
	MEOS_OTH_UTIL = MAX(0,MEOS_OTH) ;
	MEOS_COUNT = MAX(0,MEOS_COUNT) ;
	MEOS_COUNT_OTH = MAX(0, MEOS_COUNT_OTH) ;

proc sort data = outfinal.episode_emerge_&bl._&ds. OUT=EE; by BENE_ID ep_id ;
proc sort data = outfinal.episode_Interface_&bl._&ds. OUT=EI ; by BENE_ID ep_id ;

DATA MEOS_EPI_A MEOS_EPI_B ;
	MERGE EE(IN=A 	DROP =MEOS_COUNT 	   	MEOS_ALLOWED 		MEOS_STD_PAY  MEOS_UTIL OCM_ID
				   		  MEOS_COUNT_OTH 	MEOS_ALLOWED_OTH 	MEOS_STD_PAY_OTH  MEOS_OTH_UTIL)
		  EI(IN=B 	DROP =MEOS_COUNT 	   	MEOS_ALLOWED 		MEOS_STD_PAY  MEOS_UTIL OCM_ID
				   		  MEOS_COUNT_OTH 	MEOS_ALLOWED_OTH 	MEOS_STD_PAY_OTH  MEOS_OTH_UTIL)
		  MEOS_SUMMARY (IN=C) ; BY BENE_ID EP_ID ;
	IF C = 0 THEN DO ;
		MEOS_UTIL = 0 ;
		MEOS_OTH_UTIL = 0 ;
		MEOS_COUNT = 0 ;
		MEOS_COUNT_OTH =  0 ;
		MEOS_ALLOWED = 0 ;
		MEOS_ALLOWED_OTH = 0 ;
		MEOS_STD_PAY = 0 ;
		MEOS_STD_PAY_OTH = 0 ;
	END ;
	IF A THEN EMERGE_EPI = "Y" ;
	IF B THEN EMERGE_EPI = "N" ;
	IF A=0 AND B=0 THEN EMERGE_EPI = "0" ;

		OCM_ID = "&id." ;

	IF EMERGE_EPI = "0" THEN OUTPUT MEOS_EPI_B ;
	ELSE OUTPUT MEOS_EPI_A ;

*** Capture MEOS Beneficiary Information for MEOS payments not attributed to an episode. *** ;

DATA EPI_INFO ;
	SET EE EI ;

PROC SORT DATA=EPI_INFO ; BY BENE_ID EP_BEG ;
DATA EPI_INFO(KEEP = BENE_ID BENE_HICN FIRST_NAME LAST_NAME PATIENT_NAME SEX CANCER_TYPE PATIENT_SEX DOB AGE DOD ) ; 
	SET EPI_INFO ; BY BENE_ID EP_BEG ;
	IF LAST.BENE_ID ;  *** Keeps latest available information for beneficiary. *** ;

PROC SORT DATA=MEOS_EPI_B ; BY BENE_ID ;
*** Check to see that all unattributed MEOS payments get bene info. *** ;
DATA MEOS_EPI_B2 NOBENE ;
	MERGE MEOS_EPI_B(IN=A) EPI_INFO(IN=B) ; BY BENE_ID ;
	IF A THEN OUTPUT MEOS_EPI_B2 ;
	IF A AND B=0 THEN OUTPUT NOBENE ;

DATA MEOS_EPI_a Missing_DEMO ;
	SET MEOS_EPI_A MEOS_EPI_B2 ;
	IF LAST_NAME = "  " THEN OUTPUT MISSING_DEMO ;
	ELSE OUTPUT MEOS_EPI_A ;

PROC SORT DATA=MISSING_DEMO ; BY BENE_ID  ;
PROC SORT DATA=out.epi_prelim_&BL._&ds. OUT=EPI_P NODUPKEY ; BY BENE_ID ;

DATA MEOS_EPI_B ;
	MERGE MISSING_DEMO (IN=A DROP=LAST_NAME FIRST_NAME PATIENT_NAME SEX PATIENT_SEX DOB DOD AGE) 
	EPI_P(IN=B KEEP=BENE_ID BENE_HICN LAST_NAME FIRST_NAME SEX DOB DOD AGE) ; BY BENE_ID ;
	IF A ;
	FORMAT PATIENT_NAME $50. ;   LENGTH PATIENT_NAME $50. ;
	IF LAST_NAME NE "  " THEN PATIENT_NAME = PROPCASE(COMPRESS(LAST_NAME,' '))||', '||PROPCASE(COMPRESS(FIRST_NAME,' ')) ;	
	ELSE PATIENT_NAME = "UNKNOWN" ;
	IF SEX IN ("M","1") THEN PATIENT_SEX = 1  ;
	ELSE IF SEX in ("F","2") THEN PATIENT_SEX = 2 ;
	ELSE PATIENT_SEX = 0 ;
RUN ;

DATA MEOS_EPI ;
	SET MEOS_EPI_A MEOS_EPI_B;
	IF CANCER_TYPE_MILLIMAN IN ('Acute Leukemia','Anal Cancer','Bladder Cancer','Breast Cancer','Chronic Leukemia',
									'CNS Tumor','Intestinal Cancer','Endocrine Tumor','Female GU Cancer other than Ovary',
									'Gastro/Esophageal Cancer','Head and Neck Cancer','Kidney Cancer','Liver Cancer',
									'Lung Cancer','Lymphoma','Malignant Melanoma','MDS','Multiple Myeloma',
									'Ovarian Cancer','Pancreatic Cancer','Prostate Cancer',"Bladder Cancer - Low Risk",
									"Bladder Cancer - High Risk","Prostate Cancer - Low Intensity",
									"Prostate Cancer - High Intensity","Small Intestine / Colorectal Cancer",
									"Breast Cancer - Low Risk","Breast Cancer - High Risk") THEN RECON_ELIG_MILLIMAN = "1" ;
	ELSE RECON_ELIG_MILLIMAN = "0" ;
	IF CANCER_TYPE IN ('Acute Leukemia','Anal Cancer','Bladder Cancer','Breast Cancer','Chronic Leukemia',
									'CNS Tumor','Intestinal Cancer','Endocrine Tumor','Female GU Cancer other than Ovary',
									'Gastro/Esophageal Cancer','Head and Neck Cancer','Kidney Cancer','Liver Cancer',
									'Lung Cancer','Lymphoma','Malignant Melanoma','MDS','Multiple Myeloma',
									'Ovarian Cancer','Pancreatic Cancer','Prostate Cancer',"Bladder Cancer - Low Risk",
									"Bladder Cancer - High Risk","Prostate Cancer - Low Intensity",
									"Prostate Cancer - High Intensity","Small Intestine / Colorectal Cancer",
								    "Breast Cancer - Low Risk","Breast Cancer - High Risk") THEN RECON_ELIG = "1" ;
	ELSE RECON_ELIG = "0" ;
RUN ;

DATA OUTFINAL.episode_meos_&bl._&ds. ;
	RETAIN OCM_ID BENE_ID BENE_HICN FIRST_NAME LAST_NAME PATIENT_NAME SEX 
		   PATIENT_SEX DOB AGE DOD EP_ID EPI_COUNTER EP_BEG EP_END EP_LENGTH
		   CANCER_TYPE QTR_START_DATE CHEMO_DATE RISK_SCORE HIGH_RISK COMMON_CANCER_TYPE AGE_CATEGORY RACE DUAL 
			CANCER_TYPE_MILLIMAN RADIATION_MILLIMAN SURGERY_MILLIMAN CLINICAL_TRIAL_MILLIMAN 
		   PTD_CHEMO_MILLIMAN ACTUAL_EXP_BENE ALLOWED_MILLIMAN BASELINE_PRICE_MILLIMAN IP_UTIL OP_UTIL SNF_UTIL
		   HH_UTIL HSP_UTIL FAC_UTIL CHEMO_D_UTIL CHEMO_B_UTIL PROF_UTIL DRUG_UTIL RAD_ONC_UTIL
		   CHEMO_DAYS_PARTB	RAD_ONC_DAYS CHEMO_LENGTH_PARTB RAD_ONC_LENGTH IP_MED_CHEMO_UTIL
		   IP_MED_NON_CHEMO_UTIL IP_SURG_CHEMO_UTIL IP_SURG_NON_CHEMO_UTIL IP_OTHER_UTIL
		   /*ER_CHEMO_UTIL ER_NON_CHEMO_UTIL*/ OUT_SURG_CANCER_UTIL OUT_SURG_NONCANCER_UTIL ANTI_EMETICS_UTIL
		   HEMOTAPOETIC_UTIL OTHER_DRUGS_UTIL CHEMO_ADMIN_UTIL RAD_HTECH_UTIL RAD_OTHER_UTIL
		   LAB_UTIL PROF_IP_UTIL PROF_SURGERY_UTIL PROF_ANESTHESIA_UTIL PROF_OTHER_UTIL DME_UTIL OTHER_UTIL
		   ER_UG_OBS_UTIL OUT_SURG_UTIL OUT_OTHER_UTIL OP_UTIL PROF_OFFICE_UTIL EM_ATT_VISIT_UTIL EM_OTH_VISIT_UTIL PROF_ER_UTIL 
		   OTHER_UTIL  CHEMO_ADJ_UTIL
		   CHEMO_D_CYTO_UTIL CHEMO_B_CYTO_UTIL CHEMO_D_BIO_UTIL CHEMO_B_BIO_UTIL CHEMO_D_HARM_UTIL 
		   CHEMO_B_HARM_UTIL CHEMO_D_OTH_UTIL CHEMO_B_OTH_UTIL CHEMO_UTIL_TYPE 		   
		   RAD_MRI_UTIL RAD_CT_UTIL RAD_PET_UTIL EPI_TAX_ID EPI_NPI_ID EPI_ATT_TIN 

					EM_VISITS_BENE EM_VISITS_ALL_BENE ALL_TOS_BENE INP_ADMSNS_BENE INP_EX_BENE 
					UNPLANNED_READ_BENE ER_OBS_AD_BENE ER_AD_BENE OBS_AD_BENE ER_AND_OBS_AD_BENE 
					NO_ER_NO_OBS_AD_BENE OBS_STAYS_BENE OBS_ER_BENE OBS_NO_ER_BENE ER_NO_AD_OBS_BENE R_ONC_BENE 
					PHY_SRVC_BENE PHY_ONC_BENE PHY_OTH_BENE ANC_TOT_BENE ANC_LAB_TOT_BENE 
					ANC_LAB_ADV_BENE ANC_LAB_OTHER_BENE ANC_IMAG_TOT_BENE ANC_IMAG_ADV_BENE ANC_IMAG_OTH_BENE 
					OUT_OTHER_BENE HHA_BENE SNF_BENE LTC_BENE IRF_BENE HSP_TOT_BENE HSP_FAC_BENE 
					HSP_HOME_BENE HSP_BOTH_BENE DME_NO_DRUGS_BENE PD_TOT_BENE PD_PTB_PHYDME_BENE PD_PTB_OUT_BENE 
					PD_PTD_ALL_BENE OTHER_BENE ALL_TOS_ADJ_BENE INP_ADMSNS_ADJ_BENE INP_EX_ADJ_BENE 
					UNPLANNED_READ_ADJ_BENE ER_OBS_AD_ADJ_BENE ER_AD_ADJ_BENE OBS_AD_ADJ_BENE 
					ER_AND_OBS_AD_ADJ_BENE NO_ER_NO_OBS_AD_ADJ_BENE OBS_STAYS_ADJ_BENE OBS_ER_ADJ_BENE 
					OBS_NO_ER_ADJ_BENE ER_NO_AD_OBS_ADJ_BENE R_ONC_ADJ_BENE PHY_SRVC_ADJ_BENE PHY_ONC_ADJ_BENE 
					PHY_OTH_ADJ_BENE ANC_TOT_ADJ_BENE ANC_LAB_TOT_ADJ_BENE ANC_LAB_ADV_ADJ_BENE 
					ANC_LAB_OTHER_ADJ_BENE ANC_IMAG_TOT_ADJ_BENE ANC_IMAG_ADV_ADJ_BENE ANC_IMAG_OTH_ADJ_BENE 
					OUT_OTHER_ADJ_BENE HHA_ADJ_BENE SNF_ADJ_BENE LTC_ADJ_BENE IRF_ADJ_BENE 
					HSP_TOT_ADJ_BENE HSP_FAC_ADJ_BENE HSP_HOME_ADJ_BENE HSP_BOTH_ADJ_BENE DME_NO_DRUGS_ADJ_BENE 
					PD_TOT_ADJ_BENE PD_PTB_PHYDME_ADJ_BENE PD_PTB_OUT_ADJ_BENE PD_PTD_ALL_ADJ_BENE 
					OTHER_ADJ_BENE RISK_ADJ_FACTOR_BENE  INFLATION_FACTOR_BENE INP_ADMSNS_UTIL_BENE INP_EX_UTIL_BENE 
					UNPLANNED_READ_UTIL_BENE ER_OBS_AD_UTIL_BENE 
					ER_AD_UTIL_BENE OBS_AD_UTIL_BENE ER_AND_OBS_AD_UTIL_BENE NO_ER_NO_OBS_AD_UTIL_BENE 
					OBS_STAYS_UTIL_BENE OBS_ER_UTIL_BENE OBS_NO_ER_UTIL_BENE ER_NO_AD_OBS_UTIL_BENE 
				R_ONC_UTIL_BENE PHY_SRVC_UTIL_BENE PHY_ONC_UTIL_BENE PHY_OTH_UTIL_BENE ANC_LAB_TOT_UTIL_BENE 
					ANC_LAB_ADV_UTIL_BENE ANC_LAB_OTHER_UTIL_BENE ANC_IMAG_TOT_UTIL_BENE 
					ANC_IMAG_ADV_UTIL_BENE ANC_IMAG_OTH_UTIL_BENE HHA_UTIL_BENE SNF_UTIL_BENE LTC_UTIL_BENE 
					IRF_UTIL_BENE HSP_UTIL_BENE DIED_BENE HSP_30DAYS_ALL_BENE ANY_HSP_CARE_BENE 
					HSP_DAYS_BENE HOSPITAL_USE_BENE INTENSIVE_CARE_UNIT_BENE CHEMOTHERAPY_BENE 
					BR_KADYCLA_BENE BR_AVASTIN_BENE BR_AFINITOR_BENE BR_NEULASTA_BENE BR_PERJATA_BENE 
					BR_HEPCEPTIN_BENE PR_ZYTIGA_BENE PR_JEVTANA_BENE PR_XTANDI_BENE PR_PROVENGE_BENE 
				    LU_GILOTRIF_BENE LU_TECENTRIQ_BENE LU_AVASTIN_BENE LU_TARCEVA_BENE LU_OPDIVO_BENE LU_ABRAXANE_BENE
					LU_NEULASTA_BENE	LU_KEYTRUDA_BENE LU_ALIMTA_BENE LY_TREANDA_BENE LY_VELCADE_BENE 
					LY_IMBRUVICA_BENE LY_REVLIMID_BENE LY_OPDIVO_BENE LY_NEULASTA_BENE LY_KEYTRUDA_BENE	
					LY_RITUXAN_BENE IC_AVASTIN_BENE IC_XELODA_BENE IC_ERBITUX_BENE IC_VECTIBIX_BENE IC_NEULASTA_BENE
					IC_KEYTRUDA_BENE IC_ZALTRAP_BENE MU_VELCADE_BENE MU_KYPROLIS_BENE MU_DARZALEX_BENE MU_REVLIMID_BENE 
					BL_TECENTRIQ_BENE BL_OPDIVO_BENE HN_ERBITUX_BENE HN_OPDIVO_BENE HN_KEYTRUDA_BENE MA_COTELLIC_BENE
					MA_TAFINLAR_BENE MA_YERVOY_BENE MA_OPDIVO_BENE MA_KEYTRUDA_BENE MA_MEKINIST_BENE MA_ZELBORAF_BENE
					BR_ABRAXANE_BENE BR_IBRANCE_BENE PART_D_MM CHEMO_IN_PP BMT_MILLIMAN

			NOVEL_THER_UTIL NOVEL_THER_B_UTIL NOVEL_THER_D_UTIL NOVEL_THER_B_ALLOWED NOVEL_THER_D_ALLOWED 
			NOVEL_THER_ALLOWED DIED_MILLIMAN

			INP_ADMSNS_MILLIMAN INP_EXP_MILLIMAN REMOVE_0 ER_VISITS_MILLIMAN 
			HSP_TOT_MILLIMAN HSP_FAC_MILLIMAN HSP_HOME_MILLIMAN HSP_BOTH_MILLIMAN 
			HSP_30DAYS_ALL_MILLIMAN ANY_HSP_CARE_MILLIMAN HSP_DAYS_MILLIMAN HOSPITAL_USE_MILLIMAN 
			ICU_MILLIMAN CHEMOTHERAPY_MILLIMAN OCM1 OCM2 OCM3 DIED_IN_HOSP

			ER_OBS_AD_MILLIMAN ER_AD_MILLIMAN OBS_AD_MILLIMAN ER_AND_OBS_AD_MILLIMAN NO_ER_NO_OBS_AD_MILLIMAN 
			OBS_STAYS_MILLIMAN OBS_ER_MILLIMAN OBS_NO_ER_MILLIMAN ER_NO_AD_OBS_MILLIMAN
			INP_ADMSNS_UTIL_MILL INP_EX_UTIL_MILL ER_OBS_AD_UTIL_MILL ER_AD_UTIL_MILL 
			OBS_AD_UTIL_MILL ER_AND_OBS_AD_UTIL_MILL NO_ER_NO_OBS_AD_UTIL_MILL  DATA_COVERAGE
			IP_FROM_ED_UTIL IP_FROM_ED EMERGE_NOCHEMO EMERGE_NOEM

			SNF_COUNT HH_COUNT ER_COUNT ADMIT_COUNT CHEMOPB_ALLOWED CHEMOPD_ALLOWED ANTIEMETICS_ALLOWED			
			HEMATOPOIETIC_ALLOWED OTHRX_ALLOWED RADLAB_ALLOWED  PROF_ALLOWED IP_ALLOWED ER_ALLOWED
			OP_ALLOWED HOSPICE_ALLOWED IP_LOS EMERGE_NOCHEMO EMERGE_NOEM IP_FROM_ED_UTIL SNF_ALLOWED HH_ALLOWED 	
			MEOS_COUNT MEOS_COUNT_OTH MEOS_ALLOWED MEOS_ALLOWED_OTH Q1 Q2 Q3 Q4 Q5 ATTRIBUTE_FLAG perform_not_match
			ER_WEEKEND ER_WEEKEND_COUNT EM_ATT_TAX EM_NONATT_TAX EM_ATT_TAX_M M_EPI_SOURCE_FINAL EPI_TIN_MATCH
			MEOS_UTIL MEOS_OTH_UTIL INDEX_COUNT READ_COUNT 

 			EPISODE_PERIOD EP_ID_CMS NOVEL_THER_B_STD NOVEL_THER_D_STD NOVEL_THER_STD MEOS_STD_PAY MEOS_STD_PAY_OTH 
			CHEMOPB_std CHEMOPD_std ANTIEMETICS_std HEMATOPOIETIC_std OTHRX_std RADLAB_std  
			PROF_std IP_std ER_std OP_std HOSPICE_std SNF_std HH_std ACTUAL_EXP_STD_MILLIMAN 

			ZIPCODE DUAL_PTD_LIS INST RADIATION HCC_GRP HRR_REL_COST SURGERY CLINICAL_TRIAL BMT CLEAN_PD
			PTD_CHEMO ACTUAL_EXP BASELINE_PRICE EXPERIENCE_ADJ ACTUAL_EXP_UNADJ LOW_RISK_BLAD
			CAST_SENS_PROS MBI BENCHMARK_PRICE TARGET_PRICE OCM_DISCOUNT_ACO NOVEL_THERAPIES
			NUM_OCM1 NUM_OCM2 NUM_OCM3 DEN_OCM3 EXP_ALL_SERVICES RECON_PP1_FLAG

			RECON_ELIG RECON_ELIG_MILLIMAN 

			EMERGE_EPI 

			RECON_PP IN_RECON ATT_EPI_PERD_MATCH_CMS ATT_CANC_MATCH_CMS

			INDEX_ADMIT_COUNT READMISSION_COUNT
			EM_ATT_VISIT_UTIL_CHK EM_OTH_VISIT_UTIL_CHK;

	SET MEOS_EPI ;
	KEEP  OCM_ID BENE_ID BENE_HICN FIRST_NAME LAST_NAME PATIENT_NAME SEX 
		   PATIENT_SEX DOB AGE DOD EP_ID EPI_COUNTER EP_BEG EP_END EP_LENGTH
		   CANCER_TYPE QTR_START_DATE CHEMO_DATE RISK_SCORE HIGH_RISK COMMON_CANCER_TYPE AGE_CATEGORY RACE DUAL 
			CANCER_TYPE_MILLIMAN RADIATION_MILLIMAN SURGERY_MILLIMAN CLINICAL_TRIAL_MILLIMAN 
		   PTD_CHEMO_MILLIMAN ACTUAL_EXP_BENE ALLOWED_MILLIMAN BASELINE_PRICE_MILLIMAN IP_UTIL OP_UTIL SNF_UTIL
		   HH_UTIL HSP_UTIL FAC_UTIL CHEMO_D_UTIL CHEMO_B_UTIL PROF_UTIL DRUG_UTIL RAD_ONC_UTIL
		   CHEMO_DAYS_PARTB	RAD_ONC_DAYS CHEMO_LENGTH_PARTB RAD_ONC_LENGTH IP_MED_CHEMO_UTIL
		   IP_MED_NON_CHEMO_UTIL IP_SURG_CHEMO_UTIL IP_SURG_NON_CHEMO_UTIL IP_OTHER_UTIL
		   /*ER_CHEMO_UTIL ER_NON_CHEMO_UTIL*/ OUT_SURG_CANCER_UTIL OUT_SURG_NONCANCER_UTIL ANTI_EMETICS_UTIL
		   HEMOTAPOETIC_UTIL OTHER_DRUGS_UTIL CHEMO_ADMIN_UTIL RAD_HTECH_UTIL RAD_OTHER_UTIL
		   LAB_UTIL PROF_IP_UTIL PROF_SURGERY_UTIL PROF_ANESTHESIA_UTIL PROF_OTHER_UTIL DME_UTIL OTHER_UTIL
		   ER_UG_OBS_UTIL OUT_SURG_UTIL OUT_OTHER_UTIL OP_UTIL PROF_OFFICE_UTIL EM_ATT_VISIT_UTIL EM_OTH_VISIT_UTIL PROF_ER_UTIL 
		   OTHER_UTIL  CHEMO_ADJ_UTIL
		   CHEMO_D_CYTO_UTIL CHEMO_B_CYTO_UTIL CHEMO_D_BIO_UTIL CHEMO_B_BIO_UTIL CHEMO_D_HARM_UTIL 
		   CHEMO_B_HARM_UTIL CHEMO_D_OTH_UTIL CHEMO_B_OTH_UTIL CHEMO_UTIL_TYPE 		   
		   RAD_MRI_UTIL RAD_CT_UTIL RAD_PET_UTIL EPI_TAX_ID EPI_NPI_ID EPI_ATT_TIN 

					EM_VISITS_BENE EM_VISITS_ALL_BENE ALL_TOS_BENE INP_ADMSNS_BENE INP_EX_BENE 
					UNPLANNED_READ_BENE ER_OBS_AD_BENE ER_AD_BENE OBS_AD_BENE ER_AND_OBS_AD_BENE 
					NO_ER_NO_OBS_AD_BENE OBS_STAYS_BENE OBS_ER_BENE OBS_NO_ER_BENE ER_NO_AD_OBS_BENE R_ONC_BENE 
					PHY_SRVC_BENE PHY_ONC_BENE PHY_OTH_BENE ANC_TOT_BENE ANC_LAB_TOT_BENE 
					ANC_LAB_ADV_BENE ANC_LAB_OTHER_BENE ANC_IMAG_TOT_BENE ANC_IMAG_ADV_BENE ANC_IMAG_OTH_BENE 
					OUT_OTHER_BENE HHA_BENE SNF_BENE LTC_BENE IRF_BENE HSP_TOT_BENE HSP_FAC_BENE 
					HSP_HOME_BENE HSP_BOTH_BENE DME_NO_DRUGS_BENE PD_TOT_BENE PD_PTB_PHYDME_BENE PD_PTB_OUT_BENE 
					PD_PTD_ALL_BENE OTHER_BENE ALL_TOS_ADJ_BENE INP_ADMSNS_ADJ_BENE INP_EX_ADJ_BENE 
					UNPLANNED_READ_ADJ_BENE ER_OBS_AD_ADJ_BENE ER_AD_ADJ_BENE OBS_AD_ADJ_BENE 
					ER_AND_OBS_AD_ADJ_BENE NO_ER_NO_OBS_AD_ADJ_BENE OBS_STAYS_ADJ_BENE OBS_ER_ADJ_BENE 
					OBS_NO_ER_ADJ_BENE ER_NO_AD_OBS_ADJ_BENE R_ONC_ADJ_BENE PHY_SRVC_ADJ_BENE PHY_ONC_ADJ_BENE 
					PHY_OTH_ADJ_BENE ANC_TOT_ADJ_BENE ANC_LAB_TOT_ADJ_BENE ANC_LAB_ADV_ADJ_BENE 
					ANC_LAB_OTHER_ADJ_BENE ANC_IMAG_TOT_ADJ_BENE ANC_IMAG_ADV_ADJ_BENE ANC_IMAG_OTH_ADJ_BENE 
					OUT_OTHER_ADJ_BENE HHA_ADJ_BENE SNF_ADJ_BENE LTC_ADJ_BENE IRF_ADJ_BENE 
					HSP_TOT_ADJ_BENE HSP_FAC_ADJ_BENE HSP_HOME_ADJ_BENE HSP_BOTH_ADJ_BENE DME_NO_DRUGS_ADJ_BENE 
					PD_TOT_ADJ_BENE PD_PTB_PHYDME_ADJ_BENE PD_PTB_OUT_ADJ_BENE PD_PTD_ALL_ADJ_BENE 
					OTHER_ADJ_BENE RISK_ADJ_FACTOR_BENE  INFLATION_FACTOR_BENE INP_ADMSNS_UTIL_BENE INP_EX_UTIL_BENE 
					UNPLANNED_READ_UTIL_BENE ER_OBS_AD_UTIL_BENE 
					ER_AD_UTIL_BENE OBS_AD_UTIL_BENE ER_AND_OBS_AD_UTIL_BENE NO_ER_NO_OBS_AD_UTIL_BENE 
					OBS_STAYS_UTIL_BENE OBS_ER_UTIL_BENE OBS_NO_ER_UTIL_BENE ER_NO_AD_OBS_UTIL_BENE 
				R_ONC_UTIL_BENE PHY_SRVC_UTIL_BENE PHY_ONC_UTIL_BENE PHY_OTH_UTIL_BENE ANC_LAB_TOT_UTIL_BENE 
					ANC_LAB_ADV_UTIL_BENE ANC_LAB_OTHER_UTIL_BENE ANC_IMAG_TOT_UTIL_BENE 
					ANC_IMAG_ADV_UTIL_BENE ANC_IMAG_OTH_UTIL_BENE HHA_UTIL_BENE SNF_UTIL_BENE LTC_UTIL_BENE 
					IRF_UTIL_BENE HSP_UTIL_BENE DIED_BENE HSP_30DAYS_ALL_BENE ANY_HSP_CARE_BENE 
					HSP_DAYS_BENE HOSPITAL_USE_BENE INTENSIVE_CARE_UNIT_BENE CHEMOTHERAPY_BENE 
					BR_KADYCLA_BENE BR_AVASTIN_BENE BR_AFINITOR_BENE BR_NEULASTA_BENE BR_PERJATA_BENE 
					BR_HEPCEPTIN_BENE PR_ZYTIGA_BENE PR_JEVTANA_BENE PR_XTANDI_BENE PR_PROVENGE_BENE 
				    LU_GILOTRIF_BENE LU_TECENTRIQ_BENE LU_AVASTIN_BENE LU_TARCEVA_BENE LU_OPDIVO_BENE LU_ABRAXANE_BENE
					LU_NEULASTA_BENE	LU_KEYTRUDA_BENE LU_ALIMTA_BENE LY_TREANDA_BENE LY_VELCADE_BENE 
					LY_IMBRUVICA_BENE LY_REVLIMID_BENE LY_OPDIVO_BENE LY_NEULASTA_BENE LY_KEYTRUDA_BENE	
					LY_RITUXAN_BENE IC_AVASTIN_BENE IC_XELODA_BENE IC_ERBITUX_BENE IC_VECTIBIX_BENE IC_NEULASTA_BENE
					IC_KEYTRUDA_BENE IC_ZALTRAP_BENE MU_VELCADE_BENE MU_KYPROLIS_BENE MU_DARZALEX_BENE MU_REVLIMID_BENE 
					BL_TECENTRIQ_BENE BL_OPDIVO_BENE HN_ERBITUX_BENE HN_OPDIVO_BENE HN_KEYTRUDA_BENE MA_COTELLIC_BENE
					MA_TAFINLAR_BENE MA_YERVOY_BENE MA_OPDIVO_BENE MA_KEYTRUDA_BENE MA_MEKINIST_BENE MA_ZELBORAF_BENE
					BR_ABRAXANE_BENE BR_IBRANCE_BENE PART_D_MM CHEMO_IN_PP BMT_MILLIMAN

			NOVEL_THER_UTIL NOVEL_THER_B_UTIL NOVEL_THER_D_UTIL NOVEL_THER_B_ALLOWED NOVEL_THER_D_ALLOWED 
			NOVEL_THER_ALLOWED DIED_MILLIMAN

			INP_ADMSNS_MILLIMAN INP_EXP_MILLIMAN REMOVE_0 ER_VISITS_MILLIMAN 
			HSP_TOT_MILLIMAN HSP_FAC_MILLIMAN HSP_HOME_MILLIMAN HSP_BOTH_MILLIMAN 
			HSP_30DAYS_ALL_MILLIMAN ANY_HSP_CARE_MILLIMAN HSP_DAYS_MILLIMAN HOSPITAL_USE_MILLIMAN 
			ICU_MILLIMAN CHEMOTHERAPY_MILLIMAN OCM1 OCM2 OCM3 DIED_IN_HOSP

			ER_OBS_AD_MILLIMAN ER_AD_MILLIMAN OBS_AD_MILLIMAN ER_AND_OBS_AD_MILLIMAN NO_ER_NO_OBS_AD_MILLIMAN 
			OBS_STAYS_MILLIMAN OBS_ER_MILLIMAN OBS_NO_ER_MILLIMAN ER_NO_AD_OBS_MILLIMAN
			INP_ADMSNS_UTIL_MILL INP_EX_UTIL_MILL ER_OBS_AD_UTIL_MILL ER_AD_UTIL_MILL 
			OBS_AD_UTIL_MILL ER_AND_OBS_AD_UTIL_MILL NO_ER_NO_OBS_AD_UTIL_MILL  DATA_COVERAGE
			IP_FROM_ED_UTIL IP_FROM_ED EMERGE_NOCHEMO EMERGE_NOEM

			SNF_COUNT HH_COUNT ER_COUNT ADMIT_COUNT CHEMOPB_ALLOWED CHEMOPD_ALLOWED ANTIEMETICS_ALLOWED			
			HEMATOPOIETIC_ALLOWED OTHRX_ALLOWED RADLAB_ALLOWED  PROF_ALLOWED IP_ALLOWED ER_ALLOWED
			OP_ALLOWED HOSPICE_ALLOWED IP_LOS EMERGE_NOCHEMO EMERGE_NOEM IP_FROM_ED_UTIL SNF_ALLOWED HH_ALLOWED 	
			MEOS_COUNT MEOS_COUNT_OTH MEOS_ALLOWED MEOS_ALLOWED_OTH Q1 Q2 Q3 Q4 Q5 ATTRIBUTE_FLAG perform_not_match
			ER_WEEKEND ER_WEEKEND_COUNT EM_ATT_TAX EM_NONATT_TAX EM_ATT_TAX_M M_EPI_SOURCE_FINAL EPI_TIN_MATCH
			MEOS_UTIL MEOS_OTH_UTIL INDEX_COUNT READ_COUNT 

 			EPISODE_PERIOD EP_ID_CMS NOVEL_THER_B_STD NOVEL_THER_D_STD NOVEL_THER_STD MEOS_STD_PAY MEOS_STD_PAY_OTH 
			CHEMOPB_std CHEMOPD_std ANTIEMETICS_std HEMATOPOIETIC_std OTHRX_std RADLAB_std  
			PROF_std IP_std ER_std OP_std HOSPICE_std SNF_std HH_std ACTUAL_EXP_STD_MILLIMAN 

			ZIPCODE DUAL_PTD_LIS INST RADIATION HCC_GRP HRR_REL_COST SURGERY CLINICAL_TRIAL BMT CLEAN_PD
			PTD_CHEMO ACTUAL_EXP BASELINE_PRICE EXPERIENCE_ADJ ACTUAL_EXP_UNADJ LOW_RISK_BLAD
			CAST_SENS_PROS MBI BENCHMARK_PRICE TARGET_PRICE OCM_DISCOUNT_ACO NOVEL_THERAPIES
			NUM_OCM1 NUM_OCM2 NUM_OCM3 DEN_OCM3 EXP_ALL_SERVICES RECON_PP1_FLAG

			RECON_ELIG RECON_ELIG_MILLIMAN 

			EMERGE_EPI 

			RECON_PP IN_RECON ATT_EPI_PERD_MATCH_CMS ATT_CANC_MATCH_CMS

			INDEX_ADMIT_COUNT READMISSION_COUNT
			EM_ATT_VISIT_UTIL_CHK EM_OTH_VISIT_UTIL_CHK;

RUN ;

data emrg1_&bl._&ds.;
	format emerge_ep_id $100.;
	set outfinal.episode_emerge_&bl._&ds.;
	emerge_ep_id = TRANWRD(EP_ID,"-P-","-E-");
run;
proc sql;
	create table emrg2_&bl._&ds. as
	select b.emerge_ep_id, a.*
	from outfinal.CLAIMS_Emerge_&bl._&ds as a left join emrg1_&bl._&ds. as b
	on a.ep_id = b.ep_id;
quit;

data meos_emrg1_&bl._&ds. meos_emrg2_&bl._&ds.;
	set OUTFINAL.episode_meos_&bl._&ds.;
	if ep_id in ("",".") then output meos_emrg2_&bl._&ds.;
	else output meos_emrg1_&bl._&ds.;
run;
proc sql;
	create table emrg3_&bl._&ds. as
	select coalesce(b.emerge_ep_id,".") as emerge_ep_id, a.*
	from meos_emrg1_&bl._&ds. as a left join emrg1_&bl._&ds. as b
	on a.ep_id = b.ep_id;
quit;

data meos_emrg3_&bl._&ds. meos_emrg4_&bl._&ds.;
	set OUTFINAL.Claims_MEOS_&bl._&ds.;
	if ep_id in ("",".") then output meos_emrg4_&bl._&ds.;
	else output meos_emrg3_&bl._&ds.;
run;
proc sql;
	create table emrg4_&bl._&ds. as
	select coalesce(b.emerge_ep_id,".") as emerge_ep_id, a.*
	from meos_emrg3_&bl._&ds. as a left join emrg3_&bl._&ds. as b
	on a.ep_id = b.ep_id;
quit;
	
data outfinal.episode_emerge_&bl._&ds.;
	format ep_id $100.;
	set emrg1_&bl._&ds. (drop=ep_id);
	EP_ID = emerge_ep_id;
	drop emerge_ep_id;
run;
data outfinal.CLAIMS_Emerge_&bl._&ds.;
	format ep_id $100.;
	set emrg2_&bl._&ds. (drop=ep_id);
	EP_ID = emerge_ep_id;
	drop emerge_ep_id;
run;
data outfinal.episode_meos_&bl._&ds.;
	format ep_id $100.;
	set emrg3_&bl._&ds. (in=a rename=(ep_id=orig_ep_id))
		meos_emrg2_&bl._&ds. (in=b) ;
	if a then do;
		ep_id = emerge_ep_id;
		if ep_id = '.' then ep_id = orig_ep_id;
	end;
	drop orig_ep_id emerge_ep_id;
run;
data outfinal.Claims_MEOS_&bl._&ds.;
	format ep_id $100.;
	set emrg4_&bl._&ds. (in=a rename=(ep_id=orig_ep_id))
		meos_emrg4_&bl._&ds. (in=b) ;
	if a then do;
		ep_id = emerge_ep_id;
		if ep_id = '.' then ep_id = orig_ep_id;
	end;
	drop orig_ep_id emerge_ep_id;
run;

%MEND sc ; 

************************************************************************************************************* ;
************************ ATTRIBUTION FILE ******************************************************************* ;
************************************************************************************************************* ;
%macro att(DS,OCM)  ;
DATA ATT ;
	SET &ATT. ;
PROC SQL ;
	CREATE TABLE ATT2_PRE AS
	SELECT a.ep_id as ep_id_CMS, A.BENE_HICN, A.MBI as BENE_MBI, A.FIRST_NAME, A.LAST_NAME, a.EP_BEG_A, a.EP_END_A, RECON_ELIG_A, EM_VISIT_FOR_CANC,MOST_RECENT_EM, 
			CANCER_TYPE_A, B.ATTRIBUTE_FLAG, DOD, OCM_ID,EPI_NPI_ID, B.epi_tax_id, B.EPI_ATT_TIN,
		   b.EP_BEG, b.EP_END, b.MEOS_COUNT, b.MEOS_COUNT_OTH, b.MEOS_ALLOWED, b.MEOS_ALLOWED_OTH, b.EP_ID, 
			b.CANCER_TYPE_MILLIMAN, b.perform_not_match , b.bene_id, b.BENE_HICN as BENE_HICN_FIX
	FROM ATT AS A LEFT JOIN outfinal.episode_Interface_&bl._&ds. AS B
	ON /*A.BENE_HICN=B.BENE_HICN AND */A.ep_id=B.EP_id_cms ;

data ATT2 (drop=BENE_HICN_FIX);
	SET ATT2_PRE ;
	IF BENE_HICN = '' THEN BENE_HICN = BENE_HICN_FIX ;
RUN;

PROC SQL ;
	CREATE TABLE ATT2A AS
	SELECT A.*, B.IN_RECON, B.ATT_CANC_MATCH_CMS, B.RECON_PP, B.ATT_EPI_PERD_MATCH_CMS
	FROM ATT2 AS A LEFT JOIN OUT.REC_TU_FLAGS_&DS. AS B
	ON /*A.BENE_HICN = B.BENE_HICN AND*/ A.EP_ID_CMS=B.EP_ID ;
	QUIT ;

DATA ATT3 ;
	SET ATT2A ;

	FORMAT PATIENT_NAME $50. ;   LENGTH PATIENT_NAME $50. ;
	IF LAST_NAME NE "  " THEN PATIENT_NAME = PROPCASE(COMPRESS(LAST_NAME,' '))||', '||PROPCASE(COMPRESS(FIRST_NAME,' ')) ;	
	ELSE PATIENT_NAME = "UNKNOWN" ;

	%cancer_remap(cancer_type_a) ;
	LENGTH IN_PERFORMANCE_DATA EPI_START_DATE_MATCH PERFORMANCE_PER_MATCH CANCER_MATCH TIN_MATCH $5. ;
	FORMAT IN_PERFORMANCE_DATA EPI_START_DATE_MATCH PERFORMANCE_PER_MATCH CANCER_MATCH TIN_MATCH $5. ;

	if recon_pp = 4 then do ;
		in_recon = . ; ATT_CANC_MATCH_CMS = . ; ATT_EPI_PERD_MATCH_CMS = . ;
	end ;

	IF ATTRIBUTE_FLAG IN ('1','2','3','5') THEN IN_PERFORMANCE_DATA = "YES" ; 
	ELSE IN_PERFORMANCE_DATA = "NO" ;
	
	IF IN_PERFORMANCE_DATA = "YES" THEN DO ;

		IF ATTRIBUTE_FLAG IN ('1','3') THEN EPI_START_DATE_MATCH = "YES" ;
		ELSE EPI_START_DATE_MATCH = "NO" ;

		IF PERFORM_NOT_MATCH = 1 THEN PERFORMANCE_PER_MATCH = "NO" ;
		ELSE PERFORMANCE_PER_MATCH = "YES" ;

		IF ATTRIBUTE_FLAG IN ('3','5') THEN CANCER_MATCH = "NO" ;
		ELSE CANCER_MATCH = "YES" ; 

		IF epi_tax_id = EPI_ATT_TIN THEN TIN_MATCH = "YES" ;
		else TIN_MATCH = "NO" ;
	
	END ;

	IF IN_PERFORMANCE_DATA = "NO" THEN DO ;		
		epb = ((year(ep_beg_a)-2000)*10000)+(month(ep_beg_a)*100)+day(ep_beg_a) ;
		EP_ID = CATS(EP_ID_CMS,"-",epb,"-P-","&OCM.")  ;
		CANCER_TYPE_MILLIMAN = CANCER_TYPE_A ;
		EP_BEG = EP_BEG_A ;
		EP_END = EP_END_A ;
		OCM_ID = "&OCM." ;
		TIN_MATCH = "UNK" ;
		EPI_START_DATE_MATCH = "UNK" ;
		PERFORMANCE_PER_MATCH = "UNK" ;
		CANCER_MATCH = "UNK" ;
	END ;

	%EPISODE_PERIOD ;

	MEOS_COUNT = MAX(0,MEOS_COUNT) ;
	MEOS_COUNT_OTH = MAX(0, MEOS_COUNT_OTH) ;
	EM_VISIT_FOR_CANC = MAX(0,EM_VISIT_FOR_CANC) ;
RUN;
data outfinal.attrib_Interface_&bl._&ds ;
	RETAIN OCM_ID BENE_HICN BENE_MBI EP_ID EP_ID_cms CANCER_TYPE_MILLIMAN RECON_ELIG_A EP_BEG EP_END EP_END_A DOD 
		   IN_PERFORMANCE_DATA EPI_NPI_ID EPI_START_DATE_MATCH PERFORMANCE_PER_MATCH CANCER_MATCH
		   EM_VISIT_FOR_CANC MEOS_COUNT MEOS_COUNT_OTH MEOS_ALLOWED MEOS_ALLOWED_OTH TIN_MATCH
		   EPISODE_PERIOD IN_RECON ATT_CANC_MATCH_CMS ATT_EPI_PERD_MATCH_CMS PATIENT_NAME ;
	SET ATT3 ;
	KEEP OCM_ID BENE_HICN BENE_MBI EP_ID EP_ID_cms CANCER_TYPE_MILLIMAN RECON_ELIG_A EP_BEG EP_END EP_END_A DOD 
		   IN_PERFORMANCE_DATA EPI_NPI_ID EPI_START_DATE_MATCH PERFORMANCE_PER_MATCH CANCER_MATCH
		   EM_VISIT_FOR_CANC MEOS_COUNT MEOS_COUNT_OTH MEOS_ALLOWED MEOS_ALLOWED_OTH 	TIN_MATCH
		   EPISODE_PERIOD IN_RECON ATT_CANC_MATCH_CMS ATT_EPI_PERD_MATCH_CMS PATIENT_NAME ;
RUN;

%mend att ;

**************************************************************************** ;
**************************************************************************** ;
***** %macro sc(ds,id)  
		ID: 3 digit OCM id
*** !!! Only run ATT macro when attribution (but not recon file) is provided for a performance period. *** ;
**************************************************************************** ;
**************************************************************************** ;

%LET ATT = att.ATT_PP&pp1.&version1._255_50179 att2.ATT_PP&pp2.&version2._255_50179 
			att3.ATT_PP&pp3.&version3._255_50179 att4.ATT_PP&pp4.&version4._255_50179 ;
%let att_tin = '454999975' ; run ;
%SC(255_50179,255) ; run ;
%att(255_50179,255) ;run ; 

%LET ATT = att.ATT_PP&pp1.&version1._257_50195 att2.ATT_PP&pp2.&version2._257_50195 
			att3.ATT_PP&pp3.&version3._257_50195 att4.ATT_PP&pp4.&version4._257_50195 ;
%let att_tin = '636000526' ;run ;
%SC(257_50195,257) ; run ;
%att(257_50195,257) ; run ;

%LET ATT = att.ATT_PP&pp1.&version1._278_50193 att2.ATT_PP&pp2.&version2._278_50193 
			att3.ATT_PP&pp3.&version3._278_50193 att4.ATT_PP&pp4.&version4._278_50193 ;
%let att_tin = '134290167' ;run ;
%SC(278_50193,278) ; run ;
%att(278_50193,278) ; run ;

%LET ATT = att.ATT_PP&pp1.&version1._280_50115 att2.ATT_PP&pp2.&version2._280_50115 
			att3.ATT_PP&pp3.&version3._280_50115 att4.ATT_PP&pp4.&version4._280_50115 ;
%let att_tin = '731310891' ;run ;
%SC(280_50115,280) ; run ; 
%att(280_50115,280) ; run ; 

%LET ATT = att.ATT_PP&pp1.&version1._290_50202 att.ATT_PP&pp1.&version1._567_50200 att.ATT_PP&pp1.&version1._568_50201
		   att2.ATT_PP&pp2.&version2._290_50202 att3.ATT_PP&pp3.&version3._290_50202 att4.ATT_PP&pp4.&version4._290_50202 ;
%let att_tin = '540647482','540793767','541744931','311716973' ;run ;
%SC(290_50202,290) ; run ;
%att(290_50202,290) ; run ;

%LET ATT = att.ATT_PP&pp1.&version1._396_50258 att2.ATT_PP&pp2.&version2._396_50258 
			att3.ATT_PP&pp3.&version3._396_50258 att4.ATT_PP&pp4.&version4._396_50258 ;
%let att_tin = '571004971' ;run ;
%SC(396_50258,396) ; run ;
%att(396_50258,396) ; run ;

%LET ATT = att.ATT_PP&pp1.&version1._401_50228 att2.ATT_PP&pp2.&version2._401_50228 
			att3.ATT_PP&pp3.&version3._401_50228 att4.ATT_PP&pp4.&version4._401_50228 ;
%let att_tin = '205485346' ;run ;
%SC(401_50228,401) ; run ;
%att(401_50228,401) ; run ; 

%LET ATT = att.ATT_PP&pp1.&version1._459_50243 att2.ATT_PP&pp2.&version2._459_50243 
			att3.ATT_PP&pp3.&version3._459_50243 att4.ATT_PP&pp4.&version4._459_50243 ;
%let att_tin = '204881619' ;run ;
%SC(459_50243,459) ; run ;
%att(459_50243,459) ; run ;

%LET ATT = att.ATT_PP&pp1.&version1._468_50227 att2.ATT_PP&pp2.&version2._468_50227 
			att3.ATT_PP&pp3.&version3._468_50227 att4.ATT_PP&pp4.&version4._468_50227 ;
%let att_tin = '621490616' ;run ;
%SC(468_50227,468) ; run ;  
%att(468_50227,468) ; run ; 

%LET ATT = att.ATT_PP&pp1.&version1._480_50185 att2.ATT_PP&pp2.&version2._480_50185 
			att3.ATT_PP&pp3.&version3._480_50185 att4.ATT_PP&pp4.&version4._480_50185 ;
%let att_tin = '201872200' ;run ;
%SC(480_50185,480) ; run ;
%att(480_50185,480) ; run ;

%LET ATT = att.ATT_PP&pp1.&version1._523_50330 att2.ATT_PP&pp2.&version2._523_50330 
			att3.ATT_PP&pp3.&version3._523_50330 att4.ATT_PP&pp4.&version4._523_50330 ;
%let att_tin = '596014973' ;run ;
%SC(523_50330,523) ; run ;
%att(523_50330,523) ; run ;

%LET ATT = att.ATT_PP&pp1.&version1._137_50136 att2.ATT_PP&pp2.&version2._137_50136 
			att3.ATT_PP&pp3.&version3._137_50136 att4.ATT_PP&pp4.&version4._137_50136 ; 
%let att_tin = '223141761' ;run ;
%SC(137_50136,137) ; run ; 
%att(137_50136,137) ;run ;

%MACRO CHECK_PP(ds,id)  ;

proc freq data=outfinal.claims_interface_&bl._&ds. ;
	tables label2*label3*er_weekend/list missing ;
	tables start_date*er_weekend /list missing ;
	format start_date year4. ;
title "OCM &ID: Service categories" ; run ;

proc freq data=outfinal.episode_Interface_&bl._&ds ;
	tables ep_length dual;
title "OCM &ID. - EP_LENGTH should be > 0; DUAL should have values 0 and 1" ;
run ;

DATA CHECK ;
	SET outfinal.claims_interface_&bl._&ds. ;
	IF LABEL2 IN ("Emergency: Non-Chemo Sensitive","Emergency: Chemo Sensitive") AND ER_WEEKEND = . ; 
RUN ;

%MEND ;
/*
%check_pp(137_50136,137) ; run ; ** OCM added as of P1-Q3 B Oct2 Interface - has complete data *** ;
%CHECK_PP(255_50179,255) ; run ;
%CHECK_PP(257_50195,257) ; run ;
%CHECK_PP(278_50193,278) ; run ;
%CHECK_PP(280_50115,280) ; run ; ** OCM added as of P1-Q3 B Interface - has complete data *** ;
%CHECK_PP(290_50202,290) ; run ;
%CHECK_PP(396_50258,396) ; run ;
%check_pp(401_50228,401) ; run ; ** OCM added as of P1-Q3 B Interface - has complete data *** ;
%check_pp(459_50243,459) ; run ; ** OCM added as of P1-Q4 B Interface - MISSING Q1,Q2 BENE FILES *** ;
%check_pp(468_50227,468) ; run ; ** OCM added as of P1-Q3 B Oct Interface - has complete data  *** ;
%CHECK_PP(480_50185,480) ; run ;
%CHECK_PP(523_50330,523) ; run ;
*/

/*
data ipr_has ;
	set ipr_final ;
	if has_readmission = 1 ; 

data ipr2_has ;
	set ip_combine ;
	if has_readmission = 1 ; 

data ip_hs ;
	set  OUTFINAL.SC_IP_P4A_401_50228 ;
	if has_readmission = 1 ; 

proc sort data=ipr_has out=h1 nodupkey ; by bene_id ep_id ip_case ;
proc sort data=ipr2_has out=h2 nodupkey ; by bene_id ep_id ip_case ;
proc sort data=ip_hs out=h3 nodupkey ; by bene_id ep_id ip_case ;
proc sort data=ipr_has ; by bene_id ep_id ip_case ;
proc sort data=ipr2_has ; by bene_id ep_id ip_case ;
proc sort data=ip_hs ; by bene_id ep_id ip_case ;

data in1 in2 in3 inall other ;
	merge h1(in=a) h2(in=b) h3(in=c) ; by bene_id ep_id ip_case ;
	if a and b=0 and c=0 then output in1 ;
	else if a=0 and b and c=0 then output in2 ;
	else if a=0 and b=0 and c then output in3 ;
	else if a and b and c=0 then output other ;
	else if a and b and c then output inall ;
*/
run ;

