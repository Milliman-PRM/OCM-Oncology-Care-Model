********************************************************************** ;
		***** 052_BM_Episode Identification_v6.sas ***** ;
********************************************************************** ;
**** Based on Appendix A-C in OCM PBP Methodology.PDF **************** ;
	*** Part D Triggers Unavailable for this Dataset *** ;
********************************************************************** ;

libname in12 "\\chic-win-fs2\CMS\5pct_sample\2012\Raw" ; 
libname in13 "\\chic-win-fs2\CMS\5pct_sample\2013\Raw" ; 
libname in14 "\\chic-win-fs2\CMS\5pct_sample\2014\Raw" ; 
libname in15 "\\chic-win-fs2\CMS\5pct_sample\2015\Raw" ; 
libname in16 "\\chic-win-fs2\CMS\5pct_sample\2016\Annual\Raw" ; 
libname in17 "\\chic-win-fs2\CMS\5pct_sample\2017\Annual\Raw" ; 
libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\08 - Benchmark Data\BM2 - 5pct Benchmark Files" ;
RUN ;

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
********************************************************************** ;
********************************************************************** ;

options ls=132 ps=70 obs=MAX; run ;


%let hlthsas=10.10.10.21;                                                                                                                                                             
                options remote=hlthsas comamid=tcp;                                                                                                                                                 
                filename rlink '!sasroot\connect\saslink\tcpwin.scr';

data PGM=sasuser.uidpass; run;								
signon;		
run ;

********************************************************************** ;
********************************************************************** ;
**** Step 1: Identify patients with cancer related E&M claims ******** ;
%macro step1 ;
rsubmit ;

options obs=max ; 
libname in16 "\\chic-win-fs2\CMS\5pct_sample\2016\Annual\Raw" ; 
libname in17 "\\chic-win-fs2\CMS\5pct_sample\2017\Annual\Raw" ; 
libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\08 - Benchmark Data\BM2 - 5pct Benchmark Files" ;

*** Initiating therapy lists *** ;
%include "\\chic-win-fs2\HealthResearch\Sharing\NYRK\JH\OCM\000_Formats PP4.sas" ;
*** Cancer diagnosis code lists *** ;
%include "\\chic-win-fs2\HealthResearch\Sharing\NYRK\JH\OCM\000_Cancer Formats PP3.sas" ;
*** Cancer assignment macro  *** ;
%include "\\chic-win-fs2\HealthResearch\Sharing\NYRK\JH\OCM\000_Cancer Diagnoses_5.sas" ;


data Lines_5Pct Chemo_A EM_5pct ;

	set in16.raw_dme_linek_5_2016 in16.raw_pb_linek_5_2016(in=a) 
		in17.raw_dme_linek_5_2017 in17.raw_pb_linek_5_2017(in=a) ;


	%canc_init ;

	if a then carr = 1 ;
	%CANCERTYPE(LINE_ICD_DGNS_VRSN_CD, LINE_ICD_DGNS_CD) ;

	** E&M claims with cancer diagnosis for episode qualification in subsequent steps ** ;
	if a and HCPCS_CD in ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215')
		and LALOWCHG > 0 and has_cancer = 1 then output EM_5pct ;

	**The claim must contain a line item HCPCS code indicating an included chemotherapy drug 
	  (initiating cancer therapy) in any line item. ** ;
	if put(HCPCS_CD,$Chemo_J4p.) = "Y" then do ;

		**The chemotherapy drug line item must have a “line first expense date” in the appropriate 
		  6 month “Episodes Beginning” period in Table 1, inclusive of end dates. ** ;
		**** Episodes begin 7/2016-6/2017, run through 12/2017 **** ;
		if mdy(7,1,2016) le EXPNSDT2 le mdy(6,30,2017) then do ;

			**The chemotherapy drug line item must not be denied (line allowed charge >0). ** ;
			if LALOWCHG > 0 then do ;

				**The chemotherapy drug line place of service must not be an inpatient hospital (21). ** ;
				if PLCSRVC ne '21' then do ;
					chemo = 1  ;
					output Chemo_A ;
				end ;

			end ;

		end ;

	end ;

	output Lines_5pct ;

	** The chemotherapy drug claim must contain an included cancer diagnosis code available on the CMS OCM website) 
   		in any non-denied line item on the same claim (does not have to be same line as HCPCS code above -
   		do not use the header diagnoses).  ** ;

data header ;
	set in16.raw_dme_claimsk_5_2016 in16.raw_pb_claimsk_5_2016
		in17.raw_dme_claimsk_5_2017 in17.raw_pb_claimsk_5_2017 ;


proc sort data=header out=ph(KEEP = desy_sort_key claim_no thru_dt PRNCPAL_DGNS_CD PRNCPAL_DGNS_VRSN_CD ICD_DGNS:)
			  nodupkey ; by  desy_sort_key claim_no thru_dt ;

proc sort data=Lines_5Pct ; by  desy_sort_key claim_no thru_dt ;
proc sort data=Chemo_A out=chemo2(keep =  desy_sort_key claim_no thru_dt) nodupkey ; 
							by  desy_sort_key claim_no thru_dt ;

data chemo_5pct ;
	merge Lines_5Pct(in=a) chemo2(in=b) PH  ; by  desy_sort_key claim_no thru_dt ;
	if a and b ;

	IF PRNCPAL_DGNS_VRSN_CD in ("0"," ") AND 
	   PRNCPAL_DGNS_CD IN ('Z5111','Z5112') THEN ZFLAG = 1 ;
	ELSE IF PRNCPAL_DGNS_VRSN_CD in ("9") AND 
	   PRNCPAL_DGNS_CD IN ('V5811','V5812') THEN ZFLAG = 1 ;
	ELSE ZFLAG = 0 ;

	HAS_CANCER_LINE = HAS_CANCER ;

	%canc_init ;

	ARRAY DX (I) ICD_DGNS_CD: ;
	ARRAY VX (I) ICD_DGNS_VRSN: ;
	DO I = 1 TO DIM(DX);
		if vx+0 = . then vx = "0" ;
		%CANCERTYPE(VX, DX) ;
	END ;

	output chemo_5pct ;


proc download data=Lines_5Pct out=out.Lines_5Pct ; run ;
proc download data=Chemo_5Pct out=out.Chemo_5Pct ; run ;
proc download data=EM_5Pct out=out.EM_5Pct ; run ;

run ;

	**** Combining files *****;

data OP_CHEMO_REV ;
	set in16.raw_op_revenuek_5_2016  in17.raw_op_revenuek_5_2017(in=a)  ;
	**The claim must contain a HCPCS code indicating an included chemotherapy drug (initiating cancer therapy) 
	  in any revenue center. ** ;
	if put(HCPCS_CD,$Chemo_J4p.) =  "Y"  then do ;
		** The revenue center date on the same revenue center in which the HCPCS code is found must be in the 
		   appropriate 6 month Episode Beginning period in Table 1, inclusive of end dates ** ;
		if MDY(7,1,2016) LE REV_DT LE MDY(6,30,2017) then do ;
			** The revenue center in which the HCPCS code is found must not be denied (revenue center 
			   total charge amount minus revenue center non-covered charge amount > 0). ** ;
			** The claim must not be denied (Medicare non-payment reason code is not blank). ** ;
			if /*NOPAY_CD =  "  "    AND*/ REV_CHRG - REV_NCVR > 0 THEN OUTPUT ;
		END ;
	END ;

PROC SORT  DATA=OP_CHEMO_REV ; BY DESY_SORT_KEY CLAIM_NO THRU_DT ;
DATA OPCLAIMS ;
	SET in16.RAW_OP_CLAIMSk_5_2016 in17.RAW_OP_CLAIMSk_5_2017  ;
	*** Need to expand to 1 month outside timeframe since FROM_DT is not captured on header file. *** ;
	if MDY(6,1,2016) LE THRU_DT LE MDY(7,31,2017) ;
	if nopay_cd = "  " ;

PROC SORT DATA=OPCLAIMS ; BY DESY_SORT_KEY CLAIM_NO THRU_DT ;

DATA OUTPATIENT_CHEMO ;
	MERGE OP_CHEMO_REV(IN=A) OPCLAIMS(IN=B) ; BY DESY_SORT_KEY CLAIM_NO THRU_DT ;
	IF A AND B ;

PROC DOWNLOAD DATA=OUTPATIENT_CHEMO OUT=OUT.OUTPATIENT_CHEMO_5PCT ; RUN ;
endrsubmit ;
%mend step1 ;

%step1 ;
run ;

********************************************************************** ;
********************************************************************** ;
**** Step 2: Identify potential episodes ;

** For each potential trigger claim identified in Step 1, flag whether the 6 months following the 
   trigger date meet the three criteria below. Episodes will be end-dated 6 calendar months after the 
   trigger date, even in the case of death before 6 months. ** ;

%macro step2 ;
**** Step 2: Identify patients with cancer related E&M claims ******** ;
	** The chemotherapy drug claim must contain an included cancer diagnosis code available on the CMS OCM website) 
   		in any non-denied line item on the same claim (does not have to be same line as HCPCS code above -
   		do not use the header diagnoses).  ** ;

options obs=max;

DATA out.chemo_claims out.chemoz ; ;
	SET OUT.CHEMO_5PCT ;
	KEY1 = compress(DESY_SORT_KEY||CLAIM_NO||THRU_DT,"- ") ;
	format trigger_date mmddyy10. ;
	**	The trigger date is the line first expense date on the qualifying chemotherapy drug line. *** ;
	if chemo = 1 then trigger_date = expnsdt2 ;

	output out.chemo_claims ;
	if zflag = 1 then output out.chemoz ;

