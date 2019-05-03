********************************************************************** ;
		***** 003_Service_Categories.sas ***** ;
********************************************************************** ;


libname r1 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Baseline\V3" ; *** locale of SAS reads. Folder will change with baseline version update.*** ;
libname r2 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Baseline\V3" ;

options ls=132 ps=70 obs=MAX  nomprint mlogic; 

run ;

********************************************************************** ;
********************************************************************** ;
*** Initiating therapy lists *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats Baseline.sas" ;
*** Cancer diagnosis code lists *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Cancer Formats PP3.sas" ;
*** Cancer assignment macro  *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Cancer Diagnoses_5.sas" ;
*** Predictive Model Variable Development  *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Predict_Flags PP3.sas" ;
RUN ;
*** Service Categories *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Service_Categories_v2.sas" ;
*** For Inpatient allowed calculation *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000 - CMMI - Formats - Hemophilia Clotting Factors.sas" ; 
run ;
*** For chemo-sensitive override *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Breast_Hormonal.sas" ; run ;
*** For inpatient readmissions *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\IP_READMISSIONS_v2.sas" ; run ;
********************************************************************** ;
********************************************************************** ;

%let bl = blv3 ; *** baseline version, in preparation for multiple versions of these data files *** ; 
run ;

%MACRO EPISODE_PERIOD ;
	***** Assigning episode to time period. ***** ;
	EPISODE_PERIOD = "BASELINE" ;
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


%macro sc(ds,id) ; 
*** For End of Life Metrics *** ;
proc sort data=r2.epi_prelim_&bl._&ds. OUT=EPI_DOD (KEEP = EP_ID BENE_ID DOD EP_BEG EP_END cancer_type_milliman) ; BY EP_ID BENE_ID ;
**************************************************************************************
*************************** IP COST MODEL LOGIC ***************************************
***************************************************************************************;

PROC SORT DATA=R2.check_ipop_&bl._&ds. OUT=IPOP ; BY EP_ID BENE_ID CLM_ID ;
PROC MEANS DATA=IPOP NOPRINT MAX ; BY EP_ID BENE_ID CLM_ID ;
	VAR /*BMT_ALLOGENEIC_AK BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL 
		BMT_AUTOLOGOUS_AK BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL */
		BMT_ALLOGENEIC BMT_AUTOLOGOUS
		ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY 
		LIVER_SURGERY LUNG_SURGERY OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY  KIDNEY_SURGERY 
		DXANAL_SURGERY DXBLADDER_SURGERY DXBREAST_SURGERY DXFEMALEGU_SURGERY DXGASTRO_SURGERY DXHEADNECK_SURGERY 
		DXINTESTINAL_SURGERY 
		DXLIVER_SURGERY DXLUNG_SURGERY DXOVARIAN_SURGERY DXPANCREATIC_SURGERY DXPROSTATE_SURGERY  DXKIDNEY_SURGERY 
;
	OUTPUT OUT=IPOP_FLAGS (DROP = _TYPE_ _FREQ_)
		   MAX() = ;


%macro IP ;

DATA ICU ;
	SET r2.inpatient_&bl._&ds. ;
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

PROC SORT DATA=ICU ; BY EP_ID BENE_ID CLM_ID ;
PROC MEANS DATA=ICU NOPRINT MAX ; BY EP_ID BENE_ID CLM_ID ;
	VAR ICU IP_ER IP_OBS  ;
	OUTPUT OUT=ICU_FLAGS (DROP = _TYPE_ _FREQ_)
		   MAX() = ;

data iphdr_clean ;
	MERGE ICU(IN=A DROP=ICU) ICU_FLAGS(IN=B) ; by EP_ID bene_id clm_id ;
	IF A AND B ;
	if first.clm_id THEN OUTPUT ;

** Pull IME and DSH and NewTech Operating amounts for each IP claim **;
data ip2;
	set R1.inpval_&ds.;
	if VAL_CD = '18' then oper_dsh_amt = VAL_AMT;
	else if VAL_CD = '19' then oper_ime_amt = VAL_AMT;
	else if VAL_CD = '77' then tech_addon = VAL_AMT ;
run;

proc summary data=ip2 nway missing;
	class ep_id BENE_ID CLM_ID ;
	var oper_dsh_amt oper_ime_amt tech_addon;
	output out = ip2_sum (drop=_type_ _freq_) sum=;
run;

** hemophilia clotting factors **;
data ip_hemo ;
	set r2.inpatient_&bl._&ds.;
	if REV_CNTR = 636 and put(hcpcs_cd,$Hemo_JCodes.)='X';
run;

data ip_hemo3 (keep=ep_id bene_id clm_id );
	set ip_hemo;
	by bene_id clm_id  ;
		ARRAY v (I) ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD25 ;
		ARRAY d (I) ICD_DGNS_CD1-ICD_DGNS_CD25 ;
		DO I = 1 TO 25 ;
			if v = "9" and put(d,$Hemo_DiagCodes.) = "X" then hemo_diag = 1 ;
		END ;
proc sort data=ip_hemo3 nodupkey ; by ep_id bene_id clm_id ;
	
data ip_hemo4;
	merge ip_hemo3 (in=a) ip_hemo (in=b);
	by ep_id bene_id clm_id  ;
	if a and b then output;

run;

proc means data=ip_hemo4 noprint sum ; by ep_id bene_id clm_id ;
	var REV_RATE ;
	outpUT out=ip_hemo5(drop = _type_ _Freq_)
		   sum() = ;

DATA IP1A ;
	MERGE iphdr_clean(IN=A ) 
		  EPI_DOD(IN=B) ; BY EP_ID BENE_ID ;
	IF A AND B ;
	


