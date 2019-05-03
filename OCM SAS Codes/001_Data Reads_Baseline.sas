********************************************************************** ;
********************************************************************** ;
********************************************************************** ;

%let indir = R:\data\HIPAA\OCM_Oncology_Care_Model_PP\01 - Baseline Data\V3\201707-201810 ;
%let outdir = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Baseline\V3" ;
libname r2 &outdir. ;

options ls=132 ps=70 obs =max;

********************************************************************** ;
********************************************************************** ;
%let cdate = 20170702 ;  *** date in file names *** ;
%let cdate1	= 20181023; *** second date in file names ***; 
%let cdate2	= 20181102; *** second date in episode file names ***; 
********************************************************************** ;
********************************************************************** ;

%macro reads(dsid,did) ;

********************************************************************** ;
**************** Episode File **************************************** ;
data r2.epi_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._episodes_Base&cdate._&cdate2..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
	BENE_ID					:$15.
	BENE_HICN				:$12.
	FIRST_NAME				:$15.
	LAST_NAME				:$24.
	SEX						:$1.
	DOB						:yymmdd8.
	AGE						:best32.
	DOD						:yymmdd8.
	ZIPCODE					:$5.
	EP_ID					:best32.
	EP_BEG					:yymmdd8.
	EP_END					:yymmdd8.
	EP_LENGTH				:$3.
	CANCER_TYPE				:$100.
	RECON_ELIG				:$1.
	DUAL_PTD_LIS			:$1.
	INST					:$1.
	RADIATION				:$1.
	HCC_GRP					:$3.
	HRR_REL_COST			:12.
	SURGERY					:$1.
	CLINICAL_TRIAL			:$1.
	BMT						:$1.
	CLEAN_PD				:$1.
	PTD_CHEMO				:$1.
	ACTUAL_EXP				:12.
	BASELINE_PRICE			:12.
	EXPERIENCE_ADJ			:12.
	ACTUAL_EXP_UNADJ		:12.
	LOW_RISK_BLAD			:$1.
	CAST_SENS_PROS			:$1.
    ;
    format DOB DOD EP_BEG EP_END mmddyy10. ;

    array dt (i) EP_BEG EP_END ;
    array ym (i) BEG_YYMM END_YYMM ;
    do i = 1 to 2 ;
        ym = year(dt)*100 + month(dt) ;
    end ;
    drop i ;
run ;

proc freq data= r2.epi_&dsid. ;
	tables cancer_type ;