/*
proc sort data=chemo nodupkey; by key1 ;
data clmkey (keep= fmtname start label hlo);
	set chemo(rename=(key1=start)) end = eof;
	fmtname = '$clmkey';
	format label $1.;
	label = 'Y';
	output;
	if eof then do;
		call missing(start);
		*call missing(end);
		hlo = 'O';
		label = 'N'; 
	output;end;
run;
quit ;

proc sort data=clmkey nodupkey;
	by start hlo;
run;
proc format cntlin=clmkey;
run;


data out.chemo_claims ;
	set out.lines_5pct ;
	KEY1 = compress(DESY_SORT_KEY||CLAIM_NO||THRU_DT,"- ") ;
	if put(key1,$clmkey.) = "Y" ; 
	format trigger_date mmddyy10. ;
	**	The trigger date is the line first expense date on the qualifying chemotherapy drug line. *** ;
	if chemo = 1 then trigger_date = expnsdt2 ;
run ;

proc sort data=out.chemo_claims out=chemo_claims ; by  key1 DESY_SORT_KEY  CLAIM_NO thru_dt carr ;
proc means data=chemo_claims noprint min max ; by  key1 DESY_SORT_KEY  CLAIM_NO thru_dt carr;
	var has_cancer UROTHELIAL trigger_date ;
	output out=chemo_flag(drop = _freq_ _type_)
		   max(has_cancer UROTHELIAL ) = 
		   min(trigger_date) = ;	
data chemo_candidates1 ;
	set chemo_flag ;
	if has_cancer = 1 ;
run ;
*/

proc sort data=out.chemo_claims ; by  key1 DESY_SORT_KEY  CLAIM_NO thru_dt carr ;
proc means data=out.chemo_claims noprint min max ; by  key1 DESY_SORT_KEY  CLAIM_NO thru_dt carr;
	var has_cancer HAS_CANCER_LINE UROTHELIAL trigger_date ;
	output out=chemo_flag(drop = _freq_ _type_)
		   max(has_cancer HAS_CANCER_LINE UROTHELIAL ) = 
		   min(trigger_date ) = ;	

data chemo_candidates1 ;
	set chemo_flag(in=a) out.chemoz(in=b) ;
	if (a and has_cancer_LINE = 1) OR (b AND HAS_CANCER = 1) ;


DATA chemo_candidates2(keep =  DESY_SORT_KEY key1 CLAIM_NO thru_dt trigger_date has_cancer UROTHELIAL)  ;
	SET out.OUTPATIENT_CHEMO_5PCT ;
	
	KEY1 = compress(DESY_SORT_KEY||CLAIM_NO||THRU_DT,"- ") ;

		%canc_init ;

		ARRAY v (I) ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD25 ;
		ARRAY d (I) ICD_DGNS_CD1-ICD_DGNS_CD25 ;
		DO I = 1 TO 25 ;
			IF v = " " then v = 0 ;
			%CANCERTYPE(v, d) ;
		END ;
		DROP I ;

		format trigger_date mmddyy10. ;
		if has_cancer = 1 then do ;
			chemo = 1 ; 
			trigger_date = rev_dt ;
			OUTPUT CHEMO_CANDIDATES2 ;
		END ;

data triggers ;
	set chemo_candidates1(in=a) 
		chemo_candidates2(in=b) ;
	if a and carr = 1 then source = 2 ; *** carrier is second in hierarchy *** ;
	if b then source = 1 ; *** outpatient is first in hierarchy *** ;
	if a and carr ne 1 then source = 3 ; *** DME is third in hierarchy *** ;
	format EP_END mmddyy10. ;
	EP_END = intnx('month', trigger_date, 6,'same')-1 ;

proc sort data=triggers out=triggers_b nodupkey ; by  DESY_SORT_KEY trigger_date source CLAIM_NO ;

***********
Apply the following hierarchy if there is more than one trigger claim on the same day from different 
types of service: Outpatient, Carrier, DMEPOS, Part D
If there is still more than one trigger claim on the same day within the same type of service, 
choose the claim with the first claim ID. ********* ;

data triggersa ;
	set triggers_b ; by  DESY_SORT_KEY trigger_date ;
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
	set triggersa ; by  DESY_SORT_KEY trigger_date source CLAIM_NO ;
	if first.CLAIM_NO ;

** A trigger claim initiates an episode only when all of the below criteria are met.;
** For all performance periods, the potential episode trigger date must not be included 
   in any episode defined for a prior performance period.  6 Potential trigger claims occurring 
   inside a previously defined episode cannot trigger a new episode. ** ;
data triggers2 ;
	set triggersb ; by  DESY_SORT_KEY ;
	format pend mmddyy10. ; 
	if first.DESY_SORT_KEY then do ;
		keep_epi = 1 ;
		pend = EP_END ;
	end ;
	else do ;
		if trigger_date le pend then do ;
			pend = pend ;
			keep_epi = 0 ;
		end ;
		else do ;
			pend = EP_END ;
			keep_epi = sum(keep_epi,1) ;
		end ;
	end ;
	retain pend keep_epi;
	if keep_epi > 0 ;

** The 6 month period beginning with the trigger date must contain a non-denied Carrier claim with an 
   E&M visit (HCPCS code 99201 – 99205, 99211 – 99215) AND an included cancer diagnosis code on the same line item. ** ;
proc sql ;
	create table out.triggers3_5pct	 as
	select a.DESY_SORT_KEY, a.trigger_date, a.source, a.CLAIM_NO, a.EP_END, a.keep_epi
	from triggers2 as a, out.em_5PCT as b
	where a.DESY_SORT_KEY=b.DESY_SORT_KEY and 
		  trigger_date le b.expnsdt2 le EP_END ;
proc sort data=out.triggers3_5pct nodupkey ; by  DESY_SORT_KEY keep_epi trigger_date ;

run ;

%MEND STEP2 ;
run ;

%STEP2 ;
run ;



********************************************************************** ;
********************************************************************** ;
**** Step 3: Identify final set of episodes ;
*** Pull Membership Data for Potential triggers *** ;

%MACRO STEP3A ;
proc sort data=out.triggers3_5pct out=OUT.STEP3A_candidates (keep = desy_sort_key ) nodupkey ; 
	by desy_sort_key ;
RUN ;

rsubmit ;
options obs=max ; 
libname in16 "\\chic-win-fs2\CMS\5pct_sample\2016\Annual\Raw" ; 
libname in17 "\\chic-win-fs2\CMS\5pct_sample\2017\Annual\Raw" ; 

*** Initiating therapy lists *** ;
%include "\\chic-win-fs2\HealthResearch\Sharing\NYRK\JH\OCM\000_Formats PP4.sas" ;
*** Cancer diagnosis code lists *** ;
%include "\\chic-win-fs2\HealthResearch\Sharing\NYRK\JH\OCM\000_Cancer Formats PP3.sas" ;
*** Cancer assignment macro  *** ;
%include "\\chic-win-fs2\HealthResearch\Sharing\NYRK\JH\OCM\000_Cancer Diagnoses_5.sas" ;

libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\08 - Benchmark Data\BM2 - 5pct Benchmark Files" ;

proc upload data=OUT.STEP3A_candidates out=candidates ; run ;

data memkey (keep= fmtname start end label hlo);
	set candidates(rename=(desy_sort_key=start)) end = eof;
	fmtname = '$memkey';
	format label $1.;
	label = 'Y';
	output;
	if eof then do;
		call missing(start);
		*call missing(end);
		hlo = 'O';
		label = 'N'; 
	output;end;
run;

proc sort data=memkey nodupkey;
	by start hlo;
run;
proc format cntlin=memkey;
run;

data member16 ;
	set in16.raw_mems_2016(in=a DROP=BUYIN_MO)  ;
	IF NOT MISSING(DESY_SORT_KEY) ;
	IF PUT(DESY_SORT_KEY, $MEMKEY.) = "Y" ; 
	FORMAT DOD16 MMDDYY10. ;
	MD = SUBSTR(LEFT(DEATH_DT),5,2) ;
	DD = SUBSTR(LEFT(DEATH_DT),7,2) ;
	YD = SUBSTR(LEFT(DEATH_DT),1,4) ;
	DOD16 =  MDY(MD, DD, YD) ;
	DROP MD DD YD ;

	informat BUYIN1_16 BUYIN2_16 BUYIN3_16 BUYIN4_16 BUYIN5_16 BUYIN6_16 BUYIN7_16 BUYIN8_16
					  BUYIN9_16 BUYIN10_16 BUYIN11_16 BUYIN12_16 
			 HMOIND1_16 HMOIND2_16 HMOIND3_16 HMOIND4_16 HMOIND5_16 HMOIND6_16 HMOIND7_16 HMOIND8_16 
					  HMOIND9_16 HMOIND10_16 HMOIND11_16 HMOIND12_16
					  MS_CD_16 $3. ;
	if a then do ;
		AGE_16 = AGE ; AGE = . ;

		ARRAY VARS (I) BUYIN1 BUYIN2 BUYIN3 BUYIN4 BUYIN5 BUYIN6 BUYIN7 BUYIN8
					   BUYIN9 BUYIN10 BUYIN11 BUYIN12 
			 		   HMOIND1 HMOIND2 HMOIND3 HMOIND4 HMOIND5 HMOIND6 HMOIND7 HMOIND8 
					   HMOIND9 HMOIND10 HMOIND11 HMOIND12 MS_CD ;
		ARRAY REN (I) BUYIN1_16 BUYIN2_16 BUYIN3_16 BUYIN4_16 BUYIN5_16 BUYIN6_16 BUYIN7_16 BUYIN8_16
					  BUYIN9_16 BUYIN10_16 BUYIN11_16 BUYIN12_16 HMOIND1_16 HMOIND2_16 HMOIND3_16 HMOIND4_16 
					  HMOIND5_16 HMOIND6_16 HMOIND7_16 HMOIND8_16 HMOIND9_16 HMOIND10_16 HMOIND11_16 HMOIND12_16
					  MS_CD_16 ;
		DO I = 1 TO DIM(VARS) ;
			REN = VARS ;
			VARS = " " ;
		END ;
	END ;

