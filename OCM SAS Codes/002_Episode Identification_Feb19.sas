********************************************************************** ;
		***** 002_Episode Identification.sas ***** ;
*** As per 1/31/2018 - File references Baseline 2 files that apply to episodes beginning 7/1/2017 and forward. *** ;
********************************************************************** ;
**** Based on Appendix A-C in OCM PBP Methodology.PDF **************** ;
********************************************************************** ;

libname in1 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Baseline\V1" ; *** locale of V1 PDE SAS reads. *** ;
libname in2 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Baseline\V2" ; *** locale of V2 PDE SAS reads. *** ;
libname in "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Baseline\V3" ; *** locale of SAS reads. *** ;
libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Baseline\V3" ;

options ls=132 ps=70 obs=MAX ; run ;

********************************************************************** ;
%let datecreate = 20181114 ; *** Use in creation date in file name for episode validation reports. *** ;
********************************************************************** ;
*** Initiating therapy lists *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2018\Work Papers\SAS\000_Formats Baseline.sas" ;
*** Cancer diagnosis code lists *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2018\Work Papers\SAS\000_Cancer Formats PP3.sas" ;
*** Cancer assignment macro  *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2018\Work Papers\SAS\000_Cancer Diagnoses_5.sas" ;
*** Predictive Model Variable Development  *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2018\Work Papers\SAS\000_Formats_Predict_Flags PP3.sas" ;
RUN ;
********************************************************************** ;
********************************************************************** ;


%macro epi(dsid,ocm) ;
********************************************************************** ;
********************************************************************** ;

proc sort data=in.epi_&dsid. out=e ; by ep_id ;


**** Step 1: Identify all possible claims that could trigger an episode ending in the performance period ;
**** 1.A. Carrier (PHYLINE_&dsid.), DMEPOS (DMELINE_&dsid.)  **** ;


data lines chemo EM;

	set in.phyline_&dsid.(in=a) in.dmeline_&dsid. ;
	%canc_init ;

	if a then carr = 1 ;
	%CANCERTYPE(LINE_ICD_DGNS_VRSN_CD, LINE_ICD_DGNS_CD) ;

	** E&M claims with cancer diagnosis for episode qualification in subsequent steps ** ;
	if a and HCPCS_CD in ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215')
		and LALOWCHG > 0 and has_cancer = 1 then output EM ;

	**The claim must contain a line item HCPCS code indicating an included chemotherapy drug 
	  (initiating cancer therapy) in any line item. ** ;
	if put(HCPCS_CD,$Chemo_J.) = "Y" then do ;

	**The chemotherapy drug line item must have a “line first expense date” in the appropriate 
	  6 month “Episodes Beginning” period in Table 1, inclusive of end dates. ** ;
	**** Episodes begin 2012-2014, run through 6/2015 **** ;
	*if year(EXPNSDT1) in (2012,2013,2014) then do ;

	**The chemotherapy drug line item must not be denied (line allowed charge >0). ** ;
	if LALOWCHG > 0 then do ;

	**The chemotherapy drug line place of service must not be an inpatient hospital (21). ** ;
	if PLCSRVC ne '21' then do ;
		chemo = 1  ;
		output chemo ;
	end ;

	end ;

	*end ;

	end ;



	output lines ;

	** The chemotherapy drug claim must contain an included cancer diagnosis code available on the CMS OCM website) 
   		in any non-denied line item on the same claim (does not have to be same line as HCPCS code above -
   		do not use the header diagnoses).  ** ;

proc sort data=in.phyhdr_&dsid. 
			  out=ph(KEEP = ep_id bene_Id clm_id thru_dt PRNCPAL_DGNS_CD PRNCPAL_DGNS_VRSN_CD ICD_DGNS:)
			  nodupkey ; by  ep_id bene_Id clm_id thru_dt ; run;
proc sort data=in.dmehdr_&dsid. 
			  out=dh (KEEP = ep_id bene_Id clm_id thru_dt PRNCPAL_DGNS_CD PRNCPAL_DGNS_VRSN_CD ICD_DGNS:)
			  nodupkey ; by  ep_id bene_Id clm_id thru_dt ; run;
	
proc sort data=lines ; by ep_id bene_Id clm_id thru_dt ;
proc sort data=chemo out=chemo2(keep = ep_id bene_Id clm_id thru_dt) nodupkey ; by ep_id bene_Id clm_id thru_dt ;

data chemo_claims chemoz ;
	merge lines(in=a) chemo2(in=b) ph dh ; by ep_id bene_id clm_id thru_dt ;
	if a and b ;
	**	The trigger date is the line first expense date on the qualifying chemotherapy drug line. *** ;
	if chemo = 1 then trigger_date = expnsdt1 ;
	format trigger_date mmddyy10. ;

	ZFLAG = 0 ;
	IF PRNCPAL_DGNS_VRSN_CD = "0" THEN DO; 
	   IF PRNCPAL_DGNS_CD IN ('Z5111','Z5112') THEN ZFLAG = 1 ;
	END;
	ELSE DO;
	   IF PRNCPAL_DGNS_CD IN ('V5811','V5812') THEN ZFLAG = 1 ;
	END;

	HAS_CANCER_LINE = HAS_CANCER ;

	output chemo_claims ;
	if zflag = 1 then output chemoz ;
run;

proc sort data=chemo_claims ; by ep_id bene_id clm_id thru_dt carr ;
proc means data=chemo_claims noprint min max ; by ep_id bene_id clm_id thru_dt carr;
	var has_cancer HAS_CANCER_LINE trigger_date ;
	output out=chemo_flag(drop = _freq_ _type_)
		   max(has_cancer HAS_CANCER_LINE) = 
		   min(trigger_date) = ;	

data chemo_candidates1 ;
	set chemo_flag(in=a) chemoz(in=b drop=expnsdt1) ;
	if (a and has_cancer_LINE = 1) OR (b AND HAS_CANCER = 1) ;
run ;

proc sort data=chemo_candidates1 nodupkey ; by ep_id bene_id clm_id thru_dt carr trigger_date;
proc sort data=chemo_claims ; by ep_id bene_id clm_id thru_dt carr ;

data chemo_days1(keep=ep_id expnsdt1) ;
	merge chemo_claims(in=a) chemo_candidates1(in=b) ;  by ep_id bene_id clm_id thru_dt carr;
	if a and b ;

proc sort data=chemo_days1 ; by ep_id expnsdt1 ;
data chemo_days1 ;
	set chemo_days1 ; 
	by ep_id expnsdt1 ;
	if first.expnsdt1 then counter =1 ;
	

**** 1.B. Outpatient (outrev_&dsid., outhdr_&dsid.)  **** ;

	**** Combining files *****;
proc sort data=in.outhdr_&dsid. out=h ; by ep_id BENE_ID CLM_ID THRU_DT ;
proc sort data=in.outrev_&dsid. out=r ; by ep_id BENE_ID CLM_ID THRU_DT ;
data out.outpatient_&type._&dsid. ;
		merge h(in=a) r(in=b) ; 
		by ep_id BENE_ID CLM_ID THRU_DT ; 
		if a and b ;

		%canc_init ;

		ARRAY v (I) ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD25 ;
		ARRAY d (I) ICD_DGNS_CD1-ICD_DGNS_CD25 ;
		DO I = 1 TO 25 ;
			%CANCERTYPE(v, d) ;
		END ;
		DROP I ;


