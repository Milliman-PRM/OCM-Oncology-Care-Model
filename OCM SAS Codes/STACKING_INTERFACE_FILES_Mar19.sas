********************************************************************** ;
		***** STACKING INTERFACE FILES.sas ***** ;
********************************************************************** ;

	*** locale of attribution files.  *** ;
libname att 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP1" ; 
libname att2 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP2" ;
libname att3 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP3" ;

	*** locale of RECONCILIATION  files.  *** ;
libname rec1 	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP1" ;
libname rec2	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP2" ;
libname rec3	"R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP3" ;

libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Performance" ;
libname outfinal "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Performance\Mar19" ;
libname attfin  "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Performance\Feb19" ;
libname r2 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Baseline\V3" ;

options ls=132 ps=70 obs=MAX mprint mlogic; run ;

%let bl_1 = blv3 ; *** baseline version, in preparation for multiple versions of these data files *** ; 
%let vers = B ; *** indicates A(latest qtr claims only) vs B processing(all qtrs epi files received) *** ;
%let bl = p5&vers. ; *** performance period of latest bene file received *** ; 
%let bla = p5A ; *** version of latest attribution file  *** ; 

%let Rvers1 = R2 ; *** R = Reconciliation, 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let it1 = 2 ;  *** 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let Rvers2 = R1 ; *** R = Reconciliation, 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let it2 = 1 ;  *** 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let Rvers3 = R0 ; *** R = Reconciliation, 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let it3 = 0 ;  *** 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;

%let Rbl1 = p1&Rvers1. ; *** performance period 1, bene file received *** ;
%let Rbl2 = p2&Rvers2. ; *** performance period 2, bene file received *** ;
%let Rbl3 = p3&Rvers3. ; *** performance period 3, bene file received *** ;

%let att_avail = 0 ; ***1 when attribution is most recent, 0 when reconciliation most recent *** ;

%let no_bene = mdy(7,1,2018) ; *** First day with no bene file (Only applicable when vers=A)*** ;

**************************************************************************** ;
**************************************************************************** ;


%macro stack(DS) ;

data all_epi ;
	set outfinal.episode_Interface_&bl._&ds. (in=a rename=(EP_ID_CMS=EP_ID_CMS_orig))
		outfinal.episode_emerge_&bl._&ds. (in=b rename=(EP_ID_CMS=EP_ID_CMS_orig)) ;
	length EP_ID_CMS $100.; format EP_ID_CMS $100.; 
	EP_ID_CMS = cats(EP_ID_CMS_orig);
	drop EP_ID_CMS_orig;

	if a then main_episode = 1 ; else main_episode = 0 ;
	if b then emerge_episode = 1 ; else emerge_episode = 0 ;
	IF MEOS_ALLOWED = . THEN MEOS_ALLOWED = 0 ;
	IF MEOS_STD_PAY = .  THEN MEOS_STD_PAY = 0 ;
	IF MEOS_ALLOWED_OTH = . THEN MEOS_ALLOWED_OTH = 0 ;
	IF MEOS_STD_PAY_OTH = . THEN MEOS_STD_PAY_OTH = 0 ;

proc sort data=all_epi ; by bene_id ep_id ep_id_cms ;
/*proc sort data=OUTFINAL.episode_meos_&bl._&ds. out=meos ; by bene_id ep_id ep_id_cms ;*/
data meos ;
	set OUTFINAL.episode_meos_&bl._&ds. (rename=(EP_ID_CMS=EP_ID_CMS_orig));
	length EP_ID_CMS $100.; format EP_ID_CMS $100.;
	EP_ID_CMS = cats(EP_ID_CMS_orig);
	drop EP_ID_CMS_orig;

	proc sort  ; by bene_id ep_id ep_id_cms ;
run;


%if "&ds."  = "290_50202" %then %do ;