data member17 ;
	set in17.raw_mbsf_5_2017(DROP=BUYIN_MO ) ;
	format MS_CD $2.;
	IF PUT(DESY_SORT_KEY, $MEMKEY.) = "Y" ; 
	FORMAT DOD17 MMDDYY10. ;
	MD = MONTH(DEATH_DT) ;
	DD = DAY(DEATH_DT) ;
	YD = YEAR(DEATH_DT) ;
	DOD17 =  MDY(MD, DD, YD) ;
	DROP MD DD YD ;
	MS_CD = MDCR_STUS_CD_1;

PROC SQL ;
	CREATE TABLE MEMBER16A AS
	SELECT DISTINCT * 
	FROM MEMBER16 ;
	CREATE TABLE MEMBER17A AS
	SELECT DISTINCT * 
	FROM MEMBER17 ;
QUIT ;

*** Remove members who have more than one record assigned to a beneficiary ID *** ;
proc sort data=member16A ; by desy_sort_key ;
proc sort data=member17A ; by desy_sort_key ;
DATA MEMBER17B ;
	SET MEMBER17A ; BY DESY_SORT_KEY ;
	IF FIRST.DESY_SORT_KEY AND LAST.DESY_SORT_KEY ;
DATA MEMBER16B ;
	SET MEMBER16A ; BY DESY_SORT_KEY ;
	IF FIRST.DESY_SORT_KEY AND LAST.DESY_SORT_KEY ;

data member_flags ;
	merge member16B(keep = desy_sort_key buyin: hmoind: ms_cd_16 SEX)
		  member17B(keep = desy_sort_key buyin: hmoind: ms_cd SEX)	; by desy_sort_key;

data membership ;
	set member16B member17B ;
PROC SORT DATA=MEMBERSHIP ; BY DESY_SORT_KEY ;
PROC MEANS DATA=MEMBERSHIP NOPRINT MAX ; BY DESY_SORT_KEY ;
	VAR DOD16 DOD17 AGE: ;
	OUTPUT OUT=MEMB_FLAGS(DROP = _TYPE_ _FREQ_)
		   MAX() = ;
DATA UNIQ_MEMBS(KEEP = DESY_SORT_KEY DROPMEMB) ;
	SET MEMBERSHIP ; BY DESY_SORT_KEY ;
	IF FIRST.DESY_SORT_KEY THEN DO ;
		PREV_YR = RFRNC_YR ;
		PREVMEMB = DESY_SORT_KEY ;
		DROPMEMB = 0 ;
	END ;
	ELSE DO ;
		IF DESY_SORT_KEY = PREVMEMB THEN DO ;
			IF RFRNC_YR = PREV_YR THEN DROP = 1 ;
			ELSE DROPMEMB = 0 ;
		END ;
		ELSE DO ; DROPMEMB = 0 ;
		PREV_YR = RFRNC_YR ;
		PREVMEMB = DESY_SORT_KEY ;
		end ;
	END ;
	RETAIN PREVMEMB PREV_YR ;
PROC MEANS DATA=UNIQ_MEMBS NOPRINT MAX ; BY DESY_SORT_KEY ;
	VAR DROPMEMB ;
	OUTPUT OUT=UM (DROP = _TYPE_ _FREQ_)
		   MAX() = ;

DATA MEMBERSHIP_FINAL ;
	MERGE MEMB_FLAGS(IN=A) UM(IN=B) MEMBER_FLAGS(IN=C); BY DESY_SORT_KEY ;
	IF A AND C;
	IF DROPMEMB = 1 THEN DELETE ;
	FORMAT DOD MMDDYY10. ;
	IF DOD16 NE . AND DOD17 NE . THEN DOD = MAX(DOD16,DOD17) ;
	ELSE IF DOD16 NE . THEN DOD = DOD16 ;
	ELSE DOD = DOD17 ;

PROC DOWNLOAD DATA=MEMBERSHIP_FINAL OUT=OUT.MEMBERSHIP_FINAL_5PCT ; RUN ;

ENDRSUBMIT ; RUN ;
%MEND STEP3A ;

%STEP3A ;
RUN ;

**The beneficiary must meet the criteria below for the entire 6 month period (or until death) beginning with the trigger date, inclusive of end dates:
• Beneficiary is enrolled in Medicare Parts A and B
• Beneficiary does not receive the Medicare ESRD benefit, as determined by the Medicare Enrollment Database
• Beneficiary has Medicare as his or her primary payer
• Beneficiary is not covered under Medicare Advantage or any other group health program. ** ;
%MACRO STEP3B ;

data OUT.episode_candidates ;
	MERGE OUT.triggers3_5PCT(IN=A) OUT.MEMBERSHIP_FINAL_5PCT(IN=B) ; BY DESY_SORT_KEY ;
	IF A AND B ;

	FORMAT T1 T2 T3 T4 T5 T6 T7 MMDDYY10. 
		   KF1-KF7 $3. ;
	T1 = TRIGGER_DATE ;
	T2 = INTNX('MONTH',TRIGGER_DATE,1,'SAME') ;	
	T3 = INTNX('MONTH',TRIGGER_DATE,2,'SAME') ;	
	T4 = INTNX('MONTH',TRIGGER_DATE,3,'SAME') ;	
	T5 = INTNX('MONTH',TRIGGER_DATE,4,'SAME') ;	
	T6 = INTNX('MONTH',TRIGGER_DATE,5,'SAME') ;	
	T7 = INTNX('MONTH',TRIGGER_DATE,5,'SAME')-1 ;	

	*** Check for DOD *** ;
	dth_ym = year(DOD)*100 + month(DOD) ;
	if year(trigger_date)*100+month(trigger_date) = dth_ym then do ;
	   t2 = t1 ; t3 = t1 ; t4 = t1 ; t5 = t1 ; t6 = t1 ; t7 = t1 ;
	end ;
	else if year(t2)*100+month(t2) = dth_ym then do ;
		t3 = t2 ; t4 = t2 ; t5 = t2 ; t6 = t2 ; t7 = t2 ;
	end ;
	else if year(t3)*100+month(t3) = dth_ym then do ;
		t4 = t3 ; t5 = t3 ; t6 = t3 ; t7 = t3 ;
	end ;
	else if year(t4)*100+month(t4) = dth_ym then do ;
		t5 = t4 ; t6 = t4 ; t7 = t4 ;
	end ;
	else if year(t5)*100+month(t5) = dth_ym then do ;
		t6 = t5 ; t7 = t5 ;
	end ;
	else if year(t6)*100+month(t6)=dth_ym then do ;
		t7 = t6 ;
	end ;
	
	ARRAY TRIGS (TRI) t1-t7 ;
	ARRAY YRS (TRI) Y1-Y7 ;
	ARRAY MOS (TRI) M1-M7 ;
	array keepflag (TRI) kf1-kf7 ;
	array valid_month (TRI) vm1-vm7 ;
	DO TRI = 1 TO DIM(TRIGS) ;
		YRS = YEAR(TRIGS) ;
		MOS = MONTH(TRIGS) ;
		IF YRS = 2016 THEN DO ;
			IF MOS = 1 THEN KEEPFLAG = COMPRESS(BUYIN1_16,' ')||"-"||COMPRESS(HMOIND1_16,' ') ;
			IF MOS = 2 THEN KEEPFLAG = COMPRESS(BUYIN2_16,' ')||"-"||COMPRESS(HMOIND2_16,' ') ;
			IF MOS = 3 THEN KEEPFLAG = COMPRESS(BUYIN3_16,' ')||"-"||COMPRESS(HMOIND3_16,' ') ;
			IF MOS = 4 THEN KEEPFLAG = COMPRESS(BUYIN4_16,' ')||"-"||COMPRESS(HMOIND4_16,' ') ;
			IF MOS = 5 THEN KEEPFLAG = COMPRESS(BUYIN5_16,' ')||"-"||COMPRESS(HMOIND5_16,' ') ;
			IF MOS = 6 THEN KEEPFLAG = COMPRESS(BUYIN6_16,' ')||"-"||COMPRESS(HMOIND6_16,' ') ;
			IF MOS = 7 THEN KEEPFLAG = COMPRESS(BUYIN7_16,' ')||"-"||COMPRESS(HMOIND7_16,' ') ;
			IF MOS = 8 THEN KEEPFLAG = COMPRESS(BUYIN8_16,' ')||"-"||COMPRESS(HMOIND8_16,' ') ;
			IF MOS = 9 THEN KEEPFLAG = COMPRESS(BUYIN9_16,' ')||"-"||COMPRESS(HMOIND9_16,' ') ;
			IF MOS = 10 THEN KEEPFLAG = COMPRESS(BUYIN10_16,' ')||"-"||COMPRESS(HMOIND10_16,' ') ;
			IF MOS = 11 THEN KEEPFLAG = COMPRESS(BUYIN11_16,' ')||"-"||COMPRESS(HMOIND11_16,' ') ;
			IF MOS = 12 THEN KEEPFLAG = COMPRESS(BUYIN12_16,' ')||"-"||COMPRESS(HMOIND12_16,' ') ;
			IF KEEPFLAG IN ('3-0','3-4','C-0','C-4') AND
	   		   MS_CD_16 NOTIN ('11','21','31') THEN VALID_MONTH = 1 ;
		END ;
		IF YRS = 2017 THEN DO ;
			IF MOS = 1 THEN KEEPFLAG = COMPRESS(BUYIN1,' ')||"-"||COMPRESS(HMOIND1,' ') ;
			IF MOS = 2 THEN KEEPFLAG = COMPRESS(BUYIN2,' ')||"-"||COMPRESS(HMOIND2,' ') ;
			IF MOS = 3 THEN KEEPFLAG = COMPRESS(BUYIN3,' ')||"-"||COMPRESS(HMOIND3,' ') ;
			IF MOS = 4 THEN KEEPFLAG = COMPRESS(BUYIN4,' ')||"-"||COMPRESS(HMOIND4,' ') ;
			IF MOS = 5 THEN KEEPFLAG = COMPRESS(BUYIN5,' ')||"-"||COMPRESS(HMOIND5,' ') ;
			IF MOS = 6 THEN KEEPFLAG = COMPRESS(BUYIN6,' ')||"-"||COMPRESS(HMOIND6,' ') ;
			IF MOS = 7 THEN KEEPFLAG = COMPRESS(BUYIN7,' ')||"-"||COMPRESS(HMOIND7,' ') ;
			IF MOS = 8 THEN KEEPFLAG = COMPRESS(BUYIN8,' ')||"-"||COMPRESS(HMOIND8,' ') ;
			IF MOS = 9 THEN KEEPFLAG = COMPRESS(BUYIN9,' ')||"-"||COMPRESS(HMOIND9,' ') ;
			IF MOS = 10 THEN KEEPFLAG = COMPRESS(BUYIN10,' ')||"-"||COMPRESS(HMOIND10,' ') ;
			IF MOS = 11 THEN KEEPFLAG = COMPRESS(BUYIN11,' ')||"-"||COMPRESS(HMOIND11,' ') ;
			IF MOS = 12 THEN KEEPFLAG = COMPRESS(BUYIN12,' ')||"-"||COMPRESS(HMOIND12,' ') ;
			IF KEEPFLAG IN ('3-0','3-4','C-0','C-4') AND
	   		   MS_CD NOTIN ('11','21','31') THEN VALID_MONTH = 1 ;
		END ;
	END ;
	
	*** All 6 months of episode meet criteria *** ;
		VALID_MONTHS = SUM(VM1,VM2,VM3,VM4,VM5,VM6,VM7) ;
	IF VALID_MONTHS = 7 ;

	format EP_BEG EP_END  mmddyy10. ;
	EP_BEG = TRIGGER_DATE ;
	EP_END = intnx('month', trigger_date, 6,'same')-1 ;
	EP_LENGTH =  EP_END-EP_BEG+1 ;
	IF DOD < ep_end AND DOD NE . THEN EP_END = DOD ;
	m_epi_claim = CLAIM_NO ;
	m_epi_source = source ;
	drop trigger_date CLAIM_NO source ;

