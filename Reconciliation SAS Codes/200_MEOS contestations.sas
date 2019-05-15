********************************************************************** ;
****************** Data for recon/meos contests ********************** ;
********************************************************************** ;

options ls=132 ps=70 obs=max mprint mlogic; run ;

libname mar19 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Performance\Mar19" ;
libname perf "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Performance"; 
libname main "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\80 - QlikView\Qlik_Sasout" ;
libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\MEOS";
libname ref "H:\Nonclient\Medicare Bundled Payment Reference\General\SAS Datasets" ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Cancer Diagnoses_5.sas";
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Cancer Formats PP3.sas";
%include "H:\_HealthLibrary\SAS\000 - General SAS Macros.sas";
%let exportDir=R:\data\HIPAA\OCM_Oncology_Care_Model_PP\80 - QlikView\outfiles\MEOS Recoupment;
%let set_name = p5b;

proc format; value $EMClaim
'99201' = 'Y'
'99202' = 'Y'
'99203' = 'Y'
'99204' = 'Y'
'99205' = 'Y'
'99211' = 'Y'
'99212' = 'Y'
'99213' = 'Y'
'99214' = 'Y'
'99215' = 'Y'
other = 'N'
;
run;

proc format; value $CM2016_
'99490' = 'Y'
'99495' = 'Y'
'99496' = 'Y'
'99374' = 'Y'
'99375' = 'Y'
'99377' = 'Y'
'99378' = 'Y'
'90951' = 'Y'
'90970' = 'Y'
other = 'N';
run;

proc format; value $CM2017_
'99358' = 'Y'
'99359' = 'Y'
'99487' = 'Y'
'99489' = 'Y'
'G0506' = 'Y'
'G0507' = 'Y'
other = 'N';
run;

proc format; value $CM2018_
'G0179' = 'Y'
'G0180' = 'Y'
'G0181' = 'Y'
'G0182' = 'Y'
other = 'N';
run;

%MACRO readinPP(PP);

%if &PP. = PP3 %then %do;
	%let MEOSfolder = R:\data\HIPAA\OCM_Oncology_Care_Model_PP\05 - MEOS Recoupment Reports\PP3;
	%let trueup = initial;
%end;
%else %if &PP. = PP2 %then %do;
	%let MEOSfolder = R:\data\HIPAA\OCM_Oncology_Care_Model_PP\05 - MEOS Recoupment Reports\PP2 True-up 1;
	%let trueup = trueup1;
%end;
%else %if &PP. = PP1 %then %do;
	%let MEOSfolder = R:\data\HIPAA\OCM_Oncology_Care_Model_PP\05 - MEOS Recoupment Reports\PP1 True-up 2;
	%let trueup = trueup2;
%end;

	**read in MEOS recoupment data**;
	%MACRO readin(OCMID, OCMID2, Date);

		libname wrkbk excel 
			"&MEOSfolder.\OCM_&OCMID._&OCMID2._MEOSRecoupmentReport_&PP.&trueup._&date..xlsx"
			header=no
			mixed=yes;

		data set_MEOS_&PP._&OCMID. ;
			format OCM_ID $3.;
				OCM_ID = &OCMID.;
			set wrkbk.'MEOS$'n (firstobs=8);
		run; 

		data MEOS_&PP._&OCMID. ;
			set set_MEOS_&PP._&OCMID.;
				 	HICN = F1 ;
				   	MBI = F2 ;
					CCW_Beneficiary_ID = F3;
					OCM_Episode_ID = F4;
					First_Name = F5;
					Last_Name = F6;
					DOB = input(F7, mmddyy10.); 
					CCW_Claim_ID = F8;
					Claim_Control_Number = F9;
					Service_Date = input(F10, mmddyy10.); 
					Procedure_Code = F11;
					Performing_NPI = F12;
					TIN = F13;
					Claim_Line_Number = input(F14, best12.);
					Payment_Amount = input(F15, dollar8.);
					Recoupment_Reason = F16;
					Recoupment_Reason_Detail = F17;
		run; 

		data set_CM_&PP._&OCMID. ;
			format OCM_ID $3.;
				OCM_ID = &OCMID.;
			set wrkbk.'Management Services$'n (firstobs=8);
		run;

		data CM_&PP._&OCMID. ;
			set set_CM_&PP._&OCMID.;
				 	HICN = F1 ;
				   	MBI = F2 ;
					CCW_Beneficiary_ID = F3;
					OCM_Episode_ID = F4;
					First_Name = F5;
					Last_Name = F6;
					DOB = input(F7, mmddyy10.);
					CCW_Claim_ID = F8;
					Claim_Control_Number = F9;
					Service_Date = input(F10, mmddyy10.); 
					Procedure_Code = F11;
					Performing_NPI = F12;
					TIN = F13;
					Claim_Line_Number = input(F14, best12.);
					Payment_Amount = input(F15, dollar8.);
					Recoupment_Reason = F16;
		run;	

%MEND readin;

	%readin(137, 50136, 20190228); 
	%readin(255, 50179, 20190228); 
	%readin(257, 50195, 20190228);
	%readin(278, 50193, 20190228);
	%readin(280, 50115, 20190228);
	%readin(290, 50202, 20190228);
	%readin(396, 50258, 20190228);
	%readin(401, 50228, 20190228);
	%readin(459, 50243, 20190228);
	%readin(468, 50227, 20190228);
	%readin(480, 50185, 20190228);
	%readin(523, 50330, 20190228);

%MEND readinPP;

/*%readinPP(PP3);*/
/*%readinPP(PP2);*/
/*%readinPP(PP1);*/

%MACRO stackfile(file);
	data out.&file. ;
		set &file._PP1: (in = a) 
			&file._PP2: (in = b)
			&file._PP3: (in = c) ; 

		where Recoupment_Reason ^= '';

		%if &file. = MEOS %then %do;
			drop F1-F21; 
		%end;
		%else %do;
			drop F1-F16;
		%end;
 
		format perf_period $3. MBI_HICN Episode_BENE_ID $25. Patient_Name $75.;
			if a then perf_period = 'PP1';
			if b then perf_period = 'PP2';
			if c then perf_period = 'PP3';

		MBI_HICN 		= coalescec(MBI, HICN);
		Episode_Bene_ID = coalescec(OCM_Episode_ID, CCW_Beneficiary_ID);
		Patient_Name 	= trim(propcase(Last_Name)) ||', '|| trim(propcase(First_Name));


		format DOB_use Service_Date_use mmddyy10.;
		DOB_use = dob;
		Service_Date_use = Service_Date;
run;

%MEND stackfile;

/*%stackfile(MEOS);*/
/*%stackfile(CM);*/


/*%sas_2_csv(out.MEOS,MEOSRecoupments.csv);*/


