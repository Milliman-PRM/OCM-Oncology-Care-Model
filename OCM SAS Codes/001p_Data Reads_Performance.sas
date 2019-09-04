********************************************************************** ;
********************************************************************** ;
********************************************************************** ;
*** Note to programmer: Layouts have changed EVERY data submission.  
*** Need to recheck with column headers in file each and every submission. *** ;
%let indir1 = R:\data\HIPAA\OCM_Oncology_Care_Model_PP\02 - Performance Data ;
libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Performance\FBQ11" ;

options ls=132 ps=70 obs =max;

********************************************************************** ;
********************************************************************** ;
%let cdate = 20190731;  *** date in file names *** ;
%let cdate1 = 20190430;  *** date in file names - bene file *** ;

%let q = 11 ;  *** quarter of file submission *** ;

run ;

********************************************************************** ;
********************************************************************** ;

%macro readsbene(dsid,did,special,qtr) ;

**************** Beneficiary File **************************************** ;
data out.epi_&dsid. (rename=(DEATH=DOD));
				        
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._benelevel_fbq&qtr._&cdate1..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
		BENE_ID					:$15.
		BENE_HICN				:$12.
		BENE_MBI				:$50.
		FIRST_NAME				:$15.
		LAST_NAME				:$24.
		DOB						:yymmdd8.
		QTR_START_DATE			:yymmdd8.
		/* Fields new to performance data. */
		EM_VISITS				:3.
		EM_VISITS_ALL			:3.
		CHEMO_DATE				:yymmdd8.
		RISK_SCORE				:6.3
		HIGH_RISK 				:1.
		COMMON_CANCER_TYPE		:1.
		CANCER_TYPE				:$100.
		GENDER					:$1.  /*Called GENDER in documentation, but was SEX in baseline. */
		AGE_CATEGORY_5			:11. /* Actual age was provided in baseline, now <65, 65-69, 70-74, 75-79, 80+ */
		RACE					:1.
		DUAL					:1.
		ALL_TOS 				:12.2
		INP_ADMSNS 				:12.2
		INP_EX 					:12.2
		UNPLANNED_READ 			:12.2
		ER_OBS_AD 				:12.2
		ER_AD 					:12.2
		OBS_AD 					:12.2
		ER_AND_OBS_AD 			:12.2
		NO_ER_NO_OBS_AD 		:12.2
		OBS_STAYS 				:12.2
		OBS_ER 					:12.2
		OBS_NO_ER 				:12.2
		ER_NO_AD_OBS 			:12.2
		R_ONC 					:12.2
		PHY_SRVC 				:12.2
		PHY_ONC 				:12.2
		PHY_OTH 				:12.2
		ANC_TOT 				:12.2
		ANC_LAB_TOT 			:12.2
		ANC_LAB_ADV 			:12.2
		ANC_LAB_OTHER 			:12.2
		ANC_IMAG_TOT 			:12.2
		ANC_IMAG_ADV 			:12.2
		ANC_IMAG_OTH 			:12.2
		OUT_OTHER 				:12.2
		HHA 					:12.2
		SNF 					:12.2
		LTC 					:12.2
		IRF 					:12.2
		HSP_TOT 				:12.2
		HSP_FAC					:12.2
		HSP_HOME 				:12.2
		HSP_BOTH 				:12.2	
		DME_NO_DRUGS 			:12.2
		PD_TOT 					:12.2
		PD_PTB_PHYDME 			:12.2
		PD_PTB_PHYDME_CHEMO		:12.2 /*Added for FBQ08*/
		PD_PTB_PHYDME_ANTI		:12.2 /*Added for FBQ08*/
		PD_PTB_PHYDME_ESA		:12.2 /*Added for FBQ08*/
		PD_PTB_PHYDME_NGF		:12.2 /*Added for FBQ08*/
		PD_PTB_PHYDME_OTHER		:12.2 /*Added for FBQ08*/
		PD_PTB_OUT 				:12.2
		PD_PTB_OUT_CHEMO		:12.2 /*Added for FBQ08*/
		PD_PTB_OUT_ANTI			:12.2 /*Added for FBQ08*/
		PD_PTB_OUT_ESA			:12.2 /*Added for FBQ08*/
		PD_PTB_OUT_NGF			:12.2 /*Added for FBQ08*/
		PD_PTB_OUT_OTHER		:12.2 /*Added for FBQ08*/
		PD_PTD_ALL 				:12.2
		PD_PTD_CHEMO			:12.2 /*Added for FBQ08*/
		PD_PTD_ANTI				:12.2 /*Added for FBQ08*/
		PD_PTD_ESA				:12.2 /*Added for FBQ08*/
		PD_PTD_NGF				:12.2 /*Added for FBQ08*/
		PD_PTD_OTHER			:12.2 /*Added for FBQ08*/
		OTHER 					:12.2
		ALL_TOS_ADJ 			:12.2
		INP_ADMSNS_ADJ 			:12.2
		INP_EX_ADJ 				:12.2
		UNPLANNED_READ_ADJ 		:12.2
		ER_OBS_AD_ADJ 			:12.2
		ER_AD_ADJ 				:12.2
		OBS_AD_ADJ 				:12.2
		ER_AND_OBS_AD_ADJ 		:12.2	
		NO_ER_NO_OBS_AD_ADJ 	:12.2	
		OBS_STAYS_ADJ 			:12.2
		OBS_ER_ADJ 				:12.2
		OBS_NO_ER_ADJ 			:12.2
		ER_NO_AD_OBS_ADJ 		:12.2	
		R_ONC_ADJ 				:12.2
		PHY_SRVC_ADJ 			:12.2
		PHY_ONC_ADJ 			:12.2	
		PHY_OTH_ADJ 			:12.2
		ANC_TOT_ADJ 			:12.2
		ANC_LAB_TOT_ADJ 		:12.2
		ANC_LAB_ADV_ADJ 		:12.2
		ANC_LAB_OTHER_ADJ 		:12.2
		ANC_IMAG_TOT_ADJ 		:12.2
		ANC_IMAG_ADV_ADJ 		:12.2
		ANC_IMAG_OTH_ADJ 		:12.2
		OUT_OTHER_ADJ 			:12.2
		HHA_ADJ 				:12.2
		SNF_ADJ 				:12.2
		LTC_ADJ 				:12.2
		IRF_ADJ 				:12.2
		HSP_TOT_ADJ 			:12.2	
		HSP_FAC_ADJ 			:12.2	
		HSP_HOME_ADJ 			:12.2
		HSP_BOTH_ADJ 			:12.2
		DME_NO_DRUGS_ADJ 		:12.2
		PD_TOT_ADJ 				:12.2
		PD_PTB_PHYDME_ADJ 		:12.2	
		PD_PTB_PHYDME_CHEMO_ADJ :12.2 /*Added for FBQ08*/	
		PD_PTB_PHYDME_ANTI_ADJ	:12.2 /*Added for FBQ08*/	
		PD_PTB_PHYDME_ESA_ADJ	:12.2 /*Added for FBQ08*/	
		PD_PTB_PHYDME_NGF_ADJ	:12.2 /*Added for FBQ08*/	
		PD_PTB_PHYDME_OTHER_ADJ :12.2 /*Added for FBQ08*/	
		PD_PTB_OUT_ADJ 			:12.2
		PD_PTB_OUT_CHEMO_ADJ 	:12.2 /*Added for FBQ08*/	
		PD_PTB_OUT_ANTI_ADJ 	:12.2 /*Added for FBQ08*/	
		PD_PTB_OUT_ESA_ADJ		:12.2 /*Added for FBQ08*/	
		PD_PTB_OUT_NGF_ADJ 		:12.2 /*Added for FBQ08*/	
		PD_PTB_OUT_OTHER_ADJ 	:12.2 /*Added for FBQ08*/	
		PD_PTD_ALL_ADJ 			:12.2
		PD_PTD_CHEMO_ADJ		:12.2 /*Added for FBQ08*/	
		PD_PTD_ANTI_ADJ			:12.2 /*Added for FBQ08*/	
		PD_PTD_ESA_ADJ			:12.2 /*Added for FBQ08*/	
		PD_PTD_NGF_ADJ			:12.2 /*Added for FBQ08*/	
		PD_PTD_OTHER_ADJ		:12.2 /*Added for FBQ08*/	
		OTHER_ADJ 				:12.2
		RISK_ADJ_FACTOR 		:9.6
		INFLATION_FACTOR 		:6.4
		INP_ADMSNS_UTIL 		:12.	
		INP_EX_UTIL 			:12.
		UNPLANNED_READ_UTIL 	:12.
		ER_OBS_AD_UTIL 			:12.
		ER_AD_UTIL 				:12.
		OBS_AD_UTIL 			:12.
		ER_AND_OBS_AD_UTIL 		:12.
		NO_ER_NO_OBS_AD_UTIL 	:12.	
		OBS_STAYS_UTIL 			:12.
		OBS_ER_UTIL 			:12.
		OBS_NO_ER_UTIL 			:12.
		ER_NO_AD_OBS_UTIL 		:12.
		R_ONC_UTIL 				:12.
		PHY_SRVC_UTIL 			:12.
		PHY_ONC_UTIL 			:12.	
		PHY_OTH_UTIL 			:12.
		ANC_LAB_TOT_UTIL 		:12.
		ANC_LAB_ADV_UTIL 		:12.
		ANC_LAB_OTHER_UTIL 		:12.
		ANC_IMAG_TOT_UTIL 		:12.
		ANC_IMAG_ADV_UTIL 		:12.	
		ANC_IMAG_OTH_UTIL 		:12.
		HHA_UTIL 				:12.
		SNF_UTIL 				:12.	
		LTC_UTIL 				:12.
		IRF_UTIL 				:12.
		HSP_UTIL 				:12.
		DEATH 					:yymmdd8.  
		DIED					:8.
		HSP_30DAYS_ALL			:8.
		ANY_HSP_CARE			:8.
		HSP_DAYS				:8.
		HOSPITAL_USE			:8.
		INTENSIVE_CARE_UNIT		:8.
		CHEMOTHERAPY			:8.	
		/*** Fields new to Perfomance Period 2 ***/
		BR_KADYCLA_B			:12.2
		BR_AVASTIN_B			:12.2
		BR_ABRAXANE_B			:12.2  /*** NEW TO P1-Q3 *** */
		BR_NEULASTA_B			:12.2
		BR_PERJETA_B			:12.2
		BR_HERCEPTIN_B			:12.2
		BR_AFINITOR_D			:12.2
		BR_IBRANCE_D			:12.2	/*** NEW TO P1-Q3 *** */
		PR_JEVTANA_B			:12.2
		PR_PROVENGE_B			:12.2
		PR_ZYTIGA_D				:12.2
		PR_XTANDI_D				:12.2
		LU_TECENTRIQ_B			:12.2
		LU_AVASTIN_B			:12.2
		LU_OPDIVO_B				:12.2
		LU_ABRAXANE_B			:12.2
		LU_NEULASTA_B			:12.2
		LU_KEYTRUDA_B			:12.2
		LU_ALIMTA_B				:12.2
		LU_GILOTRIF_D			:12.2
		LU_TARCEVA_D			:12.2
		LY_TREANDA_B			:12.2
		LY_VELCADE_B			:12.2
		LY_OPDIVO_B				:12.2
		LY_NEULASTA_B			:12.2
		LY_KEYTRUDA_B			:12.2
		LY_RITUXAN_B			:12.2
		LY_IMBRUVICA_D			:12.2
		LY_REVLIMID_D			:12.2
		IC_AVASTIN_B			:12.2
		IC_XELODA_B				:12.2
		IC_ERBITUX_B			:12.2
		IC_NEULASTA_B			:12.2
		IC_KEYTRUDA_B			:12.2
		IC_ZALTRAP_B			:12.2
		IC_VECTIBIX_D			:12.2
		MU_VELCADE_B			:12.2
		MU_KYPROLIS_B			:12.2
		MU_DARZALEX_B			:12.2
		MU_REVLIMID_D			:12.2
		BL_TECENTRIQ_B			:12.2
		BL_OPDIVO_B				:12.2
		HN_ERBITUX_B			:12.2
		HN_OPDIVO_B				:12.2
		HN_KEYTRUDA_B			:12.2
		MA_YERVOY_B				:12.2
		MA_OPDIVO_B				:12.2
		MA_KEYTRUDA_B			:12.2
		MA_COTELLIC_D			:12.2
		MA_TAFINLAR_D			:12.2
		MA_MEKINIST_D			:12.2
		MA_ZELBORAF_D			:12.2
		/*** Fields new to P1-Q3 Membership File */
		PART_D_MM				:8.6

		;

    format DOB DEATH qtr_start_date chemo_date mmddyy10. ;
	
    array dt (i) qtr_start_date chemo_date /*EP_BEG EP_END*/ ;
    array ym (i) QTR_YYMM CHEMYYMM /*BEG_YYMM END_YYMM*/ ;
    do i = 1 to 2 ;
        ym = year(dt)*100 + month(dt) ;
    end ;
    drop i ;
