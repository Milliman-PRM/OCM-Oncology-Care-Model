********************************************************************** ;
		***** 053_Service_Categories.sas ***** ;
*********************************************************************** ;

libname r1 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\08 - Benchmark Data\BM2 - 5pct Benchmark Files" ;
libname r2 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\08 - Benchmark Data\BM2 - 5pct Benchmark Files"  ;

options ls=132 ps=70 obs=max mprint mlogic obs=MAX; 
********************************************************************** ;
********************************************************************** ;

*** Initiating therapy lists *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats PP4.sas" ;
*** Cancer diagnosis code lists *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Cancer Formats PP3.sas" ;
*** Cancer assignment macro  *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Cancer Diagnoses_5.sas" ;
*** Service Categories *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Service_Categories_v2.sas" ;
*** Predictive Model Variable Development  *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Predict_Flags PP3.sas" ;
*** Inpatient Allowed Amount Calculation Needs *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000 - CMMI - Formats - Hemophilia Clotting Factors.sas" ; 
run ;
*** Novel Therapy *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Novel Therapy.sas" ;
*** For breast cancer distinction *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Breast_Hormonal.sas" ; run ;

/*
%include "H:\OCM - Oncology Care Model\Work Papers\SAS\000_Formats_AHRQ.sas" ;run ;
run ;
*/
********************************************************************** ;
********************************************************************** ;

%let bl = BM3 ; 
%let bla = BM ; 
%let ds = 5PCT ;
%let daterun = 20190205 ;
run ;


%macro sc; 
*** For End of Life Metrics *** ;
proc sort data=r2.epi_prelim_&bl._&ds. OUT=epi1  (KEEP = EP_ID desy_sort_key EP_BEG EP_END CANCER_type_milliman) ; 
	BY desy_sort_key ep_beg ep_end;
proc sort data=r2.episode_candidates out=epi2 (keep = desy_sort_key ep_beg ep_end DOD AGE age_16) ; by desy_sort_key ep_beg ep_end;

data EPI_DOD ;
	merge epi1(in=a) epi2(in=b) ; by desy_sort_key ep_beg ep_end;
	if a ;
	cancer = cancer_type_milliman ;
**************************************************************************************
*************************** IP COST MODEL LOGIC ***************************************
***************************************************************************************;

PROC SORT DATA=R2.check_ipop_&bla._&ds. OUT=IPOP ; BY desy_sort_key EP_BEG EP_END claim_no ;
PROC MEANS DATA=IPOP NOPRINT MAX ; BY desy_sort_key EP_BEG EP_END claim_no;
	VAR /*BMT_ALLOGENEIC_AK BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL 
		BMT_AUTOLOGOUS_AK BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL */
		ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY 
		LIVER_SURGERY LUNG_SURGERY OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY ;
	OUTPUT OUT=IPOP_FLAGS (DROP = _TYPE_ _FREQ_)
		   MAX() = ;

%macro IP ;

DATA ICU ;
	SET r2.inpatient_&bla._&ds. ;
	IF REV_CNTR IN ('0200','0201','0202','0203','0204','0206','0207','0208','0209') THEN ICU = 1 ;
PROC SORT DATA=ICU ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO ;
PROC MEANS DATA=ICU NOPRINT MAX ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO ;
	VAR ICU ;
	OUTPUT OUT=ICU_FLAGS (DROP = _TYPE_ _FREQ_)
		   MAX() = ;

data iphdr_clean ;
	MERGE ICU(IN=A DROP=ICU) ICU_FLAGS(IN=B) ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO ;
	IF A AND B ;
	if first.CLAIM_NO THEN OUTPUT ;

proc sql ;
	create table ip1a as
	select a.*, b.*
	from iphdr_clean as a, epi_dod as b
	where a.desy_sort_key=b.desy_sort_key and
		  A.EP_BEG = B.EP_BEG AND
		  A.EP_END = B.EP_END and
		  b.ep_beg le admsn_dt le b.ep_end ;
quit ;

proc sort data=ip1a ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO ;
data SC_ip_&bl._&ds. ;
	MERGE IP1A(IN=A where = (nopay_cd = "   " ))
		  IPOP_FLAGS ;
	BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO ;
	if a ;

	allowed = sum(PMT_AMT,(PER_DIEM*UTIL_DAY)) ; 

	**** Initializing Service Category **** ;
	FORMAT Service_CAT $50.; length Service_CAT $50. ; 
	Service_CAT = "    " ;

	%CANC_INIT ; HAS_CANCER = 0 ;

		%canc_init ; 
		ARRAY v (I) ICD_DGNS_VRSN_CD1 ;
		ARRAY d (I) ICD_DGNS_CD1 ;
		DO I = 1 TO 1 ;
			if v = " " then v = "0" ;
			%CANCERTYPE(v, d) ;
		END ;
		has_cancer_primary = has_cancer ;

		%canc_init ; has_cancer = 0 ;
		ARRAY v2 (l) ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD25 ;
		ARRAY d2 (l) ICD_DGNS_CD1-ICD_DGNS_CD25 ;
		DO l = 1 TO dim(d2) ;
			if v2 = " " then v2e = "0" ;
			%CANCERTYPE(v2, d2) ;
		end ;


		if CANCER_TYPE_milliman ne "Breast Cancer" then BREAST_SURGERY = 0 ;
		if CANCER_TYPE_milliman ne "Anal Cancer" then ANAL_SURGERY = 0 ;
		if CANCER_TYPE_milliman ne "Liver Cancer" then LIVER_SURGERY = 0 ;
		if CANCER_TYPE_milliman ne "Lung Cancer" then LUNG_SURGERY = 0 ;
		if CANCER_TYPE_milliman ne "Bladder Cancer" then BLADDER_SURGERY = 0 ;
		if CANCER_TYPE_milliman ne "Female GU Cancer other than Ovary" then FEMALEGU_SURGERY = 0 ;
		if CANCER_TYPE_milliman ne "Gastro/Esophageal Cancer" then GASTRO_SURGERY = 0 ;
		if CANCER_TYPE_milliman ne "Head and Neck Cancer" then HEADNECK_SURGERY = 0 ;
		if CANCER_TYPE_milliman ne "Small Intestine / Colorectal Cancer" then INTESTINAL_SURGERY = 0 ;
		if CANCER_TYPE_milliman ne "Ovarian Cancer" then OVARIAN_SURGERY = 0 ;
		if CANCER_TYPE_milliman ne "Prostate Cancer" then PROSTATE_SURGERY = 0 ;
		if CANCER_TYPE_milliman ne "Pancreatic Cancer" then PANCREATIC_SURGERY = 0 ;
		if CANCER_TYPE_milliman ne "Kidney Cancer" then KIDNEY_SURGERY = 0 ;

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

		
		DROP I L;

	if substr(provider,3,1) in ('R','T') then SERVICE_CAT = "Inpatient: Other" ;
	else if anyalpha(substr(provider,3,4)) = 0 and '3025' <= substr(provider,3,4) and substr(provider,3,4) <= '3099' then SERVICE_CAT = "Inpatient: Other" ;
	ELSE if DRG_CD in ('945','946') then type='Inpatient: Other';
	if '2000' <= substr(provider,3,4) and substr(provider,3,4) <= '2299' then type='Inpatient: Other';
    if drg_cd in ('945','946') then SERVICE_CAT = "Inpatient: Other" ;

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

	
	if service_cat = "  "  then do;
				SERVICE_CAT = "Inpatient Medical" ;
	end ;

					*** End of Life variables *** ;
		IP_CAH = 0 ; IP_CHEMO_ADMIN = 0 ; 
		IF ('0001' LE SUBSTR(PROVIDER,3,4) LE '0879') OR 
		   ('1300' LE SUBSTR(PROVIDER,3,4) LE '1399') THEN IP_CAH = 1 ;

		IF PRNCPAL_DGNS_CD IN ('V5811', 'V5812', 'Z5111', 'Z5112') THEN IP_CHEMO_ADMIN = 1 ; *** Source: OCM ticket 787031 - with file attached OCM-1+Measure+Specifications *** ;
		/*
		IP_BMT_AK = MAX(BMT_ALLOGENEIC_AK,BMT_AUTOLOGOUS_AK) ;
	    IP_BMT_L = MAX( BMT_ALLOGENEIC_L,BMT_AUTOLOGOUS_L) ;
		IP_BMT_MM = MAX(BMT_ALLOGENEIC_MM,BMT_AUTOLOGOUS_MM) ;
	    IP_BMT_MDS = MAX(BMT_ALLOGENEIC_MDS,BMT_AUTOLOGOUS_MDS) ;
	    IP_BMT_CL = MAX(BMT_ALLOGENEIC_MDS,BMT_AUTOLOGOUS_CL) ;
		*/
		***************************************************** ;
		FORMAT WIN_30_DOD MMDDYY10. ;
		WIN_30_DOD = INTNX('DAY',DOD,-29,'SAME') ;
		IF IP_CAH = 1 THEN DO ;
			IF (WIN_30_DOD LE ADMSN_DT LE DOD) THEN IP_ALLCAUSE_30 = 1 ; 
		END;
		IF ICU = 1 THEN DO ;
			IF (WIN_30_DOD LE ADMSN_DT LE DOD) THEN IP_ICU_30 = 1 ; 
		END ;
		IF DOD NE . AND IP_ALLCAUSE_30 NE 1 THEN IP_ALLCAUSE_30 = 0 ;
		IF DOD NE . AND IP_ICU_30 NE 1 THEN IP_ICU_30 = 0 ;
		******************************************************* ;

		if IP_CAH = 1 AND ((ADMSN_DT LE DOD LE DSCHRGDT) OR STUS_CD = "20" )then died_in_hosp = 1 ;


		DROP HAS_CANCER %canc_flags 
			 /*BMT_ALLOGENEIC_AK BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL 
			 BMT_AUTOLOGOUS_AK BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL */
			 ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY GASTRO_SURGERY HEADNECK_SURGERY 
			 INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
			 OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY DOD;

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
PROC SORT DATA =ACUTE ; by DESY_SORT_KEY EP_BEG EP_END ADMSN_DT DSCHRGDT ;

DATA ACUTE2 ;
	SET ACUTE ; BY DESY_SORT_KEY EP_BEG EP_END ADMSN_DT ;
	FORMAT PREV_ADM  PREV_DIS MMDDYY10. ;
	IF FIRST.DESY_SORT_KEY THEN DO ;
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
PROC SORT DATA=NONACUTE ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO ;
DATA NONACUTE2 ;
	SET NONACUTE ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO ;
	IF FIRST.EP_END THEN DO ;
		IP_CASE = 1001 ;
		PREV_CASE = IP_CASE ;
		PREV_CLM = CLAIM_NO ;
	END ;
	ELSE DO ;
		IF CLAIM_NO = PREV_CLM THEN IP_CASE = PREV_CASE ;
		ELSE IP_CASE = SUM(PREV_CASE,1) ;
		PREV_CASE = IP_CASE ;
		PREV_CLM = CLAIM_NO ;
	END ;

	RETAIN PREV_CASE PREV_CLM ;
	

*** Step I4: Set flags by case *** ;
*** Per OCM Ticket response 798221: Inpatient expenditure amounts are assigned on a claim basis using the ADMSN_DT. If a transfer or 
    overlapping/nested hospitalization has an ADMSN_DT within the quarter, then its expenditures are included in the Inpatient categories.
	The combined inpatient stay would be counted in both utilization categories. This applies to any of the variations on the inpatient 
	admissions utilization measure. If one claim of the combined stay satisfies the criteria for the admissions measure, then the entire 
	stay is considered to satisfy the criteria. If multiple criteria are met, then the stay is counted in the multiple utilization categories. *** ;
DATA ALL ; SET ACUTE2 NONACUTE2 ;
proc sort data=all ; BY DESY_SORT_KEY EP_BEG EP_END  IP_CASE ;
proc means data=all noprint max ; BY DESY_SORT_KEY EP_BEG EP_END  ip_case ;
	var ip_cah ip_chemo_admin IP_ALLCAUSE_30 IP_ICU_30
		/*IP_BMT_AK IP_BMT_L IP_BMT_MM IP_BMT_MDS IP_BMT_CL */SIP_ANAL SIP_BLADDER SIP_BREAST SIP_FEMALEGU 
		SIP_GASTRO SIP_HN SIP_INT SIP_LIVER SIP_LUNG SIP_OVARIAN SIP_PROSTATE SIP_PANCREATIC SIP_KIDNEY ;
	output out=case_level (drop = _type_ _freq_)
		   max() =  ip_cah_case ip_chemo_admin_case 
					IP_ALLCAUSE_30_case IP_ICU_30_case /*IP_BMT_AK_case IP_BMT_L_case IP_BMT_MM_case 
					IP_BMT_MDS_case*/ SIP_ANAL_case SIP_BLADDER_case SIP_BREAST_case SIP_FEMALEGU_case 
					SIP_GASTRO_case SIP_HN_case SIP_INT_case SIP_LIVER_case SIP_LUNG_case SIP_OVARIAN_case
					SIP_PROSTATE_case SIP_PANCREATIC_case SIP_KIDNEY_CASE;


*** Step I5: Create final file. *** ;

DATA r2.SC_ip_&bl._&ds.  ;
	merge ALL(in=a) 
           case_level(in=b) ; 
		   BY DESY_SORT_KEY EP_BEG EP_END IP_CASE ;

PROC SORT DATA=r2.SC_ip_&bl._&ds. ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO ;


			 /*	
PROC FREQ DATA=r2.SC_ip_&bl._&ds. ; TABLES SERVICE_CAT ; 
title 'Inpatient Service Category Assignments'; run ;
*/

%mend IP ;


**************************************************************************************
*************************** OP COST MODEL LOGIC ***************************************
***************************************************************************************;
%MACRO OP ;

**** Identify ER claims **** ;
	
data er clms ;
	set R2.OUTPATIENT_&bla._&ds.(WHERE = (NOPAY_CD = "  ")) ;
	IF EP_BEG LE REV_DT LE EP_END ;

	*ALLOWED =SUM(REVPMT,PTNTRESP);
	ALLOWED = REVPMT ;
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
			if v = " " then v = "0" ;
			if v = "9" and put(d,$Chemo_Sens_ICD9_.) = "Y" then chemosens1 = 1 ;
		END ;
		has_cancer_primary = has_cancer ;

		%canc_init ; has_cancer = 0 ;

		ARRAY v2 (l) ICD_DGNS_VRSN_CD2-ICD_DGNS_VRSN_CD25 ;
		ARRAY d2 (l) ICD_DGNS_CD2-ICD_DGNS_CD25 ;
		DO l = 1 TO dim(d2) ;
			if v2 = " " then v2 = "0" ;
		END ;
		DROP I L;
		DROP HAS_CANCER %canc_flags ;

		*** 5/31/17 - Using OCM identification of ED and OBS, Not Milliman algorithm *** ;
		er_pre=0 ; OBS_PRE=0 ; /*UC_PRE=0 ;*/ ER_CHEM_PRE = 0 ; OBS_CHEM_PRE = 0 ; 
				IF '0450' LE REV_CNTR LE '0459' OR REV_CNTR = '0981' THEN DO ;
						IF REV_CHRG - REV_NCVR > 0  THEN DO ;
							ER_pre = 1 ;
							IF "70000" LE HCPCS_CD LE "89999" OR 
							    HCPCS_CD IN ('G0106','G0120','G0122','G0130','G0202','G0204','G0206','G0219',
											 'G0235','G0252','G0255','G0288','G0389','S8035','S8037','S8040',
											 'S8042','S8080','S8085','S8092','S9024') THEN ER_pre = 0 ;
						END ;
				END ;
	   
				IF REV_CNTR = '0762' OR
				  (REV_CNTR = '0760' AND HCPCS_CD = "G0378" AND REV_UNIT GE 8) THEN DO ;
						IF REV_CHRG - REV_NCVR > 0  THEN DO ;
							OBS_PRE = 1 ;
				  	END ;
				END ;



	if (er_Pre = 1 or obs_pre = 1 ) then output er;
	output clms ;

run ;

proc sort data=er ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO thru_dt rev_dt;
proc means data=er noprint max ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO thru_dt  rev_dt;
	var er_chem_pre er_pre obs_chem_pre obs_pre  ;
	output out=erclms (drop = _type_ _freq_)
		   max() = ;
run ;


proc sort data=clms ; by DESY_SORT_KEY EP_BEG EP_END CLAIM_NO thru_dt rev_dt; 
data r2.SC_op_&bl._&ds. ;
	merge clms(in=a drop=er_pre obs_pre er_chem_pre obs_chem_pre )	
		  erclms(in=b keep=DESY_SORT_KEY EP_BEG EP_END CLAIM_NO thru_dt rev_dt er_chem_pre er_pre obs_chem_pre obs_pre /*uc_chem_pre uc_pre*/) ; 
	BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO thru_dt rev_dt;
	if a ;

	***  5/4/17: Chemotherapy, Drug and Rad Once Assignments Overrides any other Non-IP assignment. *** ;
	if put(hcpcs_cd,$Chemo_J4p.) = 'Y' then do ;
		SERVICE_CAT = 'Chemotherapy Drugs (Part B)';
		BLAD_LR = 0 ; PROST_CAST = 0 ; BLAD_OTH = 0 ; PROST_OTH = 0 ;
		IF PUT(HCPCS_CD,$Bladder_LR_HCPCS.) = "Y" THEN BLAD_LR = 1 ;
		IF PUT(HCPCS_CD,$Prostate_CS_HCPCS.) = "Y" THEN PROST_CAST = 1 ;
		BC_Hormonal = 0 ;
		Nonhormonal = 1 ; 
	end ;

	*** Chemotherapy Categories *** ;
	else if put(hcpcs_cd,$anti.) = 'Y' then SERVICE_CAT = 'Anti-emetics' ;
	**************************************************************** ;
	else if put(hcpcs_cd,$chemo_admin.) = 'Y' then SERVICE_CAT = 'Chemotherapy Administration';
	else if put(rev_cntr,$addl_rev_chemo_admin.) = "Y" then SERVICE_CAT = 'Chemotherapy Administration';
	else if put(hcpcs_cd,$Hemat_agents_J.) = 'Y' then SERVICE_CAT = 'Hematopoietic Agents';
	else if put(hcpcs_cd,$adjuncts_hcpcs.) = 'Y' then SERVICE_CAT = 'Chemotherapy Adjuncts' ;

	else if put(hcpcs_cd,$RAD_ONC.) = 'Y' then SERVICE_CAT = 'Radiation Oncology';
	else if rev_cntr = '0333'  then SERVICE_CAT = 'Radiation Oncology';


	else if a and b then do ;
			SERVICE_CAT = "Emergency" ;
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


DATA PARTB ;
	set r1.PB_LINE(in=p) 
		r1.dme_line(in=d);
	if p then prof = 1 ; 
	if d then dme = 1 ;

proc sql ;
	create table  partba as
	select a.*, b.* 
	from partb as a, epi_dod as b
	where a.desy_sort_key = b.desy_sort_key and
		  b.ep_beg le a.expnsdt2 le b.ep_end ;
QUIT ;

**** Identify ER claims **** ;

DATA ER CLMS ;
	set partba ;
	allowed = LINEPMT ;
	if LALOWCHG > 0 ;  *** REMOVAL OF DENIED CLAIMS **** ;

	**** Initializing Service Category **** ;
	FORMAT SERVICE_CAT $50.; length SERVICE_CAT $50. ; 
	SERVICE_CAT = "    " ;

		er_pre=0 ; OBS_PRE=0 ; /*UC_PRE=0 ; */
		if put(HCPCS_CD,$ER_CPT.) = 'Y' then ER_pre = 1;
		if put(hcpcs_cd,$OBS_CPT.) = 'Y' then OBS_pre = 1 ;
		if put(hcpcs_cd,$UC.) = 'Y' then UC_pre = 1 ;

	if er_Pre = 1 or obs_pre = 1 or uc_pre = 1 then output er;
	output clms ; 

run ;

proc sort data=er ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO thru_dt EXPNSDT2 ;

proc means data=er noprint max ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO thru_dt EXPNSDT2 ;
	var er_pre obs_pre uc_pre ;
	output out=erclms (drop = _type_ _freq_)
		   max() = ;
run ;

*** 5/5/17: Identify unique ED dates of service to roll radiology claims occurring on same day into Professional: Emergency *** ;
proc sort data=er out=er_dos(keep=ep_id DESY_SORT_KEY EXPNSDT2 EP_BEG EP_END ) nodupkey ;
	BY DESY_SORT_KEY EP_BEG EP_END EXPNSDT2 ;

**** Identify OP Surgical claims **** ;
proc sort data=clms ; BY DESY_SORT_KEY EP_BEG EP_END EXPNSDT2;
data clms2 ;
	merge clms(in=a) er_dos(in=b) ; BY DESY_SORT_KEY EP_BEG EP_END  EXPNSDT2;
	if a ;
	format er_date mmddyy10. ;
	if b then er_date = EXPNSDT2 ;

