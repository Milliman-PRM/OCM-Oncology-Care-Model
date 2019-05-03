********************************************************************** ;
		***** 004_Episode Based Prediction Model Weights.sas ***** ;
********************************************************************** ;

libname in "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\SAS\01 - Baseline Files\In V1" ; *** locale of SAS reads. *** ;
LIBNAME R2 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\SAS\OCM - Benchmark Files" ;

options ls=132 ps=70 obs=max; run ;

PROC PRINT DATA=in.epi_112_50203 (OBS=20) ; RUN ;
********************************************************************** ;
********************************************************************** ;

data epi_all ;
	set in.epi_112_50203(in=a)
		in.epi_255_50179(in=b)
		in.epi_257_50195(in=c)
		in.epi_278_50193(in=d)
		in.epi_290_50202(in=e)
		in.epi_396_50258(in=f)
		in.epi_480_50185(in=g)
		in.epi_523_50330(in=h)
		in.epi_567_50200(in=i)
		in.epi_568_50201(in=j)
		in.epi_401_50228(in=k)
		in.epi_137_50136(in=l)
		in.epi_280_50115(in=m)
;

	if a then OCM_ID = 112 ;
	if b then OCM_ID = 255 ;
	if c then OCM_ID = 257 ;
	if d then OCM_ID = 278 ;
	if e then OCM_ID = 290 ;
	if f then OCM_ID = 396 ;
	if g then OCM_ID = 480 ;
	if h then OCM_ID = 523 ;
	if i then OCM_ID = 567 ;
	if j then OCM_ID = 568 ;
	if k then OCM_ID = 401 ;
	if l then OCM_ID = 137 ;
	if m then OCM_ID = 280 ;

	if recon_elig = 1 ;  *** Only keeping reconcilation eligible cancers ;

	clean_1_61 = 0 ; clean_62_730 = 0 ; clean_731 = 0 ;
	if clean_pd = "1" then clean_1_61 = 1 ;
	else if clean_pd = "2" then clean_62_730 = 1 ;
	else if clean_pd = "3" then clean_731 = 1 ;

	no_pd = 0 ; pd_no_lis = 0 ; pd_lis = 0 ; full_dual = 0 ;
	if dual_ptd_lis = "0" then no_pd = 1 ;
	else if dual_ptd_lis = "1" then pd_no_lis = 1 ;
	else if dual_ptd_lis = "2" then pd_lis = 1 ;
	else if dual_ptd_lis = "3" then full_dual = 1 ;

	hhs_none = 0 ; hhs1 = 0 ; hhs2 = 0 ; hhs3 = 0 ; hhs45 = 0 ; hhs6 = 0 ;  hhs_new = 0 ;
	if hcc_grp in ("00","99") then hhs_none = 1 ;
	else if hcc_grp = "01" then hhs1 = 1 ;
	else if hcc_grp = "02" then hhs2 = 1 ;
	else if hcc_grp = "03" then hhs3 = 1 ;
	else if hcc_grp = "4-5" then hhs45 = 1 ;
	else if hcc_grp = "6+" then hhs6 =  1;
	else if hcc_grp = "98" then hhs_new = 1 ;

proc freq data=epi_all ;
	tables cancer_type*ocm_id/list missing ;
title "Distribution of contributors to each Cancer Weight" ; run ;
proc freq data=epi_all ;
	tables hcc_grp ;
title "Check that no episodes report value 99 in this field" ; run ;


**************************************************************************** ;
			*** Creation of Prediction Model File *** ;
**************************************************************************** ;