data chemo_candidates2(keep = ep_id bene_id clm_id thru_dt trigger_date has_cancer)  
	all_op_chemo;
	set	out.outpatient_&type._&dsid. ;

	**The claim must contain a HCPCS code indicating an included chemotherapy drug (initiating cancer therapy) 
	  in any revenue center. ** ;
	if put(HCPCS_CD,$Chemo_J.) =  "Y"  then do ;

	** The revenue center date on the same revenue center in which the HCPCS code is found must be in the 
	   appropriate 6 month Episode Beginning period in Table 1, inclusive of end dates ** ;
	**** Episodes begin 2012-2014, run through 6/2015 **** ;
	*if year(REV_DT) in (2012,2013,2014) then do ;

	** The claim must not be denied (Medicare non-payment reason code is not blank). ** ;
	if NOPAY_CD =  "  "    then do ;

	** The revenue center in which the HCPCS code is found must not be denied (revenue center 
	   total charge amount minus revenue center non-covered charge amount > 0). ** ;
	if REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 then do ;
		chemo = 1 ; 
		format trigger_date mmddyy10. ;
		trigger_date = rev_dt ;
		output all_op_chemo ;

		** The claim header must contain an included cancer diagnosis code **;
		if has_cancer = 1 then do ;
			output chemo_candidates2 ;
		end ;
	
	end ;

	end ;

	*end ;

	end ;

proc sort data=chemo_candidates2 out=chemo2a nodupkey; by ep_id bene_id clm_id thru_dt ;
proc sort data=out.outpatient_&type._&dsid. out=op ; by ep_id bene_id clm_id thru_dt ;

data chemo_days2(keep=ep_id rev_dt) ;
	merge op(in=a) chemo2a(in=b) ;  by ep_id bene_id clm_id thru_dt ;
	if a and b ;


**** Part B Chemo claims ***** ;
data chemo_days ;
	set chemo_days1(rename = (expnsdt1=trigger_date)) chemo_days2(rename = (rev_dt=trigger_date)) ;
	if trigger_date ne . ;
proc sort data=chemo_days ; by ep_id trigger_date ;
data chemo_days ; set chemo_days ; by ep_id trigger_date ; if first.trigger_date then counter = 1 ;
proc means data = chemo_days noprint min max sum ; by ep_id ;
	var trigger_date counter ;
	output out=days (drop=_type_ _freq_)
		   min(trigger_date) = chemo_start 
		   max(trigger_date) = chemo_end 
		   sum(counter) = chemo_days ;
data days ; set days ;	format chemo_start chemo_end mmddyy10. ;

**** 1.C. Part D (PDE_&dsid.)  **** ;
/*
data pde1 (DROP=EP_ID); 
	set in1.PDE_&dsid.
	%if "&ocm." = "290" %then %do ;
			in1.pde_567_50200 
			in1.pde_568_50201 
	%end ;

;

proc sql ;
	create table pde1a as 
	select a.ep_id, b. *
	from E as a , pde1 as b 
	where a.bene_id=b.bene_id and
		  a.ep_beg le srvc_dt le ep_end ;
quit ;
*/
data pde ;
	set in.PDE_&dsid. /*pde1a*/ ;
proc sql ;
	create table out.pde2_&dsid. as 
	select distinct * from pde ;
quit ;

data  chemo_candidates3(keep = ep_id bene_id pde_id trigger_date) ;
	set out.pde2_&dsid. ;

	** The claim must contain an included chemotherapy drug (initiating cancer therapy) NDC code. ** ;
	ndc9 = substr(prod_srvc_id,1,9) ;

	if put(NDC9, $Chemo_NDC.) = "Y" then do ;

	** The claim “fill date” must be in the appropriate 6 month “Episode Beginning” period in 
	   Table 1, inclusive of end dates. ** ;
	**** Episodes begin 2012-2014, run through 6/2015 **** ;
	*if year(SRVC_DT) in (2012,2013,2014) then do ;
		chemo = 1 ;
		format trigger_date mmddyy10. ;
		trigger_date = SRVC_DT ;
		output  chemo_candidates3 ;
	*end ;

	end ;

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
	format episode_end mmddyy10. ;
	episode_end = intnx('month', trigger_date, 6,'same')-1 ;
	if a and carr = 1 then source = 2 ; *** carrier is second in hierarchy *** ;
	if b then source = 1 ; *** outpatient is first in hierarchy *** ;
	if a and carr ne 1 then source = 3 ; *** DME is third in hierarchy *** ;
	if c then source = 4 ; *** Part D is fourth in hierarchy **** ;


proc sort data=triggers nodupkey ; by ep_id bene_id trigger_date source clm_id  ;



***********
Apply the following hierarchy if there is more than one trigger claim on the same day from different 
types of service: Outpatient, Carrier, DMEPOS, Part D
If there is still more than one trigger claim on the same day within the same type of service, 
choose the claim with the first claim ID. ********* ;

data triggersa ;
	set triggers ; by ep_id bene_id trigger_date ;
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
	set triggersa ; by ep_id bene_id trigger_date source clm_id ;
	if first.clm_id ;


** A trigger claim initiates an episode only when all of the below criteria are met.;
** For all performance periods, the potential episode trigger date must not be included 
   in any episode defined for a prior performance period.  6 Potential trigger claims occurring 
   inside a previously defined episode cannot trigger a new episode. ** ;
data triggers2 ;
	set triggersb ; by ep_id bene_id ;
	format pend mmddyy10. ; 
	if first.bene_id then do ;
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

*** Keeping earliest date for a trigger claim *** ;
data triggers2a ; set triggers2 ;
	by ep_id bene_id ;
	if first.ep_id ;


** The 6 month period beginning with the trigger date must contain a non-denied Carrier claim with an 
   E&M visit (HCPCS code 99201 – 99205, 99211 – 99215) AND an included cancer diagnosis code on the same line item. ** ;
proc sql ;
	create table triggers3 as
	select a.ep_id , a.bene_id, a.trigger_date, a.source, a.episode_end
	from triggers2a as a, em as b
	where a.bene_id=b.bene_id and 
		  trigger_date le expnsdt1 le episode_end ;
quit ;
proc sort data=triggers3 nodupkey ; by ep_id bene_id trigger_date ;

run ;



********************************************************************** ;
********************************************************************** ;
**** Step 3: Identify final set of episodes ;


**The beneficiary must meet the criteria below for the entire 6 month period (or until death) beginning with the trigger date, inclusive of end dates:
• Beneficiary is enrolled in Medicare Parts A and B
• Beneficiary does not receive the Medicare ESRD benefit, as determined by the Medicare Enrollment Database
• Beneficiary has Medicare as his or her primary payer
• Beneficiary is not covered under Medicare Advantage or any other group health program. ** ;
*** Data not provided. **** ;

data episode_candidates(keep = ep_id bene_id m_episode_beg m_epi_source episode_end ) ;
	set triggers3 ;
	format m_episode_beg mmddyy10. ;
	m_episode_beg = trigger_date;
	m_epi_source = source ;
	drop trigger_date source ;

proc sort data=episode_candidates ; by ep_id bene_id m_episode_beg m_epi_source episode_end ; 

data epi_orig ;
	merge e(in=a) episode_candidates(in=b) ; by ep_id ;
	if a ;
	if a and b=0 then attribute_flag = 0 ; *** valid trigger not found in data. *** ;
	if a and b then do ;
		if ep_beg ne m_episode_beg then attribute_flag = 2 ;   *** mismatch on trigger date *** ;
		else attribute_flag = 1 ; *** match on trigger date *** ;
	END ;


 
********************************************************************** ;
********************************************************************** ;
**** Appendix B: Identify cancer ;

proc sql ;
	create table canc as
	select a.*, b.*
	from epi_orig as a, em as b
	where a.ep_id=b.ep_id and 
		ep_beg le expnsdt1 le ep_end ;

** Identify unique visits and count the number of visits associated with each cancer type. **
** For the purposes of assigning a cancer type to the episode, a visit is defined by the 
   unique combination of beneficiary ID, TIN, line first expense date, and cancer type 
   associated with the diagnosis code on the line. *** ;