proc sort data=clms2 ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO thru_dt EXPNSDT2;
data r2.SC_pb_&bl._&ds.  ;
	merge clms2(in=a drop=er_pre obs_pre uc_pre)	
		  erclms(in=b keep=DESY_SORT_KEY EP_BEG EP_END CLAIM_NO thru_dt EXPNSDT2 er_pre obs_pre uc_pre) ; 
	BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO thru_dt EXPNSDT2;
	if a ;

	***  5/4/17: Chemotherapy, Drug and Rad Once Assignments Overrides any other Non-IP assignment. *** ;
	if put(hcpcs_cd,$Chemo_J4p.) = 'Y' then do ;
		SERVICE_CAT = 'Chemotherapy Drugs (Part B)';
		BLAD_LR = 0 ; PROST_CAST = 0 ; BLAD_OTH = 0 ; PROST_OTH = 0 ;
		IF PUT(HCPCS_CD,$Bladder_LR_HCPCS.) = "Y" THEN BLAD_LR = 1 ;
		IF PUT(HCPCS_CD,$Prostate_CS_HCPCS.) = "Y" THEN PROST_CAST = 1 ;
		BC_Hormonal = 0 ;
		Nonhormonal = 1 ; 
	end ;
	*** Additional J Codes we believe are chemo - as per PP, HB  - Removed 5/4/17*** ;
	*ELSE IF hcpcs_cd in ("J0202","Q9979","J9165","J9213","J9214","J9250","J9260",
						 "J9270","J9300") then service_cat = 'Chemotherapy Drugs (Part B)';
	*** Chemotherapy Categories *** ;
	else if put(hcpcs_cd,$anti.) = 'Y' then SERVICE_CAT = 'Anti-emetics' ;
	else if put(hcpcs_cd,$chemo_admin.) = 'Y' then SERVICE_CAT = 'Chemotherapy Administration';
	else if put(hcpcs_cd,$Hemat_agents_J.) = 'Y' then SERVICE_CAT = 'Hematopoietic Agents';
	else if put(hcpcs_cd,$adjuncts_hcpcs.) = 'Y' then SERVICE_CAT = 'Chemotherapy Adjuncts' ;

	else if put(hcpcs_cd,$RAD_ONC.) = 'Y' then SERVICE_CAT = 'Radiation Oncology';

	else if a and b then do ;
		SERVICE_CAT = "Professional: Emergency" ;
	end ;

	if SERVICE_CAT = '' then do ;

			if plcsrvc = '21' then SERVICE_CAT = "Professional: Inpatient" ;
			else if put(hcpcs_cd,$P11_HCPCS.) = 'Y' then SERVICE_CAT = "Professional: Surgery" ;		
			else if put(hcpcs_cd,$P13_HCPCS.) = 'Y' then SERVICE_CAT = "Professional: Anesthesia" ;		
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
	if EXPNSDT2 = er_date and service_cat in ("Radiology: High Tech (MRI, CT, PET)","Radiology: Other") then 
			service_cat = "Professional: Emergency" ;

run ;

%mend pb ;

**************************************************************************************
********************* File Based Assignments, Part D *********************************
************************************************************************************** ;
%macro oth ;

PROC SORT DATA=r1.SNF_CLAIMS OUT=SNF1 (where = (nopay_cd="  ")) ; BY DESY_SORT_KEY ;

**** FROM_DT not available in 5% *** ;
proc sql ;
	create table snf1a as
	select a.*, b.*
	from snf1 as a, epi_dod as b
	where a.desy_sort_key=b.desy_sort_key and
		  b.ep_beg le a.ADMSN_DT le b.ep_end ;
quit ;
*** 5/4/2017 - Updated to roll SNF claims up to admission, not  claim level. *** ;
DATA SNF_CLAIMS ;
	set snf1a ;
	ADMIT_ID = DESY_SORT_KEY||PROVIDER||ADMSN_DT ;

PROC SORT DATA=SNF_CLAIMS ; BY DESY_SORT_KEY EP_BEG EP_END ADMIT_ID THRU_DT ;

DATA SNF_CHARS(DROP = UTIL_DAY PMT_AMT DSCHRGDT)  ;
	SET SNF_CLAIMS ; BY DESY_SORT_KEY EP_BEG EP_END ADMIT_ID THRU_DT ;
	IF LAST.ADMIT_ID ;
PROC MEANS DATA=SNF_CLAIMS NOPRINT MAX SUM ; BY DESY_SORT_KEY EP_BEG EP_END ADMIT_ID ;
	VAR DSCHRGDT UTIL_DAY PMT_AMT ;
	OUTPUT OUT=SNF_CLAIMS2 (DROP = _tYPE_ _FREQ_)
		   MAX(DSCHRGDT) = 
		   SUM(UTIL_DAY PMT_AMT) = ;

data r2.SC_snf_&bl._&ds. ;
	MERGE SNF_CHARS(IN=A) SNF_CLAIMS2(IN=B) ; BY DESY_SORT_KEY EP_BEG EP_END ADMIT_ID ;
	IF A AND B ;
	FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
	SERVICE_CAT = "SNF" ;
	*ALLOWED = sum(PMT_AMT, DED_AMT, COIN_AMT, BLDDEDAM);
	ALLOWED = PMT_AMT ;

*********************************************************************** ;
	**************** Hospice Metrics *************** ;
*********************************************************************** ;

*** 5/15/17 Capturing Facility and Non-Facility Flags **** ;
data HSPCODES ;
	SET r1.HOSP_REVENUE ;
	IF HCPCS_CD IN ('Q5003','Q5004','Q5005','Q5006','Q5007','Q5008','Q5010',
					'Q5001','Q5002') ;
	IF HCPCS_CD IN ('Q5003','Q5004','Q5005','Q5006','Q5007','Q5008','Q5010') THEN HSP_FAC = 1 ;
	ELSE HSP_FAC = 0 ;

	IF HCPCS_CD IN ('Q5001','Q5002') THEN HSP_HOME = 1 ; ELSE HSP_HOME = 0 ;

proc sql ;
	create table hcpcodes1 as
	select a.*, b.*
	from hspcodes as a, epi_dod as b
	where a.desy_sort_key=b.desy_sort_key and
		  b.ep_beg le a.rev_dt le b.ep_end ;
quit ;

DATA HSPCODES2 ;
	set hcpcodes1 ;
		FORMAT WIN_30_DOD MMDDYY10. ; 
		WIN_30_DOD = INTNX('DAY',DOD, -29, 'SAME') ;
			IF (WIN_30_DOD LE REV_DT LE DOD) THEN DO ;
			    HOSP_30DAYS = 1 ;
				HSP_FAC_30 = HSP_FAC ;
				HSP_HOME_30 = HSP_HOME ;
			END ;

PROC SORT DATA=HSPCODES2 ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO THRU_DT ;
PROC MEANS DATA=HSPCODES2 NOPRINT MAX ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO THRU_DT ;
	VAR HOSP_30DAYS HSP_FAC HSP_HOME HSP_FAC_30 HSP_HOME_30 ;
	OUTPUT OUT=HSP_FLAGS (DROP = _TYPE_ _FREQ_)
		   MAX() = ;

PROC SORT DATA=r1.HOSP_CLAIMS out=hosp1 ; BY DESY_SORT_KEY CLAIM_NO thru_dt ;
proc sort data=hsp_flags ; BY DESY_SORT_KEY CLAIM_NO thru_dt ;
data hosp2  ;
	merge hosp1(in=a) hsp_flags(IN=B) ; BY DESY_SORT_KEY CLAIM_NO thru_dt ;
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
proc sql ;
	create table hosp2a as
	select a.*, b.*
	from hosp2 as a, epi_dod as b
	where a.desy_sort_key=b.desy_sort_key and
		  a.ep_beg=b.ep_beg and
		  a.ep_end=b.ep_end ;

*** FROM_DT not available in the 5% *** ;
data hosp3 ;
	set hosp2a ;
	IF DOD NE . AND HSPCSTRT GE EP_BEG THEN DO ;
		FORMAT WIN_90_DOD WIN_30_DOD MMDDYY10. ; 
		WIN_90_DOD = INTNX('DAY',DOD, -89, 'SAME') ;
		WIN_30_DOD = INTNX('DAY',DOD, -29, 'SAME') ;
			IF (WIN_90_DOD LE HSPCSTRT LE DOD) OR
			   (WIN_90_DOD LE HSPCSTRT LE DOD)	THEN DO ;
				HOSP_DAYS_90 = SUM((THRU_DT - MAX(HSPCSTRT,WIN_90_DOD)),1) ;
			END ; 
			   

	END ;			

*** 5/4/2017 - Updated to roll Hospice claims up to period, not  claim level. *** ;
PROC SORT DATA=hosp3 OUT=HOSPICE ; BY DESY_SORT_KEY EP_BEG EP_END PROVIDER HSPCSTRT THRU_DT ;

DATA  HOSPICE2;
	SET HOSPICE ; BY DESY_SORT_KEY EP_BEG EP_END PROVIDER HSPCSTRT THRU_DT ;
	FORMAT PREV_THRU MMDDYY10. ;
	IF FIRST.PROVIDER THEN DO ; STAY = 1 ; PREV_THRU = THRU_DT ; END ;
	ELSE DO ;
		IF PREV_THRU NE . AND 0 LE (HSPCSTRT-PREV_THRU) LE 1 THEN STAY =STAY ;
		ELSE STAY = SUM(STAY,1) ;
		PREV_THRU = THRU_DT ;
	END ;
	RETAIN PREV_THRU STAY ; 

	FAC_PMT_AMT = PMT_AMT * HSP_FAC ;
	HOME_PMT_AMT = PMT_AMT * HSP_HOME ;
	IF HSP_FAC = 1 AND HSP_HOME = 1 THEN DO ;
		FAC_PMT_AMT = 0 ; HOME_PMT_AMT = 0 ; BOTH_PMT_AMT = PMT_AMT ; 
	END ;

PROC SORT DATA=HOSPICE2 ; BY DESY_SORT_KEY EP_BEG EP_END PROVIDER STAY HSPCSTRT THRU_DT ;

DATA HSP_CHAR(DROP = PMT_AMT HSPCSTRT ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME ANY_HSP_UNK
					 FAC_PMT_AMT HOME_PMT_AMT BOTH_PMT_AMT HOSP_30DAYS HOSP_DAYS_90 ) ;
	SET HOSPICE2 ; BY DESY_SORT_KEY EP_BEG EP_END PROVIDER STAY ;
	IF LAST.STAY ;


PROC MEANS DATA =HOSPICE2 NOPRINT MIN MAX SUM ; BY DESY_SORT_KEY EP_BEG EP_END PROVIDER STAY ;
	VAR HSPCSTRT ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME ANY_HSP_UNK HOSP_30DAYS
		PMT_AMT FAC_PMT_AMT HOME_PMT_AMT BOTH_PMT_AMT HOSP_DAYS_90 ;
	OUTPUT OUT=HSP_CLAIMS (DROP = _TYPE_ _FREQ_)
		   min(HSPCSTRT) = 
		   MAX(ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME ANY_HSP_UNK HOSP_30DAYS) = 
		   SUM(PMT_AMT FAC_PMT_AMT HOME_PMT_AMT BOTH_PMT_AMT HOSP_DAYS_90) = ;
data SC_hsp_&bl._&ds. ;
	MERGE HSP_CHAR(IN=A) HSP_CLAIMS(IN=B) ; BY DESY_SORT_KEY EP_BEG EP_END PROVIDER stay ;
	IF A AND B ;
	FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
	SERVICE_CAT = "Hospice" ;
	ALLOWED = PMT_AMT ;

**** Accounting for same day transfers for day counts **** ;
proc sort data=SC_hsp_&bl._&ds. ; BY DESY_SORT_KEY EP_BEG EP_END HSPCSTRT THRU_DT ;
DATA R2.SC_hsp_&bl._&ds. ;
	SET SC_hsp_&bl._&ds. ; BY DESY_SORT_KEY EP_BEG EP_END HSPCSTRT THRU_DT ;
	IF FIRST.EP_END THEN DO ;
		PT = THRU_DT ;
	END ;
	ELSE DO ;
		IF HSPCSTRT = PT THEN DO ;
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
PROC SORT DATA=R2.SC_hsp_&bl._&ds. OUT=sch; BY DESY_SORT_KEY EP_BEG EP_END HSPCSTRT ;
DATA LATEST ;
	SET SCH ; BY DESY_SORT_KEY EP_BEG EP_END HSPCSTRT ;
	IF LAST.EP_END AND DOD NE . ;
	IF (THRU_DT = . OR THRU_DT GE DOD) AND  (DOD-HSPCSTRT GE 3) THEN HOSP_3DAY = 1 ;
	ELSE HOSP_3DAY = 0 ;

PROC SORT DATA=LATEST ; BY DESY_SORT_KEY EP_BEG EP_END ;
PROC MEANS DATA=LATEST NOPRINT MAX ; BY DESY_SORT_KEY EP_BEG EP_END ;
	VAR HOSP_3DAY ;
	OUTPUT OUT=OCM3(DROP = _TYPE_ _FREQ_)
		   Max() = ;


PROC SORT DATA=R1.HHA_CLAIMS OUT=HHA ; BY DESY_SORT_KEY ;

*** from_dt not available in claims data files *** ;
proc sql ;
	create table hha1 as 
	select a.*, b.* 
	from hha as a, epi_dod as b 
	where a.desy_sort_key=b.desy_sort_key and
		  b.ep_beg le a.HHSTRTDT le b.ep_end ;
QUIT ;

data r2.SC_hha_&bl._&ds. ;
	set hha1 ;
	FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
	SERVICE_CAT = "Home Health" ;
	ALLOWED = PMT_AMT ;

%mend oth ;

		   
**************************************************************************** ;
**************************************************************************** ;
**************************************************************************** ;

%IP ;
%OP ; 
%PB ;
%oth ; *** Needs to be run all the time to generate OCM3 variable.   ;
run ;


**************************************************************************** ;
***************** Creating Episode Level Flags ***************************** ;
**************************************************************************** ;


data CLMS_COMBINE(drop=CANCER_TYPE_MILLIMAN DOD ) ;
	set r2.SC_ip_&bl._&ds.(IN=G)
		r2.SC_OP_&bl._&ds.(IN=OP) 
		r2.SC_PB_&bl._&ds. (IN=B)
		r2.SC_hsp_&bl._&ds.(IN=D)
		r2.SC_hha_&bl._&ds(IN=E)
		r2.SC_snf_&bl._&ds.(IN=F);
		OCM_ID = "BM_5PCT" ;
		IF B THEN SRC = "PB/DME" ;
		IF G THEN SRC = "IP" ;
		IF op THEN SRC = "OP" ;
		IF D THEN SRC = "HSP" ;
		IF E THEN SRC = "HHA" ;
		IF F THEN SRC = "SNF" ;


		FORMAT START_DATE END_DATE ADMIT_DT DSCHRG_DT MMDDYY10. ;
		IF G OR F THEN DO ;
				  START_DATE = ADMSN_DT ;
				  END_DATE = DSCHRGDT ;
				  ADMIT_DT = ADMSN_DT ;
				  DSCHRG_DT = DSCHRGDT ;
		END ;
		ELSE IF D THEN DO ;
				START_DATE = HSPCSTRT ;
  			    END_DATE = THRU_DT ;
		END ;

		ELSE IF E THEN DO ; 
				  START_DATE = HHSTRTDT ; 
				  END_DATE = THRU_DT ;
		END ;

		ELSE IF OP THEN DO ;
				  START_DATE = REV_DT ;
				  END_DATE = REV_DT ;
		END ;

		ELSE IF B THEN DO ;
					START_DATE = EXPNSDT2 ;
					END_DATE = EXPNSDT2 ;
		END ;

		*** 5/4/17: LOS to use UTIL_DAY when available. *** ;
		if B OR op OR D OR E THEN LOS = MAX((END_DATE-START_DATE),1) ;
		IF G OR F THEN LOS = UTIL_DAY ;
		*** AT_NPI already in data *** ;
		*** OP_NPI already in data *** ;
		*** DRG_CD already in data *** ;
		*** PRFNPI already in data *** ;
		IF DME = 1 THEN PRFNPI = SUP_NPI ;
		ADMIT_DIAG_CD = ADMTG_DGNS_CD ;
		PRINCIPAL_DIAG_CD = PRNCPAL_DGNS_CD ;
		IF B THEN PRINCIPAL_DIAG_CD = LINE_ICD_DGNS_CD ;
		PROCEDURE_CD_VER = "0" ;
		IF PROCEDURE_CD_VER = "  " THEN PROCEDURE_CD_VER = "0" ;
		PROCEDURE_CD = ICD_PRCDR_CD1 ;

		IF G OR op OR D OR E OR F THEN PRVDR_NUM = PROVIDER ;
		DATE_SCREEN = START_DATE;

PROC SORT DATA=CLMS_COMBINE ; BY DESY_SORT_KEY EP_BEG EP_END  ;

DATA t0 ;
	**** ENSURING THAT CLAIMS OCCUR WITHIN EPISODE **** ;
	merge EPI_DOD(in=ab keep = desy_sort_key ep_id AGE age_16 ep_beg ep_end dod cancer_TYPE_MILLIMAN ) 
		  CLMS_COMBINE(in=b) ; by DESY_SORT_KEY EP_BEG EP_END  ;
		  if ab and b ;
		  if ep_beg <= DATE_SCREEN <= ep_end ;

		  age_17 = AGE ;
		  IF YEAR(EP_END) = 2016 THEN AGE = age_16 ; 

		  CLAIM_ID = CLAIM_NO ;


		  **Setting values so macros will work. *** ;
		  CANCER_TYPE = CANCER_TYPE_MILLIMAN ;
		  NDC9 = "  " ;
		  srvc_dt = . ;

		*** Novel Therapy Flag *** ;
			FORMAT NOVEL_THERAPY $3. ;
			LENGTH NOVEL_THERAPY $3. ;
			NOVEL_THERAPY = "NO" ;
			*IF IDENDC NE "  " THEN NDC9 = SUBSTR(IDENDC,1,9) ;	*** Outpatient revenue NDC indicator *** ;
			*IF LNNDCCD NE " " THEN NDC9 = SUBSTR(LNNDCCD,1,9) ; *** DME NDC indicator *** ;
			%NT_BM ;
	proc sort; by DESY_SORT_KEY EP_ID;
RUN ;
%NT_COMBO_BM ;

data t5 ;
	merge t0(in=a) t2(in=b) ; by DESY_SORT_KEY EP_ID ;
	if a ;
	if a and b and  NOVEL_THERAPYe = "YES" then do ;
		%NT2 ;
	end ;
run;

