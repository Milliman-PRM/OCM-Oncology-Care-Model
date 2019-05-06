********************************************************************** ;
        ***** R003p_Service_Categories.sas ***** ;
********************************************************************** ;

libname IN1 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP1" ;
libname REC1 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP1" ;
libname IN2 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP2" ;
libname REC2 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP2" ;
libname IN3 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP3" ;
libname REC3 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP3" ;
libname ref "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\90 - Investigations\HCPCS_BETOS";
options ls=132 ps=70 obs=MAX mprint mlogic; run ;

********************************************************************** ;
********************************************************************** ;
*** Initiating therapy lists *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats PP2.sas" ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats PP3.sas" ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats PP4.sas" ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats PP5.sas" ;
*** Cancer diagnosis code lists *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Cancer Formats PP3.sas" ;
*** Cancer assignment macro  *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Cancer Diagnoses_5.sas" ;
*** Bene level Quality Metrics *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_AHRQ.sas" ;
*** Novel Therapy *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Novel Therapy.sas" ;
*** Service Categories *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Service_Categories_v2.sas" ;
*** Inpatient Allowed Amount Calculation Needs *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000 - CMMI - Formats - Hemophilia Clotting Factors.sas" ;
run ;
*** Predictive Model Variable Development  *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Predict_Flags PP2.sas" ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Predict_Flags PP3.sas" ;
*** MEOS Payments  *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_MEOS PAYMENTS_v3.sas" ; 
*** For chemo-sensitive override *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\000_Formats_Breast_Hormonal.sas" ; run ;
*** For unplanned readmission identification *** ;
%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\IP_Readmissions_v2.sas" ; run ;

********************************************************************** ;

***Performance Period 1***;
%let vers = R2 ; *** R = Reconciliation, 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let it = 2 ;  *** 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let tu = 2 ; *** blank for initial, 1 for true-up 1, 2 for true-up 2 *** ;
%let sd = mdy(7,1,2016) ; *** Start of reconciled period ;
%let potential = mdy(1,1,2017) ;  *** date of latest episode begin date included in reconciled period. *** ;
%let ref = 1 ; *** directory number for input and output files *** ;

/*
***Performance Period 2***;
%let vers = R1 ; *** R = Reconciliation, 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let it = 1 ;  *** 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let tu = 1 ; *** blank for initial, 1 for true-up 1, 2 for true-up 2 *** ;
%let sd = mdy(1,2,2017) ; *** Start of reconciled period ;
%let potential = mdy(7,1,2017) ;  *** date of latest episode begin date included in reconciled period. *** ;
%let ref = 2 ; *** directory number for input and output files *** ;
*/
/*
***Performance Period 3***;
%let vers = R0 ; *** R = Reconciliation, 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let it = 0 ;  *** 0 = Initial Reconciliation, 1 = True Up #1, 2 = True Up #2  *** ;
%let tu =  ; *** blank for initial, 1 for true-up 1, 2 for true-up 2 *** ;
%let sd = mdy(7,2,2017) ; *** Start of reconciled period ;
%let potential = mdy(1,1,2018) ;  *** date of latest episode begin date included in reconciled period. *** ;
%let ref = 3 ; *** directory number for input and output files *** ;
*/

%let bl = p&ref.&vers. ; *** performance period X, bene file received *** ;
%LET IN_BETOS = ref.hcpcs_betos_crosswalk ;
run ;

%MACRO EPISODE_PERIOD ;
    EPISODE_PERIOD = "PP&ref." ;
%MEND ;


***From Reconciliation Reports***;
%let othwinsl1 = 630.37 ;
%let othwinsu1 = 76759.28 ;
%let othwinsl2 = 946.41 ;
%let othwinsu2 = 89240.82 ;
%let othwinsl3 = 895.73 ;
%let othwinsu3 = 95511.36 ;
/*
**** Import of Winsorization Floors and Caps **** ;

PROC IMPORT OUT= REC1.wins_pp1
            DATAFILE= "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Data from Other Sources\CMS\Materials for PP1 Reconciliation\Winsorization_Recon_PP1_TU2.xlsx"
            DBMS=EXCEL REPLACE;
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= REC2.wins_pp2
            DATAFILE= "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Data from Other Sources\CMS\Materials for PP2 Reconciliation\Winsorization_Recon_PP2_TU1.xlsx"
            DBMS=EXCEL REPLACE;
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= REC3.wins_pp3
            DATAFILE= "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Data from Other Sources\CMS\Materials for PP3 Reconciliation\Winsorization_Recon_PP3.xlsx"
            DBMS=EXCEL REPLACE;
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
*/

********************************************************************** ;
********************************************************************** ;



%macro sc(ds,id) ;

*** For End of Life Metrics *** ;
proc sort data=REC&ref..epi_prelim_&bl._&ds. 
	OUT=EPI_DOD (KEEP = BENE_ID EP_ID DOD EP_BEG EP_END epi_tax_id EPI_ATT_TIN CANCER_TYPE %if &vers. ne R0 %then %do; Prior_Changed_Episode where = (Prior_Changed_Episode ne "Yes") %end;) ; BY BENE_ID ;

**************************************************************************************
*************************** IP COST MODEL LOGIC **************************************
**************************************************************************************;

PROC SORT DATA=REC&ref..check_ipop_&bl._&ds. OUT=IPOP ; BY BENE_ID EP_ID CLM_ID ;
PROC MEANS DATA=IPOP NOPRINT MAX ; BY BENE_ID EP_ID CLM_ID ;
    VAR BMT_ALLOGENEIC BMT_AUTOLOGOUS /*BMT_ALLOGENEIC_AK BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS
        BMT_AUTOLOGOUS_AK BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS*/
        ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY
        LIVER_SURGERY LUNG_SURGERY OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY 
		dxANAL_SURGERY dxBLADDER_SURGERY dxBREAST_SURGERY dxFEMALEGU_SURGERY dxGASTRO_SURGERY dxHEADNECK_SURGERY dxINTESTINAL_SURGERY 
		dxLIVER_SURGERY dxLUNG_SURGERY dxOVARIAN_SURGERY dxPANCREATIC_SURGERY dxPROSTATE_SURGERY ;
    OUTPUT OUT=IPOP_FLAGS (DROP = _TYPE_ _FREQ_)
           MAX() = ;
RUN ;

%macro IP ;

DATA ICU ;
    SET REC&ref..inpatient_&bl._&ds. ;
    IF REV_CNTR IN ('0200','0201','0202','0203','0204','0206','0207','0208','0209') THEN ICU = 1 ;
    IF REV_CNTR IN ('0450','0451','0452','0453','0454','0455','0456','0457','0458','0459','0981') THEN DO ;
        /*IF REV_RATE > 0 THEN*/ IP_ER = 1 ;
        IF (('70000' LE HCPCS_CD LE '89999') OR
           HCPCS_CD  IN ('G0106','G0120','G0122','G0130','G0202','G0204','G0206','G0219','G0235','G0252','G0255','G0288','G0389','S8035',
                         'S8037','S8040','S8042','S8080','S8085','S8092','S9024')) THEN IP_ER = 0 ;
    END ;
    IF REV_CNTR = '0762' OR
       (REV_CNTR = '0760' AND HCPCS_CD = 'G0378' AND REV_UNIT GE 8) THEN DO ;
       /*IF REV_RATE > 0 THEN*/ IP_OBS = 1 ;
    END ;


PROC SQL ;
        CREATE TABLE ICU2 AS
    SELECT A.*, B.*
    FROM EPI_DOD AS A, ICU AS B
    WHERE A.BENE_ID = B.BENE_ID AND
          A.EP_ID = B.EP_ID AND
          A.EP_BEG LE ADMSN_DT LE A.EP_END ;
quit ;

PROC SORT DATA=ICU2 ; BY BENE_ID EP_ID CLM_ID ;
PROC MEANS DATA=ICU2 NOPRINT MAX ; BY BENE_ID EP_ID CLM_ID ;
    VAR ICU IP_ER IP_OBS ;
    OUTPUT OUT=ICU_FLAGS (DROP = _TYPE_ _FREQ_)
           MAX() = ;

data iphdr_clean ;
    MERGE ICU2(IN=A DROP=ICU) ICU_FLAGS(IN=B) ; by bene_id ep_id clm_id ;
    IF A AND B ;
    if first.clm_id THEN OUTPUT ;

PROC SORT DATA=IPHDR_CLEAN ; BY BENE_ID EP_ID CLM_ID ;

