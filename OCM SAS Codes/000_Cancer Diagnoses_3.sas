***** 000 - Cancer Diagnoses ***** ;

%macro canc_flags ;
			     ACUTE_LEUKEMIA ANAL BLADDER BREAST CHRONIC_LEUKEMIA  CNS  ENDOCRINE  
				 FEMALEGU  GASTRO_ESOPHAGEAL  HEADNECK  INTESTINAL  KIDNEY  LIVER  LUNG  LYMPHOMA 
				 MALIGNANT_MELANOMA  MULT_MYELOMA  OVARIAN  PANCREATIC  PROSTATE  
				 ATYPICAL_LEUKEMIA  INSITU_BREAST  INSITU_CERVIX /*removed INSITU_EAR*/ INSITU_RESP  
				 INSITU_OES  INSITU_NOS_DIG  INSITU_NOS_GEN  INSITU_OTH  INSITU_SKIN  CHRONIC_LEUKEMIA_U 
				 CHRONIC_M_LEUKEMIA  KAPOSI  LEUKEMIA_NOS  LYMPHOID_LEUKEMIA  MN_ABDOMEN  MN_LIMB  MN_BONE_NOS 
				 MN_HEART  MN_LLIMB  MN_OTH_DIG  MN_FEM  MN_OTH   MN_PELVIS  MN_MALE  MN_NERVES  MN_PLACENTA 
				 MN_RP  MN_TESTIS  MN_THORAX  MN_THYMUS  MN_ULIMB  MN_NOS  MDS  MERKEL  MONO_LEUKEMIA 
				 MYELOID_LEUKEMIA  OTHER_SKIN  OTHER_LYMPH  OTHER_LLEUK  OTH_MONOLEUK  OTH_MYELEUK 
				 OTH_SPELEUK SEC_LYMPH SEC_MN_NOS SEC_MN_RESPDIG SEC_MN_NEUROEND
				 ACUTE_PAN JM_LEUK INSITU_MELANOMA 
	
%mend canc_flags ;

%macro canc_var ;

cancer_chk = ACUTE_LEUKEMIA||ANAL||BLADDER||BREAST||CHRONIC_LEUKEMIA||CNS||ENDOCRINE||FEMALEGU||GASTRO_ESOPHAGEAL||
			 HEADNECK||INTESTINAL||KIDNEY||LIVER||LUNG||LYMPHOMA||MALIGNANT_MELANOMA||MULT_MYELOMA||OVARIAN||
		     PANCREATIC||PROSTATE||ATYPICAL_LEUKEMIA||INSITU_BREAST||INSITU_CERVIX||INSITU_RESP||
			 INSITU_OES||INSITU_NOS_DIG||INSITU_NOS_GEN||INSITU_OTH||INSITU_SKIN||CHRONIC_LEUKEMIA_U||
			 CHRONIC_M_LEUKEMIA||KAPOSI||LEUKEMIA_NOS||LYMPHOID_LEUKEMIA||MN_ABDOMEN||MN_LIMB||MN_BONE_NOS||
			 MN_HEART||MN_LLIMB||MN_OTH_DIG||MN_FEM||MN_OTH||MN_PELVIS||MN_MALE||MN_NERVES||MN_PLACENTA||
			 MN_RP||MN_TESTIS||MN_THORAX||MN_THYMUS||MN_ULIMB||MN_NOS||MDS||MERKEL||MONO_LEUKEMIA||
			 MYELOID_LEUKEMIA||OTHER_SKIN||OTHER_LYMPH||OTHER_LLEUK||OTH_MONOLEUK||OTH_MYELEUK||
			 OTH_SPELEUK||SEC_LYMPH||SEC_MN_NOS||SEC_MN_RESPDIG||SEC_MN_NEUROEND||
			 ACUTE_PAN||JM_LEUK||INSITU_MELANOMA 

%mend canc_var ;