DATA all_claims2 radonc chemo_partb ocm2_chk i1 ;
	set t5;
		** Breaking out chemotherapy into types ** ;
		if SERVICE_CAT = 'Chemotherapy Drugs (Part B)' then do ;
			output chemo_partb ;
			CPB_CAT = put(HCPCS_CD,$Chemo_J_cat4p.) ;
			IF CPB_CAT = "N" then CPB_CAT = "Other" ;
			*** Additional J Codes we believe are chemo - as per PP, HB - Removed 5/4/17 *** ;
			*if hcpcs_cd in ("J0202","Q9979","J9213","J9214","J9300") then CPB_CAT = "Biologic" ;
			*else if hcpcs_cd in ("J9165") then CPB_CAT = "Hormonal" ;
			*else if hcpcs_cd in ("J9250","J9260","J9270") then CPB_CAT = "Cytotoxic" ;
			SERVICE_CAT = 'Part B Chemo: '||left(CPB_CAT) ;
		end ;

		** Breaking out Rad HT into types ** ;
		IF SERVICE_CAT = "Radiology: High Tech (MRI, CT, PET)" THEN DO ;
			RAD_CAT = put(hcpcs_cd,$Rad_HTI_CAT.) ;
			if RAD_CAT = "N" then RAD_CAT = put(rev_cntr,$Rad_HTI_REVCAT.) ;
			if RAD_CAT = "MRI" then SERVICE_CAT = "Radiology: MRI" ;
			else if RAD_CAT = "CT" then SERVICE_CAT = "Radiology: CT" ;
			else SERVICE_CAT = "Radiology: PET" ;
		end ;
			

		format LABEL2 $100. ; length LABEL2 $100. ;
		LABEL2 = SERVICE_CAT ;

		FORMAT LABEL1 $50. ; LENGTH LABEL1 $50. ; 
		if service_cat in ("Inpatient: Other","Inpatient Surgical: Cancer",
						  "Inpatient Surgical: Non-Cancer","Inpatient Medical",
						  "Emergency","Outpatient Surgery: Cancer", 
					      "Outpatient Surgery: Non-Cancer",'Outpatient: Other',
						  "SNF","Home Health","Hospice") then LABEL1 = "Facilities" ;
		else if service_cat in ("Other Drugs and Administration",'Chemotherapy Administration',
							    'Chemotherapy Adjuncts','Hematopoietic Agents','Anti-emetics')
			 OR SUBSTR(SERVICE_CAT,1,12) in ('Part B Chemo','Part D Chemo') then LABEL1 = 'Drugs' ;
		else if service_cat in ('Radiation Oncology','Radiology: MRI','Radiology: CT','Radiology: PET',
								'Radiology: Other','Lab') then LABEL1 = 'Radiation & Lab' ;
		else LABEL1 = 'Professional' ;


		IF CPB_CAT NE "  " THEN DO ;
			PART_B_CHEMO=1 ;
			IF NOVEL_THERAPY = "YES" THEN DO ;
				LABEL3 = "Part B Chemo: Novel Therapy" ;
				NT_BALL = ALLOWED ;
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
		if service_cat = "Inpatient Medical: Chemo Sensitive" then IPMedCS = 1 ;
		if service_cat = "Inpatient Medical: Non-Chemo Sensitive" then IPMedNCS = 1 ;
		if SERVICE_CAT = "Emergency: Chemo Sensitive" then FAC_ER_Chemo = 1 ;
		if SERVICE_CAT = "Emergency: Non-Chemo Sensitive" then FAC_ER_NonChemo = 1 ;
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
		if SERVICE_CAT = "DME"  then DME = 1 ;
		if SERVICE_CAT = 'Professional: Other' then PROF_OTH = 1; 
		IF SERVICE_CAT = 'Other' then OTHER = 1 ;

		*** End of Life Metrics **** ;
		format win_14_dod win_30_dod mmddyy10. ;

		IF SRC = "IP" THEN DO ;
			if cancer_type_MILLIMAN ne "Breast Cancer" then SIP_BREAST = 0 ;
			if cancer_type_MILLIMAN ne "Anal Cancer" then SIP_ANAL = 0 ;
			if cancer_type_MILLIMAN ne "Liver Cancer" then SIP_LIVER = 0 ;
			if cancer_type_MILLIMAN ne "Lung Cancer" then SIP_LUNG = 0 ;
			if cancer_type_MILLIMAN ne "Bladder Cancer" then SIP_BLADDER = 0 ;
			if cancer_type_MILLIMAN ne "Kidney Cancer" then SIP_KIDNEY = 0 ;
			if cancer_type_MILLIMAN ne "Female GU Cancer other than Ovary" then SIP_FEMALEGU = 0 ;
			if cancer_type_MILLIMAN ne "Gastro/Esophageal Cancer" then SIP_GASTRO = 0 ;
			if cancer_type_MILLIMAN ne "Head and Neck Cancer" then SIP_HN = 0 ;
			if cancer_type_MILLIMAN ne "Small Intestine / Colorectal Cancer" then SIP_INT = 0 ;
			if cancer_type_MILLIMAN ne "Ovarian Cancer" then SIP_OVARIAN = 0 ;
			if cancer_type_MILLIMAN ne "Prostate Cancer" then SIP_PROSTATE = 0 ;
			if cancer_type_MILLIMAN ne "Pancreatic Cancer" then SIP_PANCREATIC = 0 ;
			*if cancer_type_MILLIMAN ne "Acute Leukemia" then IP_BMT_AK = 0 ;
			*if cancer_type_MILLIMAN ne "Lymphoma" then IP_BMT_L = 0 ;
			*if cancer_type_MILLIMAN ne "Multiple Myeloma" then IP_BMT_MM = 0 ;
			*if cancer_type_MILLIMAN ne "MDS" then IP_BMT_MDS = 0  ;
			IF SUM(IP_CHEMO_ADMIN, /*IP_BMT_AK, IP_BMT_L, IP_BMT_MM, IP_BMT_MDS,*/ SIP_BREAST,SIP_ANAL,SIP_LIVER, 
				   SIP_LUNG, SIP_BLADDER, SIP_FEMALEGU,SIP_GASTRO, SIP_HN, SIP_INT, SIP_OVARIAN, SIP_PROSTATE, 
				   SIP_PANCREATIC,SIP_KIDNEY) GE 1 THEN EX1 = 0 ; 
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
						IF REV_CHRG - REV_NCVR > 0  THEN DO ;
							ED_OCM2 = 1 ;
							IF "70000" LE HCPCS_CD LE "89999" OR 
							    HCPCS_CD IN ('G0106','G0120','G0122','G0130','G0202','G0204','G0206','G0219',
											 'G0235','G0252','G0255','G0288','G0389','S8035','S8037','S8040',
											 'S8042','S8080','S8085','S8092','S9024') THEN ED_OCM2 = 0 ;
						END ;
				END ;
	   
				IF REV_CNTR = '0762' OR
				  (REV_CNTR = '0760' AND HCPCS_CD = "G0378" AND REV_UNIT GE 8) THEN DO ;
						IF REV_CHRG - REV_NCVR > 0  THEN DO ;
							OBS_OCM2 = 1 ;
				  		END ;
				END ;
		END ;

		IF SRC = "HSP" THEN DO ;
			HSP_PMT_AMT = ALLOWED ;
			ANYHOSP = 1 ;
		END ;


		IF DOD NE . THEN DO ;
				*** Add 1 day to include the day of DOD *** ;
				WIN_14_DOD = INTNX('DAY',DOD,-13,'SAME') ;
				IF (WIN_14_DOD LE DATE_SCREEN LE DOD) AND
				   (CPB_CAT NE "   " ) THEN CHEMO_DEATH14 = 1 ;
		END ;

		if SERVICE_CAT = 'Radiation Oncology' then output radonc ;
		IF ED_OCM2 =1 OR OBS_OCM2 = 1 THEN OUTPUT OCM2_CHK ;

		*** Assignment of these variables moved from OCM files program 002 to here for processing efficiency *** ;
			IP_UTIL = 0 ; SNF_UTIL = 0 ; HH_UTIL = 0 ; HSP_UTIL = 0 ; FAC_UTIL = 0 ; PROF_UTIL = 0 ;
			if src = "IP" then IP_UTIL = 1 ;
			IF SRC = "SNF" THEN SNF_UTIL = 1 ;
			IF SRC = "HHA" THEN HH_UTIL = 1 ;
			IF SRC = "HSP" THEN HSP_UTIL = 1 ;
			FAC_UTIL = MAX(IP_UTIL, SNF_UTIL, HH_UTIL, HSP_UTIL) ;
			if src = "PB/DME" THEN PROF_UTIL = 1 ;

		IF SRC = "IP" THEN OUTPUT I1 ;
		output ALL_CLAIMS2  ;

*** OCM2 - Seeing whether ED and OBS led to admission *** ;


PROC SQL ;
	CREATE TABLE WADMIT AS
	SELECT A.EP_BEG, A.EP_END, A.DESY_SORT_KEY, A.CLAIM_NO, A.ED_OCM2, A.OBS_OCM2, A.THRU_DT
	FROM OCM2_CHK AS A, IP1A AS B 
	WHERE A.EP_BEG = B.EP_BEG AND 
		  A.EP_END = B.EP_END AND 
		  A.DESY_SORT_KEY = B.DESY_SORT_KEY AND 
		  A.THRU_DT = B.ADMSN_DT ;
QUIT ;

PROC SORT DATA=WADMIT ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO THRU_DT ;
PROC MEANS DATA=WADMIT NOPRINT MAX ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO THRU_DT ;
	VAR ED_OCM2 OBS_OCM2 ;
	OUTPUT OUT=WADMIT2 (DROP=_TYPE_ _FREQ_)
		   MAX() = ;

PROC SORT DATA=OCM2_CHK ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO THRU_DT ;
PROC SORT DATA=ALL_CLAIMS2 ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO THRU_DT ;

	DATA O2 ;
	MERGE OCM2_CHK(IN=A) WADMIT2(IN=B DROP=ED_OCM2 OBS_OCM2) ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO THRU_DT ;
	IF A ;
	IF A AND B THEN RESULT_IN_ADMIT = 1 ;
			   ELSE RESULT_IN_ADMIT = 0 ;


PROC MEANS DATA=O2 NOPRINT MAX ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO THRU_DT ;
	VAR ED_OCM2 OBS_OCM2 RESULT_IN_ADMIT ;
	OUTPUT OUT=EDOBS (DROP = _TYPE_ _FREQ_)
		   MAX() = ;


DATA r2.ALL_CLAIMS_&bl._&DS. ;
	MERGE ALL_CLAIMS2(IN=A) EDOBS(IN=B) ; BY DESY_SORT_KEY EP_BEG EP_END CLAIM_NO THRU_DT ;
	IF A ;
	*** For ED and OBS service counts *** ;
	IF FIRST.CLAIM_NO THEN CLM_COUNT = 1 ;
	IF SUM(ED_OCM2,OBS_OCM2) > 0 THEN DO ;
		IF RESULT_IN_ADMIT NE 1 THEN DO ;
			OCM2 = 1 ;
		END ;
	END ;
			
		

PROC SORT DATA=r2.ALL_CLAIMS_&bl._&DS. ; BY DESY_SORT_KEY EP_BEG EP_END  ;
*** Gets at number of radiation oncology days for episode level file. *** ;

DATA RADONC ;
	SET RADONC ;
	RO_DATE = START_DATE ;
	FORMAT RO_DATE MMDDYY10. ;
PROC SORT DATA=RADONC NODUPKEY ; BY DESY_SORT_KEY EP_BEG EP_END RO_DATE ;
DATA RADONC ; SET RADONC ; ROC = 1 ;
PROC MEANS DATA=RADONC NOPRINT min max SUM ; BY DESY_SORT_KEY EP_BEG EP_END  ;
	VAR ROC RO_DATE ;
	OUTPUT OUT=ROC_ONC_DAYS(DROP = _TYPE_ _FREQ_)
		   SUM() = ROC_ONC_DAYS
		   MIN(RO_DATE) = RAD_ONC1
		   MAX(RO_DATE) = RAD_ONC2 ;


*** Gets at number of chemo part b days and length of part b chemo for episode level file. *** ;
DATA CHEMO_PARTB ;
	SET CHEMO_PARTB ;
	FORMAT TRIGGER_DATE MMDDYY10. ;
	TRIGGER_DATE = EXPNSDT2 ;
	IF TRIGGER_DATE = . THEN TRIGGER_DATE = rev_dt ;
	TRIGGER = 1 ;

PROC SORT DATA=CHEMO_PARTB NODUPKEY; BY DESY_SORT_KEY EP_BEG EP_END TRIGGER_DATE  ;
PROC MEANS DATA=CHEMO_PARTB NOPRINT MIN MAX SUM ; BY DESY_SORT_KEY EP_BEG EP_END ;
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
	SET R2.ALL_CLAIMS_&bl._&DS. ;
	IF SERVICE_CAT in ("Emergency: Chemo Sensitive","Emergency: Non-Chemo Sensitive") THEN OUTPUT EDCLMS ;
	ELSE OUTPUT CLMS_OTH  ;

proc sort data=EDCLMS ; by DESY_SORT_KEY EP_BEG EP_END REV_DT ;

DATA EDCLMS  ;
	SET EDCLMS ; BY DESY_SORT_KEY EP_BEG EP_END rev_dt ;
	if first.REV_DT then ER_COUNT = 1 ;
	else ER_COUNT = 0 ;

DATA CLMS_ALL ;
	SET CLMs_OTH(IN=A) EDCLMS ;
	IF A THEN ER_COUNT = 0 ;

PROC SORT DATA=CLMS_ALL ; BY DESY_SORT_KEY EP_BEG EP_END ;

proc means data=CLMS_ALL noprint max sum ; by DESY_SORT_KEY EP_BEG EP_END ;
	var IPOTH IPSCAN IPSNCAN IPMEDCS IPMEDNCS FAC_ER_CHEMO FAC_ER_NONCHEMO FAC_OPSURG_NONCANC
		FAC_OPSURG_CANC ANTIEMETICS CHEMO_ADMIN HEMATO RAD_ONC RAD_HT RAD_OTH LAB OTH_DRUG CHEMO_ADJUNCTS OP_OTH
		PROF_ER PROF_ER_CS PROF_IP PROF_SURG PROF_ANES PROF_OV DME PROF_OTH OTHER PART_B_CHEMO 
		PART_B_CHEMO_CYTO PART_B_CHEMO_BIO PART_B_CHEMO_HARM 
		PART_B_CHEMO_OTH RAD_MRI RAD_CT RAD_PET allowed  ER_COUNT
		ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME ANY_HSP_UNK EX1 IP_ALLCAUSE_30 IP_ICU_30 CHEMO_DEATH14 ANYHOSP 
		OP_ALLCAUSE_30 OCM2 HOSP_DAYS_90 HOSP_30DAYS  DIED_IN_HOSP IP_CAH IP_UTIL FAC_UTIL PROF_UTIL HH_UTIL
		HSP_UTIL SNF_UTIL NT_B NT_BALL BLAD_LR BLAD_OTH PROST_CAST PROST_OTH 
;
	output out=EPI_FLAGS_OP (drop = _type_ _freq_)
		   max(IPOTH IPSCAN IPSNCAN IPMEDCS IPMEDNCS  FAC_ER_CHEMO 
			   FAC_ER_NONCHEMO  FAC_OPSURG_NONCANC FAC_OPSURG_CANC 
			   ANTIEMETICS CHEMO_ADMIN HEMATO RAD_ONC RAD_HT RAD_OTH LAB OTH_DRUG CHEMO_ADJUNCTS OP_OTH
			   PROF_ER PROF_ER_CS PROF_IP PROF_SURG PROF_ANES PROF_OV DME PROF_OTH OTHER PART_B_CHEMO
			   	PART_B_CHEMO_CYTO PART_B_CHEMO_BIO PART_B_CHEMO_HARM 
				PART_B_CHEMO_OTH RAD_MRI RAD_CT RAD_PET 
				ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME ANY_HSP_UNK EX1 IP_ALLCAUSE_30 IP_ICU_30 CHEMO_DEATH14
				ANYHOSP OP_ALLCAUSE_30 OCM2 HOSP_30DAYS DIED_IN_HOSP IP_CAH
				IP_UTIL FAC_UTIL PROF_UTIL HH_UTIL	HSP_UTIL SNF_UTIL NT_B BLAD_LR BLAD_OTH PROST_CAST PROST_OTH ) =				
			sum(allowed  ER_COUNT HOSP_DAYS_90 NT_BALL) =  ;


**************************************************************************** ;
****************** Creating final episode INTERFACE file. ****************** ;
**************************************************************************** ;

proc sort data=r2.episode_candidates out=epi_char(keep = desy_sort_key EP_BEG EP_END age age_16 sex dod)  ; 
by DESY_SORT_KEY EP_BEG EP_END ;

proc sort data=r2.epi_prelim_&bl._&ds. out=epi_prelim ; by DESY_SORT_KEY EP_BEG EP_END  ;

data epi_prelim ;
	merge epi_prelim(in=a) epi_char(in=b) ; by desy_sort_key EP_BEG EP_END ;
	if a ;

DATA EPIPRE ;
	merge EPI_PRELIM(in=a) EPI_FLAGS_OP ROC_ONC_DAYS PB_DATES ocm3; by DESY_SORT_KEY EP_BEG EP_END  ;
	IF A ;
	BENE_ID = DESY_SORT_KEY ;
	OCM_ID = "BM_5PCT" ;
	** Overriding what is created in 052 program - to match OCM length calculation which does
	   not consider date of death for episode length. ** ;
	EP_END_length = intnx('month', ep_beg, 6,'same')-1 ;
	EP_LENGTH =  EP_END_length-EP_BEG+1 ;
	EP_180_181 = 0 ; EP_182_183 = 0 ;
	IF EP_LENGTH < 183 THEN EP_180_181 = 1 ;
	ELSE EP_182_183 = 1 ;

		  age_17 = AGE ;
		  IF YEAR(EP_BEG) = 2016 THEN AGE = age_16 ; 

	FORMAT CHEMO_UTIL_TYPE $26. ;
	LENGTH CHEMO_UTIL_TYPE $26. ;
	*IF PART_D_CHEMO = 1 AND PART_B_CHEMO = 1 then CHEMO_UTIL_TYPE = "Part B and Part D" ;
	*ELSE IF PART_D_CHEMO = 1 then CHEMO_UTIL_TYPE = "Part D" ;
	*ELSE IF PART_B_CHEMO = 1 then CHEMO_UTIL_TYPE = "Part B" ;
	CHEMO_UTIL_TYPE = "Part B" ;

	** PB_DATES merges in fields CHEMO_DATS_PARTB and CHEMO_LENGTH_PARTB ** ;
	** RAD_ONC_DAYS merges in fields RAD_ONC_DATS and RAD_ONC_LENGTH ** ;
	RAD_ONC_DAYS = MAX(0,ROC_ONC_DAYS) ;
	FORMAT RAD_ONC1 RAD_ONC2  MMDDYY10. ;
	RAD_ONC_LENGTH = SUM((RAD_ONC2-RAD_ONC1),1) ;

	IP_MED_CHEMO_UTIL = MAX(0,IPMEDCS) ;
	IP_MED_NON_CHEMO_UTIL = MAX(0,IPMEDNCS) ;
	IP_SURG_CHEMO_UTIL = MAX(0,IPSCAN) ;
	IP_SURG_NON_CHEMO_UTIL = MAX(0,IPSNCAN) ;
	IP_OTHER_UTIL = MAX(0,IPOTH) ;
	ER_CHEMO_UTIL = MAX(0,FAC_ER_CHEMO) ;
	ER_NON_CHEMO_UTIL = MAX(0, FAC_ER_NONCHEMO) ;
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
	PROF_OTHER_UTIL = MAX(0,PROF_OTH) ;
	DME_UTIL = MAX(0, DME) ;
	OUT_OTHER_UTIL = MAX(0,OP_OTH) ;
	OTHER_UTIL = MAX(0, OTHER) ;
	*CHEMO_D_UTIL = MAX(0,PART_D_CHEMO) ;
	CHEMO_B_UTIL = MAX(0,PART_B_CHEMO) ;
	*CHEMO_D_CYTO_UTIL = MAX(0,PART_D_CHEMO_CYTO) ;
	CHEMO_B_CYTO_UTIL = MAX(0,PART_B_CHEMO_CYTO) ;
	*CHEMO_D_BIO_UTIL = MAX(0,PART_D_CHEMO_BIO) ;
	CHEMO_B_BIO_UTIL = MAX(0,PART_B_CHEMO_BIO) ;
	*CHEMO_D_HARM_UTIL = MAX(0,PART_D_CHEMO_HARM) ;
	CHEMO_B_HARM_UTIL = MAX(0,PART_B_CHEMO_HARM) ;
	*CHEMO_D_OTH_UTIL = MAX(0,PART_D_CHEMO_OTH) ;
	CHEMO_B_OTH_UTIL = MAX(0,PART_B_CHEMO_OTH) ;

	*** PREDICTIVE MODEL VARIABLES ** ;
	*** NEW NOVEL THERAPY FLAGS *** ;
	NOVEL_THER_UTIL = MAX(0,NT_B) ;
	NOVEL_THER_B_UTIL = MAX(0, NT_B) ;
	NOVEL_THER_D_UTIL = 0 ;
	NOVEL_THER_B_ALLOWED = NT_BALL ;
	NOVEL_THER_D_ALLOWED = 0 ;
	NOVEL_THER_ALLOWED = NT_BALL ;


	
	
	ER_UG_OBS_UTIL = MAX(ER_CHEMO_UTIL, ER_NON_CHEMO_UTIL) ;
	OUT_SURG_UTIL = MAX(OUT_SURG_CANCER_UTIL, OUT_SURG_NONCANCER_UTIL) ;
	OP_UTIL = MAX(OUT_SURG_UTIL, OUT_OTHER_UTIL) ;
	DRUG_UTIL = MAX(ANTI_EMETICS_UTIL,HEMOTAPOETIC_UTIL,OTHER_DRUGS_UTIL, 
				    CHEMO_ADJ_UTIL,CHEMO_ADMIN_UTIL, /*CHEMO_D_UTIL,*/ CHEMO_B_UTIL);
	CHEMO_ADMIN_UTIL = MAX(0, CHEMO_ADMIN) ;
	
	RAD_ONC_UTIL = MAX(0,RAD_ONC) ;

	IF SEX = "1" THEN PATIENT_SEX = 1  ;
	ELSE IF SEX = "2" THEN PATIENT_SEX = 2 ;
	ELSE PATIENT_SEX = 0 ;

	ACTUAL_EXP_MILLIMAN = ALLOWED ;

	EPI_TAX_ID = " " ;
	EPI_NPI_ID = " " ;
	*** NOT YET OR UNABLE TO VALIDATE AS OF 9/22/16 *** ;
	*RECON_ELIG_MILLIMAN = RECON_ELIG ;
	*DUAL_PTD_LIS_MILLIMAN = DUAL_PTD_LIS ;
	*INST_MILLIMAN = INST ;
	** HCC_GRP_MILLIMAN ;
	** HRR_REL_COST_MILLIMAN ;
	BASELINE_PRICE_MILLIMAN = 0 ;

	*** End of Life Metrics *** ;
	IF EP_BEG LE DOD LE EP_END THEN DIED_MILLIMAN = 1 ;
	ELSE DIED_MILLIMAN = 0 ;

	IF DIED_MILLIMAN = 1 THEN DO ;
		HSP_30DAYS_ALL_MILLIMAN = MAX(0,HOSP_30DAYS) ;
		IF ANY_HSP_BOTH = 1 OR (ANY_HSP_FAC = 1 AND ANY_HSP_HOME = 1) THEN ANY_HSP_CARE_MILLIMAN = 3 ;
			ELSE IF ANY_HSP_FAC = 1 THEN ANY_HSP_CARE_MILLIMAN = 2 ;
			ELSE IF ANY_HSP_HOME = 1 THEN ANY_HSP_CARE_MILLIMAN = 1 ;
			ELSE IF ANY_HSP_UNK = 1 THEN ANY_HSP_CARE_MILLIMAN = 0 ;
		HSP_DAYS_MILLIMAN = MAX(0,HOSP_DAYS_90) ;
		*** As per OCM ticket 799809 - only IP services are included in HOSPITAL_USE *** ;
		HOSPITAL_USE_MILLIMAN = MAX(0,IP_ALLCAUSE_30/*,OP_ALLCAUSE_30*/) ;
		ICU_MILLIMAN = MAX(0,IP_ICU_30) ;
		CHEMOTHERAPY_MILLIMAN = MAX(0,CHEMO_DEATH14) ;
		OCM3 = MAX(0,HOSP_3DAY) ;
		DIED_IN_HOSP = MAX(0,DIED_IN_HOSP) ; 
	END ;

	INST_MILLIMAN = 0 ;

	*** OCM Quality Measures *** ;
	OCM1 = MAX(0,EX1) ;
	** episodes with emergency department (ED) visits or observation stays that did not result in a hospitalization ** ;
	OCM2 = MAX(0,OCM2) ;

	**** End of Life Values should be missing if DOD is missing **** ;
	IF died_milliman ne 1 THEN DO ;
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