proc sort data=OUT.episode_candidates ; by  DESY_SORT_KEY EP_BEG m_epi_source EP_END m_epi_claim ; 
RUN ;

%MEND STEP3B ;
%STEP3B ;
RUN ;

********************************************************************** ;
*** Step 4 (Appendix B): Identify Cancer						   *** ;
********************************************************************** ;
%macro step4 ;

*** for performance period, use all available E&M claims *** ;
proc sql ;
	create table canc as
	select a.*, b.*
	from OUT.EPISODE_CANDIDATES as a, out.EM_5Pct as b
	where a.DESY_SORT_KEY=b.DESY_SORT_KEY and 
		EP_BEG le expnsdt2 le EP_END ;

** Identify unique visits and count the number of visits associated with each cancer type. **
** For the purposes of assigning a cancer type to the episode, a visit is defined by the 
   unique combination of beneficiary ID, TIN, line first expense date, and cancer type 
   associated with the diagnosis code on the line. *** ;
proc sort data=canc ; by  DESY_SORT_KEY EP_BEG m_epi_source EP_END m_epi_claim
					    %canc_flags has_cancer PRF_NPI expnsdt2 ;

data visit_count ;
	set canc ; 
			  by  DESY_SORT_KEY ep_beg m_epi_source ep_end  m_epi_claim
					    %canc_flags has_cancer PRF_NPI expnsdt2 ;

	if first.EXPNSDT2 then visit_count = 1 ;						 	 

proc means data=visit_count noprint sum ; 
			  by  DESY_SORT_KEY EP_BEG m_epi_source EP_END m_epi_claim
					    %canc_flags has_cancer ;

	var visit_count ;
	output out=vc1(drop = _type_ _freq_)
		   sum() =  ;
run ;
** Assign the episode the cancer type that has the most visits. ** 
	In the event of a tie, apply tie-breakers in the order below. Assign the cancer type associated with:
	The most recent visit in the episode, second most recent visit, third most recent visit, etc.
	The cancer type that is reconciliation-eligible
	The lowest last digit of the TIN, second lowest digit, etc. ** ;

proc sort data=vc1 ; BY DESY_SORT_KEY EP_BEG m_epi_source EP_END m_epi_claim
					    %canc_flags has_cancer descending visit_count    ;
run ;

data cancer ;
	set vc1 ;  BY DESY_SORT_KEY EP_BEG m_epi_source EP_END m_epi_claim
					    %canc_flags has_cancer descending visit_count ;
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
	set cancer ; BY DESY_SORT_KEY EP_BEG m_epi_source EP_END m_epi_claim
					    %canc_flags has_cancer ;
	if first.m_epi_claim and last.m_epi_claim then output uniq_cancer ;
	else output mult_cancer ;

*** tie_breakers *** ;

	*** a. Capture all visits for episodes with multiple cancer designations. *** ;
	***    Derived field visit_count provides maximum count of visits to run through. *** ;
	proc sort data=mult_cancer ; by  DESY_SORT_KEY EP_BEG m_epi_source EP_END m_epi_claim 
									 %canc_flags has_cancer ;
	data claims_for_mult ;
		merge mult_cancer(in=a rename=(visit_count=max_visit_count)) visit_count(in=b) ; 
		by  DESY_SORT_KEY EP_BEG m_epi_source EP_END m_epi_claim %canc_flags has_cancer ;
		if a ;
		if visit_count = 1 ;

		*** creates a variable of all the flags *** ;
		%canc_var ;
		rev_tax = reverse(PRF_NPI) ;

	run ;
	
	*** b. Sort by descending EXPNSDT2 - will check for multiple cancers on same day *** ;
	proc sort data=claims_for_mult ; by  DESY_SORT_KEY EP_BEG m_epi_source EP_END m_epi_claim 
										 descending EXPNSDT2 ;
	run ;

	*** c. Identify unique dates of service that do NOT have multiple cancer assignments. **** ;
	data udates1 mdates1  ;
		set claims_for_mult ;  by  DESY_SORT_KEY EP_BEG m_epi_source EP_END m_epi_claim 
								   descending EXPNSDT2 ;
		if first.EXPNSDT2 and last.EXPNSDT2 then output udates1 ;
		else output mdates1 ;

	*** d. Using unique dates of service, assign cancer to most recent DOS. *** ;
	data udates1_chk ;
		set udates1 ; by  DESY_SORT_KEY EP_BEG m_epi_source EP_END m_epi_claim 
								   descending EXPNSDT2 ;
		if first.m_epi_claim ;

	*** e. Check for episodes without uniques trigger dates - will move onto reconciliation eligible check. *** ;
	data level2_tie ;
		merge mult_cancer (in=a keep=DESY_SORT_KEY)
			  udates1_chk (in=b keep=DESY_SORT_KEY) ;
		by DESY_SORT_KEY ;
		if a and b=0 ;

	proc sort data=level2_tie nodupkey ; by DESY_SORT_KEY ;

	*** f. Capture unique cancer/recon_elig combos. *** ;
	data mclaims2 ;
		merge level2_tie(in=a) claims_for_mult(in=b) ; by DESY_SORT_KEY ;
		if a and b ;
		if recon_elig = "Y" then count_y = 1 ; else count_y = 0 ;
	proc sort data=mclaims2 nodupkey out=mc2 ; by DESY_SORT_KEY cancer_chk ;

	proc sort data=mc2 ; by DESY_SORT_KEY ;
	proc means data=mc2 noprint n sum ; by DESY_SORT_KEY ;
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
		merge mc2a_canc(in=a) claims_for_mult(in=b) ; by DESY_SORT_KEY ;
		if a and b and recon_elig = "Y" ;

	data udates2_chk ; 
		set udates2_chk ; by  DESY_SORT_KEY EP_BEG m_epi_source EP_END m_epi_claim 
								   descending EXPNSDT2 ;
		if first.m_epi_claim ;
	
	*** i. run remaining through TIN tax ID check  - identify unique REV_TIN and cancer combos *** ;
	data level3_tie_a ;
		merge mclaims2(in=a) 
			  level3_tie(in=b keep=DESY_SORT_KEY count_y cancer_count) 
			  udates2_chk(in=c keep=DESY_SORT_KEY) ;
		by DESY_SORT_KEY ;
		if (a and c=0) or
		   (a and b)  ;

		** Only considers reconcilation eligible if there are a mix of eligible and non-eligible cancers *** ;
		if a and b then do ;
			if count_y gt 1  then do ;
				if recon_elig = "N" then delete ;
			end ;
		end ;


	proc sort data=level3_tie_a out=l3 nodupkey ; by DESY_SORT_KEY rev_tax cancer_chk ;

	*** j. identify final_cancer based on tin digits  *** ;
	data mc3_canc ;
		set l3 ; by DESY_SORT_KEY rev_tax cancer_chk ;
		if first.DESY_SORT_KEY ;

	proc sort data=claims_for_mult ; by DESY_SORT_KEY rev_tax cancer_chk ;

	data udates3_chk ;
		merge mc3_canc (in=a keep=DESY_SORT_KEY rev_tax cancer_chk) claims_for_mult(in=b) ;
		by DESY_SORT_KEY rev_tax cancer_chk ;
		if a and b ;

	data udates3_chk ;
		set udates3_chk ; by DESY_SORT_KEY ;
		if first.DESY_SORT_KEY ;
		*** 5/11/17 - OCM Ticket submitted on what to do if same tax id from pool e&m claims. *** ;

	***** k. Combine All Cancer Assignments. ***** ;
		*** uniq_cancer - no tie breakers needed *** ;
		*** udates1_chk - assigned based on most recent e&m claim *** ;
		*** udates2_chk - assigned based on recon eligible flag   *** ;
		*** udates3_chk - defaults to reverse tax digit screen    *** ;