data step1 ;

	SET epi_all  ;

	age_calc = intz(age) ;
	*if age_calc lt 65 then age_18_64 = 1 ; *else age_18_64 = 0 ;
	*if 65 le age_calc le 69 then age_65_69 = 1 ; *else age_65_69 = 0 ;
	*if 70 le age_calc le 74 then age_70_74 = 1 ; *else age_70_74 = 0  ;
	*if 75 le age_calc le 79 then age_75_79 = 1 ; *else age_75_79 = 0 ;
	*if 80 le age_calc then age_80 = 1 ; *else age_80 = 0 ;
	age_18_64 = 1 ; age_65_69 = 1 ; age_70_74 = 1 ; age_75_79 = 1 ; age_80 = 1 ;


	*if sex = "F" then female = 1 ; *else female = 0 ;
	*If female = 1 then male = 0 ; *else male = 1 ;  *** assigns unknown genders to male. *** ;
	female =  1 ; male = 1 ;

	IF EP_LENGTH LE 181 THEN DO ;
			EP_180_181 = 1 ; EP_182_183 = 0 ;
	END ;
	ELSE DO ;
			EP_180_181 = 0 ; EP_182_183 = 1 ;
	END ;



	insty = inst ;
	instn = 1-insty ;

	cp_1_61 = CLEAN_1_61;
	cp_62_730 = CLEAN_62_730;
	cp_none = clean_731 ;
	   
	enroll_full_dual = full_dual ;
	enroll_no_pd = no_pd ;
	enroll_pd_lis = pd_lis ;
	enroll_pd_no_lis = pd_no_lis ;

	comorb_1 = hhs1 ;
	comorb_2 = hhs2;
	comorb_3 = hhs3;
	comorb_4_5 = hhs45 ;
	comorb_6 = hhs6;
	comorb_new_enroll = hhs_new;
	comorb_none = hhs_none ;

	IF Clinical_Trial = 1		   THEN DO ; CTY = 1 ; CTN = 0 ; END ;
								   ELSE DO ; CTN = 1 ; CTY = 0 ; END ;
	IF RADIATION		     = "1" THEN DO ; RDY = 1 ; RDN = 0 ; END ;
								   ELSE DO ; RDN = 1 ; RDY = 0 ; END ;
	IF SURGERY				 = "1" THEN DO ; SGY = 1 ; SGN = 0 ; END ;
								   ELSE DO ; SGN = 1 ; SGY = 0 ; END ;
	IF BMT = 1 THEN DO ; 				au = 1 ; al = 0 ; anone = 0 ;END ;
	else if BMT IN (2,3) then do ; 	AU = 0 ; AL = 1 ; ANONE = 0 ; END ;
	ELSE IF BMT = 4 	 THEN DO ;   AU = 1/3 ; AL = 1/3 ; ANONE = 1/3 ; END ;  *** 1 for all weights ;
						 ELSE DO ;   AU = 0 ; AL = 0 ; ANONE = 1 ; END ;
	EPISODE_COUNT = 1 ;

	***Variable Derivation *** ;
	CANC_18_64_F_inst_y	= AGE_18_64*FEMALE*INSTy ;
	CANC_18_64_F_inst_n	= AGE_18_64*FEMALE*INSTn ;
	CANC_18_64_M_inst_y	= AGE_18_64*MALE*INSTy ;
	CANC_18_64_M_inst_n	= AGE_18_64*MALE*INSTn ;

	CANC_18_64_F_epi_180_181= AGE_18_64*FEMALE*EP_180_181 ;	
	CANC_18_64_F_epi_182_183 = 	AGE_18_64*FEMALE*EP_182_183 ;
	CANC_18_64_M_epi_180_181= AGE_18_64*MALE*EP_180_181 ;	
	CANC_18_64_M_epi_182_183 = 	AGE_18_64*MALE*EP_182_183 ;

	CANC_18_64_F_cp_1_61= AGE_18_64*FEMALE*CP_1_61;		
	CANC_18_64_F_cp_62_730	= AGE_18_64*FEMALE*CP_62_730 ; 
	CANC_18_64_F_cp_none = AGE_18_64*FEMALE*CP_NONE;
	CANC_18_64_M_cp_1_61= AGE_18_64*MALE*CP_1_61;		
	CANC_18_64_M_cp_62_730	= AGE_18_64*MALE*CP_62_730 ; 
	CANC_18_64_M_cp_none = AGE_18_64*MALE*CP_NONE	;

	CANC_18_64_F_enroll_full_dual= AGE_18_64*FEMALE*ENROLL_FULL_DUAL ;
	CANC_18_64_F_enroll_no_pd	= AGE_18_64*FEMALE*ENROLL_NO_PD ;
	CANC_18_64_F_enroll_pd_lis	= AGE_18_64*FEMALE*ENROLL_PD_LIS ;
	CANC_18_64_F_enroll_pd_no_lis	= AGE_18_64*FEMALE*ENROLL_PD_NO_LIS ;
	CANC_18_64_M_enroll_full_dual= AGE_18_64*MALE*ENROLL_FULL_DUAL ;
	CANC_18_64_M_enroll_no_pd	= AGE_18_64*MALE*ENROLL_NO_PD ;
	CANC_18_64_M_enroll_pd_lis	= AGE_18_64*MALE*ENROLL_PD_LIS ;
	CANC_18_64_M_enroll_pd_no_lis	= AGE_18_64*MALE*ENROLL_PD_NO_LIS ;

	CANC_18_64_F_comorb_1 = AGE_18_64*FEMALE*COMORB_1 ;	
	CANC_18_64_F_comorb_2 = AGE_18_64*FEMALE*COMORB_2 ; 	
	CANC_18_64_F_comorb_3 = AGE_18_64*FEMALE*COMORB_3 ; 	
	CANC_18_64_F_comorb_4_5	 = AGE_18_64*FEMALE*COMORB_4_5 ; 
	CANC_18_64_F_comorb_6  = AGE_18_64*FEMALE*COMORB_6 ; 	
	CANC_18_64_F_comorb_new_enroll	 = AGE_18_64*FEMALE*COMORB_NEW_ENROLL ; 
	CANC_18_64_F_comorb_none	 = AGE_18_64*FEMALE*COMORB_NONE ; 
	CANC_18_64_M_comorb_1 = AGE_18_64*MALE*COMORB_1 ;	
	CANC_18_64_M_comorb_2 = AGE_18_64*MALE*COMORB_2 ; 	
	CANC_18_64_M_comorb_3 = AGE_18_64*MALE*COMORB_3 ; 	
	CANC_18_64_M_comorb_4_5	 = AGE_18_64*MALE*COMORB_4_5 ; 
	CANC_18_64_M_comorb_6  = AGE_18_64*MALE*COMORB_6 ; 	
	CANC_18_64_M_comorb_new_enroll	 = AGE_18_64*MALE*COMORB_NEW_ENROLL ; 
	CANC_18_64_M_comorb_none	 = AGE_18_64*MALE*COMORB_NONE ; 

	CANC_18_64_F_ct_y = AGE_18_64*FEMALE*CTY; 	
	CANC_18_64_F_ct_n = AGE_18_64*FEMALE*CTN; 		
	CANC_18_64_F_rad_y = AGE_18_64*FEMALE*RDY; 	
	CANC_18_64_F_rad_n = AGE_18_64*FEMALE*RDN; 		
	CANC_18_64_F_surg_y = AGE_18_64*FEMALE*SGY; 		
	CANC_18_64_F_surg_n	= AGE_18_64*FEMALE*SGN; 		
	CANC_18_64_F_bmt_al	= AGE_18_64*FEMALE*al; 		
	CANC_18_64_F_bmt_au	= AGE_18_64*FEMALE*au; 		
	CANC_18_64_F_bmt_none = AGE_18_64*FEMALE*anone; 			
	CANC_18_64_M_ct_y = AGE_18_64*MALE*CTY; 	
	CANC_18_64_M_ct_n = AGE_18_64*MALE*CTN; 		
	CANC_18_64_M_rad_y = AGE_18_64*MALE*RDY; 	
	CANC_18_64_M_rad_n = AGE_18_64*MALE*RDN; 		
	CANC_18_64_M_surg_y = AGE_18_64*MALE*SGY; 		
	CANC_18_64_M_surg_n	= AGE_18_64*MALE*SGN; 		
	CANC_18_64_M_bmt_al	= AGE_18_64*MALE*al; 		
	CANC_18_64_M_bmt_au	= AGE_18_64*MALE*au; 		
	CANC_18_64_M_bmt_none = AGE_18_64*MALE*anone; 			

	CANC_65_69_F_inst_y	= AGE_65_69*FEMALE*INSTY ;
	CANC_65_69_F_inst_n	= AGE_65_69*FEMALE*INSTN ;
	CANC_65_69_M_inst_y	= AGE_65_69*MALE*INSTY ;
	CANC_65_69_M_inst_n	= AGE_65_69*MALE*INSTN ;

	CANC_65_69_F_epi_180_181= AGE_65_69*FEMALE*EP_180_181 ;	
	CANC_65_69_F_epi_182_183 = 	AGE_65_69*FEMALE*EP_182_183 ;
	CANC_65_69_M_epi_180_181= AGE_65_69*MALE*EP_180_181 ;	
	CANC_65_69_M_epi_182_183 = 	AGE_65_69*MALE*EP_182_183 ;

	CANC_65_69_F_cp_1_61= AGE_65_69*FEMALE*CP_1_61;		
	CANC_65_69_F_cp_62_730	= AGE_65_69*FEMALE*CP_62_730 ; 
	CANC_65_69_F_cp_none = AGE_65_69*FEMALE*CP_NONE;
	CANC_65_69_M_cp_1_61= AGE_65_69*MALE*CP_1_61;		
	CANC_65_69_M_cp_62_730	= AGE_65_69*MALE*CP_62_730 ; 
	CANC_65_69_M_cp_none = AGE_65_69*MALE*CP_NONE	;

	CANC_65_69_F_enroll_full_dual= AGE_65_69*FEMALE*ENROLL_FULL_DUAL ;
	CANC_65_69_F_enroll_no_pd	= AGE_65_69*FEMALE*ENROLL_NO_PD ;
	CANC_65_69_F_enroll_pd_lis	= AGE_65_69*FEMALE*ENROLL_PD_LIS ;
	CANC_65_69_F_enroll_pd_no_lis	= AGE_65_69*FEMALE*ENROLL_PD_NO_LIS ;
	CANC_65_69_M_enroll_full_dual= AGE_65_69*MALE*ENROLL_FULL_DUAL ;
	CANC_65_69_M_enroll_no_pd	= AGE_65_69*MALE*ENROLL_NO_PD ;
	CANC_65_69_M_enroll_pd_lis	= AGE_65_69*MALE*ENROLL_PD_LIS ;
	CANC_65_69_M_enroll_pd_no_lis	= AGE_65_69*MALE*ENROLL_PD_NO_LIS ;

	CANC_65_69_F_comorb_1 = AGE_65_69*FEMALE*COMORB_1 ;	
	CANC_65_69_F_comorb_2 = AGE_65_69*FEMALE*COMORB_2 ; 	
	CANC_65_69_F_comorb_3 = AGE_65_69*FEMALE*COMORB_3 ; 	
	CANC_65_69_F_comorb_4_5	 = AGE_65_69*FEMALE*COMORB_4_5 ; 
	CANC_65_69_F_comorb_6  = AGE_65_69*FEMALE*COMORB_6 ; 	
	CANC_65_69_F_comorb_new_enroll	 = AGE_65_69*FEMALE*COMORB_NEW_ENROLL ; 
	CANC_65_69_F_comorb_none	 = AGE_65_69*FEMALE*COMORB_NONE ; 
	CANC_65_69_M_comorb_1 = AGE_65_69*MALE*COMORB_1 ;	
	CANC_65_69_M_comorb_2 = AGE_65_69*MALE*COMORB_2 ; 	
	CANC_65_69_M_comorb_3 = AGE_65_69*MALE*COMORB_3 ; 	
	CANC_65_69_M_comorb_4_5	 = AGE_65_69*MALE*COMORB_4_5 ; 
	CANC_65_69_M_comorb_6  = AGE_65_69*MALE*COMORB_6 ; 	
	CANC_65_69_M_comorb_new_enroll	 = AGE_65_69*MALE*COMORB_NEW_ENROLL ; 
	CANC_65_69_M_comorb_none	 = AGE_65_69*MALE*COMORB_NONE ; 

	CANC_65_69_F_ct_y = AGE_65_69*FEMALE*CTY; 	
	CANC_65_69_F_ct_n = AGE_65_69*FEMALE*CTN; 		
	CANC_65_69_F_rad_y = AGE_65_69*FEMALE*RDY; 	
	CANC_65_69_F_rad_n = AGE_65_69*FEMALE*RDN; 		
	CANC_65_69_F_surg_y = AGE_65_69*FEMALE*SGY; 		
	CANC_65_69_F_surg_n	= AGE_65_69*FEMALE*SGN; 		
	CANC_65_69_F_bmt_al	= AGE_65_69*FEMALE*al; 		
	CANC_65_69_F_bmt_au	= AGE_65_69*FEMALE*au; 		
	CANC_65_69_F_bmt_none = AGE_65_69*FEMALE*anone; 			
	CANC_65_69_M_ct_y = AGE_65_69*MALE*CTY; 	
	CANC_65_69_M_ct_n = AGE_65_69*MALE*CTN; 		
	CANC_65_69_M_rad_y = AGE_65_69*MALE*RDY; 	
	CANC_65_69_M_rad_n = AGE_65_69*MALE*RDN; 		
	CANC_65_69_M_surg_y = AGE_65_69*MALE*SGY; 		
	CANC_65_69_M_surg_n	= AGE_65_69*MALE*SGN; 		
	CANC_65_69_M_bmt_al	= AGE_65_69*MALE*al; 		
	CANC_65_69_M_bmt_au	= AGE_65_69*MALE*au; 		
	CANC_65_69_M_bmt_none = AGE_65_69*MALE*anone; 			

	CANC_70_74_F_inst_y	= AGE_70_74*FEMALE*INSTY ;
	CANC_70_74_F_inst_n	= AGE_70_74*FEMALE*INSTN ;
	CANC_70_74_M_inst_y	= AGE_70_74*MALE*INSTY ;
	CANC_70_74_M_inst_n	= AGE_70_74*MALE*INSTN ;

	CANC_70_74_F_epi_180_181= AGE_70_74*FEMALE*EP_180_181 ;	
	CANC_70_74_F_epi_182_183 = 	AGE_70_74*FEMALE*EP_182_183 ;
	CANC_70_74_M_epi_180_181= AGE_70_74*MALE*EP_180_181 ;	
	CANC_70_74_M_epi_182_183 = 	AGE_70_74*MALE*EP_182_183 ;

	CANC_70_74_F_cp_1_61= AGE_70_74*FEMALE*CP_1_61;		
	CANC_70_74_F_cp_62_730	= AGE_70_74*FEMALE*CP_62_730 ; 
	CANC_70_74_F_cp_none = AGE_70_74*FEMALE*CP_NONE;
	CANC_70_74_M_cp_1_61= AGE_70_74*MALE*CP_1_61;		
	CANC_70_74_M_cp_62_730	= AGE_70_74*MALE*CP_62_730 ; 
	CANC_70_74_M_cp_none = AGE_70_74*MALE*CP_NONE	;

	CANC_70_74_F_enroll_full_dual= AGE_70_74*FEMALE*ENROLL_FULL_DUAL ;
	CANC_70_74_F_enroll_no_pd	= AGE_70_74*FEMALE*ENROLL_NO_PD ;
	CANC_70_74_F_enroll_pd_lis	= AGE_70_74*FEMALE*ENROLL_PD_LIS ;
	CANC_70_74_F_enroll_pd_no_lis	= AGE_70_74*FEMALE*ENROLL_PD_NO_LIS ;
	CANC_70_74_M_enroll_full_dual= AGE_70_74*MALE*ENROLL_FULL_DUAL ;
	CANC_70_74_M_enroll_no_pd	= AGE_70_74*MALE*ENROLL_NO_PD ;
	CANC_70_74_M_enroll_pd_lis	= AGE_70_74*MALE*ENROLL_PD_LIS ;
	CANC_70_74_M_enroll_pd_no_lis	= AGE_70_74*MALE*ENROLL_PD_NO_LIS ;

	CANC_70_74_F_comorb_1 = AGE_70_74*FEMALE*COMORB_1 ;	
	CANC_70_74_F_comorb_2 = AGE_70_74*FEMALE*COMORB_2 ; 	
	CANC_70_74_F_comorb_3 = AGE_70_74*FEMALE*COMORB_3 ; 	
	CANC_70_74_F_comorb_4_5	 = AGE_70_74*FEMALE*COMORB_4_5 ; 
	CANC_70_74_F_comorb_6  = AGE_70_74*FEMALE*COMORB_6 ; 	
	CANC_70_74_F_comorb_new_enroll	 = AGE_70_74*FEMALE*COMORB_NEW_ENROLL ; 
	CANC_70_74_F_comorb_none	 = AGE_70_74*FEMALE*COMORB_NONE ; 
	CANC_70_74_M_comorb_1 = AGE_70_74*MALE*COMORB_1 ;	
	CANC_70_74_M_comorb_2 = AGE_70_74*MALE*COMORB_2 ; 	
	CANC_70_74_M_comorb_3 = AGE_70_74*MALE*COMORB_3 ; 	
	CANC_70_74_M_comorb_4_5	 = AGE_70_74*MALE*COMORB_4_5 ; 
	CANC_70_74_M_comorb_6  = AGE_70_74*MALE*COMORB_6 ; 	
	CANC_70_74_M_comorb_new_enroll	 = AGE_70_74*MALE*COMORB_NEW_ENROLL ; 
	CANC_70_74_M_comorb_none	 = AGE_70_74*MALE*COMORB_NONE ; 

	CANC_70_74_F_ct_y = AGE_70_74*FEMALE*CTY; 	
	CANC_70_74_F_ct_n = AGE_70_74*FEMALE*CTN; 		
	CANC_70_74_F_rad_y = AGE_70_74*FEMALE*RDY; 	
	CANC_70_74_F_rad_n = AGE_70_74*FEMALE*RDN; 		
	CANC_70_74_F_surg_y = AGE_70_74*FEMALE*SGY; 		
	CANC_70_74_F_surg_n	= AGE_70_74*FEMALE*SGN; 		
	CANC_70_74_F_bmt_al	= AGE_70_74*FEMALE*al; 		
	CANC_70_74_F_bmt_au	= AGE_70_74*FEMALE*au; 		
	CANC_70_74_F_bmt_none = AGE_70_74*FEMALE*anone; 			
	CANC_70_74_M_ct_y = AGE_70_74*MALE*CTY; 	
	CANC_70_74_M_ct_n = AGE_70_74*MALE*CTN; 		
	CANC_70_74_M_rad_y = AGE_70_74*MALE*RDY; 	
	CANC_70_74_M_rad_n = AGE_70_74*MALE*RDN; 		
	CANC_70_74_M_surg_y = AGE_70_74*MALE*SGY; 		
	CANC_70_74_M_surg_n	= AGE_70_74*MALE*SGN; 		
	CANC_70_74_M_bmt_al	= AGE_70_74*MALE*al; 		
	CANC_70_74_M_bmt_au	= AGE_70_74*MALE*au; 		
	CANC_70_74_M_bmt_none = AGE_70_74*MALE*anone; 			

	CANC_75_79_F_inst_y	= AGE_75_79*FEMALE*INSTY ;
	CANC_75_79_F_inst_n	= AGE_75_79*FEMALE*INSTN ;
	CANC_75_79_M_inst_y	= AGE_75_79*MALE*INSTY ;
	CANC_75_79_M_inst_n	= AGE_75_79*MALE*INSTN ;

	CANC_75_79_F_epi_180_181= AGE_75_79*FEMALE*EP_180_181 ;	
	CANC_75_79_F_epi_182_183 = 	AGE_75_79*FEMALE*EP_182_183 ;
	CANC_75_79_M_epi_180_181= AGE_75_79*MALE*EP_180_181 ;	
	CANC_75_79_M_epi_182_183 = 	AGE_75_79*MALE*EP_182_183 ;

	CANC_75_79_F_cp_1_61= AGE_75_79*FEMALE*CP_1_61;		
	CANC_75_79_F_cp_62_730	= AGE_75_79*FEMALE*CP_62_730 ; 
	CANC_75_79_F_cp_none = AGE_75_79*FEMALE*CP_NONE	;
	CANC_75_79_M_cp_1_61= AGE_75_79*MALE*CP_1_61;		
	CANC_75_79_M_cp_62_730	= AGE_75_79*MALE*CP_62_730 ; 
	CANC_75_79_M_cp_none = AGE_75_79*MALE*CP_NONE	;

	CANC_75_79_F_enroll_full_dual= AGE_75_79*FEMALE*ENROLL_FULL_DUAL ;
	CANC_75_79_F_enroll_no_pd	= AGE_75_79*FEMALE*ENROLL_NO_PD ;
	CANC_75_79_F_enroll_pd_lis	= AGE_75_79*FEMALE*ENROLL_PD_LIS ;
	CANC_75_79_F_enroll_pd_no_lis	= AGE_75_79*FEMALE*ENROLL_PD_NO_LIS ;
	CANC_75_79_M_enroll_full_dual= AGE_75_79*MALE*ENROLL_FULL_DUAL ;
	CANC_75_79_M_enroll_no_pd	= AGE_75_79*MALE*ENROLL_NO_PD ;
	CANC_75_79_M_enroll_pd_lis	= AGE_75_79*MALE*ENROLL_PD_LIS ;
	CANC_75_79_M_enroll_pd_no_lis	= AGE_75_79*MALE*ENROLL_PD_NO_LIS ;

	CANC_75_79_F_comorb_1 = AGE_75_79*FEMALE*COMORB_1 ;	
	CANC_75_79_F_comorb_2 = AGE_75_79*FEMALE*COMORB_2 ; 	
	CANC_75_79_F_comorb_3 = AGE_75_79*FEMALE*COMORB_3 ; 	
	CANC_75_79_F_comorb_4_5	 = AGE_75_79*FEMALE*COMORB_4_5 ; 
	CANC_75_79_F_comorb_6  = AGE_75_79*FEMALE*COMORB_6 ; 	
	CANC_75_79_F_comorb_new_enroll	 = AGE_75_79*FEMALE*COMORB_NEW_ENROLL ; 
	CANC_75_79_F_comorb_none	 = AGE_75_79*FEMALE*COMORB_NONE ; 
	CANC_75_79_M_comorb_1 = AGE_75_79*MALE*COMORB_1 ;	
	CANC_75_79_M_comorb_2 = AGE_75_79*MALE*COMORB_2 ; 	
	CANC_75_79_M_comorb_3 = AGE_75_79*MALE*COMORB_3 ; 	
	CANC_75_79_M_comorb_4_5	 = AGE_75_79*MALE*COMORB_4_5 ; 
	CANC_75_79_M_comorb_6  = AGE_75_79*MALE*COMORB_6 ; 	
	CANC_75_79_M_comorb_new_enroll	 = AGE_75_79*MALE*COMORB_NEW_ENROLL ; 
	CANC_75_79_M_comorb_none	 = AGE_75_79*MALE*COMORB_NONE ; 

	CANC_75_79_F_ct_y = AGE_75_79*FEMALE*CTY; 	
	CANC_75_79_F_ct_n = AGE_75_79*FEMALE*CTN; 		
	CANC_75_79_F_rad_y = AGE_75_79*FEMALE*RDY; 	
	CANC_75_79_F_rad_n = AGE_75_79*FEMALE*RDN; 		
	CANC_75_79_F_surg_y = AGE_75_79*FEMALE*SGY; 		
	CANC_75_79_F_surg_n	= AGE_75_79*FEMALE*SGN; 		
	CANC_75_79_F_bmt_al	= AGE_75_79*FEMALE*al; 		
	CANC_75_79_F_bmt_au	= AGE_75_79*FEMALE*au; 		
	CANC_75_79_F_bmt_none = AGE_75_79*FEMALE*anone; 			
	CANC_75_79_M_ct_y = AGE_75_79*MALE*CTY; 	
	CANC_75_79_M_ct_n = AGE_75_79*MALE*CTN; 		
	CANC_75_79_M_rad_y = AGE_75_79*MALE*RDY; 	
	CANC_75_79_M_rad_n = AGE_75_79*MALE*RDN; 		
	CANC_75_79_M_surg_y = AGE_75_79*MALE*SGY; 		
	CANC_75_79_M_surg_n	= AGE_75_79*MALE*SGN; 		
	CANC_75_79_M_bmt_al	= AGE_75_79*MALE*al; 		
	CANC_75_79_M_bmt_au	= AGE_75_79*MALE*au; 		
	CANC_75_79_M_bmt_none = AGE_75_79*MALE*anone; 			

	CANC_80_F_inst_y	= AGE_80*FEMALE*INSTY ;
	CANC_80_F_inst_n	= AGE_80*FEMALE*INSTN ;
	CANC_80_M_inst_y	= AGE_80*MALE*INSTY ;
	CANC_80_M_inst_n	= AGE_80*MALE*INSTN ;

	CANC_80_F_epi_180_181= AGE_80*FEMALE*EP_180_181 ;	
	CANC_80_F_epi_182_183 = 	AGE_80*FEMALE*EP_182_183 ;
	CANC_80_M_epi_180_181= AGE_80*MALE*EP_180_181 ;	
	CANC_80_M_epi_182_183 = 	AGE_80*MALE*EP_182_183 ;

	CANC_80_F_cp_1_61= AGE_80*FEMALE*CP_1_61;		
	CANC_80_F_cp_62_730	= AGE_80*FEMALE*CP_62_730 ; 
	CANC_80_F_cp_none = AGE_80*FEMALE*CP_NONE	;
	CANC_80_M_cp_1_61= AGE_80*MALE*CP_1_61;		
	CANC_80_M_cp_62_730	= AGE_80*MALE*CP_62_730 ; 
	CANC_80_M_cp_none = AGE_80*MALE*CP_NONE;

	CANC_80_F_enroll_full_dual= AGE_80*FEMALE*ENROLL_FULL_DUAL ;
	CANC_80_F_enroll_no_pd	= AGE_80*FEMALE*ENROLL_NO_PD ;
	CANC_80_F_enroll_pd_lis	= AGE_80*FEMALE*ENROLL_PD_LIS ;
	CANC_80_F_enroll_pd_no_lis	= AGE_80*FEMALE*ENROLL_PD_NO_LIS ;
	CANC_80_M_enroll_full_dual= AGE_80*MALE*ENROLL_FULL_DUAL ;
	CANC_80_M_enroll_no_pd	= AGE_80*MALE*ENROLL_NO_PD ;
	CANC_80_M_enroll_pd_lis	= AGE_80*MALE*ENROLL_PD_LIS ;
	CANC_80_M_enroll_pd_no_lis	= AGE_80*MALE*ENROLL_PD_NO_LIS ;

	CANC_80_F_comorb_1 = AGE_80*FEMALE*COMORB_1 ;	
	CANC_80_F_comorb_2 = AGE_80*FEMALE*COMORB_2 ; 	
	CANC_80_F_comorb_3 = AGE_80*FEMALE*COMORB_3 ; 	
	CANC_80_F_comorb_4_5	 = AGE_80*FEMALE*COMORB_4_5 ; 
	CANC_80_F_comorb_6  = AGE_80*FEMALE*COMORB_6 ; 	
	CANC_80_F_comorb_new_enroll	 = AGE_80*FEMALE*COMORB_NEW_ENROLL ; 
	CANC_80_F_comorb_none	 = AGE_80*FEMALE*COMORB_NONE ; 
	CANC_80_M_comorb_1 = AGE_80*MALE*COMORB_1 ;	
	CANC_80_M_comorb_2 = AGE_80*MALE*COMORB_2 ; 	
	CANC_80_M_comorb_3 = AGE_80*MALE*COMORB_3 ; 	
	CANC_80_M_comorb_4_5	 = AGE_80*MALE*COMORB_4_5 ; 
	CANC_80_M_comorb_6  = AGE_80*MALE*COMORB_6 ; 	
	CANC_80_M_comorb_new_enroll	 = AGE_80*MALE*COMORB_NEW_ENROLL ; 
	CANC_80_M_comorb_none	 = AGE_80*MALE*COMORB_NONE ; 

	CANC_80_F_ct_y = AGE_80*FEMALE*CTY; 	
	CANC_80_F_ct_n = AGE_80*FEMALE*CTN; 		
	CANC_80_F_rad_y = AGE_80*FEMALE*RDY; 	
	CANC_80_F_rad_n = AGE_80*FEMALE*RDN; 		
	CANC_80_F_surg_y = AGE_80*FEMALE*SGY; 		
	CANC_80_F_surg_n	= AGE_80*FEMALE*SGN; 		
	CANC_80_F_bmt_al	= AGE_80*FEMALE*al; 		
	CANC_80_F_bmt_au	= AGE_80*FEMALE*au; 		
	CANC_80_F_bmt_none = AGE_80*FEMALE*anone; 			
	CANC_80_M_ct_y = AGE_80*MALE*CTY; 	
	CANC_80_M_ct_n = AGE_80*MALE*CTN; 		
	CANC_80_M_rad_y = AGE_80*MALE*RDY; 	
	CANC_80_M_rad_n = AGE_80*MALE*RDN; 		
	CANC_80_M_surg_y = AGE_80*MALE*SGY; 		
	CANC_80_M_surg_n	= AGE_80*MALE*SGN; 		
	CANC_80_M_bmt_al	= AGE_80*MALE*al; 		
	CANC_80_M_bmt_au	= AGE_80*MALE*au; 		
	CANC_80_M_bmt_none = AGE_80*MALE*anone; 			


