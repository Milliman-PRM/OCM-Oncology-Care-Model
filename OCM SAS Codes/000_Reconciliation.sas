********************************************************************** ;
********************************************************************** ;
**** Based on Appendix A-C in OCM PBP Methodology.PDF **************** ;
********************************************************************** ;

libname r2 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\SAS" ;

options ls=132 ps=70 obs=max;

********************************************************************** ;
********************************************************************** ;
%let cdate = 20160804 ;  *** date in file names *** ;
%include "H:\HIPAA\PRE_KF_Premier\44 - Oncology Care Model Interface\Work Papers\SAS\000_Formats.sas" ;
%include "H:\HIPAA\PRE_KF_Premier\44 - Oncology Care Model Interface\Work Papers\SAS\000_Cancer Diagnoses.sas" ;
********************************************************************** ;
********************************************************************** ;

%macro recon (dsid,ep) ;
proc print data=r2.epi_&dsid. ;
	where ep_id = &ep. ;
title 'episodes' ;
proc print data=r2.phyline_&dsid. ;
	where ep_id = &ep. ;
title 'phys line' ;
proc print data=r2.dmeline_&dsid. ;
	where ep_id = &ep.;
title 'DME line' ;
proc print data=r2.PDE_&dsid.;
	where ep_id = &ep. ;
title 'PDE' ;
proc print data=r2.outhdr_&dsid. ;
	where ep_id = &ep. ;
title 'outpatient head' ;
proc print data=r2.outrev_&dsid. ;
	where ep_id = &ep. ;
title 'outpatient rev line' ;

%mend recon ;

%recon(396_50258,2220039) ; run ;

proc print data=r2.outhdr_396_50258(obs=10) ; run ;
proc print data=cancers ;
	where bene_id = '100040132' ; run ;

***** Check to see if any data is provided to any episode. *** ;
%macro inv(ds) ;
data epi ;
	set r2.epi_&ds. ;
	keep bene_id ep_beg ep_end ep_id ;

proc sql ;

	create table phys_chk as 
	select a.bene_id, a.EXPNSDT1, a.thru_dt from
		r2.phyline_&ds. as a, epi as b 
	where a.bene_id=b.bene_id and a.ep_id=b.ep_id and
		  (thru_dt < ep_beg and thru_dt ne .  /*or ep_end < EXPNSDT1*/) ;

	create table dme_chk as 
	select a.bene_id, a.EXPNSDT1 from
		r2.dmeline_&ds. as a, epi as b 
	where a.bene_id=b.bene_id and a.ep_id=b.ep_id and
		  (EXPNSDT1 < ep_beg and expnsdt1 ne . /*or ep_end < EXPNSDT1*/) ;

	create table oprev_chk as 
	select a.bene_id, a.rev_dt from
		r2.outrev_&ds. as a, epi as b 
	where a.bene_id=b.bene_id and a.ep_id=b.ep_id and
		  (rev_dt < ep_beg and rev_dt ne . /*or ep_end < rev_dt*/) ;

	create table ophdr_chk as
	select a.bene_id, a.from_Dt from
		r2.outhdr_&ds. as a, epi as b
	where a.bene_id=b.bene_id and a.ep_id=b.ep_id and
		  (from_dt < ep_beg and from_dt ne . /*or ep_end < rev_dt*/) ;

		  /*
	create table pd_chk as 
	select a.bene_id, a.srvc_dt from
		r2.PDE_&ds. as a, epi as b 
	where a.bene_id=b.bene_id and a.ep_id=b.ep_id and
		  (srvc_dt < ep_beg or ep_end < srvc_dt) ;*/
quit ;
%mend inv ;
%inv(396_50258) ; run ;

proc freq data=r2.outrev_396_50258 ;
*	tables rev_dt*thru_dt/list missing ;
*	format rev_dt thru_dt yymm6. ;
	where rev_dt = . ;
	tables revpmt ; 

run ;

proc print data=r2.outrev_396_50258 (obs=100);
	where rev_dt = . ; run ;