proc sort data=canc ; by ep_id %canc_flags has_cancer tax_num expnsdt1 ;

data visit_count ;
	set canc ; by ep_id %canc_flags has_cancer tax_num expnsdt1 ;
	if first.expnsdt1 then visit_count = 1 ;						 	 

proc means data=visit_count noprint sum ; by ep_id %canc_flags has_cancer ;
	var visit_count ;
	output out=vc1(drop = _type_ _freq_)
		   sum() =  ;
run ;
** Assign the episode the cancer type that has the most visits. ** 
	In the event of a tie, apply tie-breakers in the order below. Assign the cancer type associated with:
	The most recent visit in the episode, second most recent visit, third most recent visit, etc.
	The cancer type that is reconciliation-eligible
	The lowest last digit of the TIN, second lowest digit, etc. ** ;

proc sort data=vc1 ; by ep_id has_cancer descending visit_count    ;

data cancer ;
	set vc1 ;  by ep_id has_cancer descending visit_count  ;
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
	set cancer ; by ep_id has_cancer ;
	if first.ep_id and last.ep_id then output uniq_cancer ;
	else output mult_cancer ;


*** tie_breakers *** ;
	*** a. Capture all visits for episodes with multiple cancer designations. *** ;
	***    Derived field visit_count provides maximum count of visits to run through. *** ;
	proc sort data=mult_cancer ; by ep_id %canc_flags has_cancer ;
	data claims_for_mult ;
		merge mult_cancer(in=a) visit_count(in=b) ; 
		by ep_id %canc_flags has_cancer ;
		if a ;
		if visit_count = 1 ;
		*** creates a variable of all the flags *** ;
		%canc_var ;
		rev_tax = reverse(Tax_num) ;
		last_tax = substr(left(rev_tax),1,1) ;

	*** b. Sort by descending expnsdt1 - will check for multiple cancers on same day *** ;
	proc sort data=claims_for_mult ; by  ep_id descending expnsdt1 ;
	run ;

	*** c. Identify unique dates of service that do NOT have multiple cancer assignments. **** ;
	data udates1 mdates1  ;
		set claims_for_mult ;  by  ep_id descending expnsdt1 ;
		if first.expnsdt1 and last.expnsdt1 then output udates1 ;
		else output mdates1 ;

	*** d. Using unique dates of service, assign cancer to most recent DOS. *** ;
	data udates1_chk ;
		set udates1 ; by  ep_id descending expnsdt1 ;
		if first.EP_ID ;

	*** e. Check for episodes without uniques trigger dates - will move onto reconciliation eligible check. *** ;
	data level2_tie ;
		merge mult_cancer (in=a keep=ep_id )
			  udates1_chk (in=b keep=ep_id ) ;
		by ep_id ;
		if a and b=0 ;

	proc sort data=level2_tie nodupkey ; by ep_id  ;

	*** f. Capture unique cancer/recon_elig combos. *** ;
	data mclaims2 ;
		merge level2_tie(in=a) claims_for_mult(in=b) ; by ep_id  ;
		if a and b ;
		if recon_elig = "Y" then count_y = 1 ; else count_y = 0 ;
	proc sort data=mclaims2 nodupkey out=mc2 ; by ep_id  cancer_chk ;

	proc sort data=mc2 ; by ep_id  ;
	proc means data=mc2 noprint n sum ; by ep_id ;
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
		merge mc2a_canc(in=a) claims_for_mult(in=b) ; by ep_id  ;
		if a and b and recon_elig = "Y" ;

	data udates2_chk ; 
		set udates2_chk ; by  ep_id descending expnsdt1 ;
		if first.ep_id ;

	*** i. run remaining through TIN tax ID check  - identify unique REV_TIN and cancer combos *** ;

	data level3_tie_a ;
		merge mclaims2(in=a) 
			  level3_tie(in=b keep=ep_id count_y cancer_count) 
			  udates2_chk(in=c keep=ep_id ) ;
		by ep_id ;
		if (a and c=0) or
		   (a and b)  ;

		** Only considers reconcilation eligible if there are a mix of eligible and non-eligible cancers *** ;
		if a and b then do ;
			if count_y gt 1  then do ;
				if recon_elig = "N" then delete ;
			end ;
		end ;

	*** 3/2/18: As per OCM ticket #868640 - use last digit of tin and then highest clm_id *** ;
	proc sort data=level3_tie_a out=l3 nodupkey ; by ep_id last_tax descending clm_id cancer_chk ;

	*** j. identify final_cancer based on tin digits  *** ;
	data mc3_canc ;
		set l3 ; by ep_id last_tax descending clm_id cancer_chk ;
		if first.ep_id ;

	proc sort data=claims_for_mult ; by ep_id last_tax descending clm_id cancer_chk ;

	data udates3_chk ;
		merge mc3_canc (in=a keep=ep_id last_tax clm_id cancer_chk) claims_for_mult(in=b) ;
		by ep_id last_tax descending clm_id cancer_chk ;
		if a and b ;

	data udates3_chk ;
		set udates3_chk ; by ep_id ;
		if first.ep_id  ;
		*** 5/11/17 - OCM Ticket submitted on what to do if same tax id from pool e&m claims. *** ;

	***** k. Combine All Cancer Assignments. ***** ;
		*** uniq_cancer - no tie breakers needed *** ;
		*** udates1_chk - assigned based on most recent e&m claim *** ;
		*** udates2_chk - assigned based on recon eligible flag   *** ;
		*** udates3_chk - defaults to reverse tax digit screen    *** ;
data cancer_assignment (keep =  ep_id cancer recon_elig) ;
	set uniq_cancer
		udates1_chk 
		udates2_chk 
		udates3_chk;
	%assign_cancer ; 
proc sort data=cancer_assignment ; by ep_id ;


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
	create table triggers_a2 as
	select a.ep_id, b.*
	from in.epi_&dsid. as a, chemotherapy as b
	where a.ep_id=b.ep_id and ep_beg le trigger_date le ep_end;

proc sort data=triggers_a2 ; by  ep_id ;
proc means data=triggers_a2 min max noprint ; by  ep_id ;
	var source ;	
	output out=trigger_s(drop = _type_ _freq_)
		   min(source) = mins 
		   max(source) = maxs ;

data trigger_s(keep =  ep_id partdonly) ;
	set trigger_s ;
	if mins=4 and maxs = 4 then partdonly=1 ; else partdonly = 0 ;

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
	select a.*, b.*
	from epi_orig as a, em as b
	where a.ep_id=b.ep_id and 
		ep_beg le expnsdt1 le ep_end ;

** Identify unique visits and count the number of visits associated with each cancer type. **
** For the purposes of assigning a cancer type to the episode, a visit is defined by the 
   unique combination of beneficiary ID, TIN, line first expense date, and cancer type 
   associated with the diagnosis code on the line. *** ;
proc sort data=canc2 ; by ep_id ep_beg ep_end tax_num expnsdt1 ;

data visit_count2 ;
	set canc2 ; by ep_id ep_beg ep_end tax_num expnsdt1 ;
	if first.expnsdt1 then visit_count = 1 ;						 	 

proc sort data=visit_count2 ; by ep_id ep_beg ep_end tax_num prfnpi ;
proc means data=visit_count2 noprint sum ; by ep_id ep_beg ep_end tax_num prfnpi;
	var visit_count ;
	output out=vc_npi(drop = _type_ _freq_)
		   sum() =  ;
proc means data=vc_npi noprint sum ; by ep_id ep_beg ep_end tax_num ;
	var visit_count ;
	output out=vc(drop = _type_ _freq_)
		   sum() =  ;