* Macro copied from H:\OCM - Oncology Care Model\44 - Oncology Care Model 2018\Work Papers\SAS\C002p_Episode Identification_Oct18.sas*;
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

*check deduped reasons to use later in code*;
/*proc sql;*/
/*	create table reasons as*/
/*	select distinct Recoupment_Reason, Recoupment_Reason_Detail*/
/*	from MEOS;*/
/*quit;*/

data MEOS_flags;
	set out.MEOS out.CM;

	no_episode = 0; 
		no_chemo = 0 ; no_cancer_diag = 0 ; no_qual_chemo = 0;
		ESRD = 0; MSP = 0; no_AB = 0; no_EM = 0; not_FFS = 0;
	not_attributed = 0;
		tiebreak_tin = 0; fewer_EM = 0;
	dup_payment = 0;
	MEOS_hospice = 0;
	MEOS_90day = 0;
	MEOS_6plus = 0;
	MEOS_after_death = 0;
	MEOS_CM_dup = 0;
	cant_validate = 0;

	*Recoupment Reason 1*; 
	if Recoupment_Reason = 'Beneficiary did not have a PP1 episode' 
	or Recoupment_Reason = 'Beneficiary did not have a PP2 episode' 
	or Recoupment_Reason = 'Beneficiary did not have a PP3 episode' then do;
		no_episode = 1 ; 
		if Recoupment_Reason_Detail = 'No Part B or Part D OCM initiating chemotherapy found.' then no_chemo = 1;
		else if Recoupment_Reason_Detail = 'Part B OCM initiating chemotherapy was found in PP1, but no cancer diagnosis was found on the chemotherapy claim.'
			 or Recoupment_Reason_Detail = 'Part B OCM initiating chemotherapy was found in PP2, but no cancer diagnosis was found on the chemotherapy claim.'
			 or Recoupment_Reason_Detail = 'Part B OCM initiating chemotherapy was found in PP3, but no cancer diagnosis was found on the chemotherapy claim.' then no_cancer_diag = 1;
		else if Recoupment_Reason_Detail = 'Part D OCM initiating chemotherapy was found in PP1, but no qualifying part B cancer claim was found on the prescription fill date or in the 59 days prior.'
			 or Recoupment_Reason_Detail = 'Part D OCM initiating chemotherapy was found in PP2, but no qualifying part B cancer claim was found on the prescription fill date or in the 59 days prior.'
			 or Recoupment_Reason_Detail = 'Part D OCM initiating chemotherapy was found in PP3, but no qualifying part B cancer claim was found on the prescription fill date or in the 59 days prior.' then no_qual_chemo = 1;
		else if index(Recoupment_Reason_Detail, 'however the beneficiary was on ESRD for some part of the 6 months following.') then ESRD = 1;
		else if index(Recoupment_Reason_Detail, 'however the beneficiary did not have Medicare as Primary Payer for all 6 months following.') then MSP = 1;
		else if index(Recoupment_Reason_Detail, 'however the beneficiary did not have both Medicare Parts A and B for all 6 months following.') then no_AB = 1;
		else if index(Recoupment_Reason_Detail, 'however there was no E&M visit in the 6 months following.') then no_EM = 1;
		else if index(Recoupment_Reason_Detail, 'however the beneficiary was enrolled in a group health plan for some part of the 6 months following.') then not_FFS = 1;
	end;
	*Recoupment Reason 2*;		
	else if Recoupment_Reason = 'Beneficiary was not attributed to your practice in PP1'
		 or Recoupment_Reason = 'Beneficiary was not attributed to your practice in PP2'
		 or Recoupment_Reason = 'Beneficiary was not attributed to your practice in PP3' then do;
			not_attributed = 1 ;
		if index(Recoupment_Reason_Detail, 'This beneficiary had no qualifying E&M visits for cancer to your practice') then no_EM = 1;
		else if index(Recoupment_Reason_Detail, 'tie-breaker') then tiebreak_tin = 1;
		else if index(Recoupment_Reason_Detail, ' E&M visit(s) for cancer to your practice and ')  then fewer_EM = 1;
	end;

	*Recoupment Reason 3*;		if Recoupment_Reason = 'Duplicate payment in calendar month' then dup_payment = 1 ;
	*Recoupment Reason 4*;		else if Recoupment_Reason = 'MEOS payment during Hospice' then MEOS_hospice = 1 ;
	*Recoupment Reason 5*;		else if Recoupment_Reason = 'MEOS payment more than 90 days before PP1 episode beginning date' 
									 or Recoupment_Reason = 'MEOS payment more than 90 days before PP2 episode beginning date'
									 or Recoupment_Reason = 'MEOS payment more than 90 days before PP3 episode beginning date' then MEOS_90day = 1 ;
	*Recoupment Reason 6*;		else if index(Recoupment_Reason, 'More than six MEOS payments made in the allowable MEOS billing period') then MEOS_6plus = 1 ;
	*Recoupment Reason 7*;		else if Recoupment_Reason = 'MEOS payment after death date' then MEOS_after_death = 1;
	*Recoupment due to CM*;		else if Recoupment_Reason = 'Duplicate management services and MEOS billing' then MEOS_CM_dup = 1;

	if ESRD = 1 or MSP = 1 or no_AB = 1 or not_FFS = 1 then cant_validate = 1;
	drop ESRD MSP no_AB not_FFS;
run;

********TESTING VARIABLES********;
%let OCM_ID = 137;
%let OCM_ID2 = 50136;
%let PP = 'PP2';
%let OCM_tin = '223141761' ;
*********************************;

%MACRO MEOS(OCM_ID, OCM_ID2, PP, PPvar);

*identify episodes that these MEOS payments are associated with *;
data MEOS_subset_pre;
	set MEOS_flags;
	if OCM_ID = &OCM_ID. and perf_period = &PP.;
run;

proc sql;
	create table episode_subset as
	select * from main.epi_detail_combined_&set_name._&OCM_ID.
	where BENE_ID in (select distinct CCW_Beneficiary_ID from MEOS_subset_pre)
	and EPISODE_PERIOD_USE = &PP.
;
quit;

*get key episode info on MEOS subset table*;
proc sql;
	create table MEOS_subset as
		select a.*
			, b.ep_id_use
			, b.epi_tin_match_use
			, b.attrib_flag_use
			, b.EP_BEG
			, b.EP_END
			, b.EMERGE_CHEMO_CLAIM
			, b.EMERGE_EM_CLAIM
			, b.EM_ATT_TAX_USE as EMVisits_Attrib_TIN
			, b.EM_NONATT_TAX as EMVisits_Other_TINs
			, b.DOD
		from MEOS_subset_pre as A
		left join episode_subset as B
			on A.CCW_Beneficiary_ID = b.BENE_ID
