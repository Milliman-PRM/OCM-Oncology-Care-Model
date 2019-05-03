********************************************************************** ;
		***** 000_Attribution_Reconciliation.sas  ***** ;
********************************************************************** ;
libname outfinal "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\SAS\02 - Performance Period Files\Out\November" ;
LIBNAME ATT "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\SAS\03 - Reconciliation Files" ;
options ls=132 ps=70 obs=MAX mprint mlogic; run ;

********************************************************************** ;
********************************************************************** ;

%let bl = p1a ; *** performance period 1, first version received *** ; 
%let pp = 1 ;
%let version = Initial ;

********************************************************************** ;
********************************************************************** ;

%MACRO KEEPATT ;
		BENE_HICN MBI EP_ID	FIRST_NAME LAST_NAME DOB SEX EP_BEG_A EP_END_A	CANCER_TYPE_A RECON_ELIG_A EM_VISIT_FOR_CANC
		MOST_RECENT_EM OCM_REGISTRY	
%MEND KEEPATT ;

********************************************************************** ;
********************************************************************** ;

%macro recon(ds,mult,a1,a2) ; 

%LET INEPI = outfinal.episode_Interface_&bl._&ds. ;
%LET INEMER = outfinal.episode_emerge_&bl._&ds.;

*** Reassign Attribution Cancers to Match Milliman Assignments *** ;

data att ;
	%if "&mult." = "0" %then %do ;
	set att.ATT_PP&pp.&version._&ds. ;
	%end ;
	%else %do ;
	set att.ATT_PP&pp.&version._&ds. att.ATT_PP&pp.&version._&a1. att.ATT_PP&pp.&version._&a2. ;
	%end ;
		*** Some CMS Cancer Types set to ICD10 *** ;
	if cancer_type_a = 'C26' then cancer_type_a = 'Malignant neoplasm of other and ill-defined digestive organs' ;
	if cancer_type_a = 'C37' then cancer_type_a = "Malignant neoplasm of thymus" ;
	if cancer_type_a = 'C38' then cancer_type_a = "Malignant neoplasm of heart, mediastinum and pleura" ;
	if cancer_type_a = 'C40' then cancer_type_a = "Malignant neoplasm of bone and articular cartilage of limbs" ;
	if cancer_type_a = 'C41' then cancer_type_a = "Malignant neoplasm of bone and articular cartilage of sites NOS" ;
	if cancer_type_a = 'C44' then cancer_type_a = "Malignant neoplasm of skin, NOS" ;
	if cancer_type_a = 'C46' then cancer_type_a = "Kaposi's Sarcoma" ;
	if cancer_type_a = 'C48' then cancer_type_a = "Malignant neoplasm of retroperitoneum and peritoneum" ;
	if cancer_type_a = 'C47 or C49' then cancer_type_a = "Malignant neoplasm of peripheral nerves, autonomic nervous system" ;
	if cancer_type_a = 'C4A' then cancer_type_a = "Merkel cell carcinoma" ;
	if cancer_type_a = 'C57' then cancer_type_a = "Malignant neoplasm of other and unspecified female genital organs" ;
	if cancer_type_a = 'C60 or C63' then cancer_type_a = "Malignant neoplasm of penis, other, and unspecific male organs" ;
	if cancer_type_a = 'C62' then cancer_type_a = "Malignant neoplasm of testis" ;
	if cancer_type_a = 'C76.1' then cancer_type_a = "Malignant neoplasm of thorax" ; 
	if cancer_type_a = 'C76.2' then cancer_type_a = "Malignant neoplasm of abdomen" ; 
	if cancer_type_a = 'C76.8' then cancer_type_a = "Malignant neoplasm of other specified ill-defined sites" ; 
	if cancer_type_a = 'C80' then cancer_type_a = "Malignant neoplasm NOS" ;
	if cancer_type_a = 'C91.9' then cancer_type_a = "Lymphoid Leukemia, unspecified" ;
	if cancer_type_a = 'C92.9' then cancer_type_a = 'Myeloid leukemia, unspecified';
	if cancer_type_a = 'C92.z' then cancer_type_a = 'Other myeloid leukemia';
	if cancer_type_a = 'C93.1' then cancer_type_a = 'Chronic myelomonocytic leukemia' ;
	if cancer_type_a = 'C95.1' then cancer_type_a = 'Chronic leukemia of unspecified cell type' ;
	if cancer_type_a = 'C95.9' then cancer_type_a = 'Leukemia, unspecified' ;
	if cancer_type_a = 'C96' then cancer_type_a = "Malignant neoplasm of lymphoid, hematopoietic NOS" ;
	if cancer_type_a = 'D02' then cancer_type_a = 'Carcinoma in situ of middle ear and respiratory system' ;
	if cancer_type_a = 'D04' then cancer_type_a = 'Carcinoma in situ of skin' ;
	if cancer_type_a = 'D05' then cancer_type_a = 'Carcinoma in situ of breast' ;
	if cancer_type_a = 'D07' then cancer_type_a = 'Carcinoma in situ of other and NOS genital organs' ;
	*** Added because of attribution file entries **** ;
	if cancer_type_a = 'C76.3' then cancer_type_a = "Malignant neoplasm of pelvis" ;


	*** 6/13/17: Addition of cancer type change to conform with MA labeling logic. *** ;
	if cancer_type_a = "Carcinoma in situ of other and unspecified genital organs" then 
	   cancer_type_a = "Carcinoma in situ of other and NOS genital organs"  	   ;
	if 	   cancer_type_a in 
			("Malignant neoplasm of peripheral nerves, autonomic nervous system, and other and connective soft tis",
			 "Malignant neoplasm of peripheral nerves, autonomic nervous system, and other and connective soft tissue") then 
		   cancer_type_a = "Malignant neoplasm of peripheral nerves, autonomic nervous system"   ;
	if cancer_type_a = "Myeloid leukemia, unspecified" then cancer_type_a = "Myeloid Leukemia, NOS"  ;

	PROC FREQ DATA=ATT ;
		TABLES CANCER_TYPE_A ;
		TITLE "REMAPPED CANCER TYPES: &DS." ; RUN ;