proc sort data=vc ; by ep_id ep_beg ep_end descending visit_count ;
data vc2 ;
	set vc ; by ep_id ep_beg ep_end descending visit_count ;
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

proc sort data=vc2 ; by ep_id ep_beg ep_end tax_num ;
data mult_ids uniq_ids ;
	set vc2 ; by ep_id ep_beg ep_end tax_num ;
	if first.ep_id and last.ep_id then output uniq_ids ;
	else output mult_ids ;


*** tie-breakers *** ;
proc sort data=visit_count2 ; by ep_id ep_beg ep_end tax_num ;
	*** a. Capture all visits for episodes with multiple cancer designations. *** ;
	data claims_for_mult ;
		merge mult_ids(in=a) visit_count2(in=b) ; 
		by ep_id ep_beg ep_end tax_num ;
		if a ;
		if visit_count = 1 ;
		rev_tax = reverse(Tax_num) ;

	*** b. Sort by descending expnsdt1 - will check for multiple cancers on same day *** ;
	proc sort data=claims_for_mult ; by ep_id ep_beg ep_end descending expnsdt1 ;
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
	proc sort data=claims_for_mult2 ; by ep_id ep_beg ep_end descending expnsdt1 ;
	run ;

	data udates1 mdates1 ;
		set claims_for_mult2 ; by ep_id ep_beg ep_end descending expnsdt1 ;
		if first.expnsdt1 and last.expnsdt1 then output udates1 ;
		else output mdates1 ;
	
	*** d. Using unique dates of service, assign TIN to most recent DOS. *** ;
	data udates1_chk ;
		set udates1 ; by ep_id  ep_beg ep_end descending expnsdt1 ;
		if first.ep_end and clm_last_ep=1 ;

	*** e. Check for episodes without uniques trigger dates - will move onto TIN check. *** ;
	data level2_tie ;
		merge mult_ids (in=a keep=ep_id )
			  udates1_chk (in=b keep=ep_id ) ;
		by ep_id ;
		if a and b=0 ;

	proc sort data=level2_tie nodupkey ; by ep_id  ;

	*** f. run remaining through TIN tax ID check  - identify unique REV_TIN and cancer combos *** ;
	data mt2 ;
		merge level2_tie(in=a keep=ep_id )
			  claims_for_mult2(in=b) ; by ep_id ;
		if a and b ;
		last_dig = substr(left(rev_tax),1,1) ;

	proc sort data=mt2 ; by ep_id ep_beg ep_end last_dig descending clm_id  ;
	*** g. identify final_cancer based on tin digits  *** ;
	*** 3/2/18: As per OCM ticket #868640 - use last digit of tin and then highest clm_id *** ;
	data udates2_chk ;
		set mt2 ; by ep_id ep_beg ep_end last_dig descending clm_id    ;
		if first.ep_end ;

	***** h. Combine All Cancer Assignments. ***** ;
		*** uniq_ids - no tie breakers needed *** ;
		*** udates1_chk - assigned based on most recent e&m claim *** ;
		*** udates2_chk - assigned based on reverse order of TIN   *** ;
	data tax (keep = ep_id epi_tax_id ep_beg ep_end) ;
		set uniq_ids
			udates1_chk 
			udates2_chk ;
		epi_tax_id = tax_num ;


*** Check to make sure only one tax ID  has been attributed to each episode. Record count of dupl_chk should = 0 *** ;
proc sort data=tax ; by ep_id ep_beg ep_end ;
			********************************************************************** ;
**** For Episodes Attribution, need to attribute the episode tax id to the NPI with the most e and m **** ;
			********************************************************************** ;
proc sql ;
	create table step1 as
	select a.epi_tax_id, b.* 
	from tax as a inner join vc_npi as b 
	on a.ep_id=b.ep_id and a.epi_tax_id	= b.tax_num 
	where visit_count ^ = .;

proc sort data=step1 ; by ep_id ep_beg ep_end tax_num descending visit_count ;
data step2 ;
	set step1 ; by ep_id ep_beg ep_end tax_num descending visit_count ;
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

proc sort data=step2 ; by ep_id ep_beg ep_end tax_num prfnpi;
data step3_mult step3_uniq ;
	set step2 ; by ep_id  ep_beg ep_end tax_num prfnpi ;
	if first.ep_id and last.ep_id then output step3_uniq ;
	else output step3_mult ;
run;
*** tie-breakers *** ;
proc sort data=visit_count2 ; by ep_id ep_beg ep_end tax_num prfnpi ;
data step3_multclms ;
	merge step3_mult(in=a) visit_count2(in=b) ; 
	by ep_id ep_beg ep_end tax_num prfnpi ;
	if a ;
	revnpi = reverse(prfnpi) ;
	last_dig = substr(left(revnpi),1,1) ;

proc sort data=step3_multclms out=s3 nodupkey ; by ep_id ep_beg ep_end tax_num descending expnsdt1 last_dig descending clm_id ;

data udate1 mdate1 ;
	set s3 ; by ep_id ep_beg ep_end tax_num descending expnsdt1 last_dig descending clm_id ;
	if first.expnsdt1 and last.expnsdt1 then output udate1 ;
	else output mdate1 ;

data unnpi1 ;
	set udate1 ;by ep_id ep_beg ep_end tax_num descending expnsdt1 last_dig descending clm_id ;
	if first.tax_num then output ;

data level4_tie ;
	merge unnpi1(in=a keep=ep_id ep_beg ep_end tax_num)
		  step3_multclms (in=b) ; by ep_id ep_beg ep_end tax_num ;
	if a=0 and b ;

proc sort data=level4_tie ; by ep_id ep_beg ep_end tax_num descending expnsdt1 last_dig descending clm_id  ;
data unnpi2 ;
	set leveL4_tie ;by ep_id ep_beg ep_end tax_num descending expnsdt1 last_dig descending clm_id  ;
	if first.tax_num ;

data taxnpi(keep =  ep_id epi_npi_id) ;
	set step3_uniq
		unnpi1
		unnpi2;
	epi_npi_id = prfnpi ;

proc sort data= taxnpi ; by ep_id ;
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

*ip* ;
proc sort data=in.iphdr_&dsid. out=h ; by ep_id bene_id clm_id thru_dt ;
proc sort data=in.inprev_&dsid. out=r ; by ep_id bene_id clm_id thru_dt ;

data out.inpatient_&type._&dsid. ;
	merge h(in=a) r(in=b) ; by ep_id bene_id clm_id thru_dt ;
	if a and b ;

proc sql ;
	create table inp as
	select a.*,b.ep_beg, b.ep_end 
	from out.inpatient_&type._&dsid. as a, e as b
	where a.ep_id=b.ep_id and
		  b.ep_beg le admsn_dt le b.ep_end ;
	create table out as
	select a.*,b.ep_beg, b.ep_end 
	from out.outpatient_&type._&dsid. as a, e as b
	where a.ep_id=b.ep_id and
		  b.ep_beg le REV_DT le b.ep_end ;
	create table carr1a as
	select a.*,b.ep_beg, b.ep_end 
	from in.phyline_&dsid. as a, e as b
	where a.ep_id=b.ep_id and
		  b.ep_beg le expnsdt1 le b.ep_end ;
	create table dme1a as
	select a.*,b.ep_beg, b.ep_end 
	from in.dmeline_&dsid. as a, e as b
	where a.ep_id=b.ep_id and
		  b.ep_beg le expnsdt1 le b.ep_end ;
quit ;


