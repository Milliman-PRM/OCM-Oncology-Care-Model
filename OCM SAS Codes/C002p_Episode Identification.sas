********************************************************************** ;
		***** C002p_Episode Identification.sas ***** ;
********************************************************************** ;
**** Based on Appendix A-C in OCM PBP Methodology.PDF **************** ;
********************************************************************** ;
*** Note: As of 5/9/18 - Removing match including bene_hicn - since bene_hicns are changing over time. *** ;

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

libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Performance" ;


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
RUN ;
********************************************************************** ;
%let type=p5 ; *** performance period designation *** ; RUN ;
%let vers=A ; *** indicates A (without epi file) or B (with epi file) processing *** ; RUN ;
%let sd = mdy(7,1,2016) ; *** Performance period start date. ;
%let fbq01 = mdy(7,1,2016) ; 
%let fbq02 = mdy(10,1,2016) ; 
%let fbq03 = mdy(1,1,2017) ; 
%let fbq04 = mdy(4,1,2017) ; 
%let fbq05 = mdy(7,1,2017) ; 
%let fbq06 = mdy(10,1,2017) ; 
%let fbq07 = mdy(1,1,2018) ; 
%let fbq08 = mdy(4,1,2018) ;
%let fbq09 = mdy(7,1,2018) ;
%let fbq10 = mdy(10,1,2018) ;
********************************************************************** ;
	*** Attribution File Name Macro Variables *** ;
********************************************************************** ;

%let in_att = out.RECON_OVERLAP_PP1_&DSID. out.RECON_OVERLAP_PP2_&DSID. out.RECON_OVERLAP_PP3_&DSID. ;

%let trueup = 0 ; *** 1 when need to compare true-up file to prior version, else 0 (as in recon processing) *** ;
%let in_drop = OUT.EPI_DROPPED_&VERS._&DSID. ; *** only used in trueup processing *** ;
RUN ;



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

%macro cancer_remap(canc) ;	
	*** Some CMS Cancer Types set to ICD10 *** ;
	if &CANC. = 'C26' then &CANC. = 'Malignant neoplasm of other and ill-defined digestive organs' ;
	if &CANC. = 'C37' then &CANC. = "Malignant neoplasm of thymus" ;
	if &CANC. = 'C38' then &CANC. = "Malignant neoplasm of heart, mediastinum and pleura" ;
	if &CANC. = 'C40' then &CANC. = "Malignant neoplasm of bone and articular cartilage of limbs" ;
	if &CANC. = 'C41' then &CANC. = "Malignant neoplasm of bone and articular cartilage of sites NOS" ;
	if &CANC. = 'C44' then &CANC. = "Other and unspecified malignant neoplasm of skin" ;
	if &CANC. = 'C46' then &CANC. = "Kaposi's Sarcoma" ;
	if &CANC. = 'C47' then &CANC. = "Malignant neoplasm of peripheral nerves, autonomic nervous system" ;
	if &CANC. = 'C48' then &CANC. = "Malignant neoplasm of retroperitoneum and peritoneum" ;
	if &CANC. = 'C49' then &CANC. = "Malignant neoplasm of peripheral nerves, autonomic nervous system" ;
	if &CANC. = 'C47 or C49' then &CANC. = "Malignant neoplasm of peripheral nerves, autonomic nervous system" ;
	if &CANC. = 'C4A' then &CANC. = "Merkel cell carcinoma" ;
	if &CANC. = 'C57' then &CANC. = "Malignant neoplasm of other and unspecified female genital organs" ;
	if &CANC. = 'C60 or C63' then &CANC. = "Malignant neoplasm of penis, other, and unspecific male organs" ;
	if &CANC. = 'C62' then &CANC. = "Malignant neoplasm of testis" ;
	if &CANC. = 'C76.1' then &CANC. = "Malignant neoplasm of thorax" ; 
	if &CANC. = 'C76.2' then &CANC. = "Malignant neoplasm of abdomen" ; 
	if &CANC. = 'C76.3' then &CANC. = "Malignant neoplasm of pelvis" ;
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



*** macro var chk accounts for newest quarter data not being provided *** ;
%macro epi(dsid,nmd,ocm) ;

********************************************************************** ;
********************************************************************** ;
**** Step 1: Identify all possible claims that could trigger an episode ending in the performance period ;
**** 1.A. Carrier (PHYLINE_&dsid.), DMEPOS (DMELINE_&dsid.)  **** ;

data lines chemo EM(DROP=EP_ID) lines_partd ;
	set OUT.phyline_WRECON_&dsid.(in=a) OUT.dmeline_WRECON_&dsid. ;
	if a then carr = 1 ;

	%canc_init ;

	%CANCERTYPE(LINE_ICD_DGNS_VRSN_CD, LINE_ICD_DGNS_CD) ;

	%canc_time ;

	************************************************************************************************* ;

	output lines_partd ;
	IF EXPNSDT1 GE &SD.  then do ;
	** E&M claims with cancer diagnosis for episode qualification in subsequent steps ** ;
		/*if EXPNSDT1 GE mdy(7,2,2017) then do;
			if ONC_TIN='Y' and carr=1  and HCPCS_CD in ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215')
				and LALOWCHG > 0 and has_cancer = 1 then output EM ;
		end;
		else do;*/
			if carr=1  and HCPCS_CD in ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215')
				and LALOWCHG > 0 and has_cancer = 1 then output EM ;
		/*end;*/


		**The claim must contain a line item HCPCS code indicating an included chemotherapy drug 
		  (initiating cancer therapy) in any line item. ** ;
		if (expnsdt1 le mdy(1,1,2017) and put(HCPCS_CD,$Chemo_J.) = "Y") or
		   (mdy(1,2,2017) le expnsdt1 le mdy(7,1,2017) and put(HCPCS_CD,$Chemo_J2p.) = "Y") OR
		   (mdy(7,2,2017) le expnsdt1 le mdy(1,1,2018) and put(HCPCS_CD,$Chemo_J3p.) = "Y") or
		   (mdy(1,2,2018) le expnsdt1 le mdy(7,1,2018) and put(HCPCS_CD,$Chemo_J4p.) = "Y") or
		   (mdy(7,2,2018) le expnsdt1 and put(HCPCS_CD,$Chemo_J5p.) = "Y")	then do ;

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

	end ;

	** The chemotherapy drug claim must contain an included cancer diagnosis code available on the CMS OCM website) 
   		in any non-denied line item on the same claim (does not have to be same line as HCPCS code above -
   		do not use the header diagnoses).  ** ;

proc sort data=OUT.phyhdr_WRECON_&dsid. 
			  out=ph(KEEP = bene_Id clm_id thru_dt PRNCPAL_DGNS_CD PRNCPAL_DGNS_VRSN_CD ICD_DGNS:)
			  nodupkey ; by  bene_Id clm_id thru_dt ;
proc sort data=out.dmehdr_wrecon_&dsid. 
			  out=dh (KEEP = bene_Id clm_id thru_dt PRNCPAL_DGNS_CD PRNCPAL_DGNS_VRSN_CD ICD_DGNS:)
			  nodupkey ; by  bene_Id clm_id thru_dt ;

proc sort data=lines ; by  bene_Id clm_id thru_dt ;
proc sort data=chemo out=chemo2(keep =  bene_Id clm_id thru_dt) nodupkey ; by  bene_Id clm_id thru_dt ;

data chemo_claims chemoz ;
	merge lines(in=a) chemo2(in=b) PH DH ; by  bene_id clm_id thru_dt ;
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


proc sort data=chemo_claims ; by  bene_id clm_id thru_dt carr ;
proc means data=chemo_claims noprint min max ; by  bene_id clm_id thru_dt carr;
	var has_cancer HAS_CANCER_LINE UROTHELIAL trigger_date perf_chemo EPALL EP201701 EP201707 EPALL_LINE ZFLAG EP201701_LINE EP201707_LINE;
	output out=chemo_flag(drop = _freq_ _type_)
		   max(has_cancer HAS_CANCER_LINE UROTHELIAL EPALL EP201701 EP201707 EPALL_LINE ZFLAG EP201701_LINE EP201707_LINE) = 
		   min(trigger_date perf_chemo) = ;	

data chemo_candidates1 ;
	set chemo_flag(in=a) chemoz(in=b) ;
	if (a and has_cancer_LINE = 1) OR (b AND HAS_CANCER = 1) ;
	if a then do ;
		if trigger_date < mdy(1,2,2017) and EPALL_line ne 1 then delete ;
		if trigger_date < mdy(7,2,2017) and max(EPALL_line,EP201701_line) ne 1 then delete ;
	end ;
	else do ;
		if trigger_date < mdy(1,2,2017) and EPALL ne 1 then delete ;
		if trigger_date < mdy(7,2,2017) and max(EPALL,EP201701) ne 1 then delete ;
	end ;

run ;

proc sort data=chemo_candidates1 nodupkey ; by bene_id clm_id thru_dt carr trigger_date;
proc sort data = chemo_claims ; by bene_id clm_id thru_dt carr trigger_date;
data chemo_days1(keep= bene_id trigger_date) ;
	merge chemo_claims(in=a) chemo_candidates1(in=b) ;  by  bene_id clm_id thru_dt carr trigger_date ;
	if a and b ;

**** 1.B. Outpatient (outrev_&dsid., outhdr_&dsid.)  **** ;

	**** Combining files *****;
proc sort data=out.outhdr_wrecon_&dsid. OUT=h ; by  BENE_ID CLM_ID THRU_DT ;
proc sort data=out.outrev_wrecon_&dsid. OUT=r ; by  BENE_ID CLM_ID THRU_DT ;


data out.outpatient_&type.&vers._&dsid. op_partd;
		merge h(in=a) r(in=b) ; 
		by  BENE_ID CLM_ID THRU_DT ; 
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
			IF REV_DT GE &SD. then output out.outpatient_&type.&vers._&dsid.;
			output op_partd ;


data chemo_candidates2(keep =  bene_id clm_id thru_dt rev_dt trigger_date has_cancer perf_chemo UROTHELIAL)  
	 all_op_chemo;
	set	out.outpatient_&type.&vers._&dsid. ;

	**The claim must contain a HCPCS code indicating an included chemotherapy drug (initiating cancer therapy) 
	  in any revenue center. ** ;
	if (rev_dt le mdy(1,1,2017) and put(HCPCS_CD,$Chemo_J.) =  "Y"  ) or
	   (mdy(1,2,2017) le rev_dt le mdy(7,1,2017) and put(HCPCS_CD,$Chemo_J2p.) =  "Y"  ) or
	   (mdy(7,2,2017) le rev_dt le mdy(1,1,2018) and put(HCPCS_CD,$Chemo_J3p.) =  "Y"  )or
	   (mdy(1,2,2018) le rev_dt le mdy(7,1,2018) and put(HCPCS_CD,$Chemo_J4p.) =  "Y"  )or
	   (mdy(7,2,2018) le rev_dt and put(HCPCS_CD,$Chemo_J5p.) =  "Y"  )
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
		output all_op_chemo ;
			format trigger_date perf_chemo mmddyy10. ;
			trigger_date = rev_dt ;
			if trigger_date ge &sd. then perf_chemo = trigger_date ;
			IF (TRIGGER_DATE < MDY(1,2,2017) AND EPALL = 1) or 
			   (TRIGGER_DATE < MDY(7,2,2017) AND MAX(EPALL,EP201701) = 1 ) OR	
			   (trigger_date ge mdy(7,2,2017) and has_cancer = 1) then output chemo_candidates2 ;
	end ;
	
	end ;

	end ;

proc sort data=out.outpatient_&type.&vers._&dsid. out=op ; by bene_id clm_id thru_dt ;
proc sort data=chemo_candidates2 out=chemo2a nodupkey ; by bene_id clm_id thru_dt ;

data chemo_days2(keep= bene_id rev_dt) ;
	merge op(in=a) chemo2a(in=b) ;by bene_id clm_id thru_dt ;
	if a and b ;

**** Part B Chemo claims ***** ;
data chemo_days ;
	set chemo_days1 chemo_days2(rename = (rev_dt=trigger_date)) ;
	if trigger_date ne . ;
proc sort data=chemo_days ; by  bene_id trigger_date ;
data chemo_days ; set chemo_days ; by  bene_id trigger_date ; if first.trigger_date then counter = 1 ;
	*** For performance period, capture first chemo date within period when available.  Default to earliest 
		available when no chemo is present in current period. *** ;
	format perf_chemo mmddyy10. ;
	if trigger_date ge &sd. then do ;
		perf_chemo = trigger_date ;
		perf_count = counter ;
	end ;


**** 1.C. Part D (PDE_&dsid.)  **** ;