title1 "OCM ID &dsid. : Cancer Types Appearing in Data" ; run ;
/*	
********************************************************************** ;
**************** Substance Abuse and Mental Health File ************** ;

data r2.samh_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._samh_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
	input
	Service					:$3.
	Count					:12.
	DROPPED_EXPDME			:12.

run ;
********************************************************************** ;
**************** Inpatient Header File ******************************* ;

data r2.iphdr_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._inphead_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
	BENE_ID					:$15.
	CLM_ID					:$15.
	CLM_TYPE				:$2.
	FROM_DT					:date8.
	THRU_DT					:date8.
	WKLY_DT					:date8.
	FI_CLM_PROC_DT			:date8.
	PROVIDER				:$6.
	FAC_TYPE				:$1.
	FREQ_CD					:$1.
	NOPAY_CD				:$2.
	PMT_AMT					:12.
	PRPAYAMT				:12.
	PRPAY_CD				:$1.
	PRSTATE					:$2.
	ORGNPINM				:$10.
	AT_NPI					:$10.
	OP_NPI					:$10.
	MCOPDSW					:$1.
	STUS_CD					:$2.
	PPS_IND					:$1.
	TOT_CHRG				:12.
	ADMSN_DT				:date8.
	TYPE_ADM				:$1.
	SRC_ADMS				:$1.
	PER_DIEM				:12.
	DED_AMT					:12.
	COIN_AMT				:12.
	BLDDEDAM				:12.
	PPS_CPTL				:12.
	CPTLOUTL				:12.
	DISP_SHR				:12.
	IME_AMT					:12.
	UTIL_DAY				:3.
	DSCHRGDT				:date8.
	DRG_CD					:$3.
	OUTLR_CD				:$1.
	OUTLRPMT				:12.
	ADMTG_DGNS_CD			:$7.
	PRNCPAL_DGNS_CD			:$7.
	PRNCPAL_DGNS_VRSN_CD	:$1.
	ICD_DGNS_CD1			:$7.
	ICD_DGNS_VRSN_CD1		:$1.
	ICD_DGNS_CD2			:$7.
	ICD_DGNS_VRSN_CD2		:$1.
	ICD_DGNS_CD3			:$7.
	ICD_DGNS_VRSN_CD3		:$1.
	ICD_DGNS_CD4			:$7.
	ICD_DGNS_VRSN_CD4		:$1.
	ICD_DGNS_CD5			:$7.
	ICD_DGNS_VRSN_CD5		:$1.
	ICD_DGNS_CD6			:$7.
	ICD_DGNS_VRSN_CD6		:$1.
	ICD_DGNS_CD7			:$7.
	ICD_DGNS_VRSN_CD7		:$1.
	ICD_DGNS_CD8			:$7.
	ICD_DGNS_VRSN_CD8		:$1.
	ICD_DGNS_CD9			:$7.
	ICD_DGNS_VRSN_CD9		:$1.
	ICD_DGNS_CD10			:$7.
	ICD_DGNS_VRSN_CD10		:$1.
	ICD_DGNS_CD11			:$7.
	ICD_DGNS_VRSN_CD11		:$1.
	ICD_DGNS_CD12			:$7.
	ICD_DGNS_VRSN_CD12		:$1.
	ICD_DGNS_CD13			:$7.
	ICD_DGNS_VRSN_CD13		:$1.
	ICD_DGNS_CD14			:$7.
	ICD_DGNS_VRSN_CD14		:$1.
	ICD_DGNS_CD15			:$7.
	ICD_DGNS_VRSN_CD15		:$1.
	ICD_DGNS_CD16			:$7.
	ICD_DGNS_VRSN_CD16		:$1.
	ICD_DGNS_CD17			:$7.
	ICD_DGNS_VRSN_CD17		:$1.
	ICD_DGNS_CD18			:$7.
	ICD_DGNS_VRSN_CD18		:$1.
	ICD_DGNS_CD19			:$7.
	ICD_DGNS_VRSN_CD19		:$1.
	ICD_DGNS_CD20			:$7.
	ICD_DGNS_VRSN_CD20		:$1.
	ICD_DGNS_CD21			:$7.
	ICD_DGNS_VRSN_CD21		:$1.
	ICD_DGNS_CD22			:$7.
	ICD_DGNS_VRSN_CD22		:$1.
	ICD_DGNS_CD23			:$7.
	ICD_DGNS_VRSN_CD23		:$1.
	ICD_DGNS_CD24			:$7.
	ICD_DGNS_VRSN_CD24		:$1.
	ICD_DGNS_CD25			:$7.
	ICD_DGNS_VRSN_CD25		:$1.
	ICD_PRCDR_CD1			:$7.
	ICD_PRCDR_VRSN_CD1		:$1.
	PRCDR_DT1				:date8.
	ICD_PRCDR_CD2			:$7.
	ICD_PRCDR_VRSN_CD2		:$1.
	PRCDR_DT2				:date8.
	ICD_PRCDR_CD3			:$7.
	ICD_PRCDR_VRSN_CD3		:$1.
	PRCDR_DT3				:date8.
	ICD_PRCDR_CD4			:$7.
	ICD_PRCDR_VRSN_CD4		:$1.
	PRCDR_DT4				:date8.
	ICD_PRCDR_CD5			:$7.
	ICD_PRCDR_VRSN_CD5		:$1.
	PRCDR_DT5				:date8.
	ICD_PRCDR_CD6			:$7.
	ICD_PRCDR_VRSN_CD6		:$1.
	PRCDR_DT6				:date8.
	ICD_PRCDR_CD7			:$7.
	ICD_PRCDR_VRSN_CD7		:$1.
	PRCDR_DT7				:date8.
	ICD_PRCDR_CD8			:$7.
	ICD_PRCDR_VRSN_CD8		:$1.
	PRCDR_DT8				:date8.
	ICD_PRCDR_CD9			:$7.
	ICD_PRCDR_VRSN_CD9		:$1.
	PRCDR_DT9				:date8.
	ICD_PRCDR_CD10			:$7.
	ICD_PRCDR_VRSN_CD10		:$1.
	PRCDR_DT10				:date8.
	ICD_PRCDR_CD11			:$7.
	ICD_PRCDR_VRSN_CD11		:$1.
	PRCDR_DT11				:date8.
	ICD_PRCDR_CD12			:$7.
	ICD_PRCDR_VRSN_CD12		:$1.
	PRCDR_DT12				:date8.
	ICD_PRCDR_CD13			:$7.
	ICD_PRCDR_VRSN_CD13		:$1.
	PRCDR_DT13				:date8.
	ICD_PRCDR_CD14			:$7.
	ICD_PRCDR_VRSN_CD14		:$1.
	PRCDR_DT14				:date8.
	ICD_PRCDR_CD15			:$7.
	ICD_PRCDR_VRSN_CD15		:$1.
	PRCDR_DT15				:date8.
	ICD_PRCDR_CD16			:$7.
	ICD_PRCDR_VRSN_CD16		:$1.
	PRCDR_DT16				:date8.
	ICD_PRCDR_CD17			:$7.
	ICD_PRCDR_VRSN_CD17		:$1.
	PRCDR_DT17				:date8.
	ICD_PRCDR_CD18			:$7.
	ICD_PRCDR_VRSN_CD18		:$1.
	PRCDR_DT18				:date8.
	ICD_PRCDR_CD19			:$7.
	ICD_PRCDR_VRSN_CD19		:$1.
	PRCDR_DT19				:date8.
	ICD_PRCDR_CD20			:$7.
	ICD_PRCDR_VRSN_CD20		:$1.
	PRCDR_DT20				:date8.
	ICD_PRCDR_CD21			:$7.
	ICD_PRCDR_VRSN_CD21		:$1.
	PRCDR_DT21				:date8.
	ICD_PRCDR_CD22			:$7.
	ICD_PRCDR_VRSN_CD22		:$1.
	PRCDR_DT22				:date8.
	ICD_PRCDR_CD23			:$7.
	ICD_PRCDR_VRSN_CD23		:$1.
	PRCDR_DT23				:date8.
	ICD_PRCDR_CD24			:$7.
	ICD_PRCDR_VRSN_CD24		:$1.
	PRCDR_DT24				:date8.
	ICD_PRCDR_CD25			:$7.
	ICD_PRCDR_VRSN_CD25		:$1.
	PRCDR_DT25				:date8.
	IME_OP					:12.
	DSH_OP					:12.
	CLM_MDCL_REC			:$17.
	EP_ID					:12.
	CLM_SRVC_CLSFCTN_TYPE_CD:$1.
	CLM_STD_PYMT_AMT		:12.

    ;

    format FROM_DT THRU_DT WKLY_DT  FI_CLM_PROC_DT ADMSN_DT DSCHRGDT PRCDR_DT: mmddyy10. ;
    array dt (i) From_dt thru_dt admsn_dt dschrgdt ;
    array ym (i) fromyymm thruyymm adm_yymm dis_yymm ;
    do i = 1 to 4 ;
        ym = year(dt)*100 + month(dt) ;
    end ;
    drop i ;

run ;


********************************************************************** ;
********************** SNF Header File ******************************* ;

data r2.snfhdr_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._snfhead_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
	BENE_ID					:$15.
	CLM_ID					:$15.
	CLM_TYPE				:$2.
	FROM_DT					:date8.
	THRU_DT					:date8.
	WKLY_DT					:date8.
	FI_CLM_PROC_DT			:date8.
	PROVIDER				:$6.
	FAC_TYPE				:$1.
	FREQ_CD					:$1.
	NOPAY_CD				:$2.
	PMT_AMT					:12.
	PRPAYAMT				:12.
	PRPAY_CD				:$1.
	PRSTATE					:$2.
	ORGNPINM				:$10.
	AT_NPI					:$10.
	OP_NPI					:$10.
	MCOPDSW					:$1.
	STUS_CD					:$2.
	PPS_IND					:$1.
	TOT_CHRG				:12.
	ADMSN_DT				:date8.
	TYPE_ADM				:$1.
	SRC_ADMS				:$1.
	DED_AMT					:12.
	COIN_AMT				:12.
	BLDDEDAM				:12.
	CPTLOUTL				:12.
	DISP_SHR				:12.
	IME_AMT					:12.
	UTIL_DAY				:3.
	DSCHRGDT				:date8.
	DRG_CD					:$3.
	ADMTG_DGNS_CD			:$7.
	PRNCPAL_DGNS_CD			:$7.
	PRNCPAL_DGNS_VRSN_CD	:$1.
	ICD_DGNS_CD1			:$7.
	ICD_DGNS_VRSN_CD1		:$1.
	ICD_DGNS_CD2			:$7.
	ICD_DGNS_VRSN_CD2		:$1.
	ICD_DGNS_CD3			:$7.
	ICD_DGNS_VRSN_CD3		:$1.
	ICD_DGNS_CD4			:$7.
	ICD_DGNS_VRSN_CD4		:$1.
	ICD_DGNS_CD5			:$7.
	ICD_DGNS_VRSN_CD5		:$1.
	ICD_DGNS_CD6			:$7.
	ICD_DGNS_VRSN_CD6		:$1.
	ICD_DGNS_CD7			:$7.
	ICD_DGNS_VRSN_CD7		:$1.
	ICD_DGNS_CD8			:$7.
	ICD_DGNS_VRSN_CD8		:$1.
	ICD_DGNS_CD9			:$7.
	ICD_DGNS_VRSN_CD9		:$1.
	ICD_DGNS_CD10			:$7.
	ICD_DGNS_VRSN_CD10		:$1.
	ICD_DGNS_CD11			:$7.
	ICD_DGNS_VRSN_CD11		:$1.
	ICD_DGNS_CD12			:$7.
	ICD_DGNS_VRSN_CD12		:$1.
	ICD_DGNS_CD13			:$7.
	ICD_DGNS_VRSN_CD13		:$1.
	ICD_DGNS_CD14			:$7.
	ICD_DGNS_VRSN_CD14		:$1.
	ICD_DGNS_CD15			:$7.
	ICD_DGNS_VRSN_CD15		:$1.
	ICD_DGNS_CD16			:$7.
	ICD_DGNS_VRSN_CD16		:$1.
	ICD_DGNS_CD17			:$7.
	ICD_DGNS_VRSN_CD17		:$1.
	ICD_DGNS_CD18			:$7.
	ICD_DGNS_VRSN_CD18		:$1.
	ICD_DGNS_CD19			:$7.
	ICD_DGNS_VRSN_CD19		:$1.
	ICD_DGNS_CD20			:$7.
	ICD_DGNS_VRSN_CD20		:$1.
	ICD_DGNS_CD21			:$7.
	ICD_DGNS_VRSN_CD21		:$1.
	ICD_DGNS_CD22			:$7.
	ICD_DGNS_VRSN_CD22		:$1.
	ICD_DGNS_CD23			:$7.
	ICD_DGNS_VRSN_CD23		:$1.
	ICD_DGNS_CD24			:$7.
	ICD_DGNS_VRSN_CD24		:$1.
	ICD_DGNS_CD25			:$7.
	ICD_DGNS_VRSN_CD25		:$1.
	ICD_PRCDR_CD1			:$7.
	ICD_PRCDR_VRSN_CD1		:$1.
	PRCDR_DT1				:date8.
	ICD_PRCDR_CD2			:$7.
	ICD_PRCDR_VRSN_CD2		:$1.
	PRCDR_DT2				:date8.
	ICD_PRCDR_CD3			:$7.
	ICD_PRCDR_VRSN_CD3		:$1.
	PRCDR_DT3				:date8.
	ICD_PRCDR_CD4			:$7.
	ICD_PRCDR_VRSN_CD4		:$1.
	PRCDR_DT4				:date8.
	ICD_PRCDR_CD5			:$7.
	ICD_PRCDR_VRSN_CD5		:$1.
	PRCDR_DT5				:date8.
	ICD_PRCDR_CD6			:$7.
	ICD_PRCDR_VRSN_CD6		:$1.
	PRCDR_DT6				:date8.
	ICD_PRCDR_CD7			:$7.
	ICD_PRCDR_VRSN_CD7		:$1.
	PRCDR_DT7				:date8.
	ICD_PRCDR_CD8			:$7.
	ICD_PRCDR_VRSN_CD8		:$1.
	PRCDR_DT8				:date8.
	ICD_PRCDR_CD9			:$7.
	ICD_PRCDR_VRSN_CD9		:$1.
	PRCDR_DT9				:date8.
	ICD_PRCDR_CD10			:$7.
	ICD_PRCDR_VRSN_CD10		:$1.
	PRCDR_DT10				:date8.
	ICD_PRCDR_CD11			:$7.
	ICD_PRCDR_VRSN_CD11		:$1.
	PRCDR_DT11				:date8.
	ICD_PRCDR_CD12			:$7.
	ICD_PRCDR_VRSN_CD12		:$1.
	PRCDR_DT12				:date8.
	ICD_PRCDR_CD13			:$7.
	ICD_PRCDR_VRSN_CD13		:$1.
	PRCDR_DT13				:date8.
	ICD_PRCDR_CD14			:$7.
	ICD_PRCDR_VRSN_CD14		:$1.
	PRCDR_DT14				:date8.
	ICD_PRCDR_CD15			:$7.
	ICD_PRCDR_VRSN_CD15		:$1.
	PRCDR_DT15				:date8.
	ICD_PRCDR_CD16			:$7.
	ICD_PRCDR_VRSN_CD16		:$1.
	PRCDR_DT16				:date8.
	ICD_PRCDR_CD17			:$7.
	ICD_PRCDR_VRSN_CD17		:$1.
	PRCDR_DT17				:date8.
	ICD_PRCDR_CD18			:$7.
	ICD_PRCDR_VRSN_CD18		:$1.
	PRCDR_DT18				:date8.
	ICD_PRCDR_CD19			:$7.
	ICD_PRCDR_VRSN_CD19		:$1.
	PRCDR_DT19				:date8.
	ICD_PRCDR_CD20			:$7.
	ICD_PRCDR_VRSN_CD20		:$1.
	PRCDR_DT20				:date8.
	ICD_PRCDR_CD21			:$7.
	ICD_PRCDR_VRSN_CD21		:$1.
	PRCDR_DT21				:date8.
	ICD_PRCDR_CD22			:$7.
	ICD_PRCDR_VRSN_CD22		:$1.
	PRCDR_DT22				:date8.
	ICD_PRCDR_CD23			:$7.
	ICD_PRCDR_VRSN_CD23		:$1.
	PRCDR_DT23				:date8.
	ICD_PRCDR_CD24			:$7.
	ICD_PRCDR_VRSN_CD24		:$1.
	PRCDR_DT24				:date8.
	ICD_PRCDR_CD25			:$7.
	ICD_PRCDR_VRSN_CD25		:$1.
	PRCDR_DT25				:date8.
	CLM_MDCL_REC			:$17.
	EP_ID					:12.
	CLM_SRVC_CLSFCTN_TYPE_CD:$1.
	CLM_STD_PYMT_AMT		:12.
    ;

    format FROM_DT THRU_DT WKLY_DT  FI_CLM_PROC_DT ADMSN_DT DSCHRGDT PRCDR_DT: mmddyy10. ;
    array dt (i) From_dt thru_dt admsn_dt dschrgdt ;
    array ym (i) fromyymm thruyymm adm_yymm dis_yymm ;
    do i = 1 to 4 ;
        ym = year(dt)*100 + month(dt) ;
    end ;
    drop i ;

run ;


********************************************************************** ;
%macro snf_inp_rev_val(fn) ;
********************************************************************** ;
******************* Inpatient/SNF Rev File *************************** ;

data r2.&fn.rev_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._&fn.rev_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
	BENE_ID					:$15.
	CLM_ID					:$15.
	THRU_DT					:date8.
	CLM_LN					:13.
	REV_CNTR				:$4.
	HCPCS_CD				:$5.
	REV_UNIT				:8.
	REV_RATE				:12.
	REV_CNTR_NDC_QTY		:10.
	REV_CNTR_NDC_QTY_QLFR_CD:$2.
	EP_ID					:12.
	REV_CNTR_TOT_CHRG_AMT	:12.
	REV_CNTR_NCVRD_CHRG_AMT	:12.

    ;
    format THRU_DT mmddyy10. ;
    thruyymm = year(thru_dt)*100 + month(thru_dt) ;



run ;

********************************************************************** ;
**************** Inpatient/SNF Val File ****************************** ;

data r2.&fn.val_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._&fn.val_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
	BENE_ID				:$15.
	CLM_ID				:$15.
	VAL_CD				:$2.
	VAL_AMT				:12.
	EP_ID				:12.
    ;

run ;

********************************************************************** ;
%mend snf_inp_rev_val ;
********************************************************************** ;

%snf_inp_rev_val(inp) ;
%snf_inp_rev_val(snf) ;

********************************************************************** ;
****************** Hospice Header File ******************************* ;

data r2.hsphdr_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._hsphead_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
	BENE_ID					:$15.
	CLM_ID					:$15.
	CLM_TYPE				:$2.
	FROM_DT					:date8.
	THRU_DT					:date8.
	WKLY_DT					:date8.
	FI_CLM_PROC_DT			:date8.
	PROVIDER				:$6.
	FAC_TYPE				:$1.
	NOPAY_CD				:$2.
	PMT_AMT					:12.
	PRPAYAMT				:12.
	PRPAY_CD				:$1.
	ORGNPINM				:$10.
	AT_NPI					:$10.
	STUS_CD					:$2.
	PRNCPAL_DGNS_CD			:$7.
	PRNCPAL_DGNS_VRSN_CD	:$1.
	HSPCSTRT				:date8.
	HOSPCPRD				:1.
	CLM_MDCL_REC			:$17.
	EP_ID					:12.
	NCH_BENE_DSCHRG_DT		:date8.
	CLM_SRVC_CLSFCTN_TYPE_CD:$3.
	CLM_FREQ_CD				:$1.
	ICD_DGNS_CD1			:$7.
	ICD_DGNS_VRSN_CD1		:$1.
	ICD_DGNS_CD2			:$7.
	ICD_DGNS_VRSN_CD2		:$1.
	ICD_DGNS_CD3			:$7.
	ICD_DGNS_VRSN_CD3		:$1.
	ICD_DGNS_CD4			:$7.
	ICD_DGNS_VRSN_CD4		:$1.
	ICD_DGNS_CD5			:$7.
	ICD_DGNS_VRSN_CD5		:$1.
	ICD_DGNS_CD6			:$7.
	ICD_DGNS_VRSN_CD6		:$1.
	ICD_DGNS_CD7			:$7.
	ICD_DGNS_VRSN_CD7		:$1.
	ICD_DGNS_CD8			:$7.
	ICD_DGNS_VRSN_CD8		:$1.
	ICD_DGNS_CD9			:$7.
	ICD_DGNS_VRSN_CD9		:$1.
	ICD_DGNS_CD10			:$7.
	ICD_DGNS_VRSN_CD10		:$1.
	ICD_DGNS_CD11			:$7.
	ICD_DGNS_VRSN_CD11		:$1.
	ICD_DGNS_CD12			:$7.
	ICD_DGNS_VRSN_CD12		:$1.
	ICD_DGNS_CD13			:$7.
	ICD_DGNS_VRSN_CD13		:$1.
	ICD_DGNS_CD14			:$7.
	ICD_DGNS_VRSN_CD14		:$1.
	ICD_DGNS_CD15			:$7.
	ICD_DGNS_VRSN_CD15		:$1.
	ICD_DGNS_CD16			:$7.
	ICD_DGNS_VRSN_CD16		:$1.
	ICD_DGNS_CD17			:$7.
	ICD_DGNS_VRSN_CD17		:$1.
	ICD_DGNS_CD18			:$7.
	ICD_DGNS_VRSN_CD18		:$1.
	ICD_DGNS_CD19			:$7.
	ICD_DGNS_VRSN_CD19		:$1.
	ICD_DGNS_CD20			:$7.
	ICD_DGNS_VRSN_CD20		:$1.
	ICD_DGNS_CD21			:$7.
	ICD_DGNS_VRSN_CD21		:$1.
	ICD_DGNS_CD22			:$7.
	ICD_DGNS_VRSN_CD22		:$1.
	ICD_DGNS_CD23			:$7.
	ICD_DGNS_VRSN_CD23		:$1.
	ICD_DGNS_CD24			:$7.
	ICD_DGNS_VRSN_CD24		:$1.
	ICD_DGNS_CD25			:$7.
	ICD_DGNS_VRSN_CD25		:$1.
	CLM_STD_PYMT_AMT		:12.

    ;

    format FROM_DT THRU_DT WKLY_DT  FI_CLM_PROC_DT HSPCSTRT mmddyy10. ;
    array dt (i) From_dt thru_dt HSPCSTRT ;
    array ym (i) fromyymm thruyymm hstrtyymm ;
    do i = 1 to 3 ;
        ym = year(dt)*100 + month(dt) ;
    end ;
    drop i ;

run ;

********************************************************************** ;
********************* Hospice Rev File ******************************* ;

data r2.hsprev_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._hsprev_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
	BENE_ID					:$15.
	CLM_ID					:$15.
	THRU_DT					:date8.
	CLM_LN					:13.
	REV_CNTR				:$4.
	REV_DT					:date8.
	HCPCS_CD				:$5.
	MDFR_CD1				:$5.
	MDFR_CD2				:$5.
	REVPMT					:12.
	REV_CNTR_NDC_QTY		:10.
	REV_CNTR_NDC_QTY_QLFR_CD:$2.
	EP_ID					:12.
	REV_CNTR_TOT_CHRG_AMT	:12.
	REV_CNTR_NCVRD_CHRG_AMT	:12.

    ;
    format THRU_DT REV_DT mmddyy10. ;
    thruyymm = year(thru_dt)*100 + month(thru_dt) ;
    revyymm = year(rev_dt)*100 + month(rev_dt) ;

run ;
********************************************************************** ;
********************** HHA Header File ******************************* ;

data r2.hhahdr_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._hhahead_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
	BENE_ID					:$15.
	CLM_ID					:$15.
	CLM_TYPE				:$2.
	FROM_DT					:date8.
	THRU_DT					:date8.
	WKLY_DT					:date8.
	FI_CLM_PROC_DT			:date8.
	PROVIDER				:$6.
	FAC_TYPE				:$1.
	NOPAY_CD				:$2.
	PMT_AMT					:12.
	PRPAYAMT				:12.
	PRPAY_CD				:$1.
	ORGNPINM				:$10.
	AT_NPI					:$10.
	STUS_CD					:$2.
	TOT_CHRG				:12.
	PRNCPAL_DGNS_CD			:$7.
	PRNCPAL_DGNS_VRSN_CD	:$1.
	VISITCNT				:3.
	HHSTRTDT				:date8.
	CLM_MDCL_REC			:$17.
	EP_ID					:12.
	CLM_SRVC_CLSFCTN_TYPE_CD:$1.
	CLM_FREQ_CD				:$1.
	ICD_DGNS_CD1			:$7.
	ICD_DGNS_VRSN_CD1		:$1.
	ICD_DGNS_CD2			:$7.
	ICD_DGNS_VRSN_CD2		:$1.
	ICD_DGNS_CD3			:$7.
	ICD_DGNS_VRSN_CD3		:$1.
	ICD_DGNS_CD4			:$7.
	ICD_DGNS_VRSN_CD4		:$1.
	ICD_DGNS_CD5			:$7.
	ICD_DGNS_VRSN_CD5		:$1.
	ICD_DGNS_CD6			:$7.
	ICD_DGNS_VRSN_CD6		:$1.
	ICD_DGNS_CD7			:$7.
	ICD_DGNS_VRSN_CD7		:$1.
	ICD_DGNS_CD8			:$7.
	ICD_DGNS_VRSN_CD8		:$1.
	ICD_DGNS_CD9			:$7.
	ICD_DGNS_VRSN_CD9		:$1.
	ICD_DGNS_CD10			:$7.
	ICD_DGNS_VRSN_CD10		:$1.
	ICD_DGNS_CD11			:$7.
	ICD_DGNS_VRSN_CD11		:$1.
	ICD_DGNS_CD12			:$7.
	ICD_DGNS_VRSN_CD12		:$1.
	ICD_DGNS_CD13			:$7.
	ICD_DGNS_VRSN_CD13		:$1.
	ICD_DGNS_CD14			:$7.
	ICD_DGNS_VRSN_CD14		:$1.
	ICD_DGNS_CD15			:$7.
	ICD_DGNS_VRSN_CD15		:$1.
	ICD_DGNS_CD16			:$7.
	ICD_DGNS_VRSN_CD16		:$1.
	ICD_DGNS_CD17			:$7.
	ICD_DGNS_VRSN_CD17		:$1.
	ICD_DGNS_CD18			:$7.
	ICD_DGNS_VRSN_CD18		:$1.
	ICD_DGNS_CD19			:$7.
	ICD_DGNS_VRSN_CD19		:$1.
	ICD_DGNS_CD20			:$7.
	ICD_DGNS_VRSN_CD20		:$1.
	ICD_DGNS_CD21			:$7.
	ICD_DGNS_VRSN_CD21		:$1.
	ICD_DGNS_CD22			:$7.
	ICD_DGNS_VRSN_CD22		:$1.
	ICD_DGNS_CD23			:$7.
	ICD_DGNS_VRSN_CD23		:$1.
	ICD_DGNS_CD24			:$7.
	ICD_DGNS_VRSN_CD24		:$1.
	ICD_DGNS_CD25			:$7.
	ICD_DGNS_VRSN_CD25		:$1.
	CLM_STD_PYMT_AMT		:12.
    ;

    format FROM_DT THRU_DT WKLY_DT  FI_CLM_PROC_DT HHSTRTDT mmddyy10. ;
    array dt (i) From_dt thru_dt HHSTRTDT ;
    array ym (i) fromyymm thruyymm hstrtyymm ;
    do i = 1 to 3 ;
        ym = year(dt)*100 + month(dt) ;
    end ;
    drop i ;

run ;

********************************************************************** ;
************************* HHA Rev File ******************************* ;

data r2.hharev_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._hharev_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;

	input
	BENE_ID					:$15.
	CLM_ID					:$15.
	THRU_DT					:date8.
	CLM_LN					:13.
	REV_CNTR				:$4.
	REV_DT					:date8.
	APCHIPPS				:$5.
	HCPCS_CD				:$5.
	MDFR_CD1				:$5.
	MDFR_CD2				:$5.
	PMTMTHD					:$2.
	REV_UNIT				:8.
	REVPMT					:12.
	REV_CHRG				:12.
	REV_CNTR_NDC_QTY		:10.
	REV_CNTR_NDC_QTY_QLFR_CD:$2.
	EP_ID					:12.
	REV_CNTR_NCVRD_CHRG_AMT	:12.
    ;
    format THRU_DT REV_DT mmddyy10. ;
    thruyymm = year(thru_dt)*100 + month(thru_dt) ;
    revyymm = year(rev_dt)*100 + month(rev_dt) ;

run ;

********************************************************************** ;
**********************  OP Header File ******************************* ;

data r2.outhdr_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._outhead_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;

    input
	BENE_ID					:$15.	
	CLM_ID					:$15.	
	CLM_TYPE				:$2.	
	FROM_DT					:date8.	
	THRU_DT					:date8.	
	WKLY_DT					:date8.	
	FI_CLM_PROC_DT			:date8.	
	PROVIDER				:$6.	
	FAC_TYPE				:$1.	
	NOPAY_CD				:$2.	
	PMT_AMT					:12.	
	PRPAYAMT				:12.	
	PRPAY_CD				:$1.	
	ORGNPINM				:$10.	
	AT_NPI					:$10.	
	OP_NPI					:$10.	
	MCOPDSW					:$1.	
	STUS_CD					:$2.	
	PRNCPAL_DGNS_CD			:$7.	
	PRNCPAL_DGNS_VRSN_CD	:$1.	
	ICD_DGNS_CD1			:$7.	
	ICD_DGNS_VRSN_CD1		:$1.		
	ICD_DGNS_CD2			:$7.	
	ICD_DGNS_VRSN_CD2		:$1.		
	ICD_DGNS_CD3			:$7.	
	ICD_DGNS_VRSN_CD3		:$1.		
	ICD_DGNS_CD4			:$7.	
	ICD_DGNS_VRSN_CD4		:$1.		
	ICD_DGNS_CD5			:$7.	
	ICD_DGNS_VRSN_CD5		:$1.		
	ICD_DGNS_CD6			:$7.	
	ICD_DGNS_VRSN_CD6		:$1.		
	ICD_DGNS_CD7			:$7.	
	ICD_DGNS_VRSN_CD7		:$1.		
	ICD_DGNS_CD8			:$7.	
	ICD_DGNS_VRSN_CD8		:$1.		
	ICD_DGNS_CD9			:$7.	
	ICD_DGNS_VRSN_CD9		:$1.		
	ICD_DGNS_CD10			:$7.	
	ICD_DGNS_VRSN_CD10		:$1.		
	ICD_DGNS_CD11			:$7.	
	ICD_DGNS_VRSN_CD11		:$1.		
	ICD_DGNS_CD12			:$7.	
	ICD_DGNS_VRSN_CD12		:$1.		
	ICD_DGNS_CD13			:$7.	
	ICD_DGNS_VRSN_CD13		:$1.		
	ICD_DGNS_CD14			:$7.	
	ICD_DGNS_VRSN_CD14		:$1.		
	ICD_DGNS_CD15			:$7.	
	ICD_DGNS_VRSN_CD15		:$1.		
	ICD_DGNS_CD16			:$7.	
	ICD_DGNS_VRSN_CD16		:$1.		
	ICD_DGNS_CD17			:$7.	
	ICD_DGNS_VRSN_CD17		:$1.		
	ICD_DGNS_CD18			:$7.	
	ICD_DGNS_VRSN_CD18		:$1.		
	ICD_DGNS_CD19			:$7.	
	ICD_DGNS_VRSN_CD19		:$1.		
	ICD_DGNS_CD20			:$7.	
	ICD_DGNS_VRSN_CD20		:$1.		
	ICD_DGNS_CD21			:$7.	
	ICD_DGNS_VRSN_CD21		:$1.		
	ICD_DGNS_CD22			:$7.	
	ICD_DGNS_VRSN_CD22		:$1.		
	ICD_DGNS_CD23			:$7.	
	ICD_DGNS_VRSN_CD23		:$1.		
	ICD_DGNS_CD24			:$7.	
	ICD_DGNS_VRSN_CD24		:$1.		
	ICD_DGNS_CD25			:$7.	
	ICD_DGNS_VRSN_CD25		:$1.		
	ICD_PRCDR_CD1			:$7.	
	ICD_PRCDR_VRSN_CD1		:$1.		
	PRCDR_DT1				:date8.
	ICD_PRCDR_CD2			:$7.	
	ICD_PRCDR_VRSN_CD2		:$1.		
	PRCDR_DT2				:date8.
	ICD_PRCDR_CD3			:$7.	
	ICD_PRCDR_VRSN_CD3		:$1.		
	PRCDR_DT3				:date8.
	ICD_PRCDR_CD4			:$7.	
	ICD_PRCDR_VRSN_CD4		:$1.		
	PRCDR_DT4				:date8.
	ICD_PRCDR_CD5			:$7.	
	ICD_PRCDR_VRSN_CD5		:$1.		
	PRCDR_DT5				:date8.
	ICD_PRCDR_CD6			:$7.	
	ICD_PRCDR_VRSN_CD6		:$1.		
	PRCDR_DT6				:date8.
	ICD_PRCDR_CD7			:$7.	
	ICD_PRCDR_VRSN_CD7		:$1.		
	PRCDR_DT7				:date8.
	ICD_PRCDR_CD8			:$7.	
	ICD_PRCDR_VRSN_CD8		:$1.		
	PRCDR_DT8				:date8.
	ICD_PRCDR_CD9			:$7.	
	ICD_PRCDR_VRSN_CD9		:$1.		
	PRCDR_DT9				:date8.
	ICD_PRCDR_CD10			:$7.	
	ICD_PRCDR_VRSN_CD10		:$1.		
	PRCDR_DT10				:date8.
	ICD_PRCDR_CD11			:$7.	
	ICD_PRCDR_VRSN_CD11		:$1.		
	PRCDR_DT11				:date8.
	ICD_PRCDR_CD12			:$7.	
	ICD_PRCDR_VRSN_CD12		:$1.		
	PRCDR_DT12				:date8.
	ICD_PRCDR_CD13			:$7.	
	ICD_PRCDR_VRSN_CD13		:$1.		
	PRCDR_DT13				:date8.
	ICD_PRCDR_CD14			:$7.	
	ICD_PRCDR_VRSN_CD14		:$1.		
	PRCDR_DT14				:date8.
	ICD_PRCDR_CD15			:$7.	
	ICD_PRCDR_VRSN_CD15		:$1.		
	PRCDR_DT15				:date8.
	ICD_PRCDR_CD16			:$7.	
	ICD_PRCDR_VRSN_CD16		:$1.		
	PRCDR_DT16				:date8.
	ICD_PRCDR_CD17			:$7.	
	ICD_PRCDR_VRSN_CD17		:$1.		
	PRCDR_DT17				:date8.
	ICD_PRCDR_CD18			:$7.	
	ICD_PRCDR_VRSN_CD18		:$1.		
	PRCDR_DT18				:date8.
	ICD_PRCDR_CD19			:$7.	
	ICD_PRCDR_VRSN_CD19		:$1.		
	PRCDR_DT19				:date8.
	ICD_PRCDR_CD20			:$7.	
	ICD_PRCDR_VRSN_CD20		:$1.		
	PRCDR_DT20				:date8.
	ICD_PRCDR_CD21			:$7.	
	ICD_PRCDR_VRSN_CD21		:$1.		
	PRCDR_DT21				:date8.
	ICD_PRCDR_CD22			:$7.	
	ICD_PRCDR_VRSN_CD22		:$1.		
	PRCDR_DT22				:date8.
	ICD_PRCDR_CD23			:$7.	
	ICD_PRCDR_VRSN_CD23		:$1.		
	PRCDR_DT23				:date8.
	ICD_PRCDR_CD24			:$7.	
	ICD_PRCDR_VRSN_CD24		:$1.		
	PRCDR_DT24				:date8.
	ICD_PRCDR_CD25			:$7.	
	ICD_PRCDR_VRSN_CD25		:$1.		
	PRCDR_DT25				:date8.
	CLM_MDCL_REC			:$17.	
	EP_ID					:12.
	CLM_SRVC_CLSFCTN_TYPE_CD:$1
	CLM_FREQ_CD				:$1
    ;

    format FROM_DT THRU_DT WKLY_DT  FI_CLM_PROC_DT PRCDR_DT: mmddyy10. ;
    array dt (i) From_dt thru_dt  ;
    array ym (i) fromyymm thruyymm ;
    do i = 1 to 2 ;
        ym = year(dt)*100 + month(dt) ;
    end ;
    drop i ;
run ;


********************************************************************** ;
************************** OP Rev File ******************************* ;

data r2.outrev_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._outrev_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;

	input
	BENE_ID					:$15.
	CLM_ID					:$15.
	THRU_DT					:date8.
	CLM_LN					:13.
	REV_CNTR				:$4.
	REV_DT					:date8.
	APCHIPPS				:$5.
	HCPCS_CD				:$5.
	MDFR_CD1				:$5.
	MDFR_CD2				:$5.
	PMTMTHD					:$2.
	IDENDC					:$24.
	REV_UNIT				:8.
	PTNTRESP				:12.
	REVPMT					:12.
	REV_CNTR_NDC_QTY		:10.
	REV_CNTR_NDC_QTY_QLFR_CD:$2.
	EP_ID					:12.
	REV_CNTR_TOT_CHRG_AMT	:12.
	REV_CNTR_NCVRD_CHRG_AMT	:12.
	clm_rev_std_pymt_amt	:12.

    ;
    format THRU_DT REV_DT mmddyy10. ;
    thruyymm = year(thru_dt)*100 + month(thru_dt) ;
    revyymm = year(rev_dt)*100 + month(rev_dt) ;
run ;


********************************************************************** ;
************************** OP Val File ******************************* ;

data r2.outval_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._outval_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;

	input
	BENE_ID					:$15.
	CLM_ID					:$15.
	VAL_CD					:$2.
	VAL_AMT					:12.
	EP_ID					:12.
	CLM_STD_OUTLIER_PYMT_AMT:12.
	;

run ;

********************************************************************** ;
%macro phys_dme_header(pb) ;
********************************************************************** ;
********************* PHYS/DME Header File ******************************* ;

data r2.&pb.hdr_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._&pb.head_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
	BENE_ID					:$15.
	CLM_ID					:$15.
	FROM_DT					:date8.
	THRU_DT					:date8.
	WKLY_DT					:date8.
	CARR_NUM				:$5.
	PMTDNLCD				:$2.
	PMT_AMT					:12.
	PRPAYAMT				:12.
	ASGMNTCD				:$1.
	ALOWCHRG				:12.
	PRNCPAL_DGNS_CD			:$7.
	PRNCPAL_DGNS_VRSN_CD	:$1.
	CCLTRNUM				:$8.
	CNTY_CD					:$3.
	STATE_CD				:$2.
	ZIP_CD					:$9.
	EP_ID					:12.
	ICD_DGNS_CD1			:$7.
	ICD_DGNS_VRSN_CD1		:$1.
	ICD_DGNS_CD2			:$7.
	ICD_DGNS_VRSN_CD2		:$1.
	ICD_DGNS_CD3			:$7.
	ICD_DGNS_VRSN_CD3		:$1.
	ICD_DGNS_CD4			:$7.
	ICD_DGNS_VRSN_CD4		:$1.
	ICD_DGNS_CD5			:$7.
	ICD_DGNS_VRSN_CD5		:$1.
	ICD_DGNS_CD6			:$7.
	ICD_DGNS_VRSN_CD6		:$1.
	ICD_DGNS_CD7			:$7.
	ICD_DGNS_VRSN_CD7		:$1.
	ICD_DGNS_CD8			:$7.
	ICD_DGNS_VRSN_CD8		:$1.
	ICD_DGNS_CD9			:$7.
	ICD_DGNS_VRSN_CD9		:$1.
	ICD_DGNS_CD10			:$7.
	ICD_DGNS_VRSN_CD10		:$1.
	ICD_DGNS_CD11			:$7.
	ICD_DGNS_VRSN_CD11		:$1.
	ICD_DGNS_CD12			:$7.
	ICD_DGNS_VRSN_CD		:$1.
;

    format FROM_DT THRU_DT WKLY_DT   mmddyy10. ;
    array dt (i) From_dt thru_dt  ;
    array ym (i) fromyymm thruyymm  ;
    do i = 1 to 2 ;
        ym = year(dt)*100 + month(dt) ;
    end ;
    drop i ;

run ;

********************************************************************** ;
%mend phys_dme_header ;
********************************************************************** ;

%phys_dme_header(phy) ; run ;
%phys_dme_header(dme) ; run ;

********************************************************************** ;
*********************** PHYS Line File ******************************* ;

data r2.PHYLINE_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._PHYline_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
	BENE_ID					:$15.
	CLM_ID					:$15.
	LINE_NUM				:13.
	THRU_DT					:date8.
	PRFNPI					:$12.
	TAX_NUM					:$10.
	HCFASPCL				:$3.
	SRVC_CNT				:4.
	TYPSRVCB				:$1.
	PLCSRVC					:$2.
	LCLTY_CD				:$2.
	EXPNSDT1				:date8.
	EXPNSDT2				:date8.
	HCPCS_CD				:$5.
	MDFR_CD1				:$5.
	MDFR_CD2				:$5.
	BETOS					:$3.
	LINEPMT					:12.
	LPRVPMT					:12.
	LALOWCHG				:12.
	PRCNGIND				:$2.
	MTUS_CNT				:5.
	MTUS_IND				:$1.
	LINE_ICD_DGNS_CD		:$7.
	LINE_ICD_DGNS_VRSN_CD	:$1.
	EP_ID					:12.
	CLM_LINE_STD_PYMT_AMT	:12.
    ;

    format THRU_DT expnsdt1 expnsdt2     mmddyy10. ;
    array dt (i) thru_dt  ;
    array ym (i) thruyymm  ;
    do i = 1 to 1 ;
        ym = year(dt)*100 + month(dt) ;
    end ;
    drop i ;

run ;
********************************************************************** ;
************************ DME Line File ******************************* ;

data r2.DMELINE_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._dmeline_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
	BENE_ID					:$15.
	CLM_ID					:$15.
	LINE_NUM				:13.
	THRU_DT					:date8.
	TAX_NUM					:$10.
	HCFASPCL				:$3.
	SRVC_CNT				:4.
	TYPSRVCB				:$1.
	PLCSRVC					:$2.
	EXPNSDT1				:date8.
	EXPNSDT2				:date8.
	HCPCS_CD				:$5.
	MDFR_CD1				:$5.
	MDFR_CD2				:$5.
	BETOS					:$3.
	LINEPMT					:12.
	LALOWCHG				:12.
	PRCNGIND				:$2.
	LINE_ICD_DGNS_CD		:$7.
	LINE_ICD_DGNS_VRSN_CD	:$1.
	SUP_NPI					:$12.
	LNNDCCD					:$11.
	EP_ID					:12.
	CLM_LINE_STD_PYMT_AMT	:12.
;

    format THRU_DT expnsdt1 expnsdt2     mmddyy10. ;
    array dt (i) thru_dt  ;
    array ym (i) thruyymm  ;
    do i = 1 to 1 ;
        ym = year(dt)*100 + month(dt) ;
    end ;
    drop i ;

run ;


********************************************************************** ;
***************************** PDE File ******************************* ;

data r2.PDE_&dsid. ;
    infile "&indir.\OCM_&did.\OCM_&dsid._pde_Base&cdate._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
	PDE_ID					:$15.
	BENE_ID					:$15.
	DRUG_CVRG_STUS_CD		:$1.
	CTSTRPHC_CVRG_CD		:$1.
	PROD_SRVC_ID			:$19.
	PRSCRBR_ID				:$15.
	SRVC_DT					:date8.
	FILL_NUM				:3.
	QTY_DSPNSD_NUM			:12.
	DAYS_SUPLY_NUM			:3.
	GDC_BLW_OOPT_AMT		:10.
	GDC_ABV_OOPT_AMT		:10.
	LICS_AMT				:10.
	TOT_RX_CST_AMT			:10.
	EP_ID					:12.
;
    format srvc_dt   mmddyy10. ;
    servyymm = year(srvc_dt)*100 + month(srvc_dt) ;

run ;
*/

********************************************************************** ;
********************************************************************** ;
%mend reads ; run ;
********************************************************************** ;
********************************************************************** ;
********************************************************************** ;

%reads(137_50136,137) ; run ;
%reads(255_50179,255) ; run ;
%reads(257_50195,257) ; run ;
%reads(278_50193,278) ; run ;
%reads(280_50115,280) ; run ;
%reads(290_50202,290) ; run ;
%reads(396_50258,396) ; run ;
%reads(401_50228,401) ; run ;
%reads(459_50243,459) ; run ;
%reads(468_50227,468) ; run ;
%reads(480_50185,480) ; run ;
%reads(523_50330,523) ; run ;


********************************************************************** ;
********************************************************************** ;
********************************************************************** ;