data OUT.check_ipop_&type._&dsid.(KEEP = EP_ID BENE_ID CLM_ID THRU_DT BMT_ALLOGENEIC BMT_AUTOLOGOUS
					   /*BMT_ALLOGENEIC_AK  BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM 
					   BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL BMT_AUTOLOGOUS_AK  BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM 
					   BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL*/ RADTHER 
					   ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY
					   GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
					   OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY  
					   CLINICAL_TRIAL_MILL 
					   dxANAL_SURGERY dxBLADDER_SURGERY dxBREAST_SURGERY dxFEMALEGU_SURGERY
					   dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY dxLIVER_SURGERY dxLUNG_SURGERY
					   dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY ) ;
	set inp(in=a) out ;

	ARRAY INIT (B) CT HAS_CANCER BMT_ALLO1 BMT_ALLO2 BMT_AUTO1 BMT_AUTO2 BMT_ALLOGENEIC BMT_AUTOLOGOUS 
					 /*BMT_ALLOGENEIC_AK  BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM 
					   BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL BMT_AUTOLOGOUS_AK  BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM 
					   BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL */ RADTHER 
					   ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY
					   GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
					   OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY 
					   CLINICAL_TRIAL_MILL 
					   dxANAL_SURGERY dxBLADDER_SURGERY dxBREAST_SURGERY dxFEMALEGU_SURGERY
					   dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY dxLIVER_SURGERY dxLUNG_SURGERY
					   dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY 
;
		DO B = 1 TO DIM(INIT) ;
			INIT = 0 ;
		END ;

		%canc_init ;
		ARRAY v (I) ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD25 ;
		ARRAY d (I) ICD_DGNS_CD1-ICD_DGNS_CD25 ;
		DO I = 1 TO 25 ;
			%CANCERTYPE(v, d) ;
			IF V = '9' AND D = "V707" and NOPAY_CD = ' ' THEN CT = 1 ;
		END ;
		DROP I ;

		IF HAS_CANCER = 1 AND CT = 1 THEN DO ;
				IF A THEN CLINICAL_TRIAL_MILL = 1 ;
				ELSE IF (EP_BEG LE THRU_DT LE EP_END) OR
						(EP_BEG LE FROM_DT LE EP_END) THEN CLINICAL_TRIAL_MILL = 1 ;
		END ;

		IF NOPAY_CD = '  ' THEN DO ;

			ARRAY v1 (X) ICD_prcdr_VRSN_CD1-ICD_prcdr_VRSN_CD25 ;
			ARRAY d1 (X) ICD_prcdr_CD1-ICD_prcdr_CD25 ;
			DO X = 1 TO 25 ;
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
			END ;
			DROP X ;

			***** ;

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

			*** Added 7/11/18 - Update to include surgeries with a header level diagnosis
				code for the cancer indicated for the surgery. *** ;
			if LIVER_SURGERY = 1 AND LIVER = 1 THEN dxLIVER_SURGERY = 1 ;
			if ANAL_SURGERY = 1 AND ANAL = 1 THEN dxANAL_SURGERY = 1 ;
			if BLADDER_SURGERY = 1 and BLADDER = 1 then dxBLADDER_SURGERY = 1 ;
			if LUNG_SURGERY = 1 and LUNG = 1 then dxLUNG_SURGERY = 1 ;
			if prostate_surgery = 1 and prostate = 1 then dxPROSTATE_SURGERY = 1 ;
			if PANCREATIC_SURGERY = 1 and PANCREATIC=1 then dxPANCREATIC_SURGERY = 1 ;
			if OVARIAN_SURGERY=1 and OVARIAN=1 then dxOVARIAN_SURGERY = 1 ;
			if KIDNEY_SURGERY=1 and KIDNEY=1 then dxKIDNEY_SURGERY = 1 ;
			if HEADNECK_SURGERY=1  and HEADNECK=1 then dxHEADNECK_SURGERY = 1 ;
			if INTESTINAL_SURGERY and intestinal = 1 then dxINTESTINAL_SURGERY = 1 ;
			if GASTRO_SURGERY and GASTRO_ESOPHAGEAL=1 then dxGASTRO_SURGERY = 1 ;
			if FEMALEGU_SURGERY and FEMALEGU=1 then dxFEMALEGU_SURGERY = 1 ;
			if BREAST_SURGERY=1 and breast = 1 then dxBREAST_SURGERY = 1 ;

			*IF SUM(ACUTE_LEUKEMIA,LYMPHOMA,MULT_MYELOMA,MDS,Chronic_Leukemia) > 0 THEN DO ;
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
			*END ;

		END ;

*				ARRAY CANC (c) ACUTE_LEUKEMIA LYMPHOMA MULT_MYELOMA MDS CHRONIC_LEUKEMIA;
*				ARRAY B1 (c) BMT_ALLOGENEIC_AK  BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS BMT_ALLOGENEIC_CL;
*				ARRAY B2 (c) BMT_AUTOLOGOUS_AK  BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS BMT_AUTOLOGOUS_CL ;
					
*				DO C = 1 TO 5 ;
*					IF CANC = 1 THEN DO ;
*						B1 = BMT_ALLOGENEIC ;
*						B2 = BMT_AUTOLOGOUS ;
*					END ;
*				END ;
	

			***** ;

proc sort data=in.phyhdr_&dsid. out=ph ; by bene_id ep_id clm_id ;
proc sort data=carr1a ; by bene_id ep_id clm_id ;
proc sort data=in.dmehdr_&dsid. out=dh ; by bene_id ep_id clm_id ;
proc sort data=dme1a ; by bene_id ep_id clm_id ;


data carr1b ;
	merge carr1a(in=a) ph(in=b keep = bene_id ep_id from_dt clm_id ICD_DGNS_CD: ICD_DGNS_VRSN_CD:) ; by bene_id ep_id clm_id ;
	if a and b ;

data dme1b ;
	merge dme1a(in=a) dh(in=b keep = bene_id ep_id clm_id from_dt clm_id ICD_DGNS_CD: ICD_DGNS_VRSN_CD:) ; by bene_id ep_id clm_id ;
	if a and b ;
	
data check_carr(KEEP = EP_ID BENE_ID CLM_ID THRU_DT RADTHER 
					   ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY
					   GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LUNG_SURGERY
					   OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY 
					   dxANAL_SURGERY dxBLADDER_SURGERY dxBREAST_SURGERY dxFEMALEGU_SURGERY
					   dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY dxLUNG_SURGERY
					   dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY 
					   CLINICAL_TRIAL_MILL 
					   ACUTE_LEUKEMIA LYMPHOMA MULT_MYELOMA MDS CHRONIC_LEUKEMIA has_cancer )  ;	
	SET carr1b dme1b(in=a);

	if a then dme_flag = 1 ;
	else dme_flag = 0 ;

	ARRAY INIT (B)	   RADTHER ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY
					   GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LUNG_SURGERY
					   OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY 
					   dxANAL_SURGERY dxBLADDER_SURGERY dxBREAST_SURGERY dxFEMALEGU_SURGERY
					   dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY dxLUNG_SURGERY
					   dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY 
					   CLINICAL_TRIAL_MILL ;
		DO B = 1 TO DIM(INIT) ;
			INIT = 0 ;
		END ;

	IF LALOWCHG > 0  THEN DO ;

		%canc_init ;
		%CANCERTYPE(LINE_ICD_DGNS_VRSN_CD, LINE_ICD_DGNS_CD) ;
		has_cancer_line = has_cancer ;
		
		*** Clinical Trial looks at all header diagnosis codes for CT diagnosis but must have a
		    cancer diagnosis on the line diagnosis code. *** ;
			%canc_init ;
			array dx (l) LINE_ICD_DGNS_CD ICD_DGNS_CD1-ICD_DGNS_CD12 ;
			array Vx (l) LINE_ICD_DGNS_VRSN_CD ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD12  ;
			do l = 1 to dim(dx) ;
				%CANCERTYPE(VX, DX) ;
				IF dx = "V707" THEN CT = 1 ;
			END ;
	
			IF HAS_CANCER = 1 AND CT = 1 THEN DO ;
				IF LINE_ICD_DGNS_CD = "V707" THEN CLINICAL_TRIAL_MILL = 1 ;
				ELSE IF (EP_BEG LE FROM_DT LE EP_END) OR
						(EP_BEG LE THRU_DT LE EP_END) THEN CLINICAL_TRIAL_MILL = 1 ;
			END ;

		IF DME_FLAG = 0 THEN DO ;

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

			*** Added 7/11/18 - Update to include surgeries with a header level diagnosis
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
	END ;