run ;


%mend readsbene ; run ;
********************************************************************** ;
********************************************************************** ;
********************************************************************** ;

/*
%readsbene(137_50136,137,,&q.) ; run ;
%readsbene(255_50179,255,,&q.) ; run ;
%readsbene(257_50195,257,,&q.) ; run ;
%readsbene(278_50193,278,,&q.) ; run ;
%readsbene(280_50115,280,,&q.) ; run ;
%readsbene(290_50202,290,,&q.) ; run ; 
%readsbene(396_50258,396,,&q.) ; run ;
%readsbene(401_50228,401,,&q.) ; run ;
%readsbene(459_50243,459,,&q.) ; run ; 
%readsbene(468_50227,468,,&q.) ; run ;
%readsbene(480_50185,480,,&q.) ; run ;
%readsbene(523_50330,523,,&q.) ; run ;
*/


***********************************************************************;
************** CLAIMS - LEVEL FILES************************************;
***********************************************************************;
%macro claims(qtr,qtr2) ;

********************************************************************** ;
**************** Substance Abuse and Mental Health File ************** ;

data out.samh_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._samh_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
	Service					:$3.
	Count					:12.
	Dropped_Exp				:12.

run ;
********************************************************************** ;
**************** Inpatient Header File ******************************* ;

data out.iphdr_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._inphead_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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
	TYPESRVC				:$1.
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