data chemo_candidates3_cand(keep =  bene_id pde_id trigger_date perf_chemo) ;
		set out.PDE_wrecon_&dsid.  ;
		IF SRVC_DT GE &SD. ;

	** The claim must contain an included chemotherapy drug (initiating cancer therapy) NDC code. ** ;
	ndc10 = substr(prod_srvc_id,1,10) ;
	ndc9 = substr(prod_srvc_id,1,9) ;
	ndc8 = substr(prod_srvc_id,1,8) ;

	if  (srvc_dt le mdy(1,1,2017) and (put(NDC9, $Chemo_NDC.) = "Y" or NDC8 = '00780645') ) or 
		(mdy(1,2,2017) le srvc_dt le mdy(7,1,2017) and put(NDC9, $Chemo_NDC2p.) = "Y" ) or
		(mdy(7,2,2017) le srvc_dt le mdy(1,1,2018) and put(NDC9, $Chemo_NDC3p.) = "Y")or
		(mdy(1,2,2018) le srvc_dt le mdy(7,1,2018) and put(NDC9, $Chemo_NDC4p.) = "Y")or
		(mdy(7,2,2018) le srvc_dt and put(NDC9, $Chemo_NDC5p.) = "Y")
		 then do ;
		** The claim “fill date” must be in the appropriate 6 month “Episode Beginning” period in 
		   Table 1, inclusive of end dates. ** ;
			chemo = 1 ;
			format trigger_date perf_chemo mmddyy10. ;
			trigger_date = SRVC_DT ;
			if trigger_date ge &sd. then perf_chemo = trigger_date ;
			output chemo_candidates3_cand ;
	end ;



** A non-denied Carrier (line allowed charge >0) or Outpatient (Medicare non-payment reason code is not blank) 
   claim with an included cancer diagnosis code in any line item (Carrier) or in the header (Outpatient) 
   can be found on the fill date or in the 59 days preceding the fill date. Use line first expense date on the 
   Carrier claims and from date on the Outpatient claims to determine if the claim occurred on the fill date or 
   in the 59 days prior. ** ;
data carrier(keep =  bene_id cdate EPALL EP201701 EP201707) ;
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

proc sort data=chemo_candidates3 nodupkey ; by bene_id pde_id trigger_date perf_chemo ;
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
	if a and carr = 1 then source = 2 ; *** carrier is second in hierarchy *** ;
	if b then source = 1 ; *** outpatient is first in hierarchy *** ;
	if a and carr ne 1 then source = 3 ; *** DME is third in hierarchy *** ;
	if c then source = 4 ; *** Part D is fourth in hierarchy **** ;
proc sort data=triggers ; by bene_id perf_chemo ;
proc means data=triggers noprint min ; by bene_id ;
	var perf_chemo ;
	output out=in_period (drop = _type_ _freq_)
		   min(perf_chemo) = first_chem_in_per ;
data triggers_a ;
	merge triggers(in=a) in_period(in=b) out.BENE_CW_&DSID.; by bene_id ;
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

** The 6 month period beginning with the trigger date must contain a non-denied Carrier claim with an 
   E&M visit (HCPCS code 99201 – 99205, 99211 – 99215) AND an included cancer diagnosis code on the same line item. ** ;
proc sql ;
	create table triggers_a2	 as
	select a.bene_id, a.trigger_date, a.source, a.clm_id, a.episode_end, 
		a.CHEMO_IN_PP, a.first_chem_in_per, B.EP201701, B.EPALL, b.ep201707, b.urothelial
	from triggers_a as a, em as b
	where a.bene_id=b.bene_id and 
		  trigger_date le b.expnsdt1 le episode_end ;

data triggers_a3 ;
	set triggers_a2 ;
	if trigger_date lt mdy(1,1,2017) then do ;
		IF EPALL NE 1 THEN DELETE ; *** REMOVING E&M CLAIMS REPORTING CANCERS THAT ONLY APPLY TO EPISODES BEGINNING AFTER 1/1/2017. *** ;
	end ;
	IF trigger_date lt mdy(7,1,2017) then do ;
		IF MAX(EPALL, EP201701) NE 1 THEN DELETE ;
	END ;

proc sort data=triggers_a3 nodupkey ; by  bene_id trigger_date source clm_id  ;

** A trigger claim initiates an episode only when all of the below criteria are met.;

***********
Apply the following hierarchy if there is more than one trigger claim on the same day from different 
types of service: Outpatient, Carrier, DMEPOS, Part D
If there is still more than one trigger claim on the same day within the same type of service, 
choose the claim with the first claim ID. ********* ;

data triggersa ;
	set triggers_a3 ; by  bene_id  trigger_date ;
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
	set triggersa ; by  bene_id  trigger_date source clm_id ;
	if first.clm_id ;

************************************************************************************** ;
** PASS 1: Identify Episodes using Milliman process and performance quarterly feeds ** ;
************************************************************************************** ;

***********
** For all performance periods, the potential episode trigger date must not be included 
   in any episode defined for a prior performance period.  6 Potential trigger claims occurring 
   inside a previously defined episode cannot trigger a new episode. ** ;
data triggers2 all_triggers  ;
	set triggersb ; by  bene_id  ;
	format pend mmddyy10. ; 
	if first.bene_id  then do ;
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

data triggers2 ;
	set triggers2 ; by bene_id ;
	if first.bene_id then epi_seq = 1 ;
	else epi_seq = 2 ;
	if _n_ = 1 then ecount = 0 ;
	ecount = sum(ecount,1) ;
	retain ecount epi_seq;


proc sort data=triggers2 nodupkey ; by  bene_id trigger_date ;

run ;


****************************************************************************** ;
********* Check against Attribution/Reconciliation Data ********************** ;
********* 		IN_ATT is created in 001.5 program 		********************** ;
****************************************************************************** ;
*** Ignoring any attribution episode for which we do not yet have a BENE_ID anywhere in our data provided *** ;
*** Also pulling out DROPPED episodes as they will not be used in override process. *** ;
DATA ATT2   ;
	set &in_att. (where = (miss_beneid ne 1)  );
	format trigger_date mmddyy10. ;
	trigger_date = ep_beg_a ;

proc sort data=att2 ; by bene_id trigger_date ;

data att2 ;
	set att2 ; by bene_id trigger_date ;
	if first.bene_id then epi_seq = 1 ;
	else epi_seq = sum(epi_seq,1) ;
	retain epi_seq ;

proc means data=att2 noprint min max ; by bene_id ;
	var ep_beg_a ep_end_a ;
	output out=att_epi_span(drop = _type_ _freq_)
		   min(ep_beg_a) = earliest_epi
		   max(ep_end_a) = latest_epi ;


**** Captures all triggers for beneficiaries not reporting any attributed episodes.	     **** ;	
**** Removes triggers that are incurred prior to earliest attributed episode start date. **** ;
**** Separates triggers into those incurred during episode attributed period and those incurred 
	 after episode attributed period. 													 **** ;
proc sort data=all_triggers ; by bene_id ;
data triggers2_nobene ;
	merge triggers2(in=a) att_epi_span(in=b) ; by bene_id ;
	if a and b=0 ;

proc sql ;
	*** Purposefully using triggers2 as we want to see if we would have attributed the same trigger date. *** ;
	create table triggers2_before as
		select a.* 
		from triggers2 as a, att_epi_span as b
		where a.bene_id = b.bene_id and
			  a.trigger_date lt b.earliest_epi ;
	*** Purposefully using triggers2 as we want to see if we would have attributed the same trigger date. *** ;
	create table triggers2_during as
		select a.* 
		from triggers2 as a, att_epi_span as b
		where a.bene_id = b.bene_id and
			  b.earliest_epi le trigger_date le b.latest_epi ;
	*** Purposefully using all_triggers as we want all available trigger candidates available once attribution occurs. *** ;
	create table triggers2_after as
		select a.*
		from all_triggers as a, att_epi_span as b
		where a.bene_id=b.bene_id and
		      a.trigger_date gt b.latest_epi ;
quit ;

******** Check for match with attribution file ****** ;


DATA TRIGGER_CHK1_ATT chk1_noatt(drop=ep_beg_a ) chk1_noepi(keep = bene_id   ep_beg_a);
	MERGE triggers2_during(in=a) att2(in=b keep = bene_id  trigger_date ep_beg_a) ; 
	by bene_id  trigger_date ;
	if a and b then do ;
		attribute_flag = "1" ; *** indicates in attribution and matches episode start date *** ;
		output TRIGGER_CHK1_ATT ;
	end ;
	else if a and b=0 then output chk1_noatt ;
	else if a=0 and b then output chk1_noepi ;


proc sql ;
	create table trig01 as
	select a.*, b.ep_end_a, b.ep_beg_a
	from chk1_noatt as a, att2 as b
	where a.bene_id = b.bene_id and
		  b.ep_beg_a le a.trigger_date le b.ep_end_a ;
quit ;

proc sort data=trig01 out=trig02 nodupkey ; by bene_id ep_beg_a ep_end_a ;

data triggers_reatt ;
	set trig02 ; by bene_id ep_beg_a ep_end_a ;
	trigger_date = ep_beg_a ;
		trigger_date = ep_beg_a ;
		episode_end = intnx('month', trigger_date, 6,'same')-1 ;
		attribute_flag = "2" ;  *** indicates mismatch on episode start date *** ;
		source = 0 ;

*** Check for chk1_noepi episodes would have had a mismatched trigger in time period before episode. *** ;
	** 1. Identify first episodes for each beneficiary. ** ;
	proc sql ;
		create table first_epi as
		select a. *
		from chk1_noepi as a, att_epi_span as b
		where a.bene_id=b.bene_id and
			  a.ep_beg_a = b.earliest_epi ;

	** 2. Capture the most recent trigger for a beneficiary in the trigger_before file ** ;
	proc sort data=triggers2_before ; by bene_id trigger_date ;
		data b4 ;
			set triggers2_before ; by bene_id trigger_date ;
			if last.bene_id ;

	** 3. Identify mismatch triggers ** ;
	data trigger_chk1_att_b4 chk1a_noepi(keep = bene_id  ep_beg_a);
		merge b4(in=a) first_epi(in=b) ; by bene_id ;
		if a and b then do;
			attribute_flag = "2" ;
			trigger_date = ep_beg_a ;
			episode_end = intnx('month', trigger_date, 6,'same')-1 ;
			source = 0 ;
			output trigger_chk1_att_b4 ;
		end ;
		else if a=0 and b then output chk1a_noepi ;


	** 4. Identify attributed episode that did not already get re-attributed to a target already  ** ;
	data triggers_p1 ;
		set triggers2_nobene(in=a)
			TRIGGER_CHK1_ATT 
			triggers_reatt
			triggers2_after;	
	 
	proc sort data=triggers_p1 ; by bene_id  trigger_date ;

	data trigger_chk1_att_b4a ;
		merge trigger_chk1_att_b4(in=a) triggers_p1(in=b keep = bene_id  trigger_date) ; 
		by bene_id  trigger_date ;
		if a and b=0 ;

	** 5. Set additional captured target records with others. *** ;
	data triggers_pass1 ;
		set triggers_p1 trigger_chk1_att_b4a ;

************************************************************************************ ;

proc sort data=triggers_pass1 ; by bene_id  trigger_date ;

data new_att(keep = bene_id  trigger_date ep_beg_a EP_END_A ) ;
	merge triggers_pass1(in=a) triggers2_before(IN=C) att2(in=b) ; by bene_id  trigger_date ;
	if a=0 AND C=0 and b ;
	
data triggers_pass1a ;
	set triggers_pass1
	    new_att (in=a) ;
		if a then do ;
			attribute_flag = "2" ;
			episode_end = intnx('month', trigger_date, 6,'same')-1 ;
			SOURCE = 0 ;
		end ;
		

proc sort data=triggers_pass1a ; by bene_id  trigger_date episode_end ;
	
************************************************************************************** ;
	** PASS 2: Identify Episodes using Attribution overrides where available ** ;
************************************************************************************** ;

** For all performance periods, the potential episode trigger date must not be included 
   in any episode defined for a prior performance period.  6 Potential trigger claims occurring 
   inside a previously defined episode cannot trigger a new episode. ** ;
data t2 ;
	set triggers_pass1a(drop=keep_epi pend); by  bene_id  ;
	format pend mmddyy10. ; 
	if first.bene_id  then do ;
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
	if keep_epi = 1 ;


data triggers_pass2 ;
	set t2 ; by bene_id ;
	if first.bene_id then epi_seq = 1 ;
	else epi_seq = 2 ;
	if _n_ = 1 then ecount = 0 ;
	ecount = sum(ecount,1) ;
	retain ecount epi_seq;

******** Check for match with attribution file after override - chk2_noepi should have 0 records ****** ;
DATA TRIGGER_CHK2_ATT chk2_noatt chk2_noepi;
	MERGE triggers_pass2(in=a) att2(in=b keep = bene_id  trigger_date) ; 
	by bene_id  trigger_date ;
	if a and b then output trigger_chk2_att ;
	if a and b=0 then output chk2_noatt ;
	if a=0 and b then output chk2_noepi ;

run ;

********************************************************************** ;
********************************************************************** ;
********************************************************************** ;
********************************************************************** ;
**** Step 3: Identify final set of episodes ;