run ;

data all ;
	set OUT.check_ipop_&type._&dsid. check_carr ;	
proc sort data=all ; by ep_id ;
proc means data=all noprint max ; by ep_id ;
	var BMT_ALLOGENEIC  BMT_AUTOLOGOUS  RADTHER
		ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY GASTRO_SURGERY 
		HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY 
		LUNG_SURGERY OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY KIDNEY_SURGERY 
		dxANAL_SURGERY dxBLADDER_SURGERY dxBREAST_SURGERY dxFEMALEGU_SURGERY
		dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY dxLIVER_SURGERY dxLUNG_SURGERY
		dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY dxKIDNEY_SURGERY 
		CLINICAL_TRIAL_MILL ;
	OUTPUT OUT=PREDICT_VARS (DROP = _TYPE_ _FREQ_)
		   MAX() = ;
			
***** Added 10/10/17 - Add epi counter **** ;
proc sort data=e out=e2 ; by bene_id ep_beg ep_id ;
data counter(keep = ep_id ec) ;
	set e2 ; by bene_id ep_beg ep_id ;
	if first.bene_id then ec = 1 ;
	else ec = ec+1 ;
	retain ec ;
proc sort data=counter ; by ep_id ;

********************************************************************** ;
********************************************************************** ;
****** Final Episode Files 	;