********************************************************************** ;
********************************************************************** ;
**** Step 1: Identify all possible claims that could trigger an episode ending in the performance period ;
**** 1.A. Carrier (r2.PHYLINE_&dsid.), DMEPOS (r2.DMELINE_&dsid.)  **** ;

data lines chemo EM;

	set r2.phyline_&dsid.(in=a) r2.dmeline_&dsid. ;
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
	if year(EXPNSDT1) in (2012,2013,2014) then do ;

	**The chemotherapy drug line item must not be denied (line allowed charge >0). ** ;
	if LALOWCHG > 0 then do ;

	**The chemotherapy drug line place of service must not be an inpatient hospital (21). ** ;
	if PLCSRVC ne '21' then do ;
		chemo = 1  ;
		output chemo ;
	end ;

	end ;

	end ;

	end ;



	output lines ;

	** The chemotherapy drug claim must contain an included cancer diagnosis code available on the CMS OCM website) 
   		in any non-denied line item on the same claim (does not have to be same line as HCPCS code above -
   		do not use the header diagnoses).  ** ;

proc sort data=lines ; by bene_Id clm_id thru_dt ;
proc sort data=chemo out=chemo2(keep = bene_Id clm_id thru_dt) ; by bene_Id clm_id thru_dt ;

data chemo_claims ;
	merge lines(in=a) chemo2(in=b) ; by bene_id clm_id thru_dt ;
	if a and b ;
	**	The trigger date is the line first expense date on the qualifying chemotherapy drug line. *** ;
	if chemo = 1 then trigger_date = expnsdt1 ;
	format trigger_date mmddyy10. ;

proc sort data=chemo_claims ; by bene_id clm_id thru_dt carr ;
proc means data=chemo_claims noprint min max ; by bene_id clm_id thru_dt carr;
	var has_cancer trigger_date ;
	output out=chemo_flag(drop = _freq_ _type_)
		   max(has_cancer) = 
		   min(trigger_date) = ;	

data chemo_candidates1 ;
	set chemo_flag ;
	if has_cancer = 1 ;
run ;
	

**** 1.B. Outpatient (outrev_&dsid., r2.outhdr_&dsid.)  **** ;

	**** Combining files *****;
proc sort data=r2.outhdr_&dsid. out=h ; by BENE_ID CLM_ID THRU_DT ;
proc sort data=r2.outrev_&dsid. out=r ; by BENE_ID CLM_ID THRU_DT ;
data r2.outpatient_&dsid. ;
		merge h(in=a) r(in=b) ; 
		by BENE_ID CLM_ID THRU_DT ; 
		if a and b ;

		%canc_init ;

		ARRAY v (I) ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD25 ;
		ARRAY d (I) ICD_DGNS_CD1-ICD_DGNS_CD25 ;
		DO I = 1 TO 25 ;
			%CANCERTYPE(v, d) ;
		END ;
		DROP I ;

	
data chemo_candidates2(keep = bene_id clm_id thru_dt trigger_date has_cancer)  ;
	set	r2.outpatient_&dsid. ;

	**The claim must contain a HCPCS code indicating an included chemotherapy drug (initiating cancer therapy) 
	  in any revenue center. ** ;
	if put(HCPCS_CD,$Chemo_J.) =  "Y"  then do ;

	** The revenue center date on the same revenue center in which the HCPCS code is found must be in the 
	   appropriate 6 month Episode Beginning period in Table 1, inclusive of end dates ** ;
	**** Episodes begin 2012-2014, run through 6/2015 **** ;
	if year(REV_DT) in (2012,2013,2014) then do ;

	** The claim must not be denied (Medicare non-payment reason code is not blank). ** ;
	if NOPAY_CD =  "  "    then do ;

	** The revenue center in which the HCPCS code is found must not be denied (revenue center 
	   total charge amount minus revenue center non-covered charge amount > 0). ** ;
	*** Fields not available so not performing the screen at this time. **** ;

	** The claim header must contain an included cancer diagnosis code **;
	if has_cancer = 1 then do ;
		chemo = 1 ; 
		format trigger_date mmddyy10. ;
		trigger_date = rev_dt ;
		output chemo_candidates2 ;
	end ;
	
	end ;

	end ;

	end ;


