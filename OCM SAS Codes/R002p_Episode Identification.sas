********************************************************************** ;
		***** R002p_Episode Identification_PP1.sas ***** ;
********************************************************************** ;
**** Based on Appendix A-C in OCM PBP Methodology.PDF **************** ;
********************************************************************** ;

libname in1 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP1" ; *** locale of RECON SAS reads. *** ;
libname in2 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP2" ; *** locale of RECON SAS reads. *** ;
libname in3 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP3" ; *** locale of RECON SAS reads. *** ;
libname REC1 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP1" ;
libname REC2 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP2" ;
libname REC3 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP3" ;


options ls=132 ps=70 obs=max nomprint nomlogic; run ;

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
*** Predictive Model Variable Development  *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Predict_Flags PP2.sas" ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Predict_Flags PP3.sas" ;
*** For chemo-sensitive override *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Breast_Hormonal.sas" ; run ;
RUN ;
********************************************************************** ;

%let type=p1 ; *** performance period designation *** ; 
%let ref = 1 ; *** directory number for input and output files *** ;
%let vers = R2 ; *** R = Reconciliation, 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let tu = 2 ; *** blank for initial, 1 for true-up 1, 2 for true-up 2 *** ;
%let sd = mdy(7,1,2016) ; *** Performance period start date. ;

/*
%let type=p2 ; *** performance period designation *** ; 
%let ref = 2 ; *** directory number for input and output files *** ;
%let vers = R1 ; *** R = Reconciliation, 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let tu = 1 ; *** blank for initial, 1 for true-up 1, 2 for true-up 2 *** ;
%let sd = mdy(1,2,2017) ; *** Performance period start date. ;
*/
/*
%let type=p3 ; *** performance period designation *** ; 
%let ref = 3 ; *** directory number for input and output files *** ;
%let vers = R0 ; *** R = Reconciliation, 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let tu =  ; *** blank for initial, 1 for true-up 1, 2 for true-up 2 *** ;
%let sd = mdy(7,2,2017) ; *** Performance period start date. ;
*/
%let in_recon = REC&ref..EPIATT&tu._&dsid._PP&ref.;
%let filesuff = &dsid. ;
RUN ;

********************************************************************** ;
**** To be updated to pull in prior performance period episodes. ***** ;
********************************************************************** ;
%macro prior_episodes ;

data prior_episodes(keep = bene_id ep_end) ;
	set 
		%if "&type." = "p2" %then %do ;
			in1.epi2_&dsid. 
			%if "&dsid." = "290_50202" %then %do ;
				in1.epi2_567_50200 
				in1.epi2_568_50201 
			%end ;
		%end ;
		%if "&type." = "p3" %then %do ;
			in2.epi1_&dsid. 
		%end ;
			; 
run;

proc sort data=prior_episodes ; by bene_id ep_end ;
data prior_episodes ;
	set prior_episodes ; by bene_id ep_end;
	if last.bene_id ;
	ep_end_last_pp = ep_end ;
	format ep_end_last_pp mmddyy10. ;
	drop ep_end ;

%mend prior_episode ;
********************************************************************** ;
			****** End of code needing updating ***** ;
********************************************************************** ;


********************************************************************** ;
********************************************************************** ;
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
	if &CANC. = 'D47.1' then &CANC. = 'Chronic myeloproliferative disease' ;
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


********************************************************************** ;
********************************************************************** ;

%macro null_canc ;

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
				 ATYPICAL_LEUKEMIA, INSITU_BREAST, INSITU_CERVIX, /* remove INSITU_EAR, */ INSITU_RESP, 
				 INSITU_OES, INSITU_NOS_DIG, INSITU_NOS_GEN, INSITU_OTH, INSITU_SKIN, CHRONIC_LEUKEMIA_U,
				 CHRONIC_M_LEUKEMIA, KAPOSI, LEUKEMIA_NOS, LYMPHOID_LEUKEMIA, MN_ABDOMEN, MN_LIMB, MN_BONE_NOS,
				 MN_HEART, MN_LLIMB, MN_OTH_DIG, MN_FEM, MN_OTH,  MN_PELVIS, MN_MALE, MN_NERVES, MN_PLACENTA,
				 MN_RP, MN_TESTIS, MN_THORAX, MN_THYMUS, MN_ULIMB, MN_NOS, MDS, MERKEL, MONO_LEUKEMIA,
				 MYELOID_LEUKEMIA, OTHER_SKIN, OTHER_LYMPH, OTHER_LLEUK, OTH_MONOLEUK, OTH_MYELEUK,
				 OTH_SPELEUK,ACUTE_PAN, JM_LEUK, INSITU_MELANOMA, SEC_LYMPH, SEC_MN_NOS, SEC_MN_RESPDIG,
				 SEC_MN_NEUROEND, THROMBO, OSTEO, MYELO, POLY_VERA, CHRONIC_MYELO) ;
%mend null_canc ;

%macro canc_time ;
	**** Accounts for cancers only counted for episodes beginning after a certain time period. **** ;
	EP201701 =  MAX(SEC_LYMPH,SEC_MN_NOS,SEC_MN_RESPDIG,SEC_MN_NEUROEND)  ;
	EP201707 = MAX(THROMBO, OSTEO, MYELO, POLY_VERA, CHRONIC_MYELO) ;
	EPALL = max(ACUTE_LEUKEMIA,ANAL,BLADDER,BREAST,CHRONIC_LEUKEMIA, CNS, ENDOCRINE, 
				 FEMALEGU, GASTRO_ESOPHAGEAL, HEADNECK, INTESTINAL, KIDNEY, LIVER, LUNG, LYMPHOMA,
				 MALIGNANT_MELANOMA, MULT_MYELOMA, OVARIAN, PANCREATIC, PROSTATE, 
				 ATYPICAL_LEUKEMIA, INSITU_BREAST, INSITU_CERVIX, /* remove INSITU_EAR, */ INSITU_RESP, 
				 INSITU_OES, INSITU_NOS_DIG, INSITU_NOS_GEN, INSITU_OTH, INSITU_SKIN, CHRONIC_LEUKEMIA_U,
				 CHRONIC_M_LEUKEMIA, KAPOSI, LEUKEMIA_NOS, LYMPHOID_LEUKEMIA, MN_ABDOMEN, MN_LIMB, MN_BONE_NOS,
				 MN_HEART, MN_LLIMB, MN_OTH_DIG, MN_FEM, MN_OTH,  MN_PELVIS, MN_MALE, MN_NERVES, MN_PLACENTA,
				 MN_RP, MN_TESTIS, MN_THORAX, MN_THYMUS, MN_ULIMB, MN_NOS, MDS, MERKEL, MONO_LEUKEMIA,
				 MYELOID_LEUKEMIA, OTHER_SKIN, OTHER_LYMPH, OTHER_LLEUK, OTH_MONOLEUK, OTH_MYELEUK,
				 OTH_SPELEUK,ACUTE_PAN, JM_LEUK, INSITU_MELANOMA/*, SEC_LYMPH, SEC_MN_NOS, SEC_MN_RESPDIG,
				 SEC_MN_NEUROEND, THROMBO, OSTEO, MYELO, POLY_VERA, CHRONIC_MYELO*/) ;
%mend canc_time ;

*** macro var chk accounts for newest quarter data not being provided *** ;
%macro epi(dsid,ocm) ;

********************************************************************** ;
********************************************************************** ;
**** Step 1: Identify all possible claims that could trigger an episode ending in the performance period ;
**** 1.A. Carrier (PHYLINE_&dsid.), DMEPOS (DMELINE_&dsid.)  **** ;

data lines chemo EM /*lines_partd*/ ;
	set IN&ref..phymeosline&tu._&filesuff.(in=a) IN&ref..dmeline&tu._&filesuff. ;
	if a then carr = 1 ;

	%canc_init ;

	%CANCERTYPE(LINE_ICD_DGNS_VRSN_CD, LINE_ICD_DGNS_CD) ;

	%canc_time ;


	************************************************************************************************* ;

	*output lines_partd ;
	*IF EXPNSDT1 GE &SD.  then do ;
	** E&M claims with cancer diagnosis for episode qualification in subsequent steps ** ;
	if "&type." not in ("p1","p2") then do;
		if ONC_TIN='Y' and carr=1  and HCPCS_CD in ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215')
			and LALOWCHG > 0 and has_cancer = 1 then output EM ;
	end;
	else do;
		if carr=1  and HCPCS_CD in ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215')
			and LALOWCHG > 0 and has_cancer = 1 then output EM ;
	end;

	**The claim must contain a line item HCPCS code indicating an included chemotherapy drug 
	  (initiating cancer therapy) in any line item. ** ;
	/*if %if "&type." = "p1" %then %do ; put(HCPCS_CD,$Chemo_J.) = "Y" %end ;
	   %if "&type." = "p2" %then %do ; put(HCPCS_CD,$Chemo_J2p.) = "Y" %end ;   
	   then do ;*/
	  if ("&type." = "p1" and put(HCPCS_CD,$Chemo_J.) = "Y") or
	     ("&type." = "p2" and put(HCPCS_CD,$Chemo_J2p.) = "Y") or
	     ("&type." = "p3" and put(HCPCS_CD,$Chemo_J3p.) = "Y")
	  	then do ;


	**The chemotherapy drug line item must have a “line first expense date” in the appropriate 
	  6 month “Episodes Beginning” period in Table 1, inclusive of end dates. ** ;

	**The chemotherapy drug line item must not be denied (line allowed charge >0). ** ;
	if LALOWCHG > 0 then do ;

	**The chemotherapy drug line place of service must not be an inpatient hospital (21). ** ;
	if PLCSRVC ne '21' then do ;
		chemo = 1  ;
		output chemo ;
	end ;

	end ;

	end ;

	output lines ;

	*end ;

	** The chemotherapy drug claim must contain an included cancer diagnosis code available on the CMS OCM website) 
   		in any non-denied line item on the same claim (does not have to be same line as HCPCS code above -
   		do not use the header diagnoses).  ** ;

proc sort data=in&ref..phymeoshdr&tu._&dsid. 
			  out=ph(KEEP = bene_Id ep_id clm_id thru_dt PRNCPAL_DGNS_CD PRNCPAL_DGNS_VRSN_CD ICD_DGNS:)
			  nodupkey ; by  ep_id  bene_Id clm_id thru_dt ;
proc sort data=in&ref..dmehdr&tu._&dsid. 
			  out=dh (KEEP = bene_Id ep_id clm_id thru_dt PRNCPAL_DGNS_CD PRNCPAL_DGNS_VRSN_CD ICD_DGNS:)
			  nodupkey ; by  ep_id  bene_Id clm_id thru_dt ;

proc sort data=lines ; by  EP_ID bene_Id clm_id thru_dt ;
proc sort data=chemo out=chemo2(keep =  EP_ID bene_Id clm_id thru_dt) nodupkey ; by  EP_ID bene_Id clm_id thru_dt ;

data chemo_claims chemoz;
	merge lines(in=a) chemo2(in=b) PH DH ; by  EP_ID bene_id clm_id thru_dt ;
	if a and b ;
	**	The trigger date is the line first expense date on the qualifying chemotherapy drug line. *** ;
	if chemo = 1 then trigger_date = expnsdt1 ;
	if trigger_date ge &sd. then perf_chemo = trigger_date ;
	format trigger_date perf_chemo mmddyy10. ;

	IF PRNCPAL_DGNS_VRSN_CD = "0" AND 
	   PRNCPAL_DGNS_CD IN ('Z5111','Z5112') THEN ZFLAG = 1 ;
	   ELSE ZFLAG = 0 ;

	HAS_CANCER_LINE = HAS_CANCER ;
	EPALL_LINE = EPALL ;
	EP201701_LINE = EP201701 ;
	EP201707_LINE = EP201707 ;

	%canc_init ;

	ARRAY DX (I) ICD_DGNS_CD: ;
	ARRAY VX (I) ICD_DGNS_VRSN: ;
	DO I = 1 TO DIM(DX);
		%CANCERTYPE(VX, DX) ;
	END ;

	%canc_time ;

	output chemo_claims ;
	if zflag = 1 then output chemoz ;

proc sort data=chemo_claims ; by  EP_ID bene_id clm_id thru_dt carr ;
proc means data=chemo_claims noprint min max ; by  EP_ID bene_id clm_id thru_dt carr;
	var has_cancer HAS_CANCER_LINE UROTHELIAL trigger_date perf_chemo EPALL EP201701 EP201707 EPALL_LINE ZFLAG EP201701_LINE EP201707_LINE;
	output out=chemo_flag(drop = _freq_ _type_)
		   max(has_cancer HAS_CANCER_LINE UROTHELIAL EPALL EP201701 EP201707 EPALL_LINE ZFLAG EP201701_LINE EP201707_LINE) = 
		   min(trigger_date perf_chemo) = ;	

data chemo_candidates1 ;
	set chemo_flag(in=a) chemoz(in=b) ; 
	if (a and has_cancer_LINE = 1) OR (b AND HAS_CANCER = 1) ;
	/*%if "&type." = "p1" %then %do ;   
			if a then do ;
				if EPALL_line ne 1 then delete ; 
			end ;
			else do ;
				if EPALL ne 1 then delete ; 
			end ;
	%end ;
	%if "&type." = "p2" %then %do ;   
			if a then do ;
				if max(EPALL_line,EP201701_line) ne 1 then delete ; 
			end ;
			else do ;
				if max(EPALL,EP201701) ne 1 then delete ; 
			end ;
	%end ;*/
	if a then do ;
		if "&type." = "p1" and EPALL_line ne 1 then delete ;
		if "&type." = "p2" and max(EPALL_line,EP201701_line) ne 1 then delete ;
	end ;
	else do ;
		if "&type." = "p1" and EPALL ne 1 then delete ;
		if "&type." = "p2" and max(EPALL,EP201701) ne 1 then delete ;
	end ;
	

run ;

proc sort data=chemo_candidates1 nodupkey ; by bene_id clm_id thru_dt carr trigger_date;
proc sort data = chemo_claims ; by bene_id clm_id thru_dt carr trigger_date;
data chemo_days1(keep= bene_id trigger_date) ;
	merge chemo_claims(in=a) chemo_candidates1(in=b) ;  by  bene_id clm_id thru_dt carr trigger_date ;
	if a and b ;