%macro canc_init ;

	ACUTE_LEUKEMIA = 0 ;  	ANAL = 0 ;  BLADDER = 0 ;  	BREAST = 0;  	CHRONIC_LEUKEMIA = 0 ;
	CNS = 0 ;  	ENDOCRINE = 0 ;  	FEMALEGU = 0 ;  	GASTRO_ESOPHAGEAL = 0 ;
	HEADNECK = 0 ;  INTESTINAL = 0 ;  KIDNEY = 0 ;  LIVER = 0 ;  LUNG = 0 ;  LYMPHOMA = 0 ;
	MALIGNANT_MELANOMA = 0 ;  MULT_MYELOMA = 0 ;  OVARIAN = 0 ;  PANCREATIC = 0 ; PROSTATE = 0 ;
	ATYPICAL_LEUKEMIA = 0  ;  INSITU_BREAST = 0 ; INSITU_CERVIX = 0 ; /* remove INSITU_EAR = 0 ; */
	INSITU_RESP = 0 ; INSITU_OES = 0 ;  INSITU_NOS_DIG = 0 ;  INSITU_NOS_GEN = 0 ;
	INSITU_OTH = 0 ;  INSITU_SKIN = 0 ; CHRONIC_LEUKEMIA_U = 0 ; CHRONIC_M_LEUKEMIA = 0 ;
	KAPOSI = 0 ; LEUKEMIA_NOS = 0 ; LYMPHOID_LEUKEMIA = 0 ;  MN_ABDOMEN = 0 ;
	MN_LIMB = 0 ; MN_BONE_NOS = 0 ; MN_HEART = 0 ; MN_LLIMB = 0  ; MN_OTH_DIG = 0 ;
	MN_FEM = 0 ;MN_OTH = 0 ; MN_PELVIS = 0 ; MN_MALE = 0; MN_NERVES =0 ; MN_PLACENTA = 0 ;
	MN_RP = 0  ; MN_TESTIS = 0 ; MN_THORAX = 0 ; MN_THYMUS = 0 ; MN_ULIMB = 0 ;MN_NOS = 0 ;
	MDS = 0 ; MERKEL = 0 ; MONO_LEUKEMIA = 0 ; MYELOID_LEUKEMIA = 0  ; OTHER_SKIN = 0 ;
	OTHER_LYMPH = 0 ;  OTHER_LLEUK = 0 ; OTH_MONOLEUK = 0 ; OTH_MYELEUK = 0 ; OTH_SPELEUK = 0 ;
	SEC_LYMPH = 0 ;   SEC_MN_NOS  = 0 ;  SEC_MN_RESPDIG  = 0 ;  SEC_MN_NEUROEND = 0 ;  
	ACUTE_PAN = 0 ;  JM_LEUK = 0 ;  INSITU_MELANOMA=0 ; UROTHELIAL  = 0 ;

%mend canc_init ;

%MACRO CANCERTYPE(VER,DIAG) ;

	DX3 = UPCASE(SUBSTR(&DIAG.,1,3)) ;
	DX4 = UPCASE(SUBSTR(&DIAG.,1,4)) ;
	DX5 = UPCASE(SUBSTR(&DIAG.,1,5)) ;