run ;

****** Make a copy of bladder and prostate cancers. ******** ;
data bladprost ;
	set epipre ;
	if cancer_type_milliman in ("Bladder Cancer","Prostate Cancer","Breast Cancer") then output bladprost ;

DATA BLADPROST ; SET BLADPROST ;
	IF CANCER_TYPE_milliman = "Bladder Cancer" then do ;
		IF BLAD_LR = 1 AND BLAD_OTH = 0 THEN CANCER_TYPE_milliman = "Bladder Cancer - Low Risk" ;
		ELSE CANCER_TYPE_milliman = "Bladder Cancer - High Risk" ;
	END ;
	IF CANCER_TYPE_milliman = "Prostate Cancer" then do ;
		IF PROST_CAST = 1 AND PROST_OTH = 0 THEN CANCER_TYPE_milliman = "Prostate Cancer - Low Intensity" ;
		ELSE CANCER_TYPE_milliman = "Prostate Cancer - High Intensity" ;
	END ;
	*** unable to identify low risk since hormonal patients only identified by Part D claims *** ;
	IF CANCER_TYPE_MILLIMAN = "Breast Cancer" then CANCER_TYPE_MILLIMAN = "Breast Cancer - High Risk" ;

DATA EPIPRE2 ;
	SET EPIPRE BLADPROST ;			
	
data r2.episode_Interface_&bl._&ds ;
	retain OCM_ID BENE_ID /*BENE_HICN FIRST_NAME LAST_NAME PATIENT_NAME*/ SEX 
		   PATIENT_SEX /*DOB*/ AGE DOD EP_ID EP_BEG EP_END EP_LENGTH EP_180_181 EP_182_183 
		   /*CANCER_TYPE RECON_ELIG DUAL_PTD_LIS INST RADIATION*/ HCC_GRP/*
		   HRR_REL_COST SURGERY CLINICAL_TRIAL BMT CLEAN_PD PTD_CHEMO*/
		   ACTUAL_EXP_MILLIMAN /*BASELINE_PRICE EXPERIENCE_ADJ*/ CANCER_TYPE_MILLIMAN
		   /*RECON_ELIG_MILLIMAN DUAL_PTD_LIS_MILLIMAN*/ INST_MILLIMAN RADIATION_MILLIMAN
		   /*HCC_GRP_MILLIMAN HRR_REL_COST_MILLIMAN*/ SURGERY_MILLIMAN CLINICAL_TRIAL_MILLIMAN
		   /*PTD_CHEMO_MILLIMAN*/ ACTUAL_EXP_MILLIMAN BASELINE_PRICE_MILLIMAN IP_UTIL SNF_UTIL
		   HH_UTIL HSP_UTIL FAC_UTIL /*CHEMO_D_UTIL*/ CHEMO_B_UTIL PROF_UTIL DRUG_UTIL RAD_ONC_UTIL
		   CHEMO_DAYS_PARTB	RAD_ONC_DAYS CHEMO_LENGTH_PARTB RAD_ONC_LENGTH IP_MED_CHEMO_UTIL
		   IP_MED_NON_CHEMO_UTIL IP_SURG_CHEMO_UTIL IP_SURG_NON_CHEMO_UTIL IP_OTHER_UTIL
		   ER_CHEMO_UTIL ER_NON_CHEMO_UTIL OUT_SURG_CANCER_UTIL OUT_SURG_NONCANCER_UTIL ANTI_EMETICS_UTIL
		   HEMOTAPOETIC_UTIL OTHER_DRUGS_UTIL CHEMO_ADMIN_UTIL RAD_HTECH_UTIL RAD_OTHER_UTIL
		   LAB_UTIL PROF_IP_UTIL PROF_SURGERY_UTIL PROF_ANESTHESIA_UTIL PROF_OTHER_UTIL DME_UTIL OTHER_UTIL
		   ER_UG_OBS_UTIL OUT_SURG_UTIL OUT_OTHER_UTIL OP_UTIL 
		   PROF_OFFICE_UTIL PROF_ER_UTIL OTHER_UTIL CHEMO_ADJ_UTIL
		   /*CHEMO_D_CYTO_UTIL*/ CHEMO_B_CYTO_UTIL /*CHEMO_D_BIO_UTIL*/ CHEMO_B_BIO_UTIL /*CHEMO_D_HARM_UTIL*/ 
		   CHEMO_B_HARM_UTIL /*CHEMO_D_OTH_UTIL*/ CHEMO_B_OTH_UTIL CHEMO_UTIL_TYPE RAD_MRI_UTIL RAD_CT_UTIL RAD_PET_UTIL EPI_TAX_ID EPI_NPI_ID 
		   ER_VISITS_MILLIMAN 

			NOVEL_THER_UTIL NOVEL_THER_B_UTIL NOVEL_THER_D_UTIL NOVEL_THER_B_ALLOWED NOVEL_THER_D_ALLOWED 
			NOVEL_THER_ALLOWED 

		   DIED_MILLIMAN HSP_30DAYS_ALL_MILLIMAN ANY_HSP_CARE_MILLIMAN HSP_DAYS_MILLIMAN  HOSPITAL_USE_MILLIMAN
		   ICU_MILLIMAN CHEMOTHERAPY_MILLIMAN OCM1 OCM2 OCM3 DIED_IN_HOSP
		   BMT_MILLIMAN CLEAN_1_61 CLEAN_62_730 clean_731
;

	SET EPIPRE2 ;

	KEEP OCM_ID BENE_ID /*BENE_HICN FIRST_NAME LAST_NAME PATIENT_NAME*/ SEX 
		   PATIENT_SEX /*DOB*/ AGE DOD EP_ID EP_BEG EP_END EP_LENGTH EP_180_181 EP_182_183 
		   /*CANCER_TYPE RECON_ELIG DUAL_PTD_LIS INST RADIATION*/ HCC_GRP/*
		   HRR_REL_COST SURGERY CLINICAL_TRIAL BMT CLEAN_PD PTD_CHEMO*/
		   ACTUAL_EXP_MILLIMAN /*BASELINE_PRICE EXPERIENCE_ADJ*/ CANCER_TYPE_MILLIMAN
		   /*RECON_ELIG_MILLIMAN DUAL_PTD_LIS_MILLIMAN*/ INST_MILLIMAN RADIATION_MILLIMAN
		   /*HCC_GRP_MILLIMAN HRR_REL_COST_MILLIMAN*/ SURGERY_MILLIMAN CLINICAL_TRIAL_MILLIMAN
		   /*PTD_CHEMO_MILLIMAN*/ ACTUAL_EXP_MILLIMAN BASELINE_PRICE_MILLIMAN IP_UTIL SNF_UTIL
		   HH_UTIL HSP_UTIL FAC_UTIL /*CHEMO_D_UTIL*/ CHEMO_B_UTIL PROF_UTIL DRUG_UTIL RAD_ONC_UTIL
		   CHEMO_DAYS_PARTB	RAD_ONC_DAYS CHEMO_LENGTH_PARTB RAD_ONC_LENGTH IP_MED_CHEMO_UTIL
		   IP_MED_NON_CHEMO_UTIL IP_SURG_CHEMO_UTIL IP_SURG_NON_CHEMO_UTIL IP_OTHER_UTIL
		   ER_CHEMO_UTIL ER_NON_CHEMO_UTIL OUT_SURG_CANCER_UTIL OUT_SURG_NONCANCER_UTIL ANTI_EMETICS_UTIL
		   HEMOTAPOETIC_UTIL OTHER_DRUGS_UTIL CHEMO_ADMIN_UTIL RAD_HTECH_UTIL RAD_OTHER_UTIL
		   LAB_UTIL PROF_IP_UTIL PROF_SURGERY_UTIL PROF_ANESTHESIA_UTIL PROF_OTHER_UTIL DME_UTIL OTHER_UTIL
		   ER_UG_OBS_UTIL OUT_SURG_UTIL OUT_OTHER_UTIL OP_UTIL 
		   PROF_OFFICE_UTIL PROF_ER_UTIL OTHER_UTIL  CHEMO_ADJ_UTIL
		   /*CHEMO_D_CYTO_UTIL*/ CHEMO_B_CYTO_UTIL /*CHEMO_D_BIO_UTIL*/ CHEMO_B_BIO_UTIL /*CHEMO_D_HARM_UTIL */
		   CHEMO_B_HARM_UTIL /*CHEMO_D_OTH_UTIL*/ CHEMO_B_OTH_UTIL CHEMO_UTIL_TYPE 		   
		   RAD_MRI_UTIL RAD_CT_UTIL RAD_PET_UTIL EPI_TAX_ID EPI_NPI_ID ER_VISITS_MILLIMAN 

		   	NOVEL_THER_UTIL NOVEL_THER_B_UTIL NOVEL_THER_D_UTIL NOVEL_THER_B_ALLOWED NOVEL_THER_D_ALLOWED 
			NOVEL_THER_ALLOWED 

		   DIED_MILLIMAN HSP_30DAYS_ALL_MILLIMAN ANY_HSP_CARE_MILLIMAN HSP_DAYS_MILLIMAN  HOSPITAL_USE_MILLIMAN
		   ICU_MILLIMAN CHEMOTHERAPY_MILLIMAN OCM1 OCM2 OCM3 DIED_IN_HOSP
		   BMT_MILLIMAN CLEAN_1_61 CLEAN_62_730 clean_731
;


data r2.CLAIMS_Interface_&bl._&ds ;
	RETAIN OCM_ID EP_ID CLAIM_ID START_DATE END_DATE NOVEL_THERAPY PRVDR_NUM ADMIT_DT DSCHRG_DT
		   AT_NPI OP_NPI DRG_CD ADMIT_DIAG_CD PRINCIPAL_DIAG_CD PROCEDURE_CD LOS STUS_CD VISITCNT 
		   HCFASPCL PRFNPI HCPCS_CD /*NDC*/ REV_CNTR /*PRSCRBR_ID PART_D_SERVICE_DATE FILL_NUM DAYS_SUPPLY*/ LABEL1
		   LABEL2 ALLOWED ;
	SET R2.ALL_CLAIMS_&bl._&DS. ;
	KEEP OCM_ID EP_ID CLAIM_ID START_DATE END_DATE NOVEL_THERAPY PRVDR_NUM ADMIT_DT DSCHRG_DT
		   AT_NPI OP_NPI DRG_CD ADMIT_DIAG_CD PRINCIPAL_DIAG_CD PROCEDURE_CD LOS STUS_CD VISITCNT 
		   HCFASPCL PRFNPI HCPCS_CD REV_CNTR /*NDC PRSCRBR_ID PART_D_SERVICE_DATE FILL_NUM DAYS_SUPPLY*/ LABEL1
		   LABEL2 ALLOWED ;


%MEND sc ; 
**************************************************************************** ;
**************************************************************************** ;

%SC ; run ;

**************************************************************************** ;
			*** Creation of final Benchmark File *** ;
**************************************************************************** ;

proc freq data=r2.episode_interface_&bl._&ds. ; 
	tables cancer_type_milliman ;
title "Cancers found in episode interface file to prepare for benchmarks" ; run ;

DATA STEP1 ;
	SET R2.EPISODE_INTERFACE_&bl._&ds. ;
	FORMAT CANCER_TYPE $100. ;
	IF CANCER_TYPE_MILLIMAN NOT IN ('Acute Leukemia','Anal Cancer','Bladder Cancer','Breast Cancer','Chronic Leukemia',
									'CNS Tumor','Intestinal Cancer','Endocrine Tumor','Female GU Cancer other than Ovary',
									'Gastro/Esophageal Cancer','Head and Neck Cancer','Kidney Cancer','Liver Cancer',
									'Lung Cancer','Lymphoma','Malignant Melanoma','MDS','Multiple Myeloma',
									'Ovarian Cancer','Pancreatic Cancer','Prostate Cancer',"Bladder Cancer - Low Risk",
									"Bladder Cancer - High Risk","Prostate Cancer - Low Intensity",
									"Prostate Cancer - High Intensity","Breast Cancer - High Risk")
			THEN CANCER_TYPE = "All Other Cancers" ;
			ELSE CANCER_TYPE = CANCER_TYPE_milliman ;

			IF CANCER_TYPE = "Female GU Cancer other than Ovary" THEN 
			   CANCER_TYPE = "Female GU excl ovary" ;
			IF CANCER_TYPE = "Intestinal Cancer" THEN 
			   CANCER_TYPE = "Colorectal/Intestinal Cancer" ;
 
		EP_COUNT = 1 ;

PROC SORT DATA=STEP1 ; BY CANCER_TYPE ;
PROC MEANS DATA=STEP1 NOPRINT mean SUM ; BY CANCER_TYPE ;
	VAR EP_COUNT OCM1 OCM2 OCM3 HOSPITAL_USE_MILLIMAN ICU_MILLIMAN CHEMOTHERAPY_MILLIMAN 
		HSP_30DAYS_ALL_MILLIMAN HSP_DAYS_MILLIMAN DIED_MILLIMAN DIED_IN_HOSP ;
	OUTPUT OUT=R2.EPISODE_BENCHMARKS_5PCT (DROP = _TYPE_ _FREQ_)
		   SUM(EP_COUNT) = 
		   mean(OCM1 OCM2 OCM3 HOSPITAL_USE_MILLIMAN ICU_MILLIMAN CHEMOTHERAPY_MILLIMAN 
				HSP_30DAYS_ALL_MILLIMAN HSP_DAYS_MILLIMAN DIED_MILLIMAN DIED_IN_HOSP CLEAN_1_61 CLEAN_62_730 clean_731)= ;

PROC EXPORT DATA = R2.EPISODE_BENCHMARKS_5PCT 
	OUTFILE = "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\Interface Materials\EPISODE_BENCHMARKS_5PCT_&daterun..csv"
	DBMS = CSV REPLACE ;
QUIT ;

run ;

**************************************************************************** ;
			*** Creation of Prediction Model File *** ;
**************************************************************************** ;