run ;
***** Used for Cancer Flags ***** ;
	data lines_b chemo_b EM_b /*lines_partd*/ ;
	set IN&ref..phymeosline&tu._&filesuff.(in=a) IN&ref..dmeline&tu._&filesuff. ;
	if a then carr = 1 ;

	%canc_init ;

	%CANCERTYPE(LINE_ICD_DGNS_VRSN_CD, LINE_ICD_DGNS_CD) ;

	%canc_time ;


	************************************************************************************************* ;

	*output lines_partd ;
	*IF EXPNSDT1 GE &SD.  then do ;
	** E&M claims with cancer diagnosis for episode qualification in subsequent steps ** ;
	if "&type." not in ("p1","p2") then do;
		if ONC_TIN='Y' and carr=1  and HCPCS_CD in ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215')
			and LALOWCHG > 0 and has_cancer = 1 then output EM_b ;
	end;
	else do;
		if carr=1  and HCPCS_CD in ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215')
			and LALOWCHG > 0 and has_cancer = 1 then output EM_b ;
	end;

	**The claim must contain a line item HCPCS code indicating an included chemotherapy drug 
	  (initiating cancer therapy) in any line item. ** ;
	/*if %if "&type." = "p1" %then %do ; put(HCPCS_CD,$Chemo_J.) = "Y" %end ;
	   %if "&type." = "p2" %then %do ; put(HCPCS_CD,$Chemo_J2p.) = "Y" %end ;   
	   then do ;*/
	  if ("&type." = "p1" and put(HCPCS_CD,$Chemo_J.) = "Y") or
	     ("&type." = "p2" and put(HCPCS_CD,$Chemo_J2p.) = "Y") or
	     ("&type." = "p3" and (put(HCPCS_CD,$Chemo_J3p.)="Y" or put(HCPCS_CD,$Chemo_J4p.)="Y" or put(HCPCS_CD,$Chemo_J5p.)="Y") )
	  	then do ;


	**The chemotherapy drug line item must have a “line first expense date” in the appropriate 
	  6 month “Episodes Beginning” period in Table 1, inclusive of end dates. ** ;

	**The chemotherapy drug line item must not be denied (line allowed charge >0). ** ;
	if LALOWCHG > 0 then do ;

	**The chemotherapy drug line place of service must not be an inpatient hospital (21). ** ;
	if PLCSRVC ne '21' then do ;
		chemo = 1  ;
		output chemo_b ;
	end ;

	end ;

	end ;

	output lines_b ;

	*end ;

	** The chemotherapy drug claim must contain an included cancer diagnosis code available on the CMS OCM website) 
   		in any non-denied line item on the same claim (does not have to be same line as HCPCS code above -
   		do not use the header diagnoses).  ** ;


proc sort data=lines_b ; by  EP_ID bene_Id clm_id thru_dt ;
proc sort data=chemo_b out=chemo2_b(keep =  EP_ID bene_Id clm_id thru_dt) nodupkey ; by  EP_ID bene_Id clm_id thru_dt ;

data chemo_claims_b chemoz_b;
	merge lines_b(in=a) chemo2_b(in=b) PH DH ; by  EP_ID bene_id clm_id thru_dt ;
	if a and b ;
	**	The trigger date is the line first expense date on the qualifying chemotherapy drug line. *** ;
	if chemo = 1 then trigger_date = expnsdt1 ;
	if trigger_date ge &sd. then perf_chemo = trigger_date ;
	format trigger_date perf_chemo mmddyy10. ;

	IF PRNCPAL_DGNS_VRSN_CD = "0" AND 
	   PRNCPAL_DGNS_CD IN ('Z5111','Z5112') THEN ZFLAG = 1 ;
	   ELSE ZFLAG = 0 ;

	HAS_CANCER_LINE = HAS_CANCER ;
	EPALL_LINE = EPALL ;
	EP201701_LINE = EP201701 ;
	EP201707_LINE = EP201707 ;

	%canc_init ;

	ARRAY DX (I) ICD_DGNS_CD: ;
	ARRAY VX (I) ICD_DGNS_VRSN: ;
	DO I = 1 TO DIM(DX);
		%CANCERTYPE(VX, DX) ;
	END ;

	%canc_time ;

	output chemo_claims_b ;
	if zflag = 1 then output chemoz_b ;

proc sort data=chemo_claims_b ; by  EP_ID bene_id clm_id thru_dt carr ;
proc means data=chemo_claims_b noprint min max ; by  EP_ID bene_id clm_id thru_dt carr;
	var has_cancer HAS_CANCER_LINE UROTHELIAL trigger_date perf_chemo EPALL EP201701 EP201707 EPALL_LINE ZFLAG EP201701_LINE EP201707_LINE;
	output out=chemo_flag_b(drop = _freq_ _type_)
		   max(has_cancer HAS_CANCER_LINE UROTHELIAL EPALL EP201701 EP201707 EPALL_LINE ZFLAG EP201701_LINE EP201707_LINE) = 
		   min(trigger_date perf_chemo) = ;	

data chemo_candidates1_b ;
	set chemo_flag_b(in=a) chemoz_b(in=b) ; 
	if (a and has_cancer_LINE = 1) OR (b AND HAS_CANCER = 1) ;
	/*%if "&type." = "p1" %then %do ;   
			if a then do ;
				if EPALL_line ne 1 then delete ; 
			end ;
			else do ;
				if EPALL ne 1 then delete ; 
			end ;
	%end ;
	%if "&type." = "p2" %then %do ;   
			if a then do ;
				if max(EPALL_line,EP201701_line) ne 1 then delete ; 
			end ;
			else do ;
				if max(EPALL,EP201701) ne 1 then delete ; 
			end ;
	%end ;*/
	if a then do ;
		if "&type." = "p1" and EPALL_line ne 1 then delete ;
		if "&type." = "p2" and max(EPALL_line,EP201701_line) ne 1 then delete ;
	end ;
	else do ;
		if "&type." = "p1" and EPALL ne 1 then delete ;
		if "&type." = "p2" and max(EPALL,EP201701) ne 1 then delete ;
	end ;
	
run ;
***** End - Used for Cancer Flags ***** ;

**** 1.B. Outpatient (outrev_&dsid., outhdr_&dsid.)  **** ;

	**** Combining files *****;
proc sort data=IN&ref..outhdr&tu._&filesuff. OUT=h ; by  EP_ID BENE_ID CLM_ID THRU_DT ;
proc sort data=IN&ref..outrev&tu._&filesuff. OUT=r ; by  EP_ID BENE_ID CLM_ID THRU_DT ;

data rec&ref..outpatient_&type.&vers._&dsid. /*op_partd*/;
		merge h(in=a) r(in=b) ; 
		by  EP_ID BENE_ID CLM_ID THRU_DT ; 
		if a and b ;

		%canc_init ;

		ARRAY v (I) ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD25 ;
		ARRAY d (I) ICD_DGNS_CD1-ICD_DGNS_CD25 ;
		DO I = 1 TO 25 ;
			%CANCERTYPE(v, d) ;
		END ;
		DROP I ;

		%canc_time ;

	************************************************************************************************* ;
			output rec&ref..outpatient_&type.&vers._&dsid.;
			*output op_partd ;


data chemo_candidates2(keep =  EP_ID bene_id clm_id thru_dt rev_dt trigger_date has_cancer perf_chemo )  
	 all_op_chemo ;
	set	rec&ref..outpatient_&type.&vers._&dsid. ;

	**The claim must contain a HCPCS code indicating an included chemotherapy drug (initiating cancer therapy) 
	  in any revenue center. ** ;
	/*if %if "&type." = "p1" %then %do ; put(HCPCS_CD,$Chemo_J.) =  "Y" %end ;
	   %if "&type." = "p2" %then %do ; put(HCPCS_CD,$Chemo_J2p.) =  "Y" %end ;
		then do ;*/
	if ("&type." = "p1" and put(HCPCS_CD,$Chemo_J.) =  "Y"  ) or
	   ("&type." = "p2" and put(HCPCS_CD,$Chemo_J2p.) =  "Y"  ) or
	   ("&type." = "p3" and put(HCPCS_CD,$Chemo_J3p.) =  "Y"  )
	    then do ;

		** The revenue center date on the same revenue center in which the HCPCS code is found must be in the 
		   appropriate 6 month Episode Beginning period in Table 1, inclusive of end dates ** ;

		** The claim must not be denied (Medicare non-payment reason code is not blank). ** ;
		if NOPAY_CD =  "  "    then do ;
			
			** The revenue center in which the HCPCS code is found must not be denied (revenue center 
			   total charge amount minus revenue center non-covered charge amount > 0). ** ;
			** The claim header must contain an included cancer diagnosis code **;
			if 	REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 then do ;
				chemo = 1 ; 
				format trigger_date perf_chemo mmddyy10. ;
				trigger_date = rev_dt ;
				perf_chemo = trigger_date ;
					/*IF %if "&type." = "p1" %then %do ;  EPALL = 1 %end ;
					   %if "&type." = "p2" %then %do ;  MAX(EPALL,EP201701) = 1 %end ;*/
					IF (TRIGGER_DATE < MDY(1,2,2017) AND EPALL = 1) or 
					   (TRIGGER_DATE < MDY(7,2,2017) AND MAX(EPALL,EP201701) = 1 ) OR	
					   (trigger_date ge mdy(7,2,2017) and has_cancer = 1)
					   then output chemo_candidates2 ;
				output all_op_chemo ;
			end ;
		
		end ;

	end ;
run ;

***** Used for Cancer Flags ***** ;
data chemo_candidates2_b(keep =  EP_ID bene_id clm_id thru_dt rev_dt trigger_date has_cancer perf_chemo HCPCS_CD)  
	 all_op_chemo_b ;
	set	rec&ref..outpatient_&type.&vers._&dsid. ;

	**The claim must contain a HCPCS code indicating an included chemotherapy drug (initiating cancer therapy) 
	  in any revenue center. ** ;
	/*if %if "&type." = "p1" %then %do ; put(HCPCS_CD,$Chemo_J.) =  "Y" %end ;
	   %if "&type." = "p2" %then %do ; put(HCPCS_CD,$Chemo_J2p.) =  "Y" %end ;
		then do ;*/
	if ("&type." = "p1" and put(HCPCS_CD,$Chemo_J.) =  "Y"  ) or
	   ("&type." = "p2" and put(HCPCS_CD,$Chemo_J2p.) =  "Y"  ) or
	   ("&type." = "p3" and (put(HCPCS_CD,$Chemo_J3p.)="Y" or put(HCPCS_CD,$Chemo_J4p.)="Y" or put(HCPCS_CD,$Chemo_J5p.)="Y"  ) )
	    then do ;

		** The revenue center date on the same revenue center in which the HCPCS code is found must be in the 
		   appropriate 6 month Episode Beginning period in Table 1, inclusive of end dates ** ;

		** The claim must not be denied (Medicare non-payment reason code is not blank). ** ;
		if NOPAY_CD =  "  "    then do ;
			
			** The revenue center in which the HCPCS code is found must not be denied (revenue center 
			   total charge amount minus revenue center non-covered charge amount > 0). ** ;
			** The claim header must contain an included cancer diagnosis code **;
			if 	REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 then do ;
				chemo = 1 ; 
				format trigger_date perf_chemo mmddyy10. ;
				trigger_date = rev_dt ;
				perf_chemo = trigger_date ;
					/*IF %if "&type." = "p1" %then %do ;  EPALL = 1 %end ;
					   %if "&type." = "p2" %then %do ;  MAX(EPALL,EP201701) = 1 %end ;*/
					IF (TRIGGER_DATE < MDY(1,2,2017) AND EPALL = 1) or 
					   (TRIGGER_DATE < MDY(7,2,2017) AND MAX(EPALL,EP201701) = 1 ) OR	
					   (trigger_date ge mdy(7,2,2017) and has_cancer = 1)
					   then output chemo_candidates2_b ;
				output all_op_chemo_b ;
			end ;
		
		end ;

	end ;
run ;
***** End - Used for Cancer Flags ***** ;

proc sort data=rec&ref..outpatient_&type.&vers._&dsid. out=op ; by EP_ID bene_id clm_id thru_dt ;
proc sort data=chemo_candidates2 out=chemo2a nodupkey ; by EP_ID bene_id clm_id thru_dt ;

data chemo_days2(keep= EP_ID bene_id rev_dt) ;
	merge op(in=a) chemo2a(in=b) ;by EP_ID bene_id clm_id thru_dt ;
	if a and b ;

**** Part B Chemo claims ***** ;
data chemo_days ;
	set chemo_days1 chemo_days2(rename = (rev_dt=trigger_date)) ;
	if trigger_date ne . ;
proc sort data=chemo_days ; by  EP_ID bene_id trigger_date ;
data chemo_days ; set chemo_days ; by  EP_ID bene_id trigger_date ; if first.trigger_date then counter = 1 ;
	*** For performance period, capture first chemo date within period when available.  Default to earliest 
		available when no chemo is present in current period. *** ;
	format perf_chemo mmddyy10. ;
	if trigger_date ge &sd. then do ;
		perf_chemo = trigger_date ;
		perf_count = counter ;
	end ;


**** 1.C. Part D (PDE_&dsid.)  **** ;

data chemo_candidates3/*_cand*/(keep =  EP_ID bene_id pde_id trigger_date perf_chemo ndc:) ;
		set IN&ref..PDE&tu._&filesuff.  ;
		*IF SRVC_DT GE &SD. ;

	** The claim must contain an included chemotherapy drug (initiating cancer therapy) NDC code. ** ;
	ndc10 = substr(prod_srvc_id,1,10) ;
	ndc9 = substr(prod_srvc_id,1,9) ;
	ndc8 = substr(prod_srvc_id,1,8) ;

	/*if  %if "&type." = "p1" %then %do ; put(NDC9, $Chemo_NDC.) = "Y" or NDC8 = '00780645' %end ;
		%if "&type." = "p2" %then %do ; put(NDC9, $Chemo_NDC2p.) = "Y" %end ;
		 then do ;*/
	if  ("&type." = "p1" and (put(NDC9, $Chemo_NDC.) = "Y" or NDC8 = '00780645') ) or 
		("&type." = "p2" and put(NDC9, $Chemo_NDC2p.) = "Y" ) or
		("&type." = "p3" and put(NDC9, $Chemo_NDC3p.) = "Y")
		 then do ;

		** The claim “fill date” must be in the appropriate 6 month “Episode Beginning” period in 
		   Table 1, inclusive of end dates. ** ;
			chemo = 1 ;
			format trigger_date perf_chemo mmddyy10. ;
			trigger_date = SRVC_DT ;
			if trigger_date ge &sd. then perf_chemo = trigger_date ;
			output chemo_candidates3/*_cand*/ ;
	end ;