;
quit;

*stack emerge & main claims *;
data claims_stacked;
	set main.clm_detail_interface_&set_name._&OCM_ID.
		main.clm_detail_emerge_&set_name._&OCM_ID. ;
run;

*subset claims*;
proc sql;
	create table claims_subset_0 as
	select * from claims_stacked
	where ep_id2 in (select distinct ep_id_use from episode_subset)
;
quit;

*get bene_id as personal identifier*;
proc sql;
	create table claims_subset as
		select a.*, b.BENE_ID, b.EP_BEG, b.EP_END, b.DOD
		from claims_subset_0 as A
		left join episode_subset as B
			on a.ep_id2 = b.ep_id_use
;
quit;

******************************* RECOUPMENT REASON #1 *********************************;
*identify MEOS payments that are not associated with an episode at the given practice*;
*then identify the detailed reason*;

*flag main milliman episodes as no_episode_milliman*;
*also flags emerging episodes as no_episode_milliman*;
proc sql;
	create table nomain_episode_subset as
	select *, 1 as no_episode_milliman from MEOS_subset
	where CCW_Beneficiary_ID not in (select distinct BENE_ID 
					   from main.epi_detail_combined_&set_name._&OCM_ID.
					   where EPISODE_PERIOD_USE = &PP.
					   and EPISODE_TYPE = 'Yes - Main Interface')
;
quit;

*flag emerging milliman episodes for no_chemo_milliman and no_EM_milliman*;
data no_episode_subset;
	set nomain_episode_subset;

	if EMERGE_CHEMO_CLAIM ^= '' then do;
		EMERGE_EPISODE = 1;
		if EMERGE_CHEMO_CLAIM = 'No' then no_chemo_milliman_emerge = 1;
		else if EMERGE_CHEMO_CLAIM = 'Yes' then no_chemo_milliman_emerge = 0;
	end;

	if EMERGE_EM_CLAIM ^= '' then do;
		EMERGE_EPISODE = 1;
		if EMERGE_EM_CLAIM = 'No' then no_EM_milliman_emerge = 1;
		else if EMERGE_EM_CLAIM = 'Yes' then no_EM_milliman_emerge = 0;
	end;

run;

*flag main milliman episodes with no_chemo_milliman*;
proc sql;
	create table claims_subset_reason1 as
		select * from claims_subset
		where BENE_ID in (select distinct BENE_ID from no_episode_subset
							where EMERGE_EPISODE ^= 1)
;
quit;

data reason1_chemoclaims;
	set claims_subset_reason1;
	where label3 in ('Part B Chemo: Biologic' 
					 'Part B Chemo: Cytotoxic' 
					 'Part B Chemo: Hormonal'
					 'Part B Chemo: Novel Therapy'
					 'Part B Chemo: Other'
					 'Part D Chemo: Biologic' 
					 'Part D Chemo: Cytotoxic' 
					 'Part D Chemo: Hormonal'
					 'Part D Chemo: Novel Therapy'
					 'Part D Chemo: Other');
	chemo_claim = 1;
run;

proc sql;
	create table noepisode_nochemoclaim as
		select a.*
			, case when b.chemo_claim = . and EMERGE_EPISODE ^= 1 then 1
				else 0 end as no_chemo_milliman_main
		from no_episode_subset as A
		left join reason1_chemoclaims as B
			on a.CCW_Beneficiary_ID = b.BENE_ID
			and a.EP_BEG = b.start_date_use
;
quit;

*flag main milliman episodes with no_EM_milliman*;
data reason1_EMclaims_0;
	set claims_subset_reason1;
	where put(HCPCS_CD, $EMclaim.) = 'Y';

	%canc_init;
	%CANCERTYPE(0, PRINCIPAL_DIAG_CD); 
	%null_canc;

	if has_cancer = 1 and trim(TAX_NUM) in (&OCM_tin.) then EM_claim = 1;
		else EM_claim = 0;
run;

*take max of EM_claim by bene_id and ep_id_use then join below*;
proc sql;
	create table reason1_EMclaims as
	select BENE_ID, ep_id2, start_date_use, max(EM_claim) as EM_claim
	from reason1_EMclaims_0
	group by BENE_ID, ep_id2, start_date_use
;
quit;

proc sql;
	create table noepisode_noEMclaim as
		select a.*
			, case when a.EP_BEG = . then 1
				when b.EM_claim = 0 and EMERGE_EPISODE ^= 1 then 1
				else 0 end as no_EM_milliman_main
		from noepisode_nochemoclaim as A
		left join reason1_EMclaims as B
			on a.CCW_Beneficiary_ID = b.BENE_ID
			and a.EP_BEG <= b.start_date_use <= a.EP_END
;
quit;

proc sort data = noepisode_noEMclaim nodupkey;
	by CCW_beneficiary_ID OCM_Episode_ID Claim_Control_Number Service_Date;
run;

data noepisode_flags_pre;
	set noepisode_noEMclaim;

	no_chemo_milliman 	= max(no_chemo_milliman_emerge, no_chemo_milliman_main);
	no_EM_milliman 		= max(no_EM_milliman_emerge, no_EM_milliman_main);

	drop no_chemo_milliman_emerge no_chemo_milliman_main no_EM_milliman_emerge no_EM_milliman_main;
run;

**create fields on episode_candidates file to join on MEOS recoupments**;
data episode_candidates_&OCM_ID._&OCM_ID2.;
	set perf.episode_candidates_&OCM_ID._&OCM_ID2.;
	format perf_period $3.;

		if mdy(1,1,2018) >= m_episode_beg >= mdy(7,2,2017) then perf_period = 'PP3';
		else if mdy(7,1,2017) >= m_episode_beg >= mdy(1,2,2017) then perf_period = 'PP2';
		else if mdy(1,1,2017) >= m_episode_beg >= mdy(7,1,2016) then perf_period = 'PP1';
run;

proc sql;
	create table noepisode_epi_candidate as
		select *, 0 as no_cancer_diag_milliman, 0 as no_qual_chemo_milliman 
		from noepisode_flags_pre
		where CCW_beneficiary_ID in (select distinct BENE_ID from 
									 episode_candidates_&OCM_ID._&OCM_ID2.
									 where perf_period = &PP.	)
;
quit;

proc sql;
	create table noepisode_flags as
		select a.*
			  , b.no_cancer_diag_milliman
			  , b.no_qual_chemo_milliman	
		from noepisode_flags_pre as A
		left join noepisode_epi_candidate as B
		on a.CCW_beneficiary_ID = b.CCW_beneficiary_ID
		and a.service_date = b.service_date
;
quit;


******************************* RECOUPMENT REASON #2 *********************************;
*identify non-attributed episodes*;