data episode_candidates ;
	set triggers_pass2 ;
	format m_episode_beg mmddyy10. ;
	m_episode_beg = trigger_date;
	if attribute_flag in ("1","0") then m_epi_claim = clm_id ;
	m_epi_source = source ;
	drop trigger_date clm_id source ;

proc sort data=episode_candidates ; by  bene_id  m_episode_beg m_epi_source episode_end m_epi_claim ; 

data out.episode_candidates_&dsid.;
	set episode_candidates;
run;

*** Creating file to identify reason to assign bene Id to EMERGING EPISODES. *** ;
proc sort data=triggers_a out=benehaschemo(keep = bene_id  ) nodupkey ; by bene_id  ;

%if "&vers." = "A" %then %do ;
*** Create Mock Beneficiary File *** ;
proc sort data=OUT.epi_combine_a_&dsid. out=epi_pqtr ; by bene_id ;

proc sort data = out.beneqtrs_&dsid. out=be(keep = bene_id q1 q2 q3 Q4 Q5 q6 q7 q8 q9 q10) ; by bene_id ;

data epi_combine ;
	merge epi_pqtr(in=a) be(in=b) ; by bene_id ;
	if a or b ; 
%end ;

%else %do ;
proc sort data=out.EPI_COMBINE_B_&DSID. out=epi_combine ; by bene_id  ; run;
%end ;


*** Note for fbq04 update - need to revisit - possibly assign episodes to first claim date when lack
    of valid trigger. *** ;

%if "&trueup." = "1" %then %do ;

	proc sort data=&in_drop.  out=dropped ; by bene_id ;
	data dropped ; set dropped ; cancer_type_a = cancer_type ; 

%end ;

**** aDD 2 MERGES BY BENE_ID EP_ID_A WITH EPISODE CANDIDATES *** ;
**** 1. RECON_OVERLAP_PP1
	 2. RECON_OVERLAP_PP2
**************************************************************** ;
proc sort data=episode_candidates; by bene_id ep_beg_a; run;

*** Captures all episode information for reconciliation overlap episodes *** ;
data recon_overlap_pp1_epi;
	MERGE EPI_COMBINE(IN=A) OUT.RECON_OVERLAP_PP1_&dsid.(IN=B);
	by BENE_ID ;
	if b;
run;

data recon_overlap_pp2_epi;
	MERGE EPI_COMBINE(IN=A) OUT.RECON_OVERLAP_PP2_&dsid.(IN=B);
	by BENE_ID ;
	if b;
run;

data recon_overlap_pp3_epi;
	MERGE EPI_COMBINE(IN=A) OUT.RECON_OVERLAP_PP3_&dsid.(IN=B);
	by BENE_ID ;
	if b;
run;

**********;

**** Pulls triggers for reconciliation overlap episodes. **** ;

DATA ES1 REMAIN1 recon_pp1_nomatch ;
	MERGE EPISODE_CANDIDATES (IN=A) recon_overlap_pp1_epi (IN=B) ; BY BENE_ID EP_beg_A ;
	IF A AND B THEN OUTPUT ES1 ;
	else if a=0 and b then output recon_pp1_nomatch;
	ELSE OUTPUT REMAIN1 ;
DATA ES2 REMAIN2 recon_pp2_nomatch ;
	MERGE REMAIN1(IN=A) recon_overlap_pp2_epi (IN=B) ; BY BENE_ID EP_beg_A ;
	IF A AND B THEN OUTPUT ES2 ;
	else if a=0 and b then output recon_pp2_nomatch;
	ELSE OUTPUT REMAIN2 ;
DATA ES3 REMAIN3 recon_pp3_nomatch ;
	MERGE REMAIN2(IN=A) recon_overlap_pp3_epi (IN=B) ; BY BENE_ID EP_beg_A ;
	IF A AND B THEN OUTPUT ES3 ;
	else if a=0 and b then output recon_pp3_nomatch;
	ELSE OUTPUT REMAIN3 ;
RUN;

**********;
	
**** Pulls performance episode information for non-recon episodes . **** ;

DATA PRE_STEP1 REMAIN4;
	MERGE EPI_COMBINE(IN=A)
		  %if "&trueup." = "1" %then %do ; 
			dropped( keep = bene_id bene_hicn first_name last_name sex dob cancer_type_a )
		  %end ;
		  REMAIN3(IN=B keep = bene_id episode_end chemo_in_pp epi_seq ecount attribute_flag
		   				      m_episode_beg m_epi_claim m_epi_source) ; BY BENE_ID ;
		IF A AND B THEN OUTPUT PRE_STEP1 ;
		IF A=0 AND B THEN OUTPUT REMAIN4 ;

**********;

DATA PRE_STEP2 ;
	MERGE EPI_COMBINE(IN=A) PRE_STEP1(IN=B) ES1(IN=C) ES2(IN=D) ES3(IN=E); BY BENE_ID ;
	IF A AND B=0 AND C=0 AND D=0 AND E=0 ;


DATA PRE_STEP3 ;
	MERGE PRE_STEP2(IN=A) benehaschemo(IN=B) ; BY BENE_ID ;
	any_chemo=0;
	if b then any_chemo=1;
	if a;
run;

DATA recon_pp1_nomatch2 ;
	MERGE recon_pp1_nomatch(IN=A) benehaschemo(IN=B) ; BY BENE_ID ;
	any_chemo=0;
	if b then any_chemo=1;
	if a;
run;

DATA recon_pp2_nomatch2 ;
	MERGE recon_pp2_nomatch(IN=A) benehaschemo(IN=B) ; BY BENE_ID ;
	any_chemo=0;
	if b then any_chemo=1;
	if a;
run;

DATA recon_pp3_nomatch2 ;
	MERGE recon_pp3_nomatch(IN=A) benehaschemo(IN=B) ; BY BENE_ID ;
	any_chemo=0;
	if b then any_chemo=1;
	if a;
run;


DATA epi_orig_step1_pre ;
	SET ES1(IN=A) ES2(IN=A) ES3(IN=A) PRE_STEP1(IN=A) PRE_STEP3(IN=B) recon_pp1_nomatch2(IN=C) recon_pp2_nomatch2(IN=C) recon_pp3_nomatch2(IN=C) ;
	format chemo_flg1 $1.;
	if a then chemo_flg1 = 'a';
	else if b then chemo_flg1 = 'b';
	else if c then chemo_flg1 = 'c';
	**** Reassigning chemo_in_pp flag to indicate whether a valid trigger was found or not.  **** ;
	if a then chemo_in_pp = 3 ;
run;

proc sort data=epi_orig_step1_pre; by BENE_ID; run;
data epi_orig_step1 (drop=chemo_flg1);
	MERGE epi_orig_step1_pre(IN=A) benehaschemo(IN=B) ; BY BENE_ID ;
	IF A ;
	EMERGE_NOCHEMO = 0 ;
	EMERGE_NOEM = 0 ;
	if chemo_flg1='b' /*and recon_pp1_flag notin (2,3)*/ then do ; 
		CHEMO_IN_PP = 0 ;
		if any_chemo=0 then EMERGE_NOCHEMO = 1 ;
		ELSE EMERGE_NOEM = 1 ;
	END ;
	IF chemo_flg1='c' and any_chemo=0/*AND recon_pp1_flag in (2,3)*/ then do ; 
		CHEMO_IN_PP = 0 ;  
	END ;


	FORMAT EP_BEG MMDDYY10. ;
	if m_episode_beg NE . THEN EP_BEG = m_episode_beg;
	else do ;
		*** Reconciliation Episodes that do not have a trigger because of additional screens. *** ;
		if RECON_PP1_FLAG in (2,3) then do ;
			EP_BEG = EP_BEG_A 	;
			EMERGE_NOCHEMO = 0 ;  
			EMERGE_NOEM = 0 ;
		end ;

		else do ;
			%IF "&VERS." = "A" %THEN %DO ;
			if q1 = 0 and q2 = 0 and q3 = 0 AND q4 = 0 and q5 = 0  AND Q6 = 0 and Q7 = 0 and Q8 = 0 and Q9 = 0 and Q10 = 1 then EP_BEG = &fbq10.  ;
			%END ;
			%ELSE %DO ;
			if q10 = 1 and (DOD = . or DOD gt &fbq10.) then EP_BEG = &fbq10. ;
			%END ;

			else if q9 = 1 and (DOD = . or DOD gt &fbq09.) then EP_BEG = &fbq09. ;
			else if q8 = 1 and (DOD = . or DOD gt &fbq08.) then EP_BEG = &fbq08. ;
			else if q7 = 1 and (DOD = . or DOD gt &fbq07.) then EP_BEG = &fbq07. ;
			else if q6 = 1 and (DOD = . or DOD gt &fbq06.) then EP_BEG = &fbq06. ;
			else if q5 = 1 and (DOD = . or DOD gt &fbq05.) then EP_BEG = &fbq05. ;
			else if q4 = 1 and (DOD = . or DOD gt &fbq04.) then EP_BEG = &fbq04. ;
			ELSE if q3 = 1 and (DOD = . or DOD gt &fbq03.) then EP_BEG = &fbq03. ;
			else if q2 = 1 and (DOD = . or DOD gt &fbq02.) then EP_BEG = &fbq02. ;
			else if q1 = 1 then EP_BEG = &fbq01. ;
		end ;
	END ;

	if ep_beg = . and q10 = 1 and sum(q9,q8,q7,q6,q5,q4,q3,q2,q1) = 0 and dod ne . and dod le &fbq10. then ep_beg = &fbq09. ;
	if ep_beg = . and q9 = 1 and sum(q8,q7,q6,q5,q4,q3,q2,q1) = 0 and dod ne . and dod le &fbq09. then ep_beg = &fbq08. ;
	if ep_beg = . and q8 = 1 and sum(q7,q6,q5,q4,q3,q2,q1) = 0 and dod ne . and dod le &fbq08. then ep_beg = &fbq07. ;
	if ep_beg = . and q7 = 1 and sum(q6,q5,q4,q3,q2,q1) = 0 and dod ne . and dod le &fbq07. then ep_beg = &fbq06. ;
	if ep_beg = . and q6 = 1 and sum(q5,q4,q3,q2,q1) = 0 and dod ne . and dod le &fbq06. then ep_beg = &fbq05. ;
	if ep_beg = . and q5 = 1 and sum(q4,q3,q2,q1) = 0 and dod ne . and dod  le &fbq05. then ep_beg = &fbq04. ;
	if ep_beg = . and q4 = 1 and sum(q3,q2,q1) = 0 and dod ne . and dod  le &fbq04. then ep_beg = &fbq03. ;
	if ep_beg = . and q3 = 1 and sum(q2,q1) = 0 and dod ne . and dod  le &fbq03. then ep_beg = &fbq02. ;
	if ep_beg = . and q2 = 1 and sum(q1) = 0 and dod ne . and dod  le &fbq02. then ep_beg = &fbq01. ;
	
	IF EP_BEG = . THEN EP_BEG = &fbq01. ;

*** reestablishing epi_sequence *** ;
proc sort data=epi_orig_step1 ; by bene_id ep_beg;
data epi_orig_step1 ;
	set epi_orig_step1(drop=epi_seq) ; by bene_id ep_beg;
	if first.bene_id then epi_seq = 1 ;
	else epi_seq = epi_seq + 1;
	retain epi_seq ;
run;


proc sort data=epi_orig_step1 ; by bene_id ep_beg ;
data att3 ;
	set att2 ;
	ep_beg = ep_beg_a ;
proc sort data=att3 ; by bene_id ep_beg ;

data epi_orig_step1a(drop = ep_id) ;
	merge epi_orig_step1(in=a drop=ep_id_a) att3(in=b drop=trigger_date dod) ; by bene_id ep_beg  ;
	if a ;
	if a and b=0 and attribute_flag notin ("D") then attribute_flag = "0" ; ** indicates episodes not found in attribution file. ** ;
	if a and b then do ;
		*** Reassigns episodes without a valid episode start date with attribution start date - WHEN AVAILABLE) *** ;
		if ep_beg ne ep_beg_a then do ; 
			if attribute_flag = "  " then attribute_flag = "2" ;  *** indicates mismatch on episode start date *** ;
			ep_beg = ep_beg_a ;
		end ;
		else if attribute_flag = "  " then attribute_flag = "1" ; *** indicates in attribution and matches episode start date *** ;
	end ;

	FORMAT EP_END  MMDDYY10. ;
	EP_END = intnx('month', EP_BEG, 6,'same')-1 ;
	*** Added 4/3/2017 *** ;
	IF DOD < EP_END AND DOD NE . THEN EP_END = DOD ;

proc sort data=epi_orig_step1A ; by bene_id ep_beg ;