data rec_old_ocm ;
	set     REC1.RECON&it1._Interface_&Rbl1._&ds.(RENAME= (EPI_COUNTER=COUNTER ))  
			REC1.RECON&it1._Interface_&Rbl1._567_50200(in=A RENAME= (EPI_COUNTER=COUNTER ))  
			REC1.RECON&it1._Interface_&Rbl1._568_50201(in=A RENAME= (EPI_COUNTER=COUNTER ))  
			REC2.RECON&it2._Interface_&Rbl2._&ds.(RENAME= (EPI_COUNTER=COUNTER ))  
			REC3.RECON&it3._Interface_&Rbl3._&ds.(RENAME= (EPI_COUNTER=COUNTER ))  ;
	REC_OCM_ID = OCM_ID ;
	if A THEN DO ;
		OCM_ID = '290' ;
		EP_ID_OLD = EP_ID ;
		ELOC1 = INDEX(EP_ID_OLD,'P-567') ;
		ELOC2 = INDEX(EP_ID_OLD,'P-568') ;
		ELOC = MAX(ELOC1,ELOC2) ;
		EP_ID_PRE = SUBSTR(EP_ID_OLD,1,ELOC-1) ;
		EP_ID = COMPRESS((EP_ID_PRE||'P-290')," ") ;
	END ;
PROC PRINT DATA=REC_OLD_OCM (OBS=20) ;
	WHERE REC_OCM_ID IN ('567','568') ;
	VAR BENE_ID EP_ID_CMS OCM_ID REC_OCM_ID EP_ID_OLD ELOC1 ELOC2 ELOC EP_ID_PRE EP_ID ;
TITLE "CHECK ON RECON EPISODE CONVERSION FOR 567 AND 568" ; RUN ;

data _null_;
      /* Use a pattern to replace all occurrences of cat,      */
      /* rat, or bat with the value TREE.                      */
   length text $ 46;
   RegularExpressionId = prxparse('s/[crb]at/tree/');
   text = 'The woods have a bat, cat, bat, and a rat!';
      /* Use CALL PRXCHANGE to perform the search and replace. */
      /* Because the argument times has a value of -1, the     */
      /* replacement is performed as many times as possible.   */ 
   call prxchange(RegularExpressionId, -1, text);
   put text;
run;
%END ;

%ELSE %DO ;
DATA REC_OLD_OCM ;
	SET REC1.RECON&it1._Interface_&Rbl1._&ds.(RENAME= (EPI_COUNTER=COUNTER ))  
		REC2.RECON&it2._Interface_&Rbl2._&ds.(RENAME= (EPI_COUNTER=COUNTER ))  
		REC3.RECON&it3._Interface_&Rbl3._&ds.(RENAME= (EPI_COUNTER=COUNTER ))  ;
	REC_OCM_ID = OCM_ID ;
%END ;