data out.snfhdr_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._snfhead_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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
	CLM_SRVC_CLSFCTN_TYPE_CD		:$1.
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

data out.&fn.rev_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._&fn.rev_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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
	REV_CNTR_TOT_CHRG_AMT		:12.
	REV_CNTR_NCVRD_CHRG_AMT		:12.
    ;

    ;
    format THRU_DT mmddyy10. ;
    thruyymm = year(thru_dt)*100 + month(thru_dt) ;



run ;

********************************************************************** ;
**************** Inpatient/SNF Val File ****************************** ;

data out.&fn.val_&dsid._&qtr2. ;
    infile "&&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._&fn.val_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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

data out.hsphdr_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._hsphead_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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
	NCH_BENE_DSCHRG_DT		:DATE8.
	CLM_SRVC_CLSFCTN_TYPE_CD	:$1.
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



    ;

    format FROM_DT THRU_DT WKLY_DT  FI_CLM_PROC_DT HSPCSTRT  NCH_BENE_DSCHRG_DT mmddyy10. ;
    array dt (i) From_dt thru_dt HSPCSTRT ;
    array ym (i) fromyymm thruyymm hstrtyymm ;
    do i = 1 to 3 ;
        ym = year(dt)*100 + month(dt) ;
    end ;
    drop i ;