data episode_subset_not_attrib;
	set episode_subset;
	where EPI_TIN_MATCH_USE = 'No';
run;

proc sql;
	create table not_attributed_episodes as
		select *, 1 as not_attributed_milliman from MEOS_subset
		where CCW_Beneficiary_ID in (select distinct BENE_ID from episode_subset_not_attrib)
;
quit;

*subset claims to reason 2*;
proc sql;
	create table claims_subset_reason2 as
		select * from claims_subset
		where BENE_ID in (select distinct BENE_ID from not_attributed_episodes)
;
quit;

*flag main milliman episodes with no_EM_milliman*;
data reason2_EMclaims_0;
	set claims_subset_reason2;
	where put(HCPCS_CD, $EMclaim.) = 'Y';

	%canc_init;
	%CANCERTYPE(0, PRINCIPAL_DIAG_CD); 
	%null_canc;

	if has_cancer = 1 and trim(TAX_NUM) in (&OCM_tin.) then EM_claim = 1;
		else EM_claim = 0;
run;

*take max of EM_claim by bene_id and ep_id_use then join below*;
proc sql;
	create table reason2_EMclaims as
	select BENE_ID, ep_id, sum(EM_claim) as EMVisits_OCM_TIN
	from reason2_EMclaims_0
	group by BENE_ID, ep_id 
;
quit;

proc sql;
	create table not_attributed_episodes_EM as
		select a.*
			, b.EMVisits_OCM_TIN
		from not_attributed_episodes as A
		left join reason2_EMclaims as B
			on a.CCW_Beneficiary_ID = b.BENE_ID
			and a.ep_id_use = b.ep_id
;
quit;

data not_attributed_episode_flags;
	set not_attributed_episodes_EM;

	fewer_EM_milliman = 0;
	if no_EM = 1 then do;
		if EMVisits_OCM_TIN in (0,.) then no_EM_milliman = 1;
		else no_EM_milliman = 0;
	end;
	else if EPI_TIN_MATCH_USE = 'No' and (tiebreak_tin = 1 or fewer_EM = 1) then do;
		if EMVisits_OCM_TIN = EMVisits_Attrib_TIN then tiebreak_tin_milliman = 1 and fewer_EM_milliman = 0;
		else if EMVisits_OCM_TIN < EMVisits_Attrib_TIN then tiebreak_tin_milliman = 0 and fewer_EM_milliman = 1;
		else tiebreak_tin_milliman = 0 and fewer_EM_milliman = 0;
	end;
run;


******************************* RECOUPMENT REASON #3 *********************************;
*identify duplicate payments within a calendar month*;
data MEOS_claims;
	set claims_subset;
	where HCPCS_CD = 'G9678';
	start_month = month(start_date_use);
run;

proc sql;
	create table MEOS_freq as
		select BENE_ID, ep_id2, start_month, count(*) as num_payments
		from MEOS_claims
		group by BENE_ID, ep_id2, start_month
		having calculated num_payments > 1
		order by calculated num_payments desc
;
quit;

proc sql;
	create table dup_payment_episodes as
		select *, 1 as dup_payment_milliman from MEOS_subset
		where CCW_Beneficiary_ID in (select distinct BENE_ID from MEOS_freq)
;
quit;

************************ RECOUPMENT DUE TO CARE MANAGEMENT CLAIMS ********************;
data cm_bene;
	set MEOS_subset;
	if MEOS_CM_dup = 1;

	CM2016_claim = 0;
	CM2017_claim = 0;
	CM2018_claim = 0;

	if service_date_use >= mdy(7,1,2016) then do;
		if put(Procedure_Code, $CM2016_.) = 'Y' then CM2016_claim = 1;
	end;
	if service_date_use >= mdy(1,1,2017) then do;
		if put(Procedure_Code, $CM2017_.) = 'Y' then CM2017_claim = 1;
	end;
	if service_date_use >= mdy(1,1,2018) then do;
		if put(Procedure_Code, $CM2018_.) = 'Y' then CM2018_claim = 1;
	end;

	cm_claim = max(CM2016_claim,CM2017_claim,CM2018_claim);
	if cm_claim = 1;
run;

proc sql;
	create table cm_episode_subset as
	select * from main.epi_detail_combined_&set_name._&OCM_ID.
	where BENE_ID in (select distinct CCW_Beneficiary_ID from cm_bene)
	and EPISODE_PERIOD_USE = &PP.
;
quit;

*subset claims*;
proc sql;
	create table cm_claims_subset_0 as
	select * from claims_stacked
	where ep_id2 in (select distinct ep_id_use from cm_episode_subset)
;
quit;

*get bene_id as personal identifier*;
proc sql;
	create table cm_claims_subset as
		select a.*, b.BENE_ID, b.EP_BEG, b.EP_END
		from cm_claims_subset_0 as A
		left join cm_episode_subset as B
			on a.ep_id2 = b.ep_id_use
;
quit;

data cm_claims cm_claims_valid;
	set cm_claims_subset;

	CM2016_claim = 0;
	CM2017_claim = 0;
	CM2018_claim = 0;

	if start_date_use >= mdy(7,1,2016) then do;
		if put(HCPCS_CD, $CM2016_.) = 'Y' then CM2016_claim = 1;
	end;
	else if start_date_use < mdy(7,1,2016) then do;
		if put(HCPCS_CD, $CM2016_.) = 'Y' then CM2016_valid_claim = 1;
	end;
	if start_date_use >= mdy(1,1,2017) then do;
		if put(HCPCS_CD, $CM2017_.) = 'Y' then CM2017_claim = 1;
	end;
	else if start_date_use < mdy(1,1,2017) then do;
		if put(HCPCS_CD, $CM2017_.) = 'Y' then CM2017_valid_claim = 1;
	end;
	if start_date_use >= mdy(1,1,2018) then do;
		if put(HCPCS_CD, $CM2018_.) = 'Y' then CM2018_claim = 1;
	end;
	else if start_date_use < mdy(1,1,2018) then do;
		if put(HCPCS_CD, $CM2018_.) = 'Y' then CM2018_valid_claim = 1;
	end;

	cm_claim 		= max(CM2016_claim,CM2017_claim,CM2018_claim);
	cm_claim_valid 	= max(CM2016_valid_claim,CM2017_valid_claim,CM2018_valid_claim);

	if CM2016_claim = 1 or CM2017_claim = 1 or CM2018_claim = 1 then output cm_claims;
	if CM2016_valid_claim = 1 or CM2017_valid_claim = 1 or CM2018_valid_claim = 1 then output cm_claims_valid;

run;

*invalid claims*;
proc sql;
	create table cm_claim_meos_dup as
		select a.*, 1 as MEOS_CM_dup_milliman
		from cm_claims as A
		left join MEOS_claims as B
			on a.BENE_ID = b.BENE_ID
			and trim(a.TAX_NUM) = trim(b.TAX_NUM)
			and month(a.start_date_use) = month(b.start_date_use)