PROC SORT DATA=ATT OUT=ATT_UNIQ NODUPKEY ; BY BENE_HICN ;


PROC SORT DATA=&INEPI OUT=EPI1 ; BY BENE_HICN ;
PROC SORT DATA=&INEMER OUT=EPI2 ; BY BENE_HICN ;

**** Check 1 - Attribution Beneficiaries not found in Performance Quarterly Files **** ;

DATA INATT1 (KEEP = BENE_HICN) OVERLAP1(KEEP = BENE_HICN) ;
	MERGE ATT_UNIQ(IN=A KEEP = BENE_HICN) EPI1(IN=B)  ;  BY BENE_HICN ;
	IF A AND B=0 THEN OUTPUT inatt1;
	IF A AND B THEN OUTPUT OVERLAP1 ;

DATA INATT2 (KEEP=BENE_HICN) OVERLAP2(KEEP = BENE_HICN) ;
	MERGE ATT_UNIQ(IN=A KEEP = BENE_HICN) EPI2(IN=B)  ;  BY BENE_HICN ;
	IF A AND B=0 THEN OUTPUT inatt2;
	IF A AND B THEN OUTPUT OVERLAP2 ;

DATA INATT_ONLY ;
	MERGE INATT1(IN=A) INATT2(IN=B) ; BY BENE_HICN ;
	IF A AND B ;

PROC SORT DATA=OVERLAP1 NODUPKEY ; BY BENE_HICN ;
PROC SORT DATA=OVERLAP2 NODUPKEY ; BY BENE_HICN ;
PROC SORT DATA=ATT ; BY BENE_HICN ;

DATA OL ;
	MERGE OVERLAP1(IN=A) ATT(IN=B) ; BY BENE_HICN ;
	IF A AND B ;


DATA EPI1_MATCH EPI1_MISS_BEG EPI1_MISS_CANC EPI1_NOATT ;
	MERGE EPI1(IN=A where = (ep_beg le mdy(1,1,2017))) OL(IN=B KEEP=BENE_HICN EP_BEG_A CANCER_TYPE_A) ; BY BENE_HICN ;
	IF A AND B=0 THEN OUTPUT EPI1_NOATT ;
	ELSE IF A AND B THEN DO ;
		IF EP_BEG NE EP_BEG_A THEN OUTPUT EPI1_MISS_BEG ;
		ELSE IF CANCER_TYPE_MILLIMAN NE CANCER_TYPE_A THEN OUTPUT EPI1_MISS_CANC ;
		ELSE OUTPUT EPI1_MATCH ;
	END ;

DATA OL2 ;
	MERGE OVERLAP2(IN=A) ATT(IN=B) ; BY BENE_HICN ;
	IF A AND B ;


DATA EPI2_MATCH EPI2_MISS_BEG EPI2_MISS_CANC EPI2_NOATT ;
	MERGE EPI2(IN=A where = (ep_beg le mdy(1,1,2017))) OL2(IN=B KEEP=BENE_HICN EP_BEG_A CANCER_TYPE_A) ; BY BENE_HICN ;
	IF A AND B=0 THEN OUTPUT EPI2_NOATT ;
	ELSE IF A AND B THEN DO ;
		IF EP_BEG NE EP_BEG_A THEN OUTPUT EPI2_MISS_BEG ;
		ELSE IF CANCER_TYPE_MILLIMAN NE CANCER_TYPE_A THEN OUTPUT EPI2_MISS_CANC ;
		ELSE OUTPUT EPI2_MATCH ;
	END ;


%MEND ;

%RECON(112_50203,0,,) ; run ;
%RECON(137_50136,0,,) ; run ;
%RECON(255_50179,0,,) ; run ;
%RECON(257_50195,0,,) ; run ;
%RECON(278_50193,0,,) ; run ;
%RECON(280_50115,0,,) ; run ;
%RECON(396_50258,0,,) ; run ;
%RECON(401_50228,0,,) ; run ;
%RECON(468_50227,0,,) ; run ;
%RECON(480_50185,0,,) ; run ;
%RECON(523_50330,0,,) ; run ;
%RECON(290_50202,1,567_50200,568_50201) ;
run ;