data step1 ;

	SET R2.EPISODE_INTERFACE_&bl._&ds. ;

	age_calc = intz(age) ;
	*if age_calc lt 65 then age_18_64 = 1 ; *else age_18_64 = 0 ;
	*if 65 le age_calc le 69 then age_65_69 = 1 ; *else age_65_69 = 0 ;
	*if 70 le age_calc le 74 then age_70_74 = 1 ; *else age_70_74 = 0  ;
	*if 75 le age_calc le 79 then age_75_79 = 1 ; *else age_75_79 = 0 ;
	*if 80 le age_calc then age_80 = 1 ; *else age_80 = 0 ;
	age_18_64 = 1 ; age_65_69 = 1 ; age_70_74 = 1 ; age_75_79 = 1 ; age_80 = 1 ;

	*if sex = "F" then female = 1 ; *else female = 0 ;
	*If female = 1 then male = 0 ; *else male = 1 ;  *** assigns unknown genders to male. *** ;
	female =  1 ; male = 1 ;

	*** Fields not derived as of yet. *** ;
	*IF INST_MILLIMAN = 1 THEN DO ; 
		*INSTY = 1 ; *INSTN = 0 ; *END ;
	*ELSE DO ; *INSTY = 0 ; *INSTN = 1 ; *END ;
	insty = .0111 ;
	instn = 1-insty ;


	cp_1_61 = CLEAN_1_61;
	cp_62_730 = CLEAN_62_730;
	cp_none = clean_731 ;

	enroll_full_dual = .1203 ;
	enroll_no_pd = .3548 ;
	enroll_pd_lis = .0734 ;
	enroll_pd_no_lis = .4515 ;

	comorb_1 = 0 ; COMORB_2 = 0 ; comorb_3 = 0 ; comorb_4_5 = 0 ;
	comorb_6 = 0 ; comorb_new_enroll = 0 ; comorb_none = 0 ;

	comorb_1 = (hcc_grp = "01") ;
	comorb_2 = (hcc_grp = "02") ;
	comorb_3 = (hcc_grp = "03") ;
	comorb_4_5 = (hcc_grp = "4-5") ;
	comorb_6 = (hcc_grp = "6+") ;
	comorb_new_enroll = (hcc_grp = "98");
	comorb_none = (hcc_grp = "00") ;

	*comorb_1 = 1/7 ;
	*comorb_2 = 1/7 ;
	*comorb_3 = 1/7;
	*comorb_4_5 = 1/7;
	*comorb_6 = 1/7;
	*comorb_new_enroll = 1/7;
	*comorb_none = 1/7 ;

	*** CT = Clinical_Trial_milliman *** ;
	*** RAD = RADIATION_MILLIMAN *** ;
	*** SURG = SURGERY_MILLIMAN *** ;
	*** BMT = BMT_MILLIMAN *** ;

	IF CLINICAL_TRIAL_MILLIMAN = 1 THEN DO ; CTY = 1 ; CTN = 0 ; END ;
								   ELSE DO ; CTN = 1 ; CTY = 0 ; END ;
	IF RADIATION_MILLIMAN      = 1 THEN DO ; RDY = 1 ; RDN = 0 ; END ;
								   ELSE DO ; RDN = 1 ; RDY = 0 ; END ;
	IF SURGERY_MILLIMAN		   = 1 THEN DO ; SGY = 1 ; SGN = 0 ; END ;
								   ELSE DO ; SGN = 1 ; SGY = 0 ; END ;
	IF BMT_MILLIMAN = 1 THEN DO ; 				au = 1 ; al = 0 ; anone = 0 ;END ;
	else if BMT_MILLIMAN IN (2,3) then do ; 	AU = 0 ; AL = 1 ; ANONE = 0 ; END ;
	ELSE IF BMT_MILLIMAN = 4 		THEN DO ;   AU = 1/3 ; AL = 1/3 ; ANONE = 1/3 ; END ;  *** 1 for all weights ;
							 		ELSE DO ;   AU = 0 ; AL = 0 ; ANONE = 1 ; END ;

	
	EPISODE_COUNT = 1 ;

	***Variable Derivation *** ;
	CANC_18_64_F_inst_y	= AGE_18_64*FEMALE*INSTy ;
	CANC_18_64_F_inst_n	= AGE_18_64*FEMALE*INSTn ;
	CANC_18_64_M_inst_y	= AGE_18_64*MALE*INSTy ;
	CANC_18_64_M_inst_n	= AGE_18_64*MALE*INSTn ;

	CANC_18_64_F_epi_180_181= AGE_18_64*FEMALE*EP_180_181 ;	
	CANC_18_64_F_epi_182_183 = 	AGE_18_64*FEMALE*EP_182_183 ;
	CANC_18_64_M_epi_180_181= AGE_18_64*MALE*EP_180_181 ;	
	CANC_18_64_M_epi_182_183 = 	AGE_18_64*MALE*EP_182_183 ;

	CANC_18_64_F_cp_1_61= AGE_18_64*FEMALE*CP_1_61;		
	CANC_18_64_F_cp_62_730	= AGE_18_64*FEMALE*CP_62_730 ; 
	CANC_18_64_F_cp_none = AGE_18_64*FEMALE*CP_NONE;
	CANC_18_64_M_cp_1_61= AGE_18_64*MALE*CP_1_61;		
	CANC_18_64_M_cp_62_730	= AGE_18_64*MALE*CP_62_730 ; 
	CANC_18_64_M_cp_none = AGE_18_64*MALE*CP_NONE	;

	CANC_18_64_F_enroll_full_dual= AGE_18_64*FEMALE*ENROLL_FULL_DUAL ;
	CANC_18_64_F_enroll_no_pd	= AGE_18_64*FEMALE*ENROLL_NO_PD ;
	CANC_18_64_F_enroll_pd_lis	= AGE_18_64*FEMALE*ENROLL_PD_LIS ;
	CANC_18_64_F_enroll_pd_no_lis	= AGE_18_64*FEMALE*ENROLL_PD_NO_LIS ;
	CANC_18_64_M_enroll_full_dual= AGE_18_64*MALE*ENROLL_FULL_DUAL ;
	CANC_18_64_M_enroll_no_pd	= AGE_18_64*MALE*ENROLL_NO_PD ;
	CANC_18_64_M_enroll_pd_lis	= AGE_18_64*MALE*ENROLL_PD_LIS ;
	CANC_18_64_M_enroll_pd_no_lis	= AGE_18_64*MALE*ENROLL_PD_NO_LIS ;

	CANC_18_64_F_comorb_1 = AGE_18_64*FEMALE*COMORB_1 ;	
	CANC_18_64_F_comorb_2 = AGE_18_64*FEMALE*COMORB_2 ; 	
	CANC_18_64_F_comorb_3 = AGE_18_64*FEMALE*COMORB_3 ; 	
	CANC_18_64_F_comorb_4_5	 = AGE_18_64*FEMALE*COMORB_4_5 ; 
	CANC_18_64_F_comorb_6  = AGE_18_64*FEMALE*COMORB_6 ; 	
	CANC_18_64_F_comorb_new_enroll	 = AGE_18_64*FEMALE*COMORB_NEW_ENROLL ; 
	CANC_18_64_F_comorb_none	 = AGE_18_64*FEMALE*COMORB_NONE ; 
	CANC_18_64_M_comorb_1 = AGE_18_64*MALE*COMORB_1 ;	
	CANC_18_64_M_comorb_2 = AGE_18_64*MALE*COMORB_2 ; 	
	CANC_18_64_M_comorb_3 = AGE_18_64*MALE*COMORB_3 ; 	
	CANC_18_64_M_comorb_4_5	 = AGE_18_64*MALE*COMORB_4_5 ; 
	CANC_18_64_M_comorb_6  = AGE_18_64*MALE*COMORB_6 ; 	
	CANC_18_64_M_comorb_new_enroll	 = AGE_18_64*MALE*COMORB_NEW_ENROLL ; 
	CANC_18_64_M_comorb_none	 = AGE_18_64*MALE*COMORB_NONE ; 

	CANC_18_64_F_ct_y = AGE_18_64*FEMALE*CTY; 	
	CANC_18_64_F_ct_n = AGE_18_64*FEMALE*CTN; 		
	CANC_18_64_F_rad_y = AGE_18_64*FEMALE*RDY; 	
	CANC_18_64_F_rad_n = AGE_18_64*FEMALE*RDN; 		
	CANC_18_64_F_surg_y = AGE_18_64*FEMALE*SGY; 		
	CANC_18_64_F_surg_n	= AGE_18_64*FEMALE*SGN; 		
	CANC_18_64_F_bmt_al	= AGE_18_64*FEMALE*al; 		
	CANC_18_64_F_bmt_au	= AGE_18_64*FEMALE*au; 		
	CANC_18_64_F_bmt_none = AGE_18_64*FEMALE*anone; 			
	CANC_18_64_M_ct_y = AGE_18_64*MALE*CTY; 	
	CANC_18_64_M_ct_n = AGE_18_64*MALE*CTN; 		
	CANC_18_64_M_rad_y = AGE_18_64*MALE*RDY; 	
	CANC_18_64_M_rad_n = AGE_18_64*MALE*RDN; 		
	CANC_18_64_M_surg_y = AGE_18_64*MALE*SGY; 		
	CANC_18_64_M_surg_n	= AGE_18_64*MALE*SGN; 		
	CANC_18_64_M_bmt_al	= AGE_18_64*MALE*al; 		
	CANC_18_64_M_bmt_au	= AGE_18_64*MALE*au; 		
	CANC_18_64_M_bmt_none = AGE_18_64*MALE*anone; 			

	CANC_65_69_F_inst_y	= AGE_65_69*FEMALE*INSTY ;
	CANC_65_69_F_inst_n	= AGE_65_69*FEMALE*INSTN ;
	CANC_65_69_M_inst_y	= AGE_65_69*MALE*INSTY ;
	CANC_65_69_M_inst_n	= AGE_65_69*MALE*INSTN ;

	CANC_65_69_F_epi_180_181= AGE_65_69*FEMALE*EP_180_181 ;	
	CANC_65_69_F_epi_182_183 = 	AGE_65_69*FEMALE*EP_182_183 ;
	CANC_65_69_M_epi_180_181= AGE_65_69*MALE*EP_180_181 ;	
	CANC_65_69_M_epi_182_183 = 	AGE_65_69*MALE*EP_182_183 ;

	CANC_65_69_F_cp_1_61= AGE_65_69*FEMALE*CP_1_61;		
	CANC_65_69_F_cp_62_730	= AGE_65_69*FEMALE*CP_62_730 ; 
	CANC_65_69_F_cp_none = AGE_65_69*FEMALE*CP_NONE;
	CANC_65_69_M_cp_1_61= AGE_65_69*MALE*CP_1_61;		
	CANC_65_69_M_cp_62_730	= AGE_65_69*MALE*CP_62_730 ; 
	CANC_65_69_M_cp_none = AGE_65_69*MALE*CP_NONE	;

	CANC_65_69_F_enroll_full_dual= AGE_65_69*FEMALE*ENROLL_FULL_DUAL ;
	CANC_65_69_F_enroll_no_pd	= AGE_65_69*FEMALE*ENROLL_NO_PD ;
	CANC_65_69_F_enroll_pd_lis	= AGE_65_69*FEMALE*ENROLL_PD_LIS ;
	CANC_65_69_F_enroll_pd_no_lis	= AGE_65_69*FEMALE*ENROLL_PD_NO_LIS ;
	CANC_65_69_M_enroll_full_dual= AGE_65_69*MALE*ENROLL_FULL_DUAL ;
	CANC_65_69_M_enroll_no_pd	= AGE_65_69*MALE*ENROLL_NO_PD ;
	CANC_65_69_M_enroll_pd_lis	= AGE_65_69*MALE*ENROLL_PD_LIS ;
	CANC_65_69_M_enroll_pd_no_lis	= AGE_65_69*MALE*ENROLL_PD_NO_LIS ;

	CANC_65_69_F_comorb_1 = AGE_65_69*FEMALE*COMORB_1 ;	
	CANC_65_69_F_comorb_2 = AGE_65_69*FEMALE*COMORB_2 ; 	
	CANC_65_69_F_comorb_3 = AGE_65_69*FEMALE*COMORB_3 ; 	
	CANC_65_69_F_comorb_4_5	 = AGE_65_69*FEMALE*COMORB_4_5 ; 
	CANC_65_69_F_comorb_6  = AGE_65_69*FEMALE*COMORB_6 ; 	
	CANC_65_69_F_comorb_new_enroll	 = AGE_65_69*FEMALE*COMORB_NEW_ENROLL ; 
	CANC_65_69_F_comorb_none	 = AGE_65_69*FEMALE*COMORB_NONE ; 
	CANC_65_69_M_comorb_1 = AGE_65_69*MALE*COMORB_1 ;	
	CANC_65_69_M_comorb_2 = AGE_65_69*MALE*COMORB_2 ; 	
	CANC_65_69_M_comorb_3 = AGE_65_69*MALE*COMORB_3 ; 	
	CANC_65_69_M_comorb_4_5	 = AGE_65_69*MALE*COMORB_4_5 ; 
	CANC_65_69_M_comorb_6  = AGE_65_69*MALE*COMORB_6 ; 	
	CANC_65_69_M_comorb_new_enroll	 = AGE_65_69*MALE*COMORB_NEW_ENROLL ; 
	CANC_65_69_M_comorb_none	 = AGE_65_69*MALE*COMORB_NONE ; 

	CANC_65_69_F_ct_y = AGE_65_69*FEMALE*CTY; 	
	CANC_65_69_F_ct_n = AGE_65_69*FEMALE*CTN; 		
	CANC_65_69_F_rad_y = AGE_65_69*FEMALE*RDY; 	
	CANC_65_69_F_rad_n = AGE_65_69*FEMALE*RDN; 		
	CANC_65_69_F_surg_y = AGE_65_69*FEMALE*SGY; 		
	CANC_65_69_F_surg_n	= AGE_65_69*FEMALE*SGN; 		
	CANC_65_69_F_bmt_al	= AGE_65_69*FEMALE*al; 		
	CANC_65_69_F_bmt_au	= AGE_65_69*FEMALE*au; 		
	CANC_65_69_F_bmt_none = AGE_65_69*FEMALE*anone; 			
	CANC_65_69_M_ct_y = AGE_65_69*MALE*CTY; 	
	CANC_65_69_M_ct_n = AGE_65_69*MALE*CTN; 		
	CANC_65_69_M_rad_y = AGE_65_69*MALE*RDY; 	
	CANC_65_69_M_rad_n = AGE_65_69*MALE*RDN; 		
	CANC_65_69_M_surg_y = AGE_65_69*MALE*SGY; 		
	CANC_65_69_M_surg_n	= AGE_65_69*MALE*SGN; 		
	CANC_65_69_M_bmt_al	= AGE_65_69*MALE*al; 		
	CANC_65_69_M_bmt_au	= AGE_65_69*MALE*au; 		
	CANC_65_69_M_bmt_none = AGE_65_69*MALE*anone; 			

	CANC_70_74_F_inst_y	= AGE_70_74*FEMALE*INSTY ;
	CANC_70_74_F_inst_n	= AGE_70_74*FEMALE*INSTN ;
	CANC_70_74_M_inst_y	= AGE_70_74*MALE*INSTY ;
	CANC_70_74_M_inst_n	= AGE_70_74*MALE*INSTN ;

	CANC_70_74_F_epi_180_181= AGE_70_74*FEMALE*EP_180_181 ;	
	CANC_70_74_F_epi_182_183 = 	AGE_70_74*FEMALE*EP_182_183 ;
	CANC_70_74_M_epi_180_181= AGE_70_74*MALE*EP_180_181 ;	
	CANC_70_74_M_epi_182_183 = 	AGE_70_74*MALE*EP_182_183 ;

	CANC_70_74_F_cp_1_61= AGE_70_74*FEMALE*CP_1_61;		
	CANC_70_74_F_cp_62_730	= AGE_70_74*FEMALE*CP_62_730 ; 
	CANC_70_74_F_cp_none = AGE_70_74*FEMALE*CP_NONE;
	CANC_70_74_M_cp_1_61= AGE_70_74*MALE*CP_1_61;		
	CANC_70_74_M_cp_62_730	= AGE_70_74*MALE*CP_62_730 ; 
	CANC_70_74_M_cp_none = AGE_70_74*MALE*CP_NONE	;

	CANC_70_74_F_enroll_full_dual= AGE_70_74*FEMALE*ENROLL_FULL_DUAL ;
	CANC_70_74_F_enroll_no_pd	= AGE_70_74*FEMALE*ENROLL_NO_PD ;
	CANC_70_74_F_enroll_pd_lis	= AGE_70_74*FEMALE*ENROLL_PD_LIS ;
	CANC_70_74_F_enroll_pd_no_lis	= AGE_70_74*FEMALE*ENROLL_PD_NO_LIS ;
	CANC_70_74_M_enroll_full_dual= AGE_70_74*MALE*ENROLL_FULL_DUAL ;
	CANC_70_74_M_enroll_no_pd	= AGE_70_74*MALE*ENROLL_NO_PD ;
	CANC_70_74_M_enroll_pd_lis	= AGE_70_74*MALE*ENROLL_PD_LIS ;
	CANC_70_74_M_enroll_pd_no_lis	= AGE_70_74*MALE*ENROLL_PD_NO_LIS ;

	CANC_70_74_F_comorb_1 = AGE_70_74*FEMALE*COMORB_1 ;	
	CANC_70_74_F_comorb_2 = AGE_70_74*FEMALE*COMORB_2 ; 	
	CANC_70_74_F_comorb_3 = AGE_70_74*FEMALE*COMORB_3 ; 	
	CANC_70_74_F_comorb_4_5	 = AGE_70_74*FEMALE*COMORB_4_5 ; 
	CANC_70_74_F_comorb_6  = AGE_70_74*FEMALE*COMORB_6 ; 	
	CANC_70_74_F_comorb_new_enroll	 = AGE_70_74*FEMALE*COMORB_NEW_ENROLL ; 
	CANC_70_74_F_comorb_none	 = AGE_70_74*FEMALE*COMORB_NONE ; 
	CANC_70_74_M_comorb_1 = AGE_70_74*MALE*COMORB_1 ;	
	CANC_70_74_M_comorb_2 = AGE_70_74*MALE*COMORB_2 ; 	
	CANC_70_74_M_comorb_3 = AGE_70_74*MALE*COMORB_3 ; 	
	CANC_70_74_M_comorb_4_5	 = AGE_70_74*MALE*COMORB_4_5 ; 
	CANC_70_74_M_comorb_6  = AGE_70_74*MALE*COMORB_6 ; 	
	CANC_70_74_M_comorb_new_enroll	 = AGE_70_74*MALE*COMORB_NEW_ENROLL ; 
	CANC_70_74_M_comorb_none	 = AGE_70_74*MALE*COMORB_NONE ; 

	CANC_70_74_F_ct_y = AGE_70_74*FEMALE*CTY; 	
	CANC_70_74_F_ct_n = AGE_70_74*FEMALE*CTN; 		
	CANC_70_74_F_rad_y = AGE_70_74*FEMALE*RDY; 	
	CANC_70_74_F_rad_n = AGE_70_74*FEMALE*RDN; 		
	CANC_70_74_F_surg_y = AGE_70_74*FEMALE*SGY; 		
	CANC_70_74_F_surg_n	= AGE_70_74*FEMALE*SGN; 		
	CANC_70_74_F_bmt_al	= AGE_70_74*FEMALE*al; 		
	CANC_70_74_F_bmt_au	= AGE_70_74*FEMALE*au; 		
	CANC_70_74_F_bmt_none = AGE_70_74*FEMALE*anone; 			
	CANC_70_74_M_ct_y = AGE_70_74*MALE*CTY; 	
	CANC_70_74_M_ct_n = AGE_70_74*MALE*CTN; 		
	CANC_70_74_M_rad_y = AGE_70_74*MALE*RDY; 	
	CANC_70_74_M_rad_n = AGE_70_74*MALE*RDN; 		
	CANC_70_74_M_surg_y = AGE_70_74*MALE*SGY; 		
	CANC_70_74_M_surg_n	= AGE_70_74*MALE*SGN; 		
	CANC_70_74_M_bmt_al	= AGE_70_74*MALE*al; 		
	CANC_70_74_M_bmt_au	= AGE_70_74*MALE*au; 		
	CANC_70_74_M_bmt_none = AGE_70_74*MALE*anone; 			

	CANC_75_79_F_inst_y	= AGE_75_79*FEMALE*INSTY ;
	CANC_75_79_F_inst_n	= AGE_75_79*FEMALE*INSTN ;
	CANC_75_79_M_inst_y	= AGE_75_79*MALE*INSTY ;
	CANC_75_79_M_inst_n	= AGE_75_79*MALE*INSTN ;

	CANC_75_79_F_epi_180_181= AGE_75_79*FEMALE*EP_180_181 ;	
	CANC_75_79_F_epi_182_183 = 	AGE_75_79*FEMALE*EP_182_183 ;
	CANC_75_79_M_epi_180_181= AGE_75_79*MALE*EP_180_181 ;	
	CANC_75_79_M_epi_182_183 = 	AGE_75_79*MALE*EP_182_183 ;

	CANC_75_79_F_cp_1_61= AGE_75_79*FEMALE*CP_1_61;		
	CANC_75_79_F_cp_62_730	= AGE_75_79*FEMALE*CP_62_730 ; 
	CANC_75_79_F_cp_none = AGE_75_79*FEMALE*CP_NONE	;
	CANC_75_79_M_cp_1_61= AGE_75_79*MALE*CP_1_61;		
	CANC_75_79_M_cp_62_730	= AGE_75_79*MALE*CP_62_730 ; 
	CANC_75_79_M_cp_none = AGE_75_79*MALE*CP_NONE	;

	CANC_75_79_F_enroll_full_dual= AGE_75_79*FEMALE*ENROLL_FULL_DUAL ;
	CANC_75_79_F_enroll_no_pd	= AGE_75_79*FEMALE*ENROLL_NO_PD ;
	CANC_75_79_F_enroll_pd_lis	= AGE_75_79*FEMALE*ENROLL_PD_LIS ;
	CANC_75_79_F_enroll_pd_no_lis	= AGE_75_79*FEMALE*ENROLL_PD_NO_LIS ;
	CANC_75_79_M_enroll_full_dual= AGE_75_79*MALE*ENROLL_FULL_DUAL ;
	CANC_75_79_M_enroll_no_pd	= AGE_75_79*MALE*ENROLL_NO_PD ;
	CANC_75_79_M_enroll_pd_lis	= AGE_75_79*MALE*ENROLL_PD_LIS ;
	CANC_75_79_M_enroll_pd_no_lis	= AGE_75_79*MALE*ENROLL_PD_NO_LIS ;

	CANC_75_79_F_comorb_1 = AGE_75_79*FEMALE*COMORB_1 ;	
	CANC_75_79_F_comorb_2 = AGE_75_79*FEMALE*COMORB_2 ; 	
	CANC_75_79_F_comorb_3 = AGE_75_79*FEMALE*COMORB_3 ; 	
	CANC_75_79_F_comorb_4_5	 = AGE_75_79*FEMALE*COMORB_4_5 ; 
	CANC_75_79_F_comorb_6  = AGE_75_79*FEMALE*COMORB_6 ; 	
	CANC_75_79_F_comorb_new_enroll	 = AGE_75_79*FEMALE*COMORB_NEW_ENROLL ; 
	CANC_75_79_F_comorb_none	 = AGE_75_79*FEMALE*COMORB_NONE ; 
	CANC_75_79_M_comorb_1 = AGE_75_79*MALE*COMORB_1 ;	
	CANC_75_79_M_comorb_2 = AGE_75_79*MALE*COMORB_2 ; 	
	CANC_75_79_M_comorb_3 = AGE_75_79*MALE*COMORB_3 ; 	
	CANC_75_79_M_comorb_4_5	 = AGE_75_79*MALE*COMORB_4_5 ; 
	CANC_75_79_M_comorb_6  = AGE_75_79*MALE*COMORB_6 ; 	
	CANC_75_79_M_comorb_new_enroll	 = AGE_75_79*MALE*COMORB_NEW_ENROLL ; 
	CANC_75_79_M_comorb_none	 = AGE_75_79*MALE*COMORB_NONE ; 

	CANC_75_79_F_ct_y = AGE_75_79*FEMALE*CTY; 	
	CANC_75_79_F_ct_n = AGE_75_79*FEMALE*CTN; 		
	CANC_75_79_F_rad_y = AGE_75_79*FEMALE*RDY; 	
	CANC_75_79_F_rad_n = AGE_75_79*FEMALE*RDN; 		
	CANC_75_79_F_surg_y = AGE_75_79*FEMALE*SGY; 		
	CANC_75_79_F_surg_n	= AGE_75_79*FEMALE*SGN; 		
	CANC_75_79_F_bmt_al	= AGE_75_79*FEMALE*al; 		
	CANC_75_79_F_bmt_au	= AGE_75_79*FEMALE*au; 		
	CANC_75_79_F_bmt_none = AGE_75_79*FEMALE*anone; 			
	CANC_75_79_M_ct_y = AGE_75_79*MALE*CTY; 	
	CANC_75_79_M_ct_n = AGE_75_79*MALE*CTN; 		
	CANC_75_79_M_rad_y = AGE_75_79*MALE*RDY; 	
	CANC_75_79_M_rad_n = AGE_75_79*MALE*RDN; 		
	CANC_75_79_M_surg_y = AGE_75_79*MALE*SGY; 		
	CANC_75_79_M_surg_n	= AGE_75_79*MALE*SGN; 		
	CANC_75_79_M_bmt_al	= AGE_75_79*MALE*al; 		
	CANC_75_79_M_bmt_au	= AGE_75_79*MALE*au; 		
	CANC_75_79_M_bmt_none = AGE_75_79*MALE*anone; 			

	CANC_80_F_inst_y	= AGE_80*FEMALE*INSTY ;
	CANC_80_F_inst_n	= AGE_80*FEMALE*INSTN ;
	CANC_80_M_inst_y	= AGE_80*MALE*INSTY ;
	CANC_80_M_inst_n	= AGE_80*MALE*INSTN ;

	CANC_80_F_epi_180_181= AGE_80*FEMALE*EP_180_181 ;	
	CANC_80_F_epi_182_183 = 	AGE_80*FEMALE*EP_182_183 ;
	CANC_80_M_epi_180_181= AGE_80*MALE*EP_180_181 ;	
	CANC_80_M_epi_182_183 = 	AGE_80*MALE*EP_182_183 ;

	CANC_80_F_cp_1_61= AGE_80*FEMALE*CP_1_61;		
	CANC_80_F_cp_62_730	= AGE_80*FEMALE*CP_62_730 ; 
	CANC_80_F_cp_none = AGE_80*FEMALE*CP_NONE	;
	CANC_80_M_cp_1_61= AGE_80*MALE*CP_1_61;		
	CANC_80_M_cp_62_730	= AGE_80*MALE*CP_62_730 ; 
	CANC_80_M_cp_none = AGE_80*MALE*CP_NONE;

	CANC_80_F_enroll_full_dual= AGE_80*FEMALE*ENROLL_FULL_DUAL ;
	CANC_80_F_enroll_no_pd	= AGE_80*FEMALE*ENROLL_NO_PD ;
	CANC_80_F_enroll_pd_lis	= AGE_80*FEMALE*ENROLL_PD_LIS ;
	CANC_80_F_enroll_pd_no_lis	= AGE_80*FEMALE*ENROLL_PD_NO_LIS ;
	CANC_80_M_enroll_full_dual= AGE_80*MALE*ENROLL_FULL_DUAL ;
	CANC_80_M_enroll_no_pd	= AGE_80*MALE*ENROLL_NO_PD ;
	CANC_80_M_enroll_pd_lis	= AGE_80*MALE*ENROLL_PD_LIS ;
	CANC_80_M_enroll_pd_no_lis	= AGE_80*MALE*ENROLL_PD_NO_LIS ;

	CANC_80_F_comorb_1 = AGE_80*FEMALE*COMORB_1 ;	
	CANC_80_F_comorb_2 = AGE_80*FEMALE*COMORB_2 ; 	
	CANC_80_F_comorb_3 = AGE_80*FEMALE*COMORB_3 ; 	
	CANC_80_F_comorb_4_5	 = AGE_80*FEMALE*COMORB_4_5 ; 
	CANC_80_F_comorb_6  = AGE_80*FEMALE*COMORB_6 ; 	
	CANC_80_F_comorb_new_enroll	 = AGE_80*FEMALE*COMORB_NEW_ENROLL ; 
	CANC_80_F_comorb_none	 = AGE_80*FEMALE*COMORB_NONE ; 
	CANC_80_M_comorb_1 = AGE_80*MALE*COMORB_1 ;	
	CANC_80_M_comorb_2 = AGE_80*MALE*COMORB_2 ; 	
	CANC_80_M_comorb_3 = AGE_80*MALE*COMORB_3 ; 	
	CANC_80_M_comorb_4_5	 = AGE_80*MALE*COMORB_4_5 ; 
	CANC_80_M_comorb_6  = AGE_80*MALE*COMORB_6 ; 	
	CANC_80_M_comorb_new_enroll	 = AGE_80*MALE*COMORB_NEW_ENROLL ; 
	CANC_80_M_comorb_none	 = AGE_80*MALE*COMORB_NONE ; 

	CANC_80_F_ct_y = AGE_80*FEMALE*CTY; 	
	CANC_80_F_ct_n = AGE_80*FEMALE*CTN; 		
	CANC_80_F_rad_y = AGE_80*FEMALE*RDY; 	
	CANC_80_F_rad_n = AGE_80*FEMALE*RDN; 		
	CANC_80_F_surg_y = AGE_80*FEMALE*SGY; 		
	CANC_80_F_surg_n	= AGE_80*FEMALE*SGN; 		
	CANC_80_F_bmt_al	= AGE_80*FEMALE*al; 		
	CANC_80_F_bmt_au	= AGE_80*FEMALE*au; 		
	CANC_80_F_bmt_none = AGE_80*FEMALE*anone; 			
	CANC_80_M_ct_y = AGE_80*MALE*CTY; 	
	CANC_80_M_ct_n = AGE_80*MALE*CTN; 		
	CANC_80_M_rad_y = AGE_80*MALE*RDY; 	
	CANC_80_M_rad_n = AGE_80*MALE*RDN; 		
	CANC_80_M_surg_y = AGE_80*MALE*SGY; 		
	CANC_80_M_surg_n	= AGE_80*MALE*SGN; 		
	CANC_80_M_bmt_al	= AGE_80*MALE*al; 		
	CANC_80_M_bmt_au	= AGE_80*MALE*au; 		
	CANC_80_M_bmt_none = AGE_80*MALE*anone; 			