data SC_ip_&bl._&ds. ;
	MERGE IP1A(IN=A WHERE = (NOPAY_CD = "  "))
		  IP2_SUM(IN=B)
		  ip_hemo5(IN=C) 
		  IPOP_FLAGS ;
	BY EP_ID BENE_ID CLM_ID ;
	if a ;

	if missing(oper_dsh_amt) then oper_dsh_amt = 0;
	if missing(oper_ime_amt) then oper_ime_amt = 0;
	if missing(tech_addon) then tech_addon = 0;
	if missing(HemoFactorAmount) then HemoFactorAmount = 0;
	if missing(DED_AMT) then DED_AMT = 0;
	if missing(COIN_AMT) then COIN_AMT = 0;
	if missing(BLDDEDAM) then BLDDEDAM = 0;

	allowed = sum(PMT_AMT,(PER_DIEM*UTIL_DAY)) ; 
	IF CLM_STD_PYMT_AMT = . THEN CLM_STD_PYMT_AMT = ALLOWED ;
	**** Initializing Service Category **** ;
	FORMAT Service_CAT $50.; length Service_CAT $50. ; 
	Service_CAT = "    " ;

		%canc_init ; /*chemosens1 = 0 ; chemosens2 = 0 ;*/

		ARRAY v (I) ICD_DGNS_VRSN_CD1 ;
		ARRAY d (I) ICD_DGNS_CD1 ;
		DO I = 1 TO 1 ;
			%CANCERTYPE(v, d) ;
			*if v = "9" and put(d,$Chemo_Sens_ICD9_.) = "Y" then chemosens1 = 1 ;
		END ;
		%JAN2017 ;
		has_cancer_primary = has_cancer ;

		%canc_init ; has_cancer = 0 ;

		ARRAY v2 (l) ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD25 ;
		ARRAY d2 (l) ICD_DGNS_CD1-ICD_DGNS_CD25 ;
		DO l = 1 TO dim(d2) ;
			*if v2 = "9" and put(d2,$Chemo_Sens_ICD9_.) = "Y" then chemosens2 = 1 ;
			%CANCERTYPE(v2, d2) ;
		END ;
		%JAN2017 ;

		DROP I L;
	
	*** Identification of Short Term Acute and CAH stays for readmissions *** ;
	if '0001' le substr(provider,3,4) le '0879' or
	   '1300' le substr(provider,3,4) le '1399' then readm_cand = 1 ;
	else readm_cand = 0 ;

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
				*if chemosens1 = 1 then SERVICE_CAT = "Inpatient Medical: Chemo Sensitive" ;
				*else if chemosens2 = 1 and has_cancer_primary = 1 then SERVICE_CAT = "Inpatient Medical: Chemo Sensitive" ;
				/*else*/ if put(drg_cd,$Chemo_Sens_DRG_new.) = "Y" then SERVICE_CAT = "Inpatient Medical: Potentially Chemo Related" ;
				else SERVICE_CAT = "Inpatient Medical: Other" ;
	end ;

					*** End of Life variables *** ;
		IP_CAH = 0 ; IP_CHEMO_ADMIN = 0 ; 
		IF ('0001' LE SUBSTR(PROVIDER,3,4) LE '0879') OR 
		   ('1300' LE SUBSTR(PROVIDER,3,4) LE '1399') THEN IP_CAH = 1 ;

		IF PRNCPAL_DGNS_CD IN ('V5811', 'V5812', 'Z5111', 'Z5112') THEN IP_CHEMO_ADMIN = 1 ; *** Source: OCM ticket 787031 - with file attached OCM-1+Measure+Specifications *** ;

		if CANCER_TYPE_MILLIMAN = "Acute Leukemia" then IP_BMT_AK = MAX(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;
	    if CANCER_TYPE_MILLIMAN = "Lymphoma" THEN IP_BMT_L = MAX( BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;
		if CANCER_TYPE_MILLIMAN = "Multiple Myeloma" THEN IP_BMT_MM = MAX(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;
	    if CANCER_TYPE_MILLIMAN = "MDS" THEN IP_BMT_MDS = MAX(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;
	    IF CANCER_TYPE_MILLIMAN = "Chronic Leukemia" THEN IP_BMT_CL = MAX(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;

	if CANCER_TYPE_MILLIMAN ne "Liver Cancer" and dxLiver_surgery = 0 then LIVER_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Breast Cancer" and dxBreast_surgery = 0 then BREAST_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Anal Cancer" and dxAnal_surgery = 0 then ANAL_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Kidney Cancer" and dxKidney_surgery = 0 then KIDNEY_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Lung Cancer" and dxLung_surgery = 0 then LUNG_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Bladder Cancer" and dxBladder_surgery = 0 then BLADDER_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Female GU Cancer other than Ovary" and dxFemalegu_surgery = 0 then FEMALEGU_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Gastro/Esophageal Cancer" and dxGastro_surgery = 0 then GASTRO_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Head and Neck Cancer" and dxHeadNeck_surgery = 0 then HEADNECK_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Small Intestine / Colorectal Cancer" and dxIntestinal_surgery = 0 then INTESTINAL_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Ovarian Cancer" and dxOvarian_surgery = 0 then OVARIAN_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Prostate Cancer" and dxProstate_surgery = 0 then PROSTATE_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Pancreatic Cancer" and dxPancreatic_surgery = 0 then PANCREATIC_SURGERY = 0 ;

		SIP_ANAL = ANAL_SURGERY ;
		SIP_BLADDER = BLADDER_SURGERY ;
		SIP_BREAST = BREAST_SURGERY ;
		SIP_FEMALEGU = FEMALEGU_SURGERY ;
		SIP_GASTRO = GASTRO_SURGERY ;
		SIP_HN = HEADNECK_SURGERY ;
		SIP_INT = INTESTINAL_SURGERY ;
		SIP_KIDNEY = KIDNEY_SURGERY ;
		SIP_LIVER = LIVER_SURGERY ;
		SIP_LUNG = LUNG_SURGERY ;
		SIP_OVARIAN = OVARIAN_SURGERY ;
		SIP_PROSTATE = PROSTATE_SURGERY ;
		SIP_PANCREATIC = PANCREATIC_SURGERY ;
		***************************************************** ;
		FORMAT WIN_30_DOD MMDDYY10. ;
		WIN_30_DOD = INTNX('DAY',DOD,-29,'SAME') ;
		IF IP_CAH = 1 THEN DO ;
			IF (WIN_30_DOD LE DSCHRGDT LE DOD) THEN IP_ALLCAUSE_30 = 1 ; 
		END;
		IF ICU = 1 THEN DO ;
			IF (WIN_30_DOD LE DSCHRGDT LE DOD) THEN IP_ICU_30 = 1 ; 
		END ;
		IF DOD NE . AND IP_ALLCAUSE_30 NE 1 THEN IP_ALLCAUSE_30 = 0 ;
		IF DOD NE . AND IP_ICU_30 NE 1 THEN IP_ICU_30 = 0 ;
		******************************************************* ;

		*** Premier Request: Death in Hospital *** ;
		if IP_CAH = 1 AND ((ADMSN_DT LE DOD LE DSCHRGDT) OR STUS_CD = "20") then died_in_hosp = 1 ;

		******************************************************* ;
		DROP HAS_CANCER %canc_flags BMT_ALLOGENEIC BMT_AUTOLOGOUS
			 /*BMT_ALLOGENEIC_AK BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL 
			 BMT_AUTOLOGOUS_AK BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL */
			 ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
			 OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY DOD
		     DXANAL_SURGERY DXBLADDER_SURGERY DXBREAST_SURGERY DXFEMALEGU_SURGERY DXGASTRO_SURGERY DXHEADNECK_SURGERY 
		     DXINTESTINAL_SURGERY 
		     DXLIVER_SURGERY DXLUNG_SURGERY DXOVARIAN_SURGERY DXPANCREATIC_SURGERY DXPROSTATE_SURGERY  DXKIDNEY_SURGERY 
;

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
		IP_CASE = 1001 ;
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
	var ip_cah ip_chemo_admin 
		IP_ALLCAUSE_30 IP_ICU_30
		IP_BMT_AK IP_BMT_L IP_BMT_MM IP_BMT_MDS IP_BMT_CL 
		SIP_ANAL SIP_BLADDER SIP_BREAST SIP_FEMALEGU 
		SIP_GASTRO SIP_HN SIP_INT SIP_LIVER SIP_LUNG SIP_OVARIAN SIP_PROSTATE SIP_PANCREATIC SIP_KIDNEY
		IP_ER readm_cand;
	output out=case_level (drop = _type_ _freq_)
		   max() =  ip_cah_case ip_chemo_admin_case 
					IP_ALLCAUSE_30_CASE IP_ICU_30_CASE
					IP_BMT_AK_case IP_BMT_L_case IP_BMT_MM_case IP_BMT_MDS_case IP_BMT_CL_CASE
					SIP_ANAL_case SIP_BLADDER_case SIP_BREAST_case SIP_FEMALEGU_case 
					SIP_GASTRO_case SIP_HN_case SIP_INT_case SIP_LIVER_case SIP_LUNG_case SIP_OVARIAN_case
					SIP_PROSTATE_case SIP_PANCREATIC_case SIP_KIDNEY_CASE IP_ER_CASE readm_cand_case;


DATA INPATIENT  ;
	merge ALL(in=a) 
           case_level(in=b) ; 
		   BY BENE_ID EP_ID IP_CASE ;

PROC SORT DATA=INPATIENT ; BY BENE_ID EP_ID CLM_ID ;

DATA INPATIENT ; 
	SET INPATIENT ; BY BENE_ID EP_ID CLM_ID ;
	IF FIRST.CLM_ID THEN IP_LOS = UTIL_DAY ;
 

*** Step I5: Identify Index and Readmissions. *** ;
*** IPR MACRO outputs file IPR_FINAL - which will contain index and readmit flags to merge back onto final file. *** ;
*** First macro variable is input file from previous date step.
	Second macro variable is time period of analysis - bl for baseline, pp for performance period. *** ;
%IPR(INPATIENT,bl);

proc freq data=ipr_final ;
	tables has_readmission UNPLANNED_READMIT_FLAG ; 
TITLE "OUTPUT OF INPATIENT READMISSIONS LOGIC - NUMBER W READMISSIONS SHOULD MATCH NUMBER FLAGGED AS READMISSIONS" ; run ;

*** Step I6: Create final file. *** ;
PROC SORT DATA=INPATIENT ; BY BENE_ID EP_ID IP_CASE ADMSN_DT DSCHRGDT;
DATA ip_combine ; 
	MERGE INPATIENT(IN=A) IPR_FINAL(IN=B) ; BY BENE_ID EP_ID IP_CASE ;
	IF A ;
	IF B=0 THEN DO ;
		INDEX_ADMIT = 0 ;
		UNPLANNED_READMIT_FLAG = 0 ;
		HAS_READMISSION = 0 ;
	END ;

DATA R2.SC_ip_&bl._&ds. ; 
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

%mend IP ;

**************************************************************************************
*************************** OP COST MODEL LOGIC ***************************************
***************************************************************************************;
%MACRO OP ;
**** Identify ER claims **** ;
data er clms ;
	set R2.OUTPATIENT_&bl._&ds.(WHERE = (NOPAY_CD = "  ")) ;
	if 	REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 ; 

	ALLOWED = REVPMT ;
	IF CLM_REV_STD_PYMT_AMT = .  THEN CLM_REV_STD_PYMT_AMT  = ALLOWED ;
	**** Initializing Service Category **** ;
	FORMAT SERVICE_CAT $50.; length SERVICE_CAT $50. ; 
	SERVICE_CAT = "    " ;
	*** 5/10/17 - remove lines where rev_cntr = 0001 *** ;
	if rev_cntr = "0001" then delete ;

			OP_CAH = 0 ; 
		IF ('0001' LE SUBSTR(PROVIDER,3,4) LE '0879') OR 
		   ('1300' LE SUBSTR(PROVIDER,3,4) LE '1399') THEN OP_CAH = 1 ;


		%canc_init ; 
		ARRAY v (I) ICD_DGNS_VRSN_CD1 ;
		ARRAY d (I) ICD_DGNS_CD1 ;
		DO I = 1 TO 1 ;
			%CANCERTYPE(v, d) ;
			
		END ;
		has_cancer_primary = has_cancer ;
/*
		%canc_init ; has_cancer = 0 ;

		ARRAY v2 (l) ICD_DGNS_VRSN_CD2-ICD_DGNS_VRSN_CD25 ;
		ARRAY d2 (l) ICD_DGNS_CD2-ICD_DGNS_CD25 ;
		DO l = 1 TO dim(d2) ;
			if v2 = "9" and put(d2,$Chemo_Sens_ICD9_.) = "Y" then chemosens2 = 1 ;
		END ;
		DROP L ;
*/
		DROP I ;
		DROP HAS_CANCER %canc_flags ;
		
		er_pre=0 ; OBS_PRE=0 ; UC_PRE=0 ; ER_CHEM_PRE = 0 ; OBS_CHEM_PRE = 0 ; UC_CHEM_PRE = 0 ;
		if put(rev_cntr,$ER_REV.) = 'Y' then ER_pre = 1;
		if put(HCPCS_CD,$ER_CPT.) = 'Y' then ER_pre = 1;
		if put(hcpcs_cd,$OBS_CPT.) = 'Y' then OBS_pre = 1 ;
		if put(hcpcs_cd,$UC.) = 'Y' then UC_pre = 1 ;
		if put(rev_cntr,$UC_REV.) = 'Y' then UC_Pre = 1 ;
/*
		if ER_pre = 1 then do ;
			if chemosens1 = 1 or (has_cancer_primary and chemosens2 =1) then ER_Chem_pre = 1;
		end ;
		if OBS_pre = 1 then do ;
			if chemosens1 = 1 or (has_cancer_primary and chemosens2 =1) then OBS_Chem_pre = 1;
		end ;
		if UC_pre = 1 then do ;
			if chemosens1 = 1 or (has_cancer_primary and chemosens2 =1) then UC_Chem_pre = 1;
		end ;
	*/
	if (er_Pre = 1 or obs_pre = 1 or uc_pre = 1) /*and allowed > 0*/ then output er;
	output clms ;

run ;

proc sort data=er ; by ep_id bene_id clm_id thru_dt rev_dt;
proc means data=er noprint max ; by ep_id bene_id clm_id thru_dt  rev_dt;
	var er_pre obs_pre uc_pre /*er_chem_pre uc_chem_pre obs_chem_pre*/ ;
	output out=erclms (drop = _type_ _freq_)
		   max() = ;
run ;


proc sort data=clms ; by ep_id bene_id clm_id thru_dt rev_dt; 

data OP1 ;
	merge clms(in=a drop=er_pre obs_pre uc_pre /*er_chem_pre obs_chem_pre uc_chem_pre*/)	
		  erclms(in=b keep=ep_id bene_id clm_id thru_dt rev_dt er_pre obs_pre uc_pre 
						   /*er_chem_pre obs_chem_pre uc_chem_pre*/ ) ; 
	by ep_id bene_id clm_id thru_dt rev_dt;
	if a ;

	IF A AND B THEN ER_CLAIM = 1 ;  *** flags all lines that occur on same revenue date as ED visit *** ;
	ELSE ER_CLAIM = 0 ;
run;

proc sort data=r1.outhdr_&ds. OUT=op_h ; by  EP_ID BENE_ID CLM_ID ; run ;
proc sort data=r1.outval_&ds. (where=(val_cd='17')) OUT=op_v ; by  EP_ID BENE_ID CLM_ID ; run ;

data OP_val;
		merge op_h(in=a) op_v(in=b) ; 
		by  EP_ID BENE_ID CLM_ID ; 
		if a and b ;
run;
proc sql ;
    create table OP_val2 as
    select b.*, a.*
    from epi_dod as a, OP_val as b
    where a.EP_id=b.EP_id and
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

data r2.SC_op_&bl._&ds. ;
	format rev_cntr $20. ;
	set OP1	
		OP3 ; 

	***  5/4/17: Chemotherapy, Drug and Rad Once Assignments Overrides any other Non-IP assignment. *** ;
	BLAD_LR = 0 ; PROST_CAST = 0 ; BLAD_OTH = 0 ; PROST_OTH = 0 ;
	IF PUT(HCPCS_CD,$Bladder_LR_HCPCS.) = "Y" THEN BLAD_LR = 1 ;
	IF PUT(HCPCS_CD,$Prostate_CS_HCPCS.) = "Y" THEN PROST_CAST = 1 ;
	if put(hcpcs_cd,$Chemo_J.) = 'Y' then DO ;
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


	else if ER_CLAIM = 1 then do ;
		/*
		if obs_chem_pre = 1 then SERVICE_CAT = "Emergency: Chemo Sensitive" ;
		else if obs_pre = 1 then SERVICE_CAT = "Emergency: Non-Chemo Sensitive" ;
		else if er_chem_pre = 1 then SERVICE_CAT = "Emergency: Chemo Sensitive";
		else if er_pre = 1 then SERVICE_CAT = "Emergency: Non-Chemo Sensitive" ;
		else if uc_chem_pre = 1 then SERVICE_CAT = "Emergency: Chemo Sensitive";
		else SERVICE_CAT = "Emergency: Non-Chemo Sensitive" ;
		*/
		if max(obs_pre, er_pre, uc_pre) = 1 then Service_CAT = "Emergency Department" ;
	end ;


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

DATA HEAD ;
	SET R1.PHYHDR_&DS.(KEEP = BENE_ID EP_ID CLM_ID FROM_DT)
		R1.DMEHDR_&DS. (KEEP = BENE_ID EP_ID CLM_ID FROM_DT) ;
PROC SORT DATA=HEAD NODUPKEY ; BY BENE_ID EP_ID CLM_ID ;

DATA LINES ;
	set r1.phyline_&ds.(in=p) 
		r1.dmeline_&ds.(in=d);
	if p then prof = 1 ; 
	if d then dme = 1 ;
PROC SORT DATA=LINES ; BY BENE_ID EP_ID CLM_ID ;


**** Identify ER claims **** ;
data er clms ;
	MERGE LINES(IN=A) HEAD(IN=B) ; BY BENE_ID EP_ID CLM_ID ;
	IF A AND B ;

	*allowed = LALOWCHG;
	allowed = LINEPMT ;
	IF CLM_LINE_STD_PYMT_AMT = . THEN CLM_LINE_STD_PYMT_AMT = ALLOWED ;
	if LALOWCHG > 0 ;  *** REMOVAL OF DENIED CLAIMS **** ;

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

proc sort data=er ; by ep_id bene_id clm_id thru_dt EXPNSDT1 ;
proc means data=er noprint max ; by ep_id bene_id clm_id thru_dt EXPNSDT1 ;
	var er_pre obs_pre uc_pre ;
	output out=erclms (drop = _type_ _freq_)
		   max() = ;
run ;

*** 5/5/17: Identify unique ED dates of service to roll radiology claims occurring on same day into Professional: Emergency *** ;
proc sort data=er out=er_dos(keep=ep_id bene_id EXPNSDT1) nodupkey ; by ep_id bene_id EXPNSDT1 ;

**** Identify OP Surgical claims **** ;
proc sort data=clms ; by ep_id bene_id EXPNSDT1;
data clms2 ;
	merge clms(in=a) er_dos(in=b) ; by ep_id bene_id EXPNSDT1;
	if a ;
	format er_date mmddyy10. ;
	if b then er_date = expnsdt1 ;

proc sort data=clms2 ; by ep_id bene_id clm_id thru_dt EXPNSDT1;
data r2.SC_pb_&bl._&ds.  ;
	merge clms2(in=a drop=er_pre obs_pre uc_pre)	
		  erclms(in=b keep=ep_id bene_id clm_id thru_dt EXPNSDT1 er_pre obs_pre uc_pre) ; 
	by ep_id bene_id clm_id thru_dt EXPNSDT1;
	if a ;

	%canc_init ;
	%CANCERTYPE(LINE_ICD_DGNS_VRSN_CD, LINE_ICD_DGNS_CD) ;

	***  5/4/17: Chemotherapy, Drug and Rad Once Assignments Overrides any other Non-IP assignment. *** ;

	BLAD_LR = 0 ; PROST_CAST = 0 ; BLAD_OTH = 0 ; PROST_OTH = 0 ;
	IF PUT(HCPCS_CD,$Bladder_LR_HCPCS.) = "Y" THEN BLAD_LR = 1 ;
	IF PUT(HCPCS_CD,$Prostate_CS_HCPCS.) = "Y" THEN PROST_CAST = 1 ;
	if put(hcpcs_cd,$Chemo_J.) = 'Y' then DO ;
		SERVICE_CAT = 'Chemotherapy Drugs (Part B)';
		IF BLAD_LR NE 1 THEN BLAD_OTH = 1 ;
		IF PROST_CAST NE 1 THEN PROST_OTH = 1 ;
		BC_Hormonal = 0 ;
		Nonhormonal = 1 ; 
	END ;
	*** Additional J Codes we believe are chemo - as per PP, HB  - Removed 5/4/17*** ;
	*ELSE IF hcpcs_cd in ("J0202","Q9979","J9165","J9213","J9214","J9250","J9260",
						 "J9270","J9300") then service_cat = 'Chemotherapy Drugs (Part B)';
	*** Chemotherapy Categories *** ;
	else if put(hcpcs_cd,$anti.) = 'Y' then SERVICE_CAT = 'Anti-emetics' ;
	else if put(hcpcs_cd,$chemo_admin.) = 'Y' then SERVICE_CAT = 'Chemotherapy Administration';
	else if put(hcpcs_cd,$Hemat_agents_J.) = 'Y' then SERVICE_CAT = 'Hematopoietic Agents';
	ELSE IF PUT(HCPCS_CD,$adjuncts_hcpcs.) = 'Y' THEN SERVICE_CAT = 'Chemotherapy Adjuncts' ;

	else if put(hcpcs_cd,$RAD_ONC.) = 'Y' then SERVICE_CAT = 'Radiation Oncology';

	else if a and b then do ;
		if obs_pre = 1 then SERVICE_CAT = "Professional: Emergency" ;
		else if er_pre = 1 then SERVICE_CAT = "Professional: Emergency" ;
		else SERVICE_CAT = "Professional: Emergency" ;
		
	end ;

	if SERVICE_CAT = '' then do ;

			if plcsrvc = '21' then SERVICE_CAT = "Professional: Inpatient" ;
			else if put(hcpcs_cd,$P11_HCPCS.) = 'Y' then SERVICE_CAT = "Professional: Surgery" ;		
			else if put(hcpcs_cd,$P13_HCPCS.) = 'Y' then SERVICE_CAT = "Professional: Anesthesia" ;
			else if HAS_CANCER = 1 and HCPCS_CD in ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215') then do;
				if TAX_NUM in (&att_tin.) then SERVICE_CAT = 'Professional: Qualifying E&M Visits at Attrib TIN' ;	
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
			else if put(hcpcs_cd,$p34_cpt.) = 'Y' then SERVICE_CAT = 'Other Drugs and Administration';
			else if DME = 1 then SERVICE_CAT = "DME" ;
			/*else if put(hcpcs_cd,$P99_cpts.) = 'Y' then Service_Cat = "Other" ;*/
			else SERVICE_CAT = 'Professional: Other'; 
	end ;

	*** Reassign radiology claims occurring on same day as ED visit to Professional: Emergency *** ;
	if expnsdt1 = er_date and service_cat in ("Radiology: High Tech (MRI, CT, PET)","Radiology: Other") then 
			service_cat = "Professional: Emergency" ;

%mend pb ;

**************************************************************************************
********************* File Based Assignments, Part D *********************************
************************************************************************************** ;
%macro oth ;

PROC SORT DATA=r1.snfhdr_&ds. OUT=SNF1 (where = (nopay_cd="  ")) ; BY EP_ID BENE_ID ;
*** 5/4/2017 - Updated to roll SNF claims up to admission, not  claim level. *** ;
DATA SNF_CLAIMS ;
	MERGE SNF1(IN=A) EPI_DOD(IN=B)  ; BY EP_ID BENE_ID ;
	ADMIT_ID = BENE_ID||PROVIDER||ADMSN_DT ;
	*** NEED TO SCREEN  CLAIMS FOR IN-EPISODE AT THE CLAIM AND NOT ROLLED UP LEVEL *** ;
	IF EP_BEG LE FROM_DT LE EP_END ;
	DROP DOD EP_BEG EP_END ;
	IF CLM_STD_PYMT_AMT = . THEN CLM_STD_PYMT_AMT = PMT_AMT ;

PROC SORT DATA=SNF_CLAIMS ; BY EP_ID BENE_ID ADMIT_ID THRU_DT ;

DATA SNF_CHARS(DROP = UTIL_DAY PMT_AMT DSCHRGDT CLM_STD_PYMT_AMT)  ;
	SET SNF_CLAIMS ; BY EP_ID BENE_ID ADMIT_ID THRU_DT ;
	IF LAST.ADMIT_ID ;
PROC MEANS DATA=SNF_CLAIMS NOPRINT MAX SUM ; BY EP_ID BENE_ID ADMIT_ID ;
	VAR DSCHRGDT UTIL_DAY PMT_AMT CLM_STD_PYMT_AMT;
	OUTPUT OUT=SNF_CLAIMS2 (DROP = _tYPE_ _FREQ_)
		   MAX(DSCHRGDT) = 
		   SUM(UTIL_DAY PMT_AMT CLM_STD_PYMT_AMT) = ;

data r2.SC_snf_&bl._&ds. ;
	MERGE SNF_CHARS(IN=A) SNF_CLAIMS2(IN=B) ; BY EP_ID BENE_ID ADMIT_ID ;
	IF A AND B ;
	FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
	SERVICE_CAT = "SNF" ;
	*ALLOWED = sum(PMT_AMT, DED_AMT, COIN_AMT, BLDDEDAM);
	ALLOWED = PMT_AMT ;
	IF FIRST.ADMIT_ID THEN SNF_COUNT = 1 ;

*********************************************************************** ;
	**************** Hospice Metrics *************** ;
*********************************************************************** ;

*** 5/15/17 Capturing Facility and Non-Facility Flags **** ;
data HSPCODES ;
	SET r1.hspREV_&ds. ;
	IF HCPCS_CD IN ('Q5003','Q5004','Q5005','Q5006','Q5007','Q5008','Q5010',
					'Q5001','Q5002') ;
	IF HCPCS_CD IN ('Q5003','Q5004','Q5005','Q5006','Q5007','Q5008','Q5010') THEN HSP_FAC = 1 ;
	ELSE HSP_FAC = 0 ;

	IF HCPCS_CD IN ('Q5001','Q5002') THEN HSP_HOME = 1 ; ELSE HSP_HOME = 0 ;

proc sort data=hspcodes ; by ep_id bene_id CLM_ID THRU_DT ;
PROC MEANS DATA=HSPCODES NOPRINT MAX ; by ep_id bene_id CLM_ID THRU_DT ;
	VAR HSP_FAC HSP_HOME ;
	OUTPUT OUT=HSP_FLAGS (DROP = _TYPE_ _FREQ_)
		   MAX() = ;

PROC SORT DATA=r1.hsphdr_&ds. out=hosp1 ; by ep_id bene_id clm_id thru_dt ;
data hosp2  ;
	merge hosp1(in=a) hsp_flags(IN=B) ; by ep_id bene_id clm_id thru_dt ;
	IF A ;
	IF A AND B=0 THEN DO ;
		HSP_FAC=0 ; HSP_HOME = 0 ;
	END ;
	IF NOPAY_CD = "  " ;
	*** Standardized amount only provided on header *** ;
	IF FIRST.CLM_ID THEN STD_PAY = CLM_STD_PYMT_AMT ;   

**** 5/15/17: Looking at care in 90, 30, and 3 days within date of death  ****** ;
data hosp3 ;
	merge hosp2(in=a) EPI_DOD(IN=B) ; BY ep_id BENE_ID ;
	IF A AND B ;
	*** NEED TO SCREEN HSP CLAIMS FOR IN-EPISODE AT THE CLAIM AND NOT ROLLED UP LEVEL *** ;
	IF EP_BEG LE FROM_DT LE EP_END ;

	IF DOD NE . AND FROM_DT GE EP_BEG THEN DO ;
		FORMAT WIN_90_DOD WIN_30_DOD MMDDYY10. ; 
		WIN_90_DOD = INTNX('DAY',DOD, -89, 'SAME') ;
		WIN_30_DOD = INTNX('DAY',DOD, -29, 'SAME') ;
		ANY_HSP_BOTH = 0 ; ANY_HSP_FAC = 0 ; ANY_HSP_HOME = 0 ;
			IF (WIN_30_DOD LE FROM_DT LE DOD) OR
			   (WIN_30_DOD LE THRU_DT LE DOD) THEN DO ;
				IF HSP_FAC = 1 AND HSP_HOME = 1 THEN ANY_HSP_BOTH = 1 ;
				ELSE IF HSP_FAC = 1 THEN ANY_HSP_FAC = 1 ;
				ELSE IF HSP_HOME = 1 THEN ANY_HSP_HOME = 1 ; 
			END ;
			IF (WIN_90_DOD LE FROM_DT LE DOD) OR
			   (WIN_90_DOD LE THRU_DT LE DOD)	THEN DO ;
				HOSP_DAYS_90 = SUM((THRU_DT - MAX(FROM_DT,WIN_90_DOD)),1) ;
			END ; 
	END ;			

*** 5/4/2017 - Updated to roll Hospice claims up to period, not  claim level. *** ;
PROC SORT DATA=hosp3 OUT=HOSPICE ; BY ep_id BENE_ID PROVIDER FROM_DT THRU_DT ;

DATA  HOSPICE2;
	SET HOSPICE ; BY ep_id BENE_ID PROVIDER FROM_DT THRU_DT ;
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

	IF STD_PAY = . THEN STD_PAY = PMT_AMT ;

PROC SORT DATA=HOSPICE2 ; BY ep_id BENE_ID PROVIDER STAY FROM_DT THRU_DT ;

DATA HSP_CHAR(DROP = PMT_AMT STD_PAY FROM_DT ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME
					 FAC_PMT_AMT HOME_PMT_AMT BOTH_PMT_AMT HOSP_DAYS_90 EP_BEG EP_END ) ;
	SET HOSPICE2 ;BY ep_id BENE_ID PROVIDER STAY ;
	IF LAST.STAY ;


PROC MEANS DATA =HOSPICE2 NOPRINT MIN MAX SUM ; BY ep_id BENE_ID PROVIDER STAY ;
	VAR FROM_DT ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME
		PMT_AMT STD_PAY FAC_PMT_AMT HOME_PMT_AMT BOTH_PMT_AMT HOSP_DAYS_90 ;
	OUTPUT OUT=HSP_CLAIMS (DROP = _TYPE_ _FREQ_)
		   min(FROM_DT) = 
		   MAX(ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME ) = 
		   SUM(PMT_AMT STD_PAY FAC_PMT_AMT HOME_PMT_AMT BOTH_PMT_AMT HOSP_DAYS_90) = ;
data SC_hsp_&bl._&ds. ;
	MERGE HSP_CHAR(IN=A) HSP_CLAIMS(IN=B) ; BY ep_id BENE_ID PROVIDER stay ;
	IF A AND B ;
	FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
	SERVICE_CAT = "Hospice" ;
	ALLOWED = PMT_AMT ;
	CLM_STD_PYMT_AMT = STD_PAY ; DROP STD_PAY ;

**** Accounting for same day transfers for day counts **** ;
proc sort data=SC_hsp_&bl._&ds. ; by ep_id bene_id FROM_DT THRU_DT ;
DATA R2.SC_hsp_&bl._&ds. ;
	SET SC_hsp_&bl._&ds. ;by ep_id bene_id FROM_DT THRU_DT ;
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
PROC SORT DATA=R2.SC_hsp_&bl._&ds. OUT=sch; BY ep_id BENE_ID FROM_DT ;
DATA LATEST ;
	SET SCH ; BY ep_id BENE_ID FROM_DT ;
	IF LAST.BENE_ID AND DOD NE . ;
	IF (THRU_DT = . OR THRU_DT GE DOD) AND  (DOD-FROM_DT GE 3) THEN HOSP_3DAY = 1 ;
	ELSE HOSP_3DAY = 0 ;

PROC SORT DATA=LATEST ; BY ep_id BENE_ID ;
PROC MEANS DATA=LATEST NOPRINT MAX ; BY ep_id BENE_ID ;
	VAR HOSP_3DAY ;
	OUTPUT OUT=OCM3(DROP = _TYPE_ _FREQ_)
		   Max() = ;


data r2.SC_hha_&bl._&ds. ;
	set r1.hhahdr_&ds.(WHERE = (NOPAY_CD = "  ")) ;
	FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
	SERVICE_CAT = "Home Health" ;
	ALLOWED = PMT_AMT ;
	HH_COUNT = VISITCNT ;
	IF CLM_STD_PYMT_AMT = . THEN CLM_STD_PYMT_AMT = ALLOWED ;

data r2.SC_pde_&bl._&ds. ;
	set /*r1.pde_&ds.*/ R2.pde2_&ds. ;
	FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
	SERVICE_CAT = "Other Drugs and Administration" ;
	ndc9 = substr(prod_srvc_id,1,9) ;
	ndc8 = substr(prod_srvc_id,1,8) ;

	BLAD_LR = 0 ; BLAD_OTH = 0 ; PROST_CAST = 0 ; PROST_OTH = 0 ;
	IF PUT(NDC9,$Bladder_LR_NDC.) = "Y" THEN BLAD_LR = 1 ;
	IF PUT(NDC9,$Prostate_CS_NDC.) = "Y" THEN PROST_CAST = 1 ;
	if put(NDC9, $Chemo_NDC.) = "Y" then DO ;
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
	*ALLOWED = TOT_RX_CST_AMT ;
	ALLOWED = SUM(LICS_AMT,(.8*GDC_ABV_OOPT_AMT)) ;
run ;

%mend oth ;

		   
**************************************************************************** ;
**************************************************************************** ;
**************************************************************************** ;

%IP ;
%OP ; 
%PB ;
%oth ;


**************************************************************************** ;
***************** Creating Episode Level Flags ***************************** ;
**************************************************************************** ;


data CLMS_COMBINE(drop=ep_beg ep_end dod) ;
	format rev_cntr $20. ;
	set r2.SC_ip_&bl._&ds.(IN=G)
		r2.SC_OP_&bl._&ds.(IN=OP) 
		r2.SC_PB_&bl._&ds. (IN=B)
		r2.SC_PDE_&bl._&ds.(IN=C)
		r2.SC_hsp_&bl._&ds.(IN=D)
		r2.SC_hha_&bl._&ds(IN=E)
		r2.SC_snf_&bl._&ds.(IN=F);
		OCM_ID = "&id." ;
		IF B THEN SRC = "PB/DME" ;
		IF G THEN SRC = "IP" ;
		IF op THEN SRC = "OP" ;
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

		ELSE IF OP THEN DO ;
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
		if B OR op OR C OR D OR E THEN LOS = MAX((END_DATE-START_DATE),1) ;
		IF G OR F THEN LOS = UTIL_DAY ;
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


		*** Not available for baseline *** ;
		NOVEL_THERAPY = "NO" ;

		IF G OR op OR D OR E OR F THEN PRVDR_NUM = PROVIDER ;
		DATE_SCREEN = MAX(START_DATE,PART_D_SERVICE_DATE) ;

*** Identifying castration sensitive prostate and breast cancer with hormonal treatment only for override of 
	IP chemo sensitive. *** ;
proc sort data=clms_combine ; by ep_id ;
proc means data=clms_combine noprint max ; by ep_id ;
	var BC_Hormonal Nonhormonal PROST_CAST PROST_OTH ;
	output out=flagmems (drop = _type_ _freq_)
		   max() = ;

data cs_or (keep = ep_id override_flag) ;
	merge flagmems epi_dod(keep=ep_id cancer_type_milliman); by ep_id ;
	override_flag = 0 ;
	if bc_hormonal = 1 and nonhormonal = 0 and cancer_type_milliman = "Breast Cancer" then override_flag = 1 ;
	if prost_cast = 1 and prost_oth = 0 and cancer_type_milliman = "Prostate Cancer" then override_flag = 1 ;



DATA ALL_CLAIMS_&bl._&DS. radonc chemo_partb OCM2_CHK I1;
	**** ENSURING THAT CLAIMS OCCUR WITHIN EPISODE **** ;
	merge r2.epi_prelim_&bl._&ds.(in=ab keep = ep_id ep_beg ep_end dod cancer_type cancer_type_milliman) 
		  CLMS_COMBINE(in=b) 
		  cs_or; by ep_id ;
		  if ab and b ;
		  if ep_beg <= DATE_SCREEN <= ep_end ;

		  CLAIM_ID = CLM_ID ;

		*** Generation of standardized payment summaries *** ;
		IF SRC IN ("IP","SNF","HHA","HSP") THEN DO ;
			STD_PAY = CLM_STD_PYMT_AMT ;
			IF THRU_DT GE MDY(4,1,2013) THEN STD_PAY = STD_PAY/.98 ;
		END ;
		ELSE IF SRC IN ("OP") THEN DO ;
			STD_PAY = CLM_REV_STD_PYMT_AMT ;
			IF THRU_DT GE MDY(4,1,2013) THEN STD_PAY = STD_PAY/.98 ;
		END ;
		ELSE IF SRC = "PB/DME" THEN DO ;
			STD_PAY = CLM_LINE_STD_PYMT_AMT ;
			IF PROF =  1 AND THRU_DT GE MDY(4,1,2013) THEN STD_PAY = STD_PAY/.98 ;
			IF DME = 1 AND FROM_DT GE MDY(4,1,2013) THEN STD_PAY = STD_PAY/.98 ; 
		END ;
		ELSE STD_PAY = ALLOWED ;

		**** Added 1/9/18 - Removal of facility lines with $0 Paid, with a revenue code but
			 no procedure code. **** ;
		IF SRC NOTIN ("IP","PB/DME") AND ALLOWED = 0 AND HCPCS_CD = "  " AND REV_CNTR NE "  " THEN DELETE ;
		*** Added 2/2/18 - Removal of lines with $0 paid and specific procedure codes *** ;
		IF ALLOWED = 0  AND HCPCS_CD IN ('85025','36415','80053','80048','85027','96368',
										 'J7050','A9270','J7040','96376','96361') THEN DELETE ;


		** Breaking out chemotherapy into types ** ;
		if SERVICE_CAT = 'Chemotherapy Drugs (Part B)' then do ;
			output chemo_partb ;
			CPB_CAT = put(HCPCS_CD,$Chemo_J_CAT.) ;
			IF CPB_CAT = "N" then CPB_CAT = "Other" ;
			*** Additional J Codes we believe are chemo - as per PP, HB - Removed 5/4/17 *** ;
			*if hcpcs_cd in ("J0202","Q9979","J9213","J9214","J9300") then CPB_CAT = "Biologic" ;
			*else if hcpcs_cd in ("J9165") then CPB_CAT = "Hormonal" ;
			*else if hcpcs_cd in ("J9250","J9260","J9270") then CPB_CAT = "Cytotoxic" ;
			SERVICE_CAT = 'Part B Chemo: '||left(CPB_CAT) ;
		end ;

		if SERVICE_CAT = 'Chemotherapy Drugs (Part D)' then do ;
			CPD_CAT = put(NDC9,$Chemo_NDC_CAT.) ;
			IF NDC8 = '00780645' THEN CPD_CAT = 'Biologic' ;
			IF CPB_CAT = "N" then CPB_CAT = "Other" ;
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

		format LABEL2 $100. ; length LABEL2 $100. ;
		LABEL2 = SERVICE_CAT ;

		FORMAT LABEL1 $50. ; LENGTH LABEL1 $50. ; 
		if service_cat in ("Inpatient: Other","Inpatient Surgical: Cancer",
						  "Inpatient Surgical: Non-Cancer","Inpatient Medical: Potentially Chemo Related",
						  "Inpatient Medical: Other",
						  "Emergency Department","Outpatient Surgery: Cancer", 
					      "Outpatient Surgery: Non-Cancer",'Outpatient: Other',
						  "SNF","Home Health","Hospice") then LABEL1 = "Facilities" ;
		else if service_cat in ("Other Drugs and Administration",'Chemotherapy Administration',
							    'Chemotherapy Adjuncts','Hematopoietic Agents','Anti-emetics')
			 OR SUBSTR(SERVICE_CAT,1,12) in ('Part B Chemo','Part D Chemo') then LABEL1 = 'Drugs' ;
		else if service_cat in ('Radiation Oncology','Radiology: MRI','Radiology: CT','Radiology: PET',
								'Radiology: Other','Lab') then LABEL1 = 'Radiation & Lab' ;
		else LABEL1 = 'Professional' ;


		IF CPD_CAT NE "  " THEN do ;
			PART_D_CHEMO=1 ;
			if service_cat = "Part D Chemo: Cytotoxic" then PART_D_CHEMO_CYTO = 1 ;
			else if service_cat = "Part D Chemo: Biologic" then PART_D_CHEMO_BIO = 1 ;
			else if service_cat = "Part D Chemo: Hormonal" then PART_D_CHEMO_HARM = 1 ;
			else if service_cat = "Part D Chemo: Other" then PART_D_CHEMO_OTH = 1 ;
		END ;
		IF CPB_CAT NE "  " THEN DO ;
			PART_B_CHEMO=1 ;
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


		if ER_CLAIM = 1 THEN DO ;  *** Tags all lines on ED claim, not just those which occurred on same rev_dt *** ;
			ER_DOW = WEEKDAY(DATE_SCREEN) ;
			IF ER_DOW IN (1,7) THEN ER_WEEKEND = 1 ;
			ELSE ER_WEEKEND = 0 ;
		END ;


		*** End of Life Metrics **** ;
		format win_14_dod win_30_dod mmddyy10. ;

		IF SRC = "IP" THEN DO ;
			if cancer_type ne "Breast Cancer" then SIP_BREAST = 0 ;
			if cancer_type ne "Anal Cancer" then SIP_ANAL = 0 ;
			if cancer_type ne "Kidney Cancer" then SIP_KIDNEY = 0 ;
			if cancer_type ne "Liver Cancer" then SIP_LIVER = 0 ;
			if cancer_type ne "Lung Cancer" then SIP_LUNG = 0 ;
			if cancer_type ne "Bladder Cancer" then SIP_BLADDER = 0 ;
			if cancer_type ne "Female GU Cancer other than Ovary" then SIP_FEMALEGU = 0 ;
			if cancer_type ne "Gastro/Esophageal Cancer" then SIP_GASTRO = 0 ;
			if cancer_type ne "Head and Neck Cancer" then SIP_HN = 0 ;
			if cancer_type ne "Small Intestine / Colorectal Cancer" then SIP_INT = 0 ;
			if cancer_type ne "Ovarian Cancer" then SIP_OVARIAN = 0 ;
			if cancer_type ne "Prostate Cancer" then SIP_PROSTATE = 0 ;
			if cancer_type ne "Pancreatic Cancer" then SIP_PANCREATIC = 0 ;
			if cancer_type ne "Acute Leukemia" then IP_BMT_AK = 0 ;
			if cancer_type ne "Lymphoma" then IP_BMT_L = 0 ;
			if cancer_type ne "Multiple Myeloma" then IP_BMT_MM = 0 ;
			if cancer_type ne "MDS" then IP_BMT_MDS = 0  ;
			if cancer_type ne "Chronic Leukemia" then IP_BMT_CL = 0 ;
			IF SUM(IP_CHEMO_ADMIN, IP_BMT_AK, IP_BMT_L, IP_BMT_MM, IP_BMT_MDS, IP_BMT_CL, SIP_BREAST,SIP_ANAL,SIP_LIVER, 
				   SIP_LUNG, SIP_BLADDER, SIP_FEMALEGU,SIP_GASTRO, SIP_HN, SIP_INT, SIP_OVARIAN, SIP_PROSTATE, 
				   SIP_PANCREATIC, SIP_KIDNEY) GE 1 THEN EX1 = 0 ; 
			 ELSE IF IP_CAH = 1 THEN EX1 = 1 ;
			 ELSE EX1 = 0 ;
			
			end ;


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
						IF SUM(REVPMT,PTNTRESP) > 0 THEN DO ;
							ED_OCM2 = 1 ;
							IF "70000" LE HCPCS_CD LE "89999" OR 
							    HCPCS_CD IN ('G0106','G0120','G0122','G0130','G0202','G0204','G0206','G0219',
											 'G0235','G0252','G0255','G0288','G0389','S8035','S8037','S8040',
											 'S8042','S8080','S8085','S8092','S9024') THEN ED_OCM2 = 0 ;
						END ;
				END ;
	   
				IF REV_CNTR = '0762' OR
				  (REV_CNTR = '0760' AND HCPCS_CD = "G0378" AND REV_UNIT GE 8) THEN DO ;
						IF SUM(REVPMT,PTNTRESP) > 0 THEN DO ;
							OBS_OCM2 = 1 ;
				  		END ;
				END ;
		END ;

		IF SRC = "HSP" THEN DO ;
			HSP_PMT_AMT = ALLOWED ;
			HSP_STD_AMT = STD_PAY ;
			ANYHOSP = 1 ;
		END ;


		IF DOD NE . THEN DO ;
				format win_14_dod mmddyy10. ;
				*** Add 1 day to include the day of DOD *** ;
				WIN_14_DOD = INTNX('DAY',DOD,-13,'SAME') ;
				IF (WIN_14_DOD LE DATE_SCREEN LE DOD) AND
				   (CPB_CAT NE "   " OR CPD_CAT NE "  ") THEN CHEMO_DEATH14 = 1 ;
		END ;

		********************************** ;
		********************************** ;
		*** 11/9: Creating Summary allowed amounts for Episode File **** ;
		IF LABEL2 IN ('Part B Chemo: Cytotoxic','Part B Chemo: Biologic','Part B Chemo: Hormonal',
		  			  'Part B Chemo: Other')  THEN DO ;
						CHEMOPB_ALLOWED = ALLOWED ;
						CHEMOPB_STD = STD_PAY;
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
						OTHRX_STD = STD_PAY;
						END ;

		IF LABEL1 = 'Radiation & Lab' THEN DO ;
						RADLAB_ALLOWED = ALLOWED ;
						RADLAB_STD = STD_PAY;
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

		IF LABEL2 IN ('Emergency Department') THEN DO ;
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
		********************************** ;
		*** 2/2: Creating Part B Units_Dose Field **** ;
		IF LABEL2 IN ('Part B Chemo: Cytotoxic','Part B Chemo: Biologic','Part B Chemo: Hormonal',
		  			  'Part B Chemo: Other','Hematopoietic Agents','Anti-emetics',"Other Drugs and Administration",
					  'Chemotherapy Administration','Chemotherapy Adjuncts') THEN DO ;
			IF SRC = "OP" THEN UNITS_DOSE = REV_UNIT ;
			IF SRC = "PB/DME" THEN UNITS_DOSE = SRVC_CNT ;
		END ;
			
		***************************************************************************************** ;
		**** Added 1/14/18 *** ;
		CANCER_EM = 0 ; EM_ATT = 0 ; 
		if SRC = "PB/DME" and 
		   HCPCS_CD in ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215') and 
		   has_cancer = 1 then do ;
		   		cancer_em = 1 ;
				if TAX_NUM in (&att_tin.)THEN EM_ATT = 1 ;
		END ;
		IF EM_ATT = 1 THEN EM_ATT_TAX = CANCER_EM ;
		ELSE EM_NONATT_TAX =CANCER_EM ;

		IF ED_OCM2 =1 OR OBS_OCM2 = 1 THEN OUTPUT OCM2_CHK ;
		if SERVICE_CAT = 'Radiation Oncology' then output radonc ;
		IF SRC = "IP" THEN OUTPUT I1 ;
		output ALL_CLAIMS_&bl._&DS. ;

*** OCM2 - Seeing whether ED and OBS led to admission *** ;
PROC SQL ;
	CREATE TABLE WADMIT AS
	SELECT A.BENE_ID, A.EP_ID, A.CLM_ID, A.ED_OCM2, A.OBS_OCM2, A.THRU_DT, A.IP_CASE
	FROM OCM2_CHK AS A, ip1a AS B 
	WHERE A.EP_ID =B.EP_ID AND A.THRU_DT = B.ADMSN_DT ;

PROC SORT DATA=WADMIT ; BY EP_ID CLM_ID THRU_DT ;
PROC MEANS DATA=WADMIT NOPRINT MAX ; BY EP_ID CLM_ID THRU_DT ;
	VAR ED_OCM2 OBS_OCM2 ;
	OUTPUT OUT=WADMIT2 (DROP=_TYPE_ _FREQ_)
		   MAX() = ;

PROC SORT DATA=OCM2_CHK ; BY EP_ID CLM_ID THRU_DT ;

	DATA O2 ;
	MERGE OCM2_CHK(IN=A) WADMIT2(IN=B DROP=ED_OCM2 OBS_OCM2) ; BY EP_ID CLM_ID THRU_DT ;
	IF A ;
	IF A AND B THEN RESULT_IN_ADMIT = 1 ;
			   ELSE RESULT_IN_ADMIT = 0 ;


PROC MEANS DATA=O2 NOPRINT MAX ; BY EP_ID CLM_ID THRU_DT ;
	VAR ED_OCM2 OBS_OCM2 RESULT_IN_ADMIT ;
	OUTPUT OUT=EDOBS (DROP = _TYPE_ _FREQ_)
		   MAX() = ;

PROC SORT DATA=ALL_CLAIMS_&bl._&DS. ; BY EP_ID CLM_ID THRU_DT ;

DATA ALL_CLAIMS;
	MERGE ALL_CLAIMS_&bl._&DS.(IN=A) EDOBS(IN=B) ; BY EP_ID CLM_ID THRU_DT ;
	IF A ;
	*** For ED and OBS service counts *** ;
	IF SUM(ED_OCM2,OBS_OCM2) > 0 THEN DO ;
		IF RESULT_IN_ADMIT NE 1 THEN OCM2 = 1 ;
	END ;

PROC SORT DATA=ALL_CLAIMS ; BY EP_ID ;

*** Gets at number of radiation oncology days for episode level file. *** ;

DATA RADONC ;
	SET RADONC ;
	RO_DATE = START_DATE ;
	FORMAT RO_DATE MMDDYY10. ;
PROC SORT DATA=RADONC NODUPKEY ; BY EP_ID RO_DATE ;
DATA RADONC ; SET RADONC ; ROC = 1 ;
PROC MEANS DATA=RADONC NOPRINT SUM MIN MAX ; BY EP_ID ;
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

PROC SORT DATA=CHEMO_PARTB NODUPKEY; BY EP_ID TRIGGER_DATE  ;
PROC MEANS DATA=CHEMO_PARTB NOPRINT MIN MAX SUM ; BY EP_ID ;
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
	SET ALL_CLAIMS ;
	IF SERVICE_CAT in ("Emergency Department") THEN OUTPUT EDCLMS ;
	ELSE OUTPUT CLMS_OTH  ;

proc sort data=EDCLMS ; by ep_id REV_DT ;

DATA EDCLMS  ;
	SET EDCLMS ; BY EP_ID rev_dt ;
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
	merge wadmit(in=a) ip(in=b keep = bene_id ep_id ip_case nopay_cd CLM_ID) ; BY BENE_ID EP_ID CLM_ID ;
	IF A and NOPAY_CD = " ";
PROC SORT DATA=WADMIT_A ; BY BENE_ID EP_ID IP_CASE ;
PROC MEANS DATA=WADMIT_A NOPRINT MAX ; BY BENE_ID EP_ID IP_CASE ;
	VAR ED_OCM2 OBS_OCM2 ;
	OUTPUT OUT=PRE_ADMIT (DROP =_TYPE_ _FREQ_)
		   MAX () = ;

PROC SORT DATA=IP ; BY BENE_ID EP_ID IP_CASE ;


DATA READM_TEST OTH_IP;
	MERGE IP(IN=A) PRE_ADMIT(IN=B) ; BY BENE_ID EP_ID IP_CASE ;
	IF A ;
		
		*** Beneficiary file utilization fields *** ;
			IF FIRST.IP_CASE THEN DO ;
					ADMIT_COUNT = 1 ;
			END ;
			ELSE ADMIT_COUNT = 0 ;

			IF IP_ER_CASE = 1 THEN ADM_FROM_ER_UTIL = ADMIT_COUNT ;


			READMIT_FLAG = 0 ;
			READ_COUNT = 0 ;
			IF READM_CAND_CASE = 1 THEN OUTPUT READM_TEST ;
			ELSE OUTPUT OTH_IP ;

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

DATA R2.ALL_CLAIMS_&bl._&DS.   ;
	SET READ_FINAL OTH_IP OTHER ;
	format TaxNum_TIN $32.;
	if tax_num in (&att_tin.) then TaxNum_TIN = 'Your TIN (' || tax_num || ')';
	else TaxNum_TIN = 'Other TIN (' || tax_num || ')';
run;
PROC SORT DATA=R2.ALL_CLAIMS_&bl._&DS. ; BY BENE_ID EP_ID CLM_ID THRU_DT ER_CLAIM REV_DT;
DATA R2.ALL_CLAIMS_&bl._&DS. ;
	SET R2.ALL_CLAIMS_&bl._&DS. ;BY BENE_ID EP_ID CLM_ID THRU_DT ER_CLAIM REV_DT ;
	IF FIRST.REV_DT THEN DO ;
		IF ER_CLAIM = 1 THEN ER_COUNT_FLAG = 1 ;
		PREV_ERW = ER_WEEKEND ;
	END ;
	ELSE DO ;
		ER_WEEKEND = PREV_ERW ;
	END ;
	RETAIN PREV_ERW ;

	*** Added 1/8/18 - Creates distinct count of ED visits on weekend *** ;
	ER_WEEKEND_COUNT = ER_WEEKEND*ER_COUNT_FLAG ;

PROC SORT DATA=R2.ALL_CLAIMS_&bl._&DS.  out=CLMS_ALL ; BY EP_ID ;

proc means data=CLMS_ALL noprint max sum ; by ep_id ;
	var IPOTH IPSCAN IPSNCAN IPMEDCS IPMEDNCS died_in_hosp ip_cah FAC_ER_CHEMO FAC_OPSURG_NONCANC
		FAC_OPSURG_CANC ANTIEMETICS CHEMO_ADMIN HEMATO RAD_ONC RAD_HT RAD_OTH LAB OTH_DRUG CHEMO_ADJUNCTS OP_OTH
		PROF_ER PROF_ER_CS PROF_IP PROF_SURG PROF_ANES PROF_OV EM_ATT_VISIT EM_OTH_VISIT DME PROF_OTH OTHER PART_D_CHEMO PART_B_CHEMO 
		PART_B_CHEMO_CYTO PART_D_CHEMO_CYTO PART_B_CHEMO_BIO PART_D_CHEMO_BIO PART_B_CHEMO_HARM 
		PART_D_CHEMO_HARM PART_B_CHEMO_OTH PART_D_CHEMO_OTH RAD_MRI RAD_CT RAD_PET allowed TOT_RX_CST_AMT ER_COUNT
		ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME EX1 IP_ALLCAUSE_30 IP_ICU_30 CHEMO_DEATH14 ANYHOSP 
		OP_ALLCAUSE_30 HOSP_DAYS_90 OCM2  EM_ATT_TAX EM_NONATT_TAX ER_WEEKEND BLAD_LR BLAD_OTH PROST_CAST PROST_OTH 
		ADMIT_COUNT SNF_COUNT HH_COUNT CHEMOPB_ALLOWED CHEMOPD_ALLOWED ANTIEMETICS_ALLOWED
		HEMATOPOIETIC_ALLOWED OTHRX_ALLOWED RADLAB_ALLOWED  PROF_ALLOWED IP_ALLOWED ER_ALLOWED
		OP_ALLOWED HOSPICE_ALLOWED HH_ALLOWED SNF_ALLOWED IP_LOS ADM_FROM_ER_UTIL 
		ER_WEEKEND_COUNT EM_ATT_TAX EM_NONATT_TAX READ_COUNT 
		CHEMOPB_std CHEMOPD_std ANTIEMETICS_std
		HEMATOPOIETIC_std OTHRX_std RADLAB_std  PROF_std IP_std ER_std
		OP_std HOSPICE_std SNF_std HH_std STD_PAY 
		bc_hormonal nonhormonal 	READM_COUNT INDEX_COUNT  ;
	output out=EPI_FLAGS_OP (drop = _type_ _freq_)
		   max(IPOTH IPSCAN IPSNCAN IPMEDCS IPMEDNCS  FAC_ER_CHEMO 
			   FAC_OPSURG_NONCANC FAC_OPSURG_CANC 
			   ANTIEMETICS CHEMO_ADMIN HEMATO RAD_ONC RAD_HT RAD_OTH LAB OTH_DRUG CHEMO_ADJUNCTS OP_OTH
			   PROF_ER PROF_ER_CS PROF_IP PROF_SURG PROF_ANES PROF_OV EM_ATT_VISIT EM_OTH_VISIT DME PROF_OTH OTHER PART_D_CHEMO PART_B_CHEMO
			   	PART_B_CHEMO_CYTO PART_D_CHEMO_CYTO PART_B_CHEMO_BIO PART_D_CHEMO_BIO PART_B_CHEMO_HARM 
				PART_D_CHEMO_HARM PART_B_CHEMO_OTH PART_D_CHEMO_OTH RAD_MRI RAD_CT RAD_PET 
				ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME EX1 IP_ALLCAUSE_30 IP_ICU_30 CHEMO_DEATH14
				ANYHOSP OP_ALLCAUSE_30 OCM2 ER_WEEKEND BLAD_LR BLAD_OTH PROST_CAST PROST_OTH died_in_hosp ip_cah  
				bc_hormonal nonhormonal) =				
			sum(allowed TOT_RX_CST_AMT ER_COUNT HOSP_DAYS_90 
				ADMIT_COUNT SNF_COUNT HH_COUNT CHEMOPB_ALLOWED CHEMOPD_ALLOWED ANTIEMETICS_ALLOWED
				HEMATOPOIETIC_ALLOWED OTHRX_ALLOWED RADLAB_ALLOWED PROF_ALLOWED IP_ALLOWED ER_ALLOWED
				OP_ALLOWED HOSPICE_ALLOWED HH_ALLOWED SNF_ALLOWED IP_LOS ADM_FROM_ER_UTIL
				ER_WEEKEND_COUNT EM_ATT_TAX EM_NONATT_TAX READ_COUNT 
				CHEMOPB_std CHEMOPD_std ANTIEMETICS_std
				HEMATOPOIETIC_std OTHRX_std RADLAB_std  PROF_std IP_std ER_std
				OP_std HOSPICE_std SNF_std HH_std STD_PAY READM_COUNT INDEX_COUNT ) =  
			sum(EM_ATT_VISIT EM_OTH_VISIT) = EM_ATT_VISIT_CHK EM_OTH_VISIT_CHK ;


**************************************************************************** ;
****************** Creating final episode INTERFACE file. ****************** ;
**************************************************************************** ;
DATA EPIPRE(drop = recon_elig) ;
	merge r2.epi_prelim_&bl._&ds.(in=a RENAME=(EPI_TAX_ID=TAX EPI_NPI_ID=ENI)) 
		  EPI_FLAGS_OP ROC_ONC_DAYS PB_DATES ocm3; by ep_id ;
	IF A ;

data epipre_a ;
	set epipre (rename = (EP_ID=EP_ID_CMS)) ;
	OCM_ID = "&id." ;


	if cancer_type_milliman = "  " then cancer_type_milliman = cancer_type ;
	FORMAT CHEMO_UTIL_TYPE $26. ;
	LENGTH CHEMO_UTIL_TYPE $26. ;
	IF PART_D_CHEMO = 1 AND PART_B_CHEMO = 1 then CHEMO_UTIL_TYPE = "Part B and Part D" ;
	ELSE IF PART_D_CHEMO = 1 then CHEMO_UTIL_TYPE = "Part D" ;
	ELSE IF PART_B_CHEMO = 1 then CHEMO_UTIL_TYPE = "Part B" ;
	ELSE CHEMO_UTIL_TYPE = "Chemo Type NA" ;

	**** 10/10/17 - Episode Counter **** ;
	format EPI_COUNTER $50. ; length EPI_COUNTER $50. ;
	EPI_COUNTER = "Baseline Episode "||COMPRESS(ec,' ') ;
	** PB_DATES merges in fields CHEMO_DATS_PARTB and CHEMO_LENGTH_PARTB ** ;
	** RAD_ONC_DAYS merges in fields RAD_ONC_DATS and RAD_ONC_LENGTH ** ;
    epb = ((year(ep_beg)-2000)*10000)+(month(ep_beg)*100)+day(ep_beg) ;
    LENGTH EP_ID $100. ; FORMAT EP_ID $100. ;
    EP_ID = CATS(EP_ID_CMS,"-",epb,"-B-",OCM_ID)  ;

	IP_MED_CHEMO_UTIL = MAX(0,IPMEDCS) ;
	IP_MED_NON_CHEMO_UTIL = MAX(0,IPMEDNCS) ;
	IP_SURG_CHEMO_UTIL = MAX(0,IPSCAN) ;
	IP_SURG_NON_CHEMO_UTIL = MAX(0,IPSNCAN) ;
	IP_OTHER_UTIL = MAX(0,IPOTH) ;
	**** Added 10/25/17 **** ;
	IP_FROM_ED_UTIL = MAX(0,ADM_FROM_ER_UTIL) ;
	**** Added 1/9/18 **** ;
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
	
	
	
	OUT_SURG_UTIL = MAX(OUT_SURG_CANCER_UTIL, OUT_SURG_NONCANCER_UTIL) ;
	OP_UTIL = MAX(OUT_SURG_UTIL, OUT_OTHER_UTIL) ;
	DRUG_UTIL = MAX(ANTI_EMETICS_UTIL,HEMOTAPOETIC_UTIL,OTHER_DRUGS_UTIL, 
				    CHEMO_ADJ_UTIL,CHEMO_ADMIN_UTIL, CHEMO_D_UTIL, CHEMO_B_UTIL);
	CHEMO_ADMIN_UTIL = MAX(0, CHEMO_ADMIN) ;
	
	RAD_ONC_UTIL = MAX(0,RAD_ONC) ;
	RAD_ONC_DAYS = MAX(0,ROC_ONC_DAYS) ;

	FORMAT PATIENT_NAME $50. ;   LENGTH PATIENT_NAME $50. ;
	PATIENT_NAME = PROPCASE(COMPRESS(LAST_NAME,' '))||', '||PROPCASE(COMPRESS(FIRST_NAME,' ')) ;	
	IF SEX = "1" THEN PATIENT_SEX = 1  ;
	ELSE IF SEX = "2" THEN PATIENT_SEX = 2 ;
	ELSE PATIENT_SEX = 0 ;

	ALLOWED_MILLIMAN = ALLOWED ;
	ACTUAL_EXP_STD_MILLIMAN = STD_PAY ;

	EPI_TAX_ID = TAX ;
	EPI_NPI_ID = ENI ;
	DUAL_PTD_LIS_MILLIMAN = DUAL_PTD_LIS ;
	INST_MILLIMAN = INST ;
	BASELINE_PRICE_MILLIMAN = 0 ;

	*** End of Life Metrics *** ;
	IF EP_BEG LE DOD LE EP_END THEN DIED_MILLIMAN = 1 ;
	ELSE DIED_MILLIMAN = 0 ;

	IF DIED_MILLIMAN = 1 THEN DO ;
		HSP_30DAYS_ALL_MILLIMAN = MAX(0,ANY_HSP_FAC, ANY_HSP_HOME, ANY_HSP_BOTH) ;
		IF ANY_HSP_BOTH = 1 OR (ANY_HSP_FAC = 1 AND ANY_HSP_HOME = 1) THEN ANY_HSP_CARE_MILLIMAN = 3 ;
			ELSE IF ANY_HSP_FAC = 1 THEN ANY_HSP_CARE_MILLIMAN = 2 ;
			ELSE IF ANY_HSP_HOME = 1 THEN ANY_HSP_CARE_MILLIMAN = 1 ;
			ELSE ANY_HSP_CARE_MILLIMAN = 0 ;
		HSP_DAYS_MILLIMAN = MAX(0,HOSP_DAYS_90) ;
		HOSPITAL_USE_MILLIMAN = MAX(0,IP_ALLCAUSE_30,OP_ALLCAUSE_30) ;
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
	IF DOD = . or 
	   (DOD > EP_END) THEN DO ;
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

	IP_COUNT = ADMIT_COUNT ;
	READ_COUNT = MAX(0,READ_COUNT) ;
	ER_WEEKEND = MAX(0,ER_WEEKEND) ;
	ER_WEEKEND_COUNT = MAX(0,ER_WEEKEND_COUNT) ;

	INDEX_ADMIT_COUNT = MAX(0,INDEX_COUNT) ;
	READMISSION_COUNT = MAX(0,READM_COUNT) ;

	FORMAT M_EPI_SOURCE_FINAL $10. ; LENGTH M_EPI_SOURCE_FINAL $10. ; 
	M_EPI_SOURCE = MAX(0, M_EPI_SOURCE) ;
	IF M_EPI_SOURCE = 0 then M_EPI_SOURCE_FINAL = "UNKNOWN" ;
	ELSE IF M_EPI_SOURCE = 4 THEN M_EPI_SOURCE_FINAL = "PART D" ;
	ELSE M_EPI_SOURCE_FINAL = "PART B" ;


	IF MISSING(EM_ATT_TAX) THEN EM_ATT_TAX = '0' ;
	IF MISSING(EM_NONATT_TAX) THEN EM_NONATT_TAX = '0' ;

	EPI_TIN_MATCH = "Baseline" ;

	%episode_period ;

	**** BASELINE/PP3 PROSTATE AND BLADDER DISTINCTIONS **** ;
	***Milliman Cancer Type;
	IF CANCER_TYPE_MILLIMAN = "Bladder Cancer" THEN DO ; 	
		IF BLAD_LR = 1 AND BLAD_OTH = 0 THEN DO ;
			CANCER_TYPE_MILLIMAN = "Bladder Cancer - Low Risk" ;
		end ;
		ELSE DO ;
			CANCER_TYPE_MILLIMAN = "Bladder Cancer - High Risk" ;
		END ;
	END ;

	IF CANCER_TYPE_MILLIMAN = "Prostate Cancer" then do ;
		IF PROST_CAST = 1 AND PROST_OTH = 0 THEN DO ;
			CANCER_TYPE_MILLIMAN = "Prostate Cancer - Low Intensity" ;
		end ;
		ELSE DO ;
			CANCER_TYPE_MILLIMAN = "Prostate Cancer - High Intensity" ;
		END ;
	END ;
	IF CANCER_TYPE_MILLIMAN = "Breast Cancer" then do ;
		IF bc_hormonal = 1 AND nonhormonal = 0 THEN DO ;
			CANCER_TYPE_MILLIMAN = "Breast Cancer - Low Risk" ;
		end ;
		ELSE DO ;
			CANCER_TYPE_MILLIMAN = "Breast Cancer - High Risk" ;
		END ;
	END ;

	***CMS Cancer Type;
	IF CANCER_TYPE = "Bladder Cancer" THEN DO ; 	
		IF LOW_RISK_BLAD=1 THEN DO;
			CANCER_TYPE= "Bladder Cancer - Low Risk" ;	
		end ;
		ELSE DO ;
			CANCER_TYPE= "Bladder Cancer - High Risk" ;
		END ;
	END ;

	IF CANCER_TYPE = "Prostate Cancer" then do ;
		IF CAST_SENS_PROS = 1 THEN DO ;
			CANCER_TYPE = "Prostate Cancer - Low Intensity" ;
		end ;
		ELSE DO ;
			CANCER_TYPE= "Prostate Cancer - High Intensity" ;
		END ;
	END ;

	IF CANCER_TYPE= "Breast Cancer" then do ;
		IF PTD_CHEMO = 1 THEN DO ;
			CANCER_TYPE = "Breast Cancer - Low Risk" ;
		end ;
		ELSE DO ;
			CANCER_TYPE = "Breast Cancer - High Risk" ;
		END ;
	END ;

run ;

proc sql ;
	create table epipre2 as
	select a.*, b.recon_elig
	from epipre_a as a left join r1.epi_&ds. as b
	on a.bene_id = b.bene_id and
	   a.ep_id_cms = b.ep_id  ;
quit ;

data epipre2 ; 
	set epipre2 ;
		IF CANCER_TYPE_MILLIMAN IN ('Acute Leukemia','Anal Cancer','Bladder Cancer',
									'Breast Cancer','Breast Cancer - Low Risk','Breast Cancer - High Risk',
								    'Chronic Leukemia','CNS Tumor','Intestinal Cancer',
									'Small Intestine / Colorectal Cancer',
								    'Endocrine Tumor','Female GU Cancer other than Ovary',
									'Gastro/Esophageal Cancer','Head and Neck Cancer','Kidney Cancer','Liver Cancer',
									'Lung Cancer','Lymphoma','Malignant Melanoma','MDS','Multiple Myeloma',
									'Ovarian Cancer', 'Pancreatic Cancer','Prostate Cancer',"Bladder Cancer - Low Risk",
									"Bladder Cancer - High Risk","Prostate Cancer - Low Intensity",
									"Prostate Cancer - High Intensity") THEN RECON_ELIG_MILLIMAN = "1" ;
		ELSE RECON_ELIG_MILLIMAN = "0" ;


data r2.episode_Interface_&bl._&ds ;
	retain OCM_ID BENE_ID BENE_HICN FIRST_NAME LAST_NAME PATIENT_NAME SEX 
		   PATIENT_SEX DOB AGE DOD ZIPCODE EP_ID EP_ID_CMS EPI_COUNTER EP_BEG EP_END EP_LENGTH
		   CANCER_TYPE RECON_ELIG DUAL_PTD_LIS INST RADIATION HCC_GRP
		   HRR_REL_COST SURGERY CLINICAL_TRIAL BMT CLEAN_PD PTD_CHEMO
		   ACTUAL_EXP BASELINE_PRICE EXPERIENCE_ADJ CANCER_TYPE_MILLIMAN
		   RECON_ELIG_MILLIMAN DUAL_PTD_LIS_MILLIMAN INST_MILLIMAN RADIATION_MILLIMAN
		   HCC_GRP_MILLIMAN HRR_REL_COST_MILLIMAN SURGERY_MILLIMAN CLINICAL_TRIAL_MILLIMAN
		   PTD_CHEMO_MILLIMAN BMT_MILLIMAN
		   ALLOWED_MILLIMAN  BASELINE_PRICE_MILLIMAN IP_UTIL SNF_UTIL
		   HH_UTIL HSP_UTIL FAC_UTIL CHEMO_D_UTIL CHEMO_B_UTIL PROF_UTIL DRUG_UTIL RAD_ONC_UTIL
		   CHEMO_DAYS_PARTB	RAD_ONC_DAYS CHEMO_LENGTH_PARTB RAD_ONC_LENGTH IP_MED_CHEMO_UTIL
		   IP_MED_NON_CHEMO_UTIL IP_SURG_CHEMO_UTIL IP_SURG_NON_CHEMO_UTIL IP_OTHER_UTIL
		   OUT_SURG_CANCER_UTIL OUT_SURG_NONCANCER_UTIL ANTI_EMETICS_UTIL
		   HEMOTAPOETIC_UTIL OTHER_DRUGS_UTIL CHEMO_ADMIN_UTIL RAD_HTECH_UTIL RAD_OTHER_UTIL
		   LAB_UTIL PROF_IP_UTIL PROF_SURGERY_UTIL PROF_ANESTHESIA_UTIL PROF_OTHER_UTIL DME_UTIL OTHER_UTIL
		   ER_UG_OBS_UTIL OUT_SURG_UTIL OUT_OTHER_UTIL OP_UTIL 
		   PROF_OFFICE_UTIL EM_ATT_VISIT_UTIL EM_OTH_VISIT_UTIL PROF_ER_UTIL OTHER_UTIL CHEMO_ADJ_UTIL
		   CHEMO_D_CYTO_UTIL CHEMO_B_CYTO_UTIL CHEMO_D_BIO_UTIL CHEMO_B_BIO_UTIL CHEMO_D_HARM_UTIL 
		   CHEMO_B_HARM_UTIL CHEMO_D_OTH_UTIL CHEMO_B_OTH_UTIL CHEMO_UTIL_TYPE RAD_MRI_UTIL RAD_CT_UTIL RAD_PET_UTIL EPI_TAX_ID EPI_NPI_ID 
		   ER_VISITS_MILLIMAN DIED_MILLIMAN HSP_30DAYS_ALL_MILLIMAN ANY_HSP_CARE_MILLIMAN HSP_DAYS_MILLIMAN  
			HOSPITAL_USE_MILLIMAN
		   ICU_MILLIMAN CHEMOTHERAPY_MILLIMAN OCM1 OCM2 OCM3 IP_FROM_ED_UTIL IP_FROM_ED 
			SNF_COUNT HH_COUNT ER_COUNT ADMIT_COUNT CHEMOPB_ALLOWED CHEMOPD_ALLOWED ANTIEMETICS_ALLOWED
			HEMATOPOIETIC_ALLOWED OTHRX_ALLOWED RADLAB_ALLOWED  PROF_ALLOWED IP_ALLOWED ER_ALLOWED
			OP_ALLOWED HOSPICE_ALLOWED HH_ALLOWED SNF_ALLOWED IP_LOS 
			ER_WEEKEND ER_WEEKEND_COUNT M_EPI_SOURCE_FINAL EM_ATT_TAX EM_NONATT_TAX EPI_TIN_MATCH READ_COUNT

 			EPISODE_PERIOD CHEMOPB_std CHEMOPD_std ANTIEMETICS_std HEMATOPOIETIC_std 
		    OTHRX_std RADLAB_std  
			PROF_std IP_std ER_std OP_std HOSPICE_std SNF_std HH_std ACTUAL_EXP_STD_MILLIMAN
		    DIED_IN_HOSP EM_ATT_VISIT_UTIL_CHK EM_OTH_VISIT_UTIL_CHK

			INDEX_ADMIT_COUNT READMISSION_COUNT;

	SET EPIPRE2 ;

	KEEP OCM_ID BENE_ID BENE_HICN FIRST_NAME LAST_NAME PATIENT_NAME SEX 
		   PATIENT_SEX DOB AGE DOD ZIPCODE EP_ID EP_ID_CMS EPI_COUNTER EP_BEG EP_END EP_LENGTH
		   CANCER_TYPE RECON_ELIG DUAL_PTD_LIS INST RADIATION HCC_GRP
		   HRR_REL_COST SURGERY CLINICAL_TRIAL BMT CLEAN_PD PTD_CHEMO 
		   ACTUAL_EXP BASELINE_PRICE EXPERIENCE_ADJ CANCER_TYPE_MILLIMAN
		   RECON_ELIG_MILLIMAN DUAL_PTD_LIS_MILLIMAN INST_MILLIMAN RADIATION_MILLIMAN
		   HCC_GRP_MILLIMAN HRR_REL_COST_MILLIMAN SURGERY_MILLIMAN CLINICAL_TRIAL_MILLIMAN
		   PTD_CHEMO_MILLIMAN BMT_MILLIMAN 
			ALLOWED_MILLIMAN BASELINE_PRICE_MILLIMAN IP_UTIL SNF_UTIL
		   HH_UTIL HSP_UTIL FAC_UTIL CHEMO_D_UTIL CHEMO_B_UTIL PROF_UTIL DRUG_UTIL RAD_ONC_UTIL
		   CHEMO_DAYS_PARTB	RAD_ONC_DAYS CHEMO_LENGTH_PARTB RAD_ONC_LENGTH IP_MED_CHEMO_UTIL
		   IP_MED_NON_CHEMO_UTIL IP_SURG_CHEMO_UTIL IP_SURG_NON_CHEMO_UTIL IP_OTHER_UTIL
		   OUT_SURG_CANCER_UTIL OUT_SURG_NONCANCER_UTIL ANTI_EMETICS_UTIL
		   HEMOTAPOETIC_UTIL OTHER_DRUGS_UTIL CHEMO_ADMIN_UTIL RAD_HTECH_UTIL RAD_OTHER_UTIL
		   LAB_UTIL PROF_IP_UTIL PROF_SURGERY_UTIL PROF_ANESTHESIA_UTIL PROF_OTHER_UTIL DME_UTIL OTHER_UTIL
		   ER_UG_OBS_UTIL OUT_SURG_UTIL OUT_OTHER_UTIL OP_UTIL 
		   PROF_OFFICE_UTIL EM_ATT_VISIT_UTIL EM_OTH_VISIT_UTIL PROF_ER_UTIL OTHER_UTIL  CHEMO_ADJ_UTIL
		   CHEMO_D_CYTO_UTIL CHEMO_B_CYTO_UTIL CHEMO_D_BIO_UTIL CHEMO_B_BIO_UTIL CHEMO_D_HARM_UTIL 
		   CHEMO_B_HARM_UTIL CHEMO_D_OTH_UTIL CHEMO_B_OTH_UTIL CHEMO_UTIL_TYPE 		   
		   RAD_MRI_UTIL RAD_CT_UTIL RAD_PET_UTIL EPI_TAX_ID EPI_NPI_ID ER_VISITS_MILLIMAN 
		   DIED_MILLIMAN HSP_30DAYS_ALL_MILLIMAN ANY_HSP_CARE_MILLIMAN HSP_DAYS_MILLIMAN  HOSPITAL_USE_MILLIMAN
		   ICU_MILLIMAN CHEMOTHERAPY_MILLIMAN OCM1 OCM2 OCM3 IP_FROM_ED_UTIL IP_FROM_ED
			SNF_COUNT HH_COUNT ER_COUNT ADMIT_COUNT CHEMOPB_ALLOWED CHEMOPD_ALLOWED ANTIEMETICS_ALLOWED
			HEMATOPOIETIC_ALLOWED OTHRX_ALLOWED RADLAB_ALLOWED  PROF_ALLOWED IP_ALLOWED ER_ALLOWED
			OP_ALLOWED HOSPICE_ALLOWED HH_ALLOWED SNF_ALLOWED IP_LOS 
			ER_WEEKEND ER_WEEKEND_COUNT M_EPI_SOURCE_FINAL EM_ATT_TAX EM_NONATT_TAX EPI_TIN_MATCH READ_COUNT 

 			EPISODE_PERIOD CHEMOPB_std CHEMOPD_std ANTIEMETICS_std HEMATOPOIETIC_std 
		    OTHRX_std RADLAB_std  
			PROF_std IP_std ER_std OP_std HOSPICE_std SNF_std HH_std ACTUAL_EXP_STD_MILLIMAN 
			DIED_IN_HOSP EM_ATT_VISIT_UTIL_CHK EM_OTH_VISIT_UTIL_CHK

			INDEX_ADMIT_COUNT READMISSION_COUNT;

DATA CLAIMS ;
	SET R2.ALL_CLAIMS_&bl._&DS.(RENAME = (EP_ID=EP_ID_CMS)) ;
PROC SQL ;
	CREATE TABLE CLAIMS2 AS
	SELECT A.*, B.EP_ID 
	FROM CLAIMS AS A, EPIPRE2 AS B
	WHERE A.BENE_ID=B.BENE_ID AND A.EP_ID_CMS=B.EP_ID_CMS ;
QUIT ;

data r2.CLAIMS_Interface_&bl._&ds ;
	RETAIN OCM_ID EP_ID CLAIM_ID START_DATE END_DATE NOVEL_THERAPY PRVDR_NUM ADMIT_DT DSCHRG_DT
		   AT_NPI OP_NPI DRG_CD ADMIT_DIAG_CD PRINCIPAL_DIAG_CD PROCEDURE_CD LOS STUS_CD VISITCNT 
		   HCFASPCL PRFNPI HCPCS_CD NDC REV_CNTR PRSCRBR_ID PART_D_SERVICE_DATE FILL_NUM DAYS_SUPPLY LABEL1
		   LABEL2 ALLOWED TOT_RX_CST_AMT ER_WEEKEND ER_WEEKEND_COUNT IP_ER_CASE READMIT_FLAG READ_COUNT
		   UNITS_DOSE STD_PAY INDEX_ADMIT UNPLANNED_READMIT_FLAG HAS_READMISSION IP_CASE
		   TAX_NUM TAXNUM_TIN ;
	SET CLAIMS2 ;
	KEEP OCM_ID EP_ID CLAIM_ID START_DATE END_DATE NOVEL_THERAPY PRVDR_NUM ADMIT_DT DSCHRG_DT
		   AT_NPI OP_NPI DRG_CD ADMIT_DIAG_CD PRINCIPAL_DIAG_CD PROCEDURE_CD LOS STUS_CD VISITCNT 
		   HCFASPCL PRFNPI HCPCS_CD REV_CNTR NDC PRSCRBR_ID PART_D_SERVICE_DATE FILL_NUM DAYS_SUPPLY LABEL1
		   LABEL2 ALLOWED TOT_RX_CST_AMT ER_WEEKEND ER_WEEKEND_COUNT IP_ER_CASE READMIT_FLAG READ_COUNT
		   UNITS_DOSE STD_PAY INDEX_ADMIT UNPLANNED_READMIT_FLAG HAS_READMISSION IP_CASE
		   TAX_NUM TAXNUM_TIN ;
run ;

*** Removal of episodes not found in claims interface file. *** ;
proc sort data=r2.episode_Interface_&bl._&ds out = e ; by ep_id ;
proc sort data= claims2; by ep_id ;
data check2 ;
	merge e(in=a) claims2(in=b keep=ep_id) ; by ep_id ;
	if a and b=0 then output ; 

data r2.episode_Interface_&bl._&ds ;
	merge e(in=a) check2(in=b keep=ep_id) ; by ep_id ;
	if a and b=0 ;

*** AUGUST 2018 CHANGE CHECKS *** ;

	PROC PRINT DATA=r2.episode_Interface_&bl._&ds (OBS=10) ;
	WHERE INDEX_ADMIT_COUNT < READMISSION_COUNT ; 
	title " CHeck to make sure readmission count is always less than index admit counts" ;RUN ;

	*** NOTE: Check1 should report 0 records ;
	data check1 ;
	set R2.EPISODE_INTERFACE_&bl._&ds  ;
	if cancer_type_milliman = "  " ; run ;

	proc freq data=R2.CLAIMS_INTERFACE_&bl._&ds  ;		
	tables index_admit*has_readmission*UNPLANNED_READMIT_FLAG/list missing ;
	TITLE "&DS. - LOOK FOR MISSING INDEX ADMIT WITH VALUES IN HAS_READMISSION FLAG" ; run ;

	PROC MEANS DATA=R2.episode_Interface_&bl._&ds SUM ;
		VAR INDEX_ADMIT_COUNT READMISSION_COUNT ;
	TITLE "LOOKING AT COMPARISON OF INDEX COUNT AND READMISSION COUNT" ; run ;

	data ip ;
		set R2.CLAIMS_INTERFACE_&bl._&ds  ; 
		if index_admit = 1 ;
	proc sort data=ip nodupkey ; by ep_id ip_case ;
	proc means data=ip sum ;
		var index_admit ;
	title "Index Admissions in Claims File" ; run ;
run ;


%MEND sc ; 
**************************************************************************** ;
**************************************************************************** ;

%let att_tin = '454999975' ; run ;
%SC(255_50179,255) ; run ;

%let att_tin = '636000526' ;run ;
%SC(257_50195,257) ; run ;

%let att_tin = '134290167' ;run ;
%SC(278_50193,278) ; run ;

%let att_tin = '731310891' ;run ;
%SC(280_50115,280) ; run ;

%let att_tin = '540647482','540793767','541744931','311716973' ;run ;
%SC(290_50202,290) ; run ;

%let att_tin = '571004971' ;run ;
%SC(396_50258,396) ; run ;

%let att_tin = '205485346' ;run ;
%SC(401_50228,401) ; run ;

%let att_tin = '204881619' ;run ;
%SC(459_50243,459) ; run ;

%let att_tin = '621490616' ;run ;
%SC(468_50227,468) ; run ;

%let att_tin = '201872200' ;run ;
%SC(480_50185,480) ; run ;

%let att_tin = '596014973' ;run ;
%SC(523_50330,523) ; run ;

%let att_tin = '223141761' ;run ;
%SC(137_50136,137) ; run ;

RUN ;
/*


proc freq data=ipr_final ;
	tables has_readmission UNPLANNED_READMIT_FLAG/list missing ; run ;

proc means data= R2.SC_IP_BLV2_257_50195 noprint max ; by BENE_ID EP_ID IP_CASE ;
	var index_count readm_count 
	
	IF B=0 THEN DO ;
		INDEX_ADMIT = 0 ;
		UNPLANNED_READMIT_FLAG = 0 ;
	END ;
	IF FIRST.IP_CASE THEN DO ;
		READM_COUNT = UNPLANNED_READMIT_FLAG ;
		INDEX_COUNT = INDEX_ADMIT;
	END ;

	*** Only assigning latest claim of a case to HAS_READMISSION - all other lines in flagged case = 9 **** ;
	*** Only assigning earliest claim of a case to UNPLANNED_READMIT_FLAG - all other lines in flagged case = 9 **** ;
	IF FIRST.IP_CASE NE 1 OR LAST.IP_CASE NE 1 THEN DO ;
		IF LAST.IP_CASE NE 1 THEN HAS_READMISSION = 9 ;
		IF FIRST.IP_CASE NE 1 THEN UNPLANNED_READMIT_FLAG = 9 ;
	END ;

PROC PRINT DATA=R2.SC_IP_BLV2_257_50195 ;
	*WHERE HAS_READMISSION = 9 ; 
	WHERE BENE_ID = "34318206" AND IP_CASE = 1 ; 
RUN ;*/
