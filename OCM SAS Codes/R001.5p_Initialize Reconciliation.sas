********************************************************************** ;
				***** RECON_STEP1.sas ***** ;
********* Identifies differences between recon episode file ********* ;
********* and previously submitted attribution files. 		********* ;
********************************************************************** ;
**** Requires C001.5p program using attribution file needs to be run prior to this ******************* ;


libname PER "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Performance" ;
		     
options ls=132 ps=70 obs=MAX; run ;

********************************************************************** ;
	*** Attribution File Name Macro Variables *** ;
********************************************************************** ;

/*
pp = *** performance period being run ;
tu = *** blank for initial, 1 for true-up 1, 2 for true-up 2 *** ;
version = *** initial for initial, TrueUp1 for true-up 1, TrueUp2 for true-up 2 *** ;
vprior = *** Version of reconcilation for performance period *** ;
tup = *** Version of reconcilation file to compare against => only utilized for True UP recons *** ;
*/

***PP1 Inputs***;
libname in "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP1" ; *** locale of RECON SAS reads. *** ;
libname rec "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP1" ; *** reconciliation outputs  *** ;
%let pp = 1 ; 
%let tu = 2 ; 
%let version = TrueUp2;
%let vprior = TrueUp1 ;
%let tup = 1 ; 

/*
***PP2 Inputs***;
libname in "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP2" ; *** locale of RECON SAS reads. *** ;
libname rec "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP2" ; *** reconciliation outputs  *** ;
%let pp = 2 ; 
%let tu = 1 ; 
%let version = TrueUp1 ;
%let vprior = initial ;
%let tup =  ; 
*/

/*
***PP3 Inputs***;
libname in "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP3" ; *** locale of RECON SAS reads. *** ;
libname rec "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP3" ; *** reconciliation outputs  *** ;
%let pp = 3 ; 
%let tu =  ; 
%let version = initial ;
%let vprior = initial ;
%let tup =  ; 
*/


RUN ;
********************************************************************** ;
********************************************************************** ;
********************************************************************** ;
%MACRO EPI(DSID, special) ;

DATA ATT(KEEP = BENE_ID BENE_HICN MBI EP_ID EP_BEG_A CANCER_TYPE_A) ;
	SET in.ATT_PP&pp.&version._&dsid. ;

PROC SORT DATA=ATT ; BY BENE_ID EP_ID ;

PROC SQL ;
	CREATE TABLE REC AS
	SELECT A.*, B.RECON_PP1_FLAG
	FROM IN.EPI&tu._&dsid. AS A LEFT JOIN 
		%if "&pp." = "1" %then %do ; 
			%if "&special." = "1" %then %do ; per.RECON_OVERLAP_PP1_290_50202 %end ;
			%else %do ; per.RECON_OVERLAP_PP1_&DSID.  %end ;
		%end ;
		%else %do ; per.RECON_OVERLAP_PP&pp._&DSID.  %end ;
	AS B
	ON A.BENE_ID=B.BENE_ID AND A.EP_ID=B.EP_ID_A ;
QUIT ;

PROC SORT DATA=REC; by BENE_ID EP_ID ;

DATA EPI_MATCH 
	 NOMATCH_EPI(DROP = EP_BEG_A CANCER_TYPE_A) 
	 NOMATCH_ATT(KEEP = BENE_ID BENE_HICN MBI EP_ID EP_BEG_A CANCER_TYPE_A)  ;
	MERGE ATT(IN=A) REC(IN=B) ; BY BENE_ID EP_ID ;
	IF A AND B THEN OUTPUT EPI_MATCH ;
	ELSE IF A AND B=0 THEN OUTPUT NOMATCH_EPI ;
	ELSE IF A=0 AND B THEN OUTPUT NOMATCH_ATT ;

DATA BENE_MATCH  
	 NOMATCH_EPI2(DROP = EP_BEG_A CANCER_TYPE_A) 
	 NOMATCH_ATT2(KEEP = BENE_ID BENE_HICN MBI EP_ID EP_BEG_A CANCER_TYPE_A)  ;
	MERGE NOMATCH_EPI(IN=A) NOMATCH_ATT(IN=B) ; BY BENE_ID ;
	IF A AND B THEN OUTPUT BENE_MATCH ;
	ELSE IF A AND B=0 THEN OUTPUT NOMATCH_EPI2 ;
	ELSE IF A=0 AND B THEN OUTPUT NOMATCH_ATT2 ;