run ;

********************************************************************** ;
********************* Hospice Rev File ******************************* ;

data out.hsprev_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._hsprev_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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

data out.hhahdr_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._hhahead_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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
	CLM_SRVC_CLSFCTN_TYPE_CD	:$1.
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

data out.hharev_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._hharev_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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

data out.outhdr_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._outhead_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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
	CLM_SRVC_CLSFCTN_TYPE_CD	:$1.
	CLM_FREQ_CD				:$1.
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

data out.outrev_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._outrev_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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
	CLM_REV_STD_PYMT_AMT	:12.
;
    format THRU_DT REV_DT mmddyy10. ;
    thruyymm = year(thru_dt)*100 + month(thru_dt) ;
    revyymm = year(rev_dt)*100 + month(rev_dt) ;
run ;


********************************************************************** ;
************************** OP Val File ******************************* ;

data out.outval_&dsid._&qtr2. ;
    infile "&&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._outval_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
    input
	BENE_ID					:$15.
	CLM_ID					:$15.
	VAL_CD					:$2.
	VAL_AMT					:12.
	EP_ID					:12.
	CLM_STD_OUTLIER_PYMT_AMT	:8.
	;

run ;

********************************************************************** ;
********************* DME Header File ******************************* ;

data out.dmehdr_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._dmehead_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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
	ICD_DGNS_VRSN_CD12		:$1.		

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
********************* PHYS Header File ******************************* ;

data out.phyhdr_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._phyhead_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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
	ICD_DGNS_VRSN_CD12		:$1.		


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
*********************** PHYS Line File ******************************* ;

data out.PHYLINE_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._PHYline_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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

data out.DMELINE_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._dmeline_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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

data out.PDE_&dsid._&qtr2. ;
    infile "&indir1.\FBQ&qtr.\OCM_&did.\OCM_&dsid._pde_fbq&qtr._&special.&cdate..txt" lrecl=10000 dlm='|' dsd missover firstobs=2;
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

%mend claims ;

********************************************************************** ;
********************************************************************** ;
%macro readsclaim(dsid,did,special) ;

*%claims(1) ; *** Not provided as of fbq05 ;
*%claims(2) ; *** Not provided as of fbq06 ;
*%claims(3) ; *** Not provided as of fbq07 ;
*%claims(4) ; *** Not provided as of fbq08 ;
*%claims(5) ; *** Not provided as of fbq09 ;
*%claims(6) ; *** Not provided as of fbq10 ;
*%claims(07,7) ; *** Not provided as of fbq11 ;
%claims(08,8) ;
%claims(09,9) ;
%claims(10,10) ;
%claims(11,11) ;

