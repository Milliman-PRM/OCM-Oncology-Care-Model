********************************************************************** ;
        ***** R003p_Service_Categories.sas ***** ;
********************************************************************** ;

libname IN "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP1" ;
libname REC "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP1" ;
libname ref "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\90 - Investigations\HCPCS_BETOS";
libname outfinal "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Performance\March" ;
options ls=132 ps=70 obs=MAX mprint mlogic; run ;

********************************************************************** ;
********************************************************************** ;
********************************************************************** ;
%let vers = R0 ; *** R = Reconciliation, 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let it = 0 ;  *** 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let bl = p1&vers. ; *** performance period 1, bene file received *** ;
%let sd = mdy(7,1,2016) ; *** Start of reconciled period ;
%let potential = mdy(1,1,2017) ;  *** date of latest episode begin date included in reconciled period. *** ;
run ;



%macro sc(ds,id) ;

%IF "DS." = "290_50202" %THEN %DO ;
DATA REC ;
	SET REC.RECON&it._Interface_&bl._&ds.
		REC.RECON&it._Interface_&bl._567_50200
		REC.RECON&it._Interface_&bl._568_50201 ;
%END ;

%ELSE %DO ;
DATA REC ; SET REC.RECON&it._Interface_&bl._&ds. ;
%END ;

PROC SORT DATA=REC ; BY BENE_ID EP_ID   ;

PROC SORT DATA= OUTFINAL.EPISODE_INTERFACE_P3B_&DS. OUT=INT ; BY BENE_ID EP_ID   ;

DATA INBOTH INREC_ONLY ;
	MERGE REC(IN=A KEEP = BENE_ID EP_ID)
		  INT(IN=B KEEP = BENE_ID EP_ID) ; BY BENE_ID EP_ID ;
	IF A AND B THEN OUTPUT INBOTH ;
	ELSE IF A AND B=0 THEN OUTPUT INREC_ONLY ;
RUN ;

data check1 check2 ;
	set int ;
	if sex = "  " then output check1 ;
	if bene_hicn = "  " then output check2 ;

%mend sc ;

**************************************************************************** ;
**************************************************************************** ;
***** %macro sc(ds,id)
        ID: 3 digit OCM id
**************************************************************************** ;
**************************************************************************** ;

*%SC(137_50136,137) ; run ;

*%SC(523_50330,523) ; run ;

*%SC(255_50179,255) ; run ;

*%SC(257_50195,257) ; run ;

*%SC(278_50193,278) ; run ;

*%SC(280_50115,280) ; run ;

*%SC(290_50202,290) ; run ;

*%SC(396_50258,396) ; run ;

*%SC(401_50228,401) ; run ;

*%SC(468_50227,468) ; run ;

*%SC(480_50185,480) ; run ;

%SC(459_50243,459) ; run ;

RUN ;

****************************************************************** ;
	************* Investigations ********************* ;
****************************************************************** ;