run ;

***** Used for Cancer Flags ***** ;
data chemo_candidates3_b(keep =  EP_ID bene_id pde_id trigger_date perf_chemo ndc:) ;
		set IN&ref..PDE&tu._&filesuff.  ;
		*IF SRVC_DT GE &SD. ;

	** The claim must contain an included chemotherapy drug (initiating cancer therapy) NDC code. ** ;
	ndc10 = substr(prod_srvc_id,1,10) ;
	ndc9 = substr(prod_srvc_id,1,9) ;
	ndc8 = substr(prod_srvc_id,1,8) ;

	/*if  %if "&type." = "p1" %then %do ; put(NDC9, $Chemo_NDC.) = "Y" or NDC8 = '00780645' %end ;
		%if "&type." = "p2" %then %do ; put(NDC9, $Chemo_NDC2p.) = "Y" %end ;
		 then do ;*/
	if  ("&type." = "p1" and (put(NDC9, $Chemo_NDC.) = "Y" or NDC8 = '00780645') ) or 
		("&type." = "p2" and put(NDC9, $Chemo_NDC2p.) = "Y" ) or
		("&type." = "p3" and (put(NDC9,$Chemo_NDC3p.)="Y" or put(NDC9,$Chemo_NDC4p.)="Y" or put(NDC9,$Chemo_NDC5p.)="Y") )
		 then do ;

		** The claim “fill date” must be in the appropriate 6 month “Episode Beginning” period in 
		   Table 1, inclusive of end dates. ** ;
			chemo = 1 ;
			format trigger_date perf_chemo mmddyy10. ;
			trigger_date = SRVC_DT ;
			if trigger_date ge &sd. then perf_chemo = trigger_date ;
			output chemo_candidates3_b ;
	end ;
run ;
***** End - Used for Cancer Flags ***** ;

/*
** A non-denied Carrier (line allowed charge >0) or Outpatient (Medicare non-payment reason code is not blank) 
   claim with an included cancer diagnosis code in any line item (Carrier) or in the header (Outpatient) 
   can be found on the fill date or in the 59 days preceding the fill date. Use line first expense date on the 
   Carrier claims and from date on the Outpatient claims to determine if the claim occurred on the fill date or 
   in the 59 days prior. ** ;
data carrier(keep =  EP_ID bene_id cdate HAS_CANCER) ;
	set lines_partd ;
	if carr=1 and has_cancer = 1 and LALOWCHG > 0 ;
	cdate = expnsdt1 ;
	format cdate mmddyy10. ; 
data op(keep =  bene_id cdate EPALL EP201701 EP201707) ;
	set op_partd ;
	if NOPAY_CD = "  " and has_cancer = 1 ;
	cdate = FROM_DT ;
	format cdate mmddyy10. ;
data cancers ; set carrier op ;
proc sort data=cancers nodupkey ; by  bene_id cdate ;
proc sql ;
	create table chemo3 as
	select a.*, b.EPALL, b.EP201701, b.EP201707
	from chemo_candidates3_cand as a, cancers as b
	where a.bene_id = b.bene_id and
		  (trigger_date-59)<= cdate <= trigger_date ;

data chemo_candidates3 ;
	set chemo3 ;
	*** Removed cancer op/carr lines with Sec Malignancies only has_cancer qualification for triggers
		prior to 1/1/17. *** ;
	if trigger_date < mdy(1,1,2017) and EPALL ne  1  then delete ;
	if trigger_date < mdy(7,1,2017) and max(EPALL,EP201701) ne 1 then delete ;
RUN ;
*/
proc sort data=chemo_candidates3 nodupkey ; by EP_ID bene_id pde_id trigger_date perf_chemo ; run ;
********************************************************************** ;
********************************************************************** ;
**** Step 2: Identify potential episodes ;


** For each potential trigger claim identified in Step 1, flag whether the 6 months following the 
   trigger date meet the three criteria below. Episodes will be end-dated 6 calendar months after the 
   trigger date, even in the case of death before 6 months. ** ;

data triggers ;
	set chemo_candidates1(in=a) 
		chemo_candidates2(in=b) 
		chemo_candidates3(in=c rename=(pde_id=clm_id)) ;
	if trigger_date ge &sd. ;
	if a and carr = 1 then source = 2 ; *** carrier is second in hierarchy *** ;
	if b then source = 1 ; *** outpatient is first in hierarchy *** ;
	if a and carr ne 1 then source = 3 ; *** DME is third in hierarchy *** ;
	if c then source = 4 ; *** Part D is fourth in hierarchy **** ;
proc sort data=triggers ; by EP_ID bene_id perf_chemo ;
proc means data=triggers noprint min ; by EP_ID bene_id ;
	var perf_chemo ;
	output out=in_period (drop = _type_ _freq_)
		   min(perf_chemo) = first_chem_in_per ;


data triggers_a ;
	merge triggers(in=a) in_period(in=b) &IN_RECON. ; by EP_ID BENE_ID ;
	if a ;
	format first_chem_in_per  episode_end mmddyy10. ;
	************************************************************************************************* ;
	*** CHEMO_IN_PP will be flag that marks members who have one of the following 4 characteristics:
		(0): chemo of any type was not found in the data at all
		(3): chemo found only in performance period
	************************************************************************************************* ;
	if a and b and first_chem_in_per ne . then CHEMO_IN_PP = 3 ; 
	else CHEMO_IN_PP = 0 ;

	episode_end = intnx('month', trigger_date, 6,'same')-1 ;

**** Check for prior episode end dates **** ;
%if "&ref." ne "1" %then %do ;
	%prior_episodes ;
	proc sort data=triggers_a ; by bene_id ;
	data triggers_a ;
		merge triggers_a(in=a) prior_episodes; by bene_id ;
		if a ;
		if ep_end_last_pp ne . and trigger_date le ep_end_last_pp then delete ;
	proc sort data=triggers_a ; by ep_id bene_id ;		
%end ;


** The 6 month period beginning with the trigger date must contain a non-denied Carrier claim with an 
   E&M visit (HCPCS code 99201 – 99205, 99211 – 99215) AND an included cancer diagnosis code on the same line item. ** ;
proc sql ;
	create table triggers_a2	 as
	select A.EP_ID, a.bene_id, a.bene_hicn, a.trigger_date, a.source, a.clm_id, a.episode_end, 
		a.CHEMO_IN_PP, a.first_chem_in_per, B.HAS_CANCER, b.EPALL, b.EP201701
	from triggers_a as a, em as b
	where a.bene_id=b.bene_id and
		  A.EP_ID=B.EP_ID AND  
		  trigger_date le b.expnsdt1 le episode_end ;

data triggers_a3 ;
	set triggers_a2 ;
		/*IF %if "&type." = "p1" %then %do ;  EPALL = 1 %end ;
		   %if "&type." = "p2" %then %do ;  MAX(EPALL,EP201701) = 1 %end ; ;*/
		if "&type." = "p1" then do ;
			IF EPALL NE 1 THEN DELETE ; *** REMOVING E&M CLAIMS REPORTING CANCERS THAT ONLY APPLY TO EPISODES BEGINNING AFTER 1/1/2017. *** ;
		end ;
		IF "&type." = "p2" then do ;
			IF MAX(EPALL, EP201701) NE 1 THEN DELETE ;
		END ;

proc sort data=triggers_a3 nodupkey ; by  EP_ID bene_id trigger_date source clm_id  ;

** A trigger claim initiates an episode only when all of the below criteria are met.;

***********
Apply the following hierarchy if there is more than one trigger claim on the same day from different 
types of service: Outpatient, Carrier, DMEPOS, Part D
If there is still more than one trigger claim on the same day within the same type of service, 
choose the claim with the first claim ID. ********* ;

data triggersa ;
	set triggers_a3 ; by  EP_ID bene_id trigger_date ;
	if first.trigger_date then do ;
		prevsource = source ;
		keep = 1 ;
	end ;
	else do ;
		if source = prevsource then keep = 1 ;
		else keep = 0 ;
	end ;
	retain prevsource ;
	if keep = 1 ;

data triggersb ;
	set triggersa ; by  EP_ID bene_id trigger_date source clm_id ;
	if first.clm_id ;

************************************************************************************** ;
************************************************************************************** ;

***********
** For all performance periods, the potential episode trigger date must not be included 
   in any episode defined for a prior performance period.  6 Potential trigger claims occurring 
   inside a previously defined episode cannot trigger a new episode. ** ;
data triggers2 all_triggers  ;
	set triggersb ; by  ep_id bene_id ;
	format pend mmddyy10. ; 
	if first.ep_id   then do ;
		keep_epi = 1 ;
		pend = episode_end ;
	end ;
	else do ;
		if trigger_date le pend then do ;
			pend = pend ;
			keep_epi = 0 ;
		end ;
		else do ;
			pend = episode_end ;
			keep_epi = 1 ;
		end ;
	end ;
	retain pend ;
	if keep_epi = 1 then output triggers2 ;
	output all_triggers ;


proc sort data=triggers2 nodupkey ; by  ep_id trigger_date ;
*** removal of multiple triggers - capturing earliest *** ;
data triggers2 ; 
	set triggers2 ; by ep_id trigger_date ;
	if first.ep_id ;

PROC SORT DATA=&IN_RECON. OUT=REC ; BY EP_ID ;

DATA TRIGGERS3(KEEP = EP_ID M_EPISODE_BEG M_EPI_CLAIM M_EPI_SOURCE)  ;
	SET TRIGGERS2 ;
	format m_episode_beg mmddyy10. ;
	m_episode_beg = trigger_date;
	m_epi_claim = clm_id ;
	m_epi_source = source ;

DATA EPI_ORIG NOMATCH (KEEP = EP_ID BENE_ID EP_BEG EP_END M_EPISODE_BEG M_EPI_CLAIM M_EPI_SOURCE ATTRIBUTE_FLAG bene_in_prior epi_in_prior %if &vers. ne R0 %then %do; Prior_Changed_Episode %end;);
	MERGE REC(IN=A) TRIGGERS3(IN=B) ; BY EP_ID ;
	IF A  ;
	if _n_ = 1 then ecount = 0 ;
	ecount = sum(ecount,1) ;
	EP_LENGTH_MILLIMAN = EP_END-EP_BEG+1 ; ;
	/* TO BE MOVED TO 003 SINCE EP_ID WILL BE USED TO MERGE CLAIMS TO EPISODE FILE */
	*epb = ((year(ep_beg)-2000)*10000)+(month(ep_beg)*100)+day(ep_beg) ;
	*EP_ID = CATS(EP_ID,"-",epb,"-P-","&OCM.")  ;
	IF A AND B=0 THEN ATTRIBUTE_FLAG = "0" ; *** No trigger found. *** ;
	IF EP_BEG NE M_EPISODE_BEG THEN ATTRIBUTE_FLAG = "2" ; 
	if attribute_flag = " " then ATTRIBUTE_FLAG = "1" ; *** trigger found. *** ;

	IF A AND B=0 OR
	   (A AND B AND attribute_flag in ('0','2')) THEN OUTPUT NOMATCH ;
	OUTPUT EPI_ORIG ;

*************RECON CHECK 1: How many episodes mismatch on episode start date? ***************************** ;
proc export data=NOMATCH %if &vers. ne R0 %then %do;(where = (Prior_Changed_Episode ne "Yes")) %end;  
	outfile = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP&ref.\Recon Reports\recon_check1_&VERS._&dsid."
	dbms=xls replace ;
quit ;

********************************************************************** ;
********************************************************************** ;
**** Appendix B: Identify cancer ;

*** for performance period, use all available E&M claims *** ;
proc sql ;
	create table canc as
	select a.*, b.*
	from epi_orig as a, em as b
	where a.EP_ID=b.EP_ID ;

data canc ;
	set canc ;
		/*IF 
			%if "&type." = "p1" %then %do ;  EPALL %END ;
			%if "&type." = "p2" %then %do ;  MAX(EPALL,EP201701) %END;
		= 1 ;*/
		if "&type." = "p1" and EPALL ne 1 then delete ;
		if "&type." = "p2" and max(EPALL,EP201701) ne 1 then delete ;
	

** Identify unique visits and count the number of visits associated with each cancer type. **
** For the purposes of assigning a cancer type to the episode, a visit is defined by the 
   unique combination of beneficiary ID, TIN, line first expense date, and cancer type 
   associated with the diagnosis code on the line. *** ;
proc sort data=canc ; by bene_id ep_id  EP_BEG EP_END %CANC_FLAGS has_cancer tax_num expnsdt1 ;

data visit_count ;
	set canc ; by bene_id ep_id  EP_BEG EP_END %CANC_FLAGS has_cancer tax_num expnsdt1 ;
	if first.expnsdt1 then visit_count = 1 ;						 	 

proc means data=visit_count noprint sum ; by bene_id ep_id  EP_BEG EP_END %CANC_FLAGS HAS_CANCER  ;
	var visit_count ;
	output out=vc1(drop = _type_ _freq_)
		   sum() =  ;
run ;
** Assign the episode the cancer type that has the most visits. ** 
	In the event of a tie, apply tie-breakers in the order below. Assign the cancer type associated with:
	The most recent visit in the episode, second most recent visit, third most recent visit, etc.
	The cancer type that is reconciliation-eligible
	The lowest last digit of the TIN, second lowest digit, etc. ** ;

proc sort data=vc1 ; by bene_id ep_id  EP_BEG EP_END descending visit_count    ;

data cancer ;
	set vc1 ;  by bene_id ep_id  EP_BEG EP_END descending visit_count    ;
	if first.ep_end then do ;
		most = 1 ;
		prevcnt = visit_count ;
	end ;
	else do ;
		if prevcnt = visit_count then most = 1 ;
		else most = 0 ;
	end ;
	retain prevcnt ;
	if most = 1 ;

data mult_cancer uniq_cancer ;
	set cancer ; by bene_id ep_id  EP_BEG EP_END has_cancer ;
	if first.EP_ID and last.EP_ID then output uniq_cancer ;
	else output mult_cancer ;