*** Update of Episode ID Derivation - 8/15/17 *** ;
*** [?8/?15/?2017 5:26 PM] Maggie Alston:  [BENEID+STARTDATE]-P-[OCMID] *** ;
data epi_orig_step2 ;
	set epi_orig_step1A ;
	EP_LENGTH = EP_END-EP_BEG+1 ; ;
	epb = ((year(ep_beg)-2000)*10000)+(month(ep_beg)*100)+day(ep_beg) ;
	format ep_id $100. ; length ep_id $100. ;
	EP_ID = CATS(bene_id,"-",epb,"-P-","&OCM.")  ;
	*** Using Attribution episode ID where available ** ;
	IF EP_ID_A NE . THEN EP_ID = CATS(ep_id_a,"-",epb,"-P-","&OCM.") ;
run ;

proc sort data=epi_orig_step2 ; by bene_id ep_beg ;
data epi_orig ;
	set epi_orig_step2 ; by bene_id ep_beg  ;
	if first.bene_id then epi_counter = 1 ;
	else epi_counter = sum(epi_counter,1) ;
	retain epi_counter ;
run ;	



data epi_att2(drop = source) epi_oth ;
	set epi_orig ;
	if attribute_flag = 2 then output epi_att2 ;
	else output epi_oth ;

proc sql ;
*** Capturing chemo source from triggers where attribute episode begin date differes from milliman trigger *** ;
	create table epi_att2a as
	select distinct a.*, b.source
	from epi_att2 as a left join triggers as b
	on a.bene_id = b.bene_id and
	      a.ep_beg = b.trigger_date ;

	%if "&trueup." = "1" %then %do ;
*** Capturing chemo source from triggers where available for dropped episodes *** ;
	create table dropped2 as
	select distinct a.*, b.source
	from dropped as a left join triggers as b
	on a.bene_id = b.bene_id and
		  a.ep_beg = b.trigger_date ;
	%end ;
quit ;
*** applying hierarchy to multiple sources on trigger day *** ;
proc sort data=epi_att2a ; by bene_id ep_id source ;
data epi_att2a ; set epi_att2a ;by bene_id ep_id source ; if first.ep_id ;

%if "&trueup." = "1" %then %do ;
proc sort data=dropped2; by bene_id ep_id source ;
data dropped2 ; set dropped2 ;by bene_id ep_id source ; if first.ep_id ;
%end ;

data epi_orig ;
	set epi_att2a(in=b) epi_oth %if "&trueup." = "1" %then %do ;dropped2(in=a rename=(ep_id=ep_id_a)where = (bene_id ne "  ") drop=ep_length) %end ; ;
	%if "&trueup." = "1" %then %do ;
		if a then do ;
			attribute_flag = "D" ;
			EP_LENGTH = EP_END-EP_BEG+1 ; ;
			epb = ((year(ep_beg)-2000)*10000)+(month(ep_beg)*100)+day(ep_beg) ;
			EP_ID = CATS(ep_id_a,"-",epb,"-P-","&OCM.") ;
		end ;
		if (a or b) THEN DO ;
			IF source = . then source = 0 ;
			M_EPI_SOURCE =  SOURCE ;
			DROP SOURCE ;
		END ; 
	%end ;
	%else %do ;
		if b then do ;
			IF source = . then source = 0 ;
			M_EPI_SOURCE =  SOURCE ;
			DROP SOURCE ;
		end ;
	%end ;
********************************************************************** ;
********************************************************************** ;
**** Appendix B: Identify cancer ;

*** for performance period, use all available E&M claims *** ;
proc sql ;
	create table canc as
	select a.ep_id, a.ep_beg, a.ep_end, b.*
	from epi_orig as a, em as b
	where a.bene_id=b.bene_id and ep_beg le expnsdt1 le ep_end ;

data canc ;
	set canc ;
	%null_canc ;
		if expnsdt1 < mdy(1,2,2017) and EPALL ne 1 then delete ;
		if expnsdt1 < mdy(7,2,2017) and max(EPALL,EP201701) ne 1 then delete ;
		if has_cancer = 1 ;
** Identify unique visits and count the number of visits associated with each cancer type. **
** For the purposes of assigning a cancer type to the episode, a visit is defined by the 
   unique combination of beneficiary ID, TIN, line first expense date, and cancer type 
   associated with the diagnosis code on the line. *** ;
proc sort data=canc ; by  bene_id ep_id  %canc_flags has_cancer tax_num expnsdt1 ;

data visit_count ;
	set canc ; 
			  by  bene_id ep_id %canc_flags has_cancer tax_num expnsdt1 ;

	if first.expnsdt1 then visit_count = 1 ;						 	 


proc means data=visit_count noprint sum ; 
			  by  bene_id ep_id %canc_flags has_cancer ;

	var visit_count ;
	output out=vc1(drop = _type_ _freq_)
		   sum() =  ;
run ;
** Assign the episode the cancer type that has the most visits. ** 
	In the event of a tie, apply tie-breakers in the order below. Assign the cancer type associated with:
	The most recent visit in the episode, second most recent visit, third most recent visit, etc.
	The cancer type that is reconciliation-eligible
	The lowest last digit of the TIN, second lowest digit, etc. ** ;

proc sort data=vc1 ; by  bene_id ep_id has_cancer descending visit_count    ;
run ;

data cancer ;
	set vc1 ;  by  bene_id ep_id has_cancer descending visit_count  ;
	if first.has_cancer then do ;
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
	set cancer ; by  bene_id ep_id has_cancer ;
	if first.ep_id and last.ep_id then output uniq_cancer ;
	else output mult_cancer ;

*** tie_breakers *** ;

	*** a. Capture all visits for episodes with multiple cancer designations. *** ;
	***    Derived field visit_count provides maximum count of visits to run through. *** ;
	proc sort data=mult_cancer ; by  bene_id ep_id %canc_flags has_cancer ;
	data claims_for_mult ;
		merge mult_cancer(in=a rename=(visit_count=max_visit_count)) visit_count(in=b) ; 
		by  bene_id ep_id %canc_flags has_cancer ;
		if a ;
		if visit_count = 1 ;
		*** creates a variable of all the flags *** ;
		%canc_var ;
		rev_tax = reverse(Tax_num) ;
		last_tax = substr(left(rev_tax),1,1) ;

	run ;
	
	*** b. Sort by descending expnsdt1 - will check for multiple cancers on same day *** ;
	proc sort data=claims_for_mult ; by  bene_id ep_id descending expnsdt1 ;
	run ;

	*** c. Identify unique dates of service that do NOT have multiple cancer assignments. **** ;
	data udates1 mdates1  ;
		set claims_for_mult ;  by  bene_id ep_id descending expnsdt1 ;
		if first.expnsdt1 and last.expnsdt1 then output udates1 ;
		else output mdates1 ;

	*** d. Using unique dates of service, assign cancer to most recent DOS. *** ;
	data udates1_chk ;
		set udates1 ; by  bene_id ep_id descending expnsdt1 ;
		if first.ep_id ;

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
		set udates2_chk ; by  bene_id ep_id descending expnsdt1 ;
		if first.ep_id ;
	
	*** i. run remaining through TIN tax ID check  - identify unique REV_TIN and cancer combos *** ;
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



	proc sort data=level3_tie_a out=l3 nodupkey ; by bene_id ep_id last_tax descending clm_id cancer_chk ;

	*** j. identify final_cancer based on tin digits  *** ;
	*** 3/2/18: As per OCM ticket #868640 - use last digit of tin and then highest clm_id *** ;
	data mc3_canc ;
		set l3 ; by bene_id ep_id last_tax descending clm_id cancer_chk ;
		if first.ep_id;

	proc sort data=claims_for_mult ; by bene_id ep_id last_tax descending clm_id cancer_chk ;

	data udates3_chk ;
		merge mc3_canc (in=a keep=bene_id ep_id last_tax clm_id cancer_chk) claims_for_mult(in=b) ;
		by bene_id ep_id last_tax descending clm_id cancer_chk ;
		if a and b ;

	data udates3_chk ;
		set udates3_chk ; by bene_id ep_id ;
		if first.ep_id ;

	***** k. Combine All Cancer Assignments. ***** ;
		*** uniq_cancer - no tie breakers needed *** ;
		*** udates1_chk - assigned based on most recent e&m claim *** ;
		*** udates2_chk - assigned based on recon eligible flag   *** ;
		*** udates3_chk - defaults to lowest tax digit/highest clm_id screen    *** ;
data cancer_assignment (keep =  Bene_id ep_id cancer recon_elig) ;
	set uniq_cancer
		udates1_chk 
		udates2_chk 
		udates3_chk;
	%assign_cancer ; 
proc sort data=cancer_assignment ; by  	Bene_id ep_id ; run;

*** the OCM prediction model distinguishes breast cancer episodes containing only Part D 
    chemotherapy from those containing some Part B chemotherapy. **** ;
data chemotherapy ;
	set chemo_claims (where = (chemo = 1) in=a)
		all_op_chemo (in=b)
		chemo_candidates3 (in=c) ;
	if a and carr = 1 then source = 2 ; *** carrier is second in hierarchy *** ;
	if b then source = 1 ; *** outpatient is first in hierarchy *** ;
	if a and carr ne 1 then source = 3 ; *** DME is third in hierarchy *** ;
	if c then source = 4 ; *** Part D is fourth in hierarchy **** ;

proc sql ;
	create table triggers_a3a as
	select a.ep_id, b.*
	from epi_orig as a, triggers_a3 as b
	where a.bene_id=b.bene_id and ep_beg le trigger_date le ep_end;

proc sort data=triggers_a3a ; by  bene_id ep_id ;
proc means data=triggers_a3a min max noprint ; by  bene_id ep_id ;
	var source ;	
	output out=trigger_s(drop = _type_ _freq_)
		   min(source) = mins 
		   max(source) = maxs ;

data trigger_s(keep =  bene_id ep_id partdonly) ;
	set trigger_s ;
	if mins=4 and maxs = 4 then partdonly=1 ; else partdonly = 0 ;

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
	where a.bene_id=b.bene_id and 
		ep_beg le expnsdt1 le ep_end ;

data canc2 ;
	set canc2 ;
		if ep_beg < mdy(1,2,2017) and EPALL ne 1 then delete ;
		if ep_beg < mdy(7,2,2017) and max(EPALL,EP201701) ne 1 then delete ;


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


proc sort data=vc ; by  bene_id ep_id ep_beg ep_end descending visit_count ;
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
		by  bene_id ep_id ep_beg ep_end tax_num ;
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
	proc sort data=claims_for_mult2 ; by  bene_id ep_id ep_beg ep_end descending expnsdt1 ;
	run ;

	data udates1 mdates1 ;
		set claims_for_mult2 ; by  bene_id ep_id ep_beg ep_end descending expnsdt1 ;
		if first.expnsdt1 and last.expnsdt1 then output udates1 ;
		else output mdates1 ;
	
	*** d. Using unique dates of service, assign TIN to most recent DOS. *** ;
	data udates1_chk ;
		set udates1 ; by  bene_id ep_id ep_beg ep_end descending expnsdt1 ;
		if first.ep_end and clm_last_dt=1 ;

	*** e. Check for episodes without uniques trigger dates - will move onto TIN check. *** ;
	data level2_tie ;
		merge mult_ids (in=a keep=bene_id ep_id)
			  udates1_chk (in=b keep=bene_id ep_id) ;
		by bene_id ep_id;
		if a and b=0 ;

	proc sort data=level2_tie nodupkey ; by bene_id ep_id;

	*** f. run remaining through TIN tax ID check  - identify unique REV_TIN and cancer combos *** ;
	data mt2 ;
		merge level2_tie(in=a keep=bene_id ep_id)
			  claims_for_mult2(in=b) ; by bene_id ep_id;
		if a and b ;
		last_dig = substr(left(rev_tax),1,1) ;

	proc sort data=mt2 ; by bene_id ep_id ep_beg ep_end rev_tax ;
	*** g. identify final_cancer based on tin digits  *** ;
	data udates2_chk ;
		set mt2 ; by bene_id ep_id ep_beg ep_end rev_tax;
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

proc sort data=level4_tie ; by bene_id ep_id ep_beg ep_end tax_num revnpi ;
data unnpi2 ;
	set leveL4_tie ;by bene_id ep_id ep_beg ep_end tax_num revnpi ;
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
	set out.iphdr_wrecon_&dsid. ;
data r ;
	set out.inprev_wrecon_&dsid. ;


proc sort data=h ; by  bene_id clm_id thru_dt ;
proc sort data=r ; by  bene_id clm_id thru_dt ;

data out.inpatient_&type.&vers._&dsid. ;
	merge h(in=a) r(in=b) ; by  bene_id clm_id thru_dt ;
	if a and b ;
	IF ADMSN_DT GE &SD. ;

data ipop ;
	set out.inpatient_&type.&vers._&dsid.(in=a) out.outpatient_&type.&vers._&dsid.(in=b) ;
	if a then do ;
		start_date = ADMSN_DT ;
		from_ip_file = 1 ;
	end ;
	if b then do ;
		start_date = from_dt ;
		from_ip_file = 0 ;
	end ;

proc sql ;
	create table ipop2 as
	select a.ep_id, a.ep_beg, a.ep_end, b.* 
	from epi_orig as a, ipop as b
	where a.bene_id = b.bene_id and
		  a.ep_beg le start_date le a.ep_end ;