DATA REC ;
	SET REC_OLD_OCM (rename=(EP_ID_CMS=EP_ID_CMS_orig));
	length EP_ID_CMS $100.; format EP_ID_CMS $100. REC_EP_END MMDDYY10.; 
	EP_ID_CMS = cats(EP_ID_CMS_orig);
	drop EP_ID_CMS_orig;
		   REC_CANCER_MATCH = CANCER_MATCH ;		
		   FORMAT EPI_COUNTER $50. ; LENGTH EPI_COUNTER $50. ;
		   EPI_COUNTER = COUNTER ;
		   
		   REC_BMT_MILLIMAN = BMT_MILLIMAN ;
		   REC_CANCER_TYPE_MILLIMAN =CANCER_TYPE_MILLIMAN ;
		   REC_AGE  = AGE ;
		   REC_LOW_RISK_BLAD = LOW_RISK_BLAD ;
		   REC_LOW_RISK_BLAD_MILLIMAN = LOW_RISK_BLAD_MILLIMAN ;
           REC_CAST_SENS_PROS = CAST_SENS_PROS ; 
           REC_CAST_SENS_PROS_MILLIMAN = CAST_SENS_PROS_MILLIMAN ; 
		   REC_NOVEL_THERAPIES = NOVEL_THERAPIES ;
		   REC_NOVEL_THERAPIES_MILLIMAN = NOVEL_THERAPIES_MILLIMAN ;
		   REC_PTD_CHEMO = PTD_CHEMO  ;
		   REC_PTD_CHEMO_MILLIMAN = PTD_CHEMO_MILLIMAN  ;
		   REC_RADIATION = RADIATION ;
		   REC_RADIATION_MILLIMAN = RADIATION_MILLIMAN ;
		   REC_SURGERY = SURGERY ;
		   REC_SURGERY_MILLIMAN = SURGERY_MILLIMAN ;
		   REC_CLINICAL_TRIAL = CLINICAL_TRIAL ;
		   REC_CLINICAL_TRIAL_MILLIMAN = CLINICAL_TRIAL_MILLIMAN ;
		   REC_EPI_NPI_ID = EPI_NPI_ID ;
		   REC_EPI_TAX_ID = EPI_TAX_ID ;
		   REC_EP_END = EP_END ;
		   REC_EPI_COUNTER = EPI_COUNTER ;
		   REC_M_EPI_SOURCE_FINAL = M_EPI_SOURCE_FINAL ;

			KEEP 
		   OCM_ID REC_OCM_ID EPISODE_PERIOD BENE_ID BENE_HICN FIRST_NAME LAST_NAME PATIENT_NAME SEX
           PATIENT_SEX DOB REC_AGE DOD ZIPCODE EP_ID EP_ID_CMS  EP_BEG /*EP_END */REC_EP_END REC_M_EPI_SOURCE_FINAL
           CANCER_TYPE REC_CANCER_TYPE_MILLIMAN REC_CANCER_MATCH RECON_ELIG DUAL_PTD_LIS
           INST REC_RADIATION REC_RADIATION_MILLIMAN HCC_GRP HRR_REL_COST
           REC_SURGERY REC_SURGERY_MILLIMAN REC_CLINICAL_TRIAL REC_CLINICAL_TRIAL_MILLIMAN
           BMT REC_BMT_MILLIMAN CLEAN_PD ACTUAL_EXP ACTUAL_EXP_MILLIMAN ACTUAL_EXP_NOOTH_MILLIMAN
           BASELINE_PRICE EXPERIENCE_ADJ ACTUAL_EXP_UNADJ ACTUAL_EXP_UNADJ_MILLIMAN
           REC_LOW_RISK_BLAD REC_CAST_SENS_PROS REC_LOW_RISK_BLAD_MILLIMAN REC_CAST_SENS_PROS_MILLIMAN MBI BENCHMARK_PRICE TARGET_PRICE
           OCM_DISCOUNT_ACO REC_NOVEL_THERAPIES REC_NOVEL_THERAPIES_MILLIMAN
           NUM_OCM1 NUM_OCM1_MILLIMAN NUM_OCM2 NUM_OCM2_MILLIMAN
           NUM_OCM3 NUM_OCM3_MILLIMAN DEN_OCM3 DEN_OCM3_MILLIMAN
           EXP_ALL_SERVICES EXP_ALL_SERVICES_MILLIMAN EXP_ALL_SRVC_NOOTH_MILL EXP_INP_ADMSNS EXP_INP_ADMSNS_MILLIMAN
           EXP_OBS_STAY EXP_OBS_STAY_MILLIMAN EXP_ED EXP_ED_MILLIMAN
           EXP_RAD_ONCLGY EXP_RAD_ONCLGY_MILLIMAN EXP_PHY_SRVC EXP_PHY_SRVC_MILLIMAN
           EXP_OUT_OTHER EXP_OUT_OTHER_MILLIMAN EXP_HHA EXP_HHA_MILLIMAN
           EXP_SNF EXP_SNF_MILLIMAN EXP_LTCH EXP_LTCH_MILLIMAN
           EXP_IRF EXP_IRF_MILLIMAN EXP_HSP EXP_HSP_MILLIMAN
           EXP_DME_EXCL_DRUGS EXP_DME_EXCL_DRUGS_MILL EXP_PART_B_DRUGS EXP_PART_B_DRUGS_MILL
           EXP_PD EXP_PD_MILLIMAN EXP_OTHER EXP_OTHER_MILLIMAN
           RECON_ATT_MATCH_EPI RECON_ATT_MATCH_STRT RECON_ATT_MATCH_CANC
           EPI_ATT_TIN REC_EPI_TAX_ID REC_EPI_NPI_ID TIN_MATCH IN_PERFORMANCE
		   CAST_SENS_PROS_MILLIMAN REC_CAST_SENS_PROS_MILLIMAN LOW_RISK_BLAD_MILLIMAN REC_LOW_RISK_BLAD_MILLIMAN 
		   EPI_BEG_MATCH REC_PTD_CHEMO REC_PTD_CHEMO_MILLIMAN 
		   EXP_ALL_SERVICES_MATCH REC_EPI_COUNTER EP_LENGTH
		   EXP_MEOS EXP_MEOS_MILLIMAN 

		   DIFF_TARGET_ACTUAL DIFF_TARGET_ACTUAL_PRIOR 

		   EP_ID_PRIOR BENE_HICN_PRIOR CANCER_TYPE_PRIOR HCC_GRP_PRIOR
		   EP_BEG_prior  EP_END_prior HRR_REL_COST_prior   ACTUAL_EXP_prior BASELINE_PRICE_prior EXPERIENCE_ADJ_prior ACTUAL_EXP_UNADJ_prior 		
		   BENCHMARK_PRICE_prior TARGET_PRICE_prior OCM_DISCOUNT_ACO_prior NOVEL_THERAPIES_prior  
		   EXP_ALL_SERVICES_prior EXP_INP_ADMSNS_prior EXP_OBS_STAY_prior EXP_ED_prior EXP_RAD_ONCLGY_prior EXP_PHY_SRVC_prior
		   EXP_MEOS_prior  EXP_ANC_SRVC_prior	EXP_OUT_OTHER_prior EXP_HHA_prior EXP_SNF_prior EXP_LTCH_prior EXP_IRF_prior EXP_HSP_prior
		   EXP_DME_EXCL_DRUGS_prior EXP_PART_B_DRUGS_prior EXP_PD_prior EXP_OTHER_prior 
		   BMT_prior	CAST_SENS_PROS_prior  CLEAN_PD_prior  CLINICAL_TRIAL_prior DEN_OCM3_prior  DUAL_PTD_LIS_prior  
		   EP_LENGTH_prior INST_prior LOW_RISK_BLAD_prior MBI_prior  NUM_OCM1_prior NUM_OCM2_prior NUM_OCM3_prior PTD_CHEMO_prior RADIATION_prior
		   RECON_ELIG_prior SURGERY_prior  
		   BENE_IN_PRIOR EPI_IN_PRIOR EP_BEG_MATCH_PRIOR BENE_HICN_MATCH_PRIOR EP_LENGTH_MATCH_PRIOR CANCER_TYPE_MATCH_PRIOR 
		   RECON_ELIG_MATCH_PRIOR DUAL_PTD_LIS_MATCH_PRIOR INST_MATCH_PRIOR RADIATION_MATCH_PRIOR HCC_GRP_MATCH_PRIOR 
		   SURGERY_MATCH_PRIOR CLINICAL_TRIAL_MATCH_PRIOR BMT_MATCH_PRIOR CLEAN_PD_MATCH_PRIOR LOW_RISK_BLAD_MATCH_PRIOR 
		   CAST_SENS_PROS_MATCH_PRIOR MBI_MATCH_PRIOR PTD_CHEMO_MATCH_PRIOR Prior_Changed_Episode