%if "&version." = "initial" %then %do ; DATA REC.EPIATT&tu._&dsid._PP&pp. ; %end ;
%else %do ; data epiatt ; %end ;
	set epi_match(IN=A) bene_match(IN=B) nomatch_epi2(IN=C) ;
	IF A THEN DO ;
		RECON_ATT_MATCH_EPI = 1 ;
		IF EP_BEG = EP_BEG_A THEN RECON_ATT_MATCH_STRT = 1 ; 
						     ELSE RECON_ATT_MATCH_STRT = 0 ;
		IF CANCER_TYPE = CANCER_TYPE_A THEN RECON_ATT_MATCH_CANC = 1 ;
									   ELSE RECON_ATT_MATCH_CANC = 0;
	END ;
	IF B THEN RECON_ATT_MATCH_EPI = 2 ;
	IF C THEN RECON_ATT_MATCH_EPI = 0 ;

	*** In Performance Data Flag *** ;
	IF RECON_PP1_FLAG IN (3,.) THEN IN_PERFORMANCE = 0 ; 	 *** Not in performance data. *** ;
	ELSE IF RECON_PP1_FLAG = 1 THEN IN_PERFORMANCE = 1 ; *** In performance data completely. *** ;
	ELSE IF RECON_PP1_FLAG = 2 THEN IN_PERFORMANCE = 2 ; *** In performance data with partial data. *** ;
	DROP EP_BEG_A  CANCER_TYPE_A ;
	%if "&version." = "initial" %then %do ; bene_in_prior = "init"  ; %end ;


*** Pulls in prior recon file variables ;
%IF "&VERSION." NE "initial" %then %do ;