;
quit;

proc sql;
	create table MEOS_CM_dup as
	select a.*, b.MEOS_CM_dup_milliman
	from MEOS_subset as A
	left join cm_claim_meos_dup as B
		on a.CCW_Beneficiary_ID = b.BENE_ID
		and a.CCW_Claim_ID = b.claim_id
	where A.PERF_PERIOD = &PP.
;
quit;

*valid claims*;
proc sql;
	create table cm_claim_meos_dup_valid as
		select a.*, 1 as MEOS_CM_valid_milliman
		from cm_claims_valid as A
		left join MEOS_claims as B
			on a.BENE_ID = b.BENE_ID
			and trim(a.TAX_NUM) = trim(b.TAX_NUM)
			and month(a.start_date_use) = month(b.start_date_use)
;
quit;

proc sql;
	create table MEOS_CM_valid as
	select a.*, b.MEOS_CM_valid_milliman
	from MEOS_subset as A
	left join cm_claim_meos_dup_valid as B
		on a.CCW_Beneficiary_ID = b.BENE_ID
		and a.CCW_Claim_ID = b.claim_id
	where A.PERF_PERIOD = &PP.
;
quit;

*flag any remaining CM claims that we do not observe if they overlap with a valid MEOS claim we observe*;
proc sql;
	create table MEOS_CM_overlap_0 as
		select a.*, 1 as MEOS_CM_overlap_milliman
		from cm_bene as A
		inner join MEOS_claims as B
			on a.CCW_Beneficiary_ID = b.BENE_ID
			and trim(a.TIN) = trim(b.TAX_NUM)
			and month(a.service_date_use) = month(b.start_date_use)
;
quit;

proc sql;
	create table MEOS_CM_overlap as
	select a.*, b.MEOS_CM_overlap_milliman
	from MEOS_subset as A
	left join MEOS_CM_overlap_0 as B
		on a.CCW_Beneficiary_ID = b.CCW_Beneficiary_ID
		and a.CCW_Claim_ID = b.CCW_Claim_ID
	where A.PERF_PERIOD = &PP.
;
quit;
******************************* RECOUPMENT REASON #4 *********************************;
*identify MEOS payments during that were paid during a hospice stay *;
data hospice_claims;
	set claims_subset;
	where label2 = 'Hospice';
run;

proc sql;
	create table meos_claims_during_hospice as
		select a.*, 1 as MEOS_hospice_milliman
		from MEOS_subset as A
		inner join hospice_claims as B
			on a.CCW_Beneficiary_ID = b.BENE_ID
			and b.start_date_use <= a.service_date <= b.end_date
;
quit;

******************************* RECOUPMENT REASON #5 *********************************;
*identify MEOS payments that are paid more than 90 days before episode beginning date *;
proc sql;
	create table meos_claims_90day as
		select a.*, 1 as MEOS_90day_milliman
		from MEOS_subset as A
		inner join episode_subset as B
			on a.CCW_Beneficiary_ID = b.BENE_ID
			and b.EP_BEG - 90 >= a.service_date 
;
quit;

******************************* RECOUPMENT REASON #6 *********************************;
*identify when there are more than six MEOS payments made in the allowable MEOS billing period *;
proc sql;
	create table meos_claims_during_billperiod as
		select a.*
		from MEOS_claims as A
		inner join MEOS_subset as B
			on b.CCW_Beneficiary_ID = a.BENE_ID
			and b.EP_BEG - 90 <= a.start_date_use <= b.EP_END + 90
		where label3 = 'Professional: MEOS - Your Practice';
;
quit;

proc sort data = meos_claims_during_billperiod nodupkey;
	by BENE_ID ep_id2 claim_id start_date_use end_date;
run;

proc sql;
	create table MEOS_episode_freq as
		select BENE_ID, ep_id2, count(*) as num_payments
		from meos_claims_during_billperiod
		group by BENE_ID, ep_id2
		having calculated num_payments > 6
		order by calculated num_payments desc
;
quit;

proc sql;
	create table MEOS_6plus_episodes as
		select *, 1 as MEOS_6plus_milliman from MEOS_subset
		where CCW_Beneficiary_ID in (select distinct BENE_ID from MEOS_episode_freq)
			and Procedure_Code = 'G9678'
;
quit;


******************************* RECOUPMENT REASON #7 *********************************;
*identify when there is a MEOS payment after a beneficiary dies *;
data MEOS_claims_death;
	set MEOS_claims;
	where label3 = 'Professional: MEOS - Your Practice';
	if DOD ne .;

	MEOS_after_death_milliman=0;
	if start_date_use > DOD then MEOS_after_death_milliman = 1;

	if MEOS_after_death_milliman = 1;
run;

proc sql;
	create table MEOS_after_death as
		select *, 1 as MEOS_after_death_milliman from MEOS_subset
		where CCW_Beneficiary_ID in (select distinct BENE_ID from MEOS_claims_death)
;
quit;


*********************** END RECOUPMENT REASON IDENTIFICATION **************************;