data out.cancer_assignment (keep =  DESY_SORT_KEY EP_BEG m_epi_source EP_END m_epi_claim cancer recon_elig) ;
	set uniq_cancer
		udates1_chk 
		udates2_chk 
		udates3_chk;
	%assign_cancer ; 
proc sort data=out.cancer_assignment ; by  	DESY_SORT_KEY EP_BEG m_epi_source EP_END m_epi_claim ;


proc freq data=out.cancer_assignment ;
	tables cancer ;
title "Identified Cancer Episodes Using Five Percent Data" ; run ;

%mend step4 ;
%step4 ; 

run ;
********************************************************************** ;
*** Step 5 : Pull claims for identified episodes of care.		   *** ;
********************************************************************** ;
%macro step5 ;

rsubmit ;
libname in16 "\\chic-win-fs2\CMS\5pct_sample\2016\Annual\Raw" ; 
libname in17 "\\chic-win-fs2\CMS\5pct_sample\2017\Annual\Raw" ; 
libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\08 - Benchmark Data\BM2 - 5pct Benchmark Files" ;


proc upload data=out.cancer_assignment out=candidates ; run ;
proc sort data=candidates nodupkey ; by desy_sort_key ;

data memkey (keep= fmtname start label hlo);
	set candidates(rename=(desy_sort_key=start)) end = eof;
	fmtname = '$memkey';
	format label $1.;
	label = 'Y';
	output;
	if eof then do;
		call missing(start);
		*call missing(end);
		hlo = 'O';
		label = 'N'; 
	output;end;
run;

proc sort data=memkey nodupkey;
	by start hlo;
run;
proc format cntlin=memkey;
run;

%macro pull(file,nc) ;
data &file. ;
%if "&nc." = "1" %then %do ;
	set in16.raw_&file._5_2016
		in17.raw_&file._5_2017 ;
%end ;
%else %do ;
	set in16.raw_&file.k_5_2016
		in17.raw_&file.k_5_2017 ;
%end ;
	if put(desy_sort_key,$memkey.) = "Y" ;

proc download data=&file. out=out.&file. ; run ;

%mend pull ;

%pull(pb_line,) ; run ;
%pull(dme_line,) ; run ;
%pull(hha_claims,) ; run ;
%pull(hosp_claims,) ; run ;
%pull(hosp_revenue,) ; run ;
%pull(ip_claims,) ; run ;
%pull(ip_instval,1) ; run ;
%pull(ip_revenue,) ; run ;
%pull(op_claims,) ; run ;
%pull(op_revenue,) ; run ;
%pull(snf_claims,) ; run ;
%pull(pb_claims,) ; run ;
%pull(dme_claims,) ; run ;

ENDRSUBMIT ; RUN ;

%mend step5 ;

%step5 ;
run ;



********************************************************************** ;
**** Step 6: Check for episode prediction model variables ;
**** Surgery, Radiation, BMT									****** ;

%MACRO STEP6 ;

libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\08 - Benchmark Data\BM2 - 5pct Benchmark Files" ;
RUN ;

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

*ip* ;


proc sort data=out.ip_claims out=h ; by desy_sort_key CLAIM_NO THRU_DT ;
proc sort data=out.ip_revenue out=r ; by desy_sort_key CLAIM_NO THRU_DT ;
proc sort data=out.op_claims out=ho ; by desy_sort_key CLAIM_NO THRU_DT ;
proc sort data=out.op_revenue out=ro ; by desy_sort_key CLAIM_NO THRU_DT ;
proc sort data=out.pb_claims out=hp ; by desy_sort_key CLAIM_NO THRU_DT ;
proc sort data=out.pb_line out=rp ; by desy_sort_key CLAIM_NO THRU_DT ;
proc sort data=out.DME_claims out=hd ; by desy_sort_key CLAIM_NO THRU_DT ;
proc sort data=out.DME_line out=ld ; by desy_sort_key CLAIM_NO THRU_DT ;


data inpatient_BM_5pct ;
	merge h(in=a) r(in=b) ; by desy_sort_key CLAIM_NO THRU_DT ;
	if a and b ;
	***from_dt and rev_dt are not available for inpatient stays *** ;
	from_dt = admsn_dt ;

data outpatient_BM_5pct ;
	merge ho(in=a) ro(in=b) ; by desy_sort_key CLAIM_NO THRU_DT ;
	if a and b ;
proc means data=outpatient_BM_5pct noprint min ; by desy_sort_key CLAIM_NO THRU_DT ;
	var rev_dt ;
	output out=op_dts(drop = _type_ _freq_)
		   min() = from_dt ;
data outpatient_BM_5pct ;
	merge outpatient_BM_5pct (in=a) op_dts (in=b) ; by desy_sort_key CLAIM_NO THRU_DT ;
	if a and b ;


data carrier_BM_5pct ;
	merge rp(in=a) hp(in=b keep=desy_sort_key claim_no thru_dt icd:) ; 
	by desy_sort_key claim_no thru_dt ;
	if a and b ;
data dme_BM_5pct ;
	merge ld(in=a) hd(in=b keep=desy_sort_key claim_no thru_dt icd:) ; 
	by desy_sort_key claim_no thru_dt ;
	if a and b ;

proc sort data=carrier_BM_5pct ; by desy_sort_key claim_no ;
proc means data=carrier_BM_5pct noprint min ; by desy_sort_key claim_no thru_dt;
	var expnsdt2 ;
	output out=carr_min_dt(drop = _type_ _freq_)
		   min() = clm_from_dt;

proc sort data=dme_BM_5pct ; by desy_sort_key claim_no ;
proc means data=dme_BM_5pct noprint min ; by desy_sort_key claim_no thru_dt;
	var expnsdt2 ;
	output out=dme_min_dt(drop = _type_ _freq_)
		   min() = clm_from_dt;

data carrier_BM_5Pct ;
	merge carrier_BM_5Pct(in=a) carr_min_dt(in=b) ; by desy_sort_key claim_no thru_dt;
	if a and b ;

data dme_BM_5pct ;
	merge dme_BM_5Pct(in=a) dme_min_dt(in=b) ; by desy_sort_key claim_no thru_dt ;
	if a and b ;


proc sql ;
	create table out.inpatient_BM_5pct as
	select a. *, b.ep_beg, b.ep_end 
	from inpatient_BM_5pct as a, out.cancer_assignment as b
	where  a.desy_sort_key=b.desy_sort_key and
	   (b.ep_beg le a.admsn_dt le b.ep_end) and 
		b.cancer ne "  " ;
	create table out.outpatient_BM_5pct as
	select a.*, b.ep_beg, b.ep_end
	from outpatient_BM_5pct as a, out.cancer_assignment as b
	where a.desy_sort_key=b.desy_sort_key and
	   (b.ep_beg le a.rev_dt le b.ep_end) and 
		b.cancer ne "  " ;
quit ;