*** tie_breakers *** ;

	*** a. Capture all visits for episodes with multiple cancer designations. *** ;
	***    Derived field visit_count provides maximum count of visits to run through. *** ;
	proc sort data=mult_cancer ; by  bene_id ep_id EP_BEG EP_END %canc_flags has_cancer ;
	data claims_for_mult ;
		merge mult_cancer(in=a rename=(visit_count=max_visit_count)) visit_count(in=b) ; 
		by  bene_id ep_id EP_BEG EP_END %canc_flags has_cancer ;
		if a ;
		if visit_count = 1 ;
		*** creates a variable of all the flags *** ;
		%canc_var ;
		rev_tax = reverse(Tax_num) ;
		last_dig = substr(left(rev_tax),1,1) ;

	*** b. Sort by descending expnsdt1 - will check for multiple cancers on same day *** ;
	proc sort data=claims_for_mult ; by  bene_id ep_id EP_BEG EP_END descending expnsdt1 ;
	run ;

	*** c. Identify unique dates of service that do NOT have multiple cancer assignments. **** ;
	data udates1 mdates1  ;
		set claims_for_mult ;  by  bene_id ep_id EP_BEG EP_END descending expnsdt1 ;
		if first.expnsdt1 and last.expnsdt1 then output udates1 ;
		else output mdates1 ;

	*** d. Using unique dates of service, assign cancer to most recent DOS. *** ;
	data udates1_chk ;
		set udates1 ; by  bene_id ep_id EP_BEG EP_END descending expnsdt1 ;
		if first.EP_END ;

	*** e. Check for episodes without uniques trigger dates - will move onto reconciliation eligible check. *** ;
	data level2_tie ;
		merge mult_cancer (in=a keep=bene_id ep_id )
			  udates1_chk (in=b keep=bene_id ep_id ) ;
		by bene_id ep_id ;
		if a and b=0 ;

	proc sort data=level2_tie nodupkey ; by bene_id ep_id ;

	*** f. Capture unique cancer/recon_elig combos. *** ;
	data mclaims2 ;
		merge level2_tie(in=a) claims_for_mult(in=b) ; by bene_id ep_id ;
		if a and b ;
		if recon_elig = "Y" then count_y = 1 ; else count_y = 0 ;
	proc sort data=mclaims2 nodupkey out=mc2 ; by bene_id ep_id cancer_chk ;

	proc sort data=mc2 ; by bene_id ep_id ;
	proc means data=mc2 noprint n sum ; by bene_id ep_id ;
		var count_y  ;
		output out=mc2a (drop = _type_ _freq_)
			   n() = cancer_count
			   sum(count_y ) = ;

	*** g. if only one cancer has a recon_elig flag of Y, then keep.  Otherwise goes to TIN tie breaker. *** ;
	data mc2a_canc level3_tie ;
		set mc2a ;
		if count_y < cancer_count and count_y = 1 then output mc2a_canc ;
		else output level3_tie ;

	*** h. capture cancer information for those that pass this tie breaker.  *** ;
	data udates2_chk ;
		merge mc2a_canc(in=a) claims_for_mult(in=b) ; by bene_id ep_id ;
		if a and b and recon_elig = "Y" ;

	data udates2_chk ; 
		set udates2_chk ; by  bene_id ep_id EP_BEG EP_END descending expnsdt1 ;
		if first.ep_end ;
	
	*** i. run remaining through TIN tax ID check  - identify unique REV_TIN and cancer combos *** ;
	*** 3/2/18: As per OCM ticket #868640 - use last digit of tin and then highest clm_id *** ;
	data level3_tie_a ;
		merge mclaims2(in=a) 
			  level3_tie(in=b keep=bene_id ep_id count_y cancer_count) 
			  udates2_chk(in=c keep=bene_id ep_id ) ;
		by bene_id ep_id ;
		if (a and c=0) or
		   (a and b)  ;

		** Only considers reconcilation eligible if there are a mix of eligible and non-eligible cancers *** ;
		if a and b then do ;
			if count_y gt 1  then do ;
				if recon_elig = "N" then delete ;
			end ;
		end ;


	proc sort data=level3_tie_a out=l3 nodupkey ; by bene_id ep_id last_dig descending clm_id cancer_chk ;

	*** j. identify final_cancer based on tin digits  *** ;
	data mc3_canc ;
		set l3 ; by bene_id ep_id last_dig descending clm_id cancer_chk ;
		if first.ep_id ;
		
	proc sort data=claims_for_mult ; by bene_id ep_id last_dig descending clm_id cancer_chk ;

	data udates3_chk ;
		merge mc3_canc (in=a keep=bene_id ep_id last_dig clm_id cancer_chk) claims_for_mult(in=b) ;
		by bene_id ep_id last_dig descending clm_id cancer_chk ;
		if a and b ;

	data udates3_chk ;
		set udates3_chk ; by bene_id ep_id ;
		if first.EP_id ;

	***** k. Combine All Cancer Assignments. ***** ;
		*** uniq_cancer - no tie breakers needed *** ;
		*** udates1_chk - assigned based on most recent e&m claim *** ;
		*** udates2_chk - assigned based on recon eligible flag   *** ;
		*** udates3_chk - defaults to reverse tax digit screen    *** ;
data cancer_assignment (keep =  Bene_id ep_id EP_BEG EP_END cancer recon_elig) ;
	set uniq_cancer
		udates1_chk 
		udates2_chk 
		udates3_chk;
	%assign_cancer ; 
proc sort data=cancer_assignment ; by  	Bene_id ep_id ;

*** the OCM prediction model distinguishes breast cancer episodes containing only Part D 
    chemotherapy from those containing some Part B chemotherapy. **** ;
proc sql;
	create table chemo_claims2 as
	select bene_id, clm_id, max(has_cancer_line) as has_cancer_line_max
	from chemo_claims
	group by  bene_id, clm_id;
quit;

proc sql;
	create table chemo_claims3 as
	select a.*, b.has_cancer_line_max
	from chemo_claims as a left join chemo_claims2 as b
	on a.bene_id=b.bene_id and a.clm_id=b.clm_id;
quit;

***** Used for Cancer Flags ***** ;
proc sql;
	create table chemo_claims2_b as
	select bene_id, clm_id, max(has_cancer_line) as has_cancer_line_max
	from chemo_claims_b
	group by  bene_id, clm_id;
quit;
proc sql;
	create table chemo_claims3_b as
	select a.*, b.has_cancer_line_max
	from chemo_claims_b as a left join chemo_claims2_b as b
	on a.bene_id=b.bene_id and a.clm_id=b.clm_id;
quit;
***** End - Used for Cancer Flags ***** ;

data chemotherapy ;
	set chemo_claims3_b (where = (chemo = 1 and has_cancer_line_max = 1) in=a)
		chemoz_b (where = (chemo = 1 and has_cancer = 1) in=a)
		chemo_candidates2_b (in=b)
		chemo_candidates3_b (in=c) ;
	if a and carr = 1 then source = 2 ; *** carrier is second in hierarchy *** ;
	if b then source = 1 ; *** outpatient is first in hierarchy *** ;
	if a and carr ne 1 then source = 3 ; *** DME is third in hierarchy *** ;
	if c then source = 4 ; *** Part D is fourth in hierarchy **** ;
	if put(NDC9, $Hormonal_breast_NDC.) = "Y" then BC_Hormonal = 1 ; else BC_Hormonal = 0 ;
	if put(NDC9, $Hormonal_breast_NDC.) = "N" then Nonhormonal = 1 ; else Nonhormonal = 0 ;

	BLAD_LR = 0 ; BLAD_OTH = 0 ; PROST_CAST = 0 ; PROST_OTH = 0 ;
	IF PUT(NDC9,$Bladder_LR_NDC.) = "Y" THEN BLAD_LR = 1 ;
	IF PUT(NDC9,$Prostate_CS_NDC.) = "Y" THEN PROST_CAST = 1 ;
	IF PUT(HCPCS_CD,$Bladder_LR_HCPCS.) = "Y" THEN BLAD_LR = 1 ;
	IF PUT(HCPCS_CD,$Prostate_CS_HCPCS.) = "Y" THEN PROST_CAST = 1 ;
	IF BLAD_LR NE 1 THEN BLAD_OTH = 1 ;
	IF PROST_CAST NE 1 THEN PROST_OTH = 1 ;
run;

proc sql ;
	create table triggers_a2 as
	select a.ep_id, b.*
	from epi_orig as a, chemotherapy as b
	where a.EP_id=b.EP_id and ep_beg le trigger_date le ep_end;

proc sort data=triggers_a2 ; by  bene_id ep_id ;
proc means data=triggers_a2 min max noprint ; by  bene_id ep_id ;
	var source ;	
	output out=trigger_s(drop = _type_ _freq_)
		   min(source) = mins 
		   max(source) = maxs
			max(BC_Hormonal) = BC_Hormonals
			max(Nonhormonal) = Nonhormonals
			max(BLAD_LR) = BLAD_LRs
			max(BLAD_OTH) = BLAD_OTHs
			max(PROST_CAST) = PROST_CASTs
			max(PROST_OTH) = PROST_OTHs;

data trigger_s(keep =  bene_id ep_id partdonly BC_Hormonal_only LOW_RISK_BLAD_MILLIMAN CAST_SENS_PROS_MILLIMAN) ;
	set trigger_s ;
	if mins=4 and maxs = 4 then partdonly=1 ; else partdonly = 0 ;
	if BC_Hormonals=1 and Nonhormonals = 0 then BC_Hormonal_only=1 ; else BC_Hormonal_only = 0 ;
	if BLAD_LRs=1 and BLAD_OTHs = 0 then LOW_RISK_BLAD_MILLIMAN=1 ; else LOW_RISK_BLAD_MILLIMAN = 0 ;
	if PROST_CASTs=1 and PROST_OTHs = 0 then CAST_SENS_PROS_MILLIMAN=1 ; else CAST_SENS_PROS_MILLIMAN = 0 ;
run;
/*
data ca ;
	merge cancer_assignment(in=a) trigger_s(in=b) ; by  bene_id ep_id ;
	if a ;
run ;
*/
*** 3/5/18: Need to move merge of trigger_s to episode file since some episodes might not have any E&M claims at all. *** ;
data ca ;
	set cancer_assignment  ;

********************************************************************** ;
********************************************************************** ;
**** Appendix C: Episode Attribution ;


** Attribute the episode to the TIN or OCM ID with the most qualifying visits.
 In the event of a tie, apply tie-breakers in the order below. Attribute the episode to the TIN/OCM ID with:
	The most recent visit in the episode, second most recent visit, third most recent visit, etc.
	The lowest last digit of the TIN, second lowest digit, etc.
 In cases where practices have pooled together for the purposes of reconciliation, continue to attribute 
	episodes to the individual OCM IDs within the pool. Do not combine visits across the OCM IDs in the pool 
	for the purposes of determining plurality. **** ;


proc sql ;
	create table canc2 as
	select a.ep_id, a.ep_beg, a.ep_end, b.*
	from epi_orig as a, em as b
	where a.ep_id=b.ep_id ;

data canc2 ;
	set canc ;
		/*IF 
			%if "&type." = "p1" %then %do ;  EPALL %END ;
			%if "&type." = "p2" %then %do ;  MAX(EPALL,EP201701) %END;
		= 1 ;*/
		if "&type." = "p1" and EPALL ne 1 then delete ;
		if "&type." = "p2" and max(EPALL,EP201701) ne 1 then delete ;


** Identify unique visits and count the number of visits associated with each cancer type. **
** For the purposes of assigning a cancer type to the episode, a visit is defined by the 
   unique combination of beneficiary ID, TIN, line first expense date, and cancer type 
   associated with the diagnosis code on the line. *** ;
proc sort data=canc2 ; by  bene_id ep_id ep_beg ep_end tax_num expnsdt1 ;

data visit_count2 ;
	set canc2 ; by  bene_id ep_id ep_beg ep_end tax_num expnsdt1 ;
	if first.expnsdt1 then visit_count = 1 ;						 	 

proc sort data=visit_count2 ; by  bene_id ep_id ep_beg ep_end tax_num prfnpi ;
proc means data=visit_count2 noprint sum ; by  bene_id ep_id ep_beg ep_end tax_num prfnpi;
	var visit_count ;
	output out=vc_npi(drop = _type_ _freq_)
		   sum() =  ;
proc means data=vc_npi noprint sum ; by  bene_id ep_id ep_beg ep_end tax_num ;
	var visit_count ;
	output out=vc(drop = _type_ _freq_)
		   sum() =  ;


proc sort data=vc ; by  bene_id ep_beg ep_id ep_end descending visit_count ;
data vc2 ;
	set vc ; by  bene_id ep_id ep_beg ep_end descending visit_count ;
	if first.ep_end then do ;
		MOST = 1 ;
		PREV_VC = VISIT_COUNT ;
	END ;
	else do ;
		if visit_count = prev_vc then most = 1 ; 
		else most = 0 ;
	end ;
	if most = 1 ;
	retain prev_vc ;

proc sort data=vc2 ; by  bene_id ep_id ep_beg ep_end tax_num ;
data mult_ids uniq_ids ;
	set vc2 ; by  bene_id ep_id ep_beg ep_end tax_num ;
	if first.bene_id and last.bene_id then output uniq_ids ;
	else output mult_ids ;