;

PROC SORT DATA= REC ; BY BENE_ID EP_ID EP_ID_CMS ;

DATA PERFORMANCE ;
	merge meos(in=a drop=ep_length) all_epi(in=b drop=ep_length) REC(IN=C) ; by bene_id ep_id ep_id_cms ;
	if a then meos_episode = 1 ; else meos_episode = 0 ;
	if c then recon_episode = 1 ; else recon_episode = 0 ;
	if a and b=0 then do ;
		main_episode = 0 ;
		emerge_episode = 0 ;
	end ;
	if c and b=0 then do ;
		main_episode = 0 ;
		emerge_episode = 0 ;
	end ;

	if b and M_EPI_SOURCE_FINAL='UNKNOWN' then do;
		if c and REC_M_EPI_SOURCE_FINAL^='UNKNOWN' then M_EPI_SOURCE_FINAL = REC_M_EPI_SOURCE_FINAL;
	end;

	FORMAT EPI_TIN_MATCH2 $8. ; LENGTH EPI_TIN_MATCH2 $8. ; 
	EPI_TIN_MATCH2 = EPI_TIN_MATCH ;
	DROP EPI_TIN_MATCH ;
PROC SORT DATA=PERFORMANCE ; BY EP_ID EP_ID_CMS ;

DATA ATTRIB ;
	SET attfin.attrib_Interface_&bla._&ds (rename=(EP_ID_CMS=EP_ID_CMS_orig));
	length EP_ID_CMS $100.; format EP_ID_CMS $100. ATT_EP_END MMDDYY10.; 
	EP_ID_CMS = cats(EP_ID_CMS_orig);
	drop EP_ID_CMS_orig;

	ATT_IN_PERFORMANCE_DATA = IN_PERFORMANCE_DATA ;
	ATT_EPI_START_DATE_MATCH = EPI_START_DATE_MATCH ;
	ATT_PERFORMANCE_PER_MATCH =  PERFORMANCE_PER_MATCH ;
	ATT_CANCER_MATCH = CANCER_MATCH ;
	ATT_EM_VISIT_FOR_CANC = EM_VISIT_FOR_CANC ;
	ATT_TIN_MATCH = TIN_MATCH ;
	ATT_IN_RECON = IN_RECON ;
	ATT_EP_END = EP_END ;

	KEEP OCM_ID BENE_MBI EP_ID EP_ID_cms CANCER_TYPE_MILLIMAN RECON_ELIG_A EP_BEG /*EP_END*/ATT_EP_END EP_END_A /*DOD*/ 
		   ATT_IN_PERFORMANCE_DATA ATT_EPI_START_DATE_MATCH ATT_PERFORMANCE_PER_MATCH ATT_CANCER_MATCH
		   ATT_EM_VISIT_FOR_CANC ATT_TIN_MATCH EPISODE_PERIOD ATT_IN_RECON ATT_CANC_MATCH_CMS 
		   ATT_EPI_PERD_MATCH_CMS EPISODE_PERIOD ATT_IN_RECON BENE_HICN PATIENT_NAME;