quit ;

data OUT.check_ipop_&type.&vers._&dsid.
			  (KEEP =  BENE_ID EP_ID CLM_ID THRU_DT BMT_ALLOGENEIC BMT_AUTOLOGOUS
					   /*BMT_ALLOGENEIC_AK  BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_CL 
					   BMT_ALLOGENEIC_MDS BMT_AUTOLOGOUS_AK  BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_CL 
					   BMT_AUTOLOGOUS_MDS*/ RADTHER 
					   ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY
					   GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
					   OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY 
					   dxANAL_SURGERY dxBLADDER_SURGERY dxBREAST_SURGERY dxFEMALEGU_SURGERY
					   dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY dxLIVER_SURGERY dxLUNG_SURGERY
					   dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY 
					   CLINICAL_TRIAL_MILL ) ;
	set ipop2 ;

		ARRAY INIT (B) CT HAS_CANCER BMT_ALLO BMT_AUTO BMT_ALLOGENEIC BMT_AUTOLOGOUS
					   /*BMT_ALLOGENEIC_AK  BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM 
					   BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL BMT_AUTOLOGOUS_AK  BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM 
					   BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL*/ RADTHER 
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

		IF HAS_CANCER = 1 AND CT = 1 THEN DO ;
				IF from_ip_file = 1  THEN CLINICAL_TRIAL_MILL = 1 ;
				ELSE IF (EP_BEG LE THRU_DT LE EP_END) OR
						(EP_BEG LE FROM_DT LE EP_END) THEN CLINICAL_TRIAL_MILL = 1 ;
		END ;


		IF NOPAY_CD = '  ' THEN DO ;


			ARRAY v1 (X) ICD_prcdr_VRSN_CD1-ICD_prcdr_VRSN_CD25 ;
			ARRAY d1 (X) ICD_prcdr_CD1-ICD_prcdr_CD25 ;
			DO X = 1 TO DIM(D1) ;
				*Current Performance Period Mapping ;
				if ep_beg ge mdy(7,2,2017) then do ;
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
				if ep_beg ge mdy(7,2,2017) then do ;
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

						IF SUM(ACUTE_LEUKEMIA,LYMPHOMA,MULT_MYELOMA,MDS, CHRONIC_LEUKEMIA) > 0 THEN DO ;
							IF PUT(DRG_CD,$BMT_DRG.) = "Y" THEN DO ;
								IF DRG_CD = '014' THEN BMT_ALLO2 = 1 ; 
								IF DRG_CD NE '014' THEN BMT_AUTO2 = 1 ; 
							END ;

								BMT_ALLOGENEIC = MAX(BMT_ALLO1,BMT_ALLO2) ;
								BMT_AUTOLOGOUS = MAX(BMT_AUTO1,BMT_AUTO2) ;
					
							IF SUM(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) LT 1 THEN DO ;
								IF PUT(HCPCS_CD,$BMT_CPT.) = "Y" THEN DO ;
									IF HCPCS_CD = '38240' THEN BMT_ALLOGENEIC = 1 ;
									ELSE BMT_AUTOLOGOUS = 1 ;
								END ;
								
							END ;
						END ;

				end ;
					* Prior Performance Period Mappings * ;
					*** Performance Periods 1 + 2 *** ;
				else do ;
					if put(hcpcs_cd,$RadTher_CPT2p.) = "Y" then RADTHER = 1 ;
					if put(hcpcs_cd,$Prostate_CPT2p.) = "Y" then PROSTATE_SURGERY = 1 ;
					if put(hcpcs_cd,$Pancreatic_CPT2p.) = "Y" then PANCREATIC_SURGERY = 1 ;
					if put(hcpcs_cd,$Ovarian_CPT2p.) = "Y" then OVARIAN_SURGERY = 1 ;
					if put(hcpcs_cd,$Liver_CPT2p.) = "Y" then LIVER_SURGERY = 1 ;
					if put(hcpcs_cd,$HeadNeck_CPT2p.) = "Y" then HEADNECK_SURGERY = 1 ;
					if put(hcpcs_Cd,$Gastro_CPT2p.) = "Y" then GASTRO_SURGERY = 1 ;
					if put(hcpcs_cd,$FemaleGU_CPT2p.) = "Y" then FEMALEGU_SURGERY = 1 ;
					if put(hcpcs_cd,$Breast_CPT2p.) = "Y" then BREAST_SURGERY = 1 ;


						*IF SUM(ACUTE_LEUKEMIA,LYMPHOMA,MULT_MYELOMA,MDS) > 0 THEN DO ;
							IF PUT(DRG_CD,$BMT_DRG2P.) = "Y" THEN DO ;
								IF DRG_CD = '014' THEN BMT_ALLO2 = 1 ; 
								IF DRG_CD ne '014' THEN BMT_AUTO2 = 1 ;
							END ;

								BMT_ALLOGENEIC = MAX(BMT_ALLO1,BMT_ALLO2) ;
								BMT_AUTOLOGOUS = MAX(BMT_AUTO1,BMT_AUTO2) ;
					
							IF SUM(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) LT 1 THEN DO ;
								IF PUT(HCPCS_CD,$BMT_CPT2P.) = "Y" THEN DO ;
									IF HCPCS_CD = '38240' THEN BMT_ALLOGENEIC = 1 ;
									ELSE BMT_AUTOLOGOUS = 1 ;
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
		
			*ARRAY CANC (c) ACUTE_LEUKEMIA LYMPHOMA MULT_MYELOMA MDS CHRONIC_LEUKEMIA;
			*ARRAY B1 (c) BMT_ALLOGENEIC_AK  BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL ;
			*ARRAY B2 (c) BMT_AUTOLOGOUS_AK  BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL ;
				
			*DO C = 1 TO 5 ;
				*IF CANC = 1 THEN DO ;
					*B1 = BMT_ALLOGENEIC ;
					*B2 = BMT_AUTOLOGOUS ;
				*END ;
			*END ;
				
			
data carr ;
	set out.phyline_wrecon_&dsid. ;
		IF EXPNSDT1 GE &SD. ;
data dme ;
	set out.dmeline_wrecon_&dsid. ;
		IF EXPNSDT1 GE &SD. ;



PROC SORT DATA=CARR ; BY bene_id clm_id ;
PROC SORT DATA=dme ; BY bene_id clm_id ;
proc sort data=OUT.phyhdr_WRECON_&dsid. out=ph nodupkey ; by bene_id clm_id ;
proc sort data=OUT.dmehdr_WRECON_&dsid. out=dh nodupkey ; by bene_id clm_id ;

data carr_a ;
	merge carr(in=a) ph(in=b keep=bene_id clm_id from_dt thru_dt icd_dgns_cd: ICD_DGNS_VRSN_CD:); by bene_id clm_id ;
	if a ;
data dme_a ;
	merge dme(in=a) dh(in=b keep=bene_id clm_id from_dt thru_dt icd_dgns_cd: ICD_DGNS_VRSN_CD:); by bene_id clm_id ;
	if a ;



proc sql ;
	create table carr2 as
	select a.ep_id, a.ep_beg, a.ep_end, b.* 
	from epi_orig as a, carr_a as b
	where a.bene_id = b.bene_id and
		  a.ep_beg le expnsdt1 le a.ep_end ;
quit ;

proc sql ;
	create table dme2 as 
	select a.ep_id, a.ep_beg, a.ep_end, b.* 
	from epi_orig as a, dme_a as b
	where a.bene_id = b.bene_id and
		  a.ep_beg le expnsdt1 le a.ep_end ;
quit ;

data check_carr(KEEP = BENE_ID EP_ID CLM_ID THRU_DT RADTHER 
					   BREAST_SURGERY FEMALEGU_SURGERY GASTRO_SURGERY HEADNECK_SURGERY 
					   INTESTINAL_SURGERY KIDNEY_SURGERY OVARIAN_SURGERY PANCREATIC_SURGERY 
					   PROSTATE_SURGERY LIVER_SURGERY
					   dxBREAST_SURGERY dxFEMALEGU_SURGERY dxGASTRO_SURGERY dxHEADNECK_SURGERY 
					   dxINTESTINAL_SURGERY dxKIDNEY_SURGERY dxOVARIAN_SURGERY dxPANCREATIC_SURGERY 
				       dxPROSTATE_SURGERY dxLIVER_SURGERY
					   CLINICAL_TRIAL_MILL )  ;	
	set carr2 dme2(in=a) ;

	if a then dme_flag = 1 ;
	else dme_flag = 0 ;

	ARRAY INIT (B) RADTHER 
				   BREAST_SURGERY FEMALEGU_SURGERY
				   GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY 
				   OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY CLINICAL_TRIAL_MILL 
				   dxBREAST_SURGERY dxFEMALEGU_SURGERY
				   dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY dxLIVER_SURGERY 
				   dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY 
;
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
				if ep_beg gt mdy(7,1,2017) then do ;
					IF LINE_ICD_DGNS_CD in  ("V707","Z006") THEN CLINICAL_TRIAL_MILL = 1 ;
					ELSE IF (EP_BEG LE FROM_DT LE EP_END) OR
							(EP_BEG LE THRU_DT LE EP_END) THEN CLINICAL_TRIAL_MILL = 1 ;
				end ;
				else do ;
					if dme_flag = 0 then do ;
						IF LINE_ICD_DGNS_CD in  ("V707","Z006") THEN CLINICAL_TRIAL_MILL = 1 ;
						ELSE IF (EP_BEG LE FROM_DT LE EP_END) OR
								(EP_BEG LE THRU_DT LE EP_END) THEN CLINICAL_TRIAL_MILL = 1 ;
					end ;
				end ;					
			END ;

			IF DME_FLAG = 0 THEN DO ;

					* Current Performance Period Mapping * ;
				if ep_beg ge mdy(7,2,2017) then do ;
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
				else do ;
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