proc sort data=tax ; by ep_id ;
data epi2 ;
	merge e(in=a)
		  epi_orig (in=b keep = ep_id m_episode_beg m_epi_source attribute_flag)
		  ca(keep = ep_id cancer)
		  counter
		  predict_vars
		  tax (keep = ep_id epi_tax_id) 
		  taxnpi (keep = ep_id epi_npi_id) 
		  trigger_s ; 
	by ep_id ;

	if a ;

	if attribute_flag = 0 then missing_valid_chemo = 1 ; else missing_valid_chemo = 0 ;

	if attribute_flag = 2 then invalid_epi_beg = 1 ; else invalid_epi_beg = 0 ;

	if cancer_type = 'Intestinal' then cancer_type = 'Intestinal Cancer' ;
	if cancer_type = 'Intestinal Cancer' then cancer_type = 'Small Intestine / Colorectal Cancer' ;

	if cancer = 'Intestinal Cancer' then cancer = 'Small Intestine / Colorectal Cancer' ;

	*** Some CMS Cancer Types set to ICD10 *** ;
	if cancer_type = 'C26' then cancer_type = 'Malignant neoplasm of other and ill-defined digestive organs' ;
	if cancer_type = 'C37' then cancer_type = "Malignant neoplasm of thymus" ;
	if cancer_type = 'C38' then cancer_type = "Malignant neoplasm of heart, mediastinum and pleura" ;
	if cancer_type = 'C40' then cancer_type = "Malignant neoplasm of bone and articular cartilage of limbs" ;
	if cancer_type = 'C41' then cancer_type = "Malignant neoplasm of bone and articular cartilage of sites NOS" ;
	if cancer_type = 'C44' then cancer_type = "Malignant neoplasm of skin, NOS" ;
	if cancer_type = 'C46' then cancer_type = "Kaposi's Sarcoma" ;
	if cancer_type = 'C48' then cancer_type = "Malignant neoplasm of retroperitoneum and peritoneum" ;
	if cancer_type = 'C47 or C49' then cancer_type = "Malignant neoplasm of peripheral nerves, autonomic nervous system" ;
	if cancer_type = 'C4A' then cancer_type = "Merkel cell carcinoma" ;
	if cancer_type = 'C57' then cancer_type = "Malignant neoplasm of other and unspecified female genital organs" ;
	if cancer_type = 'C60 or C63' then cancer_type = "Malignant neoplasm of penis, other, and unspecific male organs" ;
	if cancer_type = 'C62' then cancer_type = "Malignant neoplasm of testis" ;
	if cancer_type = 'C76.1' then cancer_type = "Malignant neoplasm of thorax" ; 
	if cancer_type = 'C76.2' then cancer_type = "Malignant neoplasm of abdomen" ; 
	if cancer_type = 'C76.8' then cancer_type = "Malignant neoplasm of other specified ill-defined sites" ; 
	if cancer_type = 'C77' then cancer_type = "Secondary and unspecified malignant neoplasm of lymph nodes" ;
	if cancer_type = 'C78' then cancer_type = "Secondary malignant neoplasm of resp and digestive organs" ;
	if cancer_type = 'C79' then cancer_type = "Secondary malignant neoplasm of other and unspecified sites" ;
	if cancer_type = 'C7B' then cancer_type = "Secondary neuroendocrine tumors" ;
	if cancer_type = 'C80' then cancer_type = "Malignant neoplasm NOS" ;
	if cancer_type = 'C91.9' then cancer_type = "Lymphoid Leukemia, unspecified" ;
	IF CANCER_TYPE = 'C91.z' THEN CANCER_TYPE = "Other lymphoid leukemia" ;
	IF CANCER_TYPE = 'C92.2' THEN CANCER_TYPE = "Atypical chronic myeloid leukemia, BCR/ABL negative" ;
	if cancer_type = 'C92.9' then cancer_type = 'Myeloid leukemia, unspecified';
	if cancer_type = 'C92.z' then cancer_type = 'Other myeloid leukemia';
	if cancer_type = 'C93.1' then cancer_type = 'Chronic myelomonocytic leukemia' ;
	IF CANCER_TYPE = 'C93.9' THEN CANCER_TYPE = "Monocytic Leukemia, unspecified" ;
	if cancer_type = 'C95.1' then cancer_type = 'Chronic leukemia of unspecified cell type' ;
	if cancer_type = 'C95.9' then cancer_type = 'Leukemia, unspecified' ;
	if cancer_type = 'C96' then cancer_type = "Malignant neoplasm of lymphoid, hematopoietic NOS" ;
	IF CANCER_TYPE = 'D00' THEN CANCER_TYPE = "Carcinoma in situ of oral cavity, esophagus and stomach" ;
	if cancer_type = 'D01' then cancer_type = 'Carcinoma in situ of other and NOS digestive organs' ;
	if cancer_type = 'D02' then cancer_type = 'Carcinoma in situ of middle ear and respiratory system' ;
	if cancer_type = 'D04' then cancer_type = 'Carcinoma in situ of skin' ;
	if cancer_type = 'D05' then cancer_type = 'Carcinoma in situ of breast' ;
	if cancer_type = 'D07' then cancer_type = 'Carcinoma in situ of other and NOS genital organs' ;
	if cancer_type = 'D09' then cancer_type = 'Carcinoma in situ of other and unspecified sites' ;
	if cancer_type = 'D45' then cancer_type = 'Polycythemia vera' ; 
	if cancer_type = 'D47.3' then cancer_type = 'Essential (hemorrhagic) thrombocythemia' ;
	if cancer_type = 'D47.4' then cancer_type = 'Osteomyelofibrosis' ;
	if cancer_type = 'D75.81' then cancer_type = 'Myelofibrosis' ;

	*** Renaming Milliman to match OCM ** ;
	if cancer = 'Malignant neoplasm of female genital organs NOS' then cancer = 'Malignant neoplasm of other and unspecified female genital organs' ;
	if cancer = 'Leukemia, NOS' then cancer = 'Leukemia, unspecified' ;
	if cancer = 'Malignant neoplasm of penis, other male organs NOS' then cancer = 'Malignant neoplasm of penis, other, and unspecific male organs' ;
	if cancer = 'Lymphoid Leukemia, NOS' then cancer = 'Lymphoid Leukemia, unspecified' ;
	*** added 10/18/17 *** ;
	if cancer = "Secondary malignant neoplasm NOS" then 
		cancer = "Secondary malignant neoplasm of other and unspecified sites" ;
	if cancer = 'Malignant neoplasm of other ill-defined sites' then
		cancer = 'Malignant neoplasm of other and specified ill-defined sites' ;
	
	if cancer = 'Secondary malignant neoplasm of resp and digestive organs' then 
		cancer = 'Secondary malignant neoplasm of respiratory and digestive organs' ; 
	
	*** 6/13/17: Addition of cancer type change to conform with MA labeling logic. *** ;
	if cancer_type = "Carcinoma in situ of other and unspecified genital organs" then 
	   cancer_type = "Carcinoma in situ of other and NOS genital organs"  	   ;
	if 	   cancer_type in 
			("Malignant neoplasm of peripheral nerves, autonomic nervous system, and other and connective soft tis",
			 "Malignant neoplasm of peripheral nerves, autonomic nervous system, and other and connective soft tissue") then 
		   cancer_type = "Malignant neoplasm of peripheral nerves, autonomic nervous system"   ;
	if cancer_type = "Myeloid leukemia, unspecified" then cancer_type = "Myeloid Leukemia, NOS"  ;

	if cancer_type = "Secondary and unspecified malignant neoplasm of lymph nodes" then
	   cancer_type = "Secondary malignant neoplasm of lymph nodes" ;

	IF CANCER_TYPE = "Carcinoma in situ of other and unspecified sites" THEN
	   CANCER_TYPE = "Carcinoma in situ of other and NOS sites" ;

	if cancer_type = "Juvenile myelomonocytic leukemia"  then
	   cancer_type = "JUV Myelomonocytic Leukemia" ;
	if cancer = "Juvenile myelomonocytic leukemia"  then
	   cancer = "JUV Myelomonocytic Leukemia" ;

	if cancer_type = "Essential (hemorrhagic) thrombocythemia "  then
	   cancer_type = "Essential thrombocythemia" ;
	if cancer = "Essential (hemorrhagic) thrombocythemia"  then
	   cancer = "Essential thrombocythemia" ;

	if cancer_type = "Carcinoma in situ of oral cavity, esophagus and stomach" then
	   cancer_type = "Carcinoma in situ of oral cavity, esophagus, stomach" ;

	if cancer_type = "Monocytic Leukemia, unspecified" then 
	   cancer_type = "Monocytic Leukemia, NOS" ;

	if cancer ne cancer_type then cancer_notmatch = 1 ; else cancer_notmatch = 0 ;

	CANCER_TYPE_MILLIMAN = CANCER ; DROP CANCER ;

	**** Place Holders for additional checks. **** ;
	RECON_Elig_Invalid = 0 ; **** Harsha or Mona can program to check cancer_type against what is in file. ****
							 **** Assign to 1 when CMS indication is not correct.						   **** ;
	
	DUAL_INVALID = 0 ; **** Meant to evaluate accuracy of DUAL_PTD_LIS assignment.  Unable to do this 	   **** 
					   **** screen yet as enrollment data is not provided. 								   **** ;

	INST_INVALID = 0 ; *** Unable to validate this as we do not get claims prior to episode.			   **** ;

	if RADIATION NE RADTHER THEN Rad_Invalid = 1 ; 
	else Rad_Invalid = 0 ;  
	RADIATION_MILLIMAN = RADTHER ; DROP RADTHER ;

	HCC_GRP_MILLIMAN = HCC_GRP ; *** Will need to add coding for this. *** ;
	HCC_Nomatch = 0 ;  **** Accuracy of HCC count flag.  Christine to program.							   **** ;

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
	
	has_surgery = 0 ;
	has_surgery = max(BREAST_SURGERY, ANAL_SURGERY, LUNG_SURGERY, FEMALEGU_SURGERY, LIVER_SURGERY,
					  GASTRO_SURGERY, HEADNECK_SURGERY, INTESTINAL_SURGERY, OVARIAN_SURGERY, 
					  PROSTATE_SURGERY, PANCREATIC_SURGERY, BLADDER_SURGERY, KIDNEY_SURGERY) ;
	if SURGERY ne has_surgery then SURG_INVALID = 1 ;
	else SURG_INVALID = 0 ;

	SURGERY_MILLIMAN = HAS_SURGERY ; drop has_surgery ;

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

	if CANCER_TYPE_MILLIMAN notin ("Acute Leukemia","Lymphoma","MDS","Multiple Myeloma","Chronic Leukemia") then BMT_Milliman = 4 ;
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
	if CANCER_TYPE_MILLIMAN = "Acute Leukemia" then BMT_MILLIMAN = BM_AK ;
	if CANCER_TYPE_MILLIMAN = "Lymphoma" then BMT_MILLIMAN = BM_L ;
	if CANCER_TYPE_MILLIMAN = "MDS" then BMT_MILLIMAN = BM_MDS ;
	if CANCER_TYPE_MILLIMAN = "Multiple Myeloma" then BMT_MILLIMAN = BM_MM ;
	IF CANCER_TYPE_MILLIMAN = "Chronic Leukemia" then BMT_MILLIMAN = BM_CL ;
	end ;

	if BMT ne BMT_Milliman then BMT_Invalid = 1 ;
	else BMT_Invalid = 0 ;  

	*** Do not think we can validate HRR_REL_COST field.  Check with Pamela.							   **** ;
	HRR_REL_COST_MILLIMAN = HRR_REL_COST ; 
	
	if CLINICAL_TRIAL NE CLINICAL_TRIAL_MILL THEN CT_Invalid = 1 ;
	ELSE CT_Invalid  = 0 ;   
	CLINICAL_TRIAL_MILLIMAN = CLINICAL_TRIAL_MILL ; DROP CLINICAL_TRIAL_MILL ;
	
	**** Accuracy of Part D Chemo flag.  **** ;
	PTD_CHEMO_MILLIMAN = MAX(PARTDONLY,0) ;
	if CANCER_TYPE_MILLIMAN ne "Breast Cancer" then PTD_CHEMO_MILLIMAN = 2 ;
	if PTD_CHEMO ne PTD_CHEMO_MILLIMAN then chemod_invalid = 1 ; 
	else chemod_invalid = 0 ; 

run ;

********************************************************************** ;
********************************************************************** ;

**** Create Claim flags for Episode level interface. **** ;

proc sort data=out.inpatient_&type._&dsid. out=has_ip(keep=ep_id) nodupkey ; by ep_id ;
proc sort data=in.snfhdr_&dsid. out=has_snf(keep=ep_id) nodupkey ; by ep_id ;
proc sort data=in.hhahdr_&dsid. out=has_hh(keep=ep_id) nodupkey ; by ep_id ;
proc sort data=in.hsphdr_&dsid. out=has_hsp (keep=ep_id) nodupkey ; by ep_id ;
proc sort data=out.outpatient_&type._&dsid. out=has_op (keep = ep_id) nodupkey ; by ep_id ;
DATA CARRDME ;
	set in.phyline_&dsid.(in=a) in.dmeline_&dsid. ;