PROC SORT DATA=ATTRIB ; BY EP_ID EP_ID_CMS ;

DATA PERFORMANCE2 ;
	MERGE PERFORMANCE(IN=A) ATTRIB(IN=B) ; BY EP_ID EP_ID_CMS ;
	IF B THEN attrib_episode = 1 ; else attrib_episode = 0 ;
	if a = 0 then do ;
		main_episode = 0 ;
		recon_episode = 0 ;
		meos_episode = 0 ;
		emerge_episode = 0 ;
	end ;

	%if &att_avail. = 0 %then %do;
		if main_episode=1 and recon_episode=1 and EPISODE_PERIOD in ('PP3') then do;
			if cancer_type in ('Breast Cancer - High Risk','Breast Cancer - Low Risk', 
											'Bladder Cancer - High Risk','Bladder Cancer - Low Risk',
											'Prostate Cancer - High Intensity','Prostate Cancer - Low Intensity') 
											then do;
				if cancer_type_milliman ^= cancer_type then cancer_type_milliman = cancer_type;
			end;
		end; 
	%end;
run ;
 
data epi_combined_pre_&bl._&ds.  ;
	SET PERFORMANCE2(RENAME = (EPI_TIN_MATCH2=EPI_TIN_MATCH)) 
		r2.episode_Interface_&bl_1._&ds.(IN=A rename=(EP_ID_CMS=EP_ID_CMS_orig)) ;
		length EP_ID_CMS $100.; format EP_ID_CMS $100.; 
		if a then do;
			EP_ID_CMS = cats(EP_ID_CMS_orig);
		end;
		drop EP_ID_CMS_orig;

		IF A THEN DO ;
			MAIN_EPISODE = 1 ;
			EMERGE_EPISODE = 0 ;
			MEOS_EPISODE = 0 ;
			ATTRIB_EPISODE = 0 ;
			RECON_EPISODE = 0 ;
		END ;

		if recon_elig='' and main_episode=0 and emerge_episode=0 and attrib_episode=0 and recon_episode=0 then do;
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
		end;

		if CANCER_TYPE_MILLIMAN='' and meos_episode=1 and main_episode=0 and emerge_episode=0 and attrib_episode=0 and recon_episode=0 then do;
			CANCER_TYPE_MILLIMAN=CANCER_TYPE;
			RECON_ELIG_MILLIMAN=RECON_ELIG;
		end;

		no_bene_file=0;
		%IF "&VERS." = "A" %THEN %DO ;
			if EP_BEG >= &no_bene. then no_bene_file=1;
		%END ;