IF &VER. = 9 THEN DO ;
	
	IF PUT(DX4,$Acute_leukemia_49_.) = "Y" THEN do ; ACUTE_LEUKEMIA = 1 ; RECON_ELIG = "Y" ; END ;	
	IF PUT(DX5,$Acute_leukemia_59_.) = "Y" THEN do ; ACUTE_LEUKEMIA = 1 ; RECON_ELIG = "Y" ; END ;		
	IF PUT(DX4,$Anal_49_.) = "Y" THEN do ; ANAL = 1 ; RECON_ELIG = "Y" ; END ;		
	IF PUT(DX3,$Bladder_39_.)= "Y" THEN do ; BLADDER = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$Bladder_49_.)= "Y" THEN do ; BLADDER = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Breast_39_.)= "Y" THEN do ; BREAST = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$Chronic_Leukemia_49_.)= "Y" THEN do ; CHRONIC_LEUKEMIA = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$CNS_39_.)= "Y" THEN do ; CNS = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$CNS_49_.)= "Y" THEN do ; CNS = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Endo_39_.) = "Y" THEN do ; ENDOCRINE = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$Endo_49_.) = "Y" THEN do ; ENDOCRINE = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX5,$Endo_59_.) = "Y" THEN do ; ENDOCRINE = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Female_GU_39_.) = "Y" THEN do ; FEMALEGU = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$Female_GU_49_.) = "Y" THEN do ; FEMALEGU = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Gastro_39_.) = "Y" THEN do ; GASTRO_ESOPHAGEAL = 1 ; RECON_ELIG = "Y" ; END ;		
	IF PUT(DX3,$HeadNeck_39_.) = "Y" THEN do ; HEADNECK = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$HeadNeck_49_.) = "Y" THEN do ; HEADNECK = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Intestinal_39_.) = "Y" THEN do ; INTESTINAL = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$Intestinal_49_.) = "Y" THEN do ; INTESTINAL = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$Kidney_49_.) = "Y" THEN do ; KIDNEY = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Liver_39_.) = "Y" THEN do ; LIVER = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$Liver_49_.) = "Y" THEN do ; LIVER = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Lung_39_.) = "Y" THEN do ; LUNG = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$Lung_49_.) = "Y" THEN do ; LUNG = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Lymphoma_39_.) = "Y" THEN do ; LYMPHOMA = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$Lymphoma_49_.) = "Y" THEN do ; LYMPHOMA = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX5,$Lymphoma_59_.) = "Y" THEN do ; LYMPHOMA = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$MaligMel_39_.) = "Y" THEN do ; MALIGNANT_MELANOMA = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$MultMyeloma_49_.) = "Y" THEN do ; MULT_MYELOMA = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX5,$MultMyeloma_59_.) = "Y" THEN do ; MULT_MYELOMA = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$Ovarian_49_.) = "Y" THEN do ; OVARIAN = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Pancreatic_39_.) = "Y" THEN do ; PANCREATIC = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Prostate_39_.) = "Y" THEN do ; PROSTATE = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Prostate_39_.) = "Y" THEN do ; PROSTATE = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$ACML_49_.) = "Y" THEN do ; ATYPICAL_LEUKEMIA = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$Insitu_B_49_.) = "Y" THEN do ; INSITU_BREAST = 1 ; RECON_ELIG = "N" ; END ;		
	IF PUT(DX4,$Insitu_CU_49_.) = "Y" THEN do ; INSITU_CERVIX = 1 ; RECON_ELIG = "N" ; END ;		
	IF PUT(DX3,$Insitu_Resp_39_.) = "Y" THEN do ; INSITU_RESP = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$Insitu_OES_49_.) = "Y" THEN do ; INSITU_OES = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$Insitu_DIG_49_.) = "Y" THEN do ; INSITU_NOS_DIG = 1 ; RECON_ELIG = "N" ; END ;		
	IF PUT(DX4,$Insitu_GEN_49_.) = "Y" THEN do ; INSITU_NOS_GEN = 1 ;  RECON_ELIG = "N" ; END ;		
	IF PUT(DX3,$Insitu_OTH_39_.) = "Y" THEN do ; INSITU_OTH = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$Insitu_OTH_49_.) = "Y" THEN do ; INSITU_OTH = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$Insitu_Skin_39_.) = "Y" THEN do ; INSITU_SKIN = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$CLeuk_49_.) = "Y" THEN do ; CHRONIC_LEUKEMIA_U = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$CMLeuk_49_.) = "Y" THEN do ; CHRONIC_M_LEUKEMIA = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$Kaposi_39_.) = "Y" THEN do ; KAPOSI = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$LeukUS_49_.) = "Y" THEN do ; LEUKEMIA_NOS = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$LymphLeukUS_49_.) = "Y" THEN do ; LYMPHOID_LEUKEMIA = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_Abdomen_49_.) = "Y" THEN do ; MN_ABDOMEN = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_Limb_49_.) = "Y" THEN do ; MN_LIMB = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_OthBone_49_.) = "Y" THEN do ; MN_BONE_NOS = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_Heart_39_.) = "Y" THEN do ; MN_HEART = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_Heart_49_.) = "Y" THEN do ; MN_HEART = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_LL_49_.) = "Y" THEN do ; MN_LLIMB = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_OTHDIG_39_.) = "Y" THEN do ; MN_OTH_DIG = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_OTHFEM_49_.) = "Y" THEN do ; MN_FEM = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_OTH_49_.) = "Y" THEN do ; MN_OTH = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_PELVIS_49_.) = "Y" THEN do ; MN_PELVIS = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_Male_49_.) = "Y" THEN do ; MN_MALE = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_Nerves_49_.) = "Y" THEN do ; MN_NERVES = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_Placenta_39_.) = "Y" THEN do ; MN_PLACENTA = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_RP_39_.) = "Y" THEN do ; MN_RP = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_Testis_39_.) = "Y" THEN do ; MN_TESTIS = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_Thorax_49_.) = "Y" THEN do ; MN_THORAX = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_Thymus_49_.) = "Y" THEN do ; MN_THYMUS = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_UL_49_.) = "Y" THEN do ; MN_ULIMB = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_WOSPEC_39_.) = "Y" THEN do ; MN_NOS = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX5,$MDS_59_.) = "Y" THEN do ; MDS = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX5,$Merkel_59_.) = "Y" THEN do ; MERKEL = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MonoLeukU_49_.) = "Y" THEN do ; MONO_LEUKEMIA = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MyeLeukU_49_.) = "Y" THEN do ; MYELOID_LEUKEMIA = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$OthSkin_39_.) = "Y" THEN do ; OTHER_SKIN = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$OthMNLymph_49_.) = "Y" THEN do ; OTHER_LYMPH = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX5,$OthMNLymph_59_.) = "Y" THEN do ; OTHER_LYMPH = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$Oth_LympLeuk_49_.) = "Y" THEN do ; OTHER_LLEUK = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$Oth_mONOLeuk_49_.) = "Y" THEN do ; OTH_MONOLEUK = 1 ; RECON_ELIG = "N" ; END ;		
	IF PUT(DX4,$Oth_MyeLeuk_49_.) = "Y" THEN do ; OTH_MYELEUK = 1 ;  RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$Oth_SpeLeuk_49_.) = "Y" THEN do ; OTH_SPELEUK = 1 ; RECON_ELIG = "N" ; END ;	
	
	/*IF PUT(DX3,$Sec_MN_Lymph_39_.) = "Y" THEN do ; SEC_LYMPH = 1 ; RECON_ELIG = "N" ; END ;	*/
	/*IF PUT(DX3,$Sec_MN_NOS_39_.) = "Y" THEN do ; SEC_MN_NOS = 1 ; RECON_ELIG = "N" ; END ;	*/
	/*IF PUT(DX3,$Sec_MN_RespDig_39_.) = "Y" THEN do ; SEC_MN_RESPDIG = 1 ; RECON_ELIG = "N" ; END ;*/	
	/*IF PUT(DX4,$Sec_neuro_49_.) = "Y" THEN do ; SEC_MN_NEUROEND = 1 ; RECON_ELIG = "N" ; END ;	*/

	