*** tie-breakers *** ;
proc sort data=visit_count2 ; by  bene_id ep_id ep_beg ep_end tax_num ;
	*** a. Capture all visits for episodes with multiple cancer designations. *** ;
	data claims_for_mult ;
		merge mult_ids(in=a) visit_count2(in=b) ; 
		by  bene_id ep_beg ep_end tax_num ;
		if a ;
		if visit_count = 1 ;
		rev_tax = reverse(Tax_num) ;
	*** b. Sort by descending expnsdt1 - will check for multiple cancers on same day *** ;
	proc sort data=claims_for_mult ; by  bene_id ep_id ep_beg ep_end descending expnsdt1 ;
	run ;
	*** c. Identify unique dates of service that do NOT have multiple tax numbers. **** ;
	proc sql;
		create table tiebreak_claims1 as
		select bene_id, ep_id, ep_beg, ep_end, max(expnsdt1) as max_epi_dt
		from claims_for_mult
		group by bene_id, ep_id, ep_beg, ep_end;
	quit;
	proc sql;
		create table tiebreak_claims2 as
		select a.*, b.max_epi_dt
		from claims_for_mult as a left join tiebreak_claims1 as b
		on a.bene_id=b.bene_id 
			and a.ep_id=b.ep_id
			and a.ep_beg=b.ep_beg
			and a.ep_end=b.ep_end;
	quit;
	data claims_for_mult2;
		set tiebreak_claims2;
		clm_last_dt=0;
		if expnsdt1 = max_epi_dt then clm_last_dt=1;
	run;

	data udates1 mdates1 ;
		set claims_for_mult2 ; by  bene_id ep_id ep_beg ep_end descending expnsdt1 ;
		if first.expnsdt1 and last.expnsdt1 then output udates1 ;
		else output mdates1 ;
	
	*** d. Using unique dates of service, assign TIN to most recent DOS. *** ;
	data udates1_chk ;
		set udates1 ; by  bene_id ep_id ep_beg ep_end descending expnsdt1 ;
		if first.ep_end and clm_last_dt=1;

	*** e. Check for episodes without uniques trigger dates - will move onto TIN check. *** ;
	data level2_tie ;
		merge mult_ids (in=a keep=bene_id ep_id)
			  udates1_chk (in=b keep=bene_id ep_id) ;
		by bene_id ep_id;
		if a and b=0 ;

	proc sort data=level2_tie nodupkey ; by bene_id ep_id;

	*** f. run remaining through TIN tax ID check  - identify unique REV_TIN and cancer combos *** ;
	*** 3/2/18: As per OCM ticket #868640 - use last digit of tin and then highest clm_id *** ;
	data mt2 ;
		merge level2_tie(in=a keep=bene_id ep_id)
			  claims_for_mult2(in=b) ; by bene_id ep_id;
		if a and b ;
		last_dig = substr(left(rev_tax),1,1) ;

	proc sort data=mt2 ; by bene_id ep_id ep_beg ep_end rev_tax;
	*** g. identify final_cancer based on tin digits  *** ;
	data udates2_chk ;
		set mt2 ; by bene_id ep_id ep_beg ep_end rev_tax   ;
		if first.ep_end ;

	***** h. Combine All Cancer Assignments. ***** ;
		*** uniq_ids - no tie breakers needed *** ;
		*** udates1_chk - assigned based on most recent e&m claim *** ;
		*** udates2_chk - assigned based on reverse order of TIN   *** ;
data tax (keep =  bene_id ep_id epi_tax_id ep_beg ep_end) ;
	set uniq_ids
		udates1_chk 
		udates2_chk ;
	epi_tax_id = tax_num ;

*** Check to make sure only one tax ID  has been attributed to each episode. Record count of dupl_chk should = 0 *** ;
proc sort data=tax ; by bene_id ep_id ep_beg ep_end ;
data dupl_chk ;
	set tax ; by bene_id ep_id ;
	if first.ep_id=0 or last.ep_id=0 then output ;

			********************************************************************** ;
**** For Episodes Attribution, need to attribute the episode tax id to the NPI with the most e and m **** ;
**** Tie breaker logic for NPI to tax decision to follow OCMs tie breaker logic.  **** ;
			********************************************************************** ;
proc sql ;
	create table step1 as
	select a.epi_tax_id, b.* 
	from tax as a inner join vc_npi as b 
	on a.bene_id=b.bene_id and a.epi_tax_id	= b.tax_num and a.ep_id=b.ep_id 
	where visit_count ^ = .;

proc sort data=step1 ; by  bene_id ep_id ep_beg ep_end tax_num descending visit_count ;
data step2 ;
	set step1 ; by  bene_id ep_id ep_beg ep_end tax_num descending visit_count ;
	if first.ep_end then do ;
		MOST = 1 ;
		PREV_VC = VISIT_COUNT ;
	END ;
	else do ;
		if visit_count = prev_vc then most = 1 ; 
		else most = 0 ;
	end ;
	if most = 1 ;
	retain prev_vc ;

proc sort data=step2 ; by  bene_id ep_id ep_beg ep_end tax_num prfnpi;
data step3_mult step3_uniq ;
	set step2 ; by  bene_id ep_id ep_beg ep_end tax_num prfnpi ;
	if first.ep_id  and last.ep_id  then output step3_uniq ;
	else output step3_mult ;
run;
*** tie-breakers *** ;
proc sort data=visit_count2 ; by  bene_id ep_id ep_beg ep_end tax_num prfnpi ;
data step3_multclms ;
	merge step3_mult(in=a) visit_count2(in=b) ; 
	by  bene_id ep_id ep_beg ep_end tax_num prfnpi ;
	if a and b ;
	revnpi = reverse(prfnpi) ;
	last_dig = substr(left(revnpi),1,1) ;

proc sort data=step3_multclms out=s3 nodupkey ; by bene_id ep_id ep_beg ep_end tax_num descending expnsdt1 revnpi ;

data udate1 mdate1 ;
	set s3 ; by bene_id ep_id ep_beg ep_end tax_num descending expnsdt1 revnpi;
	if first.expnsdt1 and last.expnsdt1 then output udate1 ;
	else output mdate1 ;

data unnpi1 ;
	set udate1 ;by bene_id ep_id ep_beg ep_end tax_num descending expnsdt1 revnpi;
	if first.tax_num then output ;

data level4_tie ;
	merge unnpi1(in=a keep=bene_id ep_id ep_beg ep_end tax_num)
		  step3_multclms (in=b) ; by bene_id ep_id ep_beg ep_end tax_num ;
	if a=0 and b ;

	*** 3/2/18: As per OCM ticket #868640 - use last digit of tin and then highest clm_id *** ;
proc sort data=level4_tie ; by bene_id ep_id ep_beg ep_end tax_num revnpi;
data unnpi2 ;
	set leveL4_tie ;by bene_id ep_id ep_beg ep_end tax_num revnpi;
	if first.tax_num ;

data taxnpi(keep =  bene_id ep_id epi_npi_id) ;
	set step3_uniq
		unnpi1
		unnpi2;
	epi_npi_id = prfnpi ;
 
proc sort data= taxnpi ; by  bene_id ep_id ;
********************************************************************** ;
********************************************************************** ;
**** Step 4: Check for episode prediction model variables ;
**** Surgery, Radiation, BMT									****** ;

*** From OCM Prediction Model.pdf *** ;

*** Twelve of the cancer types have cancer-related surgeries that are controlled for 
	in the OCM prediction model if the surgeries occur during an episode. *** ;

*** If any claim during an episode had one of the procedure codes listed for radiation delivery, 
	the RADIATION variable was assigned a value of 1 (otherwise 0). *** ;

*** Two bone marrow transplant (BMT) variables are calculated: one for allogeneic BMTs (BMT_ALLOGENEIC) 
	and one for autologous BMTs (BMT_AUTOLOGOUS). BMTs will be counted for four cancer types: Acute Leukemia, 
	Lymphoma, Multiple Myeloma, and MDS. If both types of BMT appear in a given episode, the allogeneic BMT will 
	take precedence. BMT procedures are identified by the codes included in the document “OCM Prediction Model 
	Code Lists,” which is available on the OCM Portal. The claim with the BMT procedure code or DRG must contain 
	a diagnosis code for the same cancer type as the episode.*** ;


*** There are differences in code lists between PP1/PP2 and PP3.  Need to create 2 flags. *** ;
*ip* ;
data h ;
	set IN&ref..iphdr&tu._&filesuff. ;
data r ;
	set IN&ref..inprev&tu._&filesuff. ;


proc sort data=h ; by  bene_id clm_id thru_dt ;
proc sort data=r ; by  bene_id clm_id thru_dt ;

data rec&ref..inpatient_&type.&vers._&dsid. ;
	merge h(in=a) r(in=b) ; by  bene_id clm_id thru_dt ;
	if a and b ;
	*IF ADMSN_DT GE &SD. ;

data ipop ;
	set rec&ref..inpatient_&type.&vers._&dsid.(in=a) rec&ref..outpatient_&type.&vers._&dsid.(in=b) ;
	if a then do ;
		start_date = ADMSN_DT ;
		from_ip_file = 1 ;
	end ;
	if b then do ;
		if "&type." not in ("p1","p2") then do ;
			start_date = REV_DT ;
		end;
		else do;
			start_date = from_dt ;
		end;
		from_ip_file = 0 ;
	end ;

proc sql ;
	create table ipop2 as
	select a.ep_id, a.ep_beg, a.ep_end, a.cancer_type, b.* 
	from epi_orig as a, ipop as b
	where a.ep_id = b.ep_id and
		  a.ep_beg le start_date le a.ep_end ;
quit ;