data all ; set OUT.check_ipop_&type.&vers._&dsid. check_carr ;
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
data out.episodes_&type.&vers._&dsid. ;
	merge epi_orig(in=a) 
		  ca(in=b)
		  predict_vars(in=c)
		  trigger_s ; by  bene_id ep_id  ;
	if cancer = "Intestinal Cancer" then cancer = "Small Intestine / Colorectal Cancer" ;

	if a ;
	/*if Q10 = 1 AND (ep_end > mdy(10,1,2018) or (q9 = 0 and q8 = 0 and q7 = 0 and q6 = 0 and q5 = 0 and q4 = 0 and q3=0 and q2=0 and q1=0)) then do ;
		CANCER_TYPE = CANCER_TYPEQ10 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ10+0;
		RISK_SCORE = risk_score_q10 ;
		RISK_ADJ_FACTOR = risk_adj_factorq10 ;
		INFLATION_FACTOR = INFLATION_FACTORQ10 ;
		HIGH_RISK = HIGH_RISKQ10 ;
		AGE_CATEGORY = AGE_CATEGORYQ10 ;
		DIED = DIEDQ10 ;
		DUAL = DUALQ10 ;
	end ;
	else*/ if Q9 = 1 AND (ep_end > mdy(7,1,2018) or (q8 = 0 and q7 = 0 and q6 = 0 and q5 = 0 and q4 = 0 and q3=0 and q2=0 and q1=0)) then do ;
		CANCER_TYPE = CANCER_TYPEQ09 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ09+0;
		RISK_SCORE = risk_score_q09 ;
		RISK_ADJ_FACTOR = risk_adj_factorq09 ;
		INFLATION_FACTOR = INFLATION_FACTORQ09 ;
		HIGH_RISK = HIGH_RISKQ09 ;
		AGE_CATEGORY = AGE_CATEGORYQ09 ;
		DIED = DIEDQ09 ;
		DUAL = DUALQ09 ;
	end ;
	else if Q8 = 1 AND (ep_end > mdy(4,1,2018) or (q7 = 0 and q6 = 0 and q5 = 0 and q4 = 0 and q3=0 and q2=0 and q1=0)) then do ;
		CANCER_TYPE = CANCER_TYPEQ08 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ08+0;
		RISK_SCORE = risk_score_q08 ;
		RISK_ADJ_FACTOR = risk_adj_factorq08 ;
		INFLATION_FACTOR = INFLATION_FACTORQ08 ;
		HIGH_RISK = HIGH_RISKQ08 ;
		AGE_CATEGORY = AGE_CATEGORYQ08 ;
		DIED = DIEDQ08 ;
		DUAL = DUALQ08 ;
	end ;
	else if Q7 = 1 AND (ep_end > mdy(1,1,2018) or (q6 = 0 and q5 = 0 and q4 = 0 and q3=0 and q2=0 and q1=0)) then do ;
		CANCER_TYPE = CANCER_TYPEQ07 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ07+0;
		RISK_SCORE = risk_score_q07 ;
		RISK_ADJ_FACTOR = risk_adj_factorq07 ;
		INFLATION_FACTOR = INFLATION_FACTORQ07 ;
		HIGH_RISK = HIGH_RISKQ07 ;
		AGE_CATEGORY = AGE_CATEGORYQ07 ;
		DIED = DIEDQ07 ;
		DUAL = DUALQ07 ;
	end ;
	else if Q6 = 1 AND (ep_end > mdy(10,1,2017) or (q5 = 0 and q4 = 0 and q3=0 and q2=0 and q1=0)) then do ;
		CANCER_TYPE = CANCER_TYPEQ06 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ06+0;
		RISK_SCORE = risk_score_q06 ;
		RISK_ADJ_FACTOR = risk_adj_factorq06 ;
		INFLATION_FACTOR = INFLATION_FACTORQ06 ;
		HIGH_RISK = HIGH_RISKQ06 ;
		AGE_CATEGORY = AGE_CATEGORYQ06 ;
		DIED = DIEDQ06 ;
		DUAL = DUALQ06 ;
	end ;
	else if Q5 = 1 AND (ep_end > mdy(7,1,2017) or (q4 = 0 and q3=0 and q2=0 and q1=0)) then do ;
		CANCER_TYPE = CANCER_TYPEQ05 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ05+0;
		RISK_SCORE = risk_score_q05 ;
		RISK_ADJ_FACTOR = risk_adj_factorq05 ;
		INFLATION_FACTOR = INFLATION_FACTORQ05 ;
		HIGH_RISK = HIGH_RISKQ05 ;
		AGE_CATEGORY = AGE_CATEGORYQ05 ;
		DIED = DIEDQ05 ;
		DUAL = DUALQ05 ;
	end ;
	else if Q4 = 1 AND (ep_end > mdy(4,1,2017) or (q3=0 and q2=0 and q1=0)) then do ;
		CANCER_TYPE = CANCER_TYPEQ04 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ04+0;
		RISK_SCORE = risk_score_q04 ;
		RISK_ADJ_FACTOR = risk_adj_factorq04 ;
		INFLATION_FACTOR = INFLATION_FACTORQ04 ;
		HIGH_RISK = HIGH_RISKQ04 ;
		AGE_CATEGORY = AGE_CATEGORYQ04 ;
		DIED = DIEDQ04 ;
		DUAL = DUALQ04 ;
	end ;
	else if Q3 = 1 AND (ep_end > mdy(12,31,2016) or (q2=0 and q1=0)) then do ;
		CANCER_TYPE = CANCER_TYPEQ03 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ03+0;
		RISK_SCORE = risk_score_q03 ;
		RISK_ADJ_FACTOR = risk_adj_factorq03 ;
		INFLATION_FACTOR = INFLATION_FACTORQ03 ;
		HIGH_RISK = HIGH_RISKQ03 ;
		AGE_CATEGORY = AGE_CATEGORYQ03 ;
		DIED = DIEDQ03 ;
		DUAL = DUALQ03 ;
	end ;
	else if q2 = 1 and (ep_end > mdy(9,30,2016) or q1=0) then do ;
		CANCER_TYPE = CANCER_TYPEQ02 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ02+0;
		RISK_SCORE = risk_score_q02 ;
		RISK_ADJ_FACTOR = risk_adj_factorq02 ;
		INFLATION_FACTOR = INFLATION_FACTORQ02 ;
		HIGH_RISK = HIGH_RISKQ02 ;
		AGE_CATEGORY = AGE_CATEGORYQ02 ;
		DIED = DIEDQ02 ;
		DUAL = DUALQ02 ;
	end ;
	else do ;
		CANCER_TYPE = CANCER_TYPEQ01 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ01+0;
		RISK_SCORE = risk_score_q01 ;
		RISK_ADJ_FACTOR = risk_adj_factorq01 ;
		INFLATION_FACTOR = INFLATION_FACTORQ01 ;
		HIGH_RISK = HIGH_RISKQ01 ;
		AGE_CATEGORY = AGE_CATEGORYQ01 ;
		DIED = DIEDQ01 ;
		DUAL = DUALQ01 ;
	end ;

	/*if cancer_type = "  " then do ;
		CANCER_TYPE = CANCER_TYPEQ10 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ10+0;
	end ;*/
	if cancer_type = "  " then do ;
		CANCER_TYPE = CANCER_TYPEQ09 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ09+0;
	end ;
	if cancer_type = "  " then do ;
		CANCER_TYPE = CANCER_TYPEQ08 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ08+0;
	end ;
	if cancer_type = "  " then do ;
		CANCER_TYPE = CANCER_TYPEQ07 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ07+0;
	end ;
	if cancer_type = "  " then do ;
		CANCER_TYPE = CANCER_TYPEQ06 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ06+0;
	end ;
	if cancer_type = "  " then do ;
		CANCER_TYPE = CANCER_TYPEQ05 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ05+0;
	end ;
	if cancer_type = "  " then do ;
		CANCER_TYPE = CANCER_TYPEQ04 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ04+0;
	end ;
	if cancer_type = "  " then do ;
		CANCER_TYPE = CANCER_TYPEQ03 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ03+0;
	end ;
	if cancer_type = "  " then do ;
		CANCER_TYPE = CANCER_TYPEQ02 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ02+0;
	end ;
	if cancer_type = "  " then do ;
		CANCER_TYPE = CANCER_TYPEQ01 ;
		COMMON_CANCER_TYPE = COMMON_CANCER_TYPEQ01+0;
	end ;
	

	
	ctype = cancer_type ;
	if ctype = "MEOS, no PBP" then ctype = cancer ;
	if ctype ne "Breast Cancer" then partdonly = 2 ;

RUN ;


proc sort data=out.episodes_&type.&vers._&dsid. ; by  bene_id EP_ID ;


***** Added 9/6/17 - Summing of BENE variables based on episode start and end date. **** ;

data quarters ;
	set in1.epi2_&dsid.(in=a)
		in2.epi_&dsid.(in=b)
		in3.epi_&dsid.(in=c) 
		in4.epi_&dsid.(in=d) 
		in5.epi_&dsid.(in=e) 
		in6.epi_&dsid.(in=f) 
		in7.epi_&dsid.(in=g) 
		in8.epi_&dsid.(in=h) 
		in9.epi_&dsid.(in=i) 
		/*in10.epi_&dsid.(in=j) */
;
		q=0 ;
		if a then q = 1 ;
		if b then q = 2 ;
		if c then q = 3 ;
		if d then q = 4 ;
		if e then q = 5 ;
		if f then q = 6 ;
		if g then q = 7 ;
		if h then q = 8 ;
		if i then q = 9 ;
		/*if j then q = 10 ; */


proc sort data=quarters ; by bene_id q ;


proc sql ;
	create table epi_q as
	select A.BENE_ID, a.ep_id, a.ep_beg, a.ep_end, a.q1, a.q2, a.q3, a.q4, a.q5, a.q6, a.q7, a.q8, a.q9, /*a.q10,  */q, 
			ALL_TOS,INP_ADMSNS,INP_EX,INP_AMB,
			UNPLANNED_READ,ER_OBS_AD,ER_AD,OBS_AD,ER_AND_OBS_AD,NO_ER_NO_OBS_AD,OBS_STAYS,
			OBS_ER,OBS_NO_ER,ER_NO_AD_OBS,EM_VISITS,EM_VISITS_ALL,
			R_ONC,PHY_SRVC,	PHY_ONC,PHY_OTH,ANC_TOT,ANC_LAB_TOT,ANC_LAB_ADV,ANC_LAB_OTHER,
			ANC_IMAG_TOT,ANC_IMAG_ADV,ANC_IMAG_OTH,OUT_OTHER,HHA,SNF,LTC,IRF,HSP_TOT,HSP_FAC,
			HSP_HOME,HSP_BOTH,DME_NO_DRUGS,PD_TOT,PD_PTB_PHYDME,PD_PTB_OUT,PD_PTD_ALL,
			OTHER,ALL_TOS_ADJ,INP_ADMSNS_ADJ,INP_EX_ADJ,INP_AMB_ADJ,UNPLANNED_READ_ADJ,	
			ER_OBS_AD_ADJ,ER_AD_ADJ,OBS_AD_ADJ,ER_AND_OBS_AD_ADJ,NO_ER_NO_OBS_AD_ADJ,
			OBS_STAYS_ADJ,OBS_ER_ADJ,OBS_NO_ER_ADJ,ER_NO_AD_OBS_ADJ,R_ONC_ADJ,PHY_SRVC_ADJ,
			PHY_ONC_ADJ,PHY_OTH_ADJ,ANC_TOT_ADJ,ANC_LAB_TOT_ADJ,ANC_LAB_ADV_ADJ,ANC_LAB_OTHER_ADJ,		
			ANC_IMAG_TOT_ADJ,ANC_IMAG_ADV_ADJ,ANC_IMAG_OTH_ADJ,OUT_OTHER_ADJ,HHA_ADJ,SNF_ADJ,
			LTC_ADJ,IRF_ADJ,HSP_TOT_ADJ,HSP_FAC_ADJ,HSP_HOME_ADJ,HSP_BOTH_ADJ,DME_NO_DRUGS_ADJ,
			PD_TOT_ADJ,	PD_PTB_PHYDME_ADJ,PD_PTB_OUT_ADJ,PD_PTD_ALL_ADJ,OTHER_ADJ,INP_ADMSNS_UTIL,
			INP_EX_UTIL,INP_AMB_UTIL,UNPLANNED_READ_UTIL,ER_OBS_AD_UTIL,ER_AD_UTIL,	OBS_AD_UTIL,
			ER_AND_OBS_AD_UTIL,NO_ER_NO_OBS_AD_UTIL,OBS_STAYS_UTIL,OBS_ER_UTIL,OBS_NO_ER_UTIL,
			ER_NO_AD_OBS_UTIL,R_ONC_UTIL,PHY_SRVC_UTIL,PHY_ONC_UTIL,PHY_OTH_UTIL,ANC_LAB_TOT_UTIL,
			ANC_LAB_ADV_UTIL,ANC_LAB_OTHER_UTIL,ANC_IMAG_TOT_UTIL,ANC_IMAG_ADV_UTIL,ANC_IMAG_OTH_UTIL,
			HHA_UTIL,SNF_UTIL,LTC_UTIL,IRF_UTIL,HSP_UTIL,BR_KADYCLA,BR_AVASTIN,BR_AFINITOR,
			BR_NEULASTA,BR_PERJATA,BR_HEPCEPTIN,PR_ZYTIGA,PR_JEVTANA,PR_XTANDI,PR_PROVENGE,LU_GILOTRIF,
			LU_TECENTRIQ,LU_AVASTIN,LU_TARCEVA,LU_OPDIVO,LU_ABRAXANE,LU_NEULASTA,LU_KEYTRUDA,
			LU_ALIMTA,LY_TREANDA,LY_VELCADE,LY_IMBRUVICA,LY_REVLIMID,LY_OPDIVO,LY_NEULASTA,LY_KEYTRUDA,
			LY_RITUXAN,IC_AVASTIN,IC_XELODA,IC_ERBITUX,IC_VECTIBIX,IC_NEULASTA,IC_KEYTRUDA,IC_ZALTRAP,
			MU_VELCADE,MU_KYPROLIS,MU_DARZALEX,MU_REVLIMID,BL_TECENTRIQ,BL_OPDIVO,HN_ERBITUX,
			HN_OPDIVO,HN_KEYTRUDA,MA_COTELLIC,MA_TAFINLAR,MA_YERVOY,MA_OPDIVO,MA_KEYTRUDA,MA_MEKINIST,
			MA_ZELBORAF,BR_ABRAXANE,BR_IBRANCE
	from out.episodes_&type.&vers._&dsid. as a left join quarters as b 
	on a.bene_id = b.bene_id ;
quit ;