**** 1.C. Part D (r2.PDE_&dsid.)  **** ;

data chemo(keep = bene_id pde_id ep_id trigger_date) ;
	set r2.PDE_&dsid. ;

	** The claim must contain an included chemotherapy drug (initiating cancer therapy) NDC code. ** ;
	ndc9 = substr(prod_srvc_id,1,9) ;

	if put(NDC9, $Chemo_NDC.) = "Y" then do ;

	** The claim “fill date” must be in the appropriate 6 month “Episode Beginning” period in 
	   Table 1, inclusive of end dates. ** ;
	**** Episodes begin 2012-2014, run through 6/2015 **** ;
	if year(SRVC_DT) in (2012,2013,2014) then do ;
		chemo = 1 ;
		format trigger_date mmddyy10. ;
		trigger_date = SRVC_DT ;
		output chemo ;
	end ;

	end ;

** A non-denied Carrier (line allowed charge >0) or Outpatient (Medicare non-payment reason code is not blank) 
   claim with an included cancer diagnosis code in any line item (Carrier) or in the header (Outpatient) 
   can be found on the fill date or in the 59 days preceding the fill date. Use line first expense date on the 
   Carrier claims and from date on the Outpatient claims to determine if the claim occurred on the fill date or 
   in the 59 days prior. ** ;
data carrier(keep = bene_id cdate) ;
	set lines ;
	if carr=1 and has_cancer = 1 and LALOWCHG > 0 ;
	cdate = expnsdt1 ;
	format cdate mmddyy10. ; 
data op(keep = bene_id cdate) ;
	set r2.outpatient_&dsid. ;
	if NOPAY_CD = "  " and has_cancer = 1 ;
	cdate = FROM_DT ;
	format cdate mmddyy10. ;
data cancers ; set carrier op ;
proc sort data=cancers nodupkey ; by bene_id cdate ;
proc sql ;
	create table chemo_candidates3 as
	select a.bene_id, a.trigger_date, a.pde_id
	from chemo as a, cancers as b
	where a.bene_id = b.bene_id and
		  (trigger_date-59)<= cdate <= trigger_date ;

RUN ;
********************************************************************** ;
********************************************************************** ;
**** Step 2: Identify potential episodes ;

** For each potential trigger claim identified in Step 1, flag whether the 6 months following the 
   trigger date meet the three criteria below. Episodes will be end-dated 6 calendar months after the 
   trigger date, even in the case of death before 6 months. ** ;

data triggers ;
	set chemo_candidates1(in=a) chemo_candidates2(in=b) chemo_candidates3(in=c rename=(pde_id=clm_id)) ;
	format episode_end mmddyy10. ;
	episode_end = intnx('month', trigger_date, 6) ;
	if a and carr = 1 then source = 1 ; *** carrier is first in hierarchy *** ;
	if b then source = 2 ; *** outpatient is second in hierarchy *** ;
	if a and carr ne 1 then source = 3 ; *** DME is third in hierarchy *** ;
	if c then source = 4 ; *** Part D is fourth in hierarchy **** ;

proc sort data=triggers nodupkey ; by bene_id trigger_date source clm_id  ;

***********
Apply the following hierarchy if there is more than one trigger claim on the same day from different 
types of service: Outpatient, Carrier, DMEPOS, Part D
If there is still more than one trigger claim on the same day within the same type of service, 
choose the claim with the first claim ID. ********* ;

data triggersa ;
	set triggers ; by bene_id trigger_date ;
	if first.trigger_date then do ;
		prevsource = source ;
		keep = 1 ;
	end ;
	else do ;
		if source = prevsource then keep = 1 ;
		else keep = 0 ;
	end ;
	retain prevsource ;