data rec&ref..check_ipop_&type.&vers._&dsid.
			  (KEEP =  BENE_ID EP_ID CLM_ID THRU_DT BMT_ALLOGENEIC BMT_AUTOLOGOUS
					   RADTHER 
					   ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY
					   GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
					   OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY
					   dxANAL_SURGERY dxBLADDER_SURGERY dxBREAST_SURGERY dxFEMALEGU_SURGERY
					   dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY dxLIVER_SURGERY dxLUNG_SURGERY
					   dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY 
					   CLINICAL_TRIAL_MILL ) ;
	set ipop2 ;

		ARRAY INIT (B) CT HAS_CANCER BMT_ALLO BMT_AUTO BMT_ALLOGENEIC BMT_AUTOLOGOUS
				       RADTHER 
					   ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY
					   GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
					   OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY
					   dxANAL_SURGERY dxBLADDER_SURGERY dxBREAST_SURGERY dxFEMALEGU_SURGERY
					   dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY dxLIVER_SURGERY dxLUNG_SURGERY
					   dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY 
					   CLINICAL_TRIAL_MILL ;
		DO B = 1 TO DIM(INIT) ;
			INIT = 0 ;
		END ;


		%canc_init ;

		ARRAY v (I) ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD25 ;
		ARRAY d (I) ICD_DGNS_CD1-ICD_DGNS_CD25 ;	
		DO I = 1 TO 25 ;
			%CANCERTYPE(v, d) ;
			IF V = '9' and D = "V707" and NOPAY_CD = ' ' THEN CT = 1 ;
			IF V = '0' and D = "Z006" and NOPAY_CD = ' ' THEN CT = 1 ;
		END ;
		DROP I ;

		%null_canc ;

		IF has_cancer = 1 AND CT = 1 THEN DO ;			
			IF from_ip_file = 1  THEN CLINICAL_TRIAL_MILL = 1 ;
			ELSE DO ;
				if "&type." not in ("p1","p2") then do ;
					IF (EP_BEG LE THRU_DT LE EP_END) OR
							(EP_BEG LE FROM_DT LE EP_END) THEN CLINICAL_TRIAL_MILL = 1 ;
				end;
				else do;
					IF /*(EP_BEG LE THRU_DT LE EP_END) OR*/
							(EP_BEG LE FROM_DT LE EP_END) THEN CLINICAL_TRIAL_MILL = 1 ;
				end;
			END ;
		END ;


		IF NOPAY_CD = '  ' THEN DO ;

			ARRAY v1 (X) ICD_prcdr_VRSN_CD1-ICD_prcdr_VRSN_CD25 ;
			ARRAY d1 (X) ICD_prcdr_CD1-ICD_prcdr_CD25 ;
			DO X = 1 TO DIM(D1) ;
				*Current Performance Period Mapping ;
				if "&type." not in ("p1","p2") then do ;
					if v1 = '9' then do ;
						if put(d1,$Anal_ICD9_.) = "Y" then ANAL_SURGERY = 1 ;
						if put(d1,$Bladder_ICD9_.) = "Y" then BLADDER_SURGERY = 1 ;
						if put(d1,$Breast_ICD9_.) = "Y" then BREAST_SURGERY = 1 ;
						if put(d1,$FemaleGU_ICD9_.) = "Y" then FEMALEGU_SURGERY = 1 ;
						if put(d1,$Gastro_ICD9_.) = "Y" then GASTRO_SURGERY = 1 ;
						if put(d1,$HeadNeck_ICD9_.) = "Y" then HEADNECK_SURGERY = 1 ;
						if put(d1,$Intestinal_ICD9_.) = "Y" then INTESTINAL_SURGERY = 1 ;
						if put(d1,$Kidney_ICD9_.) = "Y" then KIDNEY_SURGERY = 1 ;
						if put(d1,$Liver_ICD9_.) = "Y" then LIVER_SURGERY = 1 ;
						if put(d1,$Lung_ICD9_.) = "Y" then LUNG_SURGERY = 1 ;
						if put(d1,$Ovarian_ICD9_.) = "Y" then OVARIAN_SURGERY = 1 ;
						if put(d1,$Pancreatic_ICD9_.) = "Y" then PANCREATIC_SURGERY = 1 ;
						if put(d1,$Prostate_ICD9_.) = "Y" then PROSTATE_SURGERY = 1 ;
						if put(d1,$RadTher_ICD9_.) = "Y" then RADTHER = 1 ;
						IF PUT(D1,$BMT_ICD9_.) = "Y" THEN DO ;
							IF D1 IN ('4102','4103','4105','4106','4108') THEN BMT_ALLO1 = 1 ;
							IF D1 NOTIN ('4102','4103','4105','4106','4108') THEN BMT_AUTO1 = 1 ;
						END ;
					end ;	
					if v1 = '0' then do ;
						if put(d1,$Anal_ICD10_.) = "Y" then ANAL_SURGERY = 1 ;
						if put(d1,$Bladder_ICD10_.) = "Y" then BLADDER_SURGERY = 1 ;
						if put(d1,$Breast_ICD10_.) = "Y" then BREAST_SURGERY = 1 ;
						if put(d1,$FemaleGU_ICD10_.) = "Y" then FEMALEGU_SURGERY = 1 ;
						if put(d1,$Gastro_ICD10_.) = "Y" then GASTRO_SURGERY = 1 ;
						if put(d1,$HeadNeck_ICD10_.) = "Y" then HEADNECK_SURGERY = 1 ;
						if put(d1,$Intestinal_ICD10_.) = "Y" then INTESTINAL_SURGERY = 1 ;
						if put(d1,$Kidney_ICD10_.) = "Y" then KIDNEY_SURGERY = 1 ;
						if put(d1,$Liver_ICD10_.) = "Y" then LIVER_SURGERY = 1 ;
						if put(d1,$Lung_ICD10_.) = "Y" then LUNG_SURGERY = 1 ;
						if put(d1,$Ovarian_ICD10_.) = "Y" then OVARIAN_SURGERY = 1 ;
						if put(d1,$Pancreatic_ICD10_.) = "Y" then PANCREATIC_SURGERY = 1 ;
						if put(d1,$Prostate_ICD10_.) = "Y" then PROSTATE_SURGERY = 1 ;
						if put(d1,$RadTher_ICD10_.) = "Y" then RADTHER = 1 ;
						IF PUT(D1,$BMT_ICD10_.) = "Y" THEN DO ;
							IF D1 IN (
										'30230G2','30230G3','30230G4','30230X2','30230X3','30230X4','30230Y2',
										'30230Y3','30230Y4','30233G2','30233G3','30233G4','30233X2','30233X3',
										'30233X4','30233Y2','30233Y3','30233Y4','30240G2','30240G3','30240G4',
										'30240X2','30240X3','30240X4','30240Y2','30240Y3','30240Y4','30243G2',
										'30243G3','30243G4','30243X2','30243X3','30243X4','30243Y2','30243Y3',
										'30243Y4','30250G1','30250X1','30250Y1','30253G1','30253X1','30253Y1',
										'30260G1','30260X1','30260Y1','30263G1','30263X1','30263Y1'
									) THEN BMT_ALLO1 = 1 ;
							IF D1 NOTIN (
										'30230G2','30230G3','30230G4','30230X2','30230X3','30230X4','30230Y2',
										'30230Y3','30230Y4','30233G2','30233G3','30233G4','30233X2','30233X3',
										'30233X4','30233Y2','30233Y3','30233Y4','30240G2','30240G3','30240G4',
										'30240X2','30240X3','30240X4','30240Y2','30240Y3','30240Y4','30243G2',
										'30243G3','30243G4','30243X2','30243X3','30243X4','30243Y2','30243Y3',
										'30243Y4','30250G1','30250X1','30250Y1','30253G1','30253X1','30253Y1',
										'30260G1','30260X1','30260Y1','30263G1','30263X1','30263Y1'
									) THEN BMT_AUTO1 = 1 ;
						end ;
					end ;
				end ;
				* Prior Performance Period Mappings *;
				*** Performance Periods 1 + 2 *** ;
				else do ; 
					if v1 = '9' then do ;
						if put(d1,$Anal_ICD9_2p.) = "Y" then ANAL_SURGERY = 1 ;
						if put(d1,$Bladder_ICD9_2p.) = "Y" then BLADDER_SURGERY = 1 ;
						if put(d1,$Breast_ICD9_2p.) = "Y" then BREAST_SURGERY = 1 ;
						if put(d1,$FemaleGU_ICD9_2p.) = "Y" then FEMALEGU_SURGERY = 1 ;
						if put(d1,$Gastro_ICD9_2p.) = "Y" then GASTRO_SURGERY = 1 ;
						if put(d1,$HeadNeck_ICD9_2p.) = "Y" then HEADNECK_SURGERY = 1 ;
						if put(d1,$Intestinal_ICD9_2p.) = "Y" then INTESTINAL_SURGERY = 1 ;
						if put(d1,$Liver_ICD9_2p.) = "Y" then LIVER_SURGERY = 1 ;
						if put(d1,$Lung_ICD9_2p.) = "Y" then LUNG_SURGERY = 1 ;
						if put(d1,$Ovarian_ICD9_2p.) = "Y" then OVARIAN_SURGERY = 1 ;
						if put(d1,$Pancreatic_ICD9_2p.) = "Y" then PANCREATIC_SURGERY = 1 ;
						if put(d1,$Prostate_ICD9_2p.) = "Y" then PROSTATE_SURGERY = 1 ;
						if put(d1,$RadTher_ICD9_2p.) = "Y" then RADTHER = 1 ;
						IF PUT(D1,$BMT_ICD9_2p.) = "Y" THEN DO ;
							IF D1 IN ('4102','4103','4105','4106','4108') THEN BMT_ALLO1 = 1 ;
							IF D1 NOTIN ('4102','4103','4105','4106','4108') THEN BMT_AUTO1 = 1 ;
						END ;
					end ;			
					if v1 = '0' then do ;
						if put(d1,$Anal_ICD10_2p.) = "Y" then ANAL_SURGERY = 1 ;
						if put(d1,$Bladder_ICD10_2p.) = "Y" then BLADDER_SURGERY = 1 ;
						if put(d1,$Breast_ICD10_2p.) = "Y" then BREAST_SURGERY = 1 ;
						if put(d1,$FemaleGU_ICD10_2p.) = "Y" then FEMALEGU_SURGERY = 1 ;
						if put(d1,$Gastro_ICD10_2p.) = "Y" then GASTRO_SURGERY = 1 ;
						if put(d1,$HeadNeck_ICD10_2p.) = "Y" then HEADNECK_SURGERY = 1 ;
						if put(d1,$Intestinal_ICD10_2p.) = "Y" then INTESTINAL_SURGERY = 1 ;
						if put(d1,$Liver_ICD10_2p.) = "Y" then LIVER_SURGERY = 1 ;
						if put(d1,$Lung_ICD10_2p.) = "Y" then LUNG_SURGERY = 1 ;
						if put(d1,$Ovarian_ICD10_2p.) = "Y" then OVARIAN_SURGERY = 1 ;
						if put(d1,$Pancreatic_ICD10_2p.) = "Y" then PANCREATIC_SURGERY = 1 ;
						if put(d1,$Prostate_ICD10_2p.) = "Y" then PROSTATE_SURGERY = 1 ;
						if put(d1,$RadTher_ICD10_2p.) = "Y" then RADTHER = 1 ;
						IF PUT(D1,$BMT_ICD10_2p.) = "Y" THEN DO ;
							IF D1 IN (
										'30230G2','30230G3','30230G4','30230X2','30230X3','30230X4','30230Y2',
										'30230Y3','30230Y4','30233G2','30233G3','30233G4','30233X2','30233X3',
										'30233X4','30233Y2','30233Y3','30233Y4','30240G2','30240G3','30240G4',
										'30240X2','30240X3','30240X4','30240Y2','30240Y3','30240Y4','30243G2',
										'30243G3','30243G4','30243X2','30243X3','30243X4','30243Y2','30243Y3',
										'30243Y4','30250G1','30250X1','30250Y1','30253G1','30253X1','30253Y1',
										'30260G1','30260X1','30260Y1','30263G1','30263X1','30263Y1'
									) THEN BMT_ALLO1 = 1 ;
							IF D1 NOTIN (
										'30230G2','30230G3','30230G4','30230X2','30230X3','30230X4','30230Y2',
										'30230Y3','30230Y4','30233G2','30233G3','30233G4','30233X2','30233X3',
										'30233X4','30233Y2','30233Y3','30233Y4','30240G2','30240G3','30240G4',
										'30240X2','30240X3','30240X4','30240Y2','30240Y3','30240Y4','30243G2',
										'30243G3','30243G4','30243X2','30243X3','30243X4','30243Y2','30243Y3',
										'30243Y4','30250G1','30250X1','30250Y1','30253G1','30253X1','30253Y1',
										'30260G1','30260X1','30260Y1','30263G1','30263X1','30263Y1'
									) THEN BMT_AUTO1 = 1 ;
					    end ;
					end ;
				end ;
			END ;
			DROP X ;

			* Current Performance Period Mapping * ;
			if "&type." not in ("p1","p2") then do ;
				if REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 then do ;
					if put(hcpcs_cd,$RadTher_CPT.) = "Y" then RADTHER = 1 ;
					if put(hcpcs_cd,$Prostate_CPT.) = "Y" then PROSTATE_SURGERY = 1 ;
					if put(hcpcs_cd,$Pancreatic_CPT.) = "Y" then PANCREATIC_SURGERY = 1 ;
					if put(hcpcs_cd,$Ovarian_CPT.) = "Y" then OVARIAN_SURGERY = 1 ;
					if put(hcpcs_cd,$Kidney_CPT.) = "Y" then KIDNEY_SURGERY = 1 ;
					if put(hcpcs_cd,$HeadNeck_CPT.) = "Y" then HEADNECK_SURGERY = 1 ;
					if put(hcpcs_cd,$Intestinal_CPT.) = "Y" then INTESTINAL_SURGERY = 1 ;
					if put(hcpcs_Cd,$Gastro_CPT.) = "Y" then GASTRO_SURGERY = 1 ;
					if put(hcpcs_cd,$FemaleGU_CPT.) = "Y" then FEMALEGU_SURGERY = 1 ;
					if put(hcpcs_cd,$Breast_CPT.) = "Y" then BREAST_SURGERY = 1 ;
				end;

				IF SUM(ACUTE_LEUKEMIA,LYMPHOMA,MULT_MYELOMA,MDS, CHRONIC_LEUKEMIA) > 0 THEN DO ;
					IF PUT(DRG_CD,$BMT_DRG.) = "Y" THEN DO ;
						IF DRG_CD = '014' THEN BMT_ALLO2 = 1 ; 
						IF DRG_CD NE '014' THEN BMT_AUTO2 = 1 ; 
					END ;

					BMT_ALLOGENEIC = MAX(BMT_ALLO1,BMT_ALLO2) ;
					BMT_AUTOLOGOUS = MAX(BMT_AUTO1,BMT_AUTO2) ;
			
					if REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 then do ;
						IF SUM(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) LT 1 THEN DO ;
							IF PUT(HCPCS_CD,$BMT_CPT.) = "Y" THEN DO ;
								IF HCPCS_CD = '38240' THEN BMT_ALLOGENEIC = 1 ;
								ELSE BMT_AUTOLOGOUS = 1 ;
							END ;				
						END ;
					end;
				END ;
			end ;
			else do ;
				* Prior Performance Period Mappings * ;
				*** Performance Periods 1 + 2 *** ;
				if REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 then do ;
					if put(hcpcs_cd,$RadTher_CPT2p.) = "Y" then RADTHER = 1 ;
					if put(hcpcs_cd,$Prostate_CPT2p.) = "Y" then PROSTATE_SURGERY = 1 ;
					if put(hcpcs_cd,$Pancreatic_CPT2p.) = "Y" then PANCREATIC_SURGERY = 1 ;
					if put(hcpcs_cd,$Ovarian_CPT2p.) = "Y" then OVARIAN_SURGERY = 1 ;
					if put(hcpcs_cd,$Liver_CPT2p.) = "Y" then LIVER_SURGERY = 1 ;
					if put(hcpcs_cd,$HeadNeck_CPT2p.) = "Y" then HEADNECK_SURGERY = 1 ;
					if put(hcpcs_Cd,$Gastro_CPT2p.) = "Y" then GASTRO_SURGERY = 1 ;
					if put(hcpcs_cd,$FemaleGU_CPT2p.) = "Y" then FEMALEGU_SURGERY = 1 ;
					if put(hcpcs_cd,$Breast_CPT2p.) = "Y" then BREAST_SURGERY = 1 ;
				end;

				*IF SUM(ACUTE_LEUKEMIA,LYMPHOMA,MULT_MYELOMA,MDS) > 0 THEN DO ;
					IF PUT(DRG_CD,$BMT_DRG2P.) = "Y" THEN DO ;
						IF DRG_CD = '014' THEN BMT_ALLO2 = 1 ; 
						IF DRG_CD ne '014' THEN BMT_AUTO2 = 1 ;
					END ;

					BMT_ALLOGENEIC = MAX(BMT_ALLO1,BMT_ALLO2) ;
					BMT_AUTOLOGOUS = MAX(BMT_AUTO1,BMT_AUTO2) ;
			
					if REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 then do ;
						IF SUM(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) LT 1 THEN DO ;
							IF PUT(HCPCS_CD,$BMT_CPT2P.) = "Y" THEN DO ;
								IF HCPCS_CD = '38240' THEN BMT_ALLOGENEIC = 1 ;
								ELSE BMT_AUTOLOGOUS = 1 ;
							END ;
						END ;
					END ;
				*END ;
			end ;
				
			*** Added 7/26/18 - Update to include surgeries with a header level diagnosis
				code for the cancer indicated for the surgery. *** ;
			if ANAL_SURGERY = 1 AND ANAL = 1 THEN dxANAL_SURGERY = 1 ;
			if BLADDER_SURGERY = 1 and BLADDER = 1 then dxBLADDER_SURGERY = 1 ;
			if BREAST_SURGERY=1 and breast = 1 then dxBREAST_SURGERY = 1 ;
			if FEMALEGU_SURGERY and FEMALEGU=1 then dxFEMALEGU_SURGERY = 1 ;
			if GASTRO_SURGERY and GASTRO_ESOPHAGEAL=1 then dxGASTRO_SURGERY = 1 ;
			if HEADNECK_SURGERY=1  and HEADNECK=1 then dxHEADNECK_SURGERY = 1 ;
			if INTESTINAL_SURGERY and intestinal = 1 then dxINTESTINAL_SURGERY = 1 ;
			if KIDNEY_SURGERY=1 and KIDNEY=1 then dxKIDNEY_SURGERY = 1 ;
			if LIVER_SURGERY = 1 AND LIVER = 1 THEN dxLIVER_SURGERY = 1 ;
			if LUNG_SURGERY = 1 and LUNG = 1 then dxLUNG_SURGERY = 1 ;
			if OVARIAN_SURGERY=1 and OVARIAN=1 then dxOVARIAN_SURGERY = 1 ;
			if prostate_surgery = 1 and prostate = 1 then dxPROSTATE_SURGERY = 1 ;
			if PANCREATIC_SURGERY = 1 and PANCREATIC=1 then dxPANCREATIC_SURGERY = 1 ;
		
		end ;
run;
				
			
data carr ;
	set IN&ref..phymeosline&tu._&filesuff. ;
data hdr(keep = ep_id bene_id clm_id from_dt thru_dt icd_dgns_cd: ICD_DGNS_VRSN_CD:) ;
	set in&ref..phymeoshdr&tu._&filesuff. ;
data dme ;
	set IN&ref..dmeline&tu._&filesuff. ;
data hdrd(keep = ep_id bene_id clm_id from_dt thru_dt icd_dgns_cd: ICD_DGNS_VRSN_CD:) ;
	set in&ref..dmehdr&tu._&filesuff. ;
proc sort data=carr ; by ep_id bene_id clm_id thru_dt ;
proc sort data=hdr ; by ep_id bene_id clm_id thru_dt ;
proc sort data=dme ; by ep_id bene_id clm_id thru_dt ;
proc sort data=hdrd ; by ep_id bene_id clm_id thru_dt ;

data phys ;
	merge carr(in=a) hdr(in=b) ; by ep_id bene_id clm_id thru_dt ;
	if a and b ;