data prior ;
	set IN.EPI&tup._&dsid. (RENAME = (BENE_HICN = BENE_HICN_PRIOR CANCER_TYPE = CANCER_TYPE_PRIOR HCC_GRP=HCC_GRP_PRIOR)) ;

	array ren (l) 	EP_ID EP_BEG  EP_END   HRR_REL_COST  ACTUAL_EXP BASELINE_PRICE EXPERIENCE_ADJ ACTUAL_EXP_UNADJ 
					BENCHMARK_PRICE TARGET_PRICE OCM_DISCOUNT_ACO NOVEL_THERAPIES EXP_ALL_SERVICES
					EXP_INP_ADMSNS EXP_OBS_STAY EXP_ED EXP_RAD_ONCLGY EXP_PHY_SRVC EXP_MEOS	 EXP_ANC_SRVC	EXP_OUT_OTHER EXP_HHA EXP_SNF
					EXP_LTCH EXP_IRF EXP_HSP EXP_DME_EXCL_DRUGS EXP_PART_B_DRUGS EXP_PD EXP_OTHER ;

	array ren2 (l) 	EP_ID_prior EP_BEG_prior  EP_END_prior HRR_REL_COST_prior   ACTUAL_EXP_prior BASELINE_PRICE_prior EXPERIENCE_ADJ_prior ACTUAL_EXP_UNADJ_prior 		
					BENCHMARK_PRICE_prior TARGET_PRICE_prior OCM_DISCOUNT_ACO_prior NOVEL_THERAPIES_prior  
				    EXP_ALL_SERVICES_prior EXP_INP_ADMSNS_prior EXP_OBS_STAY_prior EXP_ED_prior EXP_RAD_ONCLGY_prior EXP_PHY_SRVC_prior
				    EXP_MEOS_prior  EXP_ANC_SRVC_prior	EXP_OUT_OTHER_prior EXP_HHA_prior EXP_SNF_prior EXP_LTCH_prior EXP_IRF_prior EXP_HSP_prior
				    EXP_DME_EXCL_DRUGS_prior EXP_PART_B_DRUGS_prior EXP_PD_prior EXP_OTHER_prior ;


	do l = 1 to dim(ren) ;
		ren2 = ren ;
	end ;


	ARRAY RENC (K)  BMT CAST_SENS_PROS CLEAN_PD CLINICAL_TRIAL DEN_OCM3 DUAL_PTD_LIS EP_LENGTH INST LOW_RISK_BLAD MBI 
				    NUM_OCM1 NUM_OCM2 NUM_OCM3 PTD_CHEMO RADIATION RECON_ELIG SURGERY ;
	ARRAY RENC2 (K) BMT_prior	CAST_SENS_PROS_prior  CLEAN_PD_prior  CLINICAL_TRIAL_prior DEN_OCM3_prior  DUAL_PTD_LIS_prior  
					EP_LENGTH_prior INST_prior LOW_RISK_BLAD_prior MBI_prior  NUM_OCM1_prior NUM_OCM2_prior NUM_OCM3_prior PTD_CHEMO_prior RADIATION_prior
			        RECON_ELIG_prior SURGERY_prior      ;

	DO K = 1 TO DIM(RENC) ;
		RENC2 = RENC ;
	END ;	

	

	drop 	K L EP_ID EP_BEG  EP_END   EP_LENGTH  RECON_ELIG  DUAL_PTD_LIS  INST	 RADIATION HRR_REL_COST  SURGERY  CLINICAL_TRIAL
				    BMT	CLEAN_PD  PTD_CHEMO	ACTUAL_EXP BASELINE_PRICE EXPERIENCE_ADJ ACTUAL_EXP_UNADJ LOW_RISK_BLAD	 CAST_SENS_PROS MBI	
					BENCHMARK_PRICE TARGET_PRICE OCM_DISCOUNT_ACO NOVEL_THERAPIES NUM_OCM1 NUM_OCM2 NUM_OCM3 DEN_OCM3	EXP_ALL_SERVICES
					EXP_INP_ADMSNS EXP_OBS_STAY EXP_ED EXP_RAD_ONCLGY EXP_PHY_SRVC EXP_MEOS	 EXP_ANC_SRVC	EXP_OUT_OTHER EXP_HHA EXP_SNF
					EXP_LTCH EXP_IRF EXP_HSP EXP_DME_EXCL_DRUGS EXP_PART_B_DRUGS EXP_PD EXP_OTHER ;
run ;
	

proc sort data=epiatt ; by bene_id ep_id ;
proc sort data=prior ; by bene_id ep_id_prior ;