data epi_q ;
	set epi_q ;
	sumi = 1 ; maxi = 1 ; ertrig = 0 ;
	*** Episodes beginning in first quarter *** ;
	if ep_beg le mdy(9,30,2016) then do ;
		if ep_end le mdy(12,31,2016) then do ;
			if q ge 3 then do ;
				sumi = 0 ;
				maxi = 0 ;
			end ;
			if q2 = 1 and q = 2 then ertrig = 1 ;
			else if q1 = 1 and q = 1 then ertrig = 1 ;
		end ;
		else do ;
			if q3 = 1 and q = 3 then ertrig = 1 ;
		end ;
	end ;
	
	*** Episodes beginning in second quarter *** ;
	else if ep_beg < mdy(1,1,2017) then do ;
		if q = 1 then do ;
			sumi = 0 ;
			maxi = 0 ;
		end ;
		if ep_end < mdy(4,1,2017) then do ;
			if q3 = 1 and q=3 then ertrig = 1 ;
			else if q2 = 1 and q = 2 then ertrig = 1 ;
			else if q1 = 1 and q = 1 then ertrig = 1 ;
		end ;
		else do ;
			if q4 = 1 and q = 4 then ertrig = 1 ;
			else if q3 = 1 and q = 3 then ertrig = 1 ;
		end ;
	end ;
		
	*** Episodes beginning in third  quarter *** ;
	else if ep_beg < mdy(4,1,2017) then do ;
		if q lt 3 then do ;
			sumi = 0 ;
			maxi = 0 ;
		end ;
		if q4 =1 and q = 4 then ertrig = 1 ;
		else if q3 = 1 and q = 3 then ertrig = 1 ;
	end ;

	*** Episodes beginning in fourth  quarter *** ;
	else if ep_beg < mdy(7,1,2017) then do ;
		if q < 4 then do ;
			sumi=0 ;
			maxi = 0 ;
		end ;
		if q5 =1 and q= 5 then ertrig = 1 ;
		else if q4 = 1 and q = 4 then ertRig = 1 ;
	end ;

	*** Episodes beginning in fifth  quarter *** ;
	else if ep_beg < mdy(10,1,2017) then do ;
	
		if q < 5 then do ;
			sumi=0 ;
			maxi = 0 ;
		end ;
		if q6 =1 and q= 6 then ertrig = 1 ;
		else if q5 = 1 and q = 5 then ertRig = 1 ;
	end ;
	*** Episodes beginning in sixth  quarter *** ;
	else if ep_beg < mdy(1,1,2018) then do ;
		if q < 6 then do ;
			sumi=0 ;
			maxi = 0 ;
		end ;
		if q7 = 1 and q = 7 then ertRig = 1 ;
		else if q6 = 1 and q = 6 then ertrig = 1 ;
	end ;
	*** Episodes beginning in seventh  quarter *** ;
	else if ep_beg < mdy(4,1,2018) then do ;
		if q < 7 then do ;
			sumi=0 ;
			maxi = 0 ;
		end ;
		if q8 = 1 and q = 8 then ertRig = 1 ;
		else if q7 = 1 and q = 7 then ertrig = 1 ;
	end ;
	*** Episodes beginning in eighth  quarter *** ;
	else if ep_beg < mdy(7,1,2018) then do ;
		if q < 8 then do ;
			sumi=0 ;
			maxi = 0 ;
		end ;
		if q9 = 1 and q = 9 then ertRig = 1 ;
		else if q8 = 1 and q = 8 then ertrig = 1 ;
	end ;
	*** Episodes beginning in ninth  quarter *** ;
	*else if ep_beg < mdy(10,1,2018) then do ;
	else do;
		if q < 9 then do ;
			sumi=0 ;
			maxi = 0 ;
		end ;
		*if q10 = 1 and q = 10 then ertRig = 1 ;
		*else if q9 = 1 and q = 9 then ertrig = 1 ;
		if q9 = 1 and q = 9 then ertRig = 1 ;
	end ;


proc sort data=EPI_Q ; by bene_id ep_id ;
proc means data= EPI_Q noprint sum ; by bene_id ep_id ;
	where sumi = 1 ;
	var ALL_TOS INP_ADMSNS INP_EX INP_AMB UNPLANNED_READ ER_OBS_AD 
			ER_AD OBS_AD  ER_AND_OBS_AD NO_ER_NO_OBS_AD OBS_STAYS OBS_ER OBS_NO_ER ER_NO_AD_OBS
			R_ONC PHY_SRVC 	PHY_ONC PHY_OTH ANC_TOT ANC_LAB_TOT ANC_LAB_ADV ANC_LAB_OTHER 
			ANC_IMAG_TOT ANC_IMAG_ADV ANC_IMAG_OTH OUT_OTHER HHA SNF LTC IRF HSP_TOT HSP_FAC
			HSP_HOME HSP_BOTH DME_NO_DRUGS PD_TOT PD_PTB_PHYDME PD_PTB_OUT PD_PTD_ALL 
			OTHER ALL_TOS_ADJ INP_ADMSNS_ADJ INP_EX_ADJ INP_AMB_ADJ UNPLANNED_READ_ADJ 	
			ER_OBS_AD_ADJ ER_AD_ADJ OBS_AD_ADJ ER_AND_OBS_AD_ADJ NO_ER_NO_OBS_AD_ADJ
			OBS_STAYS_ADJ OBS_ER_ADJ OBS_NO_ER_ADJ ER_NO_AD_OBS_ADJ R_ONC_ADJ PHY_SRVC_ADJ 
			PHY_ONC_ADJ PHY_OTH_ADJ ANC_TOT_ADJ ANC_LAB_TOT_ADJ ANC_LAB_ADV_ADJ ANC_LAB_OTHER_ADJ 		
			ANC_IMAG_TOT_ADJ ANC_IMAG_ADV_ADJ ANC_IMAG_OTH_ADJ OUT_OTHER_ADJ HHA_ADJ SNF_ADJ
			LTC_ADJ IRF_ADJ HSP_TOT_ADJ HSP_FAC_ADJ HSP_HOME_ADJ HSP_BOTH_ADJ DME_NO_DRUGS_ADJ 
			PD_TOT_ADJ 	PD_PTB_PHYDME_ADJ PD_PTB_OUT_ADJ PD_PTD_ALL_ADJ OTHER_ADJ INP_ADMSNS_UTIL 
			INP_EX_UTIL INP_AMB_UTIL UNPLANNED_READ_UTIL ER_OBS_AD_UTIL ER_AD_UTIL 	OBS_AD_UTIL
			ER_AND_OBS_AD_UTIL NO_ER_NO_OBS_AD_UTIL OBS_STAYS_UTIL OBS_ER_UTIL OBS_NO_ER_UTIL
			ER_NO_AD_OBS_UTIL R_ONC_UTIL PHY_SRVC_UTIL PHY_ONC_UTIL PHY_OTH_UTIL ANC_LAB_TOT_UTIL
			ANC_LAB_ADV_UTIL ANC_LAB_OTHER_UTIL ANC_IMAG_TOT_UTIL ANC_IMAG_ADV_UTIL ANC_IMAG_OTH_UTIL
			HHA_UTIL SNF_UTIL LTC_UTIL IRF_UTIL HSP_UTIL  ;
	output out=sumz(drop = _freq_ _type_)
		   sum() =  ;

proc means data= EPI_Q noprint max; by bene_id ep_id ;
	where maxi = 1 ;
	var BR_KADYCLA BR_AVASTIN	BR_AFINITOR BR_NEULASTA BR_PERJATA BR_HEPCEPTIN	PR_ZYTIGA 
		PR_JEVTANA PR_XTANDI PR_PROVENGE LU_GILOTRIF
		LU_TECENTRIQ LU_AVASTIN LU_TARCEVA LU_OPDIVO LU_ABRAXANE LU_NEULASTA LU_KEYTRUDA
		LU_ALIMTA LY_TREANDA LY_VELCADE LY_IMBRUVICA LY_REVLIMID LY_OPDIVO LY_NEULASTA LY_KEYTRUDA
		LY_RITUXAN IC_AVASTIN IC_XELODA IC_ERBITUX IC_VECTIBIX IC_NEULASTA IC_KEYTRUDA IC_ZALTRAP
		MU_VELCADE MU_KYPROLIS MU_DARZALEX MU_REVLIMID BL_TECENTRIQ BL_OPDIVO HN_ERBITUX
		HN_OPDIVO HN_KEYTRUDA MA_COTELLIC MA_TAFINLAR MA_YERVOY MA_OPDIVO MA_KEYTRUDA MA_MEKINIST
		MA_ZELBORAF BR_ABRAXANE BR_IBRANCE ;
	output out=maxiz (drop = _type_ _Freq_)
		max() =  ;

proc means data=EPI_Q noprint max ; by bene_id ep_id ;
	where ertrig = 1 ;
	var EM_VISITS EM_VISITS_ALL ;
	output out=erviz (drop = _type_ _freq_)
		   max() = ;

********************************************************************** ;
********************************************************************** ;

**** Create Episode Files for Interface. **** ;

proc sort data=tax ; by bene_id ep_id ;
data epi2a ;
	merge out.episodes_&type.&vers._&dsid.  (in=a)
		  tax (keep = bene_id ep_id epi_tax_id) 
		  taxnpi (keep = bene_id ep_id epi_npi_id) 
		  sumz maxiz erviz ; 
	by bene_id ep_id ;
	if a ;
DATA OUT.episodes_final_&type.&vers._&dsid.;
	SET EPI2A ;
	%CANCer_remap(CANCER_TYPE) ;
	%CANCer_remap(CANCER_TYPE_A) ;
	IF EP_BEG = EP_BEG_A THEN CANCER_TYPE = CANCER_TYPE_A ;
	
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
	*** added 11/20/18 *** ;
	if cancer = "Essential (hemorrhagic) thrombocythemia" then cancer = "Essential thrombocythemia" ;

	
		CANCER_TYPE_MILLIMAN = CANCER ; 
	IF ATTRIBUTE_FLAG IN ('1','2') AND CANCER NE CANCER_TYPE_A THEN DO ;
		*** flag indicates matches episodes start date, mismatches cancer *** ;
		if attribute_flag = '1' then attribute_flag = '3' ; 
		*** flag indicates mismatches on episodes start date and cancer type *** ;
		if attribute_flag = '2' then attribute_flag = '5' ; 
		CANCER_TYPE_MILLIMAN = CANCER_TYPE_A ;
	end ;


	IF CANCER_TYPE_MILLIMAN = '  ' THEN CANCER_TYPE_MILLIMAN = CANCER_TYPE ;
	IF CANCER_TYPE_MILLIMAN = '  ' THEN CANCER_TYPE_MILLIMAN = CANCER_TYPE_A ; ** (Episodes w Attribute Flag D,0) ;

	**** Place Holders for additional checks. **** ;
	RECON_Elig_Invalid = 0 ; **** Harsha or Mona can program to check cancer_type against what is in file. ****
							 **** Assign to 1 when CMS indication is not correct.						   **** ;
	
	DUAL_INVALID = 0 ; **** Meant to evaluate accuracy of DUAL_PTD_LIS assignment.  Unable to do this 	   **** 
					   **** screen yet as enrollment data is not provided. 								   **** ;

	INST_INVALID = 0 ; *** Unable to validate this as we do not get claims prior to episode.			   **** ;

	*if RADIATION NE RADTHER THEN Rad_Invalid = 1 ; 
	*else Rad_Invalid = 0 ;  
	RADIATION_MILLIMAN = RADTHER ; DROP RADTHER ;

	*HCC_GRP_MILLIMAN = HCC_GRP ; *** Will need to add coding for this. *** ;
	*HCC_Nomatch = 0 ;  **** Accuracy of HCC count flag.  Christine to program.							   **** ;

	*if SURGERY ne has_surgery then SURG_INVALID = 1 ;
	*else SURG_INVALID = 0 ;

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

	*** Field not provided.		   **** ;
	HRR_REL_COST_MILLIMAN = 0 ;
	HRR_REL_COST = 0 ;
	*if CLINICAL_TRIAL NE CLINICAL_TRIAL_MILL THEN CT_Invalid = 1 ;
	*ELSE CT_Invalid  = 0 ;   
	CLINICAL_TRIAL_MILLIMAN = MAX(CLINICAL_TRIAL_MILL,0) ; DROP CLINICAL_TRIAL_MILL ;

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
	IF CANCER_TYPE_MILLIMAN = "Chronic Leukemia" THEN DO ;
		BMT_ALLOGENEIC_CL  = BMT_ALLOGENEIC ; BMT_AUTOLOGOUS_CL = BMT_AUTOLOGOUS;
	end ;

	if ctype notin ("Acute Leukemia","Lymphoma","MDS","Multiple Myeloma","Chronic Leukemia") then BMT_Milliman = 4 ;
	else do ;
		array al (b) BMT_ALLOGENEIC_L BMT_ALLOGENEIC_AK BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL ;
		array au (b) BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_AK BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL ;
		array bm (b) BM_L BM_AK BM_MM BM_MDS BM_CL ;
		do b = 1 to 5 ;
			if al = 1 and au = 1 then BM = 3 ;
			else if al = 1 then BM = 2 ;
			else if au = 1 then BM = 1 ;
			else BM = 0 ;
		end ;
	if ctype = "Acute Leukemia" then BMT_MILLIMAN = BM_AK ;
	if ctype = "Lymphoma" then BMT_MILLIMAN = BM_L ;
	if ctype = "MDS" then BMT_MILLIMAN = BM_MDS ;
	if ctype = "Multiple Myeloma" then BMT_MILLIMAN = BM_MM ;
	IF CTYPE = "Chronic Leukemia" then BMT_MILLIMAN = BM_CL ;
	end ;
	
	*** Will not be able to check the CLEAN_PERIOD variable. *** ;
	
	*if PTD_CHEMO ne PARTDONLY then chemod_invalid = 1 ; 
	*else chemod_invalid = 0 ; *** PARTDONLY used to compare to PTD_CHEMO ; **** Accuracy of Part D Chemo flag.  **** ;
	PTD_CHEMO_MILLIMAN = PARTDONLY ; DROP PARTDONLY ;

	ACTUAL_EXP_BENE = ALL_TOS ;

	*** Dummy variables for Util Variables *** ;
	IP_UTIL = 0 ; SNF_UTIL = 0 ; HH_UTIL = 0 ; HSP_UTIL = 0  ; FAC_UTIL = 0 ;
	CHEMO_D_UTIL = 0 ; CHEMO_B_UTIL = 0 ; RAD_ONC_UTIL = 0 ; CHEMO_DAYS_PARTB = 0 ; PROF_UTIL = 0 ;
	RAD_ONC_DAYS = 0 ; CHEMO_LENGTH_PARTB = 0 ; RAD_ONC_LENGTH = 0 ;


	