PROC FREQ DATA=STEP1 ; TABLES CANCER_TYPE_MILLIMAN ; RUN ;

************************************************************************** ;
	%MACRO CN(CN,C) ;
	
	IF CANCER_TYPE_MILLIMAN = "&cn." THEN DO ;

			*** DENOMINATOR VARIABLES *** ;
			&C._18_64_F = episode_count*female*age_18_64 ;
			&C._18_64_M = episode_count*male*age_18_64 ;
			&C._65_69_F = episode_count*female*age_65_69 ;
			&C._65_69_M = episode_count*male*age_65_69 ;
			&C._70_74_F = episode_count*female*age_70_74 ;
			&C._70_74_M = episode_count*male*age_70_74 ;
			&C._75_79_F = episode_count*female*age_75_79 ;
			&C._75_79_M = episode_count*male*age_75_79 ;
			&C._80_F = episode_count*female*age_80 ;
			&C._80_M = episode_count*male*age_80 ;


			*** PREDICTION VARIABLES *** ;
			&C._18_64_F_inst_y	= CANC_18_64_F_inst_y	;
			&C._18_64_F_inst_n = CANC_18_64_F_inst_n	;
			&C._18_64_M_inst_y = CANC_18_64_M_inst_y	;
			&C._18_64_M_inst_n	= CANC_18_64_M_inst_n	;

			&C._18_64_F_epi_180_181 = CANC_18_64_F_epi_180_181;
			&C._18_64_F_epi_182_183 = CANC_18_64_F_epi_182_183;
			&C._18_64_M_epi_180_181 = CANC_18_64_M_epi_180_181;
			&C._18_64_M_epi_182_183 = CANC_18_64_M_epi_182_183;

			&C._18_64_F_cp_1_61=CANC_18_64_F_cp_1_61;
			&C._18_64_F_cp_62_730=CANC_18_64_F_cp_62_730;
			&C._18_64_F_cp_none=CANC_18_64_F_cp_none ;
			&C._18_64_M_cp_1_61=CANC_18_64_M_cp_1_61;
			&C._18_64_M_cp_62_730 = CANC_18_64_M_cp_62_730;
			&C._18_64_M_cp_none=CANC_18_64_M_cp_none ;

			&C._18_64_F_enroll_full_dual=CANC_18_64_F_enroll_full_dual;
			&C._18_64_F_enroll_no_pd=CANC_18_64_F_enroll_no_pd	;
			&C._18_64_F_enroll_pd_lis=CANC_18_64_F_enroll_pd_lis	;
			&C._18_64_F_enroll_pd_no_lis=CANC_18_64_F_enroll_pd_no_lis;
			&C._18_64_M_enroll_full_dual=CANC_18_64_M_enroll_full_dual;
			&C._18_64_M_enroll_no_pd=CANC_18_64_M_enroll_no_pd	;
			&C._18_64_M_enroll_pd_lis=CANC_18_64_M_enroll_pd_lis	;
			&C._18_64_M_enroll_pd_no_lis=CANC_18_64_M_enroll_pd_no_lis;	

			&C._18_64_F_comorb_1=CANC_18_64_F_comorb_1 ;
			&C._18_64_F_comorb_2=CANC_18_64_F_comorb_2 ;
			&C._18_64_F_comorb_3=CANC_18_64_F_comorb_3 ;
			&C._18_64_F_comorb_4_5=CANC_18_64_F_comorb_4_5; 
			&C._18_64_F_comorb_6 =CANC_18_64_F_comorb_6  ; 	
			&C._18_64_F_comorb_new_enroll=CANC_18_64_F_comorb_new_enroll	 ; 
			&C._18_64_F_comorb_none=CANC_18_64_F_comorb_none	 ; 
			&C._18_64_M_comorb_1 = CANC_18_64_M_comorb_1;	
			&C._18_64_M_comorb_2 = CANC_18_64_M_comorb_2; 	
			&C._18_64_M_comorb_3 = CANC_18_64_M_comorb_3; 	
			&C._18_64_M_comorb_4_5 =CANC_18_64_M_comorb_4_5	 ; 
			&C._18_64_M_comorb_6 = CANC_18_64_M_comorb_6  ; 	
			&C._18_64_M_comorb_new_enroll = CANC_18_64_M_comorb_new_enroll	 ; 
			&C._18_64_M_comorb_none = CANC_18_64_M_comorb_none	 ; 

			&C._18_64_F_ct_y=CANC_18_64_F_ct_y ; 	
			&C._18_64_F_ct_n=CANC_18_64_F_ct_n ; 		
			&C._18_64_F_rad_y=CANC_18_64_F_rad_y ; 	
			&C._18_64_F_rad_n=CANC_18_64_F_rad_n ; 		
			&C._18_64_F_surg_y=CANC_18_64_F_surg_y ; 		
			&C._18_64_F_surg_n=CANC_18_64_F_surg_n	; 		
			&C._18_64_F_bmt_al=CANC_18_64_F_bmt_al	; 		
			&C._18_64_F_bmt_au=CANC_18_64_F_bmt_au	; 		
			&C._18_64_F_bmt_none=CANC_18_64_F_bmt_none ; 			
			&C._18_64_M_ct_y=CANC_18_64_M_ct_y ; 	
			&C._18_64_M_ct_n=CANC_18_64_M_ct_n ; 		
			&C._18_64_M_rad_y=CANC_18_64_M_rad_y ; 	
			&C._18_64_M_rad_n=CANC_18_64_M_rad_n ; 		
			&C._18_64_M_surg_y=CANC_18_64_M_surg_y ; 		
			&C._18_64_M_surg_n	=CANC_18_64_M_surg_n	; 		
			&C._18_64_M_bmt_al	=CANC_18_64_M_bmt_al	; 		
			&C._18_64_M_bmt_au=CANC_18_64_M_bmt_au	; 		
			&C._18_64_M_bmt_none=CANC_18_64_M_bmt_none ; 			

			&C._65_69_F_inst_y=CANC_65_69_F_inst_y	;
			&C._65_69_F_inst_n=CANC_65_69_F_inst_n	;
			&C._65_69_M_inst_y=CANC_65_69_M_inst_y	;
			&C._65_69_M_inst_n=CANC_65_69_M_inst_n	;

			&C._65_69_F_epi_180_181=CANC_65_69_F_epi_180_181;	
			&C._65_69_F_epi_182_183=CANC_65_69_F_epi_182_183;
			&C._65_69_M_epi_180_181=CANC_65_69_M_epi_180_181;	
			&C._65_69_M_epi_182_183=CANC_65_69_M_epi_182_183;

			&C._65_69_F_cp_1_61=CANC_65_69_F_cp_1_61;		
			&C._65_69_F_cp_62_730=CANC_65_69_F_cp_62_730; 
			&C._65_69_F_cp_none=CANC_65_69_F_cp_none ;
			&C._65_69_M_cp_1_61=CANC_65_69_M_cp_1_61;		
			&C._65_69_M_cp_62_730=CANC_65_69_M_cp_62_730; 
			&C._65_69_M_cp_none=CANC_65_69_M_cp_none ;

			&C._65_69_F_enroll_full_dual=CANC_65_69_F_enroll_full_dual;
			&C._65_69_F_enroll_no_pd=CANC_65_69_F_enroll_no_pd	;
			&C._65_69_F_enroll_pd_lis=CANC_65_69_F_enroll_pd_lis	;
			&C._65_69_F_enroll_pd_no_lis=CANC_65_69_F_enroll_pd_no_lis	;
			&C._65_69_M_enroll_full_dual=CANC_65_69_M_enroll_full_dual;
			&C._65_69_M_enroll_no_pd=CANC_65_69_M_enroll_no_pd	;
			&C._65_69_M_enroll_pd_lis=CANC_65_69_M_enroll_pd_lis	;
			&C._65_69_M_enroll_pd_no_lis=CANC_65_69_M_enroll_pd_no_lis;

			&C._65_69_F_comorb_1=CANC_65_69_F_comorb_1 ;	
			&C._65_69_F_comorb_2=CANC_65_69_F_comorb_2 ; 	
			&C._65_69_F_comorb_3=CANC_65_69_F_comorb_3 ; 	
			&C._65_69_F_comorb_4_5=CANC_65_69_F_comorb_4_5	; 
			&C._65_69_F_comorb_6=CANC_65_69_F_comorb_6  ; 	
			&C._65_69_F_comorb_new_enroll=CANC_65_69_F_comorb_new_enroll	 ; 
			&C._65_69_F_comorb_none=CANC_65_69_F_comorb_none	 ; 
			&C._65_69_M_comorb_1=CANC_65_69_M_comorb_1  ;	
			&C._65_69_M_comorb_2=CANC_65_69_M_comorb_2 ; 	
			&C._65_69_M_comorb_3=CANC_65_69_M_comorb_3 ; 	
			&C._65_69_M_comorb_4_5=CANC_65_69_M_comorb_4_5	; 
			&C._65_69_M_comorb_6=CANC_65_69_M_comorb_6  ; 	
			&C._65_69_M_comorb_new_enroll=CANC_65_69_M_comorb_new_enroll	  ; 
			&C._65_69_M_comorb_none=CANC_65_69_M_comorb_none	 ; 

			&C._65_69_F_ct_y=CANC_65_69_F_ct_y ; 	
			&C._65_69_F_ct_n=CANC_65_69_F_ct_n ; 		
			&C._65_69_F_rad_y=CANC_65_69_F_rad_y; 	
			&C._65_69_F_rad_n=CANC_65_69_F_rad_n ; 		
			&C._65_69_F_surg_y=CANC_65_69_F_surg_y; 		
			&C._65_69_F_surg_n=CANC_65_69_F_surg_n	; 		
			&C._65_69_F_bmt_al=CANC_65_69_F_bmt_al	; 		
			&C._65_69_F_bmt_au=CANC_65_69_F_bmt_au	; 		
			&C._65_69_F_bmt_none=CANC_65_69_F_bmt_none ; 			
			&C._65_69_M_ct_y=CANC_65_69_M_ct_y  ; 	
			&C._65_69_M_ct_n=CANC_65_69_M_ct_n  ; 		
			&C._65_69_M_rad_y=CANC_65_69_M_rad_y  ; 	
			&C._65_69_M_rad_n=CANC_65_69_M_rad_n  ; 		
			&C._65_69_M_surg_y=CANC_65_69_M_surg_y  ; 		
			&C._65_69_M_surg_n=CANC_65_69_M_surg_n	 ; 		
			&C._65_69_M_bmt_al	=CANC_65_69_M_bmt_al	 ; 		
			&C._65_69_M_bmt_au	=CANC_65_69_M_bmt_au	 ; 		
			&C._65_69_M_bmt_none=CANC_65_69_M_bmt_none  ; 			

			&C._70_74_F_inst_y=CANC_70_74_F_inst_y	;
			&C._70_74_F_inst_n=CANC_70_74_F_inst_n	;
			&C._70_74_M_inst_y	=CANC_70_74_M_inst_y	;
			&C._70_74_M_inst_n	=CANC_70_74_M_inst_n	;

			&C._70_74_F_epi_180_181=CANC_70_74_F_epi_180_181;	
			&C._70_74_F_epi_182_183=CANC_70_74_F_epi_182_183;
			&C._70_74_M_epi_180_181=CANC_70_74_M_epi_180_181;	
			&C._70_74_M_epi_182_183=CANC_70_74_M_epi_182_183;

			&C._70_74_F_cp_1_61=CANC_70_74_F_cp_1_61;		
			&C._70_74_F_cp_62_730=CANC_70_74_F_cp_62_730; 
			&C._70_74_F_cp_none=CANC_70_74_F_cp_none;
			&C._70_74_M_cp_1_61=CANC_70_74_M_cp_1_61;		
			&C._70_74_M_cp_62_730=CANC_70_74_M_cp_62_730; 
			&C._70_74_M_cp_none=CANC_70_74_M_cp_none ;

			&C._70_74_F_enroll_full_dual=CANC_70_74_F_enroll_full_dual;
			&C._70_74_F_enroll_no_pd=CANC_70_74_F_enroll_no_pd;
			&C._70_74_F_enroll_pd_lis=CANC_70_74_F_enroll_pd_lis;
			&C._70_74_F_enroll_pd_no_lis=CANC_70_74_F_enroll_pd_no_lis;
			&C._70_74_M_enroll_full_dual=CANC_70_74_M_enroll_full_dual;
			&C._70_74_M_enroll_no_pd=CANC_70_74_M_enroll_no_pd	;
			&C._70_74_M_enroll_pd_lis=CANC_70_74_M_enroll_pd_lis	;
			&C._70_74_M_enroll_pd_no_lis=CANC_70_74_M_enroll_pd_no_lis;

			&C._70_74_F_comorb_1=CANC_70_74_F_comorb_1 ;	
			&C._70_74_F_comorb_2=CANC_70_74_F_comorb_2 ; 	
			&C._70_74_F_comorb_3=CANC_70_74_F_comorb_3 ; 	
			&C._70_74_F_comorb_4_5=CANC_70_74_F_comorb_4_5	; 
			&C._70_74_F_comorb_6=CANC_70_74_F_comorb_6 ; 	
			&C._70_74_F_comorb_new_enroll=CANC_70_74_F_comorb_new_enroll	 ; 
			&C._70_74_F_comorb_none=CANC_70_74_F_comorb_none	 ; 
			&C._70_74_M_comorb_1=CANC_70_74_M_comorb_1 ;	
			&C._70_74_M_comorb_2=CANC_70_74_M_comorb_2 ; 	
			&C._70_74_M_comorb_3=CANC_70_74_M_comorb_3 ; 	
			&C._70_74_M_comorb_4_5=CANC_70_74_M_comorb_4_5	 ; 
			&C._70_74_M_comorb_6=CANC_70_74_M_comorb_6  ; 	
			&C._70_74_M_comorb_new_enroll=CANC_70_74_M_comorb_new_enroll	 ; 
			&C._70_74_M_comorb_none=CANC_70_74_M_comorb_none	  ; 

			&C._70_74_F_ct_y=CANC_70_74_F_ct_y ; 	
			&C._70_74_F_ct_n=CANC_70_74_F_ct_n ; 		
			&C._70_74_F_rad_y=CANC_70_74_F_rad_y; 	
			&C._70_74_F_rad_n=CANC_70_74_F_rad_n ; 		
			&C._70_74_F_surg_y=CANC_70_74_F_surg_y ; 		
			&C._70_74_F_surg_n=CANC_70_74_F_surg_n	; 		
			&C._70_74_F_bmt_al=CANC_70_74_F_bmt_al	; 		
			&C._70_74_F_bmt_au=CANC_70_74_F_bmt_au	; 		
			&C._70_74_F_bmt_none=CANC_70_74_F_bmt_none ; 			
			&C._70_74_M_ct_y=CANC_70_74_M_ct_y  ; 	
			&C._70_74_M_ct_n=CANC_70_74_M_ct_n  ; 		
			&C._70_74_M_rad_y=CANC_70_74_M_rad_y ; 	
			&C._70_74_M_rad_n=CANC_70_74_M_rad_n  ; 		
			&C._70_74_M_surg_y=CANC_70_74_M_surg_y  ; 		
			&C._70_74_M_surg_n=CANC_70_74_M_surg_n	 ; 		
			&C._70_74_M_bmt_al=CANC_70_74_M_bmt_al	 ; 		
			&C._70_74_M_bmt_au=CANC_70_74_M_bmt_au	 ; 		
			&C._70_74_M_bmt_none=CANC_70_74_M_bmt_none ; 			

			&C._75_79_F_inst_y=CANC_75_79_F_inst_y	 ;
			&C._75_79_F_inst_n=CANC_75_79_F_inst_n	 ;
			&C._75_79_M_inst_y=CANC_75_79_M_inst_y	 ;
			&C._75_79_M_inst_n=CANC_75_79_M_inst_n	;

			&C._75_79_F_epi_180_181=CANC_75_79_F_epi_180_181;	
			&C._75_79_F_epi_182_183=CANC_75_79_F_epi_182_183;
			&C._75_79_M_epi_180_181=CANC_75_79_M_epi_180_181 ;	
			&C._75_79_M_epi_182_183=CANC_75_79_M_epi_182_183;

			&C._75_79_F_cp_1_61=CANC_75_79_F_cp_1_61;		
			&C._75_79_F_cp_62_730=CANC_75_79_F_cp_62_730	; 
			&C._75_79_F_cp_none=CANC_75_79_F_cp_none ;
			&C._75_79_M_cp_1_61=CANC_75_79_M_cp_1_61;		
			&C._75_79_M_cp_62_730=CANC_75_79_M_cp_62_730; 
			&C._75_79_M_cp_none=CANC_75_79_M_cp_none ;

			&C._75_79_F_enroll_full_dual=CANC_75_79_F_enroll_full_dual ;
			&C._75_79_F_enroll_no_pd=CANC_75_79_F_enroll_no_pd;
			&C._75_79_F_enroll_pd_lis=CANC_75_79_F_enroll_pd_lis;
			&C._75_79_F_enroll_pd_no_lis=CANC_75_79_F_enroll_pd_no_lis;
			&C._75_79_M_enroll_full_dual=CANC_75_79_M_enroll_full_dual;
			&C._75_79_M_enroll_no_pd=CANC_75_79_M_enroll_no_pd	;
			&C._75_79_M_enroll_pd_lis=CANC_75_79_M_enroll_pd_lis	;
			&C._75_79_M_enroll_pd_no_lis=CANC_75_79_M_enroll_pd_no_lis;

			&C._75_79_F_comorb_1 =CANC_75_79_F_comorb_1  ;	
			&C._75_79_F_comorb_2 = CANC_75_79_F_comorb_2 ; 	
			&C._75_79_F_comorb_3 = CANC_75_79_F_comorb_3 ; 	
			&C._75_79_F_comorb_4_5 = CANC_75_79_F_comorb_4_5; 
			&C._75_79_F_comorb_6 = CANC_75_79_F_comorb_6  ; 	
			&C._75_79_F_comorb_new_enroll = CANC_75_79_F_comorb_new_enroll	 ; 
			&C._75_79_F_comorb_none = CANC_75_79_F_comorb_none	 ; 
			&C._75_79_M_comorb_1 = CANC_75_79_M_comorb_1  ;	
			&C._75_79_M_comorb_2 = CANC_75_79_M_comorb_2  ; 	
			&C._75_79_M_comorb_3 = CANC_75_79_M_comorb_3  ; 	
			&C._75_79_M_comorb_4_5 = CANC_75_79_M_comorb_4_5	 ; 
			&C._75_79_M_comorb_6 = CANC_75_79_M_comorb_6 ; 	
			&C._75_79_M_comorb_new_enroll = CANC_75_79_M_comorb_new_enroll	 ; 
			&C._75_79_M_comorb_none = CANC_75_79_M_comorb_none	  ; 

			&C._75_79_F_ct_y=CANC_75_79_F_ct_y ; 	
			&C._75_79_F_ct_n=CANC_75_79_F_ct_n ; 		
			&C._75_79_F_rad_y=CANC_75_79_F_rad_y; 	
			&C._75_79_F_rad_n=CANC_75_79_F_rad_n; 		
			&C._75_79_F_surg_y=CANC_75_79_F_surg_y; 		
			&C._75_79_F_surg_n=CANC_75_79_F_surg_n; 		
			&C._75_79_F_bmt_al=CANC_75_79_F_bmt_al; 		
			&C._75_79_F_bmt_au=CANC_75_79_F_bmt_au; 		
			&C._75_79_F_bmt_none=CANC_75_79_F_bmt_none; 			
			&C._75_79_M_ct_y=CANC_75_79_M_ct_y ; 	
			&C._75_79_M_ct_n=CANC_75_79_M_ct_n ; 		
			&C._75_79_M_rad_y=CANC_75_79_M_rad_y ; 	
			&C._75_79_M_rad_n=CANC_75_79_M_rad_n ; 		
			&C._75_79_M_surg_y=CANC_75_79_M_surg_y ; 		
			&C._75_79_M_surg_n=CANC_75_79_M_surg_n	; 		
			&C._75_79_M_bmt_al=CANC_75_79_M_bmt_al	; 		
			&C._75_79_M_bmt_au=CANC_75_79_M_bmt_au	; 		
			&C._75_79_M_bmt_none=CANC_75_79_M_bmt_none; 			

			&C._80_F_inst_y = CANC_80_F_inst_y	 ;
			&C._80_F_inst_n = CANC_80_F_inst_n	 ;
			&C._80_M_inst_y = CANC_80_M_inst_y	;
			&C._80_M_inst_n = CANC_80_M_inst_n	;

			&C._80_F_epi_180_181= CANC_80_F_epi_180_181;	
			&C._80_F_epi_182_183 = CANC_80_F_epi_182_183;
			&C._80_M_epi_180_181 = CANC_80_M_epi_180_181;	
			&C._80_M_epi_182_183 = CANC_80_M_epi_182_183;

			&C._80_F_cp_1_61=CANC_80_F_cp_1_61;		
			&C._80_F_cp_62_730=CANC_80_F_cp_62_730; 
			&C._80_F_cp_none=CANC_80_F_cp_none ;
			&C._80_M_cp_1_61=CANC_80_M_cp_1_61;		
			&C._80_M_cp_62_730=CANC_80_M_cp_62_730	; 
			&C._80_M_cp_none=CANC_80_M_cp_none 	;

			&C._80_F_enroll_full_dual = CANC_80_F_enroll_full_dual;
			&C._80_F_enroll_no_pd = CANC_80_F_enroll_no_pd	;
			&C._80_F_enroll_pd_lis = CANC_80_F_enroll_pd_lis	;
			&C._80_F_enroll_pd_no_lis = CANC_80_F_enroll_pd_no_lis;
			&C._80_M_enroll_full_dual = CANC_80_M_enroll_full_dual;
			&C._80_M_enroll_no_pd = CANC_80_M_enroll_no_pd	;
			&C._80_M_enroll_pd_lis = CANC_80_M_enroll_pd_lis	;
			&C._80_M_enroll_pd_no_lis = CANC_80_M_enroll_pd_no_lis;

			&C._80_F_comorb_1=CANC_80_F_comorb_1 ;	
			&C._80_F_comorb_2=CANC_80_F_comorb_2 ; 	
			&C._80_F_comorb_3=CANC_80_F_comorb_3 ; 	
			&C._80_F_comorb_4_5=CANC_80_F_comorb_4_5; 
			&C._80_F_comorb_6=CANC_80_F_comorb_6  ; 	
			&C._80_F_comorb_new_enroll=CANC_80_F_comorb_new_enroll	  ; 
			&C._80_F_comorb_none=CANC_80_F_comorb_none	 ; 
			&C._80_M_comorb_1=CANC_80_M_comorb_1 ;	
			&C._80_M_comorb_2=CANC_80_M_comorb_2 ; 	
			&C._80_M_comorb_3=CANC_80_M_comorb_3 ; 	
			&C._80_M_comorb_4_5=CANC_80_M_comorb_4_5; 
			&C._80_M_comorb_6=CANC_80_M_comorb_6  ; 	
			&C._80_M_comorb_new_enroll=CANC_80_M_comorb_new_enroll	 ; 
			&C._80_M_comorb_none=CANC_80_M_comorb_none	 ; 

			&C._80_F_ct_y=CANC_80_F_ct_y ; 	
			&C._80_F_ct_n=CANC_80_F_ct_n ; 		
			&C._80_F_rad_y=CANC_80_F_rad_y ; 	
			&C._80_F_rad_n=CANC_80_F_rad_n ; 		
			&C._80_F_surg_y=CANC_80_F_surg_y ; 		
			&C._80_F_surg_n=CANC_80_F_surg_n; 		
			&C._80_F_bmt_al=CANC_80_F_bmt_al; 		
			&C._80_F_bmt_au=CANC_80_F_bmt_au; 		
			&C._80_F_bmt_none=CANC_80_F_bmt_none ; 			
			&C._80_M_ct_y=CANC_80_M_ct_y ; 	
			&C._80_M_ct_n=CANC_80_M_ct_n ; 		
			&C._80_M_rad_y=CANC_80_M_rad_y ; 	
			&C._80_M_rad_n=CANC_80_M_rad_n ; 		
			&C._80_M_surg_y=CANC_80_M_surg_y ; 		
			&C._80_M_surg_n=CANC_80_M_surg_n; 		
			&C._80_M_bmt_al=CANC_80_M_bmt_al; 		
			&C._80_M_bmt_au=CANC_80_M_bmt_au; 		
			&C._80_M_bmt_none=CANC_80_M_bmt_none; 			
	end ;