proc sort data=carrdme out=has_cd(keep = ep_id) nodupkey ; by ep_id ;
proc sort data=chemo_candidates1 out=c1(keep=ep_id) nodupkey ; by ep_id ;
proc sort data=chemo_candidates2 out=c2(keep=ep_id) nodupkey ; by ep_id ;
proc sort data=chemo_candidates3 out=c3(keep=ep_id) nodupkey ; by ep_id ;

********************************************************************** ;
********************************************************************** ;

*** Create file to present for interface. *** ;
data out.epi_prelim_&type._&dsid. ;
	merge epi2(in=a) has_ip(in=b) has_snf(in=c) has_hh(in=d) has_hsp(in=e) has_op(in=f) has_cd(in=g) 
		  c1(in=c1) c2(in=c2) c3(in=c3) days;
	by ep_id ;
	if a ;
	if b then IP_UTIL = 1 ;
	IF c THEN SNF_UTIL = 1 ;
	IF d THEN HH_UTIL = 1 ;
	IF e THEN HSP_UTIL = 1 ;
	IF b OR c OR d OR e OR f THEN FAC_UTIL = 1 ;
	IF g then PROF_UTIL = 1 ;
	if c1 or c2 then CHEMO_B_UTIL = 1 ;
	if c3 then CHEMO_D_UTIL = 1 ;
	CHEMO_DAYS_PARTB = CHEMO_DAYS ;
	CHEMO_LENGTH_PARTB = sum(chemo_start-chemo_end,1) ;

	*** Following variables will be assigned in 003_Service_Categories *** ;
	RAD_ONC_UTIL = 0 ;
	RAD_ONC_DAYS = 0 ;
	RAD_ONC_LENGTH = 0 ;
	IP_MED_CHEMO_UTIL  = 0 ;
	IP_MED_NON_CHEMO_UTIL = 0 ;
	IP_SURG_CHEMO_UTIL = 0 ;
	IP_SURG_NON_CHEMO_UTIL = 0 ;
	IP_OTHER_UTIL = 0 ;
	ER_CHEMO_UTIL = 0 ;
	ER_NON_CHEMO_UTIL = 0 ;
	OUT_SURG_CANCER_UTIL = 0 ;
	OUT_SURG_NONCANCER_UTIL = 0 ;
	ANTI_EMETICS_UTIL = 0 ;
	HEMOTAPOETIC_UTIL = 0 ;
	OTHER_DRUGS_UTIL = 0 ;
	CHEMO_ADMIN_UTIL = 0 ;
	RAD_HTECH_UTIL = 0 ;
	RAD_OTHER_UTIL = 0 ;
	LAB_UTIL = 0 ;
	PROF_IP_UTIL = 0 ;
	PROF_ANESTHESIA_UTIL = 0 ;
	PROF_OTHER_UTIL = 0 ;
	DME_UTIL = 0 ;


	
run ;

********************************************************************** ;
					**** Episode Validation **** ;
********************************************************************** ;

proc freq data=out.epi_prelim_&type._&dsid. ;
	tables cancer_type cancer_type_milliman; run ;
title "&dsid: CMS Cancer Types" ;

proc print data=out.epi_prelim_&type._&dsid. ;
	where cancer_type_milliman = "  " ;
	var bene_id ep_id ep_beg ep_end missing_valid_chemo invalid_epi_beg m_episode_beg cancer_type cancer_type_milliman ;
title "&dsid: Episodes where Milliman did not map a cancer" ;
run ;

proc freq data=out.epi_prelim_&type._&dsid. ;
	tables cancer_notmatch Rad_Invalid SURG_INVALID CT_Invalid BMT_Invalid chemod_invalid ; 
title "&dsid: Episode Mismatch Flags" ;

run ;

data mismatch_trigger(keep = bene_id ep_id cancer_type cancer_type_milliman ep_beg ep_end dod m_episode_beg 
							 missing_valid_chemo invalid_epi_beg) 
	 mismatch_pm(keep = bene_id ep_id ep_beg ep_end dod cancer_type cancer_type_milliman
						cancer_notmatch rad_invalid surg_invalid ct_invalid bmt_invalid chemod_invalid);
	set out.epi_prelim_&type._&dsid. ;
	if max(missing_valid_chemo,invalid_epi_beg) = 1 then output mismatch_trigger ;
	if max(cancer_notmatch,rad_invalid,surg_invalid, ct_invalid, bmt_invalid, chemod_invalid) = 1 then output mismatch_pm ;

proc export data=mismatch_trigger
	outfile = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Baseline\V2\REPORTS\recon_check1_&type._&dsid._&datecreate."
	dbms=xls replace ;
	quit ;
proc export data=mismatch_pm
	outfile = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Baseline\V2\REPORTS\recon_check2_&type._&dsid._&datecreate."
	dbms=xls replace ;
	quit ;


%mend epi ;
********************************************************************** ;
********************************************************************** ;
%let type=blv3 ; run ;

%epi(255_50179,255) ; run ;
%epi(257_50195,257) ; run ;
%epi(278_50193,278) ; run ;
%epi(280_50115,280) ; run ;
%epi(290_50202,290) ; run ;
%epi(396_50258,396) ; run ;
%epi(401_50228,401) ; run ;
%epi(459_50243,459) ; run ;
%epi(468_50227,468) ; run ;
%epi(480_50185,480) ; run ;
%epi(523_50330,523) ; run ;
%epi(137_50136,137) ; run ;


/*
*** Run distributions of cancer types to ensure correct wording - submit to Sam *** ;
DATA EPI_COMBINE ;
	SET OUT.epi_prelim_&type._255_50179(KEEP = CANCER_TYPE CANCER_TYPE_MILLIMAN)
		OUT.epi_prelim_&type._257_50195(KEEP = CANCER_TYPE CANCER_TYPE_MILLIMAN)
		OUT.epi_prelim_&type._278_50193(KEEP = CANCER_TYPE CANCER_TYPE_MILLIMAN)
		OUT.epi_prelim_&type._290_50202(KEEP = CANCER_TYPE CANCER_TYPE_MILLIMAN)
		OUT.epi_prelim_&type._396_50258(KEEP = CANCER_TYPE CANCER_TYPE_MILLIMAN)
		OUT.epi_prelim_&type._480_50185(KEEP = CANCER_TYPE CANCER_TYPE_MILLIMAN)
		OUT.epi_prelim_&type._523_50330(KEEP = CANCER_TYPE CANCER_TYPE_MILLIMAN)
		OUT.epi_prelim_&type._401_50228(KEEP = CANCER_TYPE CANCER_TYPE_MILLIMAN)
		OUT.epi_prelim_&type._137_50136(KEEP = CANCER_TYPE CANCER_TYPE_MILLIMAN)
		OUT.epi_prelim_&type._280_50115(KEEP = CANCER_TYPE CANCER_TYPE_MILLIMAN)
		OUT.epi_prelim_&type._468_50227(KEEP = CANCER_TYPE CANCER_TYPE_MILLIMAN)
		OUT.epi_prelim_&type._459_50243(KEEP = CANCER_TYPE CANCER_TYPE_MILLIMAN) ;

PROC FREQ DATA=EPI_COMBINE  ;
	TABLES CANCER_TYPE*CANCER_TYPE_MILLIMAN/LIST MISSING OUT = CANCER_DIST;

 PROC EXPORT DATA=CANCER_DIST
 	OUTFILE = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\89 - SAS\01 - Baseline Files\Out\CANCER_DIST_BL2_20180201.XLSX" 
	DBMS=XLS REPLACE ;
QUIT ;
*/
***************************************************************************** ;
		******************** investigations ********************* ;
***************************************************************************** ;