*join milliman variables onto MEOS_subset table*;
proc sql;
	create table MEOS_subset_&OCM_ID. as
		select a.*
			, b.no_episode_milliman 
			, b.no_chemo_milliman
			, b.no_cancer_diag_milliman
			, b.no_qual_chemo_milliman
			, max(b.no_EM_milliman, c.no_EM_milliman) as no_EM_milliman
			, c.not_attributed_milliman
			, c.tiebreak_tin_milliman
			, c.fewer_EM_milliman
			, d.dup_payment_milliman
			, e.MEOS_hospice_milliman
			, f.MEOS_90day_milliman
			, g.MEOS_6plus_milliman
			, h.MEOS_after_death_milliman
			, i.MEOS_CM_dup_milliman
			, j.MEOS_CM_valid_milliman
			, k.MEOS_CM_overlap_milliman
			,max(b.no_episode_milliman, b.no_chemo_milliman,
				 b.no_cancer_diag_milliman, b.no_qual_chemo_milliman,
				 b.no_EM_milliman, c.no_EM_milliman, c.not_attributed_milliman,
				 c.tiebreak_tin_milliman, c.fewer_EM_milliman, 
				 d.dup_payment_milliman, e.MEOS_hospice_milliman,
				 f.MEOS_90day_milliman, g.MEOS_6plus_milliman, h.MEOS_after_death_milliman,
				 i.MEOS_CM_dup_milliman, k.MEOS_CM_overlap_milliman) 		as milliman_reason_flag
			from MEOS_subset as A
				left join noepisode_flags as B
					on a.CCW_Beneficiary_ID = b.CCW_Beneficiary_ID
					and a.CCW_Claim_ID = b.CCW_Claim_ID
				left join not_attributed_episode_flags as C
					on a.CCW_Beneficiary_ID = c.CCW_Beneficiary_ID
					and a.CCW_Claim_ID = c.CCW_Claim_ID
				left join dup_payment_episodes as D
					on a.CCW_Beneficiary_ID = d.CCW_Beneficiary_ID
					and a.CCW_Claim_ID = d.CCW_Claim_ID
				left join meos_claims_during_hospice as E
					on a.CCW_Beneficiary_ID = e.CCW_Beneficiary_ID
					and a.CCW_Claim_ID = e.CCW_Claim_ID
				left join MEOS_claims_90day as F
					on a.CCW_Beneficiary_ID = f.CCW_Beneficiary_ID
					and a.CCW_Claim_ID = f.CCW_Claim_ID
				left join MEOS_6plus_episodes as G
					on a.CCW_Beneficiary_ID = g.CCW_Beneficiary_ID
					and a.CCW_Claim_ID = g.CCW_Claim_ID
				left join MEOS_after_death as H
					on a.CCW_Beneficiary_ID = H.CCW_Beneficiary_ID
					and a.CCW_Claim_ID = h.CCW_Claim_ID
				left join MEOS_CM_dup as I
					on a.CCW_Beneficiary_ID = I.CCW_Beneficiary_ID
					and a.CCW_Claim_ID = i.CCW_Claim_ID
				left join MEOS_CM_valid as J
					on a.CCW_Beneficiary_ID = J.CCW_Beneficiary_ID
					and a.CCW_Claim_ID = j.CCW_Claim_ID
				left join MEOS_CM_overlap as K
					on a.CCW_Beneficiary_ID = K.CCW_Beneficiary_ID
					and a.CCW_Claim_ID = K.CCW_Claim_ID
;
quit;

proc sort data = MEOS_subset_&OCM_ID. nodupkey;
	by CCW_Beneficiary_ID OCM_Episode_ID Claim_Control_Number Service_Date;
run;

**LAST STEP: AGREEMENT VARIABLES**;
data MEOS_summary_&OCM_ID._&PPvar.;
	set MEOS_subset_&OCM_ID.;

	if no_episode = 1 and no_episode = no_episode_milliman then no_episode_agree = 1;
		else no_episode_agree = 0;
	if no_chemo = 1 and no_chemo = no_chemo_milliman then no_chemo_agree = 1;
		else no_chemo_agree = 0;
	if no_EM = 1 and no_EM = no_EM_milliman then no_EM_agree = 1;
		else no_EM_agree = 0;
	if not_attributed = 1 and not_attributed = not_attributed_milliman then not_attributed_agree = 1;
		else not_attributed_agree = 0;
	if tiebreak_tin = 1 and tiebreak_tin = tiebreak_tin_milliman then tiebreak_tin_agree = 1;
		else tiebreak_tin_agree = 0;
	if fewer_EM = 1 and fewer_EM = fewer_EM_milliman then fewer_EM_agree = 1;
		else fewer_EM_agree = 0;
	if dup_payment = 1 and dup_payment = dup_payment_milliman then dup_payment_agree = 1;
		else dup_payment_agree = 0;
	if MEOS_hospice = 1 and MEOS_hospice = MEOS_hospice_milliman then MEOS_hospice_agree = 1;
		else MEOS_hospice_agree = 0;
	if MEOS_90day = 1 and MEOS_90day = MEOS_90day_milliman then MEOS_90day_agree = 1;
		else MEOS_90day_agree = 0;
	if MEOS_6plus = 1 and MEOS_6plus = MEOS_6plus_milliman then MEOS_6plus_agree = 1;
		else MEOS_6plus_agree = 0;
	if MEOS_after_death = 1 and MEOS_after_death = MEOS_after_death_milliman then MEOS_after_death_agree = 1;
		else MEOS_after_death_agree = 0;
	if MEOS_CM_dup = 1 and (MEOS_CM_dup = MEOS_CM_dup_milliman or MEOS_CM_dup = MEOS_CM_overlap_milliman) then MEOS_CM_dup_agree = 1;
		else MEOS_CM_dup_agree = 0;

	agree_flag = max(of no_episode_agree -- MEOS_CM_dup_agree);

/*	drop no_episode_milliman no_chemo_milliman no_EM_milliman not_attributed_milliman*/
/*		 tiebreak_tin_milliman fewer_EM_milliman dup_payment_milliman MEOS_hospice_milliman*/
/*		 MEOS_90day_milliman MEOS_6plus_milliman MEOS_after_death_agree MEOS_CM_dup_agree;*/
run;

** pull claim info for claims where we disagree and will contest*;
data contest_&OCM_ID._&PPvar.;
	set MEOS_summary_&OCM_ID._&PPvar.;
	where agree_flag = 0 and cant_validate = 0 and milliman_reason_flag ^= 1 and
	(no_episode = 1 or no_chemo = 1 or no_cancer_diag = 1 or no_qual_chemo = 1 or 
	 no_EM = 1 or not_attributed = 1 or tiebreak_tin = 1 or fewer_EM = 1 );
run;

proc sql;
	create table claims_subset_contest as
	select *, coalesce(start_date,PART_D_SERVICE_DATE) as START_DATE_USE format=mmddyy10.
	from mar19.all_claims_&set_name._&OCM_ID._&OCM_ID2.
	where BENE_ID in (select distinct CCW_Beneficiary_ID from contest_&OCM_ID._&PPvar.)
;
quit;

proc sort data = claims_subset_contest;
	by ep_id CLM_ID START_DATE_USE;
run;

data claims_subset_contest_drugs claims_subset_contest_EM;
	set claims_subset_contest;

	if label3 in ('Part B Chemo: Biologic' 
					 'Part B Chemo: Cytotoxic' 
					 'Part B Chemo: Hormonal'
					 'Part B Chemo: Novel Therapy'
					 'Part B Chemo: Other'
					 'Part D Chemo: Biologic' 
					 'Part D Chemo: Cytotoxic' 
					 'Part D Chemo: Hormonal'
					 'Part D Chemo: Novel Therapy'
					 'Part D Chemo: Other') 		then output claims_subset_contest_drugs;

	if label3 in ('Professional: Qualifying E&M Visits at Attrib TIN') then output claims_subset_contest_EM;
run;