%mend readsclaim ; run ;
********************************************************************** ;
********************************************************************** ;
********************************************************************** ;

%readsclaim(137_50136,137,) ; run ;
%readsclaim(255_50179,255,) ; run ;
%readsclaim(257_50195,257,) ; run ;
%readsclaim(278_50193,278,) ; run ;
%readsclaim(280_50115,280,) ; run ;
%readsclaim(290_50202,290,) ; run ; 
%readsclaim(396_50258,396,) ; run ;
%readsclaim(401_50228,401,) ; run ;
%readsclaim(459_50243,459,) ; run ; 
%readsclaim(468_50227,468,) ; run ;
%readsclaim(480_50185,480,) ; run ;
%readsclaim(523_50330,523,) ; run ;

********************************************************************** ;
********************************************************************** ;
********************************************************************** ;
/*
**** New Beneficiary File Checks **** ;
proc PRINT data=out.epi_468_50337 (obs=10) ;

proc freq data=out.epi_468_50337 ;
	tables QTR_YYMM CHEMYYMM HIGH_RISK COMMON_CANCER_TYPE CANCER_TYPE SEX AGE_CATEGORY RACE
		   DUAL  ;

proc univariate data=out.epi_468_50337 ;
	var ALL_TOS INP_ADMSNS 	INP_EX 	UNPLANNED_READ 	ER_OBS_AD ER_AD OBS_AD 	ER_AND_OBS_AD 			
		NO_ER_NO_OBS_AD OBS_STAYS OBS_ER OBS_NO_ER ER_NO_AD_OBS R_ONC PHY_SRVC PHY_ONC PHY_OTH
		ANC_TOT ANC_LAB_TOT ANC_LAB_ADV ANC_LAB_OTHER ANC_IMAG_TOT 	ANC_IMAG_ADV ANC_IMAG_OTH 			
		OUT_OTHER HHA SNF LTC IRF HSP_TOT HSP_FAC HSP_HOME HSP_BOTH	DME_NO_DRUGS PD_TOT 					
		PD_PTB_PHYDME PD_PTB_OUT PD_PTD_ALL OTHER ALL_TOS_ADJ INP_ADMSNS_ADJ INP_EX_ADJ
		UNPLANNED_READ_ADJ ER_OBS_AD_ADJ ER_AD_ADJ OBS_AD_ADJ ER_AND_OBS_AD_ADJ 			
		NO_ER_NO_OBS_AD_ADJ OBS_STAYS_ADJ OBS_ER_ADJ OBS_NO_ER_ADJ ER_NO_AD_OBS_ADJ R_ONC_ADJ
		PHY_SRVC_ADJ PHY_ONC_ADJ PHY_OTH_ADJ ANC_TOT_ADJ ANC_LAB_TOT_ADJ ANC_LAB_ADV_ADJ 		
		ANC_LAB_OTHER_ADJ ANC_IMAG_TOT_ADJ ANC_IMAG_ADV_ADJ ANC_IMAG_OTH_ADJ OUT_OTHER_ADJ 			
		HHA_ADJ SNF_ADJ LTC_ADJ IRF_ADJ HSP_TOT_ADJ HSP_FAC_ADJ HSP_HOME_ADJ HSP_BOTH_ADJ 			
		DME_NO_DRUGS_ADJ PD_TOT_ADJ PD_PTB_PHYDME_ADJ PD_PTB_OUT_ADJ PD_PTD_ALL_ADJ 			
		OTHER_ADJ INP_ADMSNS_UTIL INP_EX_UTIL UNPLANNED_READ_UTIL 	
		ER_OBS_AD_UTIL ER_AD_UTIL OBS_AD_UTIL ER_AND_OBS_AD_UTIL NO_ER_NO_OBS_AD_UTIL 	
		OBS_STAYS_UTIL OBS_ER_UTIL OBS_NO_ER_UTIL ER_NO_AD_OBS_UTIL R_ONC_UTIL 	PHY_SRVC_UTIL 			
		PHY_ONC_UTIL PHY_OTH_UTIL ANC_LAB_TOT_UTIL ANC_LAB_ADV_UTIL ANC_LAB_OTHER_UTIL 		
		ANC_IMAG_TOT_UTIL ANC_IMAG_ADV_UTIL ANC_IMAG_OTH_UTIL HHA_UTIL SNF_UTIL LTC_UTIL 				
		IRF_UTIL HSP_UTIL 	PART_D_MM 			
;
*/
run ;