data current old(keep=bene_id BENE_IN_PRIOR ep_id_prior) ;
	merge epiatt(in=a) prior(in=b DROP = DOB DOD SEX FIRST_NAME LAST_NAME ZIPCODE AGE BEG_YYMM END_YYMM)	; by bene_id ;
	format bene_in_prior $4. ; length bene_in_prior $4. ;

	fORMAT  		EP_BEG_match_prior  BENE_HICN_MATCH_PRIOR EP_LENGTH_match_prior CANCER_TYPE_match_prior PTD_CHEMO_match_prior RECON_ELIG_match_prior 
					DUAL_PTD_LIS_match_prior  INST_match_prior RADIATION_match_prior HCC_GRP_match_prior  SURGERY_match_prior  CLINICAL_TRIAL_match_prior 
					BMT_match_prior	CLEAN_PD_match_prior LOW_RISK_BLAD_match_prior	 CAST_SENS_PROS_match_prior MBI_match_prior epi_in_prior bene_in_prior $4. ;
	LENGTH  		EP_BEG_match_prior  BENE_HICN_MATCH_PRIOR EP_LENGTH_match_prior CANCER_TYPE_match_prior PTD_CHEMO_match_prior RECON_ELIG_match_prior 
					DUAL_PTD_LIS_match_prior  INST_match_prior RADIATION_match_prior HCC_GRP_match_prior  SURGERY_match_prior  CLINICAL_TRIAL_match_prior 
					BMT_match_prior	CLEAN_PD_match_prior LOW_RISK_BLAD_match_prior	 CAST_SENS_PROS_match_prior MBI_match_prior epi_in_prior bene_in_prior $4. ;

	***  Initialize all matching flags *** ;
	bene_in_prior = "    " ;
	epi_in_prior = "No " ;
	array flags (z) EP_BEG_match_prior  BENE_HICN_MATCH_PRIOR EP_LENGTH_match_prior CANCER_TYPE_match_prior PTD_CHEMO_match_prior RECON_ELIG_match_prior 
					DUAL_PTD_LIS_match_prior  INST_match_prior RADIATION_match_prior HCC_GRP_match_prior  SURGERY_match_prior  CLINICAL_TRIAL_match_prior 
					BMT_match_prior	CLEAN_PD_match_prior LOW_RISK_BLAD_match_prior	 CAST_SENS_PROS_match_prior MBI_match_prior ;
	do z = 1 to dim(flags) ;
		flags = "N/A" ;
	end ;

	if a and b then do ;
			bene_in_prior = "Yes" ;

			if ep_id = ep_id_prior then epi_in_prior = "Yes" ;

			ARRAY FLAGN (T) EP_BEG_match_prior  BENE_HICN_MATCH_PRIOR EP_LENGTH_match_prior CANCER_TYPE_match_prior RECON_ELIG_match_prior 
						    DUAL_PTD_LIS_match_prior  INST_match_prior RADIATION_match_prior HCC_GRP_match_prior 
						    SURGERY_match_prior  CLINICAL_TRIAL_match_prior BMT_match_prior	CLEAN_PD_match_prior  	
						    LOW_RISK_BLAD_match_prior	 CAST_SENS_PROS_match_prior MBI_match_prior PTD_CHEMO_match_prior ;
			DO T = 1 TO DIM(FLAGN) ;
				FLAGN = "No" ;
			END ;

			IF EP_BEG = EP_BEG_PRIOR THEN EP_BEG_MATCH_PRIOR = "Yes" ;
			IF BENE_HICN = BENE_HICN_PRIOR THEN BENE_HICN_MATCH_PRIOR = "Yes" ;
			IF EP_LENGTH = EP_LENGTH_PRIOR THEN EP_LENGTH_MATCH_PRIOR = "Yes" ;
			IF CANCER_TYPE = CANCER_TYPE_PRIOR THEN CANCER_TYPE_MATCH_PRIOR = "Yes" ;
			IF RECON_ELIG = RECON_ELIG_PRIOR THEN RECON_ELIG_MATCH_PRIOR = "Yes" ;
			IF DUAL_PTD_LIS = DUAL_PTD_LIS_PRIOR THEN DUAL_PTD_LIS_MATCH_PRIOR = "Yes" ;
			IF INST = INST_PRIOR THEN INST_MATCH_PRIOR = "Yes" ;
			IF RADIATION = RADIATION_PRIOR THEN RADIATION_MATCH_PRIOR = "Yes" ;
			IF HCC_GRP = HCC_GRP_PRIOR THEN HCC_GRP_MATCH_PRIOR = "Yes" ;
			IF SURGERY = SURGERY_PRIOR THEN SURGERY_MATCH_PRIOR = "Yes" ;
			IF CLINICAL_TRIAL = CLINICAL_TRIAL_PRIOR THEN CLINICAL_TRIAL_MATCH_PRIOR = "Yes" ;
			IF BMT = BMT_PRIOR THEN BMT_MATCH_PRIOR = "Yes" ;
			IF CLEAN_PD = CLEAN_PD_PRIOR THEN CLEAN_PD_MATCH_PRIOR = "Yes" ;
			IF LOW_RISK_BLAD = LOW_RISK_BLAD_PRIOR THEN LOW_RISK_BLAD_MATCH_PRIOR = "Yes" ;
			IF CAST_SENS_PROS=CAST_SENS_PROS_PRIOR THEN CAST_SENS_PROS_MATCH_PRIOR = "Yes" ;
			IF MBI = MBI_PRIOR THEN MBI_MATCH_PRIOR = "Yes" ;
			IF PTD_CHEMO = PTD_CHEMO_PRIOR THEN PTD_CHEMO_MATCH_PRIOR = "Yes" ;

	end ;
	else if a and b=0 then bene_in_prior = "No" ;
	else if a=0 and b then bene_in_prior = "Drop" ;

	drop T Z ;

	if a then output current ;
	if (a=0 and b) or epi_in_prior = "No" then output old ;