run;
data dmel ;
	merge dme(in=a) hdrd(in=b) ; by ep_id bene_id clm_id thru_dt ;
	if a and b ;
run;

%if &type. ^= p1 and &type. ^= p2 %then %do ;
	proc sql ;
		create table carr2 as
		select a.ep_id, a.ep_beg, a.ep_end, a.cancer_type, b.* 
		from epi_orig as a, phys as b
		where a.EP_id = b.EP_id and
			  a.ep_beg le b.EXPNSDT1 le a.ep_end ;
	quit ;

	proc sql ;
		create table dmel2 as
		select a.ep_id, a.ep_beg, a.ep_end, a.cancer_type, b.* 
		from epi_orig as a, dmel as b
		where a.EP_id = b.EP_id and
			  a.ep_beg le b.EXPNSDT1 le a.ep_end ;
	quit ;
%end ;
%else %do ;
	proc sql ;
		create table carr2 as
		select a.ep_id, a.ep_beg, a.ep_end, a.cancer_type, b.* 
		from epi_orig as a, phys as b
		where a.EP_id = b.EP_id and
			  a.ep_beg le b.from_dt le a.ep_end ;
	quit ;

	proc sql ;
		create table dmel2 as
		select a.ep_id, a.ep_beg, a.ep_end, a.cancer_type, b.* 
		from epi_orig as a, dmel as b
		where a.EP_id = b.EP_id and
			  a.ep_beg le b.from_dt le a.ep_end ;
	quit ;
%end ;


data check_carr(KEEP =  BENE_ID EP_ID CLM_ID THRU_DT RADTHER 
					   ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY
					   GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
					   OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY
					   dxBREAST_SURGERY dxFEMALEGU_SURGERY dxGASTRO_SURGERY dxHEADNECK_SURGERY 
					   dxINTESTINAL_SURGERY dxKIDNEY_SURGERY dxOVARIAN_SURGERY dxPANCREATIC_SURGERY 
				       dxPROSTATE_SURGERY dxLIVER_SURGERY
					   CLINICAL_TRIAL_MILL )  ;	
	set carr2 dmel2(in=a);
	if a then dme_flag = 1 ;
	else dme_flag = 0 ;

	ARRAY INIT (B) 	   RADTHER 
					   ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY
					   GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
					   OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY 
					   dxBREAST_SURGERY dxFEMALEGU_SURGERY
					   dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY dxLIVER_SURGERY 
					   dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY 
					   CLINICAL_TRIAL_MILL ;
		DO B = 1 TO DIM(INIT) ;
			INIT = 0 ;
		END ;

	if LALOWCHG > 0 then do ;

			*** Clinical Trial screens all available header diagnosis codes *** ;
			array dx (l) LINE_ICD_DGNS_CD ICD_DGNS_CD: ;
			array vx (l) LINE_ICD_DGNS_VRSN_CD ICD_DGNS_VRSN_CD: ;
			do l = 1 to dim(dx) ;
				%CANCERTYPE(VX,DX) ;
				IF vx = '9' and dx = "V707" THEN CT = 1 ;
				IF vx = '0' and dx = "Z006" THEN CT = 1 ;
			END ;

			%null_canc ;

			IF HAS_CANCER = 1 AND CT = 1 THEN do ;
				if "&type." not in ("p1","p2") then do ;
					if LINE_ICD_DGNS_CD in ("V707","Z006") then do; 
						IF (EP_BEG LE EXPNSDT1 LE EP_END) THEN CLINICAL_TRIAL_MILL = 1 ;
					end;
					else do;
						IF (EP_BEG LE FROM_DT LE EP_END) OR
							(EP_BEG LE THRU_DT LE EP_END) THEN CLINICAL_TRIAL_MILL = 1 ;
					end;
				end ;
				else do ;
					if dme_flag = 0 then do ;
						/*IF LINE_ICD_DGNS_CD in ("V707","Z006") THEN CLINICAL_TRIAL_MILL = 1 ;
						ELSE */IF (EP_BEG LE FROM_DT LE EP_END) /*OR
								(EP_BEG LE THRU_DT LE EP_END) */THEN CLINICAL_TRIAL_MILL = 1 ;
					end ;
				end ;	
			END ;

		IF DME_FLAG = 0 THEN DO ;

			* Current Performance Period Mapping * ;
			if "&type." not in ("p1","p2") then do ;
				if put(hcpcs_cd,$RadTher_CPT.) = "Y" then RADTHER = 1 ;
				if put(hcpcs_cd,$Prostate_CPT.) = "Y" then PROSTATE_SURGERY = 1 ;
				if put(hcpcs_cd,$Pancreatic_CPT.) = "Y" then PANCREATIC_SURGERY = 1 ;
				if put(hcpcs_cd,$Ovarian_CPT.) = "Y" then OVARIAN_SURGERY = 1 ;
				if put(hcpcs_cd,$Kidney_CPT.) = "Y" then KIDNEY_SURGERY = 1 ;
				if put(hcpcs_cd,$HeadNeck_CPT.) = "Y" then HEADNECK_SURGERY = 1 ;
				if put(hcpcs_cd,$Intestinal_CPT.) = "Y" then INTESTINAL_SURGERY = 1 ;
				if put(hcpcs_Cd,$Gastro_CPT.) = "Y" then GASTRO_SURGERY = 1 ;
				if put(hcpcs_cd,$FemaleGU_CPT.) = "Y" then FEMALEGU_SURGERY = 1 ;
				if put(hcpcs_cd,$Breast_CPT.) = "Y" then BREAST_SURGERY = 1 ;
			end ;

				* Prior Performance Period Mappings * ;
				*** Performance Periods 1 + 2 *** ;
			else do;
				if put(hcpcs_cd,$RadTher_CPT2p.) = "Y" then RADTHER = 1 ;
				if put(hcpcs_cd,$Prostate_CPT2p.) = "Y" then PROSTATE_SURGERY = 1 ;
				if put(hcpcs_cd,$Pancreatic_CPT2p.) = "Y" then PANCREATIC_SURGERY = 1 ;
				if put(hcpcs_cd,$Ovarian_CPT2p.) = "Y" then OVARIAN_SURGERY = 1 ;
				if put(hcpcs_cd,$Liver_CPT2p.) = "Y" then LIVER_SURGERY = 1 ;
				if put(hcpcs_cd,$HeadNeck_CPT2p.) = "Y" then HEADNECK_SURGERY = 1 ;
				if put(hcpcs_Cd,$Gastro_CPT2p.) = "Y" then GASTRO_SURGERY = 1 ;
				if put(hcpcs_cd,$FemaleGU_CPT2p.) = "Y" then FEMALEGU_SURGERY = 1 ;
				if put(hcpcs_cd,$Breast_CPT2p.) = "Y" then BREAST_SURGERY = 1 ;
			end ;


				*** Added 7/26/18 - Update to include surgeries with a header level diagnosis
					code for the cancer indicated for the surgery. *** ;
				if prostate_surgery = 1 and prostate = 1 then dxPROSTATE_SURGERY = 1 ;
				if BREAST_SURGERY=1 and breast = 1 then dxBREAST_SURGERY = 1 ;
				if FEMALEGU_SURGERY and FEMALEGU=1 then dxFEMALEGU_SURGERY = 1 ;
				if GASTRO_SURGERY and GASTRO_ESOPHAGEAL=1 then dxGASTRO_SURGERY = 1 ;
				if HEADNECK_SURGERY=1  and HEADNECK=1 then dxHEADNECK_SURGERY = 1 ;
				if INTESTINAL_SURGERY and intestinal = 1 then dxINTESTINAL_SURGERY = 1 ;
				if KIDNEY_SURGERY=1 and KIDNEY=1 then dxKIDNEY_SURGERY = 1 ;
				if LIVER_SURGERY = 1 AND LIVER = 1 THEN dxLIVER_SURGERY = 1 ;
				if OVARIAN_SURGERY=1 and OVARIAN=1 then dxOVARIAN_SURGERY = 1 ;
				if PANCREATIC_SURGERY = 1 and PANCREATIC=1 then dxPANCREATIC_SURGERY = 1 ;


		END ;

	END ;
run;
	

data all ; set rec&ref..check_ipop_&type.&vers._&dsid. check_carr ;
proc sort data=all ; by  bene_id ep_id  ;
proc means data=all noprint max ; by  bene_id ep_id ;
	var BMT_ALLOGENEIC  BMT_AUTOLOGOUS RADTHER 
	    ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY
	    GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
	    OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY 
	    dxANAL_SURGERY dxBLADDER_SURGERY dxBREAST_SURGERY dxFEMALEGU_SURGERY
	    dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY dxLIVER_SURGERY dxLUNG_SURGERY
	    dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY 
		CLINICAL_TRIAL_MILL ;
	OUTPUT OUT=PREDICT_VARS (DROP = _TYPE_ _FREQ_)
		   MAX() = ;
			
********************************************************************** ;
********************************************************************** ;
****** Final Episode Files 	;
proc sort data=epi_orig ; by bene_id ep_id ;
data rec&ref..episodes_&type.&vers._&dsid. ;
	merge epi_orig(in=a) 
		  ca(in=b)
		  predict_vars(in=c) 
		  trigger_s ; by  bene_id ep_id  ;
	if a ;
	if cancer = "Intestinal Cancer" then cancer = "Small Intestine / Colorectal Cancer" ;
	if CANCER_TYPE ne "Breast Cancer" then partdonly = 2 ;
	if CANCER_TYPE ne "Breast Cancer" then BC_Hormonal_only = 2 ;
	if CANCER_TYPE ne "Bladder Cancer" then LOW_RISK_BLAD_MILLIMAN = 2 ;
	if CANCER_TYPE ne "Prostate Cancer" then CAST_SENS_PROS_MILLIMAN = 2 ;

proc sort data=rec&ref..episodes_&type.&vers._&dsid. ; by  bene_id EP_ID ;


********************************************************************** ;
		**** Create Episode Files for Interface. **** ;
********************************************************************** ;