data OUT.check_ipop_BM_5pct(KEEP = DESY_SORT_KEY EP_BEG EP_END CLAIM_NO THRU_DT /*BMT_ALLOGENEIC_AK  
					   BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL
					   BMT_AUTOLOGOUS_AK  BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM 
					   BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL*/ BMT_ALLOGENEIC BMT_AUTOLOGOUS RADTHER 
					   ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY
					   GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
					   OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY 
					   ANAL_dxSURGERY BLADDER_dxSURGERY BREAST_dxSURGERY FEMALEGU_dxSURGERY
					   GASTRO_dxSURGERY HEADNECK_dxSURGERY INTESTINAL_dxSURGERY LIVER_dxSURGERY LUNG_dxSURGERY
					   OVARIAN_dxSURGERY PANCREATIC_dxSURGERY PROSTATE_dxSURGERY KIDNEY_dxSURGERY 
					   CLINICAL_TRIAL_MILL ) ;
	set out.inpatient_BM_5pct(in=a) out.outpatient_BM_5pct ;

	ARRAY INIT (B) CT HAS_CANCER BMT_ALLO BMT_AUTO /*BMT_ALLOGENEIC_AK  BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM 
					   BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL BMT_AUTOLOGOUS_AK  BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM 
					   BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL */BMT_ALLOGENEIC BMT_AUTOLOGOUS 
				       RADTHER ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY 
					   FEMALEGU_SURGERY GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
					   OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY 
					   ANAL_dxSURGERY BLADDER_dxSURGERY BREAST_dxSURGERY FEMALEGU_dxSURGERY
					   GASTRO_dxSURGERY HEADNECK_dxSURGERY INTESTINAL_dxSURGERY LIVER_dxSURGERY LUNG_dxSURGERY
					   OVARIAN_dxSURGERY PANCREATIC_dxSURGERY PROSTATE_dxSURGERY KIDNEY_dxSURGERY 
					   CLINICAL_TRIAL_MILL ;
		DO B = 1 TO DIM(INIT) ;
			INIT = 0 ;
		END ;

		%canc_init ;

		ARRAY v (I) ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD25 ;
		ARRAY d (I) ICD_DGNS_CD1-ICD_DGNS_CD25 ;	
		DO I = 1 TO 25 ;
			%CANCERTYPE(v, d) ;
			if v+0 = . then v = "0" ;
			IF V = "9" and D = "V707" and NOPAY_CD = ' ' THEN CT = 1 ;
			IF V = "0" and D = "Z006" and NOPAY_CD = ' ' THEN CT = 1 ;
		END ;
		DROP I ;

		IF HAS_CANCER = 1 AND CT = 1 then do ;
				IF A THEN CLINICAL_TRIAL_MILL = 1 ;
				ELSE IF (EP_BEG LE FROM_DT LE EP_END) OR
					    (EP_BEG LE THRU_DT LE EP_END) THEN CLINICAL_TRIAL_MILL = 1 ;
		end ;


		IF NOPAY_CD = '  ' THEN DO ;


			ARRAY v1 (X) ICD_prcdr_VRSN_CD1-ICD_prcdr_VRSN_CD25 ;
			ARRAY d1 (X) ICD_prcdr_CD1-ICD_prcdr_CD25 ;
			DO X = 1 TO DIM(D1) ;
				if v1+0 = . then v1 = "0" ;
					if v1 = "9" then do ;
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
					if v1 = "0" then do ;
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
							IF D1 IN ('30230G3','30230G4','30230X4','30230Y3','30230Y4','30233G3','30233G4',
									  '30233X4','30233Y3','30233Y4','30240G3','30240G4','30240X4','30240Y3',
									  '30240Y4','30243G3','30243G4','30243X4','30243Y3','30243Y4','30250G1',
									  '30250X1','30250Y1','30253G1','30253X1','30253Y1','30260G1','30260X1',
									  '30263G1','30260Y1','30263X1','30263Y1') THEN BMT_ALLO1 = 1 ;
							IF D1 NOTIN ('30230G3','30230G4','30230X4','30230Y3','30230Y4','30233G3','30233G4',
									  '30233X4','30233Y3','30233Y4','30240G3','30240G4','30240X4','30240Y3',
									  '30240Y4','30243G3','30243G4','30243X4','30243Y3','30243Y4','30250G1',
									  '30250X1','30250Y1','30253G1','30253X1','30253Y1','30260G1','30260X1',
									  '30263G1','30260Y1','30263X1','30263Y1') THEN BMT_AUTO1 = 1 ;
						end ;
					end ;
			end ;
			DROP X ;

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

			*** Added 7/17/18 - Update to include surgeries with a header level diagnosis
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
			if PANCREATIC_SURGERY = 1 and PANCREATIC=1 then dxPANCREATIC_SURGERY = 1 ;
			if prostate_surgery = 1 and prostate = 1 then dxPROSTATE_SURGERY = 1 ;

						*IF SUM(ACUTE_LEUKEMIA,LYMPHOMA,MULT_MYELOMA,MDS, CHRONIC_LEUKEMIA) > 0 THEN DO ;
							IF PUT(DRG_CD,$BMT_DRG.) = "Y" THEN DO ;
								IF DRG_CD = '014' THEN BMT_ALLO2 = 1 ; 
								ELSE BMT_AUTO2 = 1 ;
							END ;

								BMT_ALLOGENEIC = MAX(BMT_ALLO1,BMT_ALLO2) ;
								BMT_AUTOLOGOUS = MAX(BMT_AUTO1,BMT_AUTO2) ;
					
							IF SUM(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) LT 1 THEN DO ;
								IF PUT(HCPCS_CD,$BMT_CPT.) = "Y" THEN DO ;
									IF HCPCS_CD = '38240' THEN BMT_ALLOGENEIC = 1 ;
									ELSE BMT_AUTOLOGOUS = 1 ;
								END ;
							END ;

						*END ;

		end ;
		/*
			ARRAY CANC (c) ACUTE_LEUKEMIA LYMPHOMA MULT_MYELOMA MDS CHRONIC_LEUKEMIA;
			ARRAY B1 (c) BMT_ALLOGENEIC_AK  BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL ;
			ARRAY B2 (c) BMT_AUTOLOGOUS_AK  BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL ;
				
			DO C = 1 TO 5 ;
				IF CANC = 1 THEN DO ;
					B1 = BMT_ALLOGENEIC ;
					B2 = BMT_AUTOLOGOUS ;
				END ;
			END ;
			***** ;
		*/

proc sql ;
	create TABLE lines as 
	select a.*, b.ep_beg, b.ep_end 
	from carrier_BM_5pct as a, out.cancer_assignment as b
	where a.desy_sort_key=b.desy_sort_key and
	   (b.ep_beg le a.EXPNSDT2 le b.ep_end) and 
		b.cancer ne "  " ;
quit ;

proc sql ;
	create TABLE dmelines as 
	select a.*, b.ep_beg, b.ep_end 
	from dme_BM_5pct as a, out.cancer_assignment as b
	where a.desy_sort_key=b.desy_sort_key and
	   (b.ep_beg le a.EXPNSDT2 le b.ep_end) and 
		b.cancer ne "  " ;
quit ;

data check_carr(KEEP =  DESY_SORT_KEY EP_BEG EP_END CLAIM_NO THRU_DT /*BMT_ALLOGENEIC_AK  BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM 
					   BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL BMT_AUTOLOGOUS_AK  BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM 
					   BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL BMT_ALLOGENEIC BMT_AUTOLOGOUS */ RADTHER 
					   ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY
					   GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
					   OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY 
					   dxANAL_SURGERY dxBLADDER_SURGERY dxBREAST_SURGERY dxFEMALEGU_SURGERY
					   dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY dxLIVER_SURGERY dxLUNG_SURGERY
					   dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY 
					   CLINICAL_TRIAL_MILL )  ;	
	set lines dmelines(in=a) ;

	if a then dme_flag = 1 ;
	else dme_flag = 0 ;

	ARRAY INIT (B) 	   /*BMT_ALLOGENEIC BMT_AUTOLOGOUS BMT_ALLOGENEIC_AK  BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM 
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

		if LALOWCHG > 0 then do ;

			%canc_init ;
			%CANCERTYPE(LINE_ICD_DGNS_VRSN_CD, LINE_ICD_DGNS_CD) ;
			HAS_CANCER_line= HAS_CANCER ;

			%canc_init ;
			ARRAY v (I) LINE_ICD_DGNS_VRSN_CD ICD_DGNS_VRSN_CD: ;
			ARRAY d (I) LINE_ICD_DGNS_CD ICD_DGNS_CD: ;	
			DO I = 1 TO dim(d) ;
				if v+0 = . then v = "0" ;
				IF V = '9' and D = "V707" THEN CT = 1 ;
				IF V = '0' and D = "Z006" THEN CT = 1 ;
				%CANCERTYPE(V,D) ;
			END ;


			IF HAS_CANCER = 1 AND CT = 1 THEN DO ;
				IF LINE_ICD_DGNS_CD IN ("V707" ,"Z006") THEN CLINICAL_TRIAL_MILL = 1 ;
				ELSE IF (EP_BEG LE clm_FROM_DT LE EP_END) OR
						(EP_BEG LE THRU_DT LE EP_END) THEN CLINICAL_TRIAL_MILL = 1 ;
			END ;

			if dme_flag = 0 then do ;

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

				*** Added 7/17/18 - Update to include surgeries with a header level diagnosis
					code for the cancer indicated for the surgery. *** ;
				if prostate_surgery = 1 and prostate = 1 then dxPROSTATE_SURGERY = 1 ;
				if PANCREATIC_SURGERY = 1 and PANCREATIC=1 then dxPANCREATIC_SURGERY = 1 ;
				if OVARIAN_SURGERY=1 and OVARIAN=1 then dxOVARIAN_SURGERY = 1 ;
				if KIDNEY_SURGERY=1 and KIDNEY=1 then dxKIDNEY_SURGERY = 1 ;
				if HEADNECK_SURGERY=1  and HEADNECK=1 then dxHEADNECK_SURGERY = 1 ;
				if INTESTINAL_SURGERY and intestinal = 1 then dxINTESTINAL_SURGERY = 1 ;
				if GASTRO_SURGERY and GASTRO_ESOPHAGEAL=1 then dxGASTRO_SURGERY = 1 ;
				if FEMALEGU_SURGERY and FEMALEGU=1 then dxFEMALEGU_SURGERY = 1 ;
				if BREAST_SURGERY=1 and breast = 1 then dxBREAST_SURGERY = 1 ;

			END ;

			*IF SUM(ACUTE_LEUKEMIA,LYMPHOMA,MULT_MYELOMA,MDS,CHRONIC_LEUKEMIA) > 0 THEN DO ;
					*IF PUT(HCPCS_CD,$BMT_CPT.) = "Y" THEN DO ;
					*	IF HCPCS_CD = '38240' THEN BMT_ALLOGENEIC = 1 ;
					*	ELSE BMT_AUTOLOGOUS = 1 ;
					*END ;
			
			/*
					ARRAY CANC (c) ACUTE_LEUKEMIA LYMPHOMA MULT_MYELOMA MDS CHRONIC_LEUKEMIA;
					ARRAY B1 (c) BMT_ALLOGENEIC_AK  BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_AUTOLOGOUS_CL;
					ARRAY B2 (c) BMT_AUTOLOGOUS_AK  BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL ;
						
					DO C = 1 TO 5 ;
						IF CANC = 1 THEN DO ;
							B1 = BMT_ALLOGENEIC ;
							B2 = BMT_AUTOLOGOUS ;
						END ;
					END ;
			END ;*/
				
		END ;