************************************************************************** ;
	%MACRO CN(CN,C) ;
	
	IF CANCER_TYPE = "&cn." THEN DO ;

			*** DENOMINATOR VARIABLES *** ;
			&C._18_64_F = episode_count*female*age_18_64 ;
			&C._18_64_M = episode_count*male*age_18_64 ;
			&C._65_69_F = episode_count*female*age_65_69 ;
			&C._65_69_M = episode_count*male*age_65_69 ;
			&C._70_74_F = episode_count*female*age_70_74 ;
			&C._70_74_M = episode_count*male*age_70_74 ;
			&C._75_79_F = episode_count*female*age_75_79 ;
			&C._75_79_M = episode_count*male*age_75_79 ;
			&C._80_F = episode_count*female*age_80 ;
			&C._80_M = episode_count*male*age_80 ;


			*** PREDICTION VARIABLES *** ;
			&C._18_64_F_inst_y	= CANC_18_64_F_inst_y	;
			&C._18_64_F_inst_n = CANC_18_64_F_inst_n	;
			&C._18_64_M_inst_y = CANC_18_64_M_inst_y	;
			&C._18_64_M_inst_n	= CANC_18_64_M_inst_n	;

			&C._18_64_F_epi_180_181 = CANC_18_64_F_epi_180_181;
			&C._18_64_F_epi_182_183 = CANC_18_64_F_epi_182_183;
			&C._18_64_M_epi_180_181 = CANC_18_64_M_epi_180_181;
			&C._18_64_M_epi_182_183 = CANC_18_64_M_epi_182_183;

			&C._18_64_F_cp_1_61=CANC_18_64_F_cp_1_61;
			&C._18_64_F_cp_62_730=CANC_18_64_F_cp_62_730;
			&C._18_64_F_cp_none=CANC_18_64_F_cp_none ;
			&C._18_64_M_cp_1_61=CANC_18_64_M_cp_1_61;
			&C._18_64_M_cp_62_730 = CANC_18_64_M_cp_62_730;
			&C._18_64_M_cp_none=CANC_18_64_M_cp_none ;

			&C._18_64_F_enroll_full_dual=CANC_18_64_F_enroll_full_dual;
			&C._18_64_F_enroll_no_pd=CANC_18_64_F_enroll_no_pd	;
			&C._18_64_F_enroll_pd_lis=CANC_18_64_F_enroll_pd_lis	;
			&C._18_64_F_enroll_pd_no_lis=CANC_18_64_F_enroll_pd_no_lis;
			&C._18_64_M_enroll_full_dual=CANC_18_64_M_enroll_full_dual;
			&C._18_64_M_enroll_no_pd=CANC_18_64_M_enroll_no_pd	;
			&C._18_64_M_enroll_pd_lis=CANC_18_64_M_enroll_pd_lis	;
			&C._18_64_M_enroll_pd_no_lis=CANC_18_64_M_enroll_pd_no_lis;	

			&C._18_64_F_comorb_1=CANC_18_64_F_comorb_1 ;
			&C._18_64_F_comorb_2=CANC_18_64_F_comorb_2 ;
			&C._18_64_F_comorb_3=CANC_18_64_F_comorb_3 ;
			&C._18_64_F_comorb_4_5=CANC_18_64_F_comorb_4_5; 
			&C._18_64_F_comorb_6 =CANC_18_64_F_comorb_6  ; 	
			&C._18_64_F_comorb_new_enroll=CANC_18_64_F_comorb_new_enroll	 ; 
			&C._18_64_F_comorb_none=CANC_18_64_F_comorb_none	 ; 
			&C._18_64_M_comorb_1 = CANC_18_64_M_comorb_1;	
			&C._18_64_M_comorb_2 = CANC_18_64_M_comorb_2; 	
			&C._18_64_M_comorb_3 = CANC_18_64_M_comorb_3; 	
			&C._18_64_M_comorb_4_5 =CANC_18_64_M_comorb_4_5	 ; 
			&C._18_64_M_comorb_6 = CANC_18_64_M_comorb_6  ; 	
			&C._18_64_M_comorb_new_enroll = CANC_18_64_M_comorb_new_enroll	 ; 
			&C._18_64_M_comorb_none = CANC_18_64_M_comorb_none	 ; 

			&C._18_64_F_ct_y=CANC_18_64_F_ct_y ; 	
			&C._18_64_F_ct_n=CANC_18_64_F_ct_n ; 		
			&C._18_64_F_rad_y=CANC_18_64_F_rad_y ; 	
			&C._18_64_F_rad_n=CANC_18_64_F_rad_n ; 		
			&C._18_64_F_surg_y=CANC_18_64_F_surg_y ; 		
			&C._18_64_F_surg_n=CANC_18_64_F_surg_n	; 		
			&C._18_64_F_bmt_al=CANC_18_64_F_bmt_al	; 		
			&C._18_64_F_bmt_au=CANC_18_64_F_bmt_au	; 		
			&C._18_64_F_bmt_none=CANC_18_64_F_bmt_none ; 			
			&C._18_64_M_ct_y=CANC_18_64_M_ct_y ; 	
			&C._18_64_M_ct_n=CANC_18_64_M_ct_n ; 		
			&C._18_64_M_rad_y=CANC_18_64_M_rad_y ; 	
			&C._18_64_M_rad_n=CANC_18_64_M_rad_n ; 		
			&C._18_64_M_surg_y=CANC_18_64_M_surg_y ; 		
			&C._18_64_M_surg_n	=CANC_18_64_M_surg_n	; 		
			&C._18_64_M_bmt_al	=CANC_18_64_M_bmt_al	; 		
			&C._18_64_M_bmt_au=CANC_18_64_M_bmt_au	; 		
			&C._18_64_M_bmt_none=CANC_18_64_M_bmt_none ; 			

			&C._65_69_F_inst_y=CANC_65_69_F_inst_y	;
			&C._65_69_F_inst_n=CANC_65_69_F_inst_n	;
			&C._65_69_M_inst_y=CANC_65_69_M_inst_y	;
			&C._65_69_M_inst_n=CANC_65_69_M_inst_n	;

			&C._65_69_F_epi_180_181=CANC_65_69_F_epi_180_181;	
			&C._65_69_F_epi_182_183=CANC_65_69_F_epi_182_183;
			&C._65_69_M_epi_180_181=CANC_65_69_M_epi_180_181;	
			&C._65_69_M_epi_182_183=CANC_65_69_M_epi_182_183;

			&C._65_69_F_cp_1_61=CANC_65_69_F_cp_1_61;		
			&C._65_69_F_cp_62_730=CANC_65_69_F_cp_62_730; 
			&C._65_69_F_cp_none=CANC_65_69_F_cp_none ;
			&C._65_69_M_cp_1_61=CANC_65_69_M_cp_1_61;		
			&C._65_69_M_cp_62_730=CANC_65_69_M_cp_62_730; 
			&C._65_69_M_cp_none=CANC_65_69_M_cp_none ;

			&C._65_69_F_enroll_full_dual=CANC_65_69_F_enroll_full_dual;
			&C._65_69_F_enroll_no_pd=CANC_65_69_F_enroll_no_pd	;
			&C._65_69_F_enroll_pd_lis=CANC_65_69_F_enroll_pd_lis	;
			&C._65_69_F_enroll_pd_no_lis=CANC_65_69_F_enroll_pd_no_lis	;
			&C._65_69_M_enroll_full_dual=CANC_65_69_M_enroll_full_dual;
			&C._65_69_M_enroll_no_pd=CANC_65_69_M_enroll_no_pd	;
			&C._65_69_M_enroll_pd_lis=CANC_65_69_M_enroll_pd_lis	;
			&C._65_69_M_enroll_pd_no_lis=CANC_65_69_M_enroll_pd_no_lis;

			&C._65_69_F_comorb_1=CANC_65_69_F_comorb_1 ;	
			&C._65_69_F_comorb_2=CANC_65_69_F_comorb_2 ; 	
			&C._65_69_F_comorb_3=CANC_65_69_F_comorb_3 ; 	
			&C._65_69_F_comorb_4_5=CANC_65_69_F_comorb_4_5	; 
			&C._65_69_F_comorb_6=CANC_65_69_F_comorb_6  ; 	
			&C._65_69_F_comorb_new_enroll=CANC_65_69_F_comorb_new_enroll	 ; 
			&C._65_69_F_comorb_none=CANC_65_69_F_comorb_none	 ; 
			&C._65_69_M_comorb_1=CANC_65_69_M_comorb_1  ;	
			&C._65_69_M_comorb_2=CANC_65_69_M_comorb_2 ; 	
			&C._65_69_M_comorb_3=CANC_65_69_M_comorb_3 ; 	
			&C._65_69_M_comorb_4_5=CANC_65_69_M_comorb_4_5	; 
			&C._65_69_M_comorb_6=CANC_65_69_M_comorb_6  ; 	
			&C._65_69_M_comorb_new_enroll=CANC_65_69_M_comorb_new_enroll	  ; 
			&C._65_69_M_comorb_none=CANC_65_69_M_comorb_none	 ; 

			&C._65_69_F_ct_y=CANC_65_69_F_ct_y ; 	
			&C._65_69_F_ct_n=CANC_65_69_F_ct_n ; 		
			&C._65_69_F_rad_y=CANC_65_69_F_rad_y; 	
			&C._65_69_F_rad_n=CANC_65_69_F_rad_n ; 		
			&C._65_69_F_surg_y=CANC_65_69_F_surg_y; 		
			&C._65_69_F_surg_n=CANC_65_69_F_surg_n	; 		
			&C._65_69_F_bmt_al=CANC_65_69_F_bmt_al	; 		
			&C._65_69_F_bmt_au=CANC_65_69_F_bmt_au	; 		
			&C._65_69_F_bmt_none=CANC_65_69_F_bmt_none ; 			
			&C._65_69_M_ct_y=CANC_65_69_M_ct_y  ; 	
			&C._65_69_M_ct_n=CANC_65_69_M_ct_n  ; 		
			&C._65_69_M_rad_y=CANC_65_69_M_rad_y  ; 	
			&C._65_69_M_rad_n=CANC_65_69_M_rad_n  ; 		
			&C._65_69_M_surg_y=CANC_65_69_M_surg_y  ; 		
			&C._65_69_M_surg_n=CANC_65_69_M_surg_n	 ; 		
			&C._65_69_M_bmt_al	=CANC_65_69_M_bmt_al	 ; 		
			&C._65_69_M_bmt_au	=CANC_65_69_M_bmt_au	 ; 		
			&C._65_69_M_bmt_none=CANC_65_69_M_bmt_none  ; 			

			&C._70_74_F_inst_y=CANC_70_74_F_inst_y	;
			&C._70_74_F_inst_n=CANC_70_74_F_inst_n	;
			&C._70_74_M_inst_y	=CANC_70_74_M_inst_y	;
			&C._70_74_M_inst_n	=CANC_70_74_M_inst_n	;

			&C._70_74_F_epi_180_181=CANC_70_74_F_epi_180_181;	
			&C._70_74_F_epi_182_183=CANC_70_74_F_epi_182_183;
			&C._70_74_M_epi_180_181=CANC_70_74_M_epi_180_181;	
			&C._70_74_M_epi_182_183=CANC_70_74_M_epi_182_183;

			&C._70_74_F_cp_1_61=CANC_70_74_F_cp_1_61;		
			&C._70_74_F_cp_62_730=CANC_70_74_F_cp_62_730; 
			&C._70_74_F_cp_none=CANC_70_74_F_cp_none;
			&C._70_74_M_cp_1_61=CANC_70_74_M_cp_1_61;		
			&C._70_74_M_cp_62_730=CANC_70_74_M_cp_62_730; 
			&C._70_74_M_cp_none=CANC_70_74_M_cp_none ;

			&C._70_74_F_enroll_full_dual=CANC_70_74_F_enroll_full_dual;
			&C._70_74_F_enroll_no_pd=CANC_70_74_F_enroll_no_pd;
			&C._70_74_F_enroll_pd_lis=CANC_70_74_F_enroll_pd_lis;
			&C._70_74_F_enroll_pd_no_lis=CANC_70_74_F_enroll_pd_no_lis;
			&C._70_74_M_enroll_full_dual=CANC_70_74_M_enroll_full_dual;
			&C._70_74_M_enroll_no_pd=CANC_70_74_M_enroll_no_pd	;
			&C._70_74_M_enroll_pd_lis=CANC_70_74_M_enroll_pd_lis	;
			&C._70_74_M_enroll_pd_no_lis=CANC_70_74_M_enroll_pd_no_lis;

			&C._70_74_F_comorb_1=CANC_70_74_F_comorb_1 ;	
			&C._70_74_F_comorb_2=CANC_70_74_F_comorb_2 ; 	
			&C._70_74_F_comorb_3=CANC_70_74_F_comorb_3 ; 	
			&C._70_74_F_comorb_4_5=CANC_70_74_F_comorb_4_5	; 
			&C._70_74_F_comorb_6=CANC_70_74_F_comorb_6 ; 	
			&C._70_74_F_comorb_new_enroll=CANC_70_74_F_comorb_new_enroll	 ; 
			&C._70_74_F_comorb_none=CANC_70_74_F_comorb_none	 ; 
			&C._70_74_M_comorb_1=CANC_70_74_M_comorb_1 ;	
			&C._70_74_M_comorb_2=CANC_70_74_M_comorb_2 ; 	
			&C._70_74_M_comorb_3=CANC_70_74_M_comorb_3 ; 	
			&C._70_74_M_comorb_4_5=CANC_70_74_M_comorb_4_5	 ; 
			&C._70_74_M_comorb_6=CANC_70_74_M_comorb_6  ; 	
			&C._70_74_M_comorb_new_enroll=CANC_70_74_M_comorb_new_enroll	 ; 
			&C._70_74_M_comorb_none=CANC_70_74_M_comorb_none	  ; 

			&C._70_74_F_ct_y=CANC_70_74_F_ct_y ; 	
			&C._70_74_F_ct_n=CANC_70_74_F_ct_n ; 		
			&C._70_74_F_rad_y=CANC_70_74_F_rad_y; 	
			&C._70_74_F_rad_n=CANC_70_74_F_rad_n ; 		
			&C._70_74_F_surg_y=CANC_70_74_F_surg_y ; 		
			&C._70_74_F_surg_n=CANC_70_74_F_surg_n	; 		
			&C._70_74_F_bmt_al=CANC_70_74_F_bmt_al	; 		
			&C._70_74_F_bmt_au=CANC_70_74_F_bmt_au	; 		
			&C._70_74_F_bmt_none=CANC_70_74_F_bmt_none ; 			
			&C._70_74_M_ct_y=CANC_70_74_M_ct_y  ; 	
			&C._70_74_M_ct_n=CANC_70_74_M_ct_n  ; 		
			&C._70_74_M_rad_y=CANC_70_74_M_rad_y ; 	
			&C._70_74_M_rad_n=CANC_70_74_M_rad_n  ; 		
			&C._70_74_M_surg_y=CANC_70_74_M_surg_y  ; 		
			&C._70_74_M_surg_n=CANC_70_74_M_surg_n	 ; 		
			&C._70_74_M_bmt_al=CANC_70_74_M_bmt_al	 ; 		
			&C._70_74_M_bmt_au=CANC_70_74_M_bmt_au	 ; 		
			&C._70_74_M_bmt_none=CANC_70_74_M_bmt_none ; 			

			&C._75_79_F_inst_y=CANC_75_79_F_inst_y	 ;
			&C._75_79_F_inst_n=CANC_75_79_F_inst_n	 ;
			&C._75_79_M_inst_y=CANC_75_79_M_inst_y	 ;
			&C._75_79_M_inst_n=CANC_75_79_M_inst_n	;

			&C._75_79_F_epi_180_181=CANC_75_79_F_epi_180_181;	
			&C._75_79_F_epi_182_183=CANC_75_79_F_epi_182_183;
			&C._75_79_M_epi_180_181=CANC_75_79_M_epi_180_181 ;	
			&C._75_79_M_epi_182_183=CANC_75_79_M_epi_182_183;

			&C._75_79_F_cp_1_61=CANC_75_79_F_cp_1_61;		
			&C._75_79_F_cp_62_730=CANC_75_79_F_cp_62_730	; 
			&C._75_79_F_cp_none=CANC_75_79_F_cp_none ;
			&C._75_79_M_cp_1_61=CANC_75_79_M_cp_1_61;		
			&C._75_79_M_cp_62_730=CANC_75_79_M_cp_62_730; 
			&C._75_79_M_cp_none=CANC_75_79_M_cp_none ;

			&C._75_79_F_enroll_full_dual=CANC_75_79_F_enroll_full_dual ;
			&C._75_79_F_enroll_no_pd=CANC_75_79_F_enroll_no_pd;
			&C._75_79_F_enroll_pd_lis=CANC_75_79_F_enroll_pd_lis;
			&C._75_79_F_enroll_pd_no_lis=CANC_75_79_F_enroll_pd_no_lis;
			&C._75_79_M_enroll_full_dual=CANC_75_79_M_enroll_full_dual;
			&C._75_79_M_enroll_no_pd=CANC_75_79_M_enroll_no_pd	;
			&C._75_79_M_enroll_pd_lis=CANC_75_79_M_enroll_pd_lis	;
			&C._75_79_M_enroll_pd_no_lis=CANC_75_79_M_enroll_pd_no_lis;

			&C._75_79_F_comorb_1 =CANC_75_79_F_comorb_1  ;	
			&C._75_79_F_comorb_2 = CANC_75_79_F_comorb_2 ; 	
			&C._75_79_F_comorb_3 = CANC_75_79_F_comorb_3 ; 	
			&C._75_79_F_comorb_4_5 = CANC_75_79_F_comorb_4_5; 
			&C._75_79_F_comorb_6 = CANC_75_79_F_comorb_6  ; 	
			&C._75_79_F_comorb_new_enroll = CANC_75_79_F_comorb_new_enroll	 ; 
			&C._75_79_F_comorb_none = CANC_75_79_F_comorb_none	 ; 
			&C._75_79_M_comorb_1 = CANC_75_79_M_comorb_1  ;	
			&C._75_79_M_comorb_2 = CANC_75_79_M_comorb_2  ; 	
			&C._75_79_M_comorb_3 = CANC_75_79_M_comorb_3  ; 	
			&C._75_79_M_comorb_4_5 = CANC_75_79_M_comorb_4_5	 ; 
			&C._75_79_M_comorb_6 = CANC_75_79_M_comorb_6 ; 	
			&C._75_79_M_comorb_new_enroll = CANC_75_79_M_comorb_new_enroll	 ; 
			&C._75_79_M_comorb_none = CANC_75_79_M_comorb_none	  ; 

			&C._75_79_F_ct_y=CANC_75_79_F_ct_y ; 	
			&C._75_79_F_ct_n=CANC_75_79_F_ct_n ; 		
			&C._75_79_F_rad_y=CANC_75_79_F_rad_y; 	
			&C._75_79_F_rad_n=CANC_75_79_F_rad_n; 		
			&C._75_79_F_surg_y=CANC_75_79_F_surg_y; 		
			&C._75_79_F_surg_n=CANC_75_79_F_surg_n; 		
			&C._75_79_F_bmt_al=CANC_75_79_F_bmt_al; 		
			&C._75_79_F_bmt_au=CANC_75_79_F_bmt_au; 		
			&C._75_79_F_bmt_none=CANC_75_79_F_bmt_none; 			
			&C._75_79_M_ct_y=CANC_75_79_M_ct_y ; 	
			&C._75_79_M_ct_n=CANC_75_79_M_ct_n ; 		
			&C._75_79_M_rad_y=CANC_75_79_M_rad_y ; 	
			&C._75_79_M_rad_n=CANC_75_79_M_rad_n ; 		
			&C._75_79_M_surg_y=CANC_75_79_M_surg_y ; 		
			&C._75_79_M_surg_n=CANC_75_79_M_surg_n	; 		
			&C._75_79_M_bmt_al=CANC_75_79_M_bmt_al	; 		
			&C._75_79_M_bmt_au=CANC_75_79_M_bmt_au	; 		
			&C._75_79_M_bmt_none=CANC_75_79_M_bmt_none; 			

			&C._80_F_inst_y = CANC_80_F_inst_y	 ;
			&C._80_F_inst_n = CANC_80_F_inst_n	 ;
			&C._80_M_inst_y = CANC_80_M_inst_y	;
			&C._80_M_inst_n = CANC_80_M_inst_n	;

			&C._80_F_epi_180_181= CANC_80_F_epi_180_181;	
			&C._80_F_epi_182_183 = CANC_80_F_epi_182_183;
			&C._80_M_epi_180_181 = CANC_80_M_epi_180_181;	
			&C._80_M_epi_182_183 = CANC_80_M_epi_182_183;

			&C._80_F_cp_1_61=CANC_80_F_cp_1_61;		
			&C._80_F_cp_62_730=CANC_80_F_cp_62_730; 
			&C._80_F_cp_none=CANC_80_F_cp_none ;
			&C._80_M_cp_1_61=CANC_80_M_cp_1_61;		
			&C._80_M_cp_62_730=CANC_80_M_cp_62_730	; 
			&C._80_M_cp_none=CANC_80_M_cp_none 	;

			&C._80_F_enroll_full_dual = CANC_80_F_enroll_full_dual;
			&C._80_F_enroll_no_pd = CANC_80_F_enroll_no_pd	;
			&C._80_F_enroll_pd_lis = CANC_80_F_enroll_pd_lis	;
			&C._80_F_enroll_pd_no_lis = CANC_80_F_enroll_pd_no_lis;
			&C._80_M_enroll_full_dual = CANC_80_M_enroll_full_dual;
			&C._80_M_enroll_no_pd = CANC_80_M_enroll_no_pd	;
			&C._80_M_enroll_pd_lis = CANC_80_M_enroll_pd_lis	;
			&C._80_M_enroll_pd_no_lis = CANC_80_M_enroll_pd_no_lis;

			&C._80_F_comorb_1=CANC_80_F_comorb_1 ;	
			&C._80_F_comorb_2=CANC_80_F_comorb_2 ; 	
			&C._80_F_comorb_3=CANC_80_F_comorb_3 ; 	
			&C._80_F_comorb_4_5=CANC_80_F_comorb_4_5; 
			&C._80_F_comorb_6=CANC_80_F_comorb_6  ; 	
			&C._80_F_comorb_new_enroll=CANC_80_F_comorb_new_enroll	  ; 
			&C._80_F_comorb_none=CANC_80_F_comorb_none	 ; 
			&C._80_M_comorb_1=CANC_80_M_comorb_1 ;	
			&C._80_M_comorb_2=CANC_80_M_comorb_2 ; 	
			&C._80_M_comorb_3=CANC_80_M_comorb_3 ; 	
			&C._80_M_comorb_4_5=CANC_80_M_comorb_4_5; 
			&C._80_M_comorb_6=CANC_80_M_comorb_6  ; 	
			&C._80_M_comorb_new_enroll=CANC_80_M_comorb_new_enroll	 ; 
			&C._80_M_comorb_none=CANC_80_M_comorb_none	 ; 

			&C._80_F_ct_y=CANC_80_F_ct_y ; 	
			&C._80_F_ct_n=CANC_80_F_ct_n ; 		
			&C._80_F_rad_y=CANC_80_F_rad_y ; 	
			&C._80_F_rad_n=CANC_80_F_rad_n ; 		
			&C._80_F_surg_y=CANC_80_F_surg_y ; 		
			&C._80_F_surg_n=CANC_80_F_surg_n; 		
			&C._80_F_bmt_al=CANC_80_F_bmt_al; 		
			&C._80_F_bmt_au=CANC_80_F_bmt_au; 		
			&C._80_F_bmt_none=CANC_80_F_bmt_none ; 			
			&C._80_M_ct_y=CANC_80_M_ct_y ; 	
			&C._80_M_ct_n=CANC_80_M_ct_n ; 		
			&C._80_M_rad_y=CANC_80_M_rad_y ; 	
			&C._80_M_rad_n=CANC_80_M_rad_n ; 		
			&C._80_M_surg_y=CANC_80_M_surg_y ; 		
			&C._80_M_surg_n=CANC_80_M_surg_n; 		
			&C._80_M_bmt_al=CANC_80_M_bmt_al; 		
			&C._80_M_bmt_au=CANC_80_M_bmt_au; 		
			&C._80_M_bmt_none=CANC_80_M_bmt_none; 			
	end ;