run;

proc sql;
	create table episode_combined1_&bl._&ds. as
	select coalesce(b.BENE_MBI,a.BENE_MBI,'') as BENE_MBI, a.* 
	from epi_combined_pre_&bl._&ds. as a left join out.mbi_beneid_&ds. as b
	on a.bene_id=b.bene_id;
quit;

/* AD HOC - Remove after 2/14/19 Posting */
data demo_table1_&bl._&ds. demo_table2_&bl._&ds.;
	set episode_combined1_&bl._&ds.;
	if PATIENT_NAME = 'UNKNOWN' then output demo_table2_&bl._&ds.;
	else output demo_table1_&bl._&ds.;
run;

proc sort nodupkey data=demo_table1_&bl._&ds. (where=(bene_id ^= '')) out=demo_table3_&bl._&ds.;
	by bene_id;
run;

proc sql;
	create table demo_table4_&bl._&ds. as
	select 
		coalesce(b.PATIENT_NAME,a.PATIENT_NAME,'UNKNOWN') as PATIENT_NAME, 
		coalesce(b.BENE_HICN,'') as BENE_HICN2, 
		coalesce(b.SEX,a.SEX,'') as SEX, 
		coalesce(b.PATIENT_SEX,a.PATIENT_SEX,0) as PATIENT_SEX, 
		coalesce(b.DOB,a.DOB,.) as DOB, 
		a.* 
	from demo_table2_&bl._&ds. as a left join demo_table3_&bl._&ds. as b
	on a.bene_id=b.bene_id;
quit;

data demo_table5_&bl._&ds. (drop=AGE_missing BENE_HICN2);
	set demo_table4_&bl._&ds. (rename=(AGE=AGE_missing));
	format AGE BEST12.;
	if dob = . then Age = Age_missing;
	else do;
		if month(dob)*100+day(dob) < month(EP_BEG)*100+day(EP_BEG) then Age = year(EP_BEG) - year(dob);
		else Age = year(EP_BEG) - year(dob) - 1;
	end;
	if BENE_HICN = '' and BENE_HICN2 ^= '' then BENE_HICN = BENE_HICN2;
run;

data episode_combined2_&bl._&ds.;
	set demo_table1_&bl._&ds.
		demo_table5_&bl._&ds.
		;
run;