END ;

IF &VER. = 0 THEN DO ;
	
	IF PUT(DX4,$Acute_leukemia_410_.) = "Y" THEN do ; ACUTE_LEUKEMIA = 1 ; RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Anal_310_.) = "Y" THEN do ; ANAL = 1 ; RECON_ELIG = "Y" ; END ;		
	IF PUT(DX3,$Bladder_310_.)= "Y" THEN do ; 
			BLADDER = 1 ;	 RECON_ELIG = "Y" ; 
			IF DX3 IN ('C67','C68') THEN UROTHELIAL = 1 ; 
	END ;	
	IF PUT(DX3,$BREAST_310_.)= "Y" THEN do ; BREAST = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$Chronic_Leukemia_410_.)= "Y" THEN do ; CHRONIC_LEUKEMIA = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$CNS_310_.)= "Y" THEN do ; CNS = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Endo_310_.) = "Y" THEN do ; ENDOCRINE = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Female_GU_310_.) = "Y" THEN do ; FEMALEGU = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Gastro_310_.) = "Y" THEN do ; GASTRO_ESOPHAGEAL = 1 ; RECON_ELIG = "Y" ; END ;		
	IF PUT(DX3,$HeadNeck_310_.) = "Y" THEN do ; HEADNECK = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$HeadNeck_410_.) = "Y" THEN do ; HEADNECK = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Intestinal_310_.) = "Y" THEN do ; INTESTINAL = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Kidney_310_.) = "Y" THEN do ; KIDNEY = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Liver_310_.) = "Y" THEN do ; LIVER = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Lung_310_.) = "Y" THEN do ; LUNG = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Lymphoma_310_.) = "Y" THEN do ; LYMPHOMA = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$Lymphoma_410_.) = "Y" THEN do ; LYMPHOMA = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$MaligMel_310_.) = "Y" THEN do ; MALIGNANT_MELANOMA = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$MultMyeloma_310_.) = "Y" THEN do ; MULT_MYELOMA = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Ovarian_310_.) = "Y" THEN do ; OVARIAN = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Pancreatic_310_.) = "Y" THEN do ; PANCREATIC = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Prostate_310_.) = "Y" THEN do ; PROSTATE = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$AcutePan_410_.) = "Y" THEN do ; ACUTE_PAN = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$ACML_410_.) = "Y" THEN do ; ATYPICAL_LEUKEMIA = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$Insitu_B_310_.) = "Y" THEN do ; INSITU_BREAST = 1 ; RECON_ELIG = "N" ; END ;		
	IF PUT(DX3,$Insitu_CU_310_.) = "Y" THEN do ; INSITU_CERVIX = 1 ; RECON_ELIG = "N" ; END ;		
	IF PUT(DX3,$Insitu_Resp_310_.) = "Y" THEN do ; INSITU_RESP = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$Insitu_OES_310_.) = "Y" THEN do ; INSITU_OES = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$Insitu_DIG_310_.) = "Y" THEN do ; INSITU_NOS_DIG = 1 ; RECON_ELIG = "N" ; END ;		
	IF PUT(DX3,$Insitu_Gen_310_.) = "Y" THEN do ; INSITU_NOS_GEN = 1 ;  RECON_ELIG = "N" ; END ;		
	IF PUT(DX3,$Insitu_OTH_310_.) = "Y" THEN do ; INSITU_OTH = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$Insitu_Skin_310_.) = "Y" THEN do ; INSITU_SKIN = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$CLeuk_410_.) = "Y" THEN do ; CHRONIC_LEUKEMIA_U = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$CMLeuk_410_.) = "Y" THEN do ; CHRONIC_M_LEUKEMIA = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$JMLeuk_410_.) = "Y" THEN do ; JM_LEUKEMIA = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$Kaposi_310_.) = "Y" THEN do ; KAPOSI = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$LeukUS_410_.) = "Y" THEN do ; LEUKEMIA_NOS = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$LymphLeukUS_410_.) = "Y" THEN do ; LYMPHOID_LEUKEMIA = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_Abdomen_410_.) = "Y" THEN do ; MN_ABDOMEN = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_Limb_310_.) = "Y" THEN do ; MN_LIMB = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_OthBone_310_.) = "Y" THEN do ; MN_BONE_NOS = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_Heart_310_.) = "Y" THEN do ; MN_HEART = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_LL_410_.) = "Y" THEN do ; MN_LLIMB = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_OTHDIG_310_.) = "Y" THEN do ; MN_OTH_DIG = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_OTHFEM_310_.) = "Y" THEN do ; MN_FEM = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_OTH_410_.) = "Y" THEN do ; MN_OTH = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_Pelvis_410_.) = "Y" THEN do ; MN_PELVIS = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_Male_310_.) = "Y" THEN do ; MN_MALE = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_Nerves_310_.) = "Y" THEN do ; MN_NERVES = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_Placenta_310_.) = "Y" THEN do ; MN_PLACENTA = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_RP_310_.) = "Y" THEN do ; MN_RP = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_Testis_310_.) = "Y" THEN do ; MN_TESTIS = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_Thorax_410_.) = "Y" THEN do ; MN_THORAX = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_Thymus_310_.) = "Y" THEN do ; MN_THYMUS = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MN_UL_410_.) = "Y" THEN do ; MN_ULIMB = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MN_wospec_310_.) = "Y" THEN do ; MN_NOS = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$MDS_310_.) = "Y" THEN do ; MDS = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX4,$MDS_410_.) = "Y" THEN do ; MDS = 1 ;	 RECON_ELIG = "Y" ; END ;	
	IF PUT(DX3,$Insitu_Mela_310_.) = "Y" THEN do ; INSITU_MELANOMA = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$Merkel_310_.) = "Y" THEN do ; MERKEL = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MonoLeukU_410_.) = "Y" THEN do ; MONO_LEUKEMIA = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$MyeLeukU_410_.) = "Y" THEN do ; MYELOID_LEUKEMIA = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$OthSkin_310_.) = "Y" THEN do ; OTHER_SKIN = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX3,$OthMNLymph_310_.) = "Y" THEN do ; OTHER_LYMPH = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$Oth_LympLeuk_410_.) = "Y" THEN do ; OTHER_LLEUK = 1 ;	 RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$Oth_MonoLeuk_410_.) = "Y" THEN do ; OTH_MONOLEUK = 1 ; RECON_ELIG = "N" ; END ;		
	IF PUT(DX4,$Oth_MyeLeuk_410_.) = "Y" THEN do ; OTH_MYELEUK = 1 ;  RECON_ELIG = "N" ; END ;	
	IF PUT(DX4,$Oth_SpeLeuk_410_.) = "Y" THEN do ; OTH_SPELEUK = 1 ; RECON_ELIG = "N" ; END ;	
	/*IF PUT(DX3,$Sec_MN_Lymph_310_.) = "Y" THEN do ; SEC_LYMPH = 1 ; RECON_ELIG = "N" ; END ;	*/
	/*IF PUT(DX3,$Sec_MN_NOS_310_.) = "Y" THEN do ; SEC_MN_NOS = 1 ; RECON_ELIG = "N" ; END ;	*/
	/*IF PUT(DX3,$Sec_MN_RespDig_310_.) = "Y" THEN do ; SEC_MN_RESPDIG = 1 ; RECON_ELIG = "N" ; END ;*/	
	/*IF PUT(DX3,$Sec_neuro_310_.) = "Y" THEN do ; SEC_MN_NEUROEND = 1 ; RECON_ELIG = "N" ; END ;	*/