%mend ;
************************************************************************************ ;
*** Break out episode by cancer *** ;

 *CN(CN,C);
 
DATA STEP2 ;

	SET STEP1 ;

	%CN(Acute Leukemia,ACLU) ; 
	%CN(Anal Cancer,ANAL) ;
	%CN(Bladder Cancer,BLAD) ;
	%CN(Breast Cancer,BRST) ;
	%CN(Chronic Leukemia,CRLU) ;
	%CN(CNS Tumor,CNS) ;
	%CN(Endocrine Tumor,ENDO) ;
	%CN(Female GU Cancer other than Ovary,FEML) ;
	%CN(Gastro/Esophageal Cancer,GAST) ;
	%CN(Head and Neck Cancer,HEAD) ;
	%CN(Intestinal, INTS) ;
	%CN(Kidney Cancer,KIDN) ;
	%CN(Liver Cancer,LIVR) ;
	%CN(Lung Cancer, LUNG) ;
	%CN(Lymphoma, LYMP) ;
	%CN(Malignant Melanoma,MALM) ;
	%CN(MDS, MDS) ;
	%CN(Multiple Myeloma,MULM) ;
	%CN(Ovarian Cancer,OVAR) ;
	%CN(Pancreatic Cancer,PANC) ;
	%CN(Prostate Cancer,PROS) ;