%mend ;
************************************************************************************ ;
*** Break out episode by cancer *** ;

 *CN(CN,C);
 
DATA STEP2 ;

	SET STEP1 ;

	%CN(Acute Leukemia,ACLU) ; 
	%CN(Anal Cancer,ANAL) ;
	%CN(Bladder Cancer,BLAD) ;
	%CN(Bladder Cancer - Low Risk,BLADLR) ;
	%CN(Bladder Cancer - High Risk,BLADHR) ;
	%CN(Breast Cancer,BRST) ;
	%CN(Breast Cancer - High Risk,BRSTHR) ;
	%CN(Chronic Leukemia,CRLU) ;
	%CN(CNS Tumor,CNS) ;
	%CN(Endocrine Tumor,ENDO) ;
	%CN(Female GU Cancer other than Ovary,FEML) ;
	%CN(Gastro/Esophageal Cancer,GAST) ;
	%CN(Head and Neck Cancer,HEAD) ;
	%CN(Intestinal Cancer, INTS) ;
	%CN(Kidney Cancer,KIDN) ;
	%CN(Liver Cancer,LIVR) ;
	%CN(Lung Cancer, LUNG) ;
	%CN(Lymphoma, LYMP) ;
	%CN(Malignant Melanoma,MALM) ;
	%CN(MDS, MDS) ;
	%CN(Multiple Myeloma,MULM) ;
	%CN(Ovarian Cancer,OVAR) ;
	%CN(Pancreatic Cancer,PANC) ;
	%CN(Prostate Cancer,PROS) ;
	%CN(Prostate Cancer - Low Intensity,PROSCS) ;
	%CN(Prostate Cancer - High Intensity,PROSCR) ;

PROC MEANS DATA=STEP2 NOPRINT SUM ;
	VAR ACLU: ANAL: BLAD: BRST: BRSTHR: CRLU: CNS: ENDO: FEML: GAST: HEAD: INTS: KIDN: LIVR: LUNG: LYMP:
	    MALM: MDS: MULM: OVAR: PANC: PROS: ; 
	OUTPUT OUT=ONEREC (DROP = _TYPE_ _FREQ_)
		   SUM() = ;


DATA r2.PREDICT_MODEL_VARS_ACLU(keep = aclu:)
	 r2.PREDICT_MODEL_VARS_ANAL(keep = ANAL:)
	 r2.PREDICT_MODEL_VARS_BLAD(keep = BLAD_:)
	 r2.PREDICT_MODEL_VARS_BLADLR(keep = BLADLR:)
	 r2.PREDICT_MODEL_VARS_BLADHR(keep = BLADHR:)
	 r2.PREDICT_MODEL_VARS_BRST(keep = BRST_:)
	 r2.PREDICT_MODEL_VARS_BRSTHR(keep = BRSTHR:)
	 r2.PREDICT_MODEL_VARS_CRLU(keep = CRLU:)
	 r2.PREDICT_MODEL_VARS_CNS(keep = CNS:)
	 r2.PREDICT_MODEL_VARS_ENDO(keep = ENDO:)
	 r2.PREDICT_MODEL_VARS_FEML(keep = FEML:)
	 r2.PREDICT_MODEL_VARS_GAST(keep = GAST:)
	 r2.PREDICT_MODEL_VARS_HEAD(keep = HEAD:)
	 r2.PREDICT_MODEL_VARS_INTS(keep = INTS:)
	 r2.PREDICT_MODEL_VARS_KIDN(keep = KIDN:)
	 r2.PREDICT_MODEL_VARS_LIVR(keep = LIVR:)
	 r2.PREDICT_MODEL_VARS_LUNG(keep = LUNG:)
	 r2.PREDICT_MODEL_VARS_LYMP(keep = LYMP:)
	 r2.PREDICT_MODEL_VARS_MALM(keep = MALM:)
	 r2.PREDICT_MODEL_VARS_MULM(keep = MULM:)
	 r2.PREDICT_MODEL_VARS_MDS(keep = MDS:)
	 r2.PREDICT_MODEL_VARS_OVAR(keep = OVAR:)
	 r2.PREDICT_MODEL_VARS_PANC(keep = PANC:)
	 r2.PREDICT_MODEL_VARS_PROS(keep = PROS_:)
	 r2.PREDICT_MODEL_VARS_PROSCR(keep = PROSCR:)
	 r2.PREDICT_MODEL_VARS_PROSCS(keep = PROSCS:)