proc sort data=tax ; by bene_id ep_id ;
data rec&ref..epi_prelim_&type.&vers._&dsid. ;
	merge rec&ref..episodes_&type.&vers._&dsid.  (in=a)
		  tax (keep = bene_id ep_id epi_tax_id) 
		  taxnpi (keep = bene_id ep_id epi_npi_id) ; 
	by bene_id ep_id ;
	if a ;

	%CANCer_remap(CANCER_TYPE) ;

	*** Renaming Milliman to match OCM ** ;
	if cancer = 'Malignant neoplasm of female genital organs NOS' then cancer = 'Malignant neoplasm of other and unspecified female genital organs' ;
	if cancer = 'Leukemia, NOS' then cancer = 'Leukemia, unspecified' ;
	if cancer = 'Malignant neoplasm of penis, other male organs NOS' then cancer = 'Malignant neoplasm of penis, other, and unspecific male organs' ;
	if cancer = 'Lymphoid Leukemia, NOS' then cancer = 'Lymphoid Leukemia, unspecified' ;
	*** New June 2017 *** ;
	if cancer = "Malignant neoplasm of skin, NOS" then cancer = "Other and unspecified malignant neoplasm of skin" ;
	if cancer = "Malignant neoplasm NOS" then cancer = "Malignant neoplasm without specification of site" ; 
	if cancer = "Malignant neoplasm of lymphoid, hematopoietic NOS" then
	   cancer = "Other and unspecified malignant neoplasms of lymphoid, hematopoietic and related tissue" ;
	if cancer = "Malignant neoplasm without specification of site" then cancer = "Malignant neoplasm NOS" ;
	*** added 10/20/17 *** ;
	if cancer = "Secondary malignant neoplasm NOS" then 
		cancer = "Secondary malignant neoplasm of other and unspecified sites" ;
	if cancer = "Intestinal Cancer" then cancer = "Small Intestine / Colorectal Cancer" ;
	*** added 2/27/19 *** ;
	if cancer = "Essential (hemorrhagic) thrombocythemia" then cancer = "Essential thrombocythemia" ;

	
	CANCER_TYPE_MILLIMAN = CANCER ; 
	IF CANCER NE CANCER_TYPE THEN CANCER_INVALID = 1 ; 
	ELSE CANCER_INVALID = 0 ;

	if RADIATION NE RADTHER THEN Rad_Invalid = 1 ; 
	else Rad_Invalid = 0 ;  
	RADIATION_MILLIMAN = RADTHER ; DROP RADTHER ;

	if CANCER_TYPE_MILLIMAN ne "Breast Cancer" AND dxBREAST_SURGERY = 0 then BREAST_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Anal Cancer" AND dxanal_SURGERY = 0 then ANAL_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Liver Cancer" AND dxLIVER_SURGERY = 0 then LIVER_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Lung Cancer" AND dxLUNG_SURGERY = 0 then LUNG_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Kidney Cancer" AND dxKIDNEY_SURGERY = 0 then KIDNEY_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Bladder Cancer" AND dxBLADDER_SURGERY = 0 then BLADDER_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Female GU Cancer other than Ovary" AND dxFEMALEGU_SURGERY = 0 then FEMALEGU_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Gastro/Esophageal Cancer" AND dxGASTRO_SURGERY = 0 then GASTRO_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Head and Neck Cancer" AND dxHEADNECK_SURGERY = 0 then HEADNECK_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Small Intestine / Colorectal Cancer" AND dxiNTESTINAL_SURGERY = 0 then INTESTINAL_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Ovarian Cancer" AND dxOVARIAN_SURGERY = 0 then OVARIAN_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Prostate Cancer" AND dxPROSTATE_SURGERY = 0 then PROSTATE_SURGERY = 0 ;
	if CANCER_TYPE_MILLIMAN ne "Pancreatic Cancer" AND dxPANCREATIC_SURGERY = 0 then PANCREATIC_SURGERY = 0 ;
	

	
	has_surgery = 0 ;
	has_surgery = max(0,BREAST_SURGERY, ANAL_SURGERY, LIVER_SURGERY, LUNG_SURGERY, FEMALEGU_SURGERY,
					  GASTRO_SURGERY, HEADNECK_SURGERY, INTESTINAL_SURGERY, OVARIAN_SURGERY, 
					  PROSTATE_SURGERY, PANCREATIC_SURGERY, KIDNEY_SURGERY, BLADDER_SURGERY) ;

	SURGERY_MILLIMAN = HAS_SURGERY ; drop has_surgery ;
	IF SURGERY_MILLIMAN NE SURGERY THEN SURG_INVALID = 1 ;
	ELSE SURG_INVALID = 0 ;

	BMT_MILLIMAN = 0 ;
	ctype = cancer_type_milliman ;

	ARRAY BMT1 (B) BMT_ALLOGENEIC_AK BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL 
				   BMT_AUTOLOGOUS_AK BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL ;
	DO B = 1 TO DIM(BMT1) ;
		BMT1 = 0 ;
	END ;

	if CANCER_TYPE_MILLIMAN = "Acute Leukemia" then do ;
		BMT_ALLOGENEIC_AK  = BMT_ALLOGENEIC ; BMT_AUTOLOGOUS_AK = BMT_AUTOLOGOUS;
	end ;
	if CANCER_TYPE_MILLIMAN = "Lymphoma" then do ;
		BMT_ALLOGENEIC_L  = BMT_ALLOGENEIC ; BMT_AUTOLOGOUS_L = BMT_AUTOLOGOUS;
	end ;
	if CANCER_TYPE_MILLIMAN = "Multiple Myeloma" then do ;
		BMT_ALLOGENEIC_MM  = BMT_ALLOGENEIC ; BMT_AUTOLOGOUS_MM = BMT_AUTOLOGOUS;
	end ;
	if CANCER_TYPE_MILLIMAN = "MDS" then do ;
		BMT_ALLOGENEIC_MDS  = BMT_ALLOGENEIC ; BMT_AUTOLOGOUS_MDS = BMT_AUTOLOGOUS;
	end ;
	if "&type." not in ("p1","p2") then do ;
		IF CANCER_TYPE_MILLIMAN = "Chronic Leukemia" THEN DO ;
			BMT_ALLOGENEIC_CL  = BMT_ALLOGENEIC ; BMT_AUTOLOGOUS_CL = BMT_AUTOLOGOUS;
		end ;
	end;

	if "&type." not in ("p1","p2") then do ;
		if ctype notin ("Acute Leukemia","Lymphoma","MDS","Multiple Myeloma","Chronic Leukemia") then BMT_Milliman = 4 ;
	end;
	else do;
		if ctype notin ("Acute Leukemia","Lymphoma","MDS","Multiple Myeloma") then BMT_Milliman = 4 ;
	end;

	array al (b) BMT_ALLOGENEIC_L BMT_ALLOGENEIC_AK BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL ;
	array au (b) BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_AK BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL ;
	array bm (b) BM_L BM_AK BM_MM BM_MDS BM_CL ;
	do b = 1 to DIM(AL);
		if al = 1 and au = 1 then BM = 3 ;
		else if al = 1 then BM = 2 ;
		else if au = 1 then BM = 1 ;
		else BM = 0 ;
	end ;
	
	if ctype = "Acute Leukemia" then BMT_MILLIMAN = BM_AK ;
	if ctype = "Lymphoma" then BMT_MILLIMAN = BM_L ;
	if ctype = "MDS" then BMT_MILLIMAN = BM_MDS ;
	if ctype = "Multiple Myeloma" then BMT_MILLIMAN = BM_MM ;
	if "&type." not in ("p1","p2") and ctype = "Chronic Leukemia" then BMT_MILLIMAN = BM_CL ;
	IF BMT+0 NE BMT_MILLIMAN+0 THEN BMT_INVALID  = 1 ;
	ELSE BMT_INVALID = 0 ;
	

	CLINICAL_TRIAL_MILLIMAN = CLINICAL_TRIAL_MILL ; DROP CLINICAL_TRIAL_MILL ;
	if CLINICAL_TRIAL NE CLINICAL_TRIAL_MILL THEN CT_Invalid = 1 ;
	ELSE CT_Invalid  = 0 ;   


	if "&type." not in ("p1","p2") then PTD_CHEMO_MILLIMAN = BC_Hormonal_only;
	else PTD_CHEMO_MILLIMAN = PARTDONLY ; DROP PARTDONLY BC_Hormonal_only ;

	if PTD_CHEMO ne PTD_CHEMO_MILLIMAN then chemod_invalid = 1 ; 
	else chemod_invalid = 0 ; **** Accuracy of Part D Chemo flag.  **** ;

	if "&type." not in ("p1","p2") AND LOW_RISK_BLAD ne LOW_RISK_BLAD_MILLIMAN then blad_lr_invalid = 1 ; 
	else blad_lr_invalid = 0 ; **** Accuracy of low risk bladder flag.  **** ;

	if "&type." not in ("p1","p2") AND CAST_SENS_PROS ne CAST_SENS_PROS_MILLIMAN then prost_cast_invalid = 1 ; 
	else prost_cast_invalid = 0 ; **** Accuracy of low risk bladder flag.  **** ;

	EPI_ATT_TIN = EPI_TAX_ID ;
		%IF "&ocm." = "290" %THEN %do ;
			IF EPI_TAX_ID notin (&att_tin.) THEN EPI_ATT_TIN = '540647482' ;
		 %END ;
		 %ELSE %DO ;
			IF EPI_TAX_ID notin (&att_tin.) THEN EPI_ATT_TIN = &att_tin. ;
		 %END ;
	IF EPI_TAX_ID notin (&att_tin.) THEN ATT_TIN_INVALID = 1 ;
	ELSE ATT_TIN_INVALID = 0 ;

run ;

DATA FAILED(KEEP = EP_ID CANCER_INVALID RAD_INVALID SURG_INVALID BMT_INVALID 
				   CT_INVALID CHEMOD_INVALID BLAD_LR_INVALID PROST_CAST_INVALID
					ATT_TIN_INVALID %if &vers. ne R0 %then %do; Prior_Changed_Episode %end;) ;
	SET rec&ref..epi_prelim_&type.&vers._&dsid. ;
	IF MAX(CANCER_INVALID, RAD_INVALID, SURG_INVALID, BMT_INVALID, CT_INVALID, 
		   CHEMOD_INVALID, BLAD_LR_INVALID, PROST_CAST_INVALID, ATT_TIN_INVALID) = 1 ;
RUN ;

*************RECON CHECK 2: How many episodes mismatch on predvariablesiction model ? ***************************** ;
proc export data=FAILED %if &vers. ne R0 %then %do; (where = (Prior_Changed_Episode ne "Yes")) %end; 
	outfile = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP&ref.\Recon Reports\recon_check2_&VERS._&dsid."
	dbms=xls replace ;
quit ;
%mend epi ;
********************************************************************** ;
********************************************************************** ;
***** %macro epi(dsid,ocm) ;
*****  OCM = 3 digit OCM id
********************************************************************** ;
********************************************************************** ;

%let att_tin = '454999975' ; run ;
%epi(255_50179,255) ; run ;

%let att_tin = '636000526' ;run ;
%epi(257_50195,257) ; run ;

%let att_tin = '134290167' ;run ;
%epi(278_50193,278) ; run ;

%let att_tin = '731310891' ;run ;
%epi(280_50115,280) ; run ; 

*** pp2 *** ;
*%let att_tin = '540647482','540793767','541744931','311716973' ;run ; 
*** pp1 *** ; 
%let att_tin = '540647482','311716973' ;run ;
%epi(290_50202,290) ; run ;

%let att_tin = '571004971' ;run ;
%epi(396_50258,396) ; run ;

%let att_tin = '205485346' ;run ;
%epi(401_50228,401) ; run ; 

%let att_tin = '204881619' ;run ;
%epi(459_50243,459) ; run ; 

%let att_tin = '621490616' ;run ;
%epi(468_50227,468) ; run ; 
	
%let att_tin = '201872200' ;run ;
%epi(480_50185,480) ; run ;

%let att_tin = '596014973' ;run ;
%epi(523_50330,523) ; run ;

%let att_tin = '223141761' ;run ;
%epi(137_50136,137) ; run ; 


**** PP1 ONLY **** ;
%let att_tin = '540793767' ; run ;
%epi(567_50200,567) ; run ;

%let att_tin '541744931' ; run ;
%epi(568_50201,568) ; run ;



************************************************************************ ;
		************* Investigations **************** ;
************************************************************************ ;
/*
************************************************************************ ;
**** Cancer Mismatches **** ;

proc print data=REC2.EPI_PRELIM_P2R0_137_50136 ;
	where cancer_invalid = 1 ;
	var ep_id ep_beg ep_end cancer_type cancer_type_milliman ;
run ;

proc print data=em ;
	where ep_id = 977279531930 ;
run ;
proc print data=canc;
	where ep_id = 977279531930 ;
run ;
proc print data = vc1 ;
	where ep_id = 977279531930 ;
run ;
proc print data = cancer ;
	where ep_id = 76549 ;
run ;
proc print data=uniq_cancer ;
	where ep_id = 76549 ;
run ;


************************************************************************ ;
**** Radiation Mismatches **** ;

proc freq data=rec&ref..epi_prelim_&type.&vers._137_50136 ;
	tables radiation*radiation_milliman/list missing ;
	where rad_invalid = 1 ;
run ;

proc print data=rec&ref..epi_prelim_&type.&vers._523_50330  ;
	where rad_invalid = 1   ;
	var ep_id ep_beg ep_end cancer_type radiation radiation_milliman rad_invalid ;
run ;
**** from IPOP file **** ;
proc print data=rec&ref..check_ipop_&type.&vers._523_50330  ;
	where ep_id = 7685 and radther = 1 ;
run ;

proc print data=ipop ;
	where ep_id = 7685 and clm_id  = "4795791493" ; 
run ;

proc print data=IN5.phyline_480_50185 ;
	where ep_id = 450448 ; run ;


************************************************************************ ;
**** Clinical Trial Mismatches **** ;
proc freq data=rec&ref..epi_prelim_&type.&vers._523_50330 ;
	tables clinical_trial*clinical_trial_milliman/list missing ;
	where ct_invalid = 1 ;
run ;

proc print data=rec&ref..epi_prelim_&type.&vers._523_50330  ; 
	where ct_invalid = 1   ;
	var ep_id ep_beg ep_end cancer_type clinical_trial clinical_trial_milliman ct_invalid ;
run ;
	
proc print data=ipop ;
	where ep_id = 375570 ;
	var ep_id clm_id admsn_dt from_dt thru_dt ICD: nopay_cd ; run ;

************************************************************************ ;
**** BMT  Mismatches **** ;
proc freq data= REC2.EPI_PRELIM_P2R0_137_50136;
	tables bmt*bmt_milliman/list missing ;
	where bmt_invalid = 1 ;
run ;

proc print data=REC2.EPI_PRELIM_P2R0_137_50136  ; 
	where bmt_invalid = 1   ;
	*where cancer_type = "Chronic Leukemia" ; 
	var ep_id ep_beg ep_end cancer_type CANCER_TYPE_MILLIMAN bmt bmt_milliman bmt_invalid ;
run ;

PROC PRINT DATA= PREDICT_VARS ;
	WHERE EP_ID = 279722 ;
RUN ;

PROC PRINT DATA=rec&ref..epi_prelim_&type.&vers._137_50136  ;
	where ep_id = 294779 ; 
	var ep_id ep_beg ep_end cancer_type cancer_type_milliman ctype bmt bmt_milliman
		BMT_ALLOGENEIC_L BMT_ALLOGENEIC_AK BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS 
		BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_AK BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS
		BM_L BM_AK BM_MM BM_MDS ;
run ;

proc print data=check_carr  ;
	where ep_id = 294779  and BMT_ALLOGENEIC_L = 1 ;
run ;

************************************************************************ ;
	**** Chemo Part D Mismatches **** ;
proc freq data=REC2.EPI_PRELIM_P2R0_137_50136;
	tables PTD_CHEMO*PTD_CHEMO_milliman/list missing ;
	where chemod_invalid = 1 ;
run ;

proc print data=REC2.EPI_PRELIM_P2R0_137_50136; 
	where chemod_invalid = 1   ;
	var ep_id ep_beg ep_end cancer_type ptd_chemo ptd_chemo_milliman chemod_invalid ;
run ;

proc print data=chemo_candidates1 ;
	where ep_id = 597834114857 ; 
run ;
proc print data=LINES ;
	where chemo = 1 and ep_id = 597834114857 ; 
run ;
proc print data=chemo_claims ;
	*where chemo = 1 ;
	where ep_id = 49944 ; 
run ;
proc print data=triggers_a2;
	where ep_id = 597834114857 ; 
run ;


proc print data=triggers_a ;
	WHERE EP_ID = 597834114857 ;
run ;

proc print data=triggers  ;
	WHERE EP_ID = 597834114857 ;
RUN ;
proc print data=trigger_s  ;
	WHERE EP_ID = 597834114857 ;
RUN ;


proc print data=CHEMO_CANDIDATES3 ;
	WHERE EP_ID = 481442 ;
RUN ;


************************************************************************ ;
	**** Surgery Mismatches **** ;
proc print data=rec&ref..epi_prelim_&type.&vers._137_50136  ; 
	where surg_invalid = 1   ;
	var ep_id ep_beg ep_end cancer_type surgery surgery_milliman surg_invalid ;
run ;

proc print data=predict_vars ;
	where ep_id = 454475 ;
run ;

proc print data=rec&ref..episodes_&type.&vers._137_50136 ;
	where ep_id = 54355 ;
run ;

proc print data=carr2 ;
	where ep_id = 76549 ;
run ;

proc print data=ipop2 ;
	where ep_id = 76549 ;
run ;

************************************************************************ ;
***** Attributed TIN Mismatches **** ;
proc print data=rec&ref..epi_prelim_&type.&vers._137_50136  ; 
	where ATT_TIN_invalid = 1   ;
	var ep_id ep_beg ep_end cancer_type EPI_ATT_TIN EPI_TAX_ID ATT_TIN_invalid ;
run ;
proc print data=em ;
	where ep_id = 401552   ; run ;

proc print data=mt2;
	where ep_id = 401552   ; run ;
************************************************************************ ;
***** Trigger Mismatches **** ;
PROC PRINT DATA=CHEMO_CANDIDATES3 ;
	WHERE EP_ID = 481442 ;
RUN ;

proc sort data=REC&ref..EPIATT_255_50179_PP&ref. out=chk ; by bene_id ep_id ;
data dupl ;
	set chk ; by bene_id ep_id ;
	if first.ep_id=0 or last.ep_id=0 ; 
run ;

proc print data=triggers ;
	where ep_id = 750616175845; run ;

proc print data=in2.epi_255_50179 ;
	where ep_id = 750616175845; run ;