data demo_table6_&bl._&ds. demo_table7_&bl._&ds.;
	set episode_combined2_&bl._&ds.;
	if PATIENT_NAME = 'UNKNOWN' then output demo_table7_&bl._&ds.;
	else output demo_table6_&bl._&ds.;
run;

proc sort nodupkey data=demo_table6_&bl._&ds. (where=(BENE_MBI ^= '')) out=demo_table8_&bl._&ds.;
	by BENE_MBI;
run;

proc sql;
	create table demo_table9_&bl._&ds. as
	select 
		coalesce(b.PATIENT_NAME,a.PATIENT_NAME,'UNKNOWN') as PATIENT_NAME, 
		coalesce(b.SEX,a.SEX,'') as SEX, 
		coalesce(b.PATIENT_SEX,a.PATIENT_SEX,0) as PATIENT_SEX, 
		coalesce(b.DOB,a.DOB,.) as DOB, 
		a.* 
	from demo_table7_&bl._&ds. as a left join demo_table8_&bl._&ds. as b
	on a.BENE_MBI=b.BENE_MBI;
quit;

data demo_table10_&bl._&ds. (drop=AGE_missing);
	set demo_table9_&bl._&ds. (rename=(AGE=AGE_missing));
	format AGE BEST12.;
	if dob = . then Age = Age_missing;
	else do;
		if month(dob)*100+day(dob) < month(EP_BEG)*100+day(EP_BEG) then Age = year(EP_BEG) - year(dob);
		else Age = year(EP_BEG) - year(dob) - 1;
	end;
run;

data outFINAL.episode_combined_&bl._&ds.;
	set demo_table6_&bl._&ds.
		demo_table10_&bl._&ds.
		;
run;
/* END: AD HOC - Remove after 2/14/19 Posting */

/*
data outFINAL.claims_combined_&bl._&ds. ;
	SET outFINAL.claims_interface_&bl._&ds. (in=a)
		outFINAL.claims_emerge_&bl._&ds. (in=b)
		outFINAL.claims_meos_&bl._&ds. (in=c) ;

		claim_main=0;
		claim_emerge=0;
		claim_meos=0;
		if a then claim_main=1;
		if b then claim_emerge=1;
		if c then claim_meos=1;
run;
*/
%mend stack ;

**************************************************************************** ;
**************************************************************************** ;
***** %macro sc(ds,id)  
		ID: 3 digit OCM id
*** !!! Only run ATT macro when attribution (but not recon file) is provided for a performance period. *** ;
**************************************************************************** ;
**************************************************************************** ;
%STACK(255_50179) ; RUN ;
%STACK(257_50195) ; RUN ;
%STACK(278_50193) ; RUN ;
%STACK(280_50115) ; RUN ;
%STACK(290_50202) ; RUN ;
%STACK(396_50258) ; RUN ;
%STACK(401_50228) ; RUN ;
%STACK(459_50243) ; RUN ;
%STACK(468_50227) ; RUN ;
%STACK(480_50185) ; RUN ;
%STACK(523_50330) ; RUN ;
%STACK(137_50136) ; RUN ;

/*
data test_epi_count;
	set outfinal.episode_comb: ;
run;

DATA ATT ;
	SET OUTFINAL.EPISODE_COMBINED_P4A_523_50330 ;
	WHERE ATTRIB_EPISODE =  1 ;

DATA HICN NAME ;
	SET ATT ;
	IF PATIENT_NAME = "  " THEN OUTPUT NAME ;
	IF BENE_HICN = "   " THEN OUTPUT HICN ; RUN ;

proc freq data=attrib ;
	tables ATT_CANCER_MATCH*ATT_EPI_START_DATE_MATCH/list missing ; run ;

proc contents data=performance ; run ;


proc freq data=OUTFINAL.EPISODE_COMBINED_P4B_137_50136 ;
	tables ATT_CANCER_MATCH*ATT_EPI_START_DATE_MATCH*cancer_type*cancer_type_milliman/list missing ; run ;
*/