data triggersb ;
	set triggersa ; by bene_id trigger_date source clm_id ;
	if first.clm_id ;

** A trigger claim initiates an episode only when all of the below criteria are met.;
** For all performance periods, the potential episode trigger date must not be included 
   in any episode defined for a prior performance period.  6 Potential trigger claims occurring 
   inside a previously defined episode cannot trigger a new episode. ** ;
data triggers2 ;
	set triggersb ; by bene_id ;
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

** The 6 month period beginning with the trigger date must contain a non-denied Carrier claim with an 
   E&M visit (HCPCS code 99201 – 99205, 99211 – 99215) AND an included cancer diagnosis code on the same line item. ** ;
proc sql ;
	create table triggers3 as
	select a.bene_id, a.trigger_date, a.source, a.clm_id, a.episode_end 
	from triggers2 as a, em as b
	where a.bene_id=b.bene_id and 
		  trigger_date le expnsdt1 le episode_end ;
proc sort data=triggers3 nodupkey ; by bene_id trigger_date ;

********************************************************************** ;
********************************************************************** ;
**** Step 3: Identify final set of episodes ;

**The beneficiary must meet the criteria below for the entire 6 month period (or until death) beginning with the trigger date, inclusive of end dates:
• Beneficiary is enrolled in Medicare Parts A and B
• Beneficiary does not receive the Medicare ESRD benefit, as determined by the Medicare Enrollment Database
• Beneficiary has Medicare as his or her primary payer
• Beneficiary is not covered under Medicare Advantage or any other group health program. ** ;
*** Data not provided. **** ;


data episode_candidates ;
	set triggers3 ;
	format episode_beg mmddyy10. ;
	episode_beg = trigger_date;
	epi_claim = clm_id ;
	epi_source = source ;
	drop trigger_date clm_id source ;


********************************************************************** ;
********************************************************************** ;
**** Appendix B: Identify cancer ;

proc sql ;
	create table canc as
	select a.*, b.*
	from episode_candidates as a, em as b
	where a.bene_id=b.bene_id and 
		episode_beg le expnsdt1 le episode_end ;

** Identify unique visits and count the number of visits associated with each cancer type. **
** For the purposes of assigning a cancer type to the episode, a visit is defined by the 
   unique combination of beneficiary ID, TIN, line first expense date, and cancer type 
   associated with the diagnosis code on the line. *** ;
proc sort data=canc ; by bene_id episode_beg epi_source episode_end epi_claim
					    %canc_flags has_cancer tax_num expnsdt1 ;

data visit_count ;
	set canc ; 
			  by bene_id episode_beg epi_source episode_end epi_claim
				%canc_flags has_cancer tax_num expnsdt1 ;
	if first.expnsdt1 then visit_count = 1 ;						 	 

proc means data=visit_count noprint sum ; 
			  by bene_id episode_beg epi_source episode_end epi_claim
				%canc_flags has_cancer ;
	var visit_count ;
	output out=vc(drop = _type_ _freq_)
		   sum() =  ;

** Assign the episode the cancer type that has the most visits. ** 
	In the event of a tie, apply tie-breakers in the order below. Assign the cancer type associated with:
	The most recent visit in the episode, second most recent visit, third most recent visit, etc.
	The cancer type that is reconciliation-eligible
	The lowest last digit of the TIN, second lowest digit, etc. ** ;

proc sort data=vc ; by bene_id episode_beg epi_source episode_end epi_claim
					   %canc_flags has_cancer descending visit_count  ;

data cancer ;
	set vc ;  by bene_id episode_beg epi_source episode_end epi_claim
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
	set cancer ; by bene_id episode_beg epi_source episode_end epi_claim
			     %canc_flags has_cancer ;
	if first.epi_claim and last.epi_claim then output uniq_cancer ;
	else output mult_cancer ;

*** tie_breakers *** ;

data claims_for_mult ;
	merge mult_cancer(in=a) visit_count(in=b) ; 
	by bene_id episode_beg epi_source episode_end epi_claim %canc_flags has_cancer ;
	if a ;