proc sql;
	create table contest_&OCM_ID._&PPvar.drugs as
		select a.*
			  , coalesce(b.CLM_ID, b.PDE_ID) as CCW_Chemo_Claim_ID_Contest
			  , b.START_DATE_USE as Chemo_Date_Contest format mmddyy10.
			  , HCPCS_CD as Part_B_Chemo
			  , NDC10 as Part_D_Chemo
		from contest_&OCM_ID._&PPvar. as A
		left join claims_subset_contest_drugs as B
		on A.ep_id_use = B.EP_ID
		where a.perf_period = &PP.
		group by A.OCM_ID, A.ep_id_use
		order by A.OCM_ID, A.ep_id_use, b.START_DATE_USE
;
quit;	

proc sort data = contest_&OCM_ID._&PPvar.drugs  nodupkey;
	by CCW_Beneficiary_ID OCM_Episode_ID Claim_Control_Number Service_Date;
run;

proc sql;
	create table contest_&OCM_ID._&PPvar.EM as
		select a.*
			  , b.CLM_ID as CCW_EM_Claim_ID_Contest
			  , b.START_DATE_USE as EM_Date_Contest format mmddyy10.
		from contest_&OCM_ID._&PPvar.drugs as A
		left join claims_subset_contest_EM as B
		on A.ep_id_use = B.EP_ID
		where a.perf_period = &PP.
		group by A.OCM_ID, A.ep_id_use
		order by A.OCM_ID, A.ep_id_use, b.START_DATE_USE
;
quit;	

proc sort data = contest_&OCM_ID._&PPvar.EM  nodupkey out = contestation_&OCM_ID._&PPvar.;
	by CCW_Beneficiary_ID OCM_Episode_ID Claim_Control_Number Service_Date;
run;

%mend MEOS;

%let OCM_tin = '223141761' ;
%MEOS(137, 50136, 'PP1', PP1);
%MEOS(137, 50136, 'PP2', PP2);
%MEOS(137, 50136, 'PP3', PP3);
%let OCM_tin = '454999975' ;
%MEOS(255, 50179, 'PP1', PP1);
%MEOS(255, 50179, 'PP2', PP2);
%MEOS(255, 50179, 'PP3', PP3);
%let OCM_tin = '636000526' ;
%MEOS(257, 50195, 'PP1', PP1);
%MEOS(257, 50195, 'PP2', PP2);
%MEOS(257, 50195, 'PP2', PP2);
%let OCM_tin = '134290167' ;
%MEOS(278, 50193, 'PP1', PP1);
%MEOS(278, 50193, 'PP2', PP2);
%MEOS(278, 50193, 'PP3', PP3);
%let OCM_tin = '731310891' ;
%MEOS(280, 50115, 'PP1', PP1);
%MEOS(280, 50115, 'PP2', PP2);
%MEOS(280, 50115, 'PP3', PP3);
%let OCM_tin = '540647482','540793767','541744931','311716973' ;
%MEOS(290, 50202, 'PP1', PP1);
%MEOS(290, 50202, 'PP2', PP2);
%MEOS(290, 50202, 'PP3', PP3);
%let OCM_tin = '571004971' ;
%MEOS(396, 50258, 'PP1', PP1);
%MEOS(396, 50258, 'PP2', PP2);
%MEOS(396, 50258, 'PP3', PP3);
%let OCM_tin = '205485346' ;
%MEOS(401, 50228, 'PP1', PP1);
%MEOS(401, 50228, 'PP2', PP2);
%MEOS(401, 50228, 'PP3', PP3);
%let OCM_tin = '204881619' ;
%MEOS(459, 50243, 'PP1', PP1);
%MEOS(459, 50243, 'PP2', PP2);
%MEOS(459, 50243, 'PP3', PP3);
%let OCM_tin = '621490616' ;
%MEOS(468, 50227, 'PP1', PP1);
%MEOS(468, 50227, 'PP2', PP2);
%MEOS(468, 50227, 'PP3', PP3);
%let OCM_tin = '201872200' ;
%MEOS(480, 50185, 'PP1', PP1);
%MEOS(480, 50185, 'PP2', PP2);
%MEOS(480, 50185, 'PP3', PP3);
%let OCM_tin = '596014973' ;
%MEOS(523, 50330, 'PP1', PP1);
%MEOS(523, 50330, 'PP2', PP2);
%MEOS(523, 50330, 'PP3', PP3);

data out.MEOS_Summary;
	set MEOS_summary:;
	format Join_Var_MEOS $50.;
	Join_Var_MEOS = trim(OCM_ID)||trim(CCW_Beneficiary_ID)||trim(CCW_Claim_ID);
run;

** Provide Milliman comment for each MEOS recoupment**;
data out.MEOS_Summary_comments;
	set out.MEOS_summary;
	format Milliman_Comment $300.;

	if cant_validate = 1 then Milliman_Comment = 'Based on available data, we are unable to validate this MEOS claim recoupment';

		else if agree_flag = 1 then Milliman_Comment = "Based on available claims data, we agree with CMS' reason for recoupment";

		else if agree_flag = 0 then do;
			if no_episode = 1 and not_attributed_milliman = 1 		then Milliman_comment = "Based on available claims data, we do not observe an episode at this time";
			else if not_attributed = 1 and no_episode_milliman = 1 	then Milliman_comment = "Based on available claims data, we do not observe an episode at this time";
			else if no_episode = 1 and milliman_reason_flag = 1 	then Milliman_comment = "Based on available claims data, we disagree with CMS' reason for recoupment but find a different reason for recoupment";
			else if not_attributed = 1 and milliman_reason_flag = 1 then Milliman_comment = "Based on available claims data, we disagree with CMS' reason for recoupment but find a different reason for recoupment";
			else if not_attributed =1 and EPI_TIN_MATCH_USE = 'Yes' then Milliman_comment = "Based on available claims data, we disagree with CMS' reason for recoupment and observe an episode attributed to your practice";
			else if no_episode = 1 and no_EM = 1 					then Milliman_comment = "Based on available claims data, we disagree with CMS' reason for recoupment and observe at least 1 qualifying E&M visit at your practice";
			else if no_episode = 1 and index(Recoupment_Reason_Detail, 'but it did not trigger a new episode because it occurred during a prior episode') 
																	then Milliman_comment = "Based on available claims data, we disagree with CMS' reason for recoupment and observe chemotherapy that does not occur during a prior episode";
			else if dup_payment = 1 and milliman_reason_flag = 1 	then Milliman_comment = "Based on available claims data, we disagree with CMS' reason for recoupment but find a different reason for recoupment";
			else if dup_payment = 1 								then Milliman_comment = "Based on available claims data, we disagree with CMS' reason for recoupment and do not observe duplicate MEOS payments in this month";
			else if MEOS_hospice = 1 and milliman_reason_flag = 1 	then Milliman_comment = "Based on available claims data, we disagree with CMS' reason for recoupment but find a different reason for recoupment";
			else if MEOS_hospice = 1 								then Milliman_comment = "Based on available claims data, we disagree with CMS' reason for recoupment and do not observe a hospice claim that overlaps with the MEOS billing date";
			else if MEOS_CM_dup = 1 and MEOS_CM_valid_milliman = 1 	then Milliman_comment = "Based on available claims data, we disagree with CMS' reason for recoupment and observe that this Care Management claim occured prior to the effective date that CMS indicates in the MEOS Recoupment Reports";
			else if MEOS_CM_dup = 1 and milliman_reason_flag = 1 	then Milliman_comment = "Based on available claims data, we disagree with CMS' reason for recoupment but find a different reason for recoupment";
			else if MEOS_CM_dup = 1									then Milliman_comment = "Based on available claims data, we disagree with CMS' reason for recoupment and do not observe a Care Management claim in the same month as this MEOS claim";

			else Milliman_comment = "N/A";
		end;