run ;

********************************************************************** ;
********************************************************************** ;

**** Create Claim flags for Episode level interface. **** ;

proc sort data=OUT.episodes_final_&type.&vers._&dsid.; by bene_id ep_id ;
proc sort data=chemo_candidates1 out=c1(keep=bene_id trigger_date ) nodupkey ; by bene_id ;
proc sort data=chemo_candidates2 out=c2(keep=bene_id trigger_date) nodupkey ; by bene_id ;
proc sort data=chemo_candidates3_cand out=c3(keep=bene_id trigger_date) nodupkey ; by bene_id ;

proc sql ;
	create table c1a as 
	select a.ep_id, b.bene_id, b.trigger_date 
 	from OUT.episodes_final_&type.&vers._&dsid. as a, c1 as b
	where a.bene_id=b.bene_id and
       a.ep_beg le trigger_date le a.ep_end ;
	create table c2a as 
	select a.ep_id, b.bene_id, b.trigger_date 
 	from OUT.episodes_final_&type.&vers._&dsid. as a, c2 as b
	where a.bene_id=b.bene_id and
       a.ep_beg le trigger_date le a.ep_end ;
	create table c3a as 
	select a.ep_id, b.bene_id, b.trigger_date 
 	from OUT.episodes_final_&type.&vers._&dsid. as a, c3 as b
	where a.bene_id=b.bene_id and
       a.ep_beg le trigger_date le a.ep_end ;

data check(keep = bene_id ep_id c1 c2 c3) ;
	merge OUT.episodes_final_&type.&vers._&dsid.(in=a keep=bene_id ep_id) 
		  c1a(in=b) c2a(in=c) c3a(in=d) ; by bene_id ep_id;
		if a ;
		c1=0 ; c2 = 0 ; c3= 0 ;
		if a and b then c1 = 1 ;
		if a and c then c2 = 1 ;
		if a and d then c3 = 1 ;
	

proc sort data=check ; by bene_id ep_id;
proc means data=check noprint max ; by bene_id ep_id ;
	var c1 c2 c3 ;
	output out=chemo_chk(drop = _type_ _freq_)
		   max() = ;
**** Number of chemo days per episode *** ;
proc sql ;
	create table chemo_daysx as
	select a.ep_id, b.*
	from epi_orig as a, chemo_days as b
	where a.bene_id = b.bene_id and
       a.ep_beg le  trigger_date le a.ep_end ;


proc sort data=chemo_daysx ; by bene_id ep_id ;
proc means data = chemo_daysx noprint min max sum ; by  bene_id ep_id ;
	var trigger_date counter perf_chemo perf_count ;
	output out=days (drop=_type_ _freq_)
		   min(trigger_date perf_chemo ) = chemo_start pchemo_start
		   max(trigger_date perf_chemo ) = chemo_end  pchemo_end
		   sum(counter perf_count) = chemo_days pchemo_days ;
data days ; set days ;	format chemo_start chemo_end pchemo_start pchemo_end mmddyy10. ;

run ;

********************************************************************** ;
********************************************************************** ;

*** Added 1/8/18 - Creates EPI_ATT_TIN which assigns attributed episodes to the practice
	and overrides Milliman assignment *** ;
PROC SORT DATA=OUT.episodes_final_&type.&vers._&dsid.	OUT=FINAL ; BY  BENE_ID EP_BEG ;

DATA ATT (KEEP = BENE_ID EP_BEG);
	SET &in_ATT. ;
	EP_BEG = EP_BEG_A ;
PROC SORT DATA=ATT  NODUPKEY ; BY BENE_ID EP_BEG ;

DATA FINAL2 ;
	MERGE FINAL(IN=A) ATT(IN=C) ; BY BENE_ID EP_BEG ;
	IF A ;
	EPI_ATT_TIN = EPI_TAX_ID ;
	IF A AND C THEN DO ;
		%IF "&ocm." = "290" %THEN %do ;
			IF EPI_TAX_ID notin (&att_tin.) THEN EPI_ATT_TIN = '540647482' ;
		 %END ;
		 %ELSE %DO ;
			IF EPI_TAX_ID notin (&att_tin.) THEN EPI_ATT_TIN = &att_tin. ;
		%END ;
	END ;
RUN ;

PROC SORT DATA=FINAL2 ; BY BENE_ID EP_ID ; RUN ;

********************************************************************** ;
********************************************************************** ;

*** Create file to present for interface. *** ;
data out.epi_prelim_&type.&vers._&dsid. ;
	merge FINAL2(in=a) chemo_chk days;
	by bene_id ep_id ;
	if a ;
	CHEMO_B_UTIL = 0 ; CHEMO_D_UTIL = 0 ; CHEMO_DAYS_PARTB = 0 ; CHEMO_LENGTH_PARTB = 0 ;
	if sum(c1,c2) > 0 then CHEMO_B_UTIL = 1 ;
	if c3 > 0 then CHEMO_D_UTIL = 1 ;
	CHEMO_DAYS_PARTB = CHEMO_DAYS ;
	CHEMO_LENGTH_PARTB = sum(chemo_start-chemo_end,1) ;

	IF SEX = "M" THEN SEX = "1" ;
	IF SEX = "F" THEN SEX = "2" ;

	**** Episodes not expected to be found in PP1 reconciliation file **** ;
	if ep_beg gt mdy(1,1,2017) then RECON_PP1_FLAG = 0 ;

	*** Data Coverage Flag *** ;
	DATA_COVERAGE = 1 ; *** Indicates full data coverage with demographics available. *** ;
	*** Indicates Gaps in Data Coverage *** ;
	%if "&vers." = "A" %then %do ;
      IF sum(Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9)=0 and Q10=1   													THEN DATA_COVERAGE = 2 ;
    %end ;

	/*IF SUM(Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9) = 0	and q10=1 AND 			(DOD = . OR DOD > MDY(12,31,2018)) 	THEN DATA_COVERAGE = 3 ;*/
	IF SUM(Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8) = 0	and q9=1 AND 			(DOD = . OR DOD > MDY(09,30,2018)) 	THEN DATA_COVERAGE = 3 ;
	IF SUM(Q1,Q2,Q3,Q4,Q5,Q6,Q7) = 0	and q8=1 AND 			(DOD = . OR DOD > MDY(06,30,2018)) 	THEN DATA_COVERAGE = 3 ;
	IF SUM(Q1,Q2,Q3,Q4,Q5,Q6) = 0 		and q7=1 AND q8=0 AND 	(DOD = . OR DOD > MDY(03,31,2018)) 	THEN DATA_COVERAGE = 3 ;
	IF SUM(Q1,Q2,Q3,Q4,Q5) = 0 			AND q6=1 AND q7=0 AND 	(DOD = . OR DOD > MDY(12,31,2017)) 	THEN DATA_COVERAGE = 3 ;
	IF SUM(Q1,Q2,Q3,Q4) = 0 			AND q5=1 AND q6=0 AND 	(DOD = . OR DOD > MDY(09,30,2017)) 	THEN DATA_COVERAGE = 3 ;
	IF Q1 = 0 AND Q2 = 0 AND  Q3 = 0 AND Q4 = 1 and q5=0 AND (DOD = . OR DOD > MDY(6,30,2017)) 		THEN DATA_COVERAGE = 3 ;
	IF Q1 = 1 AND SUM(Q2,Q3) IN (.,0) AND (DOD = . OR DOD > MDY(9,30,2016)) THEN DATA_COVERAGE = 3 ;
	IF Q1 = 0 AND Q2 = 1 AND Q3 = 0 AND (DOD = . OR DOD > MDY(12,31,2016)) THEN DATA_COVERAGE = 3 ;
	IF Q1 = 0 AND Q2 = 0 AND Q3 = 1 AND Q4 = 0 AND (DOD = . OR DOD > MDY(3,31,2017)) THEN DATA_COVERAGE = 3 ;
	IF Q1 = 0 AND Q2 = 0 AND Q3 = 0 AND Q4 = 1 AND q5 = 0 and (DOD = . OR DOD > MDY(6,30,2017)) THEN DATA_COVERAGE = 3 ;
	
	IF ATTRIBUTE_FLAG = "D" THEN EPI_ATT_TIN = 'XXXXXXXXX' ;

PROC FREQ DATA=out.epi_prelim_&type.&vers._&dsid. ;
	TABLES DATA_COVERAGE attribute_flag recon_pp1_flag ;
	tables CHEMO_IN_PP*ATTRIBUTE_FLAG/list missing ;
TITLE "&dsid. Fields SHOULD BE 100% POPULATED" ; RUN ;

%if "&vers." = "B" %then %do ;
PROC FREQ DATA=out.epi_prelim_&type.&vers._&dsid. ;
	TABLES SEX ;
TITLE "&dsid. Fields SHOULD BE 100% POPULATED" ; RUN ;
%end ;

PROC FREQ DATA=out.epi_prelim_&type.&vers._&dsid. ;
	TABLES CANCER_TYPE_MILLIMAN*BMT_MILLIMAN/LIST MISSING ;
	TABLES CANCER_TYPE_MILLIMAN*CLINICAL_TRIAL_MILLIMAN/LIST MISSING ; 
	TABLES CANCER_TYPE_MILLIMAN*surgery_MILLIMAN/LIST MISSING ; 
	tables in_recon/LIST MISSING  ;
TITLE "&dsid. Check Key Variables" ; RUN ;

proc print data=out.epi_prelim_&type.&vers._&dsid. ;
	where ep_beg = .  ; 
TITLE "&dsid. Should have zero records - All episodes should be assigned a begin date" ; RUN ;

PROC SORT DATA=OUT.EPI_PRELIM_&type.&vers._&DSID. ; BY EP_ID ;

%if "&vers." = "B" %then %do ;
proc print data=out.epi_prelim_&type.&vers._&dsid. ;
	where BENE_HICN = "  "   ; 
TITLE "&dsid. Should have zero records - All episodes should be assigned a BENE_HICN" ; RUN ;
%end ;
run ;

%mend epi ;
********************************************************************** ;
********************************************************************** ;
***** %macro epi(dsid,nmd,ocm) ;
***** NMD:
			0 = only q1, q2 available
			1 = all quarters available
		    2 = only q1, q2 available
		    3 = only q3 and q4 available
	  OCM = 3 digit OCM id
********************************************************************** ;
********************************************************************** ;

%let att_tin = '454999975' ; run ;
%epi(255_50179,1,255) ; run ;

%let att_tin = '636000526' ;run ;
%epi(257_50195,1,257) ; run ;

%let att_tin = '134290167' ;run ;
%epi(278_50193,1,278) ; run ;

%let att_tin = '731310891' ;run ;
%epi(280_50115,1,280) ; run ; 

%let att_tin = '540647482','540793767','541744931','311716973' ;run ;
%epi(290_50202,1,290) ; run ;

%let att_tin = '571004971' ;run ;
%epi(396_50258,1,396) ; run ;

%let att_tin = '205485346' ;run ;
%epi(401_50228,1,401) ; run ; 

%let att_tin = '204881619' ;run ;
%epi(459_50243,1,459) ; run ; 

%let att_tin = '621490616' ;run ;
%epi(468_50227,1,468) ; run ; 

%let att_tin = '201872200' ;run ;
%epi(480_50185,1,480) ; run ;

%let att_tin = '596014973' ;run ;
%epi(523_50330,1,523) ; run ;

%let att_tin = '223141761' ;run ;
%epi(137_50136,1,137) ; run ; 

************************************************************************** ;
****************** Cancer Type Report ************************************ ;
************************************************************************** ;
/*
Data All(keep = cancer_type_milliman) ;
	set out.epi_prelim_&type.&vers._523_50330
		out.epi_prelim_&type.&vers._137_50136
		out.epi_prelim_&type.&vers._255_50179
		out.epi_prelim_&type.&vers._257_50195
		out.epi_prelim_&type.&vers._278_50193
		out.epi_prelim_&type.&vers._280_50115
		out.epi_prelim_&type.&vers._290_50202
		out.epi_prelim_&type.&vers._396_50258
		out.epi_prelim_&type.&vers._480_50185
		out.epi_prelim_&type.&vers._401_50228
		out.epi_prelim_&type.&vers._468_50227
		out.epi_prelim_&type.&vers._459_50243 ;

proc freq data=all noprint ;
	tables cancer_type_milliman/out=cancer_dist ;
proc export data=cancer_dist
	outfile = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Performance\cancer_dist"
	dbms=xlsx replace ;
	quit ;
*/

run ;