PROC MEANS DATA=STEP2 NOPRINT SUM ;
	VAR ACLU: ANAL: BLAD: BRST: CRLU: CNS: ENDO: FEML: GAST: HEAD: INTS: KIDN: LIVR: LUNG: LYMP:
	    MALM: MDS: MULM: OVAR: PANC: PROS: ;
	OUTPUT OUT=ONEREC (DROP = _TYPE_ _FREQ_)
		   SUM() = ;


DATA r2.PREDICT_MODEL_VARS_ACLU(keep = aclu:)
	 r2.PREDICT_MODEL_VARS_ANAL(keep = ANAL:)
	 r2.PREDICT_MODEL_VARS_BLAD(keep = BLAD:)
	 r2.PREDICT_MODEL_VARS_BRST(keep = BRST:)
	 r2.PREDICT_MODEL_VARS_CRLU(keep = CRLU:)
	 r2.PREDICT_MODEL_VARS_CNS(keep = CNS:)
	 r2.PREDICT_MODEL_VARS_ENDO(keep = ENDO:)
	 r2.PREDICT_MODEL_VARS_FEML(keep = FEML:)
	 r2.PREDICT_MODEL_VARS_GAST(keep = GAST:)
	 r2.PREDICT_MODEL_VARS_HEAD(keep = HEAD:)
	 r2.PREDICT_MODEL_VARS_INTS(keep = INTS:)
	 r2.PREDICT_MODEL_VARS_KIDN(keep = KIDN:)
	 r2.PREDICT_MODEL_VARS_LIVR(keep = LIVR:)
	 r2.PREDICT_MODEL_VARS_LUNG(keep = LUNG:)
	 r2.PREDICT_MODEL_VARS_LYMP(keep = LYMP:)
	 r2.PREDICT_MODEL_VARS_MALM(keep = MALM:)
	 r2.PREDICT_MODEL_VARS_MULM(keep = MULM:)
	 r2.PREDICT_MODEL_VARS_MDS(keep = MDS:)
	 r2.PREDICT_MODEL_VARS_OVAR(keep = OVAR:)
	 r2.PREDICT_MODEL_VARS_PANC(keep = PANC:)
	 r2.PREDICT_MODEL_VARS_PROS(keep = PROS:);

	SET ONEREC ;

	FORMAT ACLU: ANAL: BLAD: BRST: CRLU: CNS: ENDO: FEML: GAST: HEAD: INTS: KIDN: LIVR: LUNG: LYMP:
	       MALM: MULM: MDS: OVAR: PANC: PROS: 10.4 ;

	%macro SETUP(c) ;

			&C._18_64_F_inst_y = &C._18_64_F_inst_y/&C._18_64_F ;	
			&C._18_64_F_inst_n = &C._18_64_F_inst_n/&C._18_64_F 	;
			&C._18_64_M_inst_y = &C._18_64_M_inst_y/&C._18_64_M	;
			&C._18_64_M_inst_n	= &C._18_64_M_inst_n/&C._18_64_M	;

			&C._18_64_F_epi_180_181 = &C._18_64_F_epi_180_181/&C._18_64_F ;
			&C._18_64_F_epi_182_183 = &C._18_64_F_epi_182_183/&C._18_64_F ;
			&C._18_64_M_epi_180_181 = &C._18_64_M_epi_180_181/&C._18_64_M;
			&C._18_64_M_epi_182_183 = &C._18_64_M_epi_182_183/&C._18_64_M;

			&C._18_64_F_cp_1_61=&C._18_64_F_cp_1_61/&C._18_64_F ;
			&C._18_64_F_cp_62_730=&C._18_64_F_cp_62_730/&C._18_64_F ;
			&C._18_64_F_cp_none=&C._18_64_F_cp_none/&C._18_64_F  ;
			&C._18_64_M_cp_1_61=&C._18_64_M_cp_1_61/&C._18_64_M;
			&C._18_64_M_cp_62_730 = &C._18_64_M_cp_62_730/&C._18_64_M;
			&C._18_64_M_cp_none=&C._18_64_M_cp_none/&C._18_64_M ;

			&C._18_64_F_enroll_full_dual=&C._18_64_F_enroll_full_dual/&C._18_64_F ;
			&C._18_64_F_enroll_no_pd=&C._18_64_F_enroll_no_pd/&C._18_64_F 	;
			&C._18_64_F_enroll_pd_lis=&C._18_64_F_enroll_pd_lis/&C._18_64_F 	;
			&C._18_64_F_enroll_pd_no_lis=&C._18_64_F_enroll_pd_no_lis/&C._18_64_F ;
			&C._18_64_M_enroll_full_dual=&C._18_64_M_enroll_full_dual/&C._18_64_M;
			&C._18_64_M_enroll_no_pd=&C._18_64_M_enroll_no_pd/&C._18_64_M	;
			&C._18_64_M_enroll_pd_lis=&C._18_64_M_enroll_pd_lis/&C._18_64_M	;
			&C._18_64_M_enroll_pd_no_lis=&C._18_64_M_enroll_pd_no_lis/&C._18_64_M;	

			&C._18_64_F_comorb_1=&C._18_64_F_comorb_1/&C._18_64_F  ;
			&C._18_64_F_comorb_2=&C._18_64_F_comorb_2/&C._18_64_F  ;
			&C._18_64_F_comorb_3=&C._18_64_F_comorb_3/&C._18_64_F  ;
			&C._18_64_F_comorb_4_5=&C._18_64_F_comorb_4_5/&C._18_64_F ; 
			&C._18_64_F_comorb_6 =&C._18_64_F_comorb_6/&C._18_64_F   ; 	
			&C._18_64_F_comorb_new_enroll=&C._18_64_F_comorb_new_enroll/&C._18_64_F 	 ; 
			&C._18_64_F_comorb_none=&C._18_64_F_comorb_none/&C._18_64_F 	 ; 
			&C._18_64_M_comorb_1 = &C._18_64_M_comorb_1/&C._18_64_M;	
			&C._18_64_M_comorb_2 = &C._18_64_M_comorb_2/&C._18_64_M; 	
			&C._18_64_M_comorb_3 = &C._18_64_M_comorb_3/&C._18_64_M; 	
			&C._18_64_M_comorb_4_5 =&C._18_64_M_comorb_4_5/&C._18_64_M	 ; 
			&C._18_64_M_comorb_6 = &C._18_64_M_comorb_6/&C._18_64_M  ; 	
			&C._18_64_M_comorb_new_enroll = &C._18_64_M_comorb_new_enroll/&C._18_64_M	 ; 
			&C._18_64_M_comorb_none = &C._18_64_M_comorb_none/&C._18_64_M	 ; 

			&C._18_64_F_ct_y=&C._18_64_F_ct_y/&C._18_64_F  ; 	
			&C._18_64_F_ct_n=&C._18_64_F_ct_n/&C._18_64_F  ; 		
			&C._18_64_F_rad_y=&C._18_64_F_rad_y/&C._18_64_F  ; 	
			&C._18_64_F_rad_n=&C._18_64_F_rad_n/&C._18_64_F  ; 		
			&C._18_64_F_surg_y=&C._18_64_F_surg_y/&C._18_64_F  ; 		
			&C._18_64_F_surg_n=&C._18_64_F_surg_n/&C._18_64_F 	; 		
			&C._18_64_F_bmt_al=&C._18_64_F_bmt_al/&C._18_64_F 	; 		
			&C._18_64_F_bmt_au=&C._18_64_F_bmt_au/&C._18_64_F 	; 		
			&C._18_64_F_bmt_none=&C._18_64_F_bmt_none/&C._18_64_F  ; 			
			&C._18_64_M_ct_y=&C._18_64_M_ct_y/&C._18_64_M ; 	
			&C._18_64_M_ct_n=&C._18_64_M_ct_n/&C._18_64_M ; 		
			&C._18_64_M_rad_y=&C._18_64_M_rad_y/&C._18_64_M ; 	
			&C._18_64_M_rad_n=&C._18_64_M_rad_n/&C._18_64_M ; 		
			&C._18_64_M_surg_y=&C._18_64_M_surg_y/&C._18_64_M ; 		
			&C._18_64_M_surg_n	=&C._18_64_M_surg_n/&C._18_64_M	; 		
			&C._18_64_M_bmt_al	=&C._18_64_M_bmt_al/&C._18_64_M	; 		
			&C._18_64_M_bmt_au=&C._18_64_M_bmt_au/&C._18_64_M	; 		
			&C._18_64_M_bmt_none=&C._18_64_M_bmt_none/&C._18_64_M ; 			

			&C._65_69_F_inst_y=&C._65_69_F_inst_y/&C._65_69_F	;
			&C._65_69_F_inst_n=&C._65_69_F_inst_n/&C._65_69_F	;
			&C._65_69_M_inst_y=&C._65_69_M_inst_y/&C._65_69_M	;
			&C._65_69_M_inst_n=&C._65_69_M_inst_n/&C._65_69_M	;

			&C._65_69_F_epi_180_181=&C._65_69_F_epi_180_181/&C._65_69_F;	
			&C._65_69_F_epi_182_183=&C._65_69_F_epi_182_183/&C._65_69_F;
			&C._65_69_M_epi_180_181=&C._65_69_M_epi_180_181/&C._65_69_M;	
			&C._65_69_M_epi_182_183=&C._65_69_M_epi_182_183/&C._65_69_M;

			&C._65_69_F_cp_1_61=&C._65_69_F_cp_1_61/&C._65_69_F;		
			&C._65_69_F_cp_62_730=&C._65_69_F_cp_62_730/&C._65_69_F; 
			&C._65_69_F_cp_none=&C._65_69_F_cp_none/&C._65_69_F ;
			&C._65_69_M_cp_1_61=&C._65_69_M_cp_1_61/&C._65_69_M;		
			&C._65_69_M_cp_62_730=&C._65_69_M_cp_62_730/&C._65_69_M; 
			&C._65_69_M_cp_none=&C._65_69_M_cp_none/&C._65_69_M ;

			&C._65_69_F_enroll_full_dual=&C._65_69_F_enroll_full_duaL/&C._65_69_F;
			&C._65_69_F_enroll_no_pd=&C._65_69_F_enroll_no_pd/&C._65_69_F	;
			&C._65_69_F_enroll_pd_lis=&C._65_69_F_enroll_pd_lis/&C._65_69_F	;
			&C._65_69_F_enroll_pd_no_lis=&C._65_69_F_enroll_pd_no_lis/&C._65_69_F	;
			&C._65_69_M_enroll_full_dual=&C._65_69_M_enroll_full_dual/&C._65_69_M;
			&C._65_69_M_enroll_no_pd=&C._65_69_M_enroll_no_pd/&C._65_69_M	;
			&C._65_69_M_enroll_pd_lis=&C._65_69_M_enroll_pd_lis/&C._65_69_M	;
			&C._65_69_M_enroll_pd_no_lis=&C._65_69_M_enroll_pd_no_lis/&C._65_69_M;

			&C._65_69_F_comorb_1=&C._65_69_F_comorb_1/&C._65_69_F ;	
			&C._65_69_F_comorb_2=&C._65_69_F_comorb_2/&C._65_69_F ; 	
			&C._65_69_F_comorb_3=&C._65_69_F_comorb_3/&C._65_69_F ; 	
			&C._65_69_F_comorb_4_5=&C._65_69_F_comorb_4_5/&C._65_69_F	; 
			&C._65_69_F_comorb_6=&C._65_69_F_comorb_6/&C._65_69_F  ; 	
			&C._65_69_F_comorb_new_enroll=&C._65_69_F_comorb_new_enroll/&C._65_69_F	 ; 
			&C._65_69_F_comorb_none=&C._65_69_F_comorb_none/&C._65_69_F	 ; 
			&C._65_69_M_comorb_1=&C._65_69_M_comorb_1/&C._65_69_M  ;	
			&C._65_69_M_comorb_2=&C._65_69_M_comorb_2/&C._65_69_M ; 	
			&C._65_69_M_comorb_3=&C._65_69_M_comorb_3/&C._65_69_M ; 	
			&C._65_69_M_comorb_4_5=&C._65_69_M_comorb_4_5/&C._65_69_M	; 
			&C._65_69_M_comorb_6=&C._65_69_M_comorb_6/&C._65_69_M  ; 	
			&C._65_69_M_comorb_new_enroll=&C._65_69_M_comorb_new_enroll/&C._65_69_M	  ; 
			&C._65_69_M_comorb_none=&C._65_69_M_comorb_none/&C._65_69_M	 ; 

			&C._65_69_F_ct_y=&C._65_69_F_ct_y/&C._65_69_F ; 	
			&C._65_69_F_ct_n=&C._65_69_F_ct_n/&C._65_69_F ; 		
			&C._65_69_F_rad_y=&C._65_69_F_rad_y/&C._65_69_F; 	
			&C._65_69_F_rad_n=&C._65_69_F_rad_n/&C._65_69_F ; 		
			&C._65_69_F_surg_y=&C._65_69_F_surg_y/&C._65_69_F; 		
			&C._65_69_F_surg_n=&C._65_69_F_surg_n/&C._65_69_F	; 		
			&C._65_69_F_bmt_al=&C._65_69_F_bmt_al/&C._65_69_F	; 		
			&C._65_69_F_bmt_au=&C._65_69_F_bmt_au/&C._65_69_F	; 		
			&C._65_69_F_bmt_none=&C._65_69_F_bmt_none/&C._65_69_F ; 			
			&C._65_69_M_ct_y=&C._65_69_M_ct_y/&C._65_69_M  ; 	
			&C._65_69_M_ct_n=&C._65_69_M_ct_n/&C._65_69_M  ; 		
			&C._65_69_M_rad_y=&C._65_69_M_rad_y/&C._65_69_M  ; 	
			&C._65_69_M_rad_n=&C._65_69_M_rad_n/&C._65_69_M  ; 		
			&C._65_69_M_surg_y=&C._65_69_M_surg_y/&C._65_69_M  ; 		
			&C._65_69_M_surg_n=&C._65_69_M_surg_n/&C._65_69_M	 ; 		
			&C._65_69_M_bmt_al	=&C._65_69_M_bmt_al/&C._65_69_M	 ; 		
			&C._65_69_M_bmt_au	=&C._65_69_M_bmt_au/&C._65_69_M	 ; 		
			&C._65_69_M_bmt_none=&C._65_69_M_bmt_none/&C._65_69_M  ; 			

			&C._70_74_F_inst_y=&C._70_74_F_inst_y/&C._70_74_F	;
			&C._70_74_F_inst_n=&C._70_74_F_inst_n/&C._70_74_F	;
			&C._70_74_M_inst_y	=&C._70_74_M_inst_y/&C._70_74_M	;
			&C._70_74_M_inst_n	=&C._70_74_M_inst_n/&C._70_74_M	;

			&C._70_74_F_epi_180_181=&C._70_74_F_epi_180_181/&C._70_74_F;	
			&C._70_74_F_epi_182_183=&C._70_74_F_epi_182_183/&C._70_74_F;
			&C._70_74_M_epi_180_181=&C._70_74_M_epi_180_181/&C._70_74_M;	
			&C._70_74_M_epi_182_183=&C._70_74_M_epi_182_183/&C._70_74_M;

			&C._70_74_F_cp_1_61=&C._70_74_F_cp_1_61/&C._70_74_F;		
			&C._70_74_F_cp_62_730=&C._70_74_F_cp_62_730/&C._70_74_F; 
			&C._70_74_F_cp_none=&C._70_74_F_cp_none/&C._70_74_F;
			&C._70_74_M_cp_1_61=&C._70_74_M_cp_1_61/&C._70_74_M;		
			&C._70_74_M_cp_62_730=&C._70_74_M_cp_62_730/&C._70_74_M; 
			&C._70_74_M_cp_none=&C._70_74_M_cp_none/&C._70_74_M ;

			&C._70_74_F_enroll_full_dual=&C._70_74_F_enroll_full_dual/&C._70_74_F;
			&C._70_74_F_enroll_no_pd=&C._70_74_F_enroll_no_pd/&C._70_74_F;
			&C._70_74_F_enroll_pd_lis=&C._70_74_F_enroll_pd_lis/&C._70_74_F;
			&C._70_74_F_enroll_pd_no_lis=&C._70_74_F_enroll_pd_no_lis/&C._70_74_F;
			&C._70_74_M_enroll_full_dual=&C._70_74_M_enroll_full_dual/&C._70_74_M;
			&C._70_74_M_enroll_no_pd=&C._70_74_M_enroll_no_pd/&C._70_74_M	;
			&C._70_74_M_enroll_pd_lis=&C._70_74_M_enroll_pd_lis/&C._70_74_M	;
			&C._70_74_M_enroll_pd_no_lis=&C._70_74_M_enroll_pd_no_lis/&C._70_74_M;

			&C._70_74_F_comorb_1=&C._70_74_F_comorb_1/&C._70_74_F ;	
			&C._70_74_F_comorb_2=&C._70_74_F_comorb_2/&C._70_74_F ; 	
			&C._70_74_F_comorb_3=&C._70_74_F_comorb_3/&C._70_74_F ; 	
			&C._70_74_F_comorb_4_5=&C._70_74_F_comorb_4_5/&C._70_74_F	; 
			&C._70_74_F_comorb_6=&C._70_74_F_comorb_6/&C._70_74_F ; 	
			&C._70_74_F_comorb_new_enroll=&C._70_74_F_comorb_new_enroll/&C._70_74_F	 ; 
			&C._70_74_F_comorb_none=&C._70_74_F_comorb_none/&C._70_74_F	 ; 
			&C._70_74_M_comorb_1=&C._70_74_M_comorb_1/&C._70_74_M ;	
			&C._70_74_M_comorb_2=&C._70_74_M_comorb_2/&C._70_74_M ; 	
			&C._70_74_M_comorb_3=&C._70_74_M_comorb_3/&C._70_74_M ; 	
			&C._70_74_M_comorb_4_5=&C._70_74_M_comorb_4_5/&C._70_74_M	 ; 
			&C._70_74_M_comorb_6=&C._70_74_M_comorb_6/&C._70_74_M  ; 	
			&C._70_74_M_comorb_new_enroll=&C._70_74_M_comorb_new_enroll/&C._70_74_M	 ; 
			&C._70_74_M_comorb_none=&C._70_74_M_comorb_none/&C._70_74_M	  ; 

			&C._70_74_F_ct_y=&C._70_74_F_ct_y/&C._70_74_F ; 	
			&C._70_74_F_ct_n=&C._70_74_F_ct_n/&C._70_74_F ; 		
			&C._70_74_F_rad_y=&C._70_74_F_rad_y/&C._70_74_F; 	
			&C._70_74_F_rad_n=&C._70_74_F_rad_n/&C._70_74_F ; 		
			&C._70_74_F_surg_y=&C._70_74_F_surg_y/&C._70_74_F ; 		
			&C._70_74_F_surg_n=&C._70_74_F_surg_n/&C._70_74_F	; 		
			&C._70_74_F_bmt_al=&C._70_74_F_bmt_al/&C._70_74_F	; 		
			&C._70_74_F_bmt_au=&C._70_74_F_bmt_au/&C._70_74_F	; 		
			&C._70_74_F_bmt_none=&C._70_74_F_bmt_none/&C._70_74_F ; 			
			&C._70_74_M_ct_y=&C._70_74_M_ct_y/&C._70_74_M  ; 	
			&C._70_74_M_ct_n=&C._70_74_M_ct_n/&C._70_74_M  ; 		
			&C._70_74_M_rad_y=&C._70_74_M_rad_y/&C._70_74_M ; 	
			&C._70_74_M_rad_n=&C._70_74_M_rad_n/&C._70_74_M  ; 		
			&C._70_74_M_surg_y=&C._70_74_M_surg_y/&C._70_74_M  ; 		
			&C._70_74_M_surg_n=&C._70_74_M_surg_n/&C._70_74_M	 ; 		
			&C._70_74_M_bmt_al=&C._70_74_M_bmt_al/&C._70_74_M	 ; 		
			&C._70_74_M_bmt_au=&C._70_74_M_bmt_au/&C._70_74_M	 ; 		
			&C._70_74_M_bmt_none=&C._70_74_M_bmt_none/&C._70_74_M ; 			

			&C._75_79_F_inst_y=&C._75_79_F_inst_y/&C._75_79_F	 ;
			&C._75_79_F_inst_n=&C._75_79_F_inst_n/&C._75_79_F	 ;
			&C._75_79_M_inst_y=&C._75_79_M_inst_y/&C._75_79_M	 ;
			&C._75_79_M_inst_n=&C._75_79_M_inst_n/&C._75_79_M	;

			&C._75_79_F_epi_180_181=&C._75_79_F_epi_180_181/&C._75_79_F;	
			&C._75_79_F_epi_182_183=&C._75_79_F_epi_182_183/&C._75_79_F;
			&C._75_79_M_epi_180_181=&C._75_79_M_epi_180_181/&C._75_79_M ;	
			&C._75_79_M_epi_182_183=&C._75_79_M_epi_182_183/&C._75_79_M;

			&C._75_79_F_cp_1_61=&C._75_79_F_cp_1_61/&C._75_79_F;		
			&C._75_79_F_cp_62_730=&C._75_79_F_cp_62_730/&C._75_79_F	; 
			&C._75_79_F_cp_none=&C._75_79_F_cp_none/&C._75_79_F ;
			&C._75_79_M_cp_1_61=&C._75_79_M_cp_1_61/&C._75_79_M;		
			&C._75_79_M_cp_62_730=&C._75_79_M_cp_62_730/&C._75_79_M; 
			&C._75_79_M_cp_none=&C._75_79_M_cp_none/&C._75_79_M ;

			&C._75_79_F_enroll_full_dual=&C._75_79_F_enroll_full_dual/&C._75_79_F ;
			&C._75_79_F_enroll_no_pd=&C._75_79_F_enroll_no_pd/&C._75_79_F;
			&C._75_79_F_enroll_pd_lis=&C._75_79_F_enroll_pd_lis/&C._75_79_F;
			&C._75_79_F_enroll_pd_no_lis=&C._75_79_F_enroll_pd_no_lis/&C._75_79_F;
			&C._75_79_M_enroll_full_dual=&C._75_79_M_enroll_full_dual/&C._75_79_M;
			&C._75_79_M_enroll_no_pd=&C._75_79_M_enroll_no_pd/&C._75_79_M	;
			&C._75_79_M_enroll_pd_lis=&C._75_79_M_enroll_pd_lis/&C._75_79_M	;
			&C._75_79_M_enroll_pd_no_lis=&C._75_79_M_enroll_pd_no_lis/&C._75_79_M;

			&C._75_79_F_comorb_1 =&C._75_79_F_comorb_1/&C._75_79_F  ;	
			&C._75_79_F_comorb_2 = &C._75_79_F_comorb_2/&C._75_79_F ; 	
			&C._75_79_F_comorb_3 = &C._75_79_F_comorb_3/&C._75_79_F ; 	
			&C._75_79_F_comorb_4_5 = &C._75_79_F_comorb_4_5/&C._75_79_F; 
			&C._75_79_F_comorb_6 = &C._75_79_F_comorb_6/&C._75_79_F  ; 	
			&C._75_79_F_comorb_new_enroll = &C._75_79_F_comorb_new_enroll/&C._75_79_F	 ; 
			&C._75_79_F_comorb_none = &C._75_79_F_comorb_none/&C._75_79_F	 ; 
			&C._75_79_M_comorb_1 = &C._75_79_M_comorb_1/&C._75_79_M  ;	
			&C._75_79_M_comorb_2 = &C._75_79_M_comorb_2/&C._75_79_M  ; 	
			&C._75_79_M_comorb_3 = &C._75_79_M_comorb_3/&C._75_79_M  ; 	
			&C._75_79_M_comorb_4_5 = &C._75_79_M_comorb_4_5/&C._75_79_M	 ; 
			&C._75_79_M_comorb_6 = &C._75_79_M_comorb_6/&C._75_79_M ; 	
			&C._75_79_M_comorb_new_enroll = &C._75_79_M_comorb_new_enroll/&C._75_79_M	 ; 
			&C._75_79_M_comorb_none = &C._75_79_M_comorb_none/&C._75_79_M	  ; 

			&C._75_79_F_ct_y=&C._75_79_F_ct_y/&C._75_79_F ; 	
			&C._75_79_F_ct_n=&C._75_79_F_ct_n/&C._75_79_F ; 		
			&C._75_79_F_rad_y=&C._75_79_F_rad_y/&C._75_79_F; 	
			&C._75_79_F_rad_n=&C._75_79_F_rad_n/&C._75_79_F; 		
			&C._75_79_F_surg_y=&C._75_79_F_surg_y/&C._75_79_F; 		
			&C._75_79_F_surg_n=&C._75_79_F_surg_n/&C._75_79_F; 		
			&C._75_79_F_bmt_al=&C._75_79_F_bmt_al/&C._75_79_F; 		
			&C._75_79_F_bmt_au=&C._75_79_F_bmt_au/&C._75_79_F; 		
			&C._75_79_F_bmt_none=&C._75_79_F_bmt_none/&C._75_79_F; 			
			&C._75_79_M_ct_y=&C._75_79_M_ct_y/&C._75_79_M ; 	
			&C._75_79_M_ct_n=&C._75_79_M_ct_n/&C._75_79_M ; 		
			&C._75_79_M_rad_y=&C._75_79_M_rad_y/&C._75_79_M ; 	
			&C._75_79_M_rad_n=&C._75_79_M_rad_n/&C._75_79_M ; 		
			&C._75_79_M_surg_y=&C._75_79_M_surg_y/&C._75_79_M ; 		
			&C._75_79_M_surg_n=&C._75_79_M_surg_n/&C._75_79_M	; 		
			&C._75_79_M_bmt_al=&C._75_79_M_bmt_al/&C._75_79_M	; 		
			&C._75_79_M_bmt_au=&C._75_79_M_bmt_au/&C._75_79_M	; 		
			&C._75_79_M_bmt_none=&C._75_79_M_bmt_none/&C._75_79_M; 	

			&C._80_F_inst_y = &C._80_F_inst_y/&C._80_F	 ;
			&C._80_F_inst_n = &C._80_F_inst_n/&C._80_F	 ;
			&C._80_M_inst_y = &C._80_M_inst_y/&C._80_M	;
			&C._80_M_inst_n = &C._80_M_inst_n/&C._80_M	;

			&C._80_F_epi_180_181= &C._80_F_epi_180_181/&C._80_F;	
			&C._80_F_epi_182_183 = &C._80_F_epi_182_183/&C._80_F;
			&C._80_M_epi_180_181 = &C._80_M_epi_180_181/&C._80_M;	
			&C._80_M_epi_182_183 = &C._80_M_epi_182_183/&C._80_M;

			&C._80_F_cp_1_61=&C._80_F_cp_1_61/&C._80_F;		
			&C._80_F_cp_62_730=&C._80_F_cp_62_730/&C._80_F; 
			&C._80_F_cp_none=&C._80_F_cp_none/&C._80_F ;
			&C._80_M_cp_1_61=&C._80_M_cp_1_61/&C._80_M;		
			&C._80_M_cp_62_730=&C._80_M_cp_62_730/&C._80_M	; 
			&C._80_M_cp_none=&C._80_M_cp_none/&C._80_M 	;

			&C._80_F_enroll_full_dual = &C._80_F_enroll_full_dual/&C._80_F;
			&C._80_F_enroll_no_pd = &C._80_F_enroll_no_pd/&C._80_F	;
			&C._80_F_enroll_pd_lis = &C._80_F_enroll_pd_lis/&C._80_F	;
			&C._80_F_enroll_pd_no_lis = &C._80_F_enroll_pd_no_lis/&C._80_F;
			&C._80_M_enroll_full_dual = &C._80_M_enroll_full_dual/&C._80_M;
			&C._80_M_enroll_no_pd = &C._80_M_enroll_no_pd/&C._80_M	;
			&C._80_M_enroll_pd_lis = &C._80_M_enroll_pd_lis/&C._80_M	;
			&C._80_M_enroll_pd_no_lis = &C._80_M_enroll_pd_no_lis/&C._80_M;

			&C._80_F_comorb_1=&C._80_F_comorb_1/&C._80_F ;	
			&C._80_F_comorb_2=&C._80_F_comorb_2/&C._80_F ; 	
			&C._80_F_comorb_3=&C._80_F_comorb_3/&C._80_F ; 	
			&C._80_F_comorb_4_5=&C._80_F_comorb_4_5/&C._80_F; 
			&C._80_F_comorb_6=&C._80_F_comorb_6/&C._80_F  ; 	
			&C._80_F_comorb_new_enroll=&C._80_F_comorb_new_enroll/&C._80_F	  ; 
			&C._80_F_comorb_none=&C._80_F_comorb_none/&C._80_F	 ; 
			&C._80_M_comorb_1=&C._80_M_comorb_1/&C._80_M ;	
			&C._80_M_comorb_2=&C._80_M_comorb_2/&C._80_M ; 	
			&C._80_M_comorb_3=&C._80_M_comorb_3/&C._80_M ; 	
			&C._80_M_comorb_4_5=&C._80_M_comorb_4_5/&C._80_M; 
			&C._80_M_comorb_6=&C._80_M_comorb_6/&C._80_M  ; 	
			&C._80_M_comorb_new_enroll=&C._80_M_comorb_new_enroll/&C._80_M	 ; 
			&C._80_M_comorb_none=&C._80_M_comorb_none/&C._80_M	 ; 

			&C._80_F_ct_y=&C._80_F_ct_y/&C._80_F ; 	
			&C._80_F_ct_n=&C._80_F_ct_n/&C._80_F ; 		
			&C._80_F_rad_y=&C._80_F_rad_y/&C._80_F ; 	
			&C._80_F_rad_n=&C._80_F_rad_n/&C._80_F ; 		
			&C._80_F_surg_y=&C._80_F_surg_y/&C._80_F ; 		
			&C._80_F_surg_n=&C._80_F_surg_n/&C._80_F; 		
			&C._80_F_bmt_al=&C._80_F_bmt_al/&C._80_F; 		
			&C._80_F_bmt_au=&C._80_F_bmt_au/&C._80_F; 		
			&C._80_F_bmt_none=&C._80_F_bmt_none/&C._80_F ; 			
			&C._80_M_ct_y=&C._80_M_ct_y/&C._80_M ; 	
			&C._80_M_ct_n=&C._80_M_ct_n/&C._80_M ; 		
			&C._80_M_rad_y=&C._80_M_rad_y/&C._80_M ; 	
			&C._80_M_rad_n=&C._80_M_rad_n/&C._80_M ; 		
			&C._80_M_surg_y=&C._80_M_surg_y/&C._80_M ; 		
			&C._80_M_surg_n=&C._80_M_surg_n/&C._80_M; 		
			&C._80_M_bmt_al=&C._80_M_bmt_al/&C._80_M; 		
			&C._80_M_bmt_au=&C._80_M_bmt_au/&C._80_M; 		
			&C._80_M_bmt_none=&C._80_M_bmt_none/&C._80_M; 			

		DROP &C._18_64_F &C._18_64_M &C._65_69_F &C._65_69_M &C._70_74_F &C._70_74_M
			 &C._75_79_F &C._75_79_M &C._80_F ;

		OUTPUT r2.PREDICT_MODEL_VARS_&c. ;
		

		%MEND ;

		%SETUP(ACLU) ;
		%SETUP(ANAL) ; 
		%SETUP(BLAD) ; 
		%SETUP(BRST) ; 
		%SETUP(CRLU) ; 
		%SETUP(CNS) ; 
		%SETUP(ENDO) ; 
		%SETUP(FEML) ; 
		%SETUP(GAST) ; 
		%SETUP(HEAD) ; 
		%SETUP(INTS) ; 
		%SETUP(KIDN) ; 
		%SETUP(LIVR) ; 
		%SETUP(LUNG) ; 
		%SETUP(LYMP) ;
	    %SETUP(MALM) ; 
	    %SETUP(MULM) ; 
	    %SETUP(MDS) ; 
		%SETUP(OVAR) ; 
		%SETUP(PANC) ; 
		%SETUP(PROS) ; 


RUN ;