proc sort data=old ; by bene_id ep_id_prior ;
proc sort data=prior; by bene_id ep_id_prior ;

data old_keep ;
	merge prior(in=a) old(in=b keep = bene_id bene_in_prior ep_id_prior ) ; by bene_id ep_id_prior ;
	if a and b ;
	Prior_Changed_Episode = "Yes" ;
	EP_ID = EP_ID_PRIOR ;

data REC.EPIATT&tu._&dsid._PP&pp.;
	set current(in=a) old_keep ;
	if a and epi_in_prior = "No" then do  ;

	array ren2 (l) 	EP_ID_prior EP_BEG_prior  EP_END_prior HRR_REL_COST_prior   ACTUAL_EXP_prior BASELINE_PRICE_prior EXPERIENCE_ADJ_prior ACTUAL_EXP_UNADJ_prior 		
					BENCHMARK_PRICE_prior TARGET_PRICE_prior OCM_DISCOUNT_ACO_prior NOVEL_THERAPIES_prior  
				    EXP_ALL_SERVICES_prior EXP_INP_ADMSNS_prior EXP_OBS_STAY_prior EXP_ED_prior EXP_RAD_ONCLGY_prior EXP_PHY_SRVC_prior
				    EXP_MEOS_prior  EXP_ANC_SRVC_prior	EXP_OUT_OTHER_prior EXP_HHA_prior EXP_SNF_prior EXP_LTCH_prior EXP_IRF_prior EXP_HSP_prior
				    EXP_DME_EXCL_DRUGS_prior EXP_PART_B_DRUGS_prior EXP_PD_prior EXP_OTHER_prior ;
	do l = 1 to dim(ren2) ;
		ren2 = . ;
	end ;

	ARRAY RENC2 (K) BMT_prior	CAST_SENS_PROS_prior  CLEAN_PD_prior  CLINICAL_TRIAL_prior DEN_OCM3_prior  DUAL_PTD_LIS_prior  
					EP_LENGTH_prior INST_prior LOW_RISK_BLAD_prior MBI_prior  NUM_OCM1_prior NUM_OCM2_prior NUM_OCM3_prior PTD_CHEMO_prior RADIATION_prior
			        RECON_ELIG_prior SURGERY_prior   ;
	do k = 1 to dim(renc2) ;
		renc2 = "  " ;
	end ;

	bene_hicn_prior = "  " ;
	cancer_type_prior = "  " ;
	hcc_grp_prior = "   " ;

	drop l k ;

	end ;

PROC FREQ DATA= REC.EPIATT&tu._&dsid._PP&pp. ;
	TABLES bene_in_prior*epi_in_prior*Prior_Changed_Episode/LIST MISSING ;
TITLE "&DSID. Distribution of In Performance Data Flag" ;

%end ;
	
PROC SORT DATA=	REC.EPIATT&tu._&dsid._PP&pp. ; BY EP_ID BENE_ID ;
PROC FREQ DATA= REC.EPIATT&tu._&dsid._PP&pp. ;
	TABLES RECON_PP1_FLAG*IN_PERFORMANCE/LIST MISSING ;
TITLE "&DSID. Distribution of In Performance Data Flag" ;


%mend epi ;
********************************************************************** ;
********************************************************************** ;
****** %macro epi(dsid) ;
********************************************************************** ;
********************************************************************** ;

%epi(137_50136,0) ; run ; 
%epi(255_50179,0) ; run ;
%epi(257_50195,0) ; run ;
%epi(278_50193,0) ; run ;
%epi(280_50115,0) ; run ; 
%epi(290_50202,0) ; run ;
%epi(396_50258,0) ; run ;
%epi(480_50185,0) ; run ;
%epi(468_50227,0) ; run ; 
%epi(459_50243,0) ; run ;
%epi(401_50228,0) ; run ; 
%epi(523_50330,0) ; run ;

*** Only available in PP1  *** ;
%epi(567_50200,1) ; run ;
%epi(568_50201,1) ; run ;