END ;

has_cancer = max(ACUTE_LEUKEMIA,ANAL,BLADDER,BREAST,CHRONIC_LEUKEMIA, CNS, ENDOCRINE, 
				 FEMALEGU, GASTRO_ESOPHAGEAL, HEADNECK, INTESTINAL, KIDNEY, LIVER, LUNG, LYMPHOMA,
				 MALIGNANT_MELANOMA, MULT_MYELOMA, OVARIAN, PANCREATIC, PROSTATE, 
				 ATYPICAL_LEUKEMIA, INSITU_BREAST, INSITU_CERVIX, /* remove INSITU_EAR, */ INSITU_RESP, 
				 INSITU_OES, INSITU_NOS_DIG, INSITU_NOS_GEN, INSITU_OTH, INSITU_SKIN, CHRONIC_LEUKEMIA_U,
				 CHRONIC_M_LEUKEMIA, KAPOSI, LEUKEMIA_NOS, LYMPHOID_LEUKEMIA, MN_ABDOMEN, MN_LIMB, MN_BONE_NOS,
				 MN_HEART, MN_LLIMB, MN_OTH_DIG, MN_FEM, MN_OTH,  MN_PELVIS, MN_MALE, MN_NERVES, MN_PLACENTA,
				 MN_RP, MN_TESTIS, MN_THORAX, MN_THYMUS, MN_ULIMB, MN_NOS, MDS, MERKEL, MONO_LEUKEMIA,
				 MYELOID_LEUKEMIA, OTHER_SKIN, OTHER_LYMPH, OTHER_LLEUK, OTH_MONOLEUK, OTH_MYELEUK,
				 OTH_SPELEUK,ACUTE_PAN, JM_LEUK, INSITU_MELANOMA, SEC_LYMPH, SEC_MN_NOS, SEC_MN_RESPDIG,
				 SEC_MN_NEUROEND) ;


	
