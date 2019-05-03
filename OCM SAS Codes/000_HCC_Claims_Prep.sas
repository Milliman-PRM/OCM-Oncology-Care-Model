********************************************************************** ;
		***** 000_HCC_Claims_Prep.sas ***** ;
********************************************************************** ;

%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\CMS HHS 2015 Model\Annual Formats\Risk Adjustment Formats.sas" ;

%macro combine(file,p1) ;
data &file.claims(keep = desy_sort_key claim_no thru_dt icd_dgns:)  ;
	set out.&file._claimsj_hist out.&file._claims ;

data &file.rev(keep = desy_sort_key claim_no thru_dt rev_cntr hcpcs_cd) ;
	%if "&p1." = "0" %then %do ;
	set out.&file._revenuej_hist out.&file._revenue ;
	%end ;
	%else %do ;
	set out.&file._revenue_hccmodel ;
	%end ;

proc sort data=&file.claims ; by desy_sort_key claim_no thru_dt ;
proc sort data=&file.rev ; by desy_sort_key claim_no thru_dt ;

data &file. ;
	merge &file.claims(in=a) &file.rev(in=b) ; by desy_sort_key claim_no thru_dt ;
	if a and b ;
	screen_year = year(thru_dt) ;
	array dx1 (i) ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD25 ;
	DO I = 1 TO DIM(DX1) ;
		IF DX1 = " " THEN DX1 = "0" ;  *** Accounts for 2016 missing version code fields. *** ;
	END ;

proc sort data=&file. ; by desy_sort_key screen_year ;
data &file._final;
	merge out.person16(in=a keep = hicno desy_sort_key ep_id screen_year) &file.(in=b) ; by desy_sort_key screen_year ;
	if a and b ;
%mend combine ;
%combine(ip,0) ; run ;
%combine(op,0) ; run ;
%combine(hosp,0) ; run ;
%combine(hha,1) ; run ;
%combine(snf,1) ; run ;


data lines(keep = desy_sort_key screen_year claim_no thru_dt hcpcs_cd icd_dgns:) ;
	set out.pb_linej_hist out.pb_line 
		out.dme_linej_hist out.dme_line ;
	icd_dgns_cd1 = LINE_ICD_DGNS_CD ;
	ICD_DGNS_VRSN_CD1 = LINE_ICD_DGNS_VRSN_CD ;
	screen_year = year(thru_dt) ;
proc sort data=lines ; by desy_sort_key screen_year ;
data lines_final ;
	merge out.person16(in=a keep= hicno desy_sort_key ep_id screen_year)
		  lines(in=b) ; by desy_sort_key screen_year ;
	if a and b ;  


data all_claims(keep = hicno ICD_DGNS_:) ;
	set ip_final op_final hosp_final hha_final snf_final lines_final ;	
	drop icd_dgns_E: ;

	if substr(rev_cntr,2,3) IN ('000','   ') AND hcpcs_cd = ' ' then delete;

	if year(thru_dt) le 2014 then do ;
		if PUT(rev_cntr, $Valid_Rev_Code_14_.) IN ('Y') or PUT(hcpcs_cd, $Valid_Proc_Code_14_.) IN ('Y') ;
		if PUT(rev_cntr, $rev_noHCC_14_.) IN ('N') then delete;
		if PUT(hcpcs_cd, $proc_noHCC_14_.)  IN ('N') then delete;
	end ;

	else if year(thru_dt) = 2015 then do ;
		if PUT(rev_cntr, $Valid_Rev_Code_15_.) IN ('Y') or PUT(hcpcs_cd, $Valid_Proc_Code_15_.) IN ('Y');
		if PUT(rev_cntr,  $rev_noHCC_15_.) IN ('N') then delete;
		if PUT(hcpcs_cd, $proc_noHCC_15_.)  IN ('N') then delete;
	end ;

	else if year(thru_dt) = 2016 then do ;
		if PUT(rev_cntr, $Valid_Rev_Code_16_.) IN ('Y') or PUT(hcpcs_cd, $Valid_Proc_Code_16_.) IN ('Y');
		if PUT(rev_cntr,  $rev_noHCC_16_.) IN ('N') then delete;
		if PUT(hcpcs_cd, $proc_noHCC_16_.)  IN ('N') then delete;
	end ;
/*
	else if year(thru_dt) = 2017 then do ;
		if PUT(rev_cntr, $Valid_Rev_Code17.) IN ('Y') or PUT(hcpcs_cd, $Valid_Proc_Code17.) IN ('Y');
		else if PUT(rev_cntr,  $rev_noHCC17.) IN ('N') then delete;
		else if PUT(hcpcs_cd, $proc_noHCC17.)  IN ('N') then delete;
	end ;
*/
run;


%MACRO DIAG(i);

proc sql;
	create table diag_&i. as
	select hicno, icd_dgns_cd&i. as diag, ICD_DGNS_VRSN_CD&i. as diag_type 
	from all_claims
	where icd_dgns_cd&i. ne "  " ;
quit;

%MEND;

%DIAG(1);
%DIAG(2);
%DIAG(3);
%DIAG(4);
%DIAG(5);
%DIAG(6);
%DIAG(7);
%DIAG(8);
%DIAG(9);
%DIAG(10);
%DIAG(11);
%DIAG(12);
%DIAG(13);
%DIAG(14);
%DIAG(15);
%DIAG(16);
%DIAG(17);
%DIAG(18);
%DIAG(19);
%DIAG(20);
%DIAG(21);
%DIAG(22);
%DIAG(23);
%DIAG(24);
%DIAG(25);

data claims3;
	format diag $5. diag_type $1. ;
	set diag_1-diag_25;
run;

proc sort nodupkey data=claims3 out=out.Diag16;
	by HICNO diag_type diag;
run;