;

	SET ONEREC ;

	FORMAT ACLU: ANAL: BLAD_: BRST_: BRSTHR: CRLU: CNS: ENDO: FEML: GAST: HEAD: INTS: KIDN: LIVR: LUNG: LYMP:
	       MALM: MULM: MDS: OVAR: PANC: PROS_: BLADLR: BLADHR: PROSCS: PROSCR: 10.2 ;

	%macro SETUP(c) ;

			&C._18_64_F_inst_y = &C._18_64_F_inst_y/&C._18_64_F ;	
			&C._18_64_F_inst_n = &C._18_64_F_inst_n/&C._18_64_F 	;
			&C._18_64_M_inst_y = &C._18_64_M_inst_y/&C._18_64_M	;
			&C._18_64_M_inst_n	= &C._18_64_M_inst_n/&C._18_64_M	;

			&C._18_64_F_epi_180_181 = &C._18_64_F_epi_180_181/&C._18_64_F ;
			&C._18_64_F_epi_182_183 = &C._18_64_F_epi_182_183/&C._18_64_F ;
			&C._18_64_M_epi_180_181 = &C._18_64_M_epi_180_181/&C._18_64_M;
			&C._18_64_M_epi_182_183 = &C._18_64_M_epi_182_183/&C._18_64_M;

			&C._18_64_F_cp_1_61=&C._18_64_F_cp_1_61/&C._18_64_F ;
			&C._18_64_F_cp_62_730=&C._18_64_F_cp_62_730/&C._18_64_F ;
			&C._18_64_F_cp_none=&C._18_64_F_cp_none/&C._18_64_F  ;
			&C._18_64_M_cp_1_61=&C._18_64_M_cp_1_61/&C._18_64_M;
			&C._18_64_M_cp_62_730 = &C._18_64_M_cp_62_730/&C._18_64_M;
			&C._18_64_M_cp_none=&C._18_64_M_cp_none/&C._18_64_M ;

			&C._18_64_F_enroll_full_dual=&C._18_64_F_enroll_full_dual/&C._18_64_F ;
			&C._18_64_F_enroll_no_pd=&C._18_64_F_enroll_no_pd/&C._18_64_F 	;
			&C._18_64_F_enroll_pd_lis=&C._18_64_F_enroll_pd_lis/&C._18_64_F 	;
			&C._18_64_F_enroll_pd_no_lis=&C._18_64_F_enroll_pd_no_lis/&C._18_64_F ;
			&C._18_64_M_enroll_full_dual=&C._18_64_M_enroll_full_dual/&C._18_64_M;
			&C._18_64_M_enroll_no_pd=&C._18_64_M_enroll_no_pd/&C._18_64_M	;
			&C._18_64_M_enroll_pd_lis=&C._18_64_M_enroll_pd_lis/&C._18_64_M	;
			&C._18_64_M_enroll_pd_no_lis=&C._18_64_M_enroll_pd_no_lis/&C._18_64_M;	

			&C._18_64_F_comorb_1=&C._18_64_F_comorb_1/&C._18_64_F  ;
			&C._18_64_F_comorb_2=&C._18_64_F_comorb_2/&C._18_64_F  ;
			&C._18_64_F_comorb_3=&C._18_64_F_comorb_3/&C._18_64_F  ;
			&C._18_64_F_comorb_4_5=&C._18_64_F_comorb_4_5/&C._18_64_F ; 
			&C._18_64_F_comorb_6 =&C._18_64_F_comorb_6/&C._18_64_F   ; 	
			&C._18_64_F_comorb_new_enroll=&C._18_64_F_comorb_new_enroll/&C._18_64_F 	 ; 
			&C._18_64_F_comorb_none=&C._18_64_F_comorb_none/&C._18_64_F 	 ; 
			&C._18_64_M_comorb_1 = &C._18_64_M_comorb_1/&C._18_64_M;	
			&C._18_64_M_comorb_2 = &C._18_64_M_comorb_2/&C._18_64_M; 	
			&C._18_64_M_comorb_3 = &C._18_64_M_comorb_3/&C._18_64_M; 	
			&C._18_64_M_comorb_4_5 =&C._18_64_M_comorb_4_5/&C._18_64_M	 ; 
			&C._18_64_M_comorb_6 = &C._18_64_M_comorb_6/&C._18_64_M  ; 	
			&C._18_64_M_comorb_new_enroll = &C._18_64_M_comorb_new_enroll/&C._18_64_M	 ; 
			&C._18_64_M_comorb_none = &C._18_64_M_comorb_none/&C._18_64_M	 ; 

			&C._18_64_F_ct_y=&C._18_64_F_ct_y/&C._18_64_F  ; 	
			&C._18_64_F_ct_n=&C._18_64_F_ct_n/&C._18_64_F  ; 		
			&C._18_64_F_rad_y=&C._18_64_F_rad_y/&C._18_64_F  ; 	
			&C._18_64_F_rad_n=&C._18_64_F_rad_n/&C._18_64_F  ; 		
			&C._18_64_F_surg_y=&C._18_64_F_surg_y/&C._18_64_F  ; 		
			&C._18_64_F_surg_n=&C._18_64_F_surg_n/&C._18_64_F 	; 		
			&C._18_64_F_bmt_al=&C._18_64_F_bmt_al/&C._18_64_F 	; 		
			&C._18_64_F_bmt_au=&C._18_64_F_bmt_au/&C._18_64_F 	; 		
			&C._18_64_F_bmt_none=&C._18_64_F_bmt_none/&C._18_64_F  ; 			
			&C._18_64_M_ct_y=&C._18_64_M_ct_y/&C._18_64_M ; 	
			&C._18_64_M_ct_n=&C._18_64_M_ct_n/&C._18_64_M ; 		
			&C._18_64_M_rad_y=&C._18_64_M_rad_y/&C._18_64_M ; 	
			&C._18_64_M_rad_n=&C._18_64_M_rad_n/&C._18_64_M ; 		
			&C._18_64_M_surg_y=&C._18_64_M_surg_y/&C._18_64_M ; 		
			&C._18_64_M_surg_n	=&C._18_64_M_surg_n/&C._18_64_M	; 		
			&C._18_64_M_bmt_al	=&C._18_64_M_bmt_al/&C._18_64_M	; 		
			&C._18_64_M_bmt_au=&C._18_64_M_bmt_au/&C._18_64_M	; 		
			&C._18_64_M_bmt_none=&C._18_64_M_bmt_none/&C._18_64_M ; 			

			&C._65_69_F_inst_y=&C._65_69_F_inst_y/&C._65_69_F	;
			&C._65_69_F_inst_n=&C._65_69_F_inst_n/&C._65_69_F	;
			&C._65_69_M_inst_y=&C._65_69_M_inst_y/&C._65_69_M	;
			&C._65_69_M_inst_n=&C._65_69_M_inst_n/&C._65_69_M	;

			&C._65_69_F_epi_180_181=&C._65_69_F_epi_180_181/&C._65_69_F;	
			&C._65_69_F_epi_182_183=&C._65_69_F_epi_182_183/&C._65_69_F;
			&C._65_69_M_epi_180_181=&C._65_69_M_epi_180_181/&C._65_69_M;	
			&C._65_69_M_epi_182_183=&C._65_69_M_epi_182_183/&C._65_69_M;

			&C._65_69_F_cp_1_61=&C._65_69_F_cp_1_61/&C._65_69_F;		
			&C._65_69_F_cp_62_730=&C._65_69_F_cp_62_730/&C._65_69_F; 
			&C._65_69_F_cp_none=&C._65_69_F_cp_none/&C._65_69_F ;
			&C._65_69_M_cp_1_61=&C._65_69_M_cp_1_61/&C._65_69_M;		
			&C._65_69_M_cp_62_730=&C._65_69_M_cp_62_730/&C._65_69_M; 
			&C._65_69_M_cp_none=&C._65_69_M_cp_none/&C._65_69_M ;

			&C._65_69_F_enroll_full_dual=&C._65_69_F_enroll_full_duaL/&C._65_69_F;
			&C._65_69_F_enroll_no_pd=&C._65_69_F_enroll_no_pd/&C._65_69_F	;
			&C._65_69_F_enroll_pd_lis=&C._65_69_F_enroll_pd_lis/&C._65_69_F	;
			&C._65_69_F_enroll_pd_no_lis=&C._65_69_F_enroll_pd_no_lis/&C._65_69_F	;
			&C._65_69_M_enroll_full_dual=&C._65_69_M_enroll_full_dual/&C._65_69_M;
			&C._65_69_M_enroll_no_pd=&C._65_69_M_enroll_no_pd/&C._65_69_M	;
			&C._65_69_M_enroll_pd_lis=&C._65_69_M_enroll_pd_lis/&C._65_69_M	;
			&C._65_69_M_enroll_pd_no_lis=&C._65_69_M_enroll_pd_no_lis/&C._65_69_M;

			&C._65_69_F_comorb_1=&C._65_69_F_comorb_1/&C._65_69_F ;	
			&C._65_69_F_comorb_2=&C._65_69_F_comorb_2/&C._65_69_F ; 	
			&C._65_69_F_comorb_3=&C._65_69_F_comorb_3/&C._65_69_F ; 	
			&C._65_69_F_comorb_4_5=&C._65_69_F_comorb_4_5/&C._65_69_F	; 
			&C._65_69_F_comorb_6=&C._65_69_F_comorb_6/&C._65_69_F  ; 	
			&C._65_69_F_comorb_new_enroll=&C._65_69_F_comorb_new_enroll/&C._65_69_F	 ; 
			&C._65_69_F_comorb_none=&C._65_69_F_comorb_none/&C._65_69_F	 ; 
			&C._65_69_M_comorb_1=&C._65_69_M_comorb_1/&C._65_69_M  ;	
			&C._65_69_M_comorb_2=&C._65_69_M_comorb_2/&C._65_69_M ; 	
			&C._65_69_M_comorb_3=&C._65_69_M_comorb_3/&C._65_69_M ; 	
			&C._65_69_M_comorb_4_5=&C._65_69_M_comorb_4_5/&C._65_69_M	; 
			&C._65_69_M_comorb_6=&C._65_69_M_comorb_6/&C._65_69_M  ; 	
			&C._65_69_M_comorb_new_enroll=&C._65_69_M_comorb_new_enroll/&C._65_69_M	  ; 
			&C._65_69_M_comorb_none=&C._65_69_M_comorb_none/&C._65_69_M	 ; 

			&C._65_69_F_ct_y=&C._65_69_F_ct_y/&C._65_69_F ; 	
			&C._65_69_F_ct_n=&C._65_69_F_ct_n/&C._65_69_F ; 		
			&C._65_69_F_rad_y=&C._65_69_F_rad_y/&C._65_69_F; 	
			&C._65_69_F_rad_n=&C._65_69_F_rad_n/&C._65_69_F ; 		
			&C._65_69_F_surg_y=&C._65_69_F_surg_y/&C._65_69_F; 		
			&C._65_69_F_surg_n=&C._65_69_F_surg_n/&C._65_69_F	; 		
			&C._65_69_F_bmt_al=&C._65_69_F_bmt_al/&C._65_69_F	; 		
			&C._65_69_F_bmt_au=&C._65_69_F_bmt_au/&C._65_69_F	; 		
			&C._65_69_F_bmt_none=&C._65_69_F_bmt_none/&C._65_69_F ; 			
			&C._65_69_M_ct_y=&C._65_69_M_ct_y/&C._65_69_M  ; 	
			&C._65_69_M_ct_n=&C._65_69_M_ct_n/&C._65_69_M  ; 		
			&C._65_69_M_rad_y=&C._65_69_M_rad_y/&C._65_69_M  ; 	
			&C._65_69_M_rad_n=&C._65_69_M_rad_n/&C._65_69_M  ; 		
			&C._65_69_M_surg_y=&C._65_69_M_surg_y/&C._65_69_M  ; 		
			&C._65_69_M_surg_n=&C._65_69_M_surg_n/&C._65_69_M	 ; 		
			&C._65_69_M_bmt_al	=&C._65_69_M_bmt_al/&C._65_69_M	 ; 		
			&C._65_69_M_bmt_au	=&C._65_69_M_bmt_au/&C._65_69_M	 ; 		
			&C._65_69_M_bmt_none=&C._65_69_M_bmt_none/&C._65_69_M  ; 			

			&C._70_74_F_inst_y=&C._70_74_F_inst_y/&C._70_74_F	;
			&C._70_74_F_inst_n=&C._70_74_F_inst_n/&C._70_74_F	;
			&C._70_74_M_inst_y	=&C._70_74_M_inst_y/&C._70_74_M	;
			&C._70_74_M_inst_n	=&C._70_74_M_inst_n/&C._70_74_M	;

			&C._70_74_F_epi_180_181=&C._70_74_F_epi_180_181/&C._70_74_F;	
			&C._70_74_F_epi_182_183=&C._70_74_F_epi_182_183/&C._70_74_F;
			&C._70_74_M_epi_180_181=&C._70_74_M_epi_180_181/&C._70_74_M;	
			&C._70_74_M_epi_182_183=&C._70_74_M_epi_182_183/&C._70_74_M;

			&C._70_74_F_cp_1_61=&C._70_74_F_cp_1_61/&C._70_74_F;		
			&C._70_74_F_cp_62_730=&C._70_74_F_cp_62_730/&C._70_74_F; 
			&C._70_74_F_cp_none=&C._70_74_F_cp_none/&C._70_74_F;
			&C._70_74_M_cp_1_61=&C._70_74_M_cp_1_61/&C._70_74_M;		
			&C._70_74_M_cp_62_730=&C._70_74_M_cp_62_730/&C._70_74_M; 
			&C._70_74_M_cp_none=&C._70_74_M_cp_none/&C._70_74_M ;

			&C._70_74_F_enroll_full_dual=&C._70_74_F_enroll_full_dual/&C._70_74_F;
			&C._70_74_F_enroll_no_pd=&C._70_74_F_enroll_no_pd/&C._70_74_F;
			&C._70_74_F_enroll_pd_lis=&C._70_74_F_enroll_pd_lis/&C._70_74_F;
			&C._70_74_F_enroll_pd_no_lis=&C._70_74_F_enroll_pd_no_lis/&C._70_74_F;
			&C._70_74_M_enroll_full_dual=&C._70_74_M_enroll_full_dual/&C._70_74_M;
			&C._70_74_M_enroll_no_pd=&C._70_74_M_enroll_no_pd/&C._70_74_M	;
			&C._70_74_M_enroll_pd_lis=&C._70_74_M_enroll_pd_lis/&C._70_74_M	;
			&C._70_74_M_enroll_pd_no_lis=&C._70_74_M_enroll_pd_no_lis/&C._70_74_M;

			&C._70_74_F_comorb_1=&C._70_74_F_comorb_1/&C._70_74_F ;	
			&C._70_74_F_comorb_2=&C._70_74_F_comorb_2/&C._70_74_F ; 	
			&C._70_74_F_comorb_3=&C._70_74_F_comorb_3/&C._70_74_F ; 	
			&C._70_74_F_comorb_4_5=&C._70_74_F_comorb_4_5/&C._70_74_F	; 
			&C._70_74_F_comorb_6=&C._70_74_F_comorb_6/&C._70_74_F ; 	
			&C._70_74_F_comorb_new_enroll=&C._70_74_F_comorb_new_enroll/&C._70_74_F	 ; 
			&C._70_74_F_comorb_none=&C._70_74_F_comorb_none/&C._70_74_F	 ; 
			&C._70_74_M_comorb_1=&C._70_74_M_comorb_1/&C._70_74_M ;	
			&C._70_74_M_comorb_2=&C._70_74_M_comorb_2/&C._70_74_M ; 	
			&C._70_74_M_comorb_3=&C._70_74_M_comorb_3/&C._70_74_M ; 	
			&C._70_74_M_comorb_4_5=&C._70_74_M_comorb_4_5/&C._70_74_M	 ; 
			&C._70_74_M_comorb_6=&C._70_74_M_comorb_6/&C._70_74_M  ; 	
			&C._70_74_M_comorb_new_enroll=&C._70_74_M_comorb_new_enroll/&C._70_74_M	 ; 
			&C._70_74_M_comorb_none=&C._70_74_M_comorb_none/&C._70_74_M	  ; 

			&C._70_74_F_ct_y=&C._70_74_F_ct_y/&C._70_74_F ; 	
			&C._70_74_F_ct_n=&C._70_74_F_ct_n/&C._70_74_F ; 		
			&C._70_74_F_rad_y=&C._70_74_F_rad_y/&C._70_74_F; 	
			&C._70_74_F_rad_n=&C._70_74_F_rad_n/&C._70_74_F ; 		
			&C._70_74_F_surg_y=&C._70_74_F_surg_y/&C._70_74_F ; 		
			&C._70_74_F_surg_n=&C._70_74_F_surg_n/&C._70_74_F	; 		
			&C._70_74_F_bmt_al=&C._70_74_F_bmt_al/&C._70_74_F	; 		
			&C._70_74_F_bmt_au=&C._70_74_F_bmt_au/&C._70_74_F	; 		
			&C._70_74_F_bmt_none=&C._70_74_F_bmt_none/&C._70_74_F ; 			
			&C._70_74_M_ct_y=&C._70_74_M_ct_y/&C._70_74_M  ; 	
			&C._70_74_M_ct_n=&C._70_74_M_ct_n/&C._70_74_M  ; 		
			&C._70_74_M_rad_y=&C._70_74_M_rad_y/&C._70_74_M ; 	
			&C._70_74_M_rad_n=&C._70_74_M_rad_n/&C._70_74_M  ; 		
			&C._70_74_M_surg_y=&C._70_74_M_surg_y/&C._70_74_M  ; 		
			&C._70_74_M_surg_n=&C._70_74_M_surg_n/&C._70_74_M	 ; 		
			&C._70_74_M_bmt_al=&C._70_74_M_bmt_al/&C._70_74_M	 ; 		
			&C._70_74_M_bmt_au=&C._70_74_M_bmt_au/&C._70_74_M	 ; 		
			&C._70_74_M_bmt_none=&C._70_74_M_bmt_none/&C._70_74_M ; 			

			&C._75_79_F_inst_y=&C._75_79_F_inst_y/&C._75_79_F	 ;
			&C._75_79_F_inst_n=&C._75_79_F_inst_n/&C._75_79_F	 ;
			&C._75_79_M_inst_y=&C._75_79_M_inst_y/&C._75_79_M	 ;
			&C._75_79_M_inst_n=&C._75_79_M_inst_n/&C._75_79_M	;

			&C._75_79_F_epi_180_181=&C._75_79_F_epi_180_181/&C._75_79_F;	
			&C._75_79_F_epi_182_183=&C._75_79_F_epi_182_183/&C._75_79_F;
			&C._75_79_M_epi_180_181=&C._75_79_M_epi_180_181/&C._75_79_M ;	
			&C._75_79_M_epi_182_183=&C._75_79_M_epi_182_183/&C._75_79_M;

			&C._75_79_F_cp_1_61=&C._75_79_F_cp_1_61/&C._75_79_F;		
			&C._75_79_F_cp_62_730=&C._75_79_F_cp_62_730/&C._75_79_F	; 
			&C._75_79_F_cp_none=&C._75_79_F_cp_none/&C._75_79_F ;
			&C._75_79_M_cp_1_61=&C._75_79_M_cp_1_61/&C._75_79_M;		
			&C._75_79_M_cp_62_730=&C._75_79_M_cp_62_730/&C._75_79_M; 
			&C._75_79_M_cp_none=&C._75_79_M_cp_none/&C._75_79_M ;

			&C._75_79_F_enroll_full_dual=&C._75_79_F_enroll_full_dual/&C._75_79_F ;
			&C._75_79_F_enroll_no_pd=&C._75_79_F_enroll_no_pd/&C._75_79_F;
			&C._75_79_F_enroll_pd_lis=&C._75_79_F_enroll_pd_lis/&C._75_79_F;
			&C._75_79_F_enroll_pd_no_lis=&C._75_79_F_enroll_pd_no_lis/&C._75_79_F;
			&C._75_79_M_enroll_full_dual=&C._75_79_M_enroll_full_dual/&C._75_79_M;
			&C._75_79_M_enroll_no_pd=&C._75_79_M_enroll_no_pd/&C._75_79_M	;
			&C._75_79_M_enroll_pd_lis=&C._75_79_M_enroll_pd_lis/&C._75_79_M	;
			&C._75_79_M_enroll_pd_no_lis=&C._75_79_M_enroll_pd_no_lis/&C._75_79_M;

			&C._75_79_F_comorb_1 =&C._75_79_F_comorb_1/&C._75_79_F  ;	
			&C._75_79_F_comorb_2 = &C._75_79_F_comorb_2/&C._75_79_F ; 	
			&C._75_79_F_comorb_3 = &C._75_79_F_comorb_3/&C._75_79_F ; 	
			&C._75_79_F_comorb_4_5 = &C._75_79_F_comorb_4_5/&C._75_79_F; 
			&C._75_79_F_comorb_6 = &C._75_79_F_comorb_6/&C._75_79_F  ; 	
			&C._75_79_F_comorb_new_enroll = &C._75_79_F_comorb_new_enroll/&C._75_79_F	 ; 
			&C._75_79_F_comorb_none = &C._75_79_F_comorb_none/&C._75_79_F	 ; 
			&C._75_79_M_comorb_1 = &C._75_79_M_comorb_1/&C._75_79_M  ;	
			&C._75_79_M_comorb_2 = &C._75_79_M_comorb_2/&C._75_79_M  ; 	
			&C._75_79_M_comorb_3 = &C._75_79_M_comorb_3/&C._75_79_M  ; 	
			&C._75_79_M_comorb_4_5 = &C._75_79_M_comorb_4_5/&C._75_79_M	 ; 
			&C._75_79_M_comorb_6 = &C._75_79_M_comorb_6/&C._75_79_M ; 	
			&C._75_79_M_comorb_new_enroll = &C._75_79_M_comorb_new_enroll/&C._75_79_M	 ; 
			&C._75_79_M_comorb_none = &C._75_79_M_comorb_none/&C._75_79_M	  ; 

			&C._75_79_F_ct_y=&C._75_79_F_ct_y/&C._75_79_F ; 	
			&C._75_79_F_ct_n=&C._75_79_F_ct_n/&C._75_79_F ; 		
			&C._75_79_F_rad_y=&C._75_79_F_rad_y/&C._75_79_F; 	
			&C._75_79_F_rad_n=&C._75_79_F_rad_n/&C._75_79_F; 		
			&C._75_79_F_surg_y=&C._75_79_F_surg_y/&C._75_79_F; 		
			&C._75_79_F_surg_n=&C._75_79_F_surg_n/&C._75_79_F; 		
			&C._75_79_F_bmt_al=&C._75_79_F_bmt_al/&C._75_79_F; 		
			&C._75_79_F_bmt_au=&C._75_79_F_bmt_au/&C._75_79_F; 		
			&C._75_79_F_bmt_none=&C._75_79_F_bmt_none/&C._75_79_F; 			
			&C._75_79_M_ct_y=&C._75_79_M_ct_y/&C._75_79_M ; 	
			&C._75_79_M_ct_n=&C._75_79_M_ct_n/&C._75_79_M ; 		
			&C._75_79_M_rad_y=&C._75_79_M_rad_y/&C._75_79_M ; 	
			&C._75_79_M_rad_n=&C._75_79_M_rad_n/&C._75_79_M ; 		
			&C._75_79_M_surg_y=&C._75_79_M_surg_y/&C._75_79_M ; 		
			&C._75_79_M_surg_n=&C._75_79_M_surg_n/&C._75_79_M	; 		
			&C._75_79_M_bmt_al=&C._75_79_M_bmt_al/&C._75_79_M	; 		
			&C._75_79_M_bmt_au=&C._75_79_M_bmt_au/&C._75_79_M	; 		
			&C._75_79_M_bmt_none=&C._75_79_M_bmt_none/&C._75_79_M; 	

			&C._80_F_inst_y = &C._80_F_inst_y/&C._80_F	 ;
			&C._80_F_inst_n = &C._80_F_inst_n/&C._80_F	 ;
			&C._80_M_inst_y = &C._80_M_inst_y/&C._80_M	;
			&C._80_M_inst_n = &C._80_M_inst_n/&C._80_M	;

			&C._80_F_epi_180_181= &C._80_F_epi_180_181/&C._80_F;	
			&C._80_F_epi_182_183 = &C._80_F_epi_182_183/&C._80_F;
			&C._80_M_epi_180_181 = &C._80_M_epi_180_181/&C._80_M;	
			&C._80_M_epi_182_183 = &C._80_M_epi_182_183/&C._80_M;

			&C._80_F_cp_1_61=&C._80_F_cp_1_61/&C._80_F;		
			&C._80_F_cp_62_730=&C._80_F_cp_62_730/&C._80_F; 
			&C._80_F_cp_none=&C._80_F_cp_none/&C._80_F ;
			&C._80_M_cp_1_61=&C._80_M_cp_1_61/&C._80_M;		
			&C._80_M_cp_62_730=&C._80_M_cp_62_730/&C._80_M	; 
			&C._80_M_cp_none=&C._80_M_cp_none/&C._80_M 	;

			&C._80_F_enroll_full_dual = &C._80_F_enroll_full_dual/&C._80_F;
			&C._80_F_enroll_no_pd = &C._80_F_enroll_no_pd/&C._80_F	;
			&C._80_F_enroll_pd_lis = &C._80_F_enroll_pd_lis/&C._80_F	;
			&C._80_F_enroll_pd_no_lis = &C._80_F_enroll_pd_no_lis/&C._80_F;
			&C._80_M_enroll_full_dual = &C._80_M_enroll_full_dual/&C._80_M;
			&C._80_M_enroll_no_pd = &C._80_M_enroll_no_pd/&C._80_M	;
			&C._80_M_enroll_pd_lis = &C._80_M_enroll_pd_lis/&C._80_M	;
			&C._80_M_enroll_pd_no_lis = &C._80_M_enroll_pd_no_lis/&C._80_M;

			&C._80_F_comorb_1=&C._80_F_comorb_1/&C._80_F ;	
			&C._80_F_comorb_2=&C._80_F_comorb_2/&C._80_F ; 	
			&C._80_F_comorb_3=&C._80_F_comorb_3/&C._80_F ; 	
			&C._80_F_comorb_4_5=&C._80_F_comorb_4_5/&C._80_F; 
			&C._80_F_comorb_6=&C._80_F_comorb_6/&C._80_F  ; 	
			&C._80_F_comorb_new_enroll=&C._80_F_comorb_new_enroll/&C._80_F	  ; 
			&C._80_F_comorb_none=&C._80_F_comorb_none/&C._80_F	 ; 
			&C._80_M_comorb_1=&C._80_M_comorb_1/&C._80_M ;	
			&C._80_M_comorb_2=&C._80_M_comorb_2/&C._80_M ; 	
			&C._80_M_comorb_3=&C._80_M_comorb_3/&C._80_M ; 	
			&C._80_M_comorb_4_5=&C._80_M_comorb_4_5/&C._80_M; 
			&C._80_M_comorb_6=&C._80_M_comorb_6/&C._80_M  ; 	
			&C._80_M_comorb_new_enroll=&C._80_M_comorb_new_enroll/&C._80_M	 ; 
			&C._80_M_comorb_none=&C._80_M_comorb_none/&C._80_M	 ; 

			&C._80_F_ct_y=&C._80_F_ct_y/&C._80_F ; 	
			&C._80_F_ct_n=&C._80_F_ct_n/&C._80_F ; 		
			&C._80_F_rad_y=&C._80_F_rad_y/&C._80_F ; 	
			&C._80_F_rad_n=&C._80_F_rad_n/&C._80_F ; 		
			&C._80_F_surg_y=&C._80_F_surg_y/&C._80_F ; 		
			&C._80_F_surg_n=&C._80_F_surg_n/&C._80_F; 		
			&C._80_F_bmt_al=&C._80_F_bmt_al/&C._80_F; 		
			&C._80_F_bmt_au=&C._80_F_bmt_au/&C._80_F; 		
			&C._80_F_bmt_none=&C._80_F_bmt_none/&C._80_F ; 			
			&C._80_M_ct_y=&C._80_M_ct_y/&C._80_M ; 	
			&C._80_M_ct_n=&C._80_M_ct_n/&C._80_M ; 		
			&C._80_M_rad_y=&C._80_M_rad_y/&C._80_M ; 	
			&C._80_M_rad_n=&C._80_M_rad_n/&C._80_M ; 		
			&C._80_M_surg_y=&C._80_M_surg_y/&C._80_M ; 		
			&C._80_M_surg_n=&C._80_M_surg_n/&C._80_M; 		
			&C._80_M_bmt_al=&C._80_M_bmt_al/&C._80_M; 		
			&C._80_M_bmt_au=&C._80_M_bmt_au/&C._80_M; 		
			&C._80_M_bmt_none=&C._80_M_bmt_none/&C._80_M; 			

		DROP &C._18_64_F &C._18_64_M &C._65_69_F &C._65_69_M &C._70_74_F &C._70_74_M
			 &C._75_79_F &C._75_79_M &C._80_F ;

		OUTPUT r2.PREDICT_MODEL_VARS_&c. ;
		

		%MEND ;

		%SETUP(ACLU) ;
		%SETUP(ANAL) ; 
		%SETUP(BLAD) ; 
		%SETUP(BLADLR) ; 
		%SETUP(BLADHR) ; 
		%SETUP(BRST) ; 
		%SETUP(BRSTHR) ; 
		%SETUP(CRLU) ; 
		%SETUP(CNS) ; 
		%SETUP(ENDO) ; 
		%SETUP(FEML) ; 
		%SETUP(GAST) ; 
		%SETUP(HEAD) ; 
		%SETUP(INTS) ; 
		%SETUP(KIDN) ; 
		%SETUP(LIVR) ; 
		%SETUP(LUNG) ; 
		%SETUP(LYMP) ;
	    %SETUP(MALM) ; 
	    %SETUP(MULM) ; 
	    %SETUP(MDS) ; 
		%SETUP(OVAR) ; 
		%SETUP(PANC) ; 
		%SETUP(PROS) ; 
		%SETUP(PROSCR) ; 
		%SETUP(PROSCS) ; 


RUN ;