proc sort data=claims_for_mult ; by bene_id episode_beg epi_source episode_end epi_claim 
								 descending expnsdt1 descending recon_elig tax_num ;
data tb_cancer ;
	set claims_for_mult ; by bene_id episode_beg epi_source episode_end epi_claim 
							  descending expnsdt1 descending recon_elig tax_num ;
	if first.epi_claim ;

data cancer_assignment (keep = Bene_id episode_beg epi_source episode_end epi_claim cancer recon_elig) ;
	set uniq_cancer tb_cancer ;
	%assign_cancer ;
proc sort data=cancer_assignment ; by 	Bene_id episode_beg epi_source episode_end epi_claim ;
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
proc sort data=visit_count ; by bene_id episode_beg epi_source episode_end epi_claim tax_num  ;
proc means data=visit_count noprint sum ; 
			  by bene_id episode_beg epi_source episode_end epi_claim tax_num ;
	var visit_count ;
	output out=vc(drop = _type_ _freq_)
		   sum() =  ;
proc sort data=vc ; by bene_id episode_beg epi_source episode_end epi_claim descending visit_count ;
data vc2 ;
	set vc ; by bene_id episode_beg epi_source episode_end epi_claim descending visit_count ;
	if first.epi_claim then do ;
		MOST = 1 ;
		PREV_VC = VISIT_COUNT ;
	END ;
	else do ;
		if visit_count = prev_vc then most = 1 ; 
		else most = 0 ;
	end ;
	if most = 1 ;

proc sort data=vc2 ; by bene_id episode_beg epi_source episode_end epi_claim tax_num ;
data mult_ids uniq_ids ;
	set vc2 ; by bene_id episode_beg epi_source episode_end epi_claim tax_num ;
	if first.epi_claim and last.epi_claim then output uniq_ids ;
	else output mult_ids ;


*** tie-breakers *** ;
proc sort data=visit_count ; by bene_id episode_beg epi_source episode_end epi_claim tax_num ;
data claims_for_mult ;
	merge mult_ids(in=a) visit_count(in=b) ; 
	by bene_id episode_beg epi_source episode_end epi_claim tax_num ;
	if a ;

proc sort data=claims_for_mult ; by bene_id episode_beg epi_source episode_end epi_claim 
								 descending expnsdt1 tax_num ;
data tb_id ;
	set claims_for_mult ; by bene_id episode_beg epi_source episode_end epi_claim 
							 descending expnsdt1 tax_num ;
	if first.epi_claim ;

data tax(keep = bene_id episode_beg epi_source episode_end epi_claim epi_tax_id) ;
	set uniq_ids
		tb_id ;
	epi_tax_id = tax_num ;
	
********************************************************************** ;
********************************************************************** ;
****** Final Episode Files 	;
data r2.episodes_&dsid ;
	merge episode_candidates(in=a) cancer_assignment (in=b) tax(in=c) ;
	by bene_id episode_beg epi_source episode_end epi_claim ;
	if a and b and c ;

proc sort data=r2.episodes_&dsid. ; by bene_id ;

*** NOTE: should not lose any episodes in this merge - check log. **** ;
********************************************************************** ;
********************************************************************** ;
%mend epi ;
********************************************************************** ;
********************************************************************** ;
/*
%epi(255_50179) ; run ;
%epi(257_50195) ; run ;
*/
*%epi(396_50258) ; run ;



proc sort data=r2.episodes_396_50258 ; by bene_id episode_beg ;
proc sort data=r2.epi_396_50258 out=epi ; by bene_id ep_beg ;

data check ours theirs  ;
	merge r2.episodes_396_50258(in=a) 	epi(rename = (ep_beg=episode_beg) in=b) ; by bene_id episode_beg ;
	if a and b then output check ;
	else if a and b=0 then output ours  ;
	else if a=0 and b then output theirs ;
run ;

proc print data=theirs (obs=10) ; run ;
proc print data=ours ; 
	where bene_id = '100040132' ; run ;