data SC_ip_&bl._&ds. ;
    MERGE IPHDR_CLEAN(IN=A)
          IPOP_FLAGS ;
    BY BENE_ID EP_ID CLM_ID ;
    if a ;
	if nopay_cd = " " ;
    if missing(DED_AMT) then DED_AMT = 0;
    if missing(COIN_AMT) then COIN_AMT = 0;
    if missing(BLDDEDAM) then BLDDEDAM = 0;
    allowed = sum(PMT_AMT,(PER_DIEM*UTIL_DAY)) ;
    STD_PAY = CLM_STD_PYMT_AMT/.98 ;
	IF STD_PAY = . THEN STD_PAY = ALLOWED/.98 ;


    **** Initializing Service Category **** ;
    FORMAT Service_CAT $50.; length Service_CAT $50. ;
    Service_CAT = "Inpatient" ;

      pv = substr(PROVIDER,3,4);
      pv2 = substr(PROVIDER,3,1);
      if '3025'=< pv and pv <='3099' then Service_Cat='IRF';
      if pv2 in ('T','R') then Service_Cat='IRF';
      if DRG_CD in ('945','946') then Service_Cat='IRF';
      if '2000' <= pv and pv <= '2299' then Service_Cat='LTAC';
      IF PV2 in ('S','M') THEN SERVICE_CAT = "Other Hospital Type" ;
	  if '4000' <= pv and pv <= '4499' THEN SERVICE_CAT = "Other Hospital Type" ;
      IF SERVICE_CAT = "IRF" THEN EXP_IRFC = CLM_STD_PYMT_AMT/.98 ;
      ELSE IF SERVICE_CAT = "LTAC" THEN EXP_LTAC = CLM_STD_PYMT_AMT/.98;
      ELSE IF service_cat = "Other Hospital Type" then EXP_OTH = CLM_STD_PYMT_AMT/.98;
      ELSE EXP_IP = CLM_STD_PYMT_AMT/.98 ;
	  IF EXP_OTH NOTIN (0,.) THEN STD_PAY = 0  ;

        **** Flags  to Develop Benficiary File Variables *** ;
        IP_CAH = 0 ; IP_CHEMO_ADMIN = 0 ;
        IF ('0001' LE SUBSTR(PROVIDER,3,4) LE '0879') OR
           ('1300' LE SUBSTR(PROVIDER,3,4) LE '1399') THEN IP_CAH = 1 ;
    *** Identification of Short Term Acute and CAH stays for readmissions *** ;
    if '0001' le substr(provider,3,4) le '0879' or
       '1300' le substr(provider,3,4) le '1399' then readm_cand = 1 ;
    else readm_cand = 0 ;


	%canc_init ;

		ARRAY v (I) ICD_DGNS_VRSN_CD1-ICD_DGNS_VRSN_CD25 ;
		ARRAY d (I) ICD_DGNS_CD1-ICD_DGNS_CD25 ;	
		DO I = 1 TO 25 ;
			%CANCERTYPE(v, d) ;
			IF V = '9' and D = "V707" and NOPAY_CD = ' ' THEN CT = 1 ;
			IF V = '0' and D = "Z006" and NOPAY_CD = ' ' THEN CT = 1 ;
		END ;
		DROP I ;

        IF PRNCPAL_DGNS_CD IN ('V5811', 'V5812', 'Z5111', 'Z5112') THEN IP_CHEMO_ADMIN = 1 ; *** Source: OCM ticket 787031 - with file attached OCM-1+Measure+Specifications *** ;

		if CANCER_TYPE = "Acute Leukemia" then IP_BMT_AK = MAX(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;
	    if CANCER_TYPE = "Lymphoma" THEN IP_BMT_L = MAX( BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;
		if CANCER_TYPE = "Multiple Myeloma" THEN IP_BMT_MM = MAX(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;
	    if CANCER_TYPE = "MDS" THEN IP_BMT_MDS = MAX(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;
	    *IF CANCER_TYPE = "Chronic Leukemia" THEN IP_BMT_CL = MAX(BMT_ALLOGENEIC,BMT_AUTOLOGOUS) ;

		if CANCER_TYPE ne "Breast Cancer" and dxBreast_surgery = 0 then BREAST_SURGERY = 0 ;
		if CANCER_TYPE ne "Anal Cancer" and dxAnal_surgery = 0 then ANAL_SURGERY = 0 ;
		if CANCER_TYPE ne "Liver Cancer" and dxLiver_surgery = 0 then LIVER_SURGERY = 0 ;
		if CANCER_TYPE ne "Lung Cancer" and dxLung_surgery = 0 then LUNG_SURGERY = 0 ;
		if CANCER_TYPE ne "Bladder Cancer" and dxBladder_surgery = 0 then BLADDER_SURGERY = 0 ;
		if CANCER_TYPE ne "Female GU Cancer other than Ovary" and dxFemalegu_surgery = 0 then FEMALEGU_SURGERY = 0 ;
		if CANCER_TYPE ne "Gastro/Esophageal Cancer" and dxGastro_surgery = 0 then GASTRO_SURGERY = 0 ;
		if CANCER_TYPE ne "Head and Neck Cancer" and dxHeadNeck_surgery = 0 then HEADNECK_SURGERY = 0 ;
		if CANCER_TYPE ne "Small Intestine / Colorectal Cancer" and dxIntestinal_surgery = 0 then INTESTINAL_SURGERY = 0 ;
		if CANCER_TYPE ne "Ovarian Cancer" and dxOvarian_surgery = 0 then OVARIAN_SURGERY = 0 ;
		if CANCER_TYPE ne "Prostate Cancer" and dxProstate_surgery = 0 then PROSTATE_SURGERY = 0 ;
		if CANCER_TYPE ne "Pancreatic Cancer" and dxPancreatic_surgery = 0 then PANCREATIC_SURGERY = 0 ;

        SIP_ANAL = ANAL_SURGERY ;
        SIP_BLADDER = BLADDER_SURGERY ;
        SIP_BREAST = BREAST_SURGERY ;
        SIP_FEMALEGU = FEMALEGU_SURGERY ;
        *SIP_KIDNEY = KIDNEY_SURGERY ;
        SIP_GASTRO = GASTRO_SURGERY ;
        SIP_HN = HEADNECK_SURGERY ;
        SIP_INT = INTESTINAL_SURGERY ;
        SIP_LIVER = LIVER_SURGERY ;
        SIP_LUNG = LUNG_SURGERY ;
        SIP_OVARIAN = OVARIAN_SURGERY ;
        SIP_PROSTATE = PROSTATE_SURGERY ;
        SIP_PANCREATIC = PANCREATIC_SURGERY ;
        ***************************************************** ;

        IF SUM(IP_CHEMO_ADMIN, IP_BMT_AK, IP_BMT_L, IP_BMT_MM, IP_BMT_MDS, SIP_BREAST,SIP_ANAL,SIP_LIVER,
                   SIP_LUNG, SIP_BLADDER, SIP_FEMALEGU,SIP_GASTRO, SIP_HN, SIP_INT, SIP_OVARIAN, SIP_PROSTATE,
                   SIP_PANCREATIC) GE 1 THEN EX1 = 0 ; ELSE EX1 = 1 ;

		IF IP_CAH NE 1 THEN EX1 = 0 ;

                *** End of Life variables *** ;
        FORMAT WIN_30_DOD MMDDYY10. ;
        WIN_30_DOD = INTNX('DAY',DOD,-29,'SAME') ;
        *** 6/2: As per OCM Ticket Number 799812 - inpatient metrics are screened by admit date, not discharge date. *** ;
        IF IP_CAH = 1 THEN DO ;
            IF (WIN_30_DOD LE ADMSN_DT LE DOD) THEN IP_ALLCAUSE_30 = 1 ;
        END;
        *** 6/2: As per OCM Ticket Number 799812 - inpatient metrics are screened by admit date, not discharge date. *** ;
        IF ICU = 1 THEN DO ;
            IF (WIN_30_DOD LE ADMSN_DT LE DOD) THEN IP_ICU_30 = 1 ;
        END ;
        IF DOD NE . AND IP_ALLCAUSE_30 NE 1 THEN IP_ALLCAUSE_30 = 0 ;
        IF DOD NE . AND IP_ICU_30 NE 1 THEN IP_ICU_30 = 0 ;

        DROP I HAS_CANCER %canc_flags
            /* BMT_ALLOGENEIC_AK BMT_ALLOGENEIC_L BMT_ALLOGENEIC_MM BMT_ALLOGENEIC_MDS
             BMT_AUTOLOGOUS_AK BMT_AUTOLOGOUS_L BMT_AUTOLOGOUS_MM BMT_AUTOLOGOUS_MDS*/ BMT_ALLOGENEIC BMT_AUTOLOGOUS
             ANAL_SURGERY BLADDER_SURGERY BREAST_SURGERY FEMALEGU_SURGERY GASTRO_SURGERY HEADNECK_SURGERY INTESTINAL_SURGERY LIVER_SURGERY LUNG_SURGERY
             OVARIAN_SURGERY PANCREATIC_SURGERY PROSTATE_SURGERY DOD;

**** Identification of Continuous Stays **** ;
*** As per OCM, claims are considered as belonging to the same stay if they have the same beneficiary ID
    and date of admission.  Singular admissions include stays that overlay with other stays, or are transfers.
    Transfers are defined as a discharge from one acute hospitalization to another acute hospitalization
    on the same day, where the discharge date of one hospitalization equals the admission date on another
    acute hospitalization **** ;

*** Step I1: Identify acute hospitalizations *** ;
DATA ACUTE NONACUTE ;
    SET SC_ip_&bl._&ds. ;
    IF IP_CAH = 1 THEN OUTPUT ACUTE ;
    ELSE OUTPUT NONACUTE ;

*** Step I2: Identify nested stays and transfers *** ;
PROC SORT DATA =ACUTE ; BY BENE_ID EP_ID ADMSN_DT DSCHRGDT ;

DATA ACUTE2 ;
    SET ACUTE ; BY BENE_ID EP_ID ADMSN_DT ;
    FORMAT PREV_ADM  PREV_DIS MMDDYY10. ;
    IF FIRST.EP_ID  THEN DO ;
        IP_CASE = 1 ;
        PREV_IP = IP_CASE ;
        PREV_ADM = ADMSN_DT ;
        PREV_DIS = DSCHRGDT ;
    END ;
    ELSE DO ;
        IF PREV_ADM LE ADMSN_DT LE PREV_DIS THEN IP_CASE = PREV_IP ; *** nested/overlapping stays *** ;
        ELSE IF PREV_DIS = ADMSN_DT THEN IP_CASE = PREV_IP ; *** transfers *** ;
        ELSE IP_CASE=SUM(PREV_IP,1) ;
        PREV_IP = IP_CASE ;
        PREV_ADM = ADMSN_DT ;
        PREV_DIS = DSCHRGDT ;
    END ;

    RETAIN PREV_IP PREV_ADM PREV_DIS;

*** Step I3: Assign nonacute stays to case number *** ;
PROC SORT DATA=NONACUTE ; BY BENE_ID EP_ID CLM_ID ;
DATA NONACUTE2 ;
    SET NONACUTE ; BY BENE_ID EP_ID CLM_ID ;
    IF FIRST.EP_ID THEN DO ;
        IP_CASE = 1001 ;
        PREV_CASE = IP_CASE ;
        PREV_CLM = CLM_ID ;
    END ;
    ELSE DO ;
        IF CLM_ID = PREV_CLM THEN IP_CASE = PREV_CASE ;
        ELSE IP_CASE = SUM(PREV_CASE,1) ;
        PREV_CASE = IP_CASE ;
        PREV_CLM = CLM_ID ;
    END ;

    RETAIN PREV_CASE PREV_CLM ;


*** Step I4: Set flags by case *** ;
*** Per OCM Ticket response 798221: Inpatient expenditure amounts are assigned on a claim basis using the ADMSN_DT. If a transfer or
    overlapping/nested hospitalization has an ADMSN_DT within the quarter, then its expenditures are included in the Inpatient categories.
    The combined inpatient stay would be counted in both utilization categories. This applies to any of the variations on the inpatient
    admissions utilization measure. If one claim of the combined stay satisfies the criteria for the admissions measure, then the entire
    stay is considered to satisfy the criteria. If multiple criteria are met, then the stay is counted in the multiple utilization categories. *** ;
DATA ALL ; SET ACUTE2 NONACUTE2 ;
proc sort data=all ; by bene_id  EP_ID IP_CASE ;
proc means data=all noprint max ; by bene_id EP_ID ip_case ;
    var ip_cah ip_chemo_admin
        IP_ALLCAUSE_30 IP_ICU_30
        IP_BMT_AK IP_BMT_L IP_BMT_MM IP_BMT_MDS
        SIP_ANAL SIP_BLADDER SIP_BREAST SIP_FEMALEGU
        SIP_GASTRO SIP_HN SIP_INT SIP_LIVER SIP_LUNG SIP_OVARIAN
        SIP_PROSTATE SIP_PANCREATIC IP_ER ;
    output out=case_level (drop = _type_ _freq_)
           max() =  ip_cah_case ip_chemo_admin_case
                    IP_ALLCAUSE_30_case IP_ICU_30_case
                    IP_BMT_AK_case IP_BMT_L_case IP_BMT_MM_case IP_BMT_MDS_case
                    SIP_ANAL_case SIP_BLADDER_case SIP_BREAST_case SIP_FEMALEGU_case
                    SIP_GASTRO_case SIP_HN_case SIP_INT_case SIP_LIVER_case SIP_LUNG_case SIP_OVARIAN_case
                    SIP_PROSTATE_case SIP_PANCREATIC_case IP_ER_CASE ;


*** Step I5: Create final file. *** ;

DATA REC&ref..SC_ip_&bl._&ds.  ;
    merge ALL(in=a)
           case_level(in=b) ;
           BY BENE_ID EP_ID IP_CASE ;
PROC SORT DATA=REC&ref..SC_ip_&bl._&ds. ; BY BENE_ID EP_ID CLM_ID ;

DATA REC&ref..SC_ip_&bl._&ds. ;
    SET REC&ref..SC_ip_&bl._&ds. ; BY BENE_ID EP_ID CLM_ID ;
    IF FIRST.CLM_ID THEN IP_LOS = UTIL_DAY ;
RUN ;
%mend IP ;


**************************************************************************************
*************************** OP COST MODEL LOGIC ***************************************
***************************************************************************************;
%MACRO OP ;

%if "&ref." ^= "1" AND "&ref." ^= "2" %then %do;
PROC SQL ;
    CREATE TABLE OUTPATIENT AS
    SELECT A.*, B. *
    FROM EPI_DOD AS A, REC&ref..OUTPATIENT_&bl._&ds. AS B
    WHERE A.BENE_ID = B.BENE_ID AND
          A.EP_ID =  B.EP_ID AND
          A.EP_BEG LE REV_DT LE A.EP_END ;
QUIT ;
%end;
%else %do;
PROC SQL ;
    CREATE TABLE OUTPATIENT AS
    SELECT A.*, B. *
    FROM EPI_DOD AS A, REC&ref..OUTPATIENT_&bl._&ds. AS B
    WHERE A.BENE_ID = B.BENE_ID AND
          A.EP_ID =  B.EP_ID AND
          A.EP_BEG LE FROM_DT LE A.EP_END ;
QUIT ;
%end;


**** Identify ER claims **** ;
DATA CLMS ER ;
    set OUTPATIENT(WHERE = (NOPAY_CD = "  ")) ;
	if 	REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 ; 
    ALLOWED = REVPMT ;
    STD_PAY = CLM_REV_STD_PYMT_AMT/.98 ;
	IF STD_PAY = . THEN STD_PAY = ALLOWED/.98 ;
    **** Initializing Service Category **** ;
    FORMAT SERVICE_CAT $50.; length SERVICE_CAT $50. ;
    SERVICE_CAT = "    " ;

            OP_CAH = 0 ;
        IF ('0001' LE SUBSTR(PROVIDER,3,4) LE '0879') OR
           ('1300' LE SUBSTR(PROVIDER,3,4) LE '1399') THEN OP_CAH = 1 ;

        *** 5/10/17 - remove lines where rev_cntr = 0001 *** ;
        if rev_cntr = "0001" then delete ;

        *** 5/31/17 - Using OCM identification of ED and OBS, Not Milliman algorithm *** ;
        er_pre=0 ; OBS_PRE=0 ;
                IF '0450' LE REV_CNTR LE '0459' OR REV_CNTR = '0981' THEN DO ;
                        *IF SUM(REVPMT,PTNTRESP) > 0 THEN DO ;
                            ER_pre = 1 ;
                            IF "70000" LE HCPCS_CD LE "89999" OR
                                HCPCS_CD IN ('G0106','G0120','G0122','G0130','G0202','G0204','G0206','G0219',
                                             'G0235','G0252','G0255','G0288','G0389','S8035','S8037','S8040',
                                             'S8042','S8080','S8085','S8092','S9024') THEN ER_pre = 0 ;
                        *END ;
                END ;

                IF REV_CNTR = '0762' OR
                  (REV_CNTR = '0760' AND HCPCS_CD = "G0378" AND REV_UNIT GE 8) THEN DO ;
                        *IF SUM(REVPMT,PTNTRESP) > 0 THEN DO ;
                            OBS_PRE = 1 ;
                    *END ;
                END ;

        IF 	REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 and SUM(ER_PRE, OBS_PRE) > 0 THEN OUTPUT ER ;
        OUTPUT CLMS ;

proc sort data=er ; by bene_id EP_ID clm_id ;
data er ;
	set er ; by bene_id EP_ID clm_id ;
	er_pay = (std_pay>0)*er_pre;
	obs_pay = (std_pay>0)*obs_pre ;

proc means data=er noprint max ; by bene_id EP_ID clm_id ;
    var er_pre obs_pre er_pay obs_pay;
    output out=erclms (drop = _type_ _freq_)
           max() = ;
run ;

proc sort data=clms ; by bene_id EP_ID clm_id ;

DATA OP ;
    merge clms(in=a drop=er_pre obs_pre )
          erclms(in=b keep=bene_id ep_id clm_id er_pre obs_pre er_pay obs_pay);
    by bene_id EP_ID clm_id ;
    if a ;
    IF A AND B THEN ERCLAIM = 1 ;

PROC SQL ;
    CREATE TABLE OP2 AS
    SELECT A.*, B.BETOS
    FROM OP AS A LEFT JOIN &IN_BETOS. AS B
    ON A.HCPCS_CD = B.HCPCS_CD ;
QUIT ;

proc sort data=IN&ref..outhdr&tu._&ds. OUT=op_h ; by  EP_ID BENE_ID CLM_ID ; run ;
proc sort data=IN&ref..outval&tu._&ds. (where=(val_cd='17')) OUT=op_v ; by  EP_ID BENE_ID CLM_ID ; run ;

data OP_val;
		merge op_h(in=a) op_v(in=b) ; 
		by  EP_ID BENE_ID CLM_ID ; 
		if a and b ;
run;
proc sql ;
    create table OP_val2 as
    select b.*, a.*
    from epi_dod as a, OP_val as b
    where a.EP_id=b.EP_id and
          a.ep_beg le B.FROM_DT le a.ep_end ;
quit ;
data OP3;
	format rev_cntr $20.;
	set OP_val2;

	REV_DT = FROM_DT;
	rev_cntr = 'Outpatient Outlier';
	ALLOWED = VAL_AMT ;
    STD_PAY = CLM_STD_OUTLIER_PYMT_AMT/.98 ;
	IF STD_PAY = . THEN STD_PAY = ALLOWED/.98 ;
run;

data REC&ref..SC_op_&bl._&ds. ;
	format rev_cntr $20.;
    SET OP2 
		%if "&ref." ^= "1" AND "&ref." ^= "2" %then %do; OP3 %end; 
		;

        *** Radiation Oncology Expenses *** ;
		%if "&ref." ^= "1" AND "&ref." ^= "2" %then %do;
	        if put(hcpcs_cd,$RadTher_CPT.) = "Y" then RADTHER = 1 ;
	        ARRAY v1 (X) ICD_prcdr_VRSN_CD1-ICD_prcdr_VRSN_CD25 ;
	        ARRAY d1 (X) ICD_prcdr_CD1-ICD_prcdr_CD25 ;
	        DO X = 1 TO DIM(D1) ;
	            if v1 = "9" and put(d1,$RadTher_ICD9_.) = "Y" then RADTHER = 1 ;
	            if v1 = "0" and put(d1,$RadTher_ICD10_.) = "Y" then RADTHER = 1 ;
	        END ;
		%end;
		%else %do;
			if put(hcpcs_cd,$RadTher_CPT2p.) = "Y" then RADTHER = 1 ;
	        ARRAY v1 (X) ICD_prcdr_VRSN_CD1-ICD_prcdr_VRSN_CD25 ;
	        ARRAY d1 (X) ICD_prcdr_CD1-ICD_prcdr_CD25 ;
	        DO X = 1 TO DIM(D1) ;
	            if v1 = "9" and put(d1,$RadTher_ICD9_2p.) = "Y" then RADTHER = 1 ;
	            if v1 = "0" and put(d1,$RadTher_ICD10_2p.) = "Y" then RADTHER = 1 ;
	        END ;
		%end;
		
        IF obs_pre > 0 then DO ;
            SERVICE_CAT = "Observation" ;
            EXP_OBS = STD_PAY;
        END ;
        else if er_pre > 0 then DO ;
            SERVICE_CAT = "Emergency Room" ;
            EXP_ER = STD_PAY;
        END ;
        ELSE IF RADTHER = 1 THEN DO ;
            SERVICE_CAT = "Radiation Oncology" ;
            EXP_RAD = STD_PAY ;
        END ;
        *** Format in 000_Formats_Predict_Flags PP1 Recon.sas *** ;
        ELSE IF PUT(HCPCS_CD,$ANCCPT1p.) = 'Y' THEN DO ;
            SERVICE_CAT = "Ancillary" ;
            EXP_ANC = STD_PAY;
        END ;
        ELSE IF BETOS IN ('O1C','O1D','O1E','O1G','D1G') THEN DO ;
            SERVICE_CAT = "Part B Drugs" ;
            EXP_PB = STD_PAY ;
        END ;
        ELSE DO ;
            SERVICE_CAT = "Outatient Other" ;
            EXP_OUT_OTH = STD_PAY;
        END ;
RUN ;


%MEND OP ;


**************************************************************************************
************************** PB,DME COST MODEL LOGIC ***********************************
************************************************************************************** ;

%MACRO pb ;

%MEOS(in&ref..phymeosline&tu._&ds.,epi_dod,REC&REF..phyline&tu._lmeos_&ds.,REC&ref..meos&tu._&ds.) ;
**** Note to analyst: Check that the records counts of the work file MEOS are the same as
     out.meos_&ds.  We should not lose any MEOS claims in this process. **** ;

DATA HEADER(KEEP = EP_ID CLM_ID BENE_ID FROM_DT THRU_DT) ;
    set in&ref..phymeosHDR&tu._&ds.(in=p) in&ref..dmeHDR&tu._&ds.(in=d)  ;

DATA LINES ;
    set REC&REF..phyline&tu._lmeos_&ds.(in=p) in&ref..dmeline&tu._&ds.(in=d)  ;
        if p then prof = 1 ;
        if d then dme = 1 ;

PROC SORT DATA=LINES ; BY EP_ID BENE_ID CLM_ID THRU_DT ;
PROC SORT DATA=HEADER ; BY EP_ID BENE_ID CLM_ID THRU_dT ;

DATA LINES1 ;
    MERGE LINES(IN=A) HEADER(IN=B) ; BY EP_ID BENE_ID CLM_ID THRU_DT ;
    IF A AND B ;

%if "&ref." ^= "1" AND "&ref." ^= "2" %then %do;
proc sql ;
    create table lines2 as
    select a.*, b.*
    from epi_dod as a, lines1 as b
    where a.EP_id=b.EP_id and
          a.ep_beg le B.EXPNSDT1 le a.ep_end ;
quit ;
%end;
%else %do;
proc sql ;
    create table lines2 as
    select a.*, b.*
    from epi_dod as a, lines1 as b
    where a.EP_id=b.EP_id and
          a.ep_beg le B.FROM_DT le a.ep_end ;
quit ;
%end;

**** Identify ER claims **** ;
data REC&ref..SC_PB_&bl._&ds.  ;
    set lines2 rEC&ref..meos&tu._&ds. ;

    if LALOWCHG > 0 ;  *** REMOVAL OF DENIED CLAIMS **** ;
    allowed = LINEPMT ;
    STD_PAY = CLM_LINE_STD_PYMT_AMT/.98 ;
	IF STD_PAY = . THEN STD_PAY = ALLOWED/.98 ;

    *** Radiation Oncology Expenses *** ;
	%if "&ref." ^= "1" AND "&ref." ^= "2" %then %do;
    	if put(hcpcs_cd,$RadTher_CPT.) = "Y" then RADTHER = 1 ;
	%end;
	%else %do;
		if put(hcpcs_cd,$RadTher_CPT2p.) = "Y" then RADTHER = 1 ;
	%end;

    **** Initializing Service Category **** ;
    FORMAT SERVICE_CAT $50.; length SERVICE_CAT $50. ;
    SERVICE_CAT = "    " ;

    IF HCPCS_CD = "G9678" then do ;
		IF TAX_NUM IN (&ATT_TIN.) THEN DO ;
        	SERVICE_CAT = "MEOS" ;
        	EXP_MEOS = STD_PAY ;
		END ;
		ELSE DELETE ;
    END ;
    ELSE IF RADTHER = 1 THEN DO ;
        SERVICE_CAT = "Radiation Oncology" ;
        EXP_RAD = STD_PAY;
    END ;
    *** Format in 000_Formats_Predict_Flags PP1 Recon.sas *** ;
    ELSE IF PUT(HCPCS_CD,$ANCCPT1p.) = 'Y' THEN DO ;
        SERVICE_CAT = "Ancillary" ;
        EXP_ANC = STD_PAY ;
    END ;
    ELSE IF BETOS IN ('O1C','O1D','O1E','O1G','D1G') THEN DO ;
        SERVICE_CAT = "Part B Drugs" ;
        EXP_PB = STD_PAY;
    END ;
    ELSE IF PROF = 1 THEN DO ;
        SERVICE_CAT = "Physician" ;
        EXP_PHYS =  STD_PAY ;
    END ;
    ELSE DO ;
        SERVICE_CAT = "DME Excl Drugs" ;
        EXP_DME = STD_PAY;
    END ;

%mend pb ;

**************************************************************************************
********************* File Based Assignments, Part D *********************************
************************************************************************************** ;
%macro oth ;

proc sql ;
    create table snf as
    select a.*
    from in&ref..SNFHDR&tu._&ds. as a, epi_dod as b
    where a.bene_id=b.bene_id and
          a.ep_id=b.ep_id and
          ep_beg le ADMSN_DT le ep_end ;
quit ;

DATA REC&ref..SC_snf_&bl._&ds. ;
    SET snf (where = (nopay_cd="  ")) ;
    ALLOWED = PMT_AMT ;
    FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
    SERVICE_CAT = "SNF" ;
    EXP_SNFC = CLM_STD_PYMT_AMT/.98 ;
    STD_PAY = CLM_STD_PYMT_AMT/.98 ;
	IF STD_PAY = . THEN do ;
		STD_PAY = ALLOWED/.98 ;
		EXP_SNFC = STD_PAY ;
	END ;

proc sql ;
    create table hha as
    select a.*
    from in&ref..hhahdr&tu._&ds. as a, epi_dod as b
    where a.bene_id=b.bene_id and
          a.ep_id=b.ep_id and
          ep_beg le from_dt le ep_end ;
quit ;

 DATA REC&ref..SC_hha_&bl._&ds.;
    set hha(where = (nopay_cd="  ")) ;
    ALLOWED = PMT_AMT ;
    FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
    SERVICE_CAT = "Home Health" ;
    EXP_HH = CLM_STD_PYMT_AMT/.98 ;
    STD_PAY = CLM_STD_PYMT_AMT/.98 ;
	IF STD_PAY = . THEN DO ;
		STD_PAY = ALLOWED/.98 ;
		EXP_HH = STD_PAY ;
	END ;

*********************************************************************** ;
    **************** Hospice Metrics *************** ;
*********************************************************************** ;

*** 5/15/17 Capturing Facility and Non-Facility Flags **** ;

proc sort data=in&ref..HSPHDR&tu._&DS.   out=hosp1 ; by ep_id BENE_ID clm_id thru_dt ;
proc sort data=in&ref..hspREV&tu._&ds.   out=hrev1 ; by ep_id BENE_ID clm_id thru_dt ;

data hspcodes ;
    merge hrev1(in=a) hosp1(in=b keep = ep_id BENE_ID clm_id from_dt thru_dt) ; by ep_id BENE_ID clm_id thru_dt ;
    if a and b ;
    IF HCPCS_CD IN ('Q5003','Q5004','Q5005','Q5006','Q5007','Q5008','Q5010',
                    'Q5001','Q5002') ;
    IF HCPCS_CD IN ('Q5003','Q5004','Q5005','Q5006','Q5007','Q5008','Q5010') THEN HSP_FAC = 1 ;
    ELSE HSP_FAC = 0 ;

    IF HCPCS_CD IN ('Q5001','Q5002') THEN HSP_HOME = 1 ; ELSE HSP_HOME = 0 ;

PROC SQL ;
    CREATE TABLE HSPCODES_A  AS
    SELECT A.*, B.*
    FROM EPI_DOD AS A, HSPCODES AS B
    WHERE A.EP_ID=B.EP_ID AND
    EP_BEG LE from_dt LE EP_END ;
QUIT ;

DATA HSPCODES2 ;
    SET HSPCODES_A ;
        FORMAT WIN_30_DOD MMDDYY10. ;
        WIN_30_DOD = INTNX('DAY',DOD, -29, 'SAME') ;
            IF (WIN_30_DOD LE REV_DT LE DOD) THEN DO ;
                HOSP_30DAYS = 1 ;
                HSP_FAC_30 = HSP_FAC ;
                HSP_HOME_30 = HSP_HOME ;
            END ;

PROC SORT DATA=HSPCODES2 ; BY BENE_ID EP_ID CLM_ID THRU_DT ;

PROC MEANS DATA=HSPCODES2 NOPRINT MAX ; by bene_id EP_ID CLM_ID THRU_DT ;
    VAR HOSP_30DAYS HSP_FAC HSP_HOME HSP_FAC_30 HSP_HOME_30 ;
    OUTPUT OUT=HSP_FLAGS (DROP = _TYPE_ _FREQ_)
           MAX() = ;

PROC SQL ;
    CREATE TABLE HOSP1_A AS
    SELECT A.*, B. *
    FROM EPI_DOD AS A, HOSP1 AS B
    WHERE A.EP_ID=B.EP_ID AND
          EP_BEG LE FROM_DT LE EP_END ;
QUIT ;

PROC SORT DATA=hosp1_A ; by bene_id EP_ID clm_id thru_dt ;
data hosp2  ;
    merge hosp1_a(in=a) hsp_flags(IN=B) ; by bene_id EP_ID clm_id thru_dt ;
    IF A ;
    IF A AND B=0 THEN DO ;
        HSP_FAC=0 ; HSP_HOME = 0 ;
    END ;
    IF NOPAY_CD = "  "  then do ;
        ANY_HSP_BOTH = 0 ; ANY_HSP_FAC = 0 ; ANY_HSP_HOME = 0 ; ANY_HSP_UNK = 0 ;
        IF HOSP_30DAYS = 1 THEN DO ;
                IF HSP_FAC_30 = 1 AND HSP_HOME_30 = 1 THEN ANY_HSP_BOTH = 1 ;
                ELSE IF HSP_FAC_30 = 1 THEN ANY_HSP_FAC = 1 ;
                ELSE IF HSP_HOME_30 = 1 THEN ANY_HSP_HOME = 1 ;
                ELSE ANY_HSP_UNK = 1 ;
		END ;
    END ;

**** 5/15/17: Looking at care in 90, 30, and 3 days within date of death  ****** ;
    IF DOD NE . AND FROM_DT GE EP_BEG THEN DO ;
        FORMAT WIN_90_DOD WIN_30_DOD MMDDYY10. ;
        WIN_90_DOD = INTNX('DAY',DOD, -89, 'SAME') ;
        WIN_30_DOD = INTNX('DAY',DOD, -29, 'SAME') ;
            IF (WIN_90_DOD LE FROM_DT LE DOD) OR
               (WIN_90_DOD LE THRU_DT LE DOD)   THEN DO ;
                HOSP_DAYS_90 = SUM((THRU_DT - MAX(FROM_DT,WIN_90_DOD)),1) ;
            END ;
    END ;

*** 5/4/2017 - Updated to roll Hospice claims up to period, not  claim level. *** ;
PROC SORT DATA=hosp2 OUT=HOSPICE ; BY BENE_ID EP_ID PROVIDER FROM_DT THRU_DT ;

DATA  HOSPICE2;
    SET HOSPICE ; BY BENE_ID EP_ID PROVIDER FROM_DT THRU_DT ;
    FORMAT PREV_THRU MMDDYY10. ;
    IF FIRST.PROVIDER THEN DO ; STAY = 1 ; PREV_THRU = THRU_DT ; END ;
    ELSE DO ;
        IF PREV_THRU NE . AND 0 LE (FROM_DT-PREV_THRU) LE 1 THEN STAY =STAY ;
        ELSE STAY = SUM(STAY,1) ;
        PREV_THRU = THRU_DT ;
    END ;
    RETAIN PREV_THRU STAY ;

    FAC_PMT_AMT = PMT_AMT * HSP_FAC ;
    HOME_PMT_AMT = PMT_AMT * HSP_HOME ;
    IF HSP_FAC = 1 AND HSP_HOME = 1 THEN DO ;
        FAC_PMT_AMT = 0 ; HOME_PMT_AMT = 0 ; BOTH_PMT_AMT = PMT_AMT ;
    END ;

	IF CLM_STD_PYMT_AMT = . THEN CLM_STD_PYMT_AMT = PMT_AMT ;

PROC SORT DATA=HOSPICE2 ; BY BENE_ID EP_ID PROVIDER STAY FROM_DT THRU_DT ;

DATA HSP_CHAR(DROP = PMT_AMT CLM_STD_PYMT_AMT FROM_DT ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME ANY_HSP_UNK HOSP_30DAYS
                     FAC_PMT_AMT HOME_PMT_AMT BOTH_PMT_AMT HOSP_DAYS_90 EP_BEG EP_END ) ;
    SET HOSPICE2 ;BY BENE_ID EP_ID PROVIDER STAY ;
    IF LAST.STAY ;

PROC MEANS DATA =HOSPICE2 NOPRINT MIN MAX SUM ; BY BENE_ID EP_ID PROVIDER STAY ;
    VAR FROM_DT ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME ANY_HSP_UNK HOSP_30DAYS
        PMT_AMT CLM_STD_PYMT_AMT FAC_PMT_AMT HOME_PMT_AMT BOTH_PMT_AMT HOSP_DAYS_90 ;
    OUTPUT OUT=HSP_CLAIMS (DROP = _TYPE_ _FREQ_)
           min(FROM_DT) =
           MAX(ANY_HSP_BOTH ANY_HSP_FAC ANY_HSP_HOME ANY_HSP_UNK HOSP_30DAYS) =
           SUM(PMT_AMT CLM_STD_PYMT_AMT FAC_PMT_AMT HOME_PMT_AMT BOTH_PMT_AMT HOSP_DAYS_90) = ;
data SC_hsp_&bl._&ds. ;
    MERGE HSP_CHAR(IN=A) HSP_CLAIMS(IN=B) ; BY BENE_ID EP_ID PROVIDER stay ;
    IF A AND B ;
    FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
    SERVICE_CAT = "Hospice" ;
    ALLOWED = PMT_AMT ;
    EXP_HOSPICE = CLM_STD_PYMT_AMT/.98 ;
    STD_PAY = CLM_STD_PYMT_AMT/.98 ;

**** Accounting for same day transfers for day counts **** ;
proc sort data=SC_hsp_&bl._&ds. ; by bene_id EP_ID FROM_DT THRU_DT ;
DATA REC&ref..SC_hsp_&bl._&ds. ;
    SET SC_hsp_&bl._&ds. ;by bene_id EP_ID FROM_DT THRU_DT ;
    IF FIRST.ep_ID THEN DO ;
        PT = THRU_DT ;
    END ;
    ELSE DO ;
        IF FROM_DT = PT THEN DO ;
            HOSP_DAYS_90 = HOSP_DAYS_90-1 ;
            CHANGED = 1 ;
        END ;
        PT = THRU_DT ;
    END ;
    RETAIN PT ;

*** This measure needs to be flagged after roll up has occurred. *** ;
*** OCM-3 SPECS: Hospice stays are identified in the Medicare Enrollment Data Base (EDB) by:
1. Beneficiary has at least one Hospice record in the Medicare EDB AND
2. Most recent Hospice End Date is blank OR most recent Hospice End Date = Date of Death AND
3. Date of Death minus Most Recent Hospice Beginning Date = 3.*** ;
PROC SORT DATA=REC&ref..SC_hsp_&bl._&ds. OUT=sch; BY BENE_ID EP_ID FROM_DT thru_dt ;

data new_sch ;
	set sch ; by bene_id ep_id from_dt thru_dt ;
	if first.ep_id then do ;
		hsp_case_temp = 1 ;
		pthru = thru_dt ;
		pcase = hsp_case_temp ;
	end ;
	else do ;
		if from_dt le pthru+1 then hsp_case_temp = pcase ;
		else hsp_case_temp = pcase+1 ;
		pthru = thru_dt ;
		pcase = hsp_case_temp ;
	end ;
	retain pthru pcase ;

proc sort data=new_sch ; by bene_id ep_id hsp_case_temp ;
proc means data=new_sch noprint min max ; by bene_id ep_id hsp_case_temp ;
	id dod ;
	var from_dt thru_dt ;
	output out=new_sch2(drop = _type_ _freq_)
		   min(from_dt) = from_dt 
		   max(thru_dt) = thru_dt ;

proc sort data=new_sch2 ; by bene_id ep_id from_dt ;
DATA LATEST ;
    SET new_SCH2 ; BY BENE_ID EP_ID from_dt ;
    IF last.ep_id and DOD NE . ;
    IF (THRU_DT = . OR THRU_DT GE DOD) AND  (DOD-FROM_DT GE 3) THEN HOSP_3DAY = 1 ;
    ELSE HOSP_3DAY = 0 ;

PROC SORT DATA=LATEST ; BY BENE_ID EP_ID ;
PROC MEANS DATA=LATEST NOPRINT MAX ; BY BENE_ID EP_ID ;
    VAR HOSP_3DAY ;
    OUTPUT OUT=OCM3(DROP = _TYPE_ _FREQ_)
           Max() = ;

PROC SQL ;
    CREATE TABLE PDE AS
    SELECT A.*, b.cancer_type
    FROM IN&ref..PDE&tu._&ds. AS A, EPI_DOD AS B
    WHERE A.BENE_ID=B.BENE_ID AND
          A.EP_ID=B.EP_ID AND
          EP_BEG LE SRVC_DT LE EP_END ;
QUIT ;

data REC&ref..SC_pde_&bl._&ds.  ;
    set PDE  ;
    ALLOWED = SUM(LICS_AMT,(.8*GDC_ABV_OOPT_AMT)) ;
    FORMAT SERVICE_CAT $50. ;  LENGTH SERVICE_CAT $50. ;
    SERVICE_CAT = "Part D Drugs" ;
    EXP_PDE = ALLOWED ;
    STD_PAY = ALLOWED ;

%mend oth ;


**************************************************************************** ;
**************************************************************************** ;
**************************************************************************** ;

%IP ;
%OP ;
%PB ;
%oth ;*** Note: OCM3 is created in this macro so will always need to be run. *** ;


**************************************************************************** ;
***************** Creating Episode Level Flags ***************************** ;
**************************************************************************** ;
proc sort data=REC&ref..epi_prelim_&bl._&ds.
    out=epi_ct(keep = bene_id ep_beg ep_end ep_id DOB DOD CANCER_TYPE %if &vers. ne R0 %then %do; Prior_Changed_Episode where = (Prior_Changed_Episode ne "Yes") %end; ) ; by BENE_ID ep_id ;

data ALL_CLAIMS_&bl._&DS.(drop=ep_beg ep_end DOD) ;
	format rev_cntr $20.;
    set REC&ref..SC_ip_&bl._&ds.(IN=G)
        REC&ref..SC_OP_&bl._&ds.(IN=A)
        REC&ref..SC_PB_&bl._&ds. (IN=B)
        REC&ref..SC_PDE_&bl._&ds.(IN=C)
        REC&ref..SC_hsp_&bl._&ds.(IN=D)
        REC&ref..SC_hha_&bl._&ds(IN=E)
        REC&ref..SC_snf_&bl._&ds.(IN=F);
        OCM_ID = "&id." ;

        CLAIM_ID = CLM_ID ;
		

        IF B THEN SRC = "PB/DME" ;
        IF G THEN SRC = "IP" ;
        IF A THEN SRC = "OP" ;
        IF C THEN SRC = "PD" ;
        IF D THEN SRC = "HSP" ;
        IF E THEN SRC = "HHA" ;
        IF F THEN SRC = "SNF" ;

        FORMAT START_DATE END_DATE ADMIT_DT DSCHRG_DT PART_D_SERVICE_DATE MMDDYY10. ;
        IF G OR F THEN DO ;
                  START_DATE = ADMSN_DT ;
                  END_DATE = DSCHRGDT ;
        END ;
        ELSE IF D OR E THEN DO ;
                  START_DATE = FROM_DT ;
                  END_DATE = THRU_DT ;
        END ;

        ELSE IF A THEN DO ;
                  START_DATE = REV_DT ;
                  END_DATE = REV_DT ;
        END ;

        ELSE IF B THEN DO ;
                    START_DATE = EXPNSDT1 ;
                    END_DATE = EXPNSDT1 ;
        END ;

        IF G OR F THEN DO ;
                ADMIT_DT = ADMSN_DT ;
                DSCHRG_DT = DSCHRGDT ;

        END ;
        *** 5/4/17: LOS to use UTIL_DAY when available. *** ;
        if B OR A OR C OR D OR E THEN LOS = MAX((END_DATE-START_DATE),1) ;
        IF G OR F THEN LOS = UTIL_DAY ;

        IF G OR A OR D OR E OR F THEN PRVDR_NUM = PROVIDER ;
        *** AT_NPI already in data *** ;
        *** OP_NPI already in data *** ;
        *** DRG_CD already in data *** ;
        *** PRFNPI already in data *** ;
        IF DME = 1 THEN PRFNPI = SUP_NPI ;
        ADMIT_DIAG_CD = ADMTG_DGNS_CD ;
        PRINCIPAL_DIAG_CD = PRNCPAL_DGNS_CD ;
        IF B THEN PRINCIPAL_DIAG_CD = LINE_ICD_DGNS_CD ;
        PROCEDURE_CD_VER = ICD_PRCDR_VRSN_CD1 ;
        PROCEDURE_CD = ICD_PRCDR_CD1 ;
        IF C THEN DO ;
            NDC = PROD_SRVC_ID ;
            PART_D_SERVICE_DATE = SRVC_DT ;
            DAYS_SUPPLY = DAYS_SUPLY_NUM ;
        END ;
        FORMAT DATE_SCREEN MMDDYY10. ;
        DATE_SCREEN = MAX(START_DATE,PART_D_SERVICE_DATE) ;

proc sort data=ALL_CLAIMS_&bl._&DS. ; by bene_id ep_id;

data t0 all_other ;
    merge ALL_CLAIMS_&bl._&DS.(in=a ) epi_ct(in=b) ; by bene_id EP_ID ;
    if a and b ;

        *** Novel Therapy Flag *** ;
		FORMAT DATE_USE_NT MMDDYY10. ;
		DATE_USE_NT = FROM_DT ;
        FORMAT NOVEL_THERAPY $3. ;
        LENGTH NOVEL_THERAPY $3. ;
		BLAD_LR = 0 ; PROST_CAST = 0 ; BLAD_OTH = 0 ; PROST_OTH = 0 ;
		BC_HORMONAL = 0 ; NONHORMONAL = 0 ; 

        NOVEL_THERAPY = "NO" ;
        *IF IDENDC NE "  " THEN NDC9 = SUBSTR(IDENDC,1,9) ;  *** Outpatient revenue NDC indicator *** ;
        *IF LNNDCCD NE " " THEN NDC9 = SUBSTR(LNNDCCD,1,9) ; *** DME NDC indicator *** ;
        IF PROD_SRVC_ID NE "  " THEN ndc9 = substr(prod_srvc_id,1,9) ;

		if 
			%if "&ref." = "1" %then %do ;
				(put(NDC9,$Chemo_NDC.)="Y" OR put(NDC9,$Chemo_NDC2p.)="Y" OR put(NDC9,$Chemo_NDC3p.)="Y" OR put(NDC9,$Chemo_NDC4p.)="Y" OR put(NDC9,$Chemo_NDC5p.)="Y")
			%end ;
			%if "&ref." = "2" %then %do ;
				(put(NDC9,$Chemo_NDC2p.)="Y" OR put(NDC9,$Chemo_NDC3p.)="Y" OR put(NDC9,$Chemo_NDC4p.)="Y" OR put(NDC9,$Chemo_NDC5p.)="Y")
			%end ;
			%if "&ref." = "3" %then %do ;
				(put(NDC9,$Chemo_NDC3p.)="Y" OR put(NDC9,$Chemo_NDC4p.)="Y" OR put(NDC9,$Chemo_NDC5p.)="Y")
			%end ;
				then do;
			IF PUT(NDC9,$Bladder_LR_NDC.) = "Y" THEN BLAD_LR = 1 ;
			IF PUT(NDC9,$Prostate_CS_NDC.) = "Y" THEN PROST_CAST = 1 ;
			IF BLAD_LR NE 1 THEN BLAD_OTH = 1 ;
			IF PROST_CAST NE 1 THEN PROST_OTH = 1 ;
			if put(NDC9, $Hormonal_breast_NDC.) = "Y" then BC_Hormonal = 1 ; else BC_Hormonal = 0 ;
			if put(NDC9, $Hormonal_breast_NDC.) = "N" then Nonhormonal = 1 ; else Nonhormonal = 0 ;
		END ;

		CANCER_TYPE_MILLIMAN = CANCER_TYPE ;  *** OVERRRIDE NECESSARY FOR NT MACRO *** ;
        %NT ;
        DROP CANCER_TYPE_MILLIMAN ;

		if 
			%if "&ref." = "1" %then %do ;
				(put(HCPCS_CD,$Chemo_J.)="Y" OR put(HCPCS_CD,$Chemo_J2p.)="Y" OR put(HCPCS_CD,$Chemo_J3p.)="Y" OR put(HCPCS_CD,$Chemo_J4p.)="Y" OR put(HCPCS_CD,$Chemo_J5p.)="Y")
			%end ;
			%if "&ref." = "2" %then %do ;
				(put(HCPCS_CD,$Chemo_J2p.)="Y" OR put(HCPCS_CD,$Chemo_J3p.)="Y" OR put(HCPCS_CD,$Chemo_J4p.)="Y" OR put(HCPCS_CD,$Chemo_J5p.)="Y")
			%end ;
			%if "&ref." = "3" %then %do ;
				(put(HCPCS_CD,$Chemo_J3p.)="Y" OR put(HCPCS_CD,$Chemo_J4p.)="Y" OR put(HCPCS_CD,$Chemo_J5p.)="Y")
			%end ;
				then do;
			IF PUT(HCPCS_CD,$Bladder_LR_HCPCS.) = "Y" THEN BLAD_LR = 1 ;
			IF PUT(HCPCS_CD,$Prostate_CS_HCPCS.) = "Y" THEN PROST_CAST = 1 ;
			IF BLAD_LR NE 1 THEN BLAD_OTH = 1 ;
			IF PROST_CAST NE 1 THEN PROST_OTH = 1 ;
			BC_Hormonal = 0 ;
			Nonhormonal = 1 ; 
		END ;


        IF SRC = "OP" THEN DO ;
                *** OCM2 - Identification of ED/OBS Visits *** ;
                IF '0450' LE REV_CNTR LE '0459' OR REV_CNTR = '0981' THEN DO ;
                        IF 	REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 THEN DO ;
                            ED_OCM2 = 1 ;
                            IF "70000" LE HCPCS_CD LE "89999" OR
                                HCPCS_CD IN ('G0106','G0120','G0122','G0130','G0202','G0204','G0206','G0219',
                                             'G0235','G0252','G0255','G0288','G0389','S8035','S8037','S8040',
                                             'S8042','S8080','S8085','S8092','S9024') THEN ED_OCM2 = 0 ;
                        END ;
                END ;

                IF REV_CNTR = '0762' OR
                  (REV_CNTR = '0760' AND HCPCS_CD = "G0378" AND REV_UNIT GE 8) THEN DO ;
                        IF 	REV_CNTR_TOT_CHRG_AMT - REV_CNTR_NCVRD_CHRG_AMT > 0 THEN DO ;
                            OBS_OCM2 = 1 ;
                        END ;
                END ;
        END ;

        NDC9 = substr(prod_srvc_id,1,9) ;
        NDC8 = substr(prod_srvc_id,1,8) ;
        IF (SRC IN ("OP","PB/DME") AND 		
			/*%if "&ref." = "1" %then %do ; put(HCPCS_CD,$Chemo_J.) = "Y" %end ;
	   		%if "&ref." = "2" %then %do ; put(HCPCS_CD,$Chemo_J2p.) = "Y" %end ;   
	   		%if "&ref." = "3" %then %do ; put(HCPCS_CD,$Chemo_J3p.) = "Y" %end ;*/
			(put(HCPCS_CD,$Chemo_J.)="Y" OR put(HCPCS_CD,$Chemo_J2p.)="Y" OR put(HCPCS_CD,$Chemo_J3p.)="Y"))   OR
           (SRC = "PD" AND 
			/*%if "&ref." = "1" %then %do ; (put(NDC9, $Chemo_NDC.) = "Y" or NDC8 = '00780645')  %end ;
	   		%if "&ref." = "2" %then %do ; put(NDC9, $Chemo_NDC2p.) = "Y" %end ;
	   		%if "&ref." = "3" %then %do ; put(NDC9, $Chemo_NDC3p.) = "Y" %end ;*/
			(put(NDC9, $Chemo_NDC.)="Y" OR put(NDC9, $Chemo_NDC2p.)="Y" OR put(NDC9, $Chemo_NDC3p.)="Y"))
			THEN CHEMO_FLAG = 1 ;

        IF DOD NE . THEN DO ;
                *** Add 1 day to include the day of DOD *** ;
                WIN_14_DOD = INTNX('DAY',DOD,-13,'SAME') ;
                IF (WIN_14_DOD LE DATE_SCREEN LE DOD) AND
                   CHEMO_FLAG = 1 THEN CHEMO_DEATH14 = 1 ;
        END ;


		if ndc9 ne "  " or chemo_flag = 1 then output t0 ;
		else output all_other ;


%NT_COMBO ;

data t5 ;
	merge t0(in=a) t2(in=b) ; by bene_id ep_id ;
	if a ;
	if a and b and  NOVEL_THERAPYe = "YES" then do ;
		%NT2 ;
	end ;

data ALL_CLAIMS2 OCM2_CHK I1   ;
	set t5 all_other ;

	IF NOVEL_THERAPY = "YES" THEN NT_MILL = STD_PAY ;
		
        IF ED_OCM2 =1 OR OBS_OCM2 = 1 THEN OUTPUT OCM2_CHK ;
        IF SRC = "IP" THEN OUTPUT I1 ;
        output ALL_CLAIMS2  ;

*** OCM2 - Seeing whether ED and OBS led to admission *** ;

PROC SQL ;
    CREATE TABLE WADMIT AS
    SELECT A.BENE_ID, A.EP_ID, A.CLM_ID, A.ED_OCM2, A.OBS_OCM2, A.THRU_DT
    FROM OCM2_CHK AS A, REC&ref..inpatient_&bl._&ds. AS B
    WHERE A.BENE_ID = B.BENE_ID AND A.EP_ID =B.EP_ID AND A.THRU_DT = B.ADMSN_DT ;

PROC SORT DATA=WADMIT ; BY BENE_ID EP_ID CLM_ID THRU_DT ;
PROC MEANS DATA=WADMIT NOPRINT MAX ; BY BENE_ID EP_ID CLM_ID THRU_DT ;
    VAR ED_OCM2 OBS_OCM2 ;
    OUTPUT OUT=WADMIT2 (DROP=_TYPE_ _FREQ_)
           MAX() = ;

PROC SORT DATA=OCM2_CHK ; BY BENE_ID EP_ID CLM_ID THRU_DT ;
PROC SORT DATA=ALL_CLAIMS2 ; BY BENE_ID EP_ID CLM_ID THRU_DT ;

    DATA O2 ;
    MERGE OCM2_CHK(IN=A) WADMIT2(IN=B DROP=ED_OCM2 OBS_OCM2) ; BY BENE_ID EP_ID CLM_ID THRU_DT ;
    IF A ;
    IF A AND B THEN RESULT_IN_ADMIT = 1 ;
               ELSE RESULT_IN_ADMIT = 0 ;


PROC MEANS DATA=O2 NOPRINT MAX ; BY BENE_ID EP_ID CLM_ID THRU_DT ;
    VAR ED_OCM2 OBS_OCM2 RESULT_IN_ADMIT ;
    OUTPUT OUT=EDOBS (DROP = _TYPE_ _FREQ_)
           MAX() = ;

DATA ALL_CLAIMS3 ;
    MERGE ALL_CLAIMS2(IN=A DROP=ED_OCM2 OBS_OCM2) EDOBS(IN=B) ; BY BENE_ID EP_ID CLM_ID THRU_DT ;
    IF A ;
    IF SUM(ED_OCM2,OBS_OCM2) > 0 AND RESULT_IN_ADMIT NE 1 THEN OCM2 = 1 ;


PROC SORT DATA=ALL_CLAIMS3 OUT= REC&ref..ALL_CLAIMS_&bl._&DS.  ; BY bene_ID EP_ID ;


proc means data=REC&ref..ALL_CLAIMS_&bl._&DS.    noprint max sum ; by bene_id  EP_ID ;
    var EX1 OCM2
        ALLOWED STD_PAY EXP_IRFC EXP_LTAC EXP_IP EXP_OBS EXP_ER EXP_RAD EXP_PB EXP_ANC EXP_PDE EXP_MEOS
        EXP_PHYS EXP_DME NT_MILL EXP_SNFC EXP_HOSPICE EXP_HH EXP_OUT_OTH EXP_OTH BLAD_LR PROST_CAST BLAD_OTH 
		PROST_OTH BC_HORMONAL NONHORMONAL;
    output out=EPI_FLAGS_OP (drop = _type_ _freq_)
           max(EX1 OCM2 BLAD_LR PROST_CAST BLAD_OTH PROST_OTH BC_HORMONAL NONHORMONAL) =
        sum(ALLOWED STD_PAY EXP_IRFC EXP_LTAC EXP_IP EXP_OBS EXP_ER EXP_RAD EXP_PB EXP_ANC EXP_PDE EXP_MEOS
        EXP_PHYS EXP_DME NT_MILL EXP_SNFC EXP_HOSPICE EXP_HH EXP_OUT_OTH EXP_OTH ) =
			ALLOWED STD_PAY EXP_IRFC EXP_LTAC EXP_IP EXP_OBS EXP_ER EXP_RAD EXP_PB EXP_ANC EXP_PDE EXP_MEOSC
        EXP_PHYS EXP_DME NT_MILL EXP_SNFC EXP_HOSPICE EXP_HH EXP_OUT_OTH EXP_OTH ;

**************************************************************************** ;
****************** Creating final episode INTERFACE file. ****************** ;
**************************************************************************** ;
*** to calculate Milliman BMT flag *** ;
*** Removal of patients who died prior to performance period. *** ;

PROC SQL ;
    CREATE TABLE EPI AS
    SELECT A.*, B.WINS_5, B.WINS_95
    FROM REC&ref..epi_prelim_&bl._&ds. AS A LEFT JOIN REC&ref..wins_pp&ref. AS B
    ON A.CANCER_TYPE = B.CANCER_TYPE ;
QUIT ;

PROC SORT DATA=EPI ; BY BENE_ID EP_ID ;
DATA EPI ;
    SET EPI ; BY BENE_ID EP_ID ;
    IF FIRST.EP_ID THEN EPI_COUNTER  = 1 ;
DATA EPIPRE(DROP=RECON_ELIG) ;
    merge epi(in=a RENAME=(EPI_TAX_ID=TAX EPI_NPI_ID=ENI)) OCM3 EPI_FLAGS_OP; by bene_id EP_ID ;
    IF A ;

proc sql ;
	create table epipre2_pre as
	select a.*, b.recon_elig
	from epipre as a left join in&ref..epi&tu._&ds. as b
	on a.ep_id=b.ep_id ;
quit ;


*****Check for Car-T Claims and override CANCER_TYPE*****;
data CART_IP_1;
	set IN&ref..iphdr_&ds.;

	car_t_claim=0;
	ARRAY d2 (z) ICD_PRCDR_CD1-ICD_PRCDR_CD25 ;
	DO z = 1 TO dim(d2) ;
		if d2 in ('XW033C3','XW043C3') then car_t_claim=1;
	end;
	if car_t_claim=1;
	if nopay_cd = " " ;
	keep ocm_id bene_id ep_id ADMSN_DT;
run;

PROC SQL ;
    CREATE TABLE CART_IP_2 AS
    SELECT B.ocm_id, B.bene_id, B.ep_id
    FROM EPI_DOD AS A, CART_IP_1 AS B
    WHERE A.BENE_ID = B.BENE_ID AND
          A.EP_BEG LE ADMSN_DT LE A.EP_END ;
QUIT ;

data CART_OP_1;
	set IN&ref..outrev_&ds.;
	if hcpcs_cd in ('Q2040','Q2041');
	if nopay_cd = " " ;
	keep ocm_id bene_id ep_id clm_id;
run;

proc sql;
	create table CART_OP_2 as
	select a.*, b.from_dt, b.thru_dt
	from CART_OP_1 as a left join IN&ref..outhdr_&ds. as b
	on a.bene_id=b.bene_id AND
		a.clm_id=b.clm_id;
quit;

PROC SQL ;
    CREATE TABLE CART_OP_3 AS
    SELECT A.*, B.*
    FROM EPI_DOD AS A, CART_OP_2 AS B
    WHERE A.BENE_ID = B.BENE_ID AND
          A.EP_ID =  B.EP_ID;
QUIT ;

data CART_OP_4;
	set CART_OP_3;
	if (EP_BEG le FROM_DT AND FROM_DT le EP_END)
		OR (EP_BEG le THRU_DT AND THRU_DT le EP_END);
	keep ocm_id bene_id ep_id;
run;

data CART_1;
	set CART_IP_2
		CART_OP_4
		;
	CAR_T=1;
	proc sort nodupkey; by bene_id ep_id;
run;

proc sql;
	create table EPIPRE2 as
	select a.*, coalesce(b.CAR_T,0) as CAR_T
	from EPIPRE2_pre as a left join CART_1 as b
	on a.bene_id=b.bene_id
		and a.ep_id=b.ep_id;
quit;

DATA EPIPRE3 MISMATCH_OCM MISMATCH_OCMb ;
    SET EPIPRE2(RENAME = (EP_ID=EP_ID_A)) ;
    OCM_ID = "&id." ;
    %EPISODE_PERIOD ;
    LENGTH EP_ID EP_ID_CMS $100. ; FORMAT EP_ID EP_ID_CMS $100. ;
	%if &vers. ne R0 %then %do; 
		if Prior_Changed_Episode = "Yes" then do;
	    	epb = ((year(ep_beg_prior)-2000)*10000)+(month(ep_beg_prior)*100)+day(ep_beg_prior) ;
		    EP_ID = CATS("XXX-",EP_ID_prior,"-",epb,"-P-",OCM_ID)  ;
		end ;
		else do ;
			epb = ((year(ep_beg)-2000)*10000)+(month(ep_beg)*100)+day(ep_beg) ;
		    EP_ID = CATS(EP_ID_A,"-",epb,"-P-",OCM_ID)  ;
		end ;
	%end;
	%else %do;
			epb = ((year(ep_beg)-2000)*10000)+(month(ep_beg)*100)+day(ep_beg) ;
		    EP_ID = CATS(EP_ID_A,"-",epb,"-P-",OCM_ID)  ;
	%end;
    FORMAT PATIENT_NAME $50. ;   LENGTH PATIENT_NAME $50. ;
    
    IF LAST_NAME NE "  " THEN PATIENT_NAME = PROPCASE(COMPRESS(LAST_NAME,' '))||', '||PROPCASE(COMPRESS(FIRST_NAME,' ')) ;
    ELSE PATIENT_NAME = "UNKNOWN" ;
    IF SEX = "1" THEN PATIENT_SEX = 1  ;
    ELSE IF SEX = "2" THEN PATIENT_SEX = 2 ;
    ELSE PATIENT_SEX = 0 ;

    EPI_TAX_ID = TAX ;
    EPI_NPI_ID = ENI ;
        IF epi_tax_id = EPI_ATT_TIN THEN TIN_MATCH = "YES" ;
        else TIN_MATCH = "NO" ;

	IF ATTRIBUTE_FLAG = '1' THEN EPI_BEG_MATCH = "YES" ;
	ELSE EPI_BEG_MATCH = "NO" ;

	EP_ID_CMS = EP_ID_A ;
	if substr(EP_ID,1,4) = "XXX-" then EP_ID_CMS = cats("XXX-",EP_ID_CMS);

    ACTUAL_EXP_MILLIMAN = SUM(STD_PAY,EXP_OTHER) ;
	ACTUAL_EXP_NOOTH_MILLIMAN = STD_PAY ;
	%if &ref. = 1 %then %do; 
		IF WINS_5 = . THEN WINS_5 = &othwinsl1. ;
		IF WINS_95 = . THEN WINS_95 = &othwinsu1. ;
	%end;
	%else %if &ref. = 2 %then %do;
		IF WINS_5 = . THEN WINS_5 = &othwinsl2. ;
		IF WINS_95 = . THEN WINS_95 = &othwinsu2. ;
	%end;
	%else %if &ref. = 3 %then %do;
		IF WINS_5 = . THEN WINS_5 = &othwinsl3. ;
		IF WINS_95 = . THEN WINS_95 = &othwinsu3. ;
	%end;
    IF ACTUAL_EXP_MILLIMAN < WINS_5 THEN ACTUAL_EXP_MILLIMAN = WINS_5 ;
    IF ACTUAL_EXP_MILLIMAN > WINS_95 THEN ACTUAL_EXP_MILLIMAN = WINS_95 ;
    IF ACTUAL_EXP_NOOTH_MILLIMAN < WINS_5 THEN ACTUAL_EXP_NOOTH_MILLIMAN = WINS_5 ;
    IF ACTUAL_EXP_NOOTH_MILLIMAN > WINS_95 THEN ACTUAL_EXP_NOOTH_MILLIMAN = WINS_95 ;

    ACTUAL_EXP_UNADJ_MILLIMAN = ALLOWED ;

    NOVEL_THERAPIES_MILLIMAN = NT_MILL ;
    IF NOVEL_THERAPIES_MILLIMAN = . THEN NOVEL_THERAPIES_MILLIMAN = 0 ;

		
    NUM_OCM1_MILLIMAN = MAX(0,EX1) ;
    NUM_OCM2_MILLIMAN = MAX(0,OCM2) ;


    IF DOD NE . AND EP_BEG LE DOD LE EP_END THEN DEN_OCM3_MILLIMAN = 1  ;
    ELSE DEN_OCM3_MILLIMAN = 0 ;

	NUM_OCM3_MILLIMAN = 0 ;
    IF DEN_OCM3_MILLIMAN = 1 THEN NUM_OCM3_MILLIMAN = MAX(0,HOSP_3DAY) ;

	IF RECON_ELIG = "0" THEN DO ;
		NUM_OCM1_MILLIMAN = 0 ;
		NUM_OCM2_MILLIMAN = 0 ;
		NUM_OCM3_MILLIMAN = 0 ;
		DEN_OCM3_MILLIMAN = 0 ;
	END ;

	IF NUM_OCM1 = " " THEN NUM_OCM1 = '0' ;
	IF NUM_OCM2 = " " THEN NUM_OCM2 = '0' ;
	IF NUM_OCM3 = " " THEN NUM_OCM3 = '0' ;
	IF DEN_OCM3 = " " THEN DEN_OCM3 = '0' ;
    IF NUM_OCM1 NE NUM_OCM1_MILLIMAN THEN OCM1_INVALID = 1 ; ELSE OCM1_INVALID = 0 ;
    IF NUM_OCM2 NE NUM_OCM2_MILLIMAN THEN OCM2_INVALID = 1 ; ELSE OCM2_INVALID = 0 ;
    IF NUM_OCM3 NE NUM_OCM3_MILLIMAN THEN OCM3_INVALID = 1 ; ELSE OCM3_INVALID = 0 ;
    IF DEN_OCM3 NE DEN_OCM3_MILLIMAN THEN DOCM3_INVALID = 1 ; ELSE DOCM3_INVALID = 0 ;


    EXP_ALL_SERVICES_MILLIMAN = SUM(STD_PAY,EXP_OTHER);
	IF round(EXP_ALL_SERVICES_MILLIMAN - EXP_ALL_SERVICES,1)=0 THEN EXP_ALL_SERVICES_MATCH = "YES" ;
	ELSE EXP_ALL_SERVICES_MATCH = "NO" ;
	EXP_ALL_SRVC_NOOTH_MILL = STD_PAY ;
    EXP_INP_ADMSNS_MILLIMAN = EXP_IP ;
    EXP_OBS_STAY_MILLIMAN = EXP_OBS ;
    EXP_ED_MILLIMAN = EXP_ER ;
	EXP_OBS_ED_MILLIMAN = SUM(EXP_OBS, EXP_ER) ;
	EXP_OBS_ED = SUM(EXP_OBS_STAY,EXP_ED) ;
    EXP_RAD_ONCLGY_MILLIMAN = EXP_RAD ;
    EXP_PHY_SRVC_MILLIMAN = EXP_PHYS ;
    EXP_OUT_OTHER_MILLIMAN = EXP_OUT_OTH ;
    EXP_HHA_MILLIMAN = EXP_HH ;
    EXP_SNF_MILLIMAN = EXP_SNFC ;
    EXP_LTCH_MILLIMAN = EXP_LTAC ;
    EXP_IRF_MILLIMAN = EXP_IRFC ;
    EXP_HSP_MILLIMAN = EXP_HOSPICE ;
    EXP_DME_EXCL_DRUGS_MILL = EXP_DME ;
    EXP_PART_B_DRUGS_MILL = EXP_PB ;
    EXP_PD_MILLIMAN = EXP_PDE ;
    EXP_OTHER_MILLIMAN = EXP_OTH ;
	EXP_MEOS_MILLIMAN = EXP_MEOSC ;

	EXP_ALL_SERVICES_LMEOS = EXP_ALL_SERVICES - EXP_MEOS ;

         
	*** To account diff_all_service meos issues *** ;
    ARRAY EXP (E) EXP_ALL_SERVICES_MILLIMAN EXP_INP_ADMSNS_MILLIMAN EXP_OBS_STAY_MILLIMAN EXP_ED_MILLIMAN
                  EXP_RAD_ONCLGY_MILLIMAN EXP_PHY_SRVC_MILLIMAN 
                  EXP_OUT_OTHER_MILLIMAN EXP_HHA_MILLIMAN EXP_SNF_MILLIMAN EXP_LTCH_MILLIMAN EXP_IRF_MILLIMAN
                  EXP_HSP_MILLIMAN EXP_DME_EXCL_DRUGS_MILL EXP_PART_B_DRUGS_MILL EXP_PD_MILLIMAN EXP_OTHER_MILLIMAN
				  NOVEL_THERAPIES_MILLIMAN  EXP_OBS_ED_MILLIMAN EXP_MEOS_MILLIMAN ;
    ARRAY EXPORIG (E) EXP_ALL_SERVICES EXP_INP_ADMSNS EXP_OBS_STAY EXP_ED
                  EXP_RAD_ONCLGY EXP_PHY_SRVC 
                  EXP_OUT_OTHER EXP_HHA EXP_SNF EXP_LTCH EXP_IRF
                  EXP_HSP EXP_DME_EXCL_DRUGS EXP_PART_B_DRUGS EXP_PD EXP_OTHER
				  NOVEL_THERAPIES EXP_OBS_ED EXP_MEOS ;
    ARRAY DIFFORIG (E) DIFF_ALL_SERVICES DIFF_INP_ADMSNS DIFF_OBS_STAY DIFF_ED
                  DIFF_RAD_ONCLGY DIFF_PHY_SRVC 
                  DIFF_OUT_OTHER DIFF_HHA DIFF_SNF DIFF_LTCH DIFF_IRF
                  DIFF_HSP DIFF_DME_EXCL_DRUGS_MILL DIFF_PART_B_DRUGS_MILL DIFF_PD DIFF_OTHER
				  DIFF_NT DIFF_OBS_ED DIFF_MEOS ;
    DO E = 1 TO DIM(EXP) ;
        IF EXP = . THEN EXP = 0 ;
        IF EXPORIG = . THEN EXPORIG = 0 ;
        DIFFORIG = ABS(EXPORIG - EXP) ;
		IF DIFFORIG < .1 THEN DIFFORIG = 0 ;
    END ;

    ADMITS_TOTAL = SUM(EXP_INP_ADMSNS, EXP_LTCH, EXP_IRF) ;
    ADMITS_TOTAL_MILLIMAN = SUM(EXP_INP_ADMSNS_MILLIMAN, EXP_LTCH_MILLIMAN, EXP_IRF_MILLIMAN) ;

    FORMAT CANCER_MATCH $3. ; LENGTH CANCER_MATCH $3. ;
    IF CANCER_INVALID = 1 THEN CANCER_MATCH = "NO" ;
    ELSE CANCER_MATCH = "YES" ;

	*** Note 7/30/18 - Note that name of recon file flag for prostate cancer might
		change to reflect new intensity versus castration labeling - check in next
		data submission.  **** ;
	FORMAT LOW_RISK_BLAD_MILLIMAN_r CAST_SENS_PROS_MILLIMAN_r LOW_RISK_BREAST_MILLIMAN $1. ; 
	LENGTH LOW_RISK_BLAD_MILLIMAN_r CAST_SENS_PROS_MILLIMAN_r LOW_RISK_BREAST_MILLIMAN $1. ;
	IF CANCER_TYPE = "Bladder Cancer" then do ;
		IF BLAD_LR = 1 AND BLAD_OTH = 0 THEN LOW_RISK_BLAD_MILLIMAN_r = "1" ;
		ELSE LOW_RISK_BLAD_MILLIMAN_r = "0" ;
	end ;
	else LOW_RISK_BLAD_MILLIMAN_r = "2" ;
	IF CANCER_TYPE = "Prostate Cancer" THEN DO ;
		IF PROST_CAST = 1 AND PROST_OTH = 0 THEN CAST_SENS_PROS_MILLIMAN_r = "1" ;
		ELSE CAST_SENS_PROS_MILLIMAN_r = "0" ;
	END ;
	ELSE CAST_SENS_PROS_MILLIMAN_r = "2" ;
	IF CANCER_TYPE = "Breast Cancer" THEN DO ;
		IF BC_HORMONAL = 1 AND NONHORMONAL = 0 THEN LOW_RISK_BREAST_MILLIMAN = "1" ;
		ELSE LOW_RISK_BREAST_MILLIMAN = "0" ;
	END ;
	ELSE LOW_RISK_BREAST_MILLIMAN = "2" ;

	if (LOW_RISK_BLAD_MILLIMAN_r+0) ^= LOW_RISK_BLAD then LR_BLAD_INV=1; else LR_BLAD_INV=0;
	if (CAST_SENS_PROS_MILLIMAN_r+0) ^= CAST_SENS_PROS then CS_PROS_INV=1; else CS_PROS_INV=0;
	if (LOW_RISK_BREAST_MILLIMAN+0) ^= PTD_CHEMO_MILLIMAN then LR_BREAST_INV=1; else LR_BREAST_INV=0;
	if max(LR_BLAD_INV,CS_PROS_INV,LR_BREAST_INV)>0 then output MISMATCH_OCMb;
	drop LR_BLAD_INV CS_PROS_INV LR_BREAST_INV ;

	***CMS Cancer Type;
	%if "&ref." ^= "1" AND "&ref." ^= "2" %then %do;
		IF CANCER_TYPE = "Bladder Cancer" THEN DO ; 	
			IF LOW_RISK_BLAD=1 THEN DO;
				CANCER_TYPE= "Bladder Cancer - Low Risk" ;	
			end ;
			ELSE DO ;
				CANCER_TYPE= "Bladder Cancer - High Risk" ;
			END ;
		END ;

		IF CANCER_TYPE = "Prostate Cancer" then do ;
			IF CAST_SENS_PROS = 1 THEN DO ;
				CANCER_TYPE = "Prostate Cancer - Low Intensity" ;
			end ;
			ELSE DO ;
				CANCER_TYPE= "Prostate Cancer - High Intensity" ;
			END ;
		END ;

		IF CANCER_TYPE= "Breast Cancer" then do ;
			IF PTD_CHEMO = 1 THEN DO ;
				CANCER_TYPE = "Breast Cancer - Low Risk" ;
			end ;
			ELSE DO ;
				CANCER_TYPE = "Breast Cancer - High Risk" ;
			END ;
		END ;

		IF CAR_T = 1 then CANCER_TYPE = "CAR-T" ;
	%end;

	%if &vers. ne R0 %then %do; 
		if Prior_Changed_Episode = "Yes" then do ;
		    ARRAY AMTZ (F) ACTUAL_EXP ACTUAL_EXP_MILLIMAN EXP_ALL_SERVICES_MILLIMAN EXP_INP_ADMSNS_MILLIMAN EXP_OBS_STAY_MILLIMAN EXP_ED_MILLIMAN
		                  EXP_RAD_ONCLGY_MILLIMAN EXP_PHY_SRVC_MILLIMAN  ACTUAL_EXP_NOOTH_MILLIMAN
		                  EXP_OUT_OTHER_MILLIMAN EXP_HHA_MILLIMAN EXP_SNF_MILLIMAN EXP_LTCH_MILLIMAN EXP_IRF_MILLIMAN
		                  EXP_HSP_MILLIMAN EXP_DME_EXCL_DRUGS_MILL EXP_PART_B_DRUGS_MILL EXP_PD_MILLIMAN EXP_OTHER_MILLIMAN
						  NOVEL_THERAPIES_MILLIMAN  EXP_OBS_ED_MILLIMAN EXP_MEOS_MILLIMAN EXP_ALL_SERVICES EXP_INP_ADMSNS EXP_OBS_STAY EXP_ED
		                  EXP_RAD_ONCLGY EXP_PHY_SRVC ACTUAL_EXP_UNADJ_MILLIMAN NOVEL_THERAPIES_MILLIMAN
		                  EXP_OUT_OTHER EXP_HHA EXP_SNF EXP_LTCH EXP_IRF
		                  EXP_HSP EXP_DME_EXCL_DRUGS EXP_PART_B_DRUGS EXP_PD EXP_OTHER
						  NOVEL_THERAPIES EXP_OBS_ED EXP_MEOS NUM_OCM1_MILLIMAN NUM_OCM2_MILLIMAN NUM_OCM3_MILLIMAN;
					DO F = 1 TO DIM(AMTZ) ;
						AMTZ = . ;
					END ;
				
			RADIATION_MILLIMAN = "  " ;
		    SURGERY_MILLIMAN =  "  " ;
			CLINICAL_TRIAL_MILLIMAN = "  " ;
			BMT_MILLIMAN = "  " ;
		END ;
	%end;

	*** Differences in Recon *** ;
	DIFF_TARGET_ACTUAL = TARGET_PRICE - ACTUAL_EXP ;
	DIFF_TARGET_ACTUAL_PRIOR = TARGET_PRICE_PRIOR - ACTUAL_EXP_PRIOR ;

    IF MAX(OCM1_INVALID,OCM2_INVALID, OCM3_INVALID, DOCM3_INVALID) > 0 THEN
        OUTPUT MISMATCH_OCM ;
    OUTPUT EPIPRE3 ;
run;

DATA MISMATCH_OCM ;
	RETAIN EP_ID BENE_ID EP_BEG EP_END CANCER_TYPE DOD 
			OCM1_INVALID OCM2_INVALID OCM3_INVALID DOCM3_INVALID 
		   NUM_OCM1 NUM_OCM1_MILLIMAN NUM_OCM2 NUM_OCM2_MILLIMAN
		   NUM_OCM3 NUM_OCM3_MILLIMAN DEN_OCM3 DEN_OCM3_MILLIMAN ;
	SET MISMATCH_OCM ;
	KEEP EP_ID BENE_ID EP_BEG EP_END CANCER_TYPE DOD 
			OCM1_INVALID OCM2_INVALID OCM3_INVALID DOCM3_INVALID 
		   NUM_OCM1 NUM_OCM1_MILLIMAN NUM_OCM2 NUM_OCM2_MILLIMAN
		   NUM_OCM3 NUM_OCM3_MILLIMAN DEN_OCM3 DEN_OCM3_MILLIMAN ;

PROC EXPORT DATA=MISMATCH_OCM
    OUTFILE = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP&ref.\Recon Reports\recon_check3_&bl._&ds."
    dbms=xlsx replace ;
    quit ;

PROC EXPORT DATA=MISMATCH_OCMb
    OUTFILE = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP&ref.\Recon Reports\recon_check3b_&bl._&ds."
    dbms=xlsx replace ;
    quit ;

DATA MISMATCH_DOLL;
						  
	SET EPIPRE3 ;

	if diff_all_services > 1 ;

	IF (ROUND(DIFF_ALL_SERVICES,.01) - ROUND(DIFF_MEOS,.01)) < .25 THEN MEOS_FLAG = 1 ;
	ELSE MEOS_FLAG = 0 ;
				  

data mismatch_doll ; 


	retain EP_ID EP_BEG EP_END MEOS_FLAG EXP_MEOS EXP_MEOS_MILLIMAN DIFF_MEOS
		   EXP_ALL_SERVICES EXP_ALL_SERVICES_MILLIMAN EXP_ALL_SRVC_NOOTH_MILL DIFF_ALL_SERVICES
		   EXP_INP_ADMSNS EXP_INP_ADMSNS_MILLIMAN DIFF_INP_ADMSNS
           EXP_LTCH EXP_LTCH_MILLIMAN DIFF_LTCH EXP_IRF EXP_IRF_MILLIMAN DIFF_IRF
		   EXP_OTHER EXP_OTHER_MILLIMAN DIFF_OTHER
		   EXP_SNF EXP_SNF_MILLIMAN DIFF_SNF EXP_HSP EXP_HSP_MILLIMAN DIFF_HSP
		   EXP_HHA EXP_HHA_MILLIMAN DIFF_HHA EXP_PD EXP_PD_MILLIMAN DIFF_PD
		   EXP_RAD_ONCLGY EXP_RAD_ONCLGY_MILLIMAN  DIFF_RAD_ONCLGY 
		   EXP_PHY_SRVC EXP_PHY_SRVC_MILLIMAN  DIFF_PHY_SRVC
		   EXP_OUT_OTHER EXP_OUT_OTHER_MILLIMAN  DIFF_OUT_OTHER 
		   EXP_OBS_STAY EXP_OBS_STAY_MILLIMAN DIFF_OBS_STAY 
		   EXP_ED EXP_ED_MILLIMAN DIFF_ED
		   EXP_OBS_ED EXP_OBS_ED_MILLIMAN DIFF_OBS_ED
		   EXP_DME_EXCL_DRUGS EXP_DME_EXCL_DRUGS_MILL DIFF_DME_EXCL_DRUGS_MILL 
		   EXP_PART_B_DRUGS EXP_PART_B_DRUGS_MILL DIFF_PART_B_DRUGS_MILL 
		   NOVEL_THERAPIES NOVEL_THERAPIES_MILLIMAN  DIFF_NT ;

	set mismatch_doll ;

	keep EP_ID EP_BEG EP_END  MEOS_FLAG EXP_MEOS EXP_MEOS_MILLIMAN DIFF_MEOS
		   EXP_ALL_SERVICES EXP_ALL_SERVICES_MILLIMAN EXP_ALL_SRVC_NOOTH_MILL DIFF_ALL_SERVICES
		   EXP_INP_ADMSNS EXP_INP_ADMSNS_MILLIMAN DIFF_INP_ADMSNS
           EXP_LTCH EXP_LTCH_MILLIMAN DIFF_LTCH EXP_IRF EXP_IRF_MILLIMAN DIFF_IRF
		   EXP_OTHER EXP_OTHER_MILLIMAN DIFF_OTHER
		   EXP_SNF EXP_SNF_MILLIMAN DIFF_SNF EXP_HSP EXP_HSP_MILLIMAN DIFF_HSP
		   EXP_HHA EXP_HHA_MILLIMAN DIFF_HHA EXP_PD EXP_PD_MILLIMAN DIFF_PD
		   EXP_RAD_ONCLGY EXP_RAD_ONCLGY_MILLIMAN  DIFF_RAD_ONCLGY 
		   EXP_PHY_SRVC EXP_PHY_SRVC_MILLIMAN  DIFF_PHY_SRVC
		   EXP_OUT_OTHER EXP_OUT_OTHER_MILLIMAN  DIFF_OUT_OTHER 
		   EXP_OBS_STAY EXP_OBS_STAY_MILLIMAN DIFF_OBS_STAY 
		   EXP_ED EXP_ED_MILLIMAN DIFF_ED
		   EXP_OBS_ED EXP_OBS_ED_MILLIMAN DIFF_OBS_ED
		   EXP_DME_EXCL_DRUGS EXP_DME_EXCL_DRUGS_MILL DIFF_DME_EXCL_DRUGS_MILL 
		   EXP_PART_B_DRUGS EXP_PART_B_DRUGS_MILL DIFF_PART_B_DRUGS_MILL 
		   NOVEL_THERAPIES NOVEL_THERAPIES_MILLIMAN  DIFF_NT ;



PROC SORT DATA=MISMATCH_DOLL ; BY DESCENDING DIFF_ALL_SERVICES ;
PROC EXPORT DATA=MISMATCH_DOLL
    OUTFILE = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP&ref.\Recon Reports\recon_check4_&bl._&ds."
    dbms=xlsx replace ;
    quit ;


DATA MISMATCH_NT ;
	SET EPIPRE3 ;
	RETAIN BENE_ID EP_ID EP_BEG EP_END CANCER_TYPE NOVEL_THERAPIES NOVEL_THERAPIES_MILLIMAN DIFF_NT ;
	IF DIFF_NT > 0  ;
	KEEP BENE_ID EP_ID EP_BEG EP_END CANCER_TYPE NOVEL_THERAPIES NOVEL_THERAPIES_MILLIMAN DIFF_NT ;
PROC EXPORT DATA=MISMATCH_NT
    OUTFILE = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP&ref.\Recon Reports\recon_check5_&bl._&ds."
    dbms=xlsx replace ;
    quit ;

data REC&ref..RECON&it._Interface_&bl._&ds.  ;
    retain OCM_ID EPISODE_PERIOD BENE_ID BENE_HICN FIRST_NAME LAST_NAME PATIENT_NAME SEX
           PATIENT_SEX DOB AGE DOD ZIPCODE EP_ID EP_ID_CMS EPI_COUNTER EP_BEG EP_END EP_LENGTH M_EPI_SOURCE_FINAL
           CANCER_TYPE CANCER_TYPE_MILLIMAN CANCER_MATCH RECON_ELIG DUAL_PTD_LIS
           INST RADIATION RADIATION_MILLIMAN HCC_GRP HRR_REL_COST
           SURGERY SURGERY_MILLIMAN CLINICAL_TRIAL CLINICAL_TRIAL_MILLIMAN
           BMT BMT_MILLIMAN CLEAN_PD ACTUAL_EXP ACTUAL_EXP_MILLIMAN ACTUAL_EXP_NOOTH_MILLIMAN
           BASELINE_PRICE EXPERIENCE_ADJ ACTUAL_EXP_UNADJ ACTUAL_EXP_UNADJ_MILLIMAN
           LOW_RISK_BLAD CAST_SENS_PROS MBI BENCHMARK_PRICE TARGET_PRICE
           OCM_DISCOUNT_ACO NOVEL_THERAPIES NOVEL_THERAPIES_MILLIMAN
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
           EPI_ATT_TIN EPI_TAX_ID EPI_NPI_ID TIN_MATCH IN_PERFORMANCE
		   CAST_SENS_PROS_MILLIMAN LOW_RISK_BLAD_MILLIMAN EPI_BEG_MATCH PTD_CHEMO PTD_CHEMO_MILLIMAN 
		   EXP_ALL_SERVICES_MATCH LOW_RISK_BREAST_MILLIMAN 

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
		   CAST_SENS_PROS_MATCH_PRIOR MBI_MATCH_PRIOR PTD_CHEMO_MATCH_PRIOR %if &vers. ne R0 %then %do; Prior_Changed_Episode %end;
;


    SET EPIPRE3 ;

    KEEP OCM_ID EPISODE_PERIOD BENE_ID BENE_HICN FIRST_NAME LAST_NAME PATIENT_NAME SEX
           PATIENT_SEX DOB AGE DOD ZIPCODE EP_ID EP_ID_CMS EPI_COUNTER EP_BEG EP_END EP_LENGTH M_EPI_SOURCE_FINAL
           CANCER_TYPE CANCER_TYPE_MILLIMAN CANCER_MATCH RECON_ELIG DUAL_PTD_LIS
           INST RADIATION RADIATION_MILLIMAN HCC_GRP HRR_REL_COST
           SURGERY SURGERY_MILLIMAN CLINICAL_TRIAL CLINICAL_TRIAL_MILLIMAN
           BMT BMT_MILLIMAN CLEAN_PD ACTUAL_EXP ACTUAL_EXP_MILLIMAN ACTUAL_EXP_NOOTH_MILLIMAN
           BASELINE_PRICE EXPERIENCE_ADJ ACTUAL_EXP_UNADJ ACTUAL_EXP_UNADJ_MILLIMAN
           LOW_RISK_BLAD CAST_SENS_PROS MBI BENCHMARK_PRICE TARGET_PRICE
           OCM_DISCOUNT_ACO NOVEL_THERAPIES NOVEL_THERAPIES_MILLIMAN
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
           RECON_ATT_MATCH_EPI RECON_ATT_MATCH_STRT  RECON_ATT_MATCH_CANC
           EPI_ATT_TIN EPI_TAX_ID EPI_NPI_ID TIN_MATCH IN_PERFORMANCE 
		   CAST_SENS_PROS_MILLIMAN LOW_RISK_BLAD_MILLIMAN EPI_BEG_MATCH PTD_CHEMO PTD_CHEMO_MILLIMAN 
		   EXP_ALL_SERVICES_MATCH LOW_RISK_BREAST_MILLIMAN 

		   EXP_MEOS EXP_MEOS_MILLIMAN 

		   DIFF_TARGET_ACTUAL DIFF_TARGET_ACTUAL_PRIOR 

		   /*** THESE WILL SHOW UP AS UNINITIALIZED IN LOG FOR INITIAL RECON RUNS */
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
		   CAST_SENS_PROS_MATCH_PRIOR MBI_MATCH_PRIOR PTD_CHEMO_MATCH_PRIOR %if &vers. ne R0 %then %do; Prior_Changed_Episode %end;
;

FORMAT M_EPI_SOURCE_FINAL $10. ; LENGTH M_EPI_SOURCE_FINAL $10. ; 
	M_EPI_SOURCE = MAX(0, M_EPI_SOURCE) ;
	IF M_EPI_SOURCE = 0 then M_EPI_SOURCE_FINAL = "UNKNOWN" ;
	ELSE IF M_EPI_SOURCE = 4 THEN M_EPI_SOURCE_FINAL = "PART D" ;
	ELSE M_EPI_SOURCE_FINAL = "PART B" ;

run;


%mend sc ;

**************************************************************************** ;
**************************************************************************** ;
***** %macro sc(ds,id)
        ID: 3 digit OCM id
**************************************************************************** ;
**************************************************************************** ;

%let att_tin = '454999975' ; run ;
%SC(255_50179,255) ; run ;

%let att_tin = '636000526' ;run ;
%SC(257_50195,257) ; run ;

%let att_tin = '134290167' ;run ;
%SC(278_50193,278) ; run ;

%let att_tin = '731310891' ;run ;
%SC(280_50115,280) ; run ;

*** pp2 *** ;
*%let att_tin = '540647482','540793767','541744931','311716973' ; run ; 
*** pp1 *** ; 
%let att_tin = '540647482','311716973' ; run ; 
%SC(290_50202,290) ; run ;

%let att_tin = '571004971' ;run ;
%SC(396_50258,396) ; run ;

%let att_tin = '205485346' ;run ;
%SC(401_50228,401) ; run ;

%let att_tin = '204881619' ;run ;
%SC(459_50243,459) ; run ;

%let att_tin = '621490616' ;run ;
%SC(468_50227,468) ; run ;

%let att_tin = '201872200' ;run ;
%SC(480_50185,480) ; run ;

%let att_tin = '596014973' ;run ;
%SC(523_50330,523) ; run ;

%let att_tin = '223141761' ;run ;
%SC(137_50136,137) ; run ;


**** PP1 Only **** ;
%LET ATT_TIN = '541744931' ; RUN ;
%sc(568_50201,568) ; run ;

%LET ATT_TIN = '540793767' ; RUN ;
%sc(567_50200,567) ; run ;

RUN ;

**Export to a different file name bc of corruption**;
PROC EXPORT DATA=MISMATCH_DOLL
    OUTFILE = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP&ref.\Recon Reports\recon_check4_&bl._567_50200_2"
    dbms=xlsx replace ;
quit ;


****************************************************************** ;
	************* Investigations ********************* ;
****************************************************************** ;
/*
****************************************************************** ;
*** Mismatch on Novel Therapy Totals *** ;

proc print data=REC&ref..ALL_CLAIMS_&bl._257_50195 ;
	where ep_id = 437628 and Novel_therapy = "YES" ; 
	var bene_id ep_id novel_therapy CLM_REV_STD_PYMT_AMT std_pay hcpcs_cd IDENDC LNNDCCD PROD_SRVC_ID ;
	sum CLM_REV_STD_PYMT_AMT std_pay ;
run ; 

proc print data=REC&ref..RECON&it._Interface_&bl._257_50195 ;
	where ep_id = "437628-161201-P-257" ;
run ;

proc print data=REC&ref..OUTPATIENT_&bl._257_50195 ;
	where ep_id = 437628 and hcpcs_cd = "J9047" ;
	var bene_id ep_id clm_id from_dt thru_dt hcpcs_cd CLM_REV_STD_PYMT_AMT  ;
	sum CLM_REV_STD_PYMT_AMT ;
run ;

proc print data=outpatient;
	where ep_id = 437628 and hcpcs_cd in ('J9999','J8999');
	var bene_id ep_id clm_id from_dt thru_dt hcpcs_cd CLM_REV_STD_PYMT_AMT  ;
	sum CLM_REV_STD_PYMT_AMT ;
run ;

proc print data=REC&ref..SC_pde_&bl._257_50195 ;
	where ep_id = 437628 ;
run ;

 
****************************************************************** ;
*** Mismatch on ED and OBS STAY Totals *** ;

proc sort data=REC&ref..ALL_CLAIMS_&bl._523_50330  out=all_clms ; by ep_id clm_id clm_ln ;
proc print data=all_clms ; by ep_id clm_id ;
	where ep_id = 356025 and sum(er_pre,obs_pre ) > 0 ;
	var bene_id ep_id ep_beg ep_end clm_id rev_dt REV_CNTR_TOT_CHRG_AMT REV_CNTR_NCVRD_CHRG_AMT std_pay 
		REV_CNTR  hcpcs_cd REV_UNIT  er_pre obs_pre  SERVICE_CAT;
	sum std_pay ;
run ;


****************************************************************** ;
*** Mismatch on Totals *** ;
proc sort data=REC&ref..ALL_CLAIMS_&bl._523_50330  out=all_clms ; by ep_id service_category;

PROC PRINT DATA=REC&ref..RECON&it._Interface_&bl._523_50330  (OBS=20) ; RUN ;

proc print data=REC&ref..check_ipop_&bl._257_50195 ;

where ep_id =  555522 ;
run ;

****************************************************************** ;
*** Mismatch on OCM QUALITY *** ;

proc print data=REC&ref..SC_ip_&bl._257_50195 ;
	where ep_id =  555522 and clm_id = '4948697927';
run ;	 

proc print data=REC&ref..RECON&it._Interface_&bl._257_50195 ;
	where ep_id_cms = 555522 ;
	var bene_id ep_id ep_beg ep_end cancer_type surgery surgery_milliman num_ocm1 num_ocm1_milliman ;
run ;
proc print data=REC&ref..outpatient_&bl._257_50195 ;
	where ep_id =  555522 and clm_id = '4948697927';
run ;

PROC PRINT DATA=REC&ref..EPIATT_137_50136_PP1 ;
	var bene_id ep_id ep_beg ep_end cancer_type DOD num_ocm1 num_ocm2 num_ocm3 DEN_OCM3 ;
	WHERE EP_ID = 367085 ; 
RUN ;

PROC freq DATA=REC&ref..EPIATT_137_50136_PP1 ;
	tables num_ocm1 num_ocm2 num_ocm3 den_ocm3 ; run ;

proc print data=REC&ref..RECON&it._Interface_&bl._137_50136 ;
	where ep_id_CMS  = 418175426977;
	var bene_id ep_id ep_beg ep_end cancer_type DOD num_ocm1 num_ocm2 num_ocm3 DEN_OCM3 BMT
		BMT_MILLIMAN SURGERY SURGERY_MILLIMAN ;
run ;

PROC PRINT DATA=SC_ip_&bl._396_50258 ;
	VAR BENE_ID EP_ID CLM_ID admsn_dt from_dt thru_dt EX1 
		IP_CHEMO_ADMIN  IP_BMT_AK  IP_BMT_L  IP_BMT_MM  IP_BMT_MDS  SIP_BREAST SIP_ANAL SIP_LIVER 
        SIP_LUNG  SIP_BLADDER  SIP_FEMALEGU SIP_GASTRO  SIP_HN  SIP_INT  SIP_OVARIAN  SIP_PROSTATE 
        SIP_PANCREATIC PRNCPAL_DGNS_CD NOPAY_CD PROVIDER;
	WHERE EP_ID = 166859 ; RUN ;

proc print data=REC&ref..RECON&it._Interface_&bl._278_50193 ;
	where ep_id_CMS  = 106562;
	var bene_id ep_id ep_beg ep_end cancer_type DOD num_ocm1 num_ocm2 num_ocm3 DEN_OCM3 BMT BMT_MILLIMAN
		surgery surgery_milliman;
run ;

proc print data=ocm2_chk ;
	where ep_id = 166859; 
	var bene_id ep_id clm_id from_dt thru_dt REV_CNTR hcpcs_cd rev_unit ed_ocm2 obs_ocm2 
	    REV_CNTR_TOT_CHRG_AMT REV_CNTR_NCVRD_CHRG_AMT ;
run ;

proc print data=REC&ref..inpatient_&bl._396_50258;
	where ep_id = 166859 ;
	var bene_id ep_id clm_id from_dt thru_dt admsn_dt ;
run ;


proc print data=o2 ;
	where ep_id = 247707 ; 
run ;



data dupl1;
	set epi_ct;  by bene_id ep_id ;
	if first.ep_id=0 or last.ep_id=0 then output ;
run ;

proc print data=REC2.EPI_PRELIM_P2R0_255_50179 ; 
	where ep_id = 750616175845; run ;
	
proc print data=REC2.EPI_PRELIM_P2R0_137_50136 ; 
	where ep_id = 421689020; run ;
proc print data=hspcodes2 ;
	where ep_id = 421689020 ; run ;
proc print data=hsp_flags ;
	where ep_id = 421689020 ; run ;
proc print data=HOSP1_A ;
	where ep_id = 421689020 ; run ;
proc print data=HOSP2 ;
	where ep_id = 421689020 ; run ;
proc print data=latest ;
	where ep_id = 421689020 ; run ;
proc print data=sch ;
	where ep_id = 421689020 ; run ;

proc print data= REC&ref..SC_ip_&bl._137_50136  ;
	where ep_id = 99346134908 ; 
run ;
data chk ;
	set t3 ; by bene_id ep_id ctype ;
	if first.ep_id=0 or last.ep_id=0 ;
run ;
data chk2 ;
	set epi_ct ;
	if cancer_type = "  " ; 
	run ;
proc print data=REC1.EPI_PRELIM_P1R1_278_50193 ; 
	where bene_id = "302842729" ; run ;

PROC EXPORT DATA=MISMATCH_DOLL
    OUTFILE = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP&ref.\Recon Reports\recon_check4_&bl._567_50200_2"
    dbms=xlsx replace ;
    quit ;