data all ; set OUT.check_ipop_BM_5pct check_carr ;
proc sort data=all ; by DESY_SORT_KEY EP_BEG EP_END ;
proc means data=all noprint max ; by DESY_SORT_KEY EP_BEG EP_END  ;
	var /*BMT_ALLOGENEIC_AK  BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL BMT_AUTOLOGOUS_AK  
		BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM  BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL*/
		BMT_ALLOGENEIC BMT_AUTOLOGOUS RADTHER 
		ANAL_SURGERY BLADDER_SURGERY 
		BREAST_SURGERY FEMALEGU_SURGERY GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY 
		LUNG_SURGERY OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY 
	    dxANAL_SURGERY dxBLADDER_SURGERY dxBREAST_SURGERY dxFEMALEGU_SURGERY
		dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY dxLIVER_SURGERY dxLUNG_SURGERY
		dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY  
		CLINICAL_TRIAL_MILL ;
	OUTPUT OUT=OUT.PREDICT_VARS_BM_5PCT  (DROP = _TYPE_ _FREQ_)
		   MAX() = ;
RUN ;
	
%MEND STEP6 ;
%STEP6 ;
RUN ;

********************************************************************** ;
********************************************************************** ;
****** Step 7 - Final Episode File *********************************** ;	
%macro step7 ;

data epi ;
	merge out.cancer_assignment(in=a) out.predict_vars_bm_5pct (in=b) ; by desy_sort_key ep_beg ep_end;
	if a ;
	if cancer ne "  " ;

	if cancer ne "Breast Cancer" and dxbreast_surgery = 0 then BREAST_SURGERY = 0 ;
	if cancer ne "Anal Cancer" and dxanal_surgery = 0 then ANAL_SURGERY = 0 ;
	if cancer ne "Liver Cancer" and dxliver_surgery = 0 then LIVER_SURGERY = 0 ;
	if cancer ne "Lung Cancer" and dxlung_surgery = 0 then LUNG_SURGERY = 0 ;
	if cancer ne "Kidney Cancer" and dxkidney_surgery = 0 then KIDNEY_SURGERY = 0 ;
	if cancer ne "Bladder Cancer" and dxbladder_surgery = 0 then BLADDER_SURGERY = 0 ;
	if cancer ne "Female GU Cancer other than Ovary" and dxfemalegu_surgery = 0 then FEMALEGU_SURGERY = 0 ;
	if cancer ne "Gastro/Esophageal Cancer" and dxgastro_surgery = 0 then GASTRO_SURGERY = 0 ;
	if cancer ne "Head and Neck Cancer" and dxheadneck_surgery = 0 then HEADNECK_SURGERY = 0 ;
	if cancer ne "Intestinal Cancer" and dxintestinal_surgery = 0 then INTESTINAL_SURGERY = 0 ;
	if cancer ne "Ovarian Cancer" and dxovarian_surgery = 0 then OVARIAN_SURGERY = 0 ;
	if cancer ne "Prostate Cancer" and dxprostate_surgery = 0 then PROSTATE_SURGERY = 0 ;
	if cancer ne "Pancreatic Cancer" and dxpancreatic_surgery = 0 then PANCREATIC_SURGERY = 0 ;
	
	
								
	*** Renaming Milliman to match OCM ** ;
	if cancer = 'Malignant neoplasm of female genital organs NOS' then cancer = 'Malignant neoplasm of other and unspecified female genital organs' ;
	if cancer = 'Leukemia, NOS' then cancer = 'Leukemia, unspecified' ;
	if cancer = 'Malignant neoplasm of penis, other male organs NOS' then cancer = 'Malignant neoplasm of penis, other, and unspecific male organs' ;
	if cancer = 'Lymphoid Leukemia, NOS' then cancer = 'Lymphoid Leukemia, unspecified' ;

	CANCER_TYPE_MILLIMAN = CANCER ; DROP CANCER ;
	RADIATION_MILLIMAN = RADTHER ; DROP RADTHER ;
	has_surgery = 0 ;
	SURGERY_MILLIMAN = max(BREAST_SURGERY, ANAL_SURGERY, LIVER_SURGERY, LUNG_SURGERY, FEMALEGU_SURGERY,
					  GASTRO_SURGERY, HEADNECK_SURGERY, INTESTINAL_SURGERY, OVARIAN_SURGERY, 
					  PROSTATE_SURGERY, PANCREATIC_SURGERY, KIDNEY_surgery, BLADDER_SURGERY ) ;
	CLINICAL_TRIAL_MILLIMAN = CLINICAL_TRIAL_MILL ; DROP CLINICAL_TRIAL_MILL ;
	BMT_MILLIMAN = 0 ;

	ARRAY BMT (B) BMT_ALLOGENEIC_AK BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL 
				  BMT_AUTOLOGOUS_AK BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL ;
	DO B = 1 TO DIM(BMT) ;
		BMT = 0 ;
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


	if cancer notin ("Acute Leukemia","Lymphoma","MDS","Multiple Myeloma","Chronic Leukemia") then BMT_Milliman = 4 ;
	else do ;
		array al (b) BMT_ALLOGENEIC_L BMT_ALLOGENEIC_AK BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL ;
		array au (b) BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_AK BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL;
		array bm (b) BM_L BM_AK BM_MM BM_MDS BM_CL ;
		do b = 1 to 5 ;
			if al = 1 and au = 1 then bm = 3 ;
			else if al = 1 then bm = 2 ;
			else if au = 1 then bm = 1 ;
			else bm = 0 ;
		end ;
	end ;
	if cancer = "Acute Leukemia" then BMT_MILLIMAN = BM_AK ;
	if cancer = "Lymphoma" then BMT_MILLIMAN = BM_L ;
	if cancer = "MDS" then BMT_MILLIMAN = BM_MDS ;
	if cancer = "Multiple Myeloma" then BMT_MILLIMAN = BM_MM ;
	IF cancer = "Chronic Leukemia" then BMT_MILLIMAN = BM_CL ;

proc sort data=epi ; by desy_sort_key ep_beg ep_end ;

data out.epi_prelim_BM_5pct ;
	set epi ;
	if _n_ = 1 then ep_id = 100001 ;
	else do ;
		ep_id = sum(ep_id,1) ;
	end ;
	retain ep_id ;

proc sort data=out.epi_prelim_BM_5pct  ; by ep_id desy_sort_key ep_beg ep_end ;
proc contents data=out.epi_prelim_BM_5pct ; 

run ;

%mend step7 ;

%step7 ; 
run ;


********************************************************************** ;
********************************************************************** ;
****** Step 8 - Pull historical data for beneficiaries with episodes * ;	

%macro step8 ;

rsubmit ;
libname in12 "\\chic-win-fs2\CMS\5pct_sample\2012\Raw" ; 
libname in13 "\\chic-win-fs2\CMS\5pct_sample\2013\Raw" ; 
libname in14 "\\chic-win-fs2\CMS\5pct_sample\2014\Raw" ; 
libname in15 "\\chic-win-fs2\CMS\5pct_sample\2015\Raw" ; 
libname in16 "\\chic-win-fs2\CMS\5pct_sample\2016\Annual\Raw" ; 
libname in17 "\\chic-win-fs2\CMS\5pct_sample\2017\Annual\Raw" ; 
libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\08 - Benchmark Data\BM2 - 5pct Benchmark Files" ;

proc upload data =out.epi_prelim_BM_5pct out=epi ; run ;
proc sort data=epi nodupkey ; by desy_sort_key;
data memkey (keep= fmtname start label hlo);
	set epi(rename=(desy_sort_key=start)) end = eof;
	fmtname = '$memkey';
	format label $1.;
	label = 'Y';
	output;
	if eof then do;
		call missing(start);
		*call missing(end);
		hlo = 'O';
		label = 'N'; 
	output;end;
run;
quit ;

proc sort data=memkey nodupkey;
	by start hlo;
run;
proc format cntlin=memkey;
run;

%macro pull(file) ;
data &file._hist ;
	set in14.raw_&file._5_2014
		in15.raw_&file._5_2015 ;
	if put(desy_sort_key,$memkey.) = "Y" ;

proc download data=&file._hist out=out.&file._hist ; run ;

%mend pull ;

%pull(pb_linej) ; run ;
%pull(dme_linej) ; run ;
%pull(hha_claimsj) ; run ;
%pull(hosp_claimsj) ; run ;
%pull(hosp_revenuej) ; run ;
%pull(ip_claimsj) ; run ;
%pull(ip_instval) ; run ;
%pull(ip_revenuej) ; run ;
%pull(op_claimsj) ; run ;
%pull(op_revenuej) ; run ;
%pull(snf_claimsj) ; run ;

ENDRSUBMIT ; RUN ;

%mend step8 ;

%step8 ; run ;

********************************************************************** ;
********************************************************************** ;
****** Step 9 - Calculate clean period variable ********************** ;	

%macro step9 ;

*** Step 9a - Identify all chemo claims *** ;
data chemo_claims ;
	set out.pb_line out.dme_line
		out.pb_linej_hist out.dme_linej_hist
		out.op_revenue(in=a) out.op_revenuej_hist(in=a) ;
	if put(HCPCS_CD,$Chemo_J4p.) = "Y"  ;
	format date_screen mmddyy10. ;
	if a then date_screen = rev_dt ;
	else date_screen = expnsdt2 ;
	chemo_flag = 1 ;