****************************************************************** ;
*** Mismatch on Novel Therapy Totals *** ;
/*
proc print data=REC.ALL_CLAIMS_&bl._257_50195 ;
	where ep_id = 437628 and Novel_therapy = "YES" ; 
	var bene_id ep_id novel_therapy CLM_REV_STD_PYMT_AMT std_pay hcpcs_cd IDENDC LNNDCCD PROD_SRVC_ID ;
	sum CLM_REV_STD_PYMT_AMT std_pay ;
run ; 

proc print data=REC.RECON&it._Interface_&bl._257_50195 ;
	where ep_id = "437628-161201-P-257" ;
run ;

proc print data=REC.OUTPATIENT_&bl._257_50195 ;
	where ep_id = 437628 and hcpcs_cd = "J9047" ;
	var bene_id ep_id clm_id from_dt thru_dt hcpcs_cd CLM_REV_STD_PYMT_AMT  ;
	sum CLM_REV_STD_PYMT_AMT ;
run ;

proc print data=outpatient;
	where ep_id = 437628 and hcpcs_cd in ('J9999','J8999');
	var bene_id ep_id clm_id from_dt thru_dt hcpcs_cd CLM_REV_STD_PYMT_AMT  ;
	sum CLM_REV_STD_PYMT_AMT ;
run ;

proc print data=REC.SC_pde_&bl._257_50195 ;
	where ep_id = 437628 ;
run ;

 
****************************************************************** ;
*** Mismatch on ED and OBS STAY Totals *** ;

proc sort data=REC.ALL_CLAIMS_&bl._523_50330  out=all_clms ; by ep_id clm_id clm_ln ;
proc print data=all_clms ; by ep_id clm_id ;
	where ep_id = 356025 and sum(er_pre,obs_pre ) > 0 ;
	var bene_id ep_id ep_beg ep_end clm_id rev_dt REV_CNTR_TOT_CHRG_AMT REV_CNTR_NCVRD_CHRG_AMT std_pay 
		REV_CNTR  hcpcs_cd REV_UNIT  er_pre obs_pre  SERVICE_CAT;
	sum std_pay ;
run ;


****************************************************************** ;
*** Mismatch on Totals *** ;
proc sort data=REC.ALL_CLAIMS_&bl._523_50330  out=all_clms ; by ep_id service_category;

PROC PRINT DATA=REC.RECON&it._Interface_&bl._523_50330  (OBS=20) ; RUN ;

proc print data=REC.check_ipop_&bl._257_50195 ;

where ep_id =  555522 ;
run ;

****************************************************************** ;
*** Mismatch on OCM QUALITY *** ;
proc print data=REC.SC_ip_&bl._257_50195 ;
	where ep_id =  555522 and clm_id = '4948697927';
run ;	 

proc print data=REC.RECON&it._Interface_&bl._257_50195 ;
	where ep_id_cms = 555522 ;
	var bene_id ep_id ep_beg ep_end cancer_type surgery surgery_milliman num_ocm1 num_ocm1_milliman ;
run ;
proc print data=REC.outpatient_&bl._257_50195 ;
	where ep_id =  555522 and clm_id = '4948697927';
run ;

PROC PRINT DATA=REC.EPIATT_137_50136_PP1 ;
	var bene_id ep_id ep_beg ep_end cancer_type DOD num_ocm1 num_ocm2 num_ocm3 DEN_OCM3 ;
	WHERE EP_ID = 367085 ; 
RUN ;

PROC freq DATA=REC.EPIATT_137_50136_PP1 ;
	tables num_ocm1 num_ocm2 num_ocm3 den_ocm3 ; run ;

proc print data=REC.RECON&it._Interface_&bl._396_50258 ;
	where ep_id_CMS  = 166859;
	var bene_id ep_id ep_beg ep_end cancer_type DOD num_ocm1 num_ocm2 num_ocm3 DEN_OCM3 BMT
		BMT_MILLIMAN SURGERY SURGERY_MILLIMAN ;
run ;

PROC PRINT DATA=SC_ip_&bl._396_50258 ;
	VAR BENE_ID EP_ID CLM_ID admsn_dt from_dt thru_dt EX1 
		IP_CHEMO_ADMIN  IP_BMT_AK  IP_BMT_L  IP_BMT_MM  IP_BMT_MDS  SIP_BREAST SIP_ANAL SIP_LIVER 
        SIP_LUNG  SIP_BLADDER  SIP_FEMALEGU SIP_GASTRO  SIP_HN  SIP_INT  SIP_OVARIAN  SIP_PROSTATE 
        SIP_PANCREATIC PRNCPAL_DGNS_CD NOPAY_CD PROVIDER;
	WHERE EP_ID = 166859 ; RUN ;

proc print data=REC.RECON&it._Interface_&bl._278_50193 ;
	where ep_id_CMS  = 106562;
	var bene_id ep_id ep_beg ep_end cancer_type DOD num_ocm1 num_ocm2 num_ocm3 DEN_OCM3 BMT BMT_MILLIMAN
		surgery surgery_milliman;
run ;

proc print data=ocm2_chk ;
	where ep_id = 166859; 
	var bene_id ep_id clm_id from_dt thru_dt REV_CNTR hcpcs_cd rev_unit ed_ocm2 obs_ocm2 
	    REV_CNTR_TOT_CHRG_AMT REV_CNTR_NCVRD_CHRG_AMT ;
run ;

proc print data=REC.inpatient_&bl._396_50258;
	where ep_id = 166859 ;
	var bene_id ep_id clm_id from_dt thru_dt admsn_dt ;
run ;


proc print data=o2 ;
	where ep_id = 247707 ; 
run ;


*/