run;

data out.MEOS_Summary_disagree;
	set out.MEOS_Summary_comments;
	if index(Milliman_comment, 'we disagree with CMS') and not index(Milliman_comment, 'but find a different reason');

	format Contestation_Reason $50. Error_Description $300.;
	Contestation_Reason = 'MEOS Payment Valid for '|| perf_period;

	if tiebreak_tin = 1 then Error_Description = "Based on available claims data, we disagree with CMS' reason for recoupment and observe an episode attributed to our practice, either because we had the latest E&M claim or had more E&M visits attributed to our practice following the trigger claim to the right";
	else if Milliman_comment  = "Based on available claims data, we disagree with CMS' reason for recoupment and observe at least 1 qualifying E&M visit at your practice" then
	 	    Error_Description = "Based on available claims data, we disagree with CMS' reason for recoupment and observe at least 1 qualifying E&M visit at our practice following the trigger claim to the right";
	else if Milliman_comment  = "Based on available claims data, we disagree with CMS' reason for recoupment and observe an episode attributed to your practice" then
	   		Error_Description = "Based on available claims data, we disagree with CMS' reason for recoupment and observe an episode attributed to our practice";
	else Error_Description = Milliman_comment;

	Contest = 1;
run;

data contest1;
	set contestation_:;
run;

*output contestations only*;
proc sql;
	create table out.MEOS_Contestations as
		select a.*
			, b.CCW_Chemo_Claim_ID_Contest
			, b.Chemo_Date_Contest
			, b.CCW_EM_Claim_ID_Contest
			, b.EM_Date_Contest
			, b.Part_B_Chemo
			, b.Part_D_Chemo
		from out.MEOS_Summary_disagree as A
		left join contest1 as B
		on A.CCW_Beneficiary_ID = b.CCW_Beneficiary_ID
		and A.OCM_Episode_ID = B.OCM_Episode_ID
		and A.Claim_Control_Number = B.Claim_Control_Number
		and A.Service_Date = B.Service_Date
;
quit;

*output final table*;
proc sql;
	create table MEOS_Summary_w_Contestations as
		select a.*
			, b.Contestation_Reason
			, b.CCW_Chemo_Claim_ID_Contest
			, b.Chemo_Date_Contest
			, b.CCW_EM_Claim_ID_Contest
			, b.EM_Date_Contest
			, b.Part_B_Chemo
			, b.Part_D_Chemo
			, b.Error_Description
		from out.MEOS_Summary_comments as A
		left join out.MEOS_Contestations as B
		on A.CCW_Beneficiary_ID = b.CCW_Beneficiary_ID
		and A.OCM_Episode_ID = B.OCM_Episode_ID
		and A.Claim_Control_Number = B.Claim_Control_Number
		and A.Service_Date = B.Service_Date
;
quit;

*grab metadata for attributed provider*;
proc sql;
	create table out.MEOS_Summary_w_Contestations as
		select a.*
			, case when b.provider_last_name__legal_name_ = "" then strip("Unknown ("||strip(a.Performing_NPI)||")")
				else strip(propcase(b.provider_last_name__legal_name_))||", "||strip(propcase(b.provider_first_name))||" ("||strip(a.Performing_NPI)||")"
				end as Performing_NPI_Name
		from MEOS_Summary_w_Contestations as a
		left join ref.npi_data as b
		on a.Performing_NPI=b.npi
;
quit;


%macro sas_2_xl(infile,tab);
PROC EXPORT
DATA= &infile.
OUTFILE= "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\80 - QlikView\outfiles\MEOS Recoupment\MEOS_summary"
	DBMS= XLSX
	REPLACE;
	SHEET= "OCMID &tab.";
RUN;
%mend sas_2_xl;


***SPLIT INTO PREMIER AND NON-PREMIER***;
%let other_flag=('396','137');

data MEOS_Summary_w_Contest_pmr
	 MEOS_Summary_w_Contest_other;
		 set out.MEOS_Summary_w_Contestations;

	 if OCM_ID not in &other_flag. then output MEOS_Summary_w_Contest_pmr;
	 else output MEOS_Summary_w_Contest_other;

run;

*MEOS Recoupment Demos*;

data out.MEOS_Summary_w_Contest_Demo;
	set out.MEOS_Summary_w_Contestations (rename=(OCM_ID = OCM_ID0
												  Service_Date_use = Service_Date_use0
												  Chemo_Date_Contest = Chemo_Date_Contest0));
	if OCM_ID0 in ('255', '480', '278');

	**Randomly change the episode start date by a value in -30 to +30 days**;
	**Change the episode year to a year not covered by the models**;
	**Apply to all dates of service**;
	format Service_Date_use Chemo_Date_Contest  mmddyy10. ;

	Service_Date_use = intnx('year',intnx('day', Service_Date_use0, floor(ranuni(7)*60)),10,'sameday');	

	increment = Service_Date_use - Service_Date_use0;

	%macro date(date);
		&date. = &date.0 + increment;
	%mend date;

	%date(Chemo_Date_Contest);

	**Manually change the names/labels for the OCM practices**;
	if OCM_ID0 = '255' then do; OCM_ID = '111'; OCM_NAME = 'Practice 1 (OCM 111)'; end;
		else if OCM_ID0 = '480' then do;  OCM_ID = '222'; OCM_NAME = 'Practice 2 (OCM 222)'; end;
		else if OCM_ID0 = '278' then do; OCM_ID = '333'; OCM_NAME = 'Practice 3 (OCM 333)'; end;

	MBI_HICN_DEMO = '999999999X';
run;

%sas_2_csv(out.MEOS_Summary_w_Contestations,MEOSRecoupments.csv);
%sas_2_csv(MEOS_Summary_w_Contest_pmr,MEOSRecoupments_premier.csv);
%sas_2_csv(MEOS_Summary_w_Contest_other,MEOSRecoupments_other.csv);

%sas_2_csv(out.MEOS_Summary_w_Contest_Demo,MEOSRecoupments_demo.csv);