proc sql ;
	create table lookback as
	select a.desy_sort_key, a.ep_id, a.ep_beg, a.ep_end, b.date_screen, b.chemo_flag
	from out.epi_prelim_BM_5pct as a left join chemo_claims as b
	on a.desy_sort_key=b.desy_sort_key and 
	   ep_beg-731 le date_screen lt ep_beg ;
quit ;

data lookback2 ;
	set lookback ;
	format c61 c730 mmddyy10. ;
	c61 = intnx('day',ep_beg,-61,'same') ;
	c730 = intnx('day',ep_beg,-730,'same') ;
	if c61 le date_screen lt ep_beg then chemo_1_61 = chemo_flag ;
	else if c730 le date_screen lt c61 then chemo_62_730 = chemo_flag ;

proc sort data=lookback2 ; by desy_sort_key ep_id ;
proc means data=lookback2 noprint max ; by desy_sort_key ep_id ;
	var chemo_1_61 chemo_62_730 ;
	output out=lookback3 (drop = _type_ _Freq_)
	 	   max() = ;

data final_lookback(keep = ep_id clean_1_61 clean_62_730 clean_731) ;
	set lookback3 ;
	clean_1_61 = 0 ; clean_62_730 = 0 ; clean_731 = 0 ;
	if chemo_1_61 = 1 then clean_1_61 = 1 ; 
	else if chemo_62_730 = 1 then clean_62_730 = 1 ;
	else clean_731 = 1 ;

proc sort data=final_lookback ; by ep_id ;
proc sort data= out.epi_prelim_BM_5pct out=epi ; by ep_id ;


data out.epi_prelim_BM2_5pct ;
	merge epi(in=a) final_lookback(in=b) ; by ep_id ;
	if a and b ;

run ;
*** These 3 fields should be mutually exclusive for each episode *** ;
proc freq data=out.epi_prelim_BM2_5pct ;
	tables clean_1_61*clean_62_730*clean_731/list missing ; run ;

%mend step9 ;

%step9 ;
run ;

********************************************************************** ;
********************************************************************** ;
****** Step 10 - Creation of CMS HHS RA Model Person File ************ ;	

%macro step10 ;

rsubmit ;
libname in12 "\\chic-win-fs2\CMS\5pct_sample\2012\Raw" ; 
libname in13 "\\chic-win-fs2\CMS\5pct_sample\2013\Raw" ; 
libname in14 "\\chic-win-fs2\CMS\5pct_sample\2014\Raw" ; 
libname in15 "\\chic-win-fs2\CMS\5pct_sample\2015\Raw" ; 
libname in16 "\\chic-win-fs2\CMS\5pct_sample\2016\Annual\Raw" ; 
libname in17 "\\chic-win-fs2\CMS\5pct_sample\2017\Annual\Raw" ; 
libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\08 - Benchmark Data\BM2 - 5pct Benchmark Files" ;

proc upload data =out.epi_prelim_BM2_5pct out=epi ; run ;
proc sort data=epi nodupkey ; by desy_sort_key;
data memkey (keep= fmtname start label hlo);
	set epi(rename=(desy_sort_key=start)) end = eof;
	fmtname = '$memkey';
	format label $1.;
	label = 'Y';
	output;
	if eof then do;
		call missing(start);
		*call missing(end);
		hlo = 'O';
		label = 'N'; 
	output;end;
run;
quit ;

proc sort data=memkey nodupkey;
	by start hlo;
run;
proc format cntlin=memkey;
run;


data mems_hccmodel ;
	set in13.raw_mems_2013 
		in14.raw_mems_2014 
		in15.raw_mems_2015 
		in16.raw_mems_2016
		in17.raw_mbsf_5_2017;
	if put(desy_sort_key,$memkey.) = "Y" ;
	if rfrnc_yr = 2017 then rfrnc_yr = 17;
run;

proc sort data=mems_hccmodel ; by desy_sort_key rfrnc_yr ;
proc download data=mems_hccmodel out=out.mems_hccmodel ; run ;

*** Need to pull revenue files for snf and HHA which were not pulled previously *** ;
%macro pull(file) ;
data &file._hccmodel ;
	set in13.raw_&file.J_5_2013(in=b) 
		in14.raw_&file.J_5_2014(in=c) 
		in15.raw_&file.J_5_2015(in=d)
		in16.raw_&file.K_5_2016(in=e)
		in17.raw_&file.K_5_2017(in=f);
	if put(desy_sort_key,$memkey.) = "Y" ;
	if B then rfrnc_yr = 13 ;
	else if C then rfrnc_yr = 14 ;
	else if D then rfrnc_yr = 15 ;
	else if E then rfrnc_yr = 16 ;
	else if F then rfrnc_yr = 17 ;

proc sort data=&file._hccmodel ; by desy_sort_key rfrnc_yr ;
proc download data=&file._hccmodel out=out.&file._hccmodel ; run ;

%mend pull ;

%pull(snf_revenue) ; run ;
%pull(hha_revenue) ; run ;
%pull(pb_claims) ; run ;
%pull(dme_claims) ; run ;

ENDRSUBMIT ;

data epi(keep=desy_sort_key ep_id ep_beg YEAR_BEG);
	set out.epi_prelim_BM2_5pct ;
	year_beg = year(ep_beg) - 2000 ;
run ;

proc sql ;
	create table hist as
	select a.ep_id, a.ep_beg, a.Year_beg, b.*
	from epi as a,out.mems_hccmodel as b
	where a.desy_sort_key = b.desy_sort_key and
	   a.year_beg-1 = b.rfrnc_yr ;
	create table curr as
	select a.ep_id, a.ep_beg, a.Year_beg, b.*
	from epi as a , out.mems_hccmodel as b
	where a.desy_sort_key = b.desy_sort_key and
	   a.year_beg = b.rfrnc_yr ;
quit ;

data epi_pre(keep = desy_sort_key ep_id ep_beg MCAID) ;
	set hist ;
	Mcaid = 0 ; Nemcaid = 0 ;
		if buyin_mo > 1 then Mcaid = 1 ;
data epi_curr(keep = desy_sort_key ep_id NemCAID OREC sex  DOB ) ;
	set curr ;
	format DOB mmddyy10. ;
	Mcaid = 0 ; Nemcaid = 0 ;
	if buyin_mo > 1 then Nemcaid = 1 ;
		DOB_Year = Year(Ep_beg) - Age ;
		DOB = mdy(7,1,DOB_Year) ;
 
data out.person16(keep = hicno date_asof16 desy_sort_key ep_id sex DOB OREC MCAID NEMCAID new_enrollee screen_year) nohist nocurr ;
	merge epi_pre(in=a) epi_curr(in=b) ; by desy_sort_key ep_id ;
	if a  or (a=0 and b) then do ;
		HICNO = desy_sort_key||ep_id ;
		screen_year = year(ep_beg) - 1 ;
		format date_asof16 mmddyY10. ;
		DATE_ASOF16 = mdy(2,1,year(ep_beg)) ;
		if a=0 and b then do ; new_enrollee = 1 ; MCAID = 0 ; end ;
		if a and b then NEMCAID = 0 ;
		output out.person16 ;
	end ;
	if a=0 and b then output nohist ;
	if a and b=0 then output nocurr ;
run ;

%mend step10 ;
%step10 ; run ;


********************************************************************** ;
********************************************************************** ;
************* Step 11 - Generate DIAG File and HCC Flags ************ ;	
%macro step11 ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_HCC_Claims_PREP.sas" ; RUN ;

%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\CMS HHS 2015 Model\V2216L1P.sas" ;RUN ;

proc sort data=out.epi_prelim_BM2_5pct out=epi2 ; by ep_id ;
proc sort data=OUTHCC.PERSON16_Scored out=hcc ; by ep_id ;

data out.epi_prelim_BM3_5pct ;
	merge epi2(in=a)
		  hcc(in=b keep = EP_ID HCC: NEW_ENROLLEE) ; by ep_id ;
	format HCC_GRP $3. ;
	*** Using values in the baseline episode file.  **** ;
	if new_enrollee = 1 then HCC_GRP = '98' ;
	else do ;

		HCC_COUNT = SUM(HCC1,HCC2,HCC17,HCC18,HCC19,HCC22,HCC23,HCC27,HCC28,HCC29,HCC33,
						HCC34,HCC35,HCC39,HCC40,HCC54,HCC55,HCC57,HCC58,HCC70,HCC71,HCC72,
						HCC73,HCC74,HCC75,HCC76,HCC77,HCC78,HCC79,HCC80,HCC82,HCC83,HCC84,
						HCC85,HCC86,HCC87,HCC88,HCC96,HCC99,HCC100,HCC103,HCC104,HCC106,
						HCC107,HCC108,HCC110,HCC111,HCC112,HCC114,HCC115,HCC122,HCC124,
						HCC134,HCC135,HCC136,HCC137,HCC157,HCC158,HCC161,HCC162,HCC166,
						HCC167,HCC169,HCC170,HCC173,HCC176,HCC186,HCC188,HCC189) ; 
	 	IF HCC_COUNT = 0 THEN HCC_GRP = "00" ;
		ELSE IF HCC_COUNT = 1 THEN HCC_GRP = "01" ;
		ELSE IF HCC_COUNT = 2 THEN HCC_GRP = "02" ;
		ELSE IF HCC_COUNT = 3 THEN HCC_GRP = "03" ;
		ELSE IF 4 LE HCC_COUNT LE 5 THEN HCC_GRP = "4-5" ; 
		ELSE IF 6 LE HCC_COUNT  THEN HCC_GRP = "6+" ;
	END ;
RUN ;

%MEND STEP11 ;		

%STEP11 ; 
RUN ;