%MEND CANCERTYPE ;

%macro assign_cancer ;

format cancer $100. ;

 
	IF ACUTE_LEUKEMIA = 1 then cancer = "Acute Leukemia" ;  	
	IF ANAL = 1 then cancer = "Anal Cancer" ;  	
	IF BLADDER = 1 then cancer = "Bladder Cancer" ;	  
	IF BREAST = 1 then cancer = "Breast Cancer" ;	  
	IF CHRONIC_LEUKEMIA = 1 then cancer = "Chronic Leukemia" ;	  
	IF CNS = 1 then cancer = "CNS Tumor" ;	  
	IF ENDOCRINE = 1 then cancer = "Endocrine Tumor";	  
	IF FEMALEGU = 1 then cancer = "Female GU Cancer other than Ovary" ;	  
	IF GASTRO_ESOPHAGEAL = 1 then cancer = "Gastro/Esophageal Cancer";  	
	IF HEADNECK = 1 then cancer = "Head and Neck Cancer" ;	  
	IF INTESTINAL = 1 then cancer = "Intestinal Cancer" ;	  
	IF KIDNEY = 1 then cancer = "Kidney Cancer" ;	  
	IF LIVER = 1 then cancer = "Liver Cancer" ;	  
	IF LUNG = 1 then cancer = "Lung Cancer" ;	  
	IF LYMPHOMA = 1 then cancer = "Lymphoma" ;	  
	IF MALIGNANT_MELANOMA = 1 then cancer = "Malignant Melanoma" ;	  
	IF MULT_MYELOMA = 1 then cancer = "Multiple Myeloma" ;	  
	IF OVARIAN = 1 then cancer = "Ovarian Cancer" ;	  
	IF PANCREATIC = 1 then cancer = "Pancreatic Cancer" ;	  
	IF PROSTATE = 1 then cancer = "Prostate Cancer" ;	  
	IF ATYPICAL_LEUKEMIA = 1 then cancer = "Atypical chronic myeloid leukemia, BCR/ABL negative" ;	  
	IF INSITU_BREAST = 1 then cancer = "Carcinoma in situ of breast" ;  	
	IF INSITU_CERVIX = 1 then cancer = "Carcinoma in situ of cervix uteri";  	
	IF INSITU_RESP = 1 then cancer = "Carcinoma in situ of middle ear and respiratory system";	  
	IF INSITU_OES = 1 then cancer = "Carcinoma in situ of oral cavity, esophagus, stomach";	  
	IF INSITU_NOS_DIG = 1 then cancer = "Carcinoma in situ of other and NOS digestive organs";  	
	IF INSITU_NOS_GEN = 1 then cancer = "Carcinoma in situ of other and NOS genital organs";   	
	IF INSITU_OTH = 1 then cancer = "Carcinoma in situ of other and NOS sites";	  
	IF INSITU_SKIN = 1 then cancer = "Carcinoma in situ of skin" ;	  
	IF CHRONIC_LEUKEMIA_U = 1 then cancer = "Chronic leukemia of unspecified cell type";	  
	IF CHRONIC_M_LEUKEMIA = 1 then cancer = "Chronic myelomonocytic leukemia";	  
	IF KAPOSI = 1 then cancer = "Kaposi's Sarcoma" ;	  
	IF LEUKEMIA_NOS = 1 then cancer = "Leukemia, NOS";	  
	IF LYMPHOID_LEUKEMIA = 1 then cancer = "Lymphoid Leukemia, NOS";	  
	IF MN_ABDOMEN = 1 then cancer = "Malignant neoplasm of abdomen" ;	  
	IF MN_LIMB = 1 then cancer = "Malignant neoplasm of bone and articular cartilage of limbs";	  
	IF MN_BONE_NOS = 1 then cancer = "Malignant neoplasm of bone and articular cartilage of sites NOS";	  
	IF MN_HEART = 1 then cancer = "Malignant neoplasm of heart, mediastinum and pleura" ;	  
	IF MN_LLIMB = 1 then cancer = "Malignant neoplasm of lower limb";	  
	IF MN_OTH_DIG = 1 then cancer = "Malignant neoplasm of other and ill-defined digestive organs";	  
	IF MN_FEM = 1 then cancer = "Malignant neoplasm of female genital organs NOS" ;	  
	IF MN_OTH = 1 then cancer = "Malignant neoplasm of other and ill-defined sites";	  
	IF MN_PELVIS = 1 then cancer = "Malignant neoplasm of pelvis";	  
	IF MN_MALE = 1 then cancer = "Malignant neoplasm of penis, other male organs NOS";	  
	IF MN_NERVES = 1 then cancer = "Malignant neoplasm of peripheral nerves, autonomic nervous system";	  
	IF MN_PLACENTA = 1 then cancer = "Malignant neoplasm of placenta";	  
	IF MN_RP = 1 then cancer = "Malignant neoplasm of retroperitoneum and peritoneum" ;	  
	IF MN_TESTIS = 1 then cancer = "Malignant neoplasm of testis";	  
	IF MN_THORAX = 1 then cancer = "Malignant neoplasm of thorax";	  
	IF MN_THYMUS = 1 then cancer = "Malignant neoplasm of thymus";	  
	IF MN_ULIMB = 1 then cancer = "Malignant neoplasm of upper limb";	  
	IF MN_NOS = 1 then cancer = "Malignant neoplasm NOS";	  
	IF MDS = 1 then cancer = "MDS";	  
	IF MERKEL = 1 then cancer = "Merkel cell carcinoma" ;	  
	IF MONO_LEUKEMIA = 1 then cancer = "Monocytic Leukemia, NOS";	  
	IF MYELOID_LEUKEMIA = 1 then cancer = "Myeloid Leukemia, NOS";	  
	IF OTHER_SKIN = 1 then cancer = "Malignant neoplasm of skin, NOS";	  
	IF OTHER_LYMPH = 1 then cancer = "Malignant neoplasm of lymphoid, hematopoietic NOS";	  
	IF OTHER_LLEUK = 1 then cancer = "Other lymphoid leukemia";	  
	IF OTH_MONOLEUK = 1 then cancer = "Other monoctyic leukemia";  	
	IF OTH_MYELEUK = 1 then cancer = "Other myeloid leukemia" ;   
	IF OTH_SPELEUK = 1 then cancer = "Other SPECIFIED leukemias";  

	IF ACUTE_PAN = 1 then cancer = "Acute panmyelosis with myelofibrosis" ;
	IF JM_LEUK = 1 then cancer = "Juvenile myelomonocytic leukemia" ;
	IF INSITU_MELANOMA = 1 then cancer = "Melanoma in situ" ;



run ;
%MEND assign_cancer ;
