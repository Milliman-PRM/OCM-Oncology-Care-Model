
********************************************************************** ;
****************** 004_Dashboard Monthly Datasets.sas **************** ;
********************************************************************** ;

options ls=132 ps=70 obs=max mprint mlogic; run ;

%include "H:\_HealthLibrary\SAS\000 - General SAS Macros.sas";
*Turn on for baseline CLAIMS data;
%let label = base; 
libname in "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Baseline\V3" ;

*Turn on for performance CLAIMS data and ALL EPISODE RUN;
/*%let label = performance;*/
/*libname in "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Performance\Mar19";*/

libname inrec "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\80 - QlikView\Qlik_Sasout";

%let set_name = p5b; *'a' is the designation when we don't yet have the most recent beneficiary file, else 'b';
%let set_name_base = blv3;
/*%let ocmid1 = 523;*/
/*%let ocmid2 = 50203;*/
/*%let ocmfac_name = 'TEST';*/

**export directory**;
%let exportDir=R:\data\HIPAA\OCM_Oncology_Care_Model_PP\80 - QlikView\outfiles;

libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\80 - QlikView\Qlik_Sasout" ;
libname metadat "H:\Nonclient\Medicare Bundled Payment Reference\General\SAS Datasets";
libname ref "H:\Nonclient\Medicare Bundled Payment Reference\General\SAS Datasets" ;
libname bench "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\08 - Benchmark Data\BM2 - 5pct Benchmark Files";

**  Premier vs. Other Hospitals **;
%let other_flag=('396','137');

*************************************************************************************************************;
**************************************** EPISODE PROCESSING *************************************************;
*************************************************************************************************************;

%macro episode(OCMID1, ocmid2, ocmfac_name);

data epi_detail1;

    format
        ocm_name $255. ep_id_use $255. CANCER_TYPE_USE NEW_CANCER_TYPE_USE $50. DATA_COVERAGE_USE $50. PATIENT_NAME_USE $50. OCM_ID $3.
        period $10. EPI_START_SOURCE JOIN_VAR $10. EM_ATT_TAX_USE 12. EPI_TIN_MATCH_USE $8.
        MEOS_ALLOWED_TOTAL BEST12. EPISODE_TYPE RECON_BENE_HICN MBI_HICN $50.
        ANCHOR_YEAR ANCHOR_QUARTER ANCHOR_MONTH EP_END_YEAR EP_END_QUARTER EP_END_MONTH EMERGING_QUARTER PERFORMANCE_QUARTER $19.
        DUAL_PTD_LIS_USE $50. CLEAN_PERIOD_USE $35.
        ;

    length
        HCC_GRP_USE BMT_USE CLEAN_PERIOD_USE ATTRIB_FLAG_ABBREV $30
        RADIATION_USE CLINICAL_TRIAL_USE RECON_ELIG_USE RECON_ELIG_prior_use RECON_RECON_ELIG_USE $3
        PTD_CHEMO_USE DUAL_PTD_LIS_USE CHEMO_IN_PP_USE $50
        SURGERY_USE EP_LENGTH2 $3
        RISK_SCORE_USE RECON_AGE 8.
        CANCER_TYPE_ABBREV EPI_COUNTER_USE $100
        ATTRIB_FLAG_USE $50
        EPI_TIN_MATCH_USE $8
        EMERGE_CHEMO_CLAIM EMERGE_EM_CLAIM $3
        MILLIMAN_CANCER_TYPE_USE CMS_CANCER_TYPE_USE CMS_CANCER_TYPE_PRIOR_USE RECON_CANCER_TYPE_USE $50
        ;

    set in.Episode_combined_&set_name._&OCMid1._&ocmid2. ;

	**CHANGE IF NEW RECON PERIOD**;
	if EPISODE_PERIOD = 'PP1' then JOIN_VAR = rec_ocm_id || EPISODE_PERIOD || '2' ;
		else if EPISODE_PERIOD = 'PP2' then JOIN_VAR = rec_ocm_id || EPISODE_PERIOD || '1' ;
		else if EPISODE_PERIOD = 'PP3' then JOIN_VAR = rec_ocm_id || EPISODE_PERIOD || '0' ;
		else JOIN_VAR = '';

    if EM_ATT_TAX = '' then EM_ATT_TAX_USE = 0;
        else EM_ATT_TAX_USE = EM_ATT_TAX;

    if ocm_id in (&other_flag.) then CLIENT_FLAG=0;
        else CLIENT_FLAG=1;

    OCM_NAME = &ocmfac_name.||' (OCM ID '||ocm_id||')';

    if MEOS_episode = 1 and main_episode ^= 1 and emerge_episode ^= 1 and recon_episode ^=1 and attrib_episode ^=1 then ANCHOR_YEAR = '';
        else ANCHOR_YEAR = put(year(ep_beg), 4.);
    if MEOS_episode = 1 and main_episode ^= 1 and emerge_episode ^= 1 and recon_episode ^=1 and attrib_episode ^=1 then ANCHOR_QUARTER = '';
        else ANCHOR_QUARTER = put(year(ep_beg), 4.)||' Q'||strip(qtr(ep_beg));
    if MEOS_episode = 1 and main_episode ^= 1 and emerge_episode ^= 1 and recon_episode ^=1 and attrib_episode ^=1 then ANCHOR_MONTH = '';
        else if month(ep_beg) < 10 then ANCHOR_MONTH = put(year(ep_beg), 4.)||' M0'||strip(month(ep_beg));
        else ANCHOR_MONTH = put(year(ep_beg), 4.)||' M'||strip(month(ep_beg));
    if main_episode = 1 then do;
        ANCHOR_YEAR = put(year(ep_beg), 4.);
        ANCHOR_QUARTER = put(year(ep_beg), 4.)||' Q'||strip(qtr(ep_beg));
        if month(ep_beg) < 10 then ANCHOR_MONTH = put(year(ep_beg), 4.)||' M0'||strip(month(ep_beg));
        else ANCHOR_MONTH = put(year(ep_beg), 4.)||' M'||strip(month(ep_beg));

        EP_END_YEAR = put(year(ep_end),4.);
        EP_END_QUARTER=put(year(ep_end),4.)||' Q'||strip(qtr(ep_end));
        if month(ep_end) < 10 then EP_END_MONTH = put(year(ep_end), 4.)||' M0'||strip(month(ep_end));
                else EP_END_MONTH = put(year(ep_end), 4.)||' M'||strip(month(ep_end));
    end;
    else do;
        ANCHOR_YEAR = '';
        ANCHOR_QUARTER = '';
        ANCHOR_MONTH = '';

        EP_END_YEAR = '';
        EP_END_QUARTER = '';
        EP_END_MONTH = '';
    end;

    if emerge_episode = 1 then do;
        EMERGING_QUARTER = put(year(ep_beg), 4.)||' Q'||strip(qtr(ep_beg));
    end;
    else do;
        EMERGING_QUARTER = '';
    end;

    if recon_episode = 1 then do;
        PERFORMANCE_QUARTER = put(year(ep_beg), 4.)||' Q'||strip(qtr(ep_beg));
    end;
    else do;
        PERFORMANCE_QUARTER = '';
    end;

**************************************************************;
***************BEGIN RECON PROCESSING*************************;
**************************************************************;

    if recon_episode = 1 then do;
	/*REMOVE CODE LINE BELOW ONCE CAR-T LOGIC IS BUILT INTO PROCESSING --- MAY POSTING*/
		if CANCER_TYPE = 'CAR-T' then REC_CANCER_MATCH_USE = 'Yes';
		else REC_CANCER_MATCH_USE = propcase(REC_CANCER_MATCH);

        if IN_PERFORMANCE=2 then IN_PERFORMANCE_USE='Partial';
        else if IN_PERFORMANCE=1 then IN_PERFORMANCE_USE='Full';
        else IN_PERFORMANCE_USE='No';

        EPI_BEG_MATCH_USE = propcase(EPI_BEG_MATCH);

        if RADIATION=REC_RADIATION_MILLIMAN then RADIATION_MATCH='Yes';
          else RADIATION_MATCH='No';

        if SURGERY=REC_SURGERY_MILLIMAN then SURGERY_MATCH='Yes';
            else SURGERY_MATCH='No';

        if CLINICAL_TRIAL=REC_CLINICAL_TRIAL_MILLIMAN then CLINICAL_TRIAL_MATCH='Yes';
            else CLINICAL_TRIAL_MATCH='No';

        if REC_PTD_CHEMO=REC_PTD_CHEMO_MILLIMAN and CANCER_TYPE in ('Breast Cancer','Breast Cancer - Low Risk','Breast Cancer - High Risk') then PTD_CHEMO_MATCH='Yes';
			else if REC_PTD_CHEMO ne REC_PTD_CHEMO_MILLIMAN and CANCER_TYPE in ('Breast Cancer','Breast Cancer - Low Risk','Breast Cancer - High Risk') then PTD_CHEMO_MATCH='No';
			else PTD_CHEMO_MATCH='N/A';

        if BMT=REC_BMT_MILLIMAN and CANCER_TYPE in ('Acute Leukemia','Multiple Myeloma','MDS','Lymphoma') then BMT_MATCH='Yes';
            else if BMT ne REC_BMT_MILLIMAN and CANCER_TYPE in ('Acute Leukemia','Multiple Myeloma','MDS','Lymphoma') then BMT_MATCH='No';
            else BMT_MATCH='N/A';

		LOW_RISK_BLAD_MATCH='N/A';
		CAST_SENS_PROS_MATCH='N/A';

		if EPISODE_PERIOD not in ('PP1', 'PP2') then do;
	        if REC_LOW_RISK_BLAD=REC_LOW_RISK_BLAD_MILLIMAN and CANCER_TYPE in ('Bladder Cancer - Low Risk', 'Bladder Cancer - High Risk') then LOW_RISK_BLAD_MATCH='Yes';
	            else if REC_LOW_RISK_BLAD ne REC_LOW_RISK_BLAD_MILLIMAN and CANCER_TYPE in ('Bladder Cancer - Low Risk', 'Bladder Cancer - High Risk') then LOW_RISK_BLAD_MATCH='No';
	            else LOW_RISK_BLAD_MATCH='N/A';

	        if REC_CAST_SENS_PROS=REC_CAST_SENS_PROS_MILLIMAN and CANCER_TYPE in ('Prostate Cancer - Low Intensity', 'Prostate Cancer - High Intensity') then CAST_SENS_PROS_MATCH='Yes';
	            else if REC_CAST_SENS_PROS ne REC_CAST_SENS_PROS_MILLIMAN and CANCER_TYPE in ('Prostate Cancer - Low Intensity', 'Prostate Cancer - High Intensity') then CAST_SENS_PROS_MATCH='No';
	            else CAST_SENS_PROS_MATCH='N/A';

			if BMT=REC_BMT_MILLIMAN and CANCER_TYPE in ('Chronic Leukemia') then BMT_MATCH='Yes';
	            else if BMT ne REC_BMT_MILLIMAN and CANCER_TYPE in ('Chronic Leukemia') then BMT_MATCH='No';
		end;

        NUM_OCM1_N = input(NUM_OCM1,12.);
        NUM_OCM2_N = input(NUM_OCM2,12.);
        NUM_OCM3_N = input(NUM_OCM3,12.);
        DEN_OCM3_N = input(DEN_OCM3,12.);

        if RECON_ATT_MATCH_CANC = 1 then RECON_ATT_CANCER_MATCH = 'Yes';
            else RECON_ATT_CANCER_MATCH = 'No';

        if RECON_ATT_MATCH_EPI = 1 then RECON_ATT_MATCH_EPI_USE = 'Yes';
                else RECON_ATT_MATCH_EPI_USE = 'No';

        if RECON_ATT_MATCH_STRT = 1 then RECON_ATT_MATCH_STRT_USE = 'Yes';
                else RECON_ATT_MATCH_STRT_USE = 'No';

        EXP_ALL_SERVICES_MATCH_USE = propcase(EXP_ALL_SERVICES_MATCH);

        TIN_MATCH_USE = propcase(TIN_MATCH);

		if bene_in_prior = 'Drop' then EPISODE_STATUS = 'Dropped';
        if bene_in_prior = 'No' then EPISODE_STATUS = 'New';
		if bene_in_prior = 'Yes' and prior_changed_episode = 'Yes' then EPISODE_STATUS = 'Changed';
            else EPISODE_STATUS = 'None';

        if bene_in_prior = 'Drop' then EPISODE_DROPPED = 'Yes';
			else EPISODE_DROPPED = 'No';

        if bene_in_prior = 'No' then EPISODE_NEW = 'Yes';
			else EPISODE_NEW = 'No';

		if bene_in_prior = 'Yes' and prior_changed_episode = 'Yes' then EPISODE_CHANGED = 'Yes';
            else EPISODE_CHANGED = 'No';

            ***Make MILLIMAN_CANCER_TYPE_USE***;
        if CANCER_TYPE_MILLIMAN = '' then MILLIMAN_CANCER_TYPE_USE = 'Unknown';
        else if CANCER_TYPE_MILLIMAN='MEOS, no PBP' then MILLIMAN_CANCER_TYPE_USE = 'MEOS, no PBP';
        else if CANCER_TYPE_MILLIMAN='Acute Leukemia' then MILLIMAN_CANCER_TYPE_USE='Acute Leukemia';
        else if CANCER_TYPE_MILLIMAN='Anal Cancer' then MILLIMAN_CANCER_TYPE_USE='Anal Cancer';
        else if CANCER_TYPE_MILLIMAN='Bladder Cancer' then MILLIMAN_CANCER_TYPE_USE='Bladder Cancer';
        else if CANCER_TYPE_MILLIMAN='Bladder Cancer - Low Risk' then MILLIMAN_CANCER_TYPE_USE='Bladder Cancer - Low Risk';
        else if CANCER_TYPE_MILLIMAN='Bladder Cancer - High Risk' then MILLIMAN_CANCER_TYPE_USE='Bladder Cancer - High Risk';
        else if CANCER_TYPE_MILLIMAN='Breast Cancer' then MILLIMAN_CANCER_TYPE_USE='Breast Cancer';
        else if CANCER_TYPE_MILLIMAN='Breast Cancer - Low Risk' then MILLIMAN_CANCER_TYPE_USE='Breast Cancer - Low Risk';
        else if CANCER_TYPE_MILLIMAN='Breast Cancer - High Risk' then MILLIMAN_CANCER_TYPE_USE='Breast Cancer - High Risk';
        else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of breast' then MILLIMAN_CANCER_TYPE_USE='CIS of breast';
        else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of middle ear and respiratory system' then MILLIMAN_CANCER_TYPE_USE='CIS of ear and resp';
        else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of other and NOS genital organs' then MILLIMAN_CANCER_TYPE_USE='CIS of other genital';
        else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of other and NOS digestive organs' then MILLIMAN_CANCER_TYPE_USE='CIS of other digestive';
        else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of other and unspecified sites' then MILLIMAN_CANCER_TYPE_USE='CIS of other, UNS';
        else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of other and NOS sites' then MILLIMAN_CANCER_TYPE_USE='CIS of other, UNS';
        else if CANCER_TYPE_MILLIMAN='Chronic Leukemia' then MILLIMAN_CANCER_TYPE_USE='Chronic Leukemia';
        else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of cervix uteri' then MILLIMAN_CANCER_TYPE_USE='CIS of uterine cervix';
        else if CANCER_TYPE_MILLIMAN='Chronic leukemia of unspecified cell type' then MILLIMAN_CANCER_TYPE_USE='Chronic Leukemia, UNS';
        else if CANCER_TYPE_MILLIMAN='Chronic myelomonocytic leukemia' then MILLIMAN_CANCER_TYPE_USE='CMML';
        else if CANCER_TYPE_MILLIMAN='CNS Tumor' then MILLIMAN_CANCER_TYPE_USE='CNS Tumor';
        else if CANCER_TYPE_MILLIMAN='Endocrine Tumor' then MILLIMAN_CANCER_TYPE_USE='Endocrine Tumor';
        else if CANCER_TYPE_MILLIMAN='Female GU Cancer other than Ovary' then MILLIMAN_CANCER_TYPE_USE='Female GU excl ovary';
        else if CANCER_TYPE_MILLIMAN='Gastro/Esophageal Cancer' then MILLIMAN_CANCER_TYPE_USE='Gastro/Esophageal Cancer';
        else if CANCER_TYPE_MILLIMAN='Head and Neck Cancer' then MILLIMAN_CANCER_TYPE_USE='Head and Neck Cancer';
        else if CANCER_TYPE_MILLIMAN='Intestinal Cancer' then MILLIMAN_CANCER_TYPE_USE='Colorectal/Intestinal Cancer';
        else if substr(CANCER_TYPE_MILLIMAN,1,5)='Kapos' then MILLIMAN_CANCER_TYPE_USE='Kaposis Sarcoma';
        else if CANCER_TYPE_MILLIMAN='Kidney Cancer' then MILLIMAN_CANCER_TYPE_USE='Kidney Cancer';
        else if CANCER_TYPE_MILLIMAN='Leukemia, unspecified' then MILLIMAN_CANCER_TYPE_USE='Leukemia, UNS';
        else if CANCER_TYPE_MILLIMAN='Liver Cancer' then MILLIMAN_CANCER_TYPE_USE='Liver Cancer';
        else if CANCER_TYPE_MILLIMAN='Lung Cancer' then MILLIMAN_CANCER_TYPE_USE='Lung Cancer';
        else if CANCER_TYPE_MILLIMAN='Lymphoid Leukemia, unspecified' then MILLIMAN_CANCER_TYPE_USE='Lymphoid Leukemia, UNS';
        else if CANCER_TYPE_MILLIMAN='Lymphoma' then MILLIMAN_CANCER_TYPE_USE='Lymphoma';
        else if CANCER_TYPE_MILLIMAN='Malignant Melanoma' then MILLIMAN_CANCER_TYPE_USE='Malignant Melanoma';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm NOS' then MILLIMAN_CANCER_TYPE_USE='MN NOS';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of abdomen' then MILLIMAN_CANCER_TYPE_USE='MN of abdomen';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of bone and articular cartilage of limbs' then MILLIMAN_CANCER_TYPE_USE='MN of bone, limbs';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of bone and articular cartilage of sites NOS' then MILLIMAN_CANCER_TYPE_USE='MN of bone, other sites';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of bone and articular cartilage of other and unspecified sites' then MILLIMAN_CANCER_TYPE_USE='MN of bone, other sites';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of heart, mediastinum and pleura' then MILLIMAN_CANCER_TYPE_USE='MN of heart';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of lymphoid, hematopoietic NOS' then MILLIMAN_CANCER_TYPE_USE='MN lymphoid NOS';
        else if CANCER_TYPE_MILLIMAN='Other and unspecified malignant neoplasms of lymphoid, hematopoietic and related tissue' then MILLIMAN_CANCER_TYPE_USE='MN lymphoid NOS';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of other and ill-defined digestive organs' then MILLIMAN_CANCER_TYPE_USE='MN of digest';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of other and unspecified female genital organs' then MILLIMAN_CANCER_TYPE_USE='MN of female genital';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of other specified ill-defined sites' then MILLIMAN_CANCER_TYPE_USE='MN of other';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of other and ill-defined sites' then MILLIMAN_CANCER_TYPE_USE='MN of other';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of penis, other, and unspecific male organs' then MILLIMAN_CANCER_TYPE_USE='MN of male genital';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of peripheral nerves, autonomic nervous system' then MILLIMAN_CANCER_TYPE_USE='MN of nervous sys';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of retroperitoneum and peritoneum' then MILLIMAN_CANCER_TYPE_USE='MN of peritoneum';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of skin, NOS' then MILLIMAN_CANCER_TYPE_USE='MN of skin NOS';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of testis' then MILLIMAN_CANCER_TYPE_USE='MN of testis';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of thorax' then MILLIMAN_CANCER_TYPE_USE='MN of thorax';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of thymus' then MILLIMAN_CANCER_TYPE_USE='MN of thymus';
        else if CANCER_TYPE_MILLIMAN='MDS' then MILLIMAN_CANCER_TYPE_USE='MDS';
        else if CANCER_TYPE_MILLIMAN='Merkel cell carcinoma' then MILLIMAN_CANCER_TYPE_USE='Merkel cell carcinoma';
        else if CANCER_TYPE_MILLIMAN='Multiple Myeloma' then MILLIMAN_CANCER_TYPE_USE='Multiple Myeloma';
        else if CANCER_TYPE_MILLIMAN='Ovarian Cancer' then MILLIMAN_CANCER_TYPE_USE='Ovarian Cancer';
        else if CANCER_TYPE_MILLIMAN='Pancreatic Cancer' then MILLIMAN_CANCER_TYPE_USE='Pancreatic Cancer';
        else if CANCER_TYPE_MILLIMAN='Prostate Cancer' then MILLIMAN_CANCER_TYPE_USE='Prostate Cancer';
        else if CANCER_TYPE_MILLIMAN='Prostate Cancer - High Intensity' then MILLIMAN_CANCER_TYPE_USE='Prostate Cancer - High Intensity';
        else if CANCER_TYPE_MILLIMAN='Prostate Cancer - Low Intensity' then MILLIMAN_CANCER_TYPE_USE='Prostate Cancer - Low Intensity';
        else if CANCER_TYPE_MILLIMAN='Atypical chronic myeloid leukemia, BCR/ABL negative' then MILLIMAN_CANCER_TYPE_USE='Atypical CML, BCR/ABL neg';
        else if CANCER_TYPE_MILLIMAN='Juvenile myelomonocytic leukemia' then MILLIMAN_CANCER_TYPE_USE='JMML';
        else if CANCER_TYPE_MILLIMAN='Monocytic Leukemia, unspecified' then MILLIMAN_CANCER_TYPE_USE='Monocytic Leukemia, UNS';
        else if CANCER_TYPE_MILLIMAN='Myeloid leukemia, unspecified' then MILLIMAN_CANCER_TYPE_USE='Myeloid Leukemia, UNS';
        else if CANCER_TYPE_MILLIMAN='Other lymphoid leukemia' then MILLIMAN_CANCER_TYPE_USE='Lymphoid Leukemia, OTH';
        else if CANCER_TYPE_MILLIMAN='Other monocytic leukemia' then MILLIMAN_CANCER_TYPE_USE='Monocytic Leukemia, OTH';
        else if CANCER_TYPE_MILLIMAN='Other myeloid leukemia' then MILLIMAN_CANCER_TYPE_USE='Myeloid Leukemia, OTH';
        else if CANCER_TYPE_MILLIMAN='Other specified leukemias' then MILLIMAN_CANCER_TYPE_USE='Leukemia, OTH';
        else if CANCER_TYPE_MILLIMAN='Other SPECIFIED leukemias' then MILLIMAN_CANCER_TYPE_USE='Leukemia, OTH';
        else if CANCER_TYPE_MILLIMAN='Small Intestine / Colorectal Cancer' then MILLIMAN_CANCER_TYPE_USE='Colorectal/Intestinal Cancer';
        else if CANCER_TYPE_MILLIMAN='Secondary malignant neoplasm of lymph nodes' then MILLIMAN_CANCER_TYPE_USE='SEC and UNS MN lymph';
        else if CANCER_TYPE_MILLIMAN='Secondary malignant neoplasm of other and unspecified sites' then MILLIMAN_CANCER_TYPE_USE='SEC MN, OTH and UNS';
        else if CANCER_TYPE_MILLIMAN='Secondary malignant neoplasm of respiratory and digestive organs' then MILLIMAN_CANCER_TYPE_USE='SEC MN, resp and digest';
        else if CANCER_TYPE_MILLIMAN='Secondary malignant neoplasm of resp and digestive organs' then MILLIMAN_CANCER_TYPE_USE='SEC MN, resp and digest';
        else if CANCER_TYPE_MILLIMAN='Secondary neuroendocrine tumors' then MILLIMAN_CANCER_TYPE_USE='SEC neuroendocrine tumors';
        else if CANCER_TYPE_MILLIMAN='Myeloid Leukemia, NOS' then MILLIMAN_CANCER_TYPE_USE='Myeloid Leukemia, NOS';
        else if CANCER_TYPE_MILLIMAN='Secondary malignant neoplasm NOS' then MILLIMAN_CANCER_TYPE_USE='SEC MN, OTH and UNS';
        else if CANCER_TYPE_MILLIMAN='Melanoma in situ' then MILLIMAN_CANCER_TYPE_USE='Melanoma in situ';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of pelvis' then MILLIMAN_CANCER_TYPE_USE='Malignant neoplasm of pelvis';
        else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of skin' then MILLIMAN_CANCER_TYPE_USE = 'Carcinoma in situ of skin';
        else if CANCER_TYPE_MILLIMAN='Malignant neoplasm without specification of site' then MILLIMAN_CANCER_TYPE_USE = 'MN of unknown site';
        else if CANCER_TYPE_MILLIMAN='Other and unspecified malignant neoplasm of skin' then MILLIMAN_CANCER_TYPE_USE = 'Skin, UNS or OTH';
        else if CANCER_TYPE_MILLIMAN='UNKNOWN' then MILLIMAN_CANCER_TYPE_USE = 'Unknown';
        else if CANCER_TYPE_MILLIMAN='' then MILLIMAN_CANCER_TYPE_USE = 'Unknown';
        else if CANCER_TYPE_MILLIMAN='C91.z' then MILLIMAN_CANCER_TYPE_USE = 'Lymphoid Leukemia, OTH';
        else if CANCER_TYPE_MILLIMAN='C92.2' then MILLIMAN_CANCER_TYPE_USE = 'Atypical CML, BCR/ABL neg';
        else if CANCER_TYPE_MILLIMAN='D00' then MILLIMAN_CANCER_TYPE_USE = 'CIS of oral, esophagus, stomach';
        else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of oral cavity, esophagus, stomach' then MILLIMAN_CANCER_TYPE_USE = 'CIS of oral, esophagus, stomach';
        else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of oral cavity, espophagus, stomach' then MILLIMAN_CANCER_TYPE_USE = 'CIS of oral, esophagus, stomach';
        else if CANCER_TYPE_MILLIMAN='C93.9' then MILLIMAN_CANCER_TYPE_USE = 'Monocytic Leukemia, UNS';
        else if CANCER_TYPE_MILLIMAN='Monocytic Leukemia, NOS' then MILLIMAN_CANCER_TYPE_USE = 'Monocytic Leukemia, UNS';
        else if CANCER_TYPE_MILLIMAN='D05' then MILLIMAN_CANCER_TYPE_USE='CIS of breast';
        else if CANCER_TYPE_MILLIMAN='C44' then MILLIMAN_CANCER_TYPE_USE = 'Skin, UNS or OTH';
        else if CANCER_TYPE_MILLIMAN='C80' then MILLIMAN_CANCER_TYPE_USE = 'MN of unknown site';
        else if CANCER_TYPE_MILLIMAN='C48' then MILLIMAN_CANCER_TYPE_USE='MN of peritoneum';
        else if CANCER_TYPE_MILLIMAN='C57' then MILLIMAN_CANCER_TYPE_USE='MN of female genital';
        else if CANCER_TYPE_MILLIMAN='C4A' then MILLIMAN_CANCER_TYPE_USE='Merkel cell carcinoma';
        else if CANCER_TYPE_MILLIMAN='C92.9' then MILLIMAN_CANCER_TYPE_USE='Myeloid Leukemia, UNS';
        else if CANCER_TYPE_MILLIMAN='Polycythemia vera' then MILLIMAN_CANCER_TYPE_USE='Polycythemia Vera';
        else if CANCER_TYPE_MILLIMAN='Chronic myeloproliferative disease' then MILLIMAN_CANCER_TYPE_USE='Chronic Myeloproliferative Disease';
        else if CANCER_TYPE_MILLIMAN='Essential (hemorrhagic) thrombocythemia' then MILLIMAN_CANCER_TYPE_USE='Essential Thrombocythemia';
        else if CANCER_TYPE_MILLIMAN='Essential thrombocythemia' then MILLIMAN_CANCER_TYPE_USE='Essential Thrombocythemia';
        else if CANCER_TYPE_MILLIMAN='Osteomyelofibrosis' then MILLIMAN_CANCER_TYPE_USE='Osteomyelofibrosis';
        else if CANCER_TYPE_MILLIMAN='Myelofibrosis' then MILLIMAN_CANCER_TYPE_USE='Myelofibrosis';
        else if CANCER_TYPE_MILLIMAN='Juvenile myelomonocytic leukemia' then MILLIMAN_CANCER_TYPE_USE='JUV Myelomonocytic Leukemia';
        else if CANCER_TYPE_MILLIMAN='CAR-T' then MILLIMAN_CANCER_TYPE_USE='CAR-T';

            ***Make CMS_CANCER_TYPE_USE***;
        if CANCER_TYPE = '' then CMS_CANCER_TYPE_USE = 'Unknown';
        else if CANCER_TYPE='MEOS, no PBP' then CMS_CANCER_TYPE_USE = 'MEOS, no PBP';
        else if CANCER_TYPE='Acute Leukemia' then CMS_CANCER_TYPE_USE='Acute Leukemia';
        else if CANCER_TYPE='Anal Cancer' then CMS_CANCER_TYPE_USE='Anal Cancer';
        else if CANCER_TYPE='Bladder Cancer' then CMS_CANCER_TYPE_USE='Bladder Cancer';
        else if CANCER_TYPE='Bladder Cancer - Low Risk' then CMS_CANCER_TYPE_USE='Bladder Cancer - Low Risk';
        else if CANCER_TYPE='Bladder Cancer - High Risk' then CMS_CANCER_TYPE_USE='Bladder Cancer - High Risk';
        else if CANCER_TYPE='Breast Cancer' then CMS_CANCER_TYPE_USE='Breast Cancer';
        else if CANCER_TYPE='Breast Cancer - Low Risk' then CMS_CANCER_TYPE_USE='Breast Cancer - Low Risk';
        else if CANCER_TYPE='Breast Cancer - High Risk' then CMS_CANCER_TYPE_USE='Breast Cancer - High Risk';
        else if CANCER_TYPE='Carcinoma in situ of breast' then CMS_CANCER_TYPE_USE='CIS of breast';
        else if CANCER_TYPE='Carcinoma in situ of middle ear and respiratory system' then CMS_CANCER_TYPE_USE='CIS of ear and resp';
        else if CANCER_TYPE='Carcinoma in situ of other and NOS genital organs' then CMS_CANCER_TYPE_USE='CIS of other genital';
        else if CANCER_TYPE='Carcinoma in situ of other and NOS digestive organs' then CMS_CANCER_TYPE_USE='CIS of other digestive';
        else if CANCER_TYPE='Carcinoma in situ of other and unspecified sites' then CMS_CANCER_TYPE_USE='CIS of other, UNS';
        else if CANCER_TYPE='Carcinoma in situ of other and NOS sites' then CMS_CANCER_TYPE_USE='CIS of other, UNS';
        else if CANCER_TYPE='Chronic Leukemia' then CMS_CANCER_TYPE_USE='Chronic Leukemia';
        else if CANCER_TYPE='Carcinoma in situ of cervix uteri' then CMS_CANCER_TYPE_USE='CIS of uterine cervix';
        else if CANCER_TYPE='Chronic leukemia of unspecified cell type' then CMS_CANCER_TYPE_USE='Chronic Leukemia, UNS';
        else if CANCER_TYPE='Chronic myelomonocytic leukemia' then CMS_CANCER_TYPE_USE='CMML';
        else if CANCER_TYPE='CNS Tumor' then CMS_CANCER_TYPE_USE='CNS Tumor';
        else if CANCER_TYPE='Endocrine Tumor' then CMS_CANCER_TYPE_USE='Endocrine Tumor';
        else if CANCER_TYPE='Female GU Cancer other than Ovary' then CMS_CANCER_TYPE_USE='Female GU excl ovary';
        else if CANCER_TYPE='Gastro/Esophageal Cancer' then CMS_CANCER_TYPE_USE='Gastro/Esophageal Cancer';
        else if CANCER_TYPE='Head and Neck Cancer' then CMS_CANCER_TYPE_USE='Head and Neck Cancer';
        else if CANCER_TYPE='Intestinal Cancer' then CMS_CANCER_TYPE_USE='Colorectal/Intestinal Cancer';
        else if substr(CANCER_TYPE,1,5)='Kapos' then CMS_CANCER_TYPE_USE='Kaposis Sarcoma';
        else if CANCER_TYPE='Kidney Cancer' then CMS_CANCER_TYPE_USE='Kidney Cancer';
        else if CANCER_TYPE='Leukemia, unspecified' then CMS_CANCER_TYPE_USE='Leukemia, UNS';
        else if CANCER_TYPE='Liver Cancer' then CMS_CANCER_TYPE_USE='Liver Cancer';
        else if CANCER_TYPE='Lung Cancer' then CMS_CANCER_TYPE_USE='Lung Cancer';
        else if CANCER_TYPE='Lymphoid Leukemia, unspecified' then CMS_CANCER_TYPE_USE='Lymphoid Leukemia, UNS';
        else if CANCER_TYPE='Lymphoma' then CMS_CANCER_TYPE_USE='Lymphoma';
        else if CANCER_TYPE='Malignant Melanoma' then CMS_CANCER_TYPE_USE='Malignant Melanoma';
        else if CANCER_TYPE='Malignant neoplasm NOS' then CMS_CANCER_TYPE_USE='MN NOS';
        else if CANCER_TYPE='Malignant neoplasm of abdomen' then CMS_CANCER_TYPE_USE='MN of abdomen';
        else if CANCER_TYPE='Malignant neoplasm of bone and articular cartilage of limbs' then CMS_CANCER_TYPE_USE='MN of bone, limbs';
        else if CANCER_TYPE='Malignant neoplasm of bone and articular cartilage of sites NOS' then CMS_CANCER_TYPE_USE='MN of bone, other sites';
        else if CANCER_TYPE='Malignant neoplasm of bone and articular cartilage of other and unspecified sites' then CMS_CANCER_TYPE_USE='MN of bone, other sites';
        else if CANCER_TYPE='Malignant neoplasm of heart, mediastinum and pleura' then CMS_CANCER_TYPE_USE='MN of heart';
        else if CANCER_TYPE='Malignant neoplasm of lymphoid, hematopoietic NOS' then CMS_CANCER_TYPE_USE='MN lymphoid NOS';
        else if CANCER_TYPE='Other and unspecified malignant neoplasms of lymphoid, hematopoietic and related tissue' then CMS_CANCER_TYPE_USE='MN lymphoid NOS';
        else if CANCER_TYPE='Malignant neoplasm of other and ill-defined digestive organs' then CMS_CANCER_TYPE_USE='MN of digest';
        else if CANCER_TYPE='Malignant neoplasm of other and unspecified female genital organs' then CMS_CANCER_TYPE_USE='MN of female genital';
        else if CANCER_TYPE='Malignant neoplasm of other specified ill-defined sites' then CMS_CANCER_TYPE_USE='MN of other';
        else if CANCER_TYPE='Malignant neoplasm of other and ill-defined sites' then CMS_CANCER_TYPE_USE='MN of other';
        else if CANCER_TYPE='Malignant neoplasm of penis, other, and unspecific male organs' then CMS_CANCER_TYPE_USE='MN of male genital';
        else if CANCER_TYPE='Malignant neoplasm of peripheral nerves, autonomic nervous system' then CMS_CANCER_TYPE_USE='MN of nervous sys';
        else if CANCER_TYPE='Malignant neoplasm of retroperitoneum and peritoneum' then CMS_CANCER_TYPE_USE='MN of peritoneum';
        else if CANCER_TYPE='Malignant neoplasm of skin, NOS' then CMS_CANCER_TYPE_USE='MN of skin NOS';
        else if CANCER_TYPE='Malignant neoplasm of testis' then CMS_CANCER_TYPE_USE='MN of testis';
        else if CANCER_TYPE='Malignant neoplasm of thorax' then CMS_CANCER_TYPE_USE='MN of thorax';
        else if CANCER_TYPE='Malignant neoplasm of thymus' then CMS_CANCER_TYPE_USE='MN of thymus';
        else if CANCER_TYPE='MDS' then CMS_CANCER_TYPE_USE='MDS';
        else if CANCER_TYPE='Merkel cell carcinoma' then CMS_CANCER_TYPE_USE='Merkel cell carcinoma';
        else if CANCER_TYPE='Multiple Myeloma' then CMS_CANCER_TYPE_USE='Multiple Myeloma';
        else if CANCER_TYPE='Ovarian Cancer' then CMS_CANCER_TYPE_USE='Ovarian Cancer';
        else if CANCER_TYPE='Pancreatic Cancer' then CMS_CANCER_TYPE_USE='Pancreatic Cancer';
        else if CANCER_TYPE='Prostate Cancer' then CMS_CANCER_TYPE_USE='Prostate Cancer';
        else if CANCER_TYPE='Prostate Cancer - High Intensity' then CMS_CANCER_TYPE_USE='Prostate Cancer - High Intensity';
        else if CANCER_TYPE='Prostate Cancer - Low Intensity' then CMS_CANCER_TYPE_USE='Prostate Cancer - Low Intensity';
        else if CANCER_TYPE='Atypical chronic myeloid leukemia, BCR/ABL negative' then CMS_CANCER_TYPE_USE='Atypical CML, BCR/ABL neg';
        else if CANCER_TYPE='Juvenile myelomonocytic leukemia' then CMS_CANCER_TYPE_USE='JMML';
        else if CANCER_TYPE='Monocytic Leukemia, unspecified' then CMS_CANCER_TYPE_USE='Monocytic Leukemia, UNS';
        else if CANCER_TYPE='Myeloid leukemia, unspecified' then CMS_CANCER_TYPE_USE='Myeloid Leukemia, UNS';
        else if CANCER_TYPE='Other lymphoid leukemia' then CMS_CANCER_TYPE_USE='Lymphoid Leukemia, OTH';
        else if CANCER_TYPE='Other monocytic leukemia' then CMS_CANCER_TYPE_USE='Monocytic Leukemia, OTH';
        else if CANCER_TYPE='Other myeloid leukemia' then CMS_CANCER_TYPE_USE='Myeloid Leukemia, OTH';
        else if CANCER_TYPE='Other specified leukemias' then CMS_CANCER_TYPE_USE='Leukemia, OTH';
        else if CANCER_TYPE='Other SPECIFIED leukemias' then CMS_CANCER_TYPE_USE='Leukemia, OTH';
        else if CANCER_TYPE='Small Intestine / Colorectal Cancer' then CMS_CANCER_TYPE_USE='Colorectal/Intestinal Cancer'; /*HM updated - 4/24/2017*/
        else if CANCER_TYPE='Secondary malignant neoplasm of lymph nodes' then CMS_CANCER_TYPE_USE='SEC and UNS MN lymph';
        else if CANCER_TYPE='Secondary malignant neoplasm of other and unspecified sites' then CMS_CANCER_TYPE_USE='SEC MN, OTH and UNS';
        else if CANCER_TYPE='Secondary malignant neoplasm of respiratory and digestive organs' then CMS_CANCER_TYPE_USE='SEC MN, resp and digest';
        else if CANCER_TYPE='Secondary malignant neoplasm of resp and digestive organs' then CMS_CANCER_TYPE_USE='SEC MN, resp and digest';
        else if CANCER_TYPE='Secondary neuroendocrine tumors' then CMS_CANCER_TYPE_USE='SEC neuroendocrine tumors';
        else if CANCER_TYPE='Myeloid Leukemia, NOS' then CMS_CANCER_TYPE_USE='Myeloid Leukemia, NOS';
        else if CANCER_TYPE='Secondary malignant neoplasm NOS' then CMS_CANCER_TYPE_USE='SEC MN, OTH and UNS';
        else if CANCER_TYPE='Melanoma in situ' then CMS_CANCER_TYPE_USE='Melanoma in situ';
        else if CANCER_TYPE='Malignant neoplasm of pelvis' then CMS_CANCER_TYPE_USE='Malignant neoplasm of pelvis';
        else if CANCER_TYPE='Carcinoma in situ of skin' then CMS_CANCER_TYPE_USE = 'Carcinoma in situ of skin';
        else if CANCER_TYPE='Malignant neoplasm without specification of site' then CMS_CANCER_TYPE_USE = 'MN of unknown site';
        else if CANCER_TYPE='Other and unspecified malignant neoplasm of skin' then CMS_CANCER_TYPE_USE = 'Skin, UNS or OTH';
        else if CANCER_TYPE='UNKNOWN' then CMS_CANCER_TYPE_USE = 'Unknown';
        else if CANCER_TYPE='' then CMS_CANCER_TYPE_USE = 'Unknown';
        else if CANCER_TYPE='C91.z' then CMS_CANCER_TYPE_USE = 'Lymphoid Leukemia, OTH';
        else if CANCER_TYPE='C92.2' then CMS_CANCER_TYPE_USE = 'Atypical CML, BCR/ABL neg';
        else if CANCER_TYPE='D00' then CMS_CANCER_TYPE_USE = 'CIS of oral, esophagus, stomach';
        else if CANCER_TYPE='Carcinoma in situ of oral cavity, esophagus, stomach' then CMS_CANCER_TYPE_USE = 'CIS of oral, esophagus, stomach';
        else if CANCER_TYPE='Carcinoma in situ of oral cavity, espophagus, stomach' then CMS_CANCER_TYPE_USE = 'CIS of oral, esophagus, stomach';
        else if CANCER_TYPE='C93.9' then CMS_CANCER_TYPE_USE = 'Monocytic Leukemia, UNS';
        else if CANCER_TYPE='Monocytic Leukemia, NOS' then CMS_CANCER_TYPE_USE = 'Monocytic Leukemia, UNS';
        else if CANCER_TYPE='D05' then CMS_CANCER_TYPE_USE='CIS of breast';
        else if CANCER_TYPE='C44' then CMS_CANCER_TYPE_USE = 'Skin, UNS or OTH';
        else if CANCER_TYPE='C80' then CMS_CANCER_TYPE_USE = 'MN of unknown site';
        else if CANCER_TYPE='C48' then CMS_CANCER_TYPE_USE='MN of peritoneum';
        else if CANCER_TYPE='C57' then CMS_CANCER_TYPE_USE='MN of female genital';
        else if CANCER_TYPE='C4A' then CMS_CANCER_TYPE_USE='Merkel cell carcinoma';
        else if CANCER_TYPE='C92.9' then CMS_CANCER_TYPE_USE='Myeloid Leukemia, UNS';
        else if CANCER_TYPE='Polycythemia vera' then CMS_CANCER_TYPE_USE='Polycythemia Vera';
        else if CANCER_TYPE='Chronic myeloproliferative disease' then CMS_CANCER_TYPE_USE='Chronic Myeloproliferative Disease';
        else if CANCER_TYPE='Essential (hemorrhagic) thrombocythemia' then CMS_CANCER_TYPE_USE='Essential Thrombocythemia';
        else if CANCER_TYPE='Essential thrombocythemia' then CMS_CANCER_TYPE_USE='Essential Thrombocythemia';
        else if CANCER_TYPE='Osteomyelofibrosis' then CMS_CANCER_TYPE_USE='Osteomyelofibrosis';
        else if CANCER_TYPE='Myelofibrosis' then CMS_CANCER_TYPE_USE='Myelofibrosis';
        else if CANCER_TYPE='Juvenile myelomonocytic leukemia' then CMS_CANCER_TYPE_USE='JUV Myelomonocytic Leukemia';
        else if CANCER_TYPE='C49' then CMS_CANCER_TYPE_USE='MN of other connective, soft tissue';
        else if CANCER_TYPE='CAR-T' then CMS_CANCER_TYPE_USE='CAR-T';

    end;

    if substr(EP_ID_CMS,1,3) = 'XXX' then do;

        *MAKE CANCER_TYPE_PRIOR_USE*;
        if CANCER_TYPE_PRIOR = '' then CMS_CANCER_TYPE_PRIOR_USE = 'Unknown';
        else if CANCER_TYPE_PRIOR='MEOS, no PBP' then CMS_CANCER_TYPE_PRIOR_USE = 'MEOS, no PBP';
        else if CANCER_TYPE_PRIOR='Acute Leukemia' then CMS_CANCER_TYPE_PRIOR_USE='Acute Leukemia';
        else if CANCER_TYPE_PRIOR='Anal Cancer' then CMS_CANCER_TYPE_PRIOR_USE='Anal Cancer';
        else if CANCER_TYPE_PRIOR='Bladder Cancer' then CMS_CANCER_TYPE_PRIOR_USE='Bladder Cancer';
        else if CANCER_TYPE_PRIOR='Bladder Cancer - Low Risk' then CMS_CANCER_TYPE_PRIOR_USE='Bladder Cancer - Low Risk';
        else if CANCER_TYPE_PRIOR='Bladder Cancer - High Risk' then CMS_CANCER_TYPE_PRIOR_USE='Bladder Cancer - High Risk';
        else if CANCER_TYPE_PRIOR='Breast Cancer' then CMS_CANCER_TYPE_PRIOR_USE='Breast Cancer';
        else if CANCER_TYPE_PRIOR='Breast Cancer - Low Risk' then CMS_CANCER_TYPE_PRIOR_USE='Breast Cancer - Low Risk';
        else if CANCER_TYPE_PRIOR='Breast Cancer - High Risk' then CMS_CANCER_TYPE_PRIOR_USE='Breast Cancer - High Risk';
        else if CANCER_TYPE_PRIOR='Carcinoma in situ of breast' then CMS_CANCER_TYPE_PRIOR_USE='CIS of breast';
        else if CANCER_TYPE_PRIOR='Carcinoma in situ of middle ear and respiratory system' then CMS_CANCER_TYPE_PRIOR_USE='CIS of ear and resp';
        else if CANCER_TYPE_PRIOR='Carcinoma in situ of other and NOS genital organs' then CMS_CANCER_TYPE_PRIOR_USE='CIS of other genital';
        else if CANCER_TYPE_PRIOR='Carcinoma in situ of other and NOS digestive organs' then CMS_CANCER_TYPE_PRIOR_USE='CIS of other digestive';
        else if CANCER_TYPE_PRIOR='Carcinoma in situ of other and unspecified sites' then CMS_CANCER_TYPE_PRIOR_USE='CIS of other, UNS';
        else if CANCER_TYPE_PRIOR='Carcinoma in situ of other and NOS sites' then CMS_CANCER_TYPE_PRIOR_USE='CIS of other, UNS';
        else if CANCER_TYPE_PRIOR='Chronic Leukemia' then CMS_CANCER_TYPE_PRIOR_USE='Chronic Leukemia';
        else if CANCER_TYPE_PRIOR='Carcinoma in situ of cervix uteri' then CMS_CANCER_TYPE_PRIOR_USE='CIS of uterine cervix';
        else if CANCER_TYPE_PRIOR='Chronic leukemia of unspecified cell type' then CMS_CANCER_TYPE_PRIOR_USE='Chronic Leukemia, UNS';
        else if CANCER_TYPE_PRIOR='Chronic myelomonocytic leukemia' then CMS_CANCER_TYPE_PRIOR_USE='CMML';
        else if CANCER_TYPE_PRIOR='CNS Tumor' then CMS_CANCER_TYPE_PRIOR_USE='CNS Tumor';
        else if CANCER_TYPE_PRIOR='Endocrine Tumor' then CMS_CANCER_TYPE_PRIOR_USE='Endocrine Tumor';
        else if CANCER_TYPE_PRIOR='Female GU Cancer other than Ovary' then CMS_CANCER_TYPE_PRIOR_USE='Female GU excl ovary';
        else if CANCER_TYPE_PRIOR='Gastro/Esophageal Cancer' then CMS_CANCER_TYPE_PRIOR_USE='Gastro/Esophageal Cancer';
        else if CANCER_TYPE_PRIOR='Head and Neck Cancer' then CMS_CANCER_TYPE_PRIOR_USE='Head and Neck Cancer';
        else if CANCER_TYPE_PRIOR='Intestinal Cancer' then CMS_CANCER_TYPE_PRIOR_USE='Colorectal/Intestinal Cancer';
        else if substr(CANCER_TYPE_PRIOR,1,5)='Kapos' then CMS_CANCER_TYPE_PRIOR_USE='Kaposis Sarcoma';
        else if CANCER_TYPE_PRIOR='Kidney Cancer' then CMS_CANCER_TYPE_PRIOR_USE='Kidney Cancer';
        else if CANCER_TYPE_PRIOR='Leukemia, unspecified' then CMS_CANCER_TYPE_PRIOR_USE='Leukemia, UNS';
        else if CANCER_TYPE_PRIOR='Liver Cancer' then CMS_CANCER_TYPE_PRIOR_USE='Liver Cancer';
        else if CANCER_TYPE_PRIOR='Lung Cancer' then CMS_CANCER_TYPE_PRIOR_USE='Lung Cancer';
        else if CANCER_TYPE_PRIOR='Lymphoid Leukemia, unspecified' then CMS_CANCER_TYPE_PRIOR_USE='Lymphoid Leukemia, UNS';
        else if CANCER_TYPE_PRIOR='Lymphoma' then CMS_CANCER_TYPE_PRIOR_USE='Lymphoma';
        else if CANCER_TYPE_PRIOR='Malignant Melanoma' then CMS_CANCER_TYPE_PRIOR_USE='Malignant Melanoma';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm NOS' then CMS_CANCER_TYPE_PRIOR_USE='MN NOS';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of abdomen' then CMS_CANCER_TYPE_PRIOR_USE='MN of abdomen';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of bone and articular cartilage of limbs' then CMS_CANCER_TYPE_PRIOR_USE='MN of bone, limbs';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of bone and articular cartilage of sites NOS' then CMS_CANCER_TYPE_PRIOR_USE='MN of bone, other sites';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of bone and articular cartilage of other and unspecified sites' then CMS_CANCER_TYPE_PRIOR_USE='MN of bone, other sites';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of heart, mediastinum and pleura' then CMS_CANCER_TYPE_PRIOR_USE='MN of heart';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of lymphoid, hematopoietic NOS' then CMS_CANCER_TYPE_PRIOR_USE='MN lymphoid NOS';
        else if CANCER_TYPE_PRIOR='Other and unspecified malignant neoplasms of lymphoid, hematopoietic and related tissue' then CMS_CANCER_TYPE_PRIOR_USE='MN lymphoid NOS';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of other and ill-defined digestive organs' then CMS_CANCER_TYPE_PRIOR_USE='MN of digest';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of other and unspecified female genital organs' then CMS_CANCER_TYPE_PRIOR_USE='MN of female genital';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of other specified ill-defined sites' then CMS_CANCER_TYPE_PRIOR_USE='MN of other';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of other and ill-defined sites' then CMS_CANCER_TYPE_PRIOR_USE='MN of other';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of penis, other, and unspecific male organs' then CMS_CANCER_TYPE_PRIOR_USE='MN of male genital';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of peripheral nerves, autonomic nervous system' then CMS_CANCER_TYPE_PRIOR_USE='MN of nervous sys';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of retroperitoneum and peritoneum' then CMS_CANCER_TYPE_PRIOR_USE='MN of peritoneum';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of skin, NOS' then CMS_CANCER_TYPE_PRIOR_USE='MN of skin NOS';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of testis' then CMS_CANCER_TYPE_PRIOR_USE='MN of testis';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of thorax' then CMS_CANCER_TYPE_PRIOR_USE='MN of thorax';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of thymus' then CMS_CANCER_TYPE_PRIOR_USE='MN of thymus';
        else if CANCER_TYPE_PRIOR='MDS' then CMS_CANCER_TYPE_PRIOR_USE='MDS';
        else if CANCER_TYPE_PRIOR='Merkel cell carcinoma' then CMS_CANCER_TYPE_PRIOR_USE='Merkel cell carcinoma';
        else if CANCER_TYPE_PRIOR='Multiple Myeloma' then CMS_CANCER_TYPE_PRIOR_USE='Multiple Myeloma';
        else if CANCER_TYPE_PRIOR='Ovarian Cancer' then CMS_CANCER_TYPE_PRIOR_USE='Ovarian Cancer';
        else if CANCER_TYPE_PRIOR='Pancreatic Cancer' then CMS_CANCER_TYPE_PRIOR_USE='Pancreatic Cancer';
        else if CANCER_TYPE_PRIOR='Prostate Cancer' then CMS_CANCER_TYPE_PRIOR_USE='Prostate Cancer';
        else if CANCER_TYPE_PRIOR='Prostate Cancer - High Intensity' then CMS_CANCER_TYPE_PRIOR_USE='Prostate Cancer - High Intensity';
        else if CANCER_TYPE_PRIOR='Prostate Cancer - Low Intensity' then CMS_CANCER_TYPE_PRIOR_USE='Prostate Cancer - Low Intensity';
        else if CANCER_TYPE_PRIOR='Atypical chronic myeloid leukemia, BCR/ABL negative' then CMS_CANCER_TYPE_PRIOR_USE='Atypical CML, BCR/ABL neg';
        else if CANCER_TYPE_PRIOR='Juvenile myelomonocytic leukemia' then CMS_CANCER_TYPE_PRIOR_USE='JMML';
        else if CANCER_TYPE_PRIOR='Monocytic Leukemia, unspecified' then CMS_CANCER_TYPE_PRIOR_USE='Monocytic Leukemia, UNS';
        else if CANCER_TYPE_PRIOR='Myeloid leukemia, unspecified' then CMS_CANCER_TYPE_PRIOR_USE='Myeloid Leukemia, UNS';
        else if CANCER_TYPE_PRIOR='Other lymphoid leukemia' then CMS_CANCER_TYPE_PRIOR_USE='Lymphoid Leukemia, OTH';
        else if CANCER_TYPE_PRIOR='Other monocytic leukemia' then CMS_CANCER_TYPE_PRIOR_USE='Monocytic Leukemia, OTH';
        else if CANCER_TYPE_PRIOR='Other myeloid leukemia' then CMS_CANCER_TYPE_PRIOR_USE='Myeloid Leukemia, OTH';
        else if CANCER_TYPE_PRIOR='Other specified leukemias' then CMS_CANCER_TYPE_PRIOR_USE='Leukemia, OTH';
        else if CANCER_TYPE_PRIOR='Other SPECIFIED leukemias' then CMS_CANCER_TYPE_PRIOR_USE='Leukemia, OTH';
        else if CANCER_TYPE_PRIOR='Small Intestine / Colorectal Cancer' then CMS_CANCER_TYPE_PRIOR_USE='Colorectal/Intestinal Cancer'; /*HM updated - 4/24/2017*/
        else if CANCER_TYPE_PRIOR='Secondary malignant neoplasm of lymph nodes' then CMS_CANCER_TYPE_PRIOR_USE='SEC and UNS MN lymph';
        else if CANCER_TYPE_PRIOR='Secondary malignant neoplasm of other and unspecified sites' then CMS_CANCER_TYPE_PRIOR_USE='SEC MN, OTH and UNS';
        else if CANCER_TYPE_PRIOR='Secondary malignant neoplasm of respiratory and digestive organs' then CMS_CANCER_TYPE_PRIOR_USE='SEC MN, resp and digest';
        else if CANCER_TYPE_PRIOR='Secondary malignant neoplasm of resp and digestive organs' then CMS_CANCER_TYPE_PRIOR_USE='SEC MN, resp and digest';
        else if CANCER_TYPE_PRIOR='Secondary neuroendocrine tumors' then CMS_CANCER_TYPE_PRIOR_USE='SEC neuroendocrine tumors';
        else if CANCER_TYPE_PRIOR='Myeloid Leukemia, NOS' then CMS_CANCER_TYPE_PRIOR_USE='Myeloid Leukemia, NOS';
        else if CANCER_TYPE_PRIOR='Secondary malignant neoplasm NOS' then CMS_CANCER_TYPE_PRIOR_USE='SEC MN, OTH and UNS';
        else if CANCER_TYPE_PRIOR='Melanoma in situ' then CMS_CANCER_TYPE_PRIOR_USE='Melanoma in situ';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm of pelvis' then CMS_CANCER_TYPE_PRIOR_USE='Malignant neoplasm of pelvis';
        else if CANCER_TYPE_PRIOR='Carcinoma in situ of skin' then CMS_CANCER_TYPE_PRIOR_USE = 'Carcinoma in situ of skin';
        else if CANCER_TYPE_PRIOR='Malignant neoplasm without specification of site' then CMS_CANCER_TYPE_PRIOR_USE = 'MN of unknown site';
        else if CANCER_TYPE_PRIOR='Other and unspecified malignant neoplasm of skin' then CMS_CANCER_TYPE_PRIOR_USE = 'Skin, UNS or OTH';
        else if CANCER_TYPE_PRIOR='UNKNOWN' then CMS_CANCER_TYPE_PRIOR_USE = 'Unknown';
        else if CANCER_TYPE_PRIOR='' then CMS_CANCER_TYPE_PRIOR_USE = 'Unknown';
        else if CANCER_TYPE_PRIOR='C91.z' then CMS_CANCER_TYPE_PRIOR_USE = 'Lymphoid Leukemia, OTH';
        else if CANCER_TYPE_PRIOR='C92.2' then CMS_CANCER_TYPE_PRIOR_USE = 'Atypical CML, BCR/ABL neg';
        else if CANCER_TYPE_PRIOR='D00' then CMS_CANCER_TYPE_PRIOR_USE = 'CIS of oral, esophagus, stomach';
        else if CANCER_TYPE_PRIOR='Carcinoma in situ of oral cavity, esophagus, stomach' then CMS_CANCER_TYPE_PRIOR_USE = 'CIS of oral, esophagus, stomach';
        else if CANCER_TYPE_PRIOR='Carcinoma in situ of oral cavity, espophagus, stomach' then CMS_CANCER_TYPE_PRIOR_USE = 'CIS of oral, esophagus, stomach';
        else if CANCER_TYPE_PRIOR='C93.9' then CMS_CANCER_TYPE_PRIOR_USE = 'Monocytic Leukemia, UNS';
        else if CANCER_TYPE_PRIOR='Monocytic Leukemia, NOS' then CMS_CANCER_TYPE_PRIOR_USE = 'Monocytic Leukemia, UNS';
        else if CANCER_TYPE_PRIOR='D05' then CMS_CANCER_TYPE_PRIOR_USE='CIS of breast';
        else if CANCER_TYPE_PRIOR='C44' then CMS_CANCER_TYPE_PRIOR_USE = 'Skin, UNS or OTH';
        else if CANCER_TYPE_PRIOR='C80' then CMS_CANCER_TYPE_PRIOR_USE = 'MN of unknown site';
        else if CANCER_TYPE_PRIOR='C48' then CMS_CANCER_TYPE_PRIOR_USE='MN of peritoneum';
        else if CANCER_TYPE_PRIOR='C57' then CMS_CANCER_TYPE_PRIOR_USE='MN of female genital';
        else if CANCER_TYPE_PRIOR='C4A' then CMS_CANCER_TYPE_PRIOR_USE='Merkel cell carcinoma';
        else if CANCER_TYPE_PRIOR='C92.9' then CMS_CANCER_TYPE_PRIOR_USE='Myeloid Leukemia, UNS';
        else if CANCER_TYPE_PRIOR='Polycythemia vera' then CMS_CANCER_TYPE_PRIOR_USE='Polycythemia Vera';
        else if CANCER_TYPE_PRIOR='Chronic myeloproliferative disease' then CMS_CANCER_TYPE_PRIOR_USE='Chronic Myeloproliferative Disease';
        else if CANCER_TYPE_PRIOR='Essential (hemorrhagic) thrombocythemia' then CMS_CANCER_TYPE_PRIOR_USE='Essential Thrombocythemia';
        else if CANCER_TYPE_PRIOR='Essential thrombocythemia' then CMS_CANCER_TYPE_PRIOR_USE='Essential Thrombocythemia';
        else if CANCER_TYPE_PRIOR='Osteomyelofibrosis' then CMS_CANCER_TYPE_PRIOR_USE='Osteomyelofibrosis';
        else if CANCER_TYPE_PRIOR='Myelofibrosis' then CMS_CANCER_TYPE_PRIOR_USE='Myelofibrosis';
        else if CANCER_TYPE_PRIOR='Juvenile myelomonocytic leukemia' then CMS_CANCER_TYPE_PRIOR_USE='JUV Myelomonocytic Leukemia';
        else if CANCER_TYPE_PRIOR='C49' then CMS_CANCER_TYPE_PRIOR_USE='MN of other connective, soft tissue';
        else if CANCER_TYPE_PRIOR='C46' then CMS_CANCER_TYPE_PRIOR_USE='Kaposis Sarcoma';
        else if CANCER_TYPE_PRIOR='C47 or C49' then CMS_CANCER_TYPE_PRIOR_USE='Malignant neoplasm of peripheral nerves, autonomic nervous system';
        else if CANCER_TYPE_PRIOR='CAR-T' then CMS_CANCER_TYPE_PRIOR_USE='CAR-T';

end;


**************************************************************;
*****************END RECON PROCESSING*************************;
**************************************************************;

**************************************************************;
***************BEGIN ATTRIBUTION PROCESSING*******************;
**************************************************************;

    if attrib_episode = 1 then do;

        if ATT_TIN_MATCH = 'UNK' then ATT_TIN_MATCH_USE = 'Unknown';
            else ATT_TIN_MATCH_USE = propcase(ATT_TIN_MATCH);
        ATT_CANCER_MATCH_USE = propcase(ATT_CANCER_MATCH);

        if EPISODE_PERIOD = 'PP1' or EPISODE_PERIOD = 'PP2' or EPISODE_PERIOD = 'PP3' then do;
            if ATT_IN_RECON = 1 then TRUE_UP_MATCH = 'Complete Match';
                else if ATT_IN_RECON = 2 then TRUE_UP_MATCH = 'New to True-up';
                else if ATT_IN_RECON = 3 then TRUE_UP_MATCH = 'Change in Start Date or Cancer Type';
                else if ATT_IN_RECON = 4 then TRUE_UP_MATCH = 'Dropped Episode';

            if ATT_CANC_MATCH_CMS = 2 then ATT_CANC_CHANGE_CMS = 'N/A';
                else if ATT_CANC_MATCH_CMS = 1 then ATT_CANC_CHANGE_CMS = 'Yes';
                else if ATT_CANC_MATCH_CMS in (0,.) then ATT_CANC_CHANGE_CMS = 'No';

            if ATT_EPI_PERD_MATCH_CMS = 2 then ATT_STRTDT_CHANGE_CMS = 'N/A';
                else if ATT_EPI_PERD_MATCH_CMS = 1 then ATT_STRTDT_CHANGE_CMS = 'Yes';
                else if ATT_EPI_PERD_MATCH_CMS in (0,.) then ATT_STRTDT_CHANGE_CMS = 'No';

            if ATT_CANC_MATCH_CMS = 1 then ATT_CANC_MATCH_CNT = 1;
                else ATT_CANC_MATCH_CNT = 0;

            if ATT_EPI_PERD_MATCH_CMS = 1 then ATT_STRTDT_MATCH_CNT = 1;
                else ATT_STRTDT_MATCH_CNT = 0;
        end;

        EPI_START_DATE_MATCH_USE = propcase(ATT_EPI_START_DATE_MATCH);
        IN_PERF_DATA_USE = propcase(ATT_IN_PERFORMANCE_DATA);
        PERF_PER_MATCH_USE = propcase(ATT_PERFORMANCE_PER_MATCH);
        CANCER_MATCH_USE = propcase(ATT_CANCER_MATCH);

        if ATT_EPI_START_DATE_MATCH = 'YES' then EPI_START_DATE_MATCH_COUNT = 1;
            else EPI_START_DATE_MATCH_COUNT = 0;
        if ATT_IN_PERFORMANCE_DATA = 'YES' then IN_PERF_DATA_COUNT = 1;
            else IN_PERF_DATA_COUNT = 0;
        if ATT_PERFORMANCE_PER_MATCH = 'YES' then PERF_PER_MATCH_COUNT = 1;
            else PERF_PER_MATCH_COUNT = 0;
        if ATT_CANCER_MATCH = 'YES' then CANCER_MATCH_COUNT = 1;
            else CANCER_MATCH_COUNT = 0;

        if RECON_ELIG_A = 'Y' then RECON_ELIG_USE = 'Yes';
            else RECON_ELIG_USE = 'No';

    end;

**************************************************************;
*****************END ATTRIBUTION PROCESSING*******************;
**************************************************************;

    TOTAL_EPISODE_COST=ALLOWED_MILLIMAN;

    if EPISODE_PERIOD = 'PP1' then PERF_PERIOD_LONG = 'Performance Period 1';
        else if EPISODE_PERIOD = 'PP2' then PERF_PERIOD_LONG = 'Performance Period 2';
        else if EPISODE_PERIOD = 'PP3' then PERF_PERIOD_LONG = 'Performance Period 3';
        else if EPISODE_PERIOD = 'PP4' then PERF_PERIOD_LONG = 'Performance Period 4';
        else if EPISODE_PERIOD = 'PP5' then PERF_PERIOD_LONG = 'Performance Period 5';
        else if EPISODE_PERIOD = 'BAS' then PERF_PERIOD_LONG = 'Baseline';
        else PERF_PERIOD_LONG = 'N/A';

    if EPISODE_PERIOD = 'BAS' then EPISODE_PERIOD_USE = 'Base';
        else if EPISODE_PERIOD = 'PP1' then EPISODE_PERIOD_USE = 'PP1';
        else if EPISODE_PERIOD = 'PP2' then EPISODE_PERIOD_USE = 'PP2';
        else if EPISODE_PERIOD = 'PP3' then EPISODE_PERIOD_USE = 'PP3';
        else if EPISODE_PERIOD = 'PP4' then EPISODE_PERIOD_USE = 'PP4';
        else if EPISODE_PERIOD = 'PP5' then EPISODE_PERIOD_USE = 'PP5';
        else EPISODE_PERIOD_USE = 'N/A';

    if EPI_COUNTER='' then EPI_COUNTER_USE='N/A';
        else EPI_COUNTER_USE=propcase(EPI_COUNTER);

    if CANCER_TYPE_MILLIMAN = '' then CANCER_TYPE_MILLIMAN = CANCER_TYPE;
        else if CANCER_TYPE_MILLIMAN='MEOS, no PBP' then CANCER_TYPE_MILLIMAN = CANCER_TYPE;

    if CANCER_TYPE_MILLIMAN='Acute Leukemia' then CANCER_TYPE_USE='Acute Leukemia';
    else if CANCER_TYPE_MILLIMAN='Anal Cancer' then CANCER_TYPE_USE='Anal Cancer';
    else if CANCER_TYPE_MILLIMAN='Bladder Cancer' then CANCER_TYPE_USE='Bladder Cancer';
    else if CANCER_TYPE_MILLIMAN='Bladder Cancer - Low Risk' then CANCER_TYPE_USE='Bladder Cancer - Low Risk';
    else if CANCER_TYPE_MILLIMAN='Bladder Cancer - High Risk' then CANCER_TYPE_USE='Bladder Cancer - High Risk';
    else if CANCER_TYPE_MILLIMAN='Breast Cancer' then CANCER_TYPE_USE='Breast Cancer';
    else if CANCER_TYPE_MILLIMAN='Breast Cancer - Low Risk' then CANCER_TYPE_USE='Breast Cancer - Low Risk';
    else if CANCER_TYPE_MILLIMAN='Breast Cancer - High Risk' then CANCER_TYPE_USE='Breast Cancer - High Risk';
    else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of breast' then CANCER_TYPE_USE='CIS of breast';
    else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of middle ear and respiratory system' then CANCER_TYPE_USE='CIS of ear and resp';
    else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of other and NOS genital organs' then CANCER_TYPE_USE='CIS of other genital';
    else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of other and NOS digestive organs' then CANCER_TYPE_USE='CIS of other digestive';
    else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of other and unspecified sites' then CANCER_TYPE_USE='CIS of other, UNS';
    else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of other and NOS sites' then CANCER_TYPE_USE='CIS of other, UNS';
    else if CANCER_TYPE_MILLIMAN='Chronic Leukemia' then CANCER_TYPE_USE='Chronic Leukemia';
    else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of cervix uteri' then CANCER_TYPE_USE='CIS of uterine cervix';
    else if CANCER_TYPE_MILLIMAN='Chronic leukemia of unspecified cell type' then CANCER_TYPE_USE='Chronic Leukemia, UNS';
    else if CANCER_TYPE_MILLIMAN='Chronic myelomonocytic leukemia' then CANCER_TYPE_USE='CMML';
    else if CANCER_TYPE_MILLIMAN='CNS Tumor' then CANCER_TYPE_USE='CNS Tumor';
    else if CANCER_TYPE_MILLIMAN='Endocrine Tumor' then CANCER_TYPE_USE='Endocrine Tumor';
    else if CANCER_TYPE_MILLIMAN='Female GU Cancer other than Ovary' then CANCER_TYPE_USE='Female GU excl ovary';
    else if CANCER_TYPE_MILLIMAN='Gastro/Esophageal Cancer' then CANCER_TYPE_USE='Gastro/Esophageal Cancer';
    else if CANCER_TYPE_MILLIMAN='Head and Neck Cancer' then CANCER_TYPE_USE='Head and Neck Cancer';
    else if CANCER_TYPE_MILLIMAN='Intestinal Cancer' then CANCER_TYPE_USE='Colorectal/Intestinal Cancer';
    else if substr(CANCER_TYPE_MILLIMAN,1,5)='Kapos' then CANCER_TYPE_USE='Kaposis Sarcoma';
    else if CANCER_TYPE_MILLIMAN='Kidney Cancer' then CANCER_TYPE_USE='Kidney Cancer';
    else if CANCER_TYPE_MILLIMAN='Leukemia, unspecified' then CANCER_TYPE_USE='Leukemia, UNS';
    else if CANCER_TYPE_MILLIMAN='Liver Cancer' then CANCER_TYPE_USE='Liver Cancer';
    else if CANCER_TYPE_MILLIMAN='Lung Cancer' then CANCER_TYPE_USE='Lung Cancer';
    else if CANCER_TYPE_MILLIMAN='Lymphoid Leukemia, unspecified' then CANCER_TYPE_USE='Lymphoid Leukemia, UNS';
    else if CANCER_TYPE_MILLIMAN='Lymphoma' then CANCER_TYPE_USE='Lymphoma';
    else if CANCER_TYPE_MILLIMAN='Malignant Melanoma' then CANCER_TYPE_USE='Malignant Melanoma';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm NOS' then CANCER_TYPE_USE='MN NOS';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of abdomen' then CANCER_TYPE_USE='MN of abdomen';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of bone and articular cartilage of limbs' then CANCER_TYPE_USE='MN of bone, limbs';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of bone and articular cartilage of sites NOS' then CANCER_TYPE_USE='MN of bone, other sites';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of bone and articular cartilage of other and unspecified sites' then CANCER_TYPE_USE='MN of bone, other sites';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of heart, mediastinum and pleura' then CANCER_TYPE_USE='MN of heart';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of lymphoid, hematopoietic NOS' then CANCER_TYPE_USE='MN lymphoid NOS';
    else if CANCER_TYPE_MILLIMAN='Other and unspecified malignant neoplasms of lymphoid, hematopoietic and related tissue' then CANCER_TYPE_USE='MN lymphoid NOS';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of other and ill-defined digestive organs' then CANCER_TYPE_USE='MN of digest';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of other and unspecified female genital organs' then CANCER_TYPE_USE='MN of female genital';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of other specified ill-defined sites' then CANCER_TYPE_USE='MN of other';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of other and ill-defined sites' then CANCER_TYPE_USE='MN of other';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of penis, other, and unspecific male organs' then CANCER_TYPE_USE='MN of male genital';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of peripheral nerves, autonomic nervous system' then CANCER_TYPE_USE='MN of nervous sys';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of retroperitoneum and peritoneum' then CANCER_TYPE_USE='MN of peritoneum';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of skin, NOS' then CANCER_TYPE_USE='MN of skin NOS';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of testis' then CANCER_TYPE_USE='MN of testis';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of thorax' then CANCER_TYPE_USE='MN of thorax';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of thymus' then CANCER_TYPE_USE='MN of thymus';
    else if CANCER_TYPE_MILLIMAN='MDS' then CANCER_TYPE_USE='MDS';
    else if CANCER_TYPE_MILLIMAN='Merkel cell carcinoma' then CANCER_TYPE_USE='Merkel cell carcinoma';
    else if CANCER_TYPE_MILLIMAN='Multiple Myeloma' then CANCER_TYPE_USE='Multiple Myeloma';
    else if CANCER_TYPE_MILLIMAN='Ovarian Cancer' then CANCER_TYPE_USE='Ovarian Cancer';
    else if CANCER_TYPE_MILLIMAN='Pancreatic Cancer' then CANCER_TYPE_USE='Pancreatic Cancer';
    else if CANCER_TYPE_MILLIMAN='Prostate Cancer' then CANCER_TYPE_USE='Prostate Cancer';
    else if CANCER_TYPE_MILLIMAN='Prostate Cancer - High Intensity' then CANCER_TYPE_USE='Prostate Cancer - High Intensity';
    else if CANCER_TYPE_MILLIMAN='Prostate Cancer - Low Intensity' then CANCER_TYPE_USE='Prostate Cancer - Low Intensity';
    else if CANCER_TYPE_MILLIMAN='Atypical chronic myeloid leukemia, BCR/ABL negative' then CANCER_TYPE_USE='Atypical CML, BCR/ABL neg';
    else if CANCER_TYPE_MILLIMAN='Juvenile myelomonocytic leukemia' then CANCER_TYPE_USE='JMML';
    else if CANCER_TYPE_MILLIMAN='Monocytic Leukemia, unspecified' then CANCER_TYPE_USE='Monocytic Leukemia, UNS';
    else if CANCER_TYPE_MILLIMAN='Myeloid leukemia, unspecified' then CANCER_TYPE_USE='Myeloid Leukemia, UNS';
    else if CANCER_TYPE_MILLIMAN='Other lymphoid leukemia' then CANCER_TYPE_USE='Lymphoid Leukemia, OTH';
    else if CANCER_TYPE_MILLIMAN='Other monocytic leukemia' then CANCER_TYPE_USE='Monocytic Leukemia, OTH';
    else if CANCER_TYPE_MILLIMAN='Other myeloid leukemia' then CANCER_TYPE_USE='Myeloid Leukemia, OTH';
    else if CANCER_TYPE_MILLIMAN='Other specified leukemias' then CANCER_TYPE_USE='Leukemia, OTH';
    else if CANCER_TYPE_MILLIMAN='Other SPECIFIED leukemias' then CANCER_TYPE_USE='Leukemia, OTH';
    else if CANCER_TYPE_MILLIMAN='Small Intestine / Colorectal Cancer' then CANCER_TYPE_USE='Colorectal/Intestinal Cancer';
    else if CANCER_TYPE_MILLIMAN='Secondary malignant neoplasm of lymph nodes' then CANCER_TYPE_USE='SEC and UNS MN lymph';
    else if CANCER_TYPE_MILLIMAN='Secondary malignant neoplasm of other and unspecified sites' then CANCER_TYPE_USE='SEC MN, OTH and UNS';
    else if CANCER_TYPE_MILLIMAN='Secondary malignant neoplasm of respiratory and digestive organs' then CANCER_TYPE_USE='SEC MN, resp and digest';
    else if CANCER_TYPE_MILLIMAN='Secondary malignant neoplasm of resp and digestive organs' then CANCER_TYPE_USE='SEC MN, resp and digest';
    else if CANCER_TYPE_MILLIMAN='Secondary neuroendocrine tumors' then CANCER_TYPE_USE='SEC neuroendocrine tumors';
    else if CANCER_TYPE_MILLIMAN='Myeloid Leukemia, NOS' then CANCER_TYPE_USE='Myeloid Leukemia, NOS';
    else if CANCER_TYPE_MILLIMAN='Secondary malignant neoplasm NOS' then CANCER_TYPE_USE='SEC MN, OTH and UNS';
    else if CANCER_TYPE_MILLIMAN='Melanoma in situ' then CANCER_TYPE_USE='Melanoma in situ';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm of pelvis' then CANCER_TYPE_USE='Malignant neoplasm of pelvis';
    else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of skin' then CANCER_TYPE_USE = 'Carcinoma in situ of skin';
    else if CANCER_TYPE_MILLIMAN='Malignant neoplasm without specification of site' then CANCER_TYPE_USE = 'MN of unknown site';
    else if CANCER_TYPE_MILLIMAN='Other and unspecified malignant neoplasm of skin' then CANCER_TYPE_USE = 'Skin, UNS or OTH';
    else if CANCER_TYPE_MILLIMAN='UNKNOWN' then CANCER_TYPE_USE = 'Unknown';
    else if CANCER_TYPE_MILLIMAN='' then CANCER_TYPE_USE = 'Unknown';
    else if CANCER_TYPE_MILLIMAN='C91.z' then CANCER_TYPE_USE = 'Lymphoid Leukemia, OTH';
    else if CANCER_TYPE_MILLIMAN='C92.2' then CANCER_TYPE_USE = 'Atypical CML, BCR/ABL neg';
    else if CANCER_TYPE_MILLIMAN='D00' then CANCER_TYPE_USE = 'CIS of oral, esophagus, stomach';
    else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of oral cavity, esophagus, stomach' then CANCER_TYPE_USE = 'CIS of oral, esophagus, stomach';
    else if CANCER_TYPE_MILLIMAN='Carcinoma in situ of oral cavity, espophagus, stomach' then CANCER_TYPE_USE = 'CIS of oral, esophagus, stomach';
    else if CANCER_TYPE_MILLIMAN='C93.9' then CANCER_TYPE_USE = 'Monocytic Leukemia, UNS';
    else if CANCER_TYPE_MILLIMAN='Monocytic Leukemia, NOS' then CANCER_TYPE_USE = 'Monocytic Leukemia, UNS';
    else if CANCER_TYPE_MILLIMAN='D05' then CANCER_TYPE_USE='CIS of breast';
    else if CANCER_TYPE_MILLIMAN='C44' then CANCER_TYPE_USE = 'Skin, UNS or OTH';
    else if CANCER_TYPE_MILLIMAN='C80' then CANCER_TYPE_USE = 'MN of unknown site';
    else if CANCER_TYPE_MILLIMAN='C48' then CANCER_TYPE_USE='MN of peritoneum';
    else if CANCER_TYPE_MILLIMAN='C57' then CANCER_TYPE_USE='MN of female genital';
    else if CANCER_TYPE_MILLIMAN='C4A' then CANCER_TYPE_USE='Merkel cell carcinoma';
    else if CANCER_TYPE_MILLIMAN='C92.9' then CANCER_TYPE_USE='Myeloid Leukemia, UNS';
    else if CANCER_TYPE_MILLIMAN='C49' then CANCER_TYPE_USE='MN of other connective, soft tissue';

    else if CANCER_TYPE_MILLIMAN='Polycythemia vera' then CANCER_TYPE_USE='Polycythemia Vera';
    else if CANCER_TYPE_MILLIMAN='Chronic myeloproliferative disease' then CANCER_TYPE_USE='Chronic Myeloproliferative Disease';
    else if CANCER_TYPE_MILLIMAN='Essential (hemorrhagic) thrombocythemia' then CANCER_TYPE_USE='Essential Thrombocythemia';
    else if CANCER_TYPE_MILLIMAN='Essential thrombocythemia' then CANCER_TYPE_USE='Essential Thrombocythemia';
    else if CANCER_TYPE_MILLIMAN='Osteomyelofibrosis' then CANCER_TYPE_USE='Osteomyelofibrosis';
    else if CANCER_TYPE_MILLIMAN='Myelofibrosis' then CANCER_TYPE_USE='Myelofibrosis';
    else if CANCER_TYPE_MILLIMAN='Juvenile myelomonocytic leukemia' then CANCER_TYPE_USE='JUV Myelomonocytic Leukemia';
    else if CANCER_TYPE_MILLIMAN='CAR-T' then CANCER_TYPE_USE='CAR-T';

    if EPISODE_PERIOD = 'BAS' then do;
                    ***Make CMS_CANCER_TYPE_USE***;
        if CANCER_TYPE = '' then CMS_CANCER_TYPE_USE = 'Unknown';
        else if CANCER_TYPE='MEOS, no PBP' then CMS_CANCER_TYPE_USE = 'MEOS, no PBP';
        else if CANCER_TYPE='Acute Leukemia' then CMS_CANCER_TYPE_USE='Acute Leukemia';
        else if CANCER_TYPE='Anal Cancer' then CMS_CANCER_TYPE_USE='Anal Cancer';
        else if CANCER_TYPE='Bladder Cancer' then CMS_CANCER_TYPE_USE='Bladder Cancer';
        else if CANCER_TYPE='Bladder Cancer - Low Risk' then CMS_CANCER_TYPE_USE='Bladder Cancer - Low Risk';
        else if CANCER_TYPE='Bladder Cancer - High Risk' then CMS_CANCER_TYPE_USE='Bladder Cancer - High Risk';
        else if CANCER_TYPE='Breast Cancer' then CMS_CANCER_TYPE_USE='Breast Cancer';
        else if CANCER_TYPE='Breast Cancer - Low Risk' then CMS_CANCER_TYPE_USE='Breast Cancer - Low Risk';
        else if CANCER_TYPE='Breast Cancer - High Risk' then CMS_CANCER_TYPE_USE='Breast Cancer - High Risk';
        else if CANCER_TYPE='Carcinoma in situ of breast' then CMS_CANCER_TYPE_USE='CIS of breast';
        else if CANCER_TYPE='Carcinoma in situ of middle ear and respiratory system' then CMS_CANCER_TYPE_USE='CIS of ear and resp';
        else if CANCER_TYPE='Carcinoma in situ of other and NOS genital organs' then CMS_CANCER_TYPE_USE='CIS of other genital';
        else if CANCER_TYPE='Carcinoma in situ of other and NOS digestive organs' then CMS_CANCER_TYPE_USE='CIS of other digestive';
        else if CANCER_TYPE='Carcinoma in situ of other and unspecified sites' then CMS_CANCER_TYPE_USE='CIS of other, UNS';
        else if CANCER_TYPE='Carcinoma in situ of other and NOS sites' then CMS_CANCER_TYPE_USE='CIS of other, UNS';
        else if CANCER_TYPE='Chronic Leukemia' then CMS_CANCER_TYPE_USE='Chronic Leukemia';
        else if CANCER_TYPE='Carcinoma in situ of cervix uteri' then CMS_CANCER_TYPE_USE='CIS of uterine cervix';
        else if CANCER_TYPE='Chronic leukemia of unspecified cell type' then CMS_CANCER_TYPE_USE='Chronic Leukemia, UNS';
        else if CANCER_TYPE='Chronic myelomonocytic leukemia' then CMS_CANCER_TYPE_USE='CMML';
        else if CANCER_TYPE='CNS Tumor' then CMS_CANCER_TYPE_USE='CNS Tumor';
        else if CANCER_TYPE='Endocrine Tumor' then CMS_CANCER_TYPE_USE='Endocrine Tumor';
        else if CANCER_TYPE='Female GU Cancer other than Ovary' then CMS_CANCER_TYPE_USE='Female GU excl ovary';
        else if CANCER_TYPE='Gastro/Esophageal Cancer' then CMS_CANCER_TYPE_USE='Gastro/Esophageal Cancer';
        else if CANCER_TYPE='Head and Neck Cancer' then CMS_CANCER_TYPE_USE='Head and Neck Cancer';
        else if CANCER_TYPE='Intestinal Cancer' then CMS_CANCER_TYPE_USE='Colorectal/Intestinal Cancer';
        else if substr(CANCER_TYPE,1,5)='Kapos' then CMS_CANCER_TYPE_USE='Kaposis Sarcoma';
        else if CANCER_TYPE='Kidney Cancer' then CMS_CANCER_TYPE_USE='Kidney Cancer';
        else if CANCER_TYPE='Leukemia, unspecified' then CMS_CANCER_TYPE_USE='Leukemia, UNS';
        else if CANCER_TYPE='Liver Cancer' then CMS_CANCER_TYPE_USE='Liver Cancer';
        else if CANCER_TYPE='Lung Cancer' then CMS_CANCER_TYPE_USE='Lung Cancer';
        else if CANCER_TYPE='Lymphoid Leukemia, unspecified' then CMS_CANCER_TYPE_USE='Lymphoid Leukemia, UNS';
        else if CANCER_TYPE='Lymphoma' then CMS_CANCER_TYPE_USE='Lymphoma';
        else if CANCER_TYPE='Malignant Melanoma' then CMS_CANCER_TYPE_USE='Malignant Melanoma';
        else if CANCER_TYPE='Malignant neoplasm NOS' then CMS_CANCER_TYPE_USE='MN NOS';
        else if CANCER_TYPE='Malignant neoplasm of abdomen' then CMS_CANCER_TYPE_USE='MN of abdomen';
        else if CANCER_TYPE='Malignant neoplasm of bone and articular cartilage of limbs' then CMS_CANCER_TYPE_USE='MN of bone, limbs';
        else if CANCER_TYPE='Malignant neoplasm of bone and articular cartilage of sites NOS' then CMS_CANCER_TYPE_USE='MN of bone, other sites';
        else if CANCER_TYPE='Malignant neoplasm of bone and articular cartilage of other and unspecified sites' then CMS_CANCER_TYPE_USE='MN of bone, other sites';
        else if CANCER_TYPE='Malignant neoplasm of heart, mediastinum and pleura' then CMS_CANCER_TYPE_USE='MN of heart';
        else if CANCER_TYPE='Malignant neoplasm of lymphoid, hematopoietic NOS' then CMS_CANCER_TYPE_USE='MN lymphoid NOS';
        else if CANCER_TYPE='Other and unspecified malignant neoplasms of lymphoid, hematopoietic and related tissue' then CMS_CANCER_TYPE_USE='MN lymphoid NOS';
        else if CANCER_TYPE='Malignant neoplasm of other and ill-defined digestive organs' then CMS_CANCER_TYPE_USE='MN of digest';
        else if CANCER_TYPE='Malignant neoplasm of other and unspecified female genital organs' then CMS_CANCER_TYPE_USE='MN of female genital';
        else if CANCER_TYPE='Malignant neoplasm of other specified ill-defined sites' then CMS_CANCER_TYPE_USE='MN of other';
        else if CANCER_TYPE='Malignant neoplasm of other and ill-defined sites' then CMS_CANCER_TYPE_USE='MN of other';
        else if CANCER_TYPE='Malignant neoplasm of penis, other, and unspecific male organs' then CMS_CANCER_TYPE_USE='MN of male genital';
        else if CANCER_TYPE='Malignant neoplasm of peripheral nerves, autonomic nervous system' then CMS_CANCER_TYPE_USE='MN of nervous sys';
        else if CANCER_TYPE='Malignant neoplasm of retroperitoneum and peritoneum' then CMS_CANCER_TYPE_USE='MN of peritoneum';
        else if CANCER_TYPE='Malignant neoplasm of skin, NOS' then CMS_CANCER_TYPE_USE='MN of skin NOS';
        else if CANCER_TYPE='Malignant neoplasm of testis' then CMS_CANCER_TYPE_USE='MN of testis';
        else if CANCER_TYPE='Malignant neoplasm of thorax' then CMS_CANCER_TYPE_USE='MN of thorax';
        else if CANCER_TYPE='Malignant neoplasm of thymus' then CMS_CANCER_TYPE_USE='MN of thymus';
        else if CANCER_TYPE='MDS' then CMS_CANCER_TYPE_USE='MDS';
        else if CANCER_TYPE='Merkel cell carcinoma' then CMS_CANCER_TYPE_USE='Merkel cell carcinoma';
        else if CANCER_TYPE='Multiple Myeloma' then CMS_CANCER_TYPE_USE='Multiple Myeloma';
        else if CANCER_TYPE='Ovarian Cancer' then CMS_CANCER_TYPE_USE='Ovarian Cancer';
        else if CANCER_TYPE='Pancreatic Cancer' then CMS_CANCER_TYPE_USE='Pancreatic Cancer';
        else if CANCER_TYPE='Prostate Cancer' then CMS_CANCER_TYPE_USE='Prostate Cancer';
        else if CANCER_TYPE='Prostate Cancer - High Intensity' then CMS_CANCER_TYPE_USE='Prostate Cancer - High Intensity';
        else if CANCER_TYPE='Prostate Cancer - Low Intensity' then CMS_CANCER_TYPE_USE='Prostate Cancer - Low Intensity';
        else if CANCER_TYPE='Atypical chronic myeloid leukemia, BCR/ABL negative' then CMS_CANCER_TYPE_USE='Atypical CML, BCR/ABL neg';
        else if CANCER_TYPE='Juvenile myelomonocytic leukemia' then CMS_CANCER_TYPE_USE='JMML';
        else if CANCER_TYPE='Monocytic Leukemia, unspecified' then CMS_CANCER_TYPE_USE='Monocytic Leukemia, UNS';
        else if CANCER_TYPE='Myeloid leukemia, unspecified' then CMS_CANCER_TYPE_USE='Myeloid Leukemia, UNS';
        else if CANCER_TYPE='Other lymphoid leukemia' then CMS_CANCER_TYPE_USE='Lymphoid Leukemia, OTH';
        else if CANCER_TYPE='Other monocytic leukemia' then CMS_CANCER_TYPE_USE='Monocytic Leukemia, OTH';
        else if CANCER_TYPE='Other myeloid leukemia' then CMS_CANCER_TYPE_USE='Myeloid Leukemia, OTH';
        else if CANCER_TYPE='Other specified leukemias' then CMS_CANCER_TYPE_USE='Leukemia, OTH';
        else if CANCER_TYPE='Other SPECIFIED leukemias' then CMS_CANCER_TYPE_USE='Leukemia, OTH';
        else if CANCER_TYPE='Small Intestine / Colorectal Cancer' then CMS_CANCER_TYPE_USE='Colorectal/Intestinal Cancer'; /*HM updated - 4/24/2017*/
        else if CANCER_TYPE='Secondary malignant neoplasm of lymph nodes' then CMS_CANCER_TYPE_USE='SEC and UNS MN lymph';
        else if CANCER_TYPE='Secondary malignant neoplasm of other and unspecified sites' then CMS_CANCER_TYPE_USE='SEC MN, OTH and UNS';
        else if CANCER_TYPE='Secondary malignant neoplasm of respiratory and digestive organs' then CMS_CANCER_TYPE_USE='SEC MN, resp and digest';
        else if CANCER_TYPE='Secondary malignant neoplasm of resp and digestive organs' then CMS_CANCER_TYPE_USE='SEC MN, resp and digest';
        else if CANCER_TYPE='Secondary neuroendocrine tumors' then CMS_CANCER_TYPE_USE='SEC neuroendocrine tumors';
        else if CANCER_TYPE='Myeloid Leukemia, NOS' then CMS_CANCER_TYPE_USE='Myeloid Leukemia, NOS';
        else if CANCER_TYPE='Secondary malignant neoplasm NOS' then CMS_CANCER_TYPE_USE='SEC MN, OTH and UNS';
        else if CANCER_TYPE='Melanoma in situ' then CMS_CANCER_TYPE_USE='Melanoma in situ';
        else if CANCER_TYPE='Malignant neoplasm of pelvis' then CMS_CANCER_TYPE_USE='Malignant neoplasm of pelvis';
        else if CANCER_TYPE='Carcinoma in situ of skin' then CMS_CANCER_TYPE_USE = 'Carcinoma in situ of skin';
        else if CANCER_TYPE='Malignant neoplasm without specification of site' then CMS_CANCER_TYPE_USE = 'MN of unknown site';
        else if CANCER_TYPE='Other and unspecified malignant neoplasm of skin' then CMS_CANCER_TYPE_USE = 'Skin, UNS or OTH';
        else if CANCER_TYPE='UNKNOWN' then CMS_CANCER_TYPE_USE = 'Unknown';
        else if CANCER_TYPE='' then CMS_CANCER_TYPE_USE = 'Unknown';
        else if CANCER_TYPE='C91.z' then CMS_CANCER_TYPE_USE = 'Lymphoid Leukemia, OTH';
        else if CANCER_TYPE='C92.2' then CMS_CANCER_TYPE_USE = 'Atypical CML, BCR/ABL neg';
        else if CANCER_TYPE='D00' then CMS_CANCER_TYPE_USE = 'CIS of oral, esophagus, stomach';
        else if CANCER_TYPE='Carcinoma in situ of oral cavity, esophagus, stomach' then CMS_CANCER_TYPE_USE = 'CIS of oral, esophagus, stomach';
        else if CANCER_TYPE='Carcinoma in situ of oral cavity, espophagus, stomach' then CMS_CANCER_TYPE_USE = 'CIS of oral, esophagus, stomach';
        else if CANCER_TYPE='C93.9' then CMS_CANCER_TYPE_USE = 'Monocytic Leukemia, UNS';
        else if CANCER_TYPE='Monocytic Leukemia, NOS' then CMS_CANCER_TYPE_USE = 'Monocytic Leukemia, UNS';
        else if CANCER_TYPE='D05' then CMS_CANCER_TYPE_USE='CIS of breast';
        else if CANCER_TYPE='C44' then CMS_CANCER_TYPE_USE = 'Skin, UNS or OTH';
        else if CANCER_TYPE='C80' then CMS_CANCER_TYPE_USE = 'MN of unknown site';
        else if CANCER_TYPE='C48' then CMS_CANCER_TYPE_USE='MN of peritoneum';
        else if CANCER_TYPE='C57' then CMS_CANCER_TYPE_USE='MN of female genital';
        else if CANCER_TYPE='C4A' then CMS_CANCER_TYPE_USE='Merkel cell carcinoma';
        else if CANCER_TYPE='C92.9' then CMS_CANCER_TYPE_USE='Myeloid Leukemia, UNS';
        else if CANCER_TYPE='Polycythemia vera' then CMS_CANCER_TYPE_USE='Polycythemia Vera';
        else if CANCER_TYPE='Chronic myeloproliferative disease' then CMS_CANCER_TYPE_USE='Chronic Myeloproliferative Disease';
        else if CANCER_TYPE='Essential (hemorrhagic) thrombocythemia' then CMS_CANCER_TYPE_USE='Essential Thrombocythemia';
        else if CANCER_TYPE='Essential thrombocythemia' then CMS_CANCER_TYPE_USE='Essential Thrombocythemia';
        else if CANCER_TYPE='Osteomyelofibrosis' then CMS_CANCER_TYPE_USE='Osteomyelofibrosis';
        else if CANCER_TYPE='Myelofibrosis' then CMS_CANCER_TYPE_USE='Myelofibrosis';
        else if CANCER_TYPE='Juvenile myelomonocytic leukemia' then CMS_CANCER_TYPE_USE='JUV Myelomonocytic Leukemia';
        else if CANCER_TYPE='C49' then CMS_CANCER_TYPE_USE='MN of other connective, soft tissue';
        else if CANCER_TYPE='CAR-T' then CMS_CANCER_TYPE_USE='CAR-T';

    end;

    if EPISODE_PERIOD = 'BAS' then NEW_CANCER_TYPE_USE = CMS_CANCER_TYPE_USE;
        else NEW_CANCER_TYPE_USE = CANCER_TYPE_USE;

    ** Cancer Types for report with abbreviations **;
    if NEW_CANCER_TYPE_USE = 'Breast Cancer' then CANCER_TYPE_ABBREV = 'BCa = Breast Cancer';
    else if NEW_CANCER_TYPE_USE = 'Breast Cancer - Low Risk' then CANCER_TYPE_ABBREV = 'BCaL = Breast Cancer - Low Risk';
    else if NEW_CANCER_TYPE_USE = 'Breast Cancer - High Risk' then CANCER_TYPE_ABBREV = 'BCaH = Breast Cancer - High Risk';
    else if NEW_CANCER_TYPE_USE = 'Prostate Cancer' then CANCER_TYPE_ABBREV = 'PCa = Prostate Cancer';
    else if NEW_CANCER_TYPE_USE = 'Lung Cancer' then CANCER_TYPE_ABBREV = 'LUNG = Lung Cancer';
    else if NEW_CANCER_TYPE_USE = 'Multiple Myeloma' then CANCER_TYPE_ABBREV = 'MM = Multiple Myeloma';
    else if NEW_CANCER_TYPE_USE = 'Lymphoma' then CANCER_TYPE_ABBREV = 'LYMP = Lymphoma';
    else if NEW_CANCER_TYPE_USE = 'Colorectal/Intestinal Cancer' then CANCER_TYPE_ABBREV = 'CRCI = Colorectal/Intestinal Cancer';
    else if NEW_CANCER_TYPE_USE = 'Chronic Leukemia' then CANCER_TYPE_ABBREV = 'CL = Chronic Leukemia';
    else if NEW_CANCER_TYPE_USE = 'Pancreatic Cancer' then CANCER_TYPE_ABBREV = 'PANC = Pancreatic Cancer';
    else if NEW_CANCER_TYPE_USE = 'Ovarian Cancer' then CANCER_TYPE_ABBREV = 'OVAR = Ovarian Cancer';
    else if NEW_CANCER_TYPE_USE = 'Bladder Cancer' then CANCER_TYPE_ABBREV = 'BLC = Bladder Cancer';
    else if NEW_CANCER_TYPE_USE = 'Gastro/Esophageal Cancer' then CANCER_TYPE_ABBREV = 'GEC = Gastro/Esophageal Cancer';
    else if NEW_CANCER_TYPE_USE = 'MDS' then CANCER_TYPE_ABBREV = 'MDS = MDS';
    else if NEW_CANCER_TYPE_USE = 'Female GU excl ovary' then CANCER_TYPE_ABBREV = 'FGU = Female GU excl ovary';
    else if NEW_CANCER_TYPE_USE = 'Head and Neck Cancer' then CANCER_TYPE_ABBREV = 'HN = Head and Neck Cancer';
    else if NEW_CANCER_TYPE_USE = 'Malignant Melanoma' then CANCER_TYPE_ABBREV = 'MMEL = Malignant Melanoma';
    else if NEW_CANCER_TYPE_USE = 'Liver Cancer' then CANCER_TYPE_ABBREV = 'LIV = Liver Cancer';
    else if NEW_CANCER_TYPE_USE = 'Acute Leukemia' then CANCER_TYPE_ABBREV = 'AL = Acute Leukemia';
    else if NEW_CANCER_TYPE_USE = 'Kidney Cancer' then CANCER_TYPE_ABBREV = 'KIDN = Kidney Cancer';
    else if NEW_CANCER_TYPE_USE = 'Endocrine Tumor' then CANCER_TYPE_ABBREV = 'ENDO = Endocrine Tumor';
    else if NEW_CANCER_TYPE_USE = 'CNS Tumor' then CANCER_TYPE_ABBREV = 'CNS = CNS Tumor';
    else if NEW_CANCER_TYPE_USE = 'Prostate Cancer - High Intensity' then CANCER_TYPE_ABBREV = 'PCaH = Prostate Cancer - High Intensity';
    else if NEW_CANCER_TYPE_USE = 'Prostate Cancer - Low Intensity' then CANCER_TYPE_ABBREV = 'PCaL = Prostate Cancer - Low Intensity';
    else if NEW_CANCER_TYPE_USE = 'Anal Cancer' then CANCER_TYPE_ABBREV = 'ANAL = Anal Cancer';
    else if NEW_CANCER_TYPE_USE = 'Bladder Cancer - High Risk' then CANCER_TYPE_ABBREV = 'BLCH = Bladder Cancer - High Risk';
    else if NEW_CANCER_TYPE_USE = 'Bladder Cancer - Low Risk' then CANCER_TYPE_ABBREV = 'BLCL = Bladder Cancer - Low Risk';
    else if NEW_CANCER_TYPE_USE = 'Atypical CML, BCR/ABL neg' then CANCER_TYPE_ABBREV = 'ACML = Atypical CML, BCR/ABL neg';
    else if NEW_CANCER_TYPE_USE = 'Carcinoma in situ of skin' then CANCER_TYPE_ABBREV = 'CISS = Carcinoma in situ of skin';
    else if NEW_CANCER_TYPE_USE = 'Chronic Leukemia, UNS' then CANCER_TYPE_ABBREV = 'CLU = Chronic Leukemia, UNS';
    else if NEW_CANCER_TYPE_USE = 'Chronic Myeloproliferative Disease' then CANCER_TYPE_ABBREV = 'CMD = Chronic Myeloproliferative Disease';
    else if NEW_CANCER_TYPE_USE = 'CIS of breast' then CANCER_TYPE_ABBREV = 'CISB = CIS of breast';
    else if NEW_CANCER_TYPE_USE = 'CIS of ear and resp' then CANCER_TYPE_ABBREV = 'CISE = CIS of ear and resp';
    else if NEW_CANCER_TYPE_USE = 'CIS of oral, esophagus, stomach' then CANCER_TYPE_ABBREV = 'CISO = CIS of oral, esophagus, stomach';
    else if NEW_CANCER_TYPE_USE = 'CIS of other genital' then CANCER_TYPE_ABBREV = 'CISG = CIS of other genital';
    else if NEW_CANCER_TYPE_USE = 'CIS of other digestive' then CANCER_TYPE_ABBREV = 'CISD = CIS of other digestive';
    else if NEW_CANCER_TYPE_USE = 'CIS of other, UNS' then CANCER_TYPE_ABBREV = 'CISU = CIS of other, UNS';
    else if NEW_CANCER_TYPE_USE = 'CIS of uterine cervix' then CANCER_TYPE_ABBREV = 'CISC = CIS of uterine cervix';
    else if NEW_CANCER_TYPE_USE = 'CMML' then CANCER_TYPE_ABBREV = 'CMML = CMML';
    else if NEW_CANCER_TYPE_USE = 'Essential Thrombocythemia' then CANCER_TYPE_ABBREV = 'ET = Essential Thrombocythemia';
    else if NEW_CANCER_TYPE_USE = 'Kaposis Sarcoma' then CANCER_TYPE_ABBREV = 'KS = Kaposis Sarcoma';
    else if NEW_CANCER_TYPE_USE = 'Leukemia, UNS' then CANCER_TYPE_ABBREV = 'LU = Leukemia, UNS';
    else if NEW_CANCER_TYPE_USE = 'Lymphoid Leukemia, OTH' then CANCER_TYPE_ABBREV = 'LLO = Lymphoid Leukemia, OTH';
    else if NEW_CANCER_TYPE_USE = 'Lymphoid Leukemia, UNS' then CANCER_TYPE_ABBREV = 'LLU = Lymphoid Leukemia, UNS';
    else if NEW_CANCER_TYPE_USE = 'Melanoma in situ' then CANCER_TYPE_ABBREV = 'MIS = Melanoma in situ';
    else if NEW_CANCER_TYPE_USE = 'Merkel cell carcinoma' then CANCER_TYPE_ABBREV = 'MCC = Merkel cell carcinoma';
    else if NEW_CANCER_TYPE_USE = 'MN lymphoid NOS' then CANCER_TYPE_ABBREV = 'MNLN = MN lymphoid NOS';
    else if NEW_CANCER_TYPE_USE = 'MN NOS' then CANCER_TYPE_ABBREV = 'MNN = MN NOS';
    else if NEW_CANCER_TYPE_USE = 'MN of abdomen' then CANCER_TYPE_ABBREV = 'MNA = MN of abdomen';
    else if NEW_CANCER_TYPE_USE = 'MN of bone, limbs' then CANCER_TYPE_ABBREV = 'MNBL = MN of bone, limbs';
    else if NEW_CANCER_TYPE_USE = 'MN of bone, other sites' then CANCER_TYPE_ABBREV = 'MNBO = MN of bone, other sites';
    else if NEW_CANCER_TYPE_USE = 'MN of digest' then CANCER_TYPE_ABBREV = 'MND = MN of digest';
    else if NEW_CANCER_TYPE_USE = 'MN of female genital' then CANCER_TYPE_ABBREV = 'MNFG = MN of female genital';
    else if NEW_CANCER_TYPE_USE = 'MN of heart' then CANCER_TYPE_ABBREV = 'MNH = MN of heart';
    else if NEW_CANCER_TYPE_USE = 'MN of male genital' then CANCER_TYPE_ABBREV = 'MNMG = MN of male genital';
    else if NEW_CANCER_TYPE_USE = 'MN of nervous sys' then CANCER_TYPE_ABBREV = 'MNNS = MN of nervous sys';
    else if NEW_CANCER_TYPE_USE = 'MN of other' then CANCER_TYPE_ABBREV = 'MNO = MN of other';
    else if NEW_CANCER_TYPE_USE = 'MN of peritoneum' then CANCER_TYPE_ABBREV = 'MNP = MN of peritoneum';
    else if NEW_CANCER_TYPE_USE = 'MN of skin NOS' then CANCER_TYPE_ABBREV = 'MNSN = MN of skin NOS';
    else if NEW_CANCER_TYPE_USE = 'MN of testis' then CANCER_TYPE_ABBREV = 'MNT = MN of testis';
    else if NEW_CANCER_TYPE_USE = 'MN of thorax' then CANCER_TYPE_ABBREV = 'MNTX = MN of thorax';
    else if NEW_CANCER_TYPE_USE = 'MN of thymus' then CANCER_TYPE_ABBREV = 'MNTY = MN of thymus';
    else if NEW_CANCER_TYPE_USE = 'Monocytic Leukemia, UNS' then CANCER_TYPE_ABBREV = 'MLU = Monocytic Leukemia, UNS';
    else if NEW_CANCER_TYPE_USE = 'Myelofibrosis' then CANCER_TYPE_ABBREV = 'MF = Myelofibrosis';
    else if NEW_CANCER_TYPE_USE = 'Myeloid Leukemia, NOS' then CANCER_TYPE_ABBREV = 'MLN = Myeloid Leukemia, NOS';
    else if NEW_CANCER_TYPE_USE = 'Myeloid Leukemia, OTH' then CANCER_TYPE_ABBREV = 'MLO = Myeloid Leukemia, OTH';
    else if NEW_CANCER_TYPE_USE = 'Osteomyelofibrosis' then CANCER_TYPE_ABBREV = 'OMF = Osteomyelofibrosis';
    else if NEW_CANCER_TYPE_USE = 'Polycythemia Vera' then CANCER_TYPE_ABBREV = 'PV = Polycythemia Vera';
    else if NEW_CANCER_TYPE_USE = 'SEC and UNS MN lymph' then CANCER_TYPE_ABBREV = 'SECL = SEC and UNS MN lymph';
    else if NEW_CANCER_TYPE_USE = 'SEC MN, OTH and UNS' then CANCER_TYPE_ABBREV = 'SECO = SEC MN, OTH and UNS';
    else if NEW_CANCER_TYPE_USE = 'SEC MN, resp and digest' then CANCER_TYPE_ABBREV = 'SECR = SEC MN, resp and digest';
    else if NEW_CANCER_TYPE_USE = 'SEC neuroendocrine tumors' then CANCER_TYPE_ABBREV = 'SECN = SEC neuroendocrine tumors';
    else if NEW_CANCER_TYPE_USE = 'Skin, UNS or OTH' then CANCER_TYPE_ABBREV = 'SKUO = Skin, UNS or OTH';
    else if NEW_CANCER_TYPE_USE = 'MN of other connective, soft tissue' then CANCER_TYPE_ABBREV='MNOT = MN of other connective, soft tissue';


    if EPISODE_PERIOD = 'BAS' or recon_episode = 1 then do;
        if inst = '1' then INST_USE = 'Yes';
            else INST_USE = 'No';
    end;

    if EPISODE_PERIOD = 'BAS' or recon_episode = 1 then do;
        if radiation = '1' then RADIATION_USE = 'Yes';
            else RADIATION_USE = 'No';
    end;
    else do;
        if radiation_milliman = 1 then RADIATION_USE = 'Yes';
            else RADIATION_USE = 'No';
    end;

    if EPISODE_PERIOD = 'BAS' or recon_episode = 1 then do;
        if clinical_trial = '1' then CLINICAL_TRIAL_USE = 'Yes';
            else CLINICAL_TRIAL_USE = 'No';
    end;
    else do;
        IF CLINICAL_TRIAL_MILLIMAN = 1 then CLINICAL_TRIAL_USE = 'Yes';
            else CLINICAL_TRIAL_USE = 'No';
    end;

    if EPISODE_PERIOD = 'BAS' or recon_episode = 1 then do;
        if DUAL_PTD_LIS = '0' then DUAL_PTD_LIS_USE = 'No Part D';
            else if DUAL_PTD_LIS = '1' then DUAL_PTD_LIS_USE = 'Part D, no LIS';
            else if DUAL_PTD_LIS = '2' then DUAL_PTD_LIS_USE = 'Part D, not full dual, LIS';
            else if DUAL_PTD_LIS = '3' then DUAL_PTD_LIS_USE = 'Part D, full dual, LIS';
            else if substr(EP_ID,1,3)='XXX' then DUAL_PTD_LIS_USE = 'N/A';
    end;
    else do;
        if DUAL = 1 then DUAL_PTD_LIS_USE = 'Dual';
            else if DUAL = 0 then DUAL_PTD_LIS_USE = 'Non-Dual';
			else DUAL_PTD_LIS_USE = 'Unknown';
    end;

    if HCC_GRP = '00' then HCC_GRP_USE = 'None';
        else if HCC_GRP = '01' then HCC_GRP_USE = '1';
        else if HCC_GRP = '02' then HCC_GRP_USE = '2';
        else if HCC_GRP = '03' then HCC_GRP_USE = '3';
        else if HCC_GRP = '4-5' then HCC_GRP_USE = '4 or 5';
        else if HCC_GRP = '98' then HCC_GRP_USE = 'New';
        else if HCC_GRP = '6+' then HCC_GRP_USE = '6+';
        else HCC_GRP_USE = 'N/A';

    if BMT_MILLIMAN = 0 then BMT_USE = 'No';
        else if BMT_MILLIMAN = 1 then BMT_USE = 'Autologous';
        else if BMT_MILLIMAN = 2 then BMT_USE = 'Allogeneic';
        else if BMT_MILLIMAN = 3 then BMT_USE = 'Both';
        else BMT_USE = 'Not Applicable';

    if CLEAN_PD = '1' then CLEAN_PERIOD_USE = '0 - 61 Days';
        else if CLEAN_PD = '2' then CLEAN_PERIOD_USE = '62 - 730 Days';
        else if CLEAN_PD = '3' then CLEAN_PERIOD_USE = 'More than 730 Days';
        else CLEAN_PERIOD_USE = 'N/A';

    if EPISODE_PERIOD = 'BAS' then do;
        if PTD_CHEMO = '0' then PTD_CHEMO_USE = 'Some Part B';
            else if PTD_CHEMO = '1' then PTD_CHEMO_USE = 'Part D Only';
            else PTD_CHEMO_USE = 'Not Applicable';
    end;
    else do;
        if cancer_type = 'Breast Cancer' then do;
            if CHEMO_B_UTIL = 1 then PTD_CHEMO_USE = 'Some Part B';
            else if CHEMO_D_UTIL = 1 and CHEMO_B_UTIL = 0  then PTD_CHEMO_USE = 'Part D Only';
            else PTD_CHEMO_USE = 'Unknown';
        end;
    end;

    if recon_episode = 1 or EPISODE_PERIOD = 'BAS' then do;
        if RECON_ELIG= '1' then RECON_ELIG_USE='Yes';
            else RECON_ELIG_USE='No';
    end;
    else do;
        if recon_elig_milliman= '1' then RECON_ELIG_USE='Yes';
            else RECON_ELIG_USE='No';
    end;

    if recon_elig_use='Yes' then CANCER_TYPE_QUALITY=NEW_CANCER_TYPE_USE;
        else CANCER_TYPE_QUALITY='All Other Cancers';

    if recon_episode = 1 then do;
        if SURGERY = 1 then SURGERY_USE = 'Yes';
            else SURGERY_USE = 'No';
    end;


    else do;
        if SURGERY_MILLIMAN = 1 then SURGERY_USE = 'Yes';
            else SURGERY_USE = 'No';
    end;

    if EPISODE_PERIOD = 'BAS' then ATTRIB_FLAG_USE = 'Baseline';
        else if ATTRIBUTE_FLAG=0 then ATTRIB_FLAG_USE='Not Attributed Episode';
        else if ATTRIBUTE_FLAG=1 then ATTRIB_FLAG_USE='Attributed Episode';
        else if ATTRIBUTE_FLAG=2 then ATTRIB_FLAG_USE='Attributed Episode';
        else if ATTRIBUTE_FLAG=3 then ATTRIB_FLAG_USE='Attributed Episode';
        else if ATTRIBUTE_FLAG=4 then ATTRIB_FLAG_USE='Potentially Attributed Episode';
        else if ATTRIBUTE_FLAG=5 then ATTRIB_FLAG_USE='Attributed Episode';
        else if EP_ID = '' and ATTRIBUTE_FLAG=. then ATTRIB_FLAG_USE='Not an Episode';
        else if ATTRIBUTE_FLAG='D' then ATTRIB_FLAG_USE='Dropped Episode';
        else ATTRIB_FLAG_USE='N/A';

    if EPISODE_PERIOD = 'BAS' then ATTRIB_FLAG_ABBREV = 'Baseline';
        else if ATTRIBUTE_FLAG=0 then ATTRIB_FLAG_ABBREV='No';
        else if ATTRIBUTE_FLAG=1 then ATTRIB_FLAG_ABBREV='Yes';
        else if ATTRIBUTE_FLAG=2 then ATTRIB_FLAG_ABBREV='Yes';
        else if ATTRIBUTE_FLAG=3 then ATTRIB_FLAG_ABBREV='Yes';
        else if ATTRIBUTE_FLAG=4 then ATTRIB_FLAG_ABBREV='Potentially';
        else if ATTRIBUTE_FLAG=5 then ATTRIB_FLAG_ABBREV='Yes';
		else if EP_ID = '' and ATTRIBUTE_FLAG=. then ATTRIB_FLAG_ABBREV='N/A';
        else if ATTRIBUTE_FLAG='D' then ATTRIB_FLAG_ABBREV='Dropped';
        else ATTRIB_FLAG_ABBREV='N/A';

    if MEOS_episode = 1 then do;
        if emerge_episode = 1 then EPISODE_TYPE = 'Yes - Emerging';
            else if main_episode = 1 then EPISODE_TYPE = 'Yes - Main Interface';
            else EPISODE_TYPE = 'No';

        MEOS_ALLOWED_TOTAL = SUM(MEOS_ALLOWED, MEOS_ALLOWED_OTH);
    end;

    if RECON_PP = 1 or RECON_PP = 2 then do;
        if IN_RECON = 1 then TRUE_UP_MATCH = 'Complete Match';
                else if IN_RECON = 2 then TRUE_UP_MATCH = 'New to True-up';
                else if IN_RECON = 3 then TRUE_UP_MATCH = 'Change in Start Date or Cancer Type';
                else if IN_RECON = 4 then TRUE_UP_MATCH = 'Dropped Episode';

        if ATT_CANC_MATCH_CMS = 2 then ATT_CANC_CHANGE_CMS = 'N/A';
            else if ATT_CANC_MATCH_CMS = 1 then ATT_CANC_CHANGE_CMS = 'Yes';
            else if ATT_CANC_MATCH_CMS in (0,.) then ATT_CANC_CHANGE_CMS = 'No';

        if ATT_EPI_PERD_MATCH_CMS = 2 then ATT_STRTDT_CHANGE_CMS = 'N/A';
            else if ATT_EPI_PERD_MATCH_CMS = 1 then ATT_STRTDT_CHANGE_CMS = 'Yes';
            else if ATT_EPI_PERD_MATCH_CMS in (0,.) then ATT_STRTDT_CHANGE_CMS = 'No';

        if ATT_CANC_MATCH_CMS = 1 then ATT_CANC_CHANGE_CNT = 1;
            else if ATT_CANC_MATCH_CMS = 0 then ATT_CANC_CHANGE_CNT = 0;

        if ATT_EPI_PERD_MATCH_CMS = 1 then ATT_STRTDT_CHANGE_CNT = 1;
            else if ATT_EPI_PERD_MATCH_CMS = 0 then ATT_STRTDT_CHANGE_CNT = 0;
    end;

    if sex = '1' then SEX_USE = 'M';
    else if sex = '2' then SEX_USE = 'F';
	else SEX_USE = 'U';

    if CHEMO_IN_PP = 0 then CHEMO_IN_PP_USE = 'No Chemotherapy Claims';
        else if CHEMO_IN_PP = 1 then CHEMO_IN_PP_USE = 'Chemotherapy Prior to Q3 2016 Only';
        else if CHEMO_IN_PP = 2 or CHEMO_IN_PP = 3 then CHEMO_IN_PP_USE = 'Chemotherapy in Performance Period';
        else CHEMO_IN_PP_USE = '-';

    if NOVEL_THER_UTIL = 1 then NOVEL_THER_UTIL_USE = 'Yes';
        else if NOVEL_THER_UTIL = 0 then NOVEL_THER_UTIL_USE = 'No';
        else NOVEL_THER_UTIL_USE = '-';

    if NOVEL_THER_B_UTIL = 1 then NOVEL_THER_B_UTIL_USE = 'Yes';
        else if NOVEL_THER_B_UTIL = 0 then NOVEL_THER_B_UTIL_USE = 'No';
        else NOVEL_THER_B_UTIL_USE = '-';

    if NOVEL_THER_D_UTIL = 1 then NOVEL_THER_D_UTIL_USE = 'Yes';
        else if NOVEL_THER_D_UTIL = 0 then NOVEL_THER_D_UTIL_USE = 'No';
        else NOVEL_THER_D_UTIL_USE = '-';

    if DIED_MILLIMAN=1 then DIED_MILLIMAN_USE='Yes';
        else if DIED_MILLIMAN=0 then DIED_MILLIMAN_USE='No';
        else DIED_MILLIMAN_USE='-';

    if HSP_30DAYS_ALL_MILLIMAN=1 then HSP_30DAYS_ALL_MILLIMAN_USE='Yes';
        else if HSP_30DAYS_ALL_MILLIMAN=0 then HSP_30DAYS_ALL_MILLIMAN_USE='No';
        else HSP_30DAYS_ALL_MILLIMAN_USE='-';

    if ANY_HSP_CARE_MILLIMAN=3 then ANY_HSP_CARE_MILLIMAN_USE='Home & Facility';
        else if ANY_HSP_CARE_MILLIMAN=2 then ANY_HSP_CARE_MILLIMAN_USE='Facility';
        else if ANY_HSP_CARE_MILLIMAN=1 then ANY_HSP_CARE_MILLIMAN_USE='Home';
        else ANY_HSP_CARE_MILLIMAN_USE='-';

    if HOSPITAL_USE_MILLIMAN=1 then HOSPITAL_USE_MILLIMAN_USE='Yes';
        else if HOSPITAL_USE_MILLIMAN=0 then HOSPITAL_USE_MILLIMAN_USE='No';
        else HOSPITAL_USE_MILLIMAN_USE='-';

    if ICU_MILLIMAN=1 then ICU_MILLIMAN_USE='Yes';
        else if ICU_MILLIMAN=0 then ICU_MILLIMAN_USE='No';
        else ICU_MILLIMAN_USE='-';

    if CHEMOTHERAPY_MILLIMAN=1 then CHEMOTHERAPY_MILLIMAN_USE='Yes';
        else if CHEMOTHERAPY_MILLIMAN=0 then CHEMOTHERAPY_MILLIMAN_USE='No';
        else CHEMOTHERAPY_MILLIMAN_USE='-';

    if OCM1=1 then OCM1_USE='Yes';
        else if OCM1=0 then OCM1_USE='No';
        else OCM1_USE='-';

    if OCM3=1 then OCM3_USE='Yes';
        else if OCM3=0 then OCM3_USE='No';
        else OCM3_USE='-';

    if OCM2=1 then OCM2_USE='Yes';
        else if OCM2=0 then OCM2_USE='No';
        else OCM2_USE='-';

    if EPISODE_PERIOD = 'BAS' then do;
        DATA_COVERAGE_USE='Baseline';
    end;
    else do;
        if DATA_COVERAGE=1 then DATA_COVERAGE_USE='Full data coverage with demographics available';
            else if DATA_COVERAGE=2 then DATA_COVERAGE_USE='Full data coverage w/o demographics available';
            else if DATA_COVERAGE=3 then DATA_COVERAGE_USE='Gaps in Data Coverage';
            else DATA_COVERAGE_USE='-';
    end;

    if RISK_SCORE ne '' then RISK_SCORE_USE=RISK_SCORE;
        else RISK_SCORE_USE='-';

    if DIED_IN_HOSP=1 then DIED_IN_HOSP_USE='Yes';
        else if DIED_IN_HOSP=0 then DIED_IN_HOSP_USE='No';
        else DIED_IN_HOSP_USE='-';

    if Chemo_D_Util=1 and Chemo_B_Util=1 then CHEMO_EPI_UTIL= 'Part B and Part D';
        else if Chemo_D_Util=0 and Chemo_B_Util=1 then CHEMO_EPI_UTIL='Part B only';
        else if Chemo_D_Util=1 and Chemo_B_Util=0 then CHEMO_EPI_UTIL= 'Part D only';
        else CHEMO_EPI_UTIL ='None';

    if PATIENT_NAME='UNKNOWN' then PATIENT_NAME_USE='Unknown';
        else if PATIENT_NAME='' then PATIENT_NAME_USE='Unknown';
        else PATIENT_NAME_USE=PATIENT_NAME;

    if CHEMO_EPI_UTIL= 'Part B and Part D' then PARTB_CHEMO_UTIL ='Yes';
        else if CHEMO_EPI_UTIL='Part B only' then PARTB_CHEMO_UTIL ='Yes';
        else PARTB_CHEMO_UTIL ='No';

    ****Calculate allowed amount proportions by service cat to estimate for standardized total amounts***;
    CHEMOPB_ALLOWED_PROPORTION = CHEMOPB_ALLOWED/ALLOWED_MILLIMAN ;
    CHEMOPD_ALLOWED_PROPORTION = CHEMOPD_ALLOWED/ALLOWED_MILLIMAN ;
    OTHRX_ALLOWED_PROPORTION = sum(ANTIEMETICS_ALLOWED,HEMATOPOIETIC_ALLOWED,OTHRX_ALLOWED)/ALLOWED_MILLIMAN ;
    RADLAB_ALLOWED_PROPORTION = RADLAB_ALLOWED/ALLOWED_MILLIMAN ;
    IP_ALLOWED_PROPORTION = IP_ALLOWED/ALLOWED_MILLIMAN ;
    ER_OP_ALLOWED_PROPORTION = sum(OP_ALLOWED,ER_ALLOWED)/ALLOWED_MILLIMAN ;
    OTHR_FAC_ALLOWED_PROPORTION = sum(HOSPICE_ALLOWED,SNF_ALLOWED,HH_ALLOWED)/ALLOWED_MILLIMAN ;
    PROF_ALLOWED_PROPORTION = PROF_ALLOWED/ALLOWED_MILLIMAN ;
    ****************************************************************************************************;

    EPI_START_SOURCE = propcase(M_EPI_SOURCE_FINAL);

    if emerge_episode = 1 then do;
        if EMERGE_NOCHEMO = 1 then EMERGE_CHEMO_CLAIM = 'No';
            else EMERGE_CHEMO_CLAIM = 'Yes';

        if EMERGE_NOEM = 1 then EMERGE_EM_CLAIM = 'No';
            else EMERGE_EM_CLAIM = 'Yes';
    end;

    if EPISODE_PERIOD = 'BAS' then EPI_TIN_MATCH_USE='Baseline';
        else if attrib_episode = 1 and main_episode = 0 and ATT_TIN_MATCH = 'UNK' then EPI_TIN_MATCH_USE = 'N/A';
        else if attrib_episode = 1 and main_episode = 0 then EPI_TIN_MATCH_USE = propcase(ATT_TIN_MATCH);
        else if ATTRIBUTE_FLAG='D' then EPI_TIN_MATCH_USE='No';
        else if EPI_TIN_MATCH=1 then EPI_TIN_MATCH_USE='Yes';
        else if EPI_TIN_MATCH=0 then EPI_TIN_MATCH_USE='No';
        else EPI_TIN_MATCH_USE = 'N/A';

    if EPISODE_PERIOD = 'BAS' then period = 'BASE';
        else period = 'PERF';

    if meos_episode = 1 and main_episode = 0 and emerge_episode = 0 then ep_id_use = bene_id;
        else ep_id_use = ep_id;

    ** modify Cancer type and recon elig flag for filters on recon page **;
        if substr(EP_ID_CMS,1,3) = 'XXX' then RECON_CANCER_TYPE_USE = CMS_CANCER_TYPE_PRIOR_USE;
            else RECON_CANCER_TYPE_USE = CMS_CANCER_TYPE_USE;

        if substr(EP_ID_CMS,1,3) = 'XXX' then RECON_RECON_ELIG_FLAG = RECON_ELIG_prior;
            else RECON_RECON_ELIG_FLAG = RECON_ELIG;

        if substr(EP_ID_CMS,1,3) = 'XXX' then do;
            if RECON_ELIG_prior = 1 then RECON_ELIG_prior_use = 'Yes';
                else RECON_ELIG_prior_use = 'No';
        end;

        if substr(EP_ID_CMS,1,3) = 'XXX' then RECON_RECON_ELIG_USE = RECON_ELIG_prior_use;
            else RECON_RECON_ELIG_USE = RECON_ELIG_USE;

    ** modify age, HICN and recon elig flag for filters on recon page **;
        if substr(EP_ID_CMS,1,3) = 'XXX' then RECON_AGE = REC_AGE;
            else RECON_AGE = AGE;

        if substr(EP_ID_CMS,1,3) = 'XXX' then RECON_BENE_HICN = BENE_HICN_PRIOR;
            else RECON_BENE_HICN = BENE_HICN;

	** show MBI where we have it, else show RECON_BENE_HICN **;
		MBI_HICN = coalescec(BENE_MBI, RECON_BENE_HICN);

run;

proc sql;
    create table epi_detail2 as
        select a.*
              ,b.OCM1 as Milliman_NAvg_OCM1
              ,b.OCM2 as Milliman_NAvg_OCM2
              ,b.OCM3 as Milliman_NAvg_OCM3
              ,b.HOSPITAL_USE_MILLIMAN as Milliman_NAvg_Hospital
              ,b.ICU_MILLIMAN as Milliman_NAvg_ICU
              ,b.CHEMOTHERAPY_MILLIMAN as Milliman_NAvg_Chemo
              ,b.HSP_30DAYS_ALL_MILLIMAN as Milliman_NAvg_Hosp_Use
              ,b.HSP_DAYS_MILLIMAN as Milliman_NAvg_Hosp_Days
              ,b.DIED_MILLIMAN as Milliman_NAvg_Died_Episode
              ,b.DIED_IN_HOSP as Milliman_NAvg_OCM1_Died_Hospital
        from epi_detail1 as a
        left join bench.episode_benchmarks_5pct as b
        on a.CANCER_TYPE_QUALITY=b.CANCER_TYPE
        and (a.CHEMO_EPI_UTIL='Part B and Part D' or a.CHEMO_EPI_UTIL='Part B only')
;
quit;

proc sql;
    create table epi_detail_milliman_prices_pre as
        select a.*
             , b.BASELINE_PRICE_MILLIMAN as BASELINE_PRICE_MILLIMAN_REC
             , b.TREND
             , b.WIN_ADJ_NOVEL_THER
             , b.NOVEL_THER_ADJ
             , case when EPISODE_PERIOD_USE = 'PP1' then 0.145007165906
                when EPISODE_PERIOD_USE = 'PP2' then 0.178407991936
				when EPISODE_PERIOD_USE = 'PP3' then 0.189648474153
                end as NON_OCM_PROP_ACTUAL_EP_EXP_NOVEL /*FROM RECON REPORTS*/
        from epi_detail2 as A
            left join inrec.price_summary as B
            on compress(a.EP_ID_CMS) = compress(b.EP_ID_CMS)
;
quit;

**sum of baseline prices*;
proc sql;
    create table epi_sum_prices as
        select REC_OCM_ID
            , EPISODE_PERIOD_USE
            , max(TREND) as TREND
            , max(WIN_ADJ_NOVEL_THER) as WIN_ADJ_NOVEL_THER
            , max(NON_OCM_PROP_ACTUAL_EP_EXP_NOVEL) as NON_OCM_PROP_ACTUAL_EP_EXP_NOVEL
            , max(NOVEL_THER_ADJ) as NOVEL_THER_ADJ
            , sum(ACTUAL_EXP_MILLIMAN) as ACTUAL_EXP_MILLIMAN_SUM
            , sum(BASELINE_PRICE_MILLIMAN_REC) as BASELINE_PRICE_MILLIMAN_SUM
            , sum(REC_NOVEL_THERAPIES_MILLIMAN) as NOVEL_THERAPIES_MILLIMAN_SUM
        from epi_detail_milliman_prices_pre
        where recon_episode = 1
          and recon_elig = '1'
        group by REC_OCM_ID, EPISODE_PERIOD_USE;
quit;

*PRACTICE LEVEL*;
data practice_level_milliman_prices;
    set epi_sum_prices;

    ** MILLIMAN CALC OF [TAB 3 - RECON ADJUSTMENT DETAIL] **;
        *G*; novel_ther_wins                = NOVEL_THERAPIES_MILLIMAN_SUM * WIN_ADJ_NOVEL_THER;
        *H*; prop_act_exp_novel_ther        = novel_ther_wins / ACTUAL_EXP_MILLIMAN_SUM;
        *J*; prop_novel_ther_beyond         = max(0, prop_act_exp_novel_ther - NON_OCM_PROP_ACTUAL_EP_EXP_NOVEL);
        *K*; addl_exp_novel_ther_use        = ACTUAL_EXP_MILLIMAN_SUM * prop_novel_ther_beyond;
        *L*; addl_exp_novel_ther_use_adj    = addl_exp_novel_ther_use * 0.8;
        *M*; trended_sum_baseline_price     = BASELINE_PRICE_MILLIMAN_SUM * TREND;
        *N*; NOVEL_THER_ADJ_MILLIMAN        = ROUND((1 + (addl_exp_novel_ther_use_adj/trended_sum_baseline_price)), .000000000001);

run;

*EPISODE LEVEL*;
proc sql;
    create table epi_detail_milliman_prices as
        select a.*
              ,b.NOVEL_THER_ADJ_MILLIMAN
        from epi_detail_milliman_prices_pre as A
        left join practice_level_milliman_prices as B
        on A.REC_OCM_ID = B.REC_OCM_ID
        and A.EPISODE_PERIOD_USE = B.EPISODE_PERIOD_USE
;
quit;

data epi_detail_milliman_final;
    set epi_detail_milliman_prices;

    ** MILLIMAN CALC OF [TAB 2 - RECONCILIATION CALC] **;
        *G*; BENCHMARK_PRICE_MILLIMAN   = BASELINE_PRICE_MILLIMAN_REC * TREND * NOVEL_THER_ADJ_MILLIMAN;
        *I*; TARGET_PRICE_MILLIMAN      = BENCHMARK_PRICE_MILLIMAN * (1-0.04); /* OCM DISCOUNT = 4% */

    **CHECK DIFFERENCES**;
    **; novel_ther_adj_diff             = NOVEL_THER_ADJ_MILLIMAN - NOVEL_THER_ADJ;
     TARGET_PRICE_DIFF_CMS_MILL         = TARGET_PRICE_MILLIMAN - TARGET_PRICE;
    **; target_price_novel_ther_diff    = novel_ther_adj_diff * TARGET_PRICE;
     DIFF_TARGET_ACTUAL_MILLIMAN        = TARGET_PRICE_MILLIMAN - ACTUAL_EXP_MILLIMAN;
    *********************;

run;

proc sql;
    create table ocmid_level_sums as
        select
            REC_OCM_ID
            , EPISODE_PERIOD_USE
            , sum(TARGET_PRICE_MILLIMAN) as TARGET_PRICE_MILLIMAN_SUM
            , sum(ACTUAL_EXP_MILLIMAN) as ACTUAL_EXP_MILLIMAN_SUM
            , sum(NUM_OCM1_MILLIMAN)/count(EP_ID) as OCM1_MILLIMAN_VALUE_SUM
            , sum(NUM_OCM1_N)/count(EP_ID) as OCM1_CMS_VALUE_SUM
            , sum(NUM_OCM2_MILLIMAN)/count(EP_ID) as OCM2_MILLIMAN_VALUE_SUM
            , sum(NUM_OCM2_N)/count(EP_ID) as OCM2_CMS_VALUE_SUM
            , sum(NUM_OCM3_MILLIMAN)/sum(DEN_OCM3_MILLIMAN) as OCM3_MILLIMAN_VALUE_SUM
            , sum(NUM_OCM3_N)/sum(DEN_OCM3_N) as OCM3_CMS_VALUE_SUM
            , sum(BENCHMARK_PRICE_MILLIMAN) as BENCHMARK_PRICE_MILLIMAN_SUM
            , (calculated BENCHMARK_PRICE_MILLIMAN_SUM *0.2) as STOP_LOSS_MILLIMAN
        from epi_detail_milliman_final
        where recon_episode=1
          and recon_elig = '1'
        group by REC_OCM_ID, EPISODE_PERIOD_USE
;
quit;

proc sql;
    create table epi_detail3 as
        select a.*
            , b.OCM1_MILLIMAN_VALUE_SUM
            , b.OCM1_CMS_VALUE_SUM
            , b.OCM2_MILLIMAN_VALUE_SUM
            , b.OCM2_CMS_VALUE_SUM
            , b.OCM3_MILLIMAN_VALUE_SUM
            , b.OCM3_CMS_VALUE_SUM
            , b.TARGET_PRICE_MILLIMAN_SUM
            , b.ACTUAL_EXP_MILLIMAN_SUM
            , b.BENCHMARK_PRICE_MILLIMAN_SUM
            , b.STOP_LOSS_MILLIMAN
            , (sign(b.TARGET_PRICE_MILLIMAN_SUM - b.ACTUAL_EXP_MILLIMAN_SUM)
                * Min(b.STOP_LOSS_MILLIMAN,abs(b.TARGET_PRICE_MILLIMAN_SUM - b.ACTUAL_EXP_MILLIMAN_SUM)))
                as MILLIMAN_PBP_AFTER_STOPLOSS
    from epi_detail_milliman_final as a
        left join ocmid_level_sums as b
    on a.REC_OCM_ID=b.REC_OCM_ID
    and a.EPISODE_PERIOD_USE = b.EPISODE_PERIOD_USE
;
quit;

proc sql;
    create table
            out.epi_detail_combined_&set_name._&ocmid1.

    as
        select a.*
            ,case when a.EPI_NPI_ID in ("",".") then "Unknown"
                when b.provider_last_name__legal_name_ = "" then strip("Unknown ("||strip(EPI_NPI_ID)||")")
                else strip(propcase(b.provider_last_name__legal_name_))||", "||strip(propcase(b.provider_first_name))||" ("||strip(EPI_NPI_ID)||")"
                end as ATTRIBUTED_PROV
            ,case when a.EPI_NPI_ID in ("",".") then "Unknown"
                when b.provider_last_name__legal_name_ = "" then strip("Unknown ("||strip(EPI_NPI_ID)||")")
                else strip(propcase(b.provider_last_name__legal_name_))||", "||strip(propcase(substr(b.provider_first_name,1,1)))||" - "||strip(substr(EPI_NPI_ID,7,4))
                end as ATTRIBUTED_PROV_ABBREV
            ,case when a.REC_EPI_NPI_ID in ("",".") then "Unknown"
                when b.provider_last_name__legal_name_ = "" then strip("Unknown ("||strip(REC_EPI_NPI_ID)||")")
                else strip(propcase(b.provider_last_name__legal_name_))||", "||strip(propcase(b.provider_first_name))||" ("||strip(REC_EPI_NPI_ID)||")"
                end as REC_ATTRIBUTED_PROV
            ,case when a.REC_EPI_NPI_ID in ("",".") then "Unknown"
                when b.provider_last_name__legal_name_ = "" then strip("Unknown ("||strip(REC_EPI_NPI_ID)||")")
                else strip(propcase(b.provider_last_name__legal_name_))||", "||strip(propcase(substr(b.provider_first_name,1,1)))||" - "||strip(substr(REC_EPI_NPI_ID,7,4))
                end as REC_ATTRIBUTED_PROV_ABBREV
    from
            epi_detail3

    as a
            left join
            ref.npi_data as b
            on a.EPI_NPI_ID =b.npi
;
quit;


%mend episode;

*************************************************************************************************************;
**************************************** END EPISODE PROCESSING *********************************************;
*************************************************************************************************************;

*----------- ALL files -----------*;
/*%episode(255,50179,'MSMC Oncology LLC');*/
/*%episode(257,50195,'Cancer Center of East Alabama');*/
/*%episode(480,50185,'Peninsula Cancer Institute LLC');*/
/*%episode(396,50258,'GHS DBA University Medical Group');*/
/*%episode(278,50193,'Upstate Oncology Associates');*/
/*%episode(290,50202,'BSHSI St. Francis Medical Center');*/
/*%episode(523,50330,'Memorial Cancer Institute');*/
/*%episode(280,50115,'Warren Clinic Saint Francis Cancer Center');*/
/*%episode(401,50228,'Mountain States Regional Cancer Center');*/
/*%episode(468,50227,'Johnson City Regional Cancer Center');*/
/*%episode(459,50243,'University Hospitals Medical Group');*/
/*%episode(137,50136,'Regional Cancer Care Associates');*/


*************************************************************************************************************;
**************************************** CLAIMS PROCESSING **************************************************;
*************************************************************************************************************;

%macro claims(OCMID1, ocmid2, ocmfac_name, report);

*Claims Detail*;
**	A) Add CCN Name	**;
proc sql;
	create table claims_detail_A1_&report. as
	select ocm_id
		  ,ep_id
		 %if &report. = MEOS %then %do;
		  ,bene_id
		 %end;
		  ,claim_id
		  ,start_date
		  ,end_date
		  ,prvdr_num
		  ,admit_dt
		  ,dschrg_dt
		  ,at_npi
		  ,op_npi
		  ,drg_cd
		  ,admit_diag_cd
		  ,principal_diag_cd
		  ,procedure_cd
		  ,los
		  ,stus_cd
		  ,visitcnt
		  ,hcfaspcl
		  ,prfnpi
		  ,hcpcs_cd
		  ,ndc
		  ,REV_CNTR
		  ,prscrbr_id
		  ,part_d_service_date
		  ,fill_num
		  ,days_supply
		  ,label1
		  ,label2
		  ,ER_WEEKEND
		  ,ER_WEEKEND_COUNT 
		  ,IP_ER_CASE
		  ,UNITS_DOSE
		  , case when READMIT_FLAG=1 then "Yes"
		  	else "No" end as READMIT_FLAG_USE
		  %if &report. = MEOS %then %do;
		  	,MEOS_STD_PAY
		  %end;
		  ,INDEX_ADMIT 
		  ,UNPLANNED_READMIT_FLAG
		  ,HAS_READMISSION
		  %if &report. ^= MEOS %then %do;
		 	 ,TaxNum_TIN
			 ,TAX_NUM
		  %end;
		  %if &label. = base %then %do;
				  ,label2 as LABEL3
				  ,'-' as novel_therapy 
		  %end;
		  %else %do;
				  ,LABEL3
				  ,propcase(novel_therapy) as novel_therapy 
		  %end;

		  ,sum(allowed) as allowed
		  ,sum(tot_rx_cst_amt) as tot_rx_cst_amt
		,case when substr(prvdr_num,3,1) in ("Z") then tranwrd(prvdr_num,"Z","1")
			  	when substr(prvdr_num,3,1) in ("R") then tranwrd(prvdr_num,"R","1")
				when substr(prvdr_num,3,1) in ("M") then tranwrd(prvdr_num,"M","1")
			  	when substr(prvdr_num,3,1) in ("S") then tranwrd(prvdr_num,"S","0")
				when substr(prvdr_num,3,1) in ("T") then tranwrd(prvdr_num,"T","0")
				when substr(prvdr_num,3,1) in ("U") then tranwrd(prvdr_num,"U","0")
				else prvdr_num
				end as provider_ccn_use

		%if &label. = performance %then %do;
			from in.claims_&report._&set_name._&ocmid1._&ocmid2. as a 
		%end;
		%else %do;
			from in.claims_&report._&set_name_base._&ocmid1._&ocmid2. as a 
		%end;

		group by
		 ocm_id
		  ,ep_id
		 %if &report. = MEOS %then %do;
		  ,bene_id
		 %end;
		  ,claim_id
		  ,start_date
		  ,end_date
		  ,novel_therapy
		  ,prvdr_num
		  ,admit_dt
		  ,dschrg_dt
		  ,at_npi
		  ,op_npi
		  ,drg_cd
		  ,admit_diag_cd
		  ,principal_diag_cd
		  ,procedure_cd
		  ,los
		  ,stus_cd
		  ,visitcnt
		  ,hcfaspcl
		  ,prfnpi
		  ,hcpcs_cd
		  ,ndc
		  ,REV_CNTR
		  ,prscrbr_id
		  ,part_d_service_date
		  ,fill_num
		  ,days_supply
		  ,label1
		  ,label2
		  ,ER_WEEKEND
		  ,ER_WEEKEND_COUNT
		  ,IP_ER_CASE
		  ,UNITS_DOSE
		  ,READMIT_FLAG_USE
		  ,label3
		  ,provider_ccn_use
		  %if &report. = MEOS %then %do;
		  	,MEOS_STD_PAY
		  %end;
		  ,INDEX_ADMIT 
		  ,UNPLANNED_READMIT_FLAG
		  ,HAS_READMISSION
		  %if &report. ^= MEOS %then %do;
		 	 ,TaxNum_TIN
			 ,TAX_NUM
		  %end;
;


create table claims_detail_A_&report. as
	select	distinct a.*
		,	case when a.prvdr_num in ("",".") then ""
				when b.fac_name = "" then strip("Unknown ("||strip(a.prvdr_num)||")")
				else (propcase(strip(b.fac_name))||" ("||a.prvdr_num||")")
				end as PROVIDER_NAME
	from	claims_detail_A1_&report. as a
			left join
			metadat.ccns_codemap as b
			on a.provider_ccn_use=strip(b.ccn)
			;
quit;

**	B) Add Attending and Operating Provider Names	**;
proc sql;
	create table claims_detail_B1_&report. as
	select	distinct a.*
		,	case when a.at_npi in ("",".") then ""
				when b.provider_last_name__legal_name_ = "" then strip("Unknown ("||strip(at_npi)||")")
				else strip(propcase(b.provider_last_name__legal_name_))||", "||strip(propcase(b.provider_first_name))||" ("||at_npi||")"
				end as AT_NPI_NAME
	from	claims_detail_A_&report. as a
			left join
			ref.npi_data as b
			on a.at_npi=b.npi
;
	create table claims_detail_B2_&report. as
	select	distinct a.*
		,	case when a.op_npi in ("",".") then ""
				when b.provider_last_name__legal_name_ = "" then strip("Unknown ("||strip(op_npi)||")")
				else strip(propcase(b.provider_last_name__legal_name_))||", "||strip(propcase(b.provider_first_name))||" ("||op_npi||")"
				end as OP_NPI_NAME
	from	claims_detail_B1_&report. as a
			left join
			ref.npi_data as b
			on a.op_npi=b.npi
;
quit;

**	C) Add MSDRG Names	**;
proc sql;
	create table claims_detail_C_&report. as
	select	distinct a.*
		,	case when a.drg_cd in ("",".","000") then ""
				when b.msdrg_description = "" then a.drg_cd
				else strip(a.drg_cd)||": "||b.msdrg_description
				end as DRG_CD_NAME
		,	case when b.msdrg_description in ("",".") then "" else propcase(b.msdrg_description) end as DRG_DESC
	from	claims_detail_B2_&report. as a
			left join
			metadat.msdrgs as b
			on a.drg_cd=b.msdrg
;
quit;

**	D) Add Admit and Diag Code Descriptions**;
proc sql;
	create table claims_detail_D1_&report. as
	select	distinct a.*
		,	case when a.admit_diag_cd in ("",".") then ""
				when b.diag_desc = "" then a.admit_diag_cd
				else strip(a.admit_diag_cd)||": "||lowcase(b.diag_desc)
				end as ADMIT_DIAG_CD_NAME
	from	claims_detail_C_&report. as a
			left join
			metadat.icd9diag_codemap as b
			on a.admit_diag_cd=b.diag
			and ((a.end_date < '01OCT2015'd and b.version = 9) or (a.end_date >= '01OCT2015'd and b.version = 0))
;
	create table claims_detail_D2_&report. as
	select	distinct a.*
		,	case when a.principal_diag_cd in ("",".") then ""
				when b.diag_desc = "" then a.principal_diag_cd
				else strip(a.principal_diag_cd)||": "||lowcase(b.diag_desc)
				end as PRINCIPAL_DIAG_CD_NAME
	from	claims_detail_D1_&report. as a
			left join
			metadat.icd9diag_codemap as b
			on a.principal_diag_cd=b.diag
			and ((a.end_date < '01OCT2015'd and b.version = 9) or (a.end_date >= '01OCT2015'd and b.version = 0))
;
quit;

**	E) Add procedure code description	**;
proc sql;
	create table claims_detail_E_&report. as
	select	distinct a.*
		,	case when a.procedure_cd in ("",".") then ""
				when b.icd9proc_desc = "" then a.procedure_cd
				else strip(a.procedure_cd)||": "||lowcase(b.icd9proc_Desc)
				end as PROCEDURE_CODE_NAME
	from	claims_detail_D2_&report. as a
			left join
			metadat.icd9proc_codemap as b
			on a.procedure_cd=b.icd9proc
			and ((a.end_date < '01OCT2015'd and b.version = 9) or (a.end_date >= '01OCT2015'd and b.version = 0))
;
quit;

**	F) Add Status Code Descriptions	**;
proc sql;
	create table claims_detail_F_&report. as
	select	distinct a.*
		,	b.stus_cd_desc as DISCHARGE_STATUS
	from	claims_detail_E_&report. as a
			left join
			ref.stus_cd_desc as b
			on a.stus_cd=put(b.stus_cd,2.)
;
quit;

**	G) Specialty Code Descriptions	**;
proc sql;
	create table claims_detail_G_&report. as
	select	distinct a.*
		,	b.prov_type_description2 as PROVIDER_SPECIALTY
	from	claims_detail_F_&report. as a
			left join
			ref.specialty_code_descriptions as b
			on a.HCFASPCL=b.medicare_specialty_code
;
quit;

**	H) Add PRF NPI Name	**;
proc sql;
	create table claims_detail_H_&report. as
	select	distinct a.*
		,	case when a.prfnpi in ("",".") then ""
				when b.Provider_Organization_Name__Leg ^= "" then strip(propcase(strip(b.Provider_Organization_Name__Leg))||" ("||strip(prfnpi)||")")
				when b.provider_last_name__legal_name_ = "" then strip("Unknown ("||strip(prfnpi)||")")
				else strip(propcase(b.provider_last_name__legal_name_))||", "||strip(propcase(b.provider_first_name))||" ("||strip(prfnpi)||")"
				end as NPI_NAME

	from	claims_detail_G_&report. as a
			left join
			ref.npi_data as b
			on a.prfnpi=b.npi
;
quit;

**	H-1) Add Prescribing NPI Name	**;
proc sql;
	create table claims_detail_H1_&report. as
	select	distinct a.*
		,	case when a.PRSCRBR_ID in ("",".") then ""
				when b.provider_last_name__legal_name_ = "" and Provider_Organization_Name__Leg ^= '' then strip(Provider_Organization_Name__Leg||" ("||strip(a.PRSCRBR_ID)||")")
				when b.provider_last_name__legal_name_ = "" then strip("Unknown ("||strip(a.PRSCRBR_ID)||")")
				else strip(propcase(b.provider_last_name__legal_name_))||", "||strip(propcase(b.provider_first_name))||" ("||strip(PRSCRBR_ID)||")"
				end as PRSCRBR_ID_NAME

	from	claims_detail_H_&report. as a
			left join
			ref.npi_data as b
			on a.PRSCRBR_ID=b.npi
;
quit;


**	I) Add HCPCS**;
proc sql;
	create table claims_detail_I_&report. as
	select	distinct a.*
		,	case when a.hcpcs_cd in ("",".") then ""
				when substr(a.hcpcs_cd,1,2) in ("WW") then strip(a.hcpcs_cd)||": "||c.drug_name
				when b.proc_desc = "" then a.hcpcs_cd
				else strip(a.hcpcs_cd)||": "||b.proc_desc
				end as HCPCS_CD_NAME
		,	case when substr(a.hcpcs_cd,1,2) in ("WW") then propcase(c.drug_name)
				 when b.proc_desc in ("",".") then ""
				 else propcase(b.proc_desc) 
				 end as HCPCS_DESC
		,coalesce(PROVIDER_NAME,NPI_NAME,PRSCRBR_ID_NAME) as PROVIDER_NAME_USE
		,coalesce(start_date,PART_D_SERVICE_DATE) as START_DATE_USE format=mmddyy10.
	from	claims_detail_H1_&report. as a
			left join
			metadat.hcpcs as b
			on a.hcpcs_cd=b.proc
			left join
			metadat.ndc_descriptions as c
			on a.hcpcs_cd=c.ndc
;
quit;

**	J. Add NDC Description	**;
proc sql;
	create table claims_detail_J_&report. as
	select	distinct a.*
		,	case when a.ndc in ("",".") then ""
				 when b.drug_name in ("",".") then strip(a.ndc)
				 else strip(a.ndc)||": "||propcase(b.drug_name) 
				 end as NDC_NAME
		,	case when b.drug_name in ("",".") then "" else propcase(b.drug_name) end as NDC_DESC
	from	claims_detail_I_&report. as a
			left join
			metadat.ndc_descriptions as b
			on substr(a.ndc,1,11)=substr(b.ndc,1,11)
;
quit;


**	K) Add RevCodes**;
proc sql;
	create table claims_detail_K_&report. as
	select	distinct a.*
		,	case when a.REV_CNTR in ("",".") then ""
				when b.rev_desc = "" then a.REV_CNTR
				when a.REV_CNTR = 'Outpatient Outlier' then 'Outpatient Outlier'
				else strip(a.REV_CNTR)||": "||b.rev_desc
				end as REV_CD_NAME
		,	case when b.rev_desc in ("",".") then "" else propcase(b.rev_desc) end as REV_DESC
	from	claims_detail_J_&report. as a
			left join
			metadat.revcode_descriptions as b
			on a.REV_CNTR=b.rev
;
quit;


**	L. Create total description field	**; 
proc sql;

	create table claims_detail_L_&report. as 
	select *
		,	coalesce(DRG_CD, HCPCS_CD, NDC, REV_CNTR,'') as CODE_USE
		,	coalesce(DRG_DESC, HCPCS_DESC, NDC_DESC, REV_DESC,'') as CODE_DESC_USE
		,	coalesce(DRG_CD_NAME, HCPCS_CD_NAME, NDC_NAME, REV_CD_NAME,'') as CODE_NAME_USE
	from claims_detail_K_&report.

;
quit;


**	FINAL: Add Claim Counter and output dataset	**;
data claims_detail_M_&report.;
	format OCM_ID $3. UNPLANNED_READMIT_FLAG_USE HAS_READMISSION_USE $12. TIN_CCN $150.;
	set claims_detail_L_&report.;
	length period $4 ep_id2 $50 OCM_ID $3 ep_id_meos Join_Var_MEOS $50.;
	retain CLAIM_COUNTER;
	claim_counter+1;

	%if &report. ^= MEOS %then %do;
		if TAX_NUM ne '' then do;
			TIN_CCN = coalescec(TaxNum_TIN,PROVIDER_NAME,'-');
		end;
		else do;
			TIN_CCN = coalescec(TAX_NUM,PROVIDER_NAME,'-');
		end;
	%end;

	%if &label. = base %then %do;
		period = "BASE";
		ep_id2 = ep_id;
	%end;
	%else %do;
		period = "PERF";
		ep_id2 = ep_id;
	%end;

	%if &report. = MEOS %then %do;
		ep_id_meos = coalescec(ep_id,BENE_ID);
		Join_Var_MEOS = trim(OCM_ID)||trim(BENE_ID)||trim(Claim_ID);
	%end;

/*	if label1 = 'Facilities' then do;*/
		IF LABEL3 = 'Emergency Department' 										THEN SORT_ORDER = 1;
			ELSE IF LABEL3 = 'Professional: Emergency' 							THEN SORT_ORDER = 2;
			ELSE IF LABEL3 = 'Outpatient: Other' 								THEN SORT_ORDER = 3;
			ELSE IF LABEL3 = 'Inpatient Medical: Potentially Chemo Related' 	THEN SORT_ORDER = 4;
			ELSE IF LABEL3 = 'Inpatient Medical: Other' 						THEN SORT_ORDER = 5;
			ELSE IF LABEL3 = 'Inpatient Surgical: Cancer ' 						THEN SORT_ORDER = 6;
			ELSE IF LABEL3 = 'Inpatient Surgical: Non-Cancer' 					THEN SORT_ORDER = 7;
			ELSE IF LABEL3 = 'Inpatient: Other' 								THEN SORT_ORDER = 8;
			ELSE IF LABEL3 = 'Outpatient Surgery: Cancer' 						THEN SORT_ORDER = 9;
			ELSE IF LABEL3 = 'Outpatient Surgery: Non-Cancer'					THEN SORT_ORDER = 10;
			ELSE IF LABEL3 = 'SNF' 												THEN SORT_ORDER = 11;
			ELSE IF LABEL3 = 'Home Health' 										THEN SORT_ORDER = 12;
			ELSE IF LABEL3 = 'Hospice' 											THEN SORT_ORDER = 13;
/*	end;*/
/*	else if label1 = 'Drugs' then do;*/
		ELSE IF LABEL3 = 'Part B Chemo: Novel Therapy' 							THEN SORT_ORDER = 14;
			ELSE IF LABEL3 = 'Part B Chemo: Biologic' 							THEN SORT_ORDER = 15;
			ELSE IF LABEL3 = 'Part B Chemo: Cytotoxic' 							THEN SORT_ORDER = 16;
			ELSE IF LABEL3 = 'Part B Chemo: Hormonal'							THEN SORT_ORDER = 17;
			ELSE IF LABEL3 = 'Part B Chemo: Other' 								THEN SORT_ORDER = 18;
			ELSE IF LABEL3 = 'Part D Chemo: Novel Therapy' 						THEN SORT_ORDER = 19;
			ELSE IF LABEL3 = 'Part D Chemo: Biologic' 							THEN SORT_ORDER = 10;
			ELSE IF LABEL3 = 'Part D Chemo: Cytotoxic' 							THEN SORT_ORDER = 22;
			ELSE IF LABEL3 = 'Part D Chemo: Hormonal' 							THEN SORT_ORDER = 23;
			ELSE IF LABEL3 = 'Part D Chemo: Other' 								THEN SORT_ORDER = 23;
			ELSE IF LABEL3 = 'Anti-emetics'										THEN SORT_ORDER = 24;
			ELSE IF LABEL3 = 'Hematopoietic Agents' 							THEN SORT_ORDER = 25;
			ELSE IF LABEL3 = 'Chemotherapy Adjuncts' 							THEN SORT_ORDER = 26;
			ELSE IF LABEL3 = 'Chemotherapy Administration' 						THEN SORT_ORDER = 27;
			ELSE IF LABEL3 = 'Other Drugs and Administration' 					THEN SORT_ORDER = 28;
/*	end;*/
/*	else if label1 = 'Radiation & Lab' then do;*/
		ELSE IF LABEL3 = 'Radiation Oncology' 									THEN SORT_ORDER = 29;
			ELSE IF LABEL3 = 'Radiology: MRI' 									THEN SORT_ORDER = 30;
			ELSE IF LABEL3 = 'Radiology: PET' 									THEN SORT_ORDER = 31;
			ELSE IF LABEL3 = 'Radiology: CT'									THEN SORT_ORDER = 32;
			ELSE IF LABEL3 = 'Radiology: Other' 								THEN SORT_ORDER = 33;
			ELSE IF LABEL3 = 'Lab' 												THEN SORT_ORDER = 34;
/*	end;*/
/*	else if label1 = 'Professional' then do;*/
		ELSE IF LABEL3 = 'Professional: Inpatient' 								THEN SORT_ORDER = 35;
			ELSE IF LABEL3 = 'Professional: Anesthesia' 						THEN SORT_ORDER = 36;
			ELSE IF LABEL3 = 'Professional: Office Visit' 						THEN SORT_ORDER = 37;
			ELSE IF LABEL3 = 'Professional: Surgery' 							THEN SORT_ORDER = 38;
			ELSE IF LABEL3 = 'Professional: MEOS - Your Practice' 				THEN SORT_ORDER = 39;
			ELSE IF LABEL3 = 'Professional: MEOS - All Other Practices' 		THEN SORT_ORDER = 40;
			ELSE IF LABEL3 = 'Professional: Qualifying E&M Visits at Attrib TIN' THEN SORT_ORDER = 41;
			ELSE IF LABEL3 = 'Professional: Qualifying E&M Visits at Other TINs' THEN SORT_ORDER = 42;
			ELSE IF LABEL3 = 'Professional: Other' 								THEN SORT_ORDER = 43;
			ELSE IF LABEL3 = 'DME'												THEN SORT_ORDER = 44;
/*	end;*/

	OCM_NAME=&ocmfac_name.||' (OCM ID '||ocm_id||')';

	if UNPLANNED_READMIT_FLAG = 9 then UNPLANNED_READMIT_FLAG_USE = 'Transfer';
		else if UNPLANNED_READMIT_FLAG = 1 then UNPLANNED_READMIT_FLAG_USE = 'Yes';
		else if UNPLANNED_READMIT_FLAG = 0 then UNPLANNED_READMIT_FLAG_USE = 'No';
		else UNPLANNED_READMIT_FLAG_USE = '';

	if HAS_READMISSION = 9 then HAS_READMISSION_USE = 'Transfer';
		else if HAS_READMISSION = 1 then HAS_READMISSION_USE = 'Yes';
		else if HAS_READMISSION = 0 then HAS_READMISSION_USE = 'No';
		else HAS_READMISSION_USE = '';


run;

proc sort data=claims_detail_M_&report.;
	by ep_id2 start_date_use label3 code_use;
run;

data 
	%if &label. = performance %then %do;
		out.clm_detail_&report._&set_name._&ocmid1.
	%end;
	%else %do;
		out.clm_detail_&report._&set_name_base._&ocmid1.
	%end;

	(drop=counter);

	set claims_detail_M_&report.;
	by ep_id2;
	retain counter;

	if first.ep_id2 then counter = 1;

	claim_detail_sort = strip("Claim"||strip(put(counter,best12.)));

	counter + 1;

run;


proc sql;
	create table 

		%if &label. = performance %then %do;
			out.util_filter_&report._&set_name._&ocmid1.
		%end;
		%else %do;
			out.util_filter_&report._&set_name_base._&ocmid1.
		%end;

	as
	select distinct ep_id2
			,code_name_use
			,label3
	from 

		%if &label. = performance %then %do;
			out.clm_detail_&report._&set_name._&ocmid1.
		%end;
		%else %do;
			out.clm_detail_&report._&set_name_base._&ocmid1.
		%end;
		where code_name_use ^=''
		;

quit;

*************************************************************************************************************;
************************************* PATIENT JOURNEY PROCESSING ********************************************;
*************************************************************************************************************;

%if &report. = interface %then %do;

	data patientjourney_1 ;
		set 
			%if &label = performance %then %do;
				out.clm_detail_&report._&set_name._&ocmid1.;
			%end;
			%else %do;
				out.clm_detail_&report._&set_name_base._&ocmid1.;
			%end;
		keep  ep_id2 period START_DATE END_DATE LABEL2 provider_name_use rank;

		if label2 = 'Emergency Department' then rank = '1';

		else if label2 = 'Inpatient Medical: Potentially Chemo Related' then rank = '2';
		else if label2 = 'Inpatient Medical: Other' then rank = '2';
		else if label2 = 'Inpatient Surgical: Cancer' then rank = '2';
		else if label2 = 'Inpatient Surgical: Non-Cancer' then rank = '2';
		else if label2 = 'Inpatient: Other' then rank = '2';

		else if label2 = 'Part B Chemo: Biologic' then rank = '3';
		else if label2 = 'Part B Chemo: Cytotoxic' then rank = '3';
		else if label2 = 'Part B Chemo: Hormonal' then rank = '3';
		else if label2 = 'Part B Chemo: Other' then rank = '3';

		else if label2 = 'Radiation Oncology' then rank = '4';

		else if label2 = 'Hospice' then rank = '5';

		else delete;

		run;

	proc sql;
		create table patientjourney_2 as 
			select distinct coalesce(a.ep_id2,b.ep_id_use) as ep_id2
						   ,a.period 
						   ,a.START_DATE 
						   ,a.END_DATE 
						   ,a.LABEL2 
						   ,a.provider_name_use 
						   ,a.rank
						   ,b.cancer_type_use
						   ,b.dod
						   ,b.ep_beg
						   ,b.ep_end
						   ,ocm_name
			from patientjourney_1 as a
			right join 
					out.epi_detail_combined_&set_name._&ocmid1. as b
					on a.ep_id2 = b.ep_id_use
			where 
				%if &label. = performance %then %do;
					a.period = 'PERF'
				%end;
				%else %do;
					a.period = 'BASE'
				%end;
		;
	quit;

	proc sort data = patientjourney_2 nodupkey;
		by ep_id2 start_date rank;
	run;


	data 
		%if &label = performance %then %do;
			out.patjourney_&report._&set_name._&ocmid1. 
		%end;
		%else %do;
			out.patjourney_&report._&set_name_base._&ocmid1. 
		%end;

	(keep= ocm_name d1--d183 rank_d1--rank_d183 period ep_id2);
		set patientjourney_2;
		length period $4;
		by ocm_name ep_id2;
		
		retain rank2 label2_2 provider_name2 d1-d183 rank_d1-rank_d183 ;
		length label2_2 provider_name2 d1-d183 $255 rank_d1-rank_d183 rank2 $3;

		if first.ep_id2 then do;

			d1 = ''; d2 = ''; d3 = ''; d4 = ''; d5 = ''; d6 = ''; d7 = ''; d8 = ''; d9 = '';
			d10 = ''; d11 = ''; d12 = ''; d13 = ''; d14 = ''; d15 = ''; d16 = ''; d17 = ''; d18 = ''; d19 = '';
			d20 = ''; d21 = ''; d22 = ''; d23 = ''; d24 = ''; d25 = ''; d26 = ''; d27 = ''; d28 = ''; d29 = '';
			d30 = ''; d31 = ''; d32 = ''; d33 = ''; d34 = ''; d35 = ''; d36 = ''; d37 = ''; d38 = ''; d39 = '';
			d40 = ''; d41 = ''; d42 = ''; d43 = ''; d44 = ''; d45 = ''; d46 = ''; d47 = ''; d48 = ''; d49 = '';
			d50 = ''; d51 = ''; d52 = ''; d53 = ''; d54 = ''; d55 = ''; d56 = ''; d57 = ''; d58 = ''; d59 = '';
			d60 = ''; d61 = ''; d62 = ''; d63 = ''; d64 = ''; d65 = ''; d66 = ''; d67 = ''; d68 = ''; d69 = '';
			d70 = ''; d71 = ''; d72 = ''; d73 = ''; d74 = ''; d75 = ''; d76 = ''; d77 = ''; d78 = ''; d79 = '';
			d80 = ''; d81 = ''; d82 = ''; d83 = ''; d84 = ''; d85 = ''; d86 = ''; d87 = ''; d88 = ''; d89 = '';
			d90 = ''; d91 = ''; d92 = ''; d93 = ''; d94 = ''; d95 = ''; d96 = ''; d97 = ''; d98 = ''; d99 = '';
			d100 = ''; d101 = ''; d102 = ''; d103 = ''; d104 = ''; d105 = ''; d106 = ''; d107 = ''; d108 = ''; d109 = '';
			d110 = ''; d111 = ''; d112 = ''; d113 = ''; d114 = ''; d115 = ''; d116 = ''; d117 = ''; d118 = ''; d119 = '';
			d120 = ''; d121 = ''; d122 = ''; d123 = ''; d124 = ''; d125 = ''; d126 = ''; d127 = ''; d128 = ''; d129 = '';
			d130 = ''; d131 = ''; d132 = ''; d133 = ''; d134 = ''; d135 = ''; d136 = ''; d137 = ''; d138 = ''; d139 = '';
			d140 = ''; d141 = ''; d142 = ''; d143 = ''; d144 = ''; d145 = ''; d146 = ''; d147 = ''; d148 = ''; d149 = '';
			d150 = ''; d151 = ''; d152 = ''; d153 = ''; d154 = ''; d155 = ''; d156 = ''; d157 = ''; d158 = ''; d159 = '';
			d160 = ''; d161 = ''; d162 = ''; d163 = ''; d164 = ''; d165 = ''; d166 = ''; d167 = ''; d168 = ''; d169 = '';
			d170 = ''; d171 = ''; d172 = ''; d173 = ''; d174 = ''; d175 = ''; d176 = ''; d177 = ''; d178 = ''; d179 = '';
			d180 = ''; d181 = ''; d182 = ''; d183 = ''; 

			rank_d1 = ''; rank_d2 = ''; rank_d3 = ''; rank_d4 = ''; rank_d5 = ''; rank_d6 = ''; rank_d7 = ''; rank_d8 = ''; rank_d9 = '';
			rank_d10 = ''; rank_d11 = ''; rank_d12 = ''; rank_d13 = ''; rank_d14 = ''; rank_d15 = ''; rank_d16 = ''; rank_d17 = ''; rank_d18 = ''; rank_d19 = '';
			rank_d20 = ''; rank_d21 = ''; rank_d22 = ''; rank_d23 = ''; rank_d24 = ''; rank_d25 = ''; rank_d26 = ''; rank_d27 = ''; rank_d28 = ''; rank_d29 = '';
			rank_d30 = ''; rank_d31 = ''; rank_d32 = ''; rank_d33 = ''; rank_d34 = ''; rank_d35 = ''; rank_d36 = ''; rank_d37 = ''; rank_d38 = ''; rank_d39 = '';
			rank_d40 = ''; rank_d41 = ''; rank_d42 = ''; rank_d43 = ''; rank_d44 = ''; rank_d45 = ''; rank_d46 = ''; rank_d47 = ''; rank_d48 = ''; rank_d49 = '';
			rank_d50 = ''; rank_d51 = ''; rank_d52 = ''; rank_d53 = ''; rank_d54 = ''; rank_d55 = ''; rank_d56 = ''; rank_d57 = ''; rank_d58 = ''; rank_d59 = '';
			rank_d60 = ''; rank_d61 = ''; rank_d62 = ''; rank_d63 = ''; rank_d64 = ''; rank_d65 = ''; rank_d66 = ''; rank_d67 = ''; rank_d68 = ''; rank_d69 = '';
			rank_d70 = ''; rank_d71 = ''; rank_d72 = ''; rank_d73 = ''; rank_d74 = ''; rank_d75 = ''; rank_d76 = ''; rank_d77 = ''; rank_d78 = ''; rank_d79 = '';
			rank_d80 = ''; rank_d81 = ''; rank_d82 = ''; rank_d83 = ''; rank_d84 = ''; rank_d85 = ''; rank_d86 = ''; rank_d87 = ''; rank_d88 = ''; rank_d89 = '';
			rank_d90 = ''; rank_d91 = ''; rank_d92 = ''; rank_d93 = ''; rank_d94 = ''; rank_d95 = ''; rank_d96 = ''; rank_d97 = ''; rank_d98 = ''; rank_d99 = '';
			rank_d100 = ''; rank_d101 = ''; rank_d102 = ''; rank_d103 = ''; rank_d104 = ''; rank_d105 = ''; rank_d106 = ''; rank_d107 = ''; rank_d108 = ''; rank_d109 = '';
			rank_d110 = ''; rank_d111 = ''; rank_d112 = ''; rank_d113 = ''; rank_d114 = ''; rank_d115 = ''; rank_d116 = ''; rank_d117 = ''; rank_d118 = ''; rank_d119 = '';
			rank_d120 = ''; rank_d121 = ''; rank_d122 = ''; rank_d123 = ''; rank_d124 = ''; rank_d125 = ''; rank_d126 = ''; rank_d127 = ''; rank_d128 = ''; rank_d129 = '';
			rank_d130 = ''; rank_d131 = ''; rank_d132 = ''; rank_d133 = ''; rank_d134 = ''; rank_d135 = ''; rank_d136 = ''; rank_d137 = ''; rank_d138 = ''; rank_d139 = '';
			rank_d140 = ''; rank_d141 = ''; rank_d142 = ''; rank_d143 = ''; rank_d144 = ''; rank_d145 = ''; rank_d146 = ''; rank_d147 = ''; rank_d148 = ''; rank_d149 = '';
			rank_d150 = ''; rank_d151 = ''; rank_d152 = ''; rank_d153 = ''; rank_d154 = ''; rank_d155 = ''; rank_d156 = ''; rank_d157 = ''; rank_d158 = ''; rank_d159 = '';
			rank_d160 = ''; rank_d161 = ''; rank_d162 = ''; rank_d163 = ''; rank_d164 = ''; rank_d165 = ''; rank_d166 = ''; rank_d167 = ''; rank_d168 = ''; rank_d169 = '';
			rank_d170 = ''; rank_d171 = ''; rank_d172 = ''; rank_d173 = ''; rank_d174 = ''; rank_d175 = ''; rank_d176 = ''; rank_d177 = ''; rank_d178 = ''; rank_d179 = '';
			rank_d180 = ''; rank_d181 = ''; rank_d182 = ''; rank_d183 = ''; 


			rank2 = ''; label2_2 = ''; provider_name2 = '';
		end;

		epi_length = ep_end - ep_beg;
		if dod ^= . then do;
			epi_death = dod - ep_beg;
		end;
		else do;
			epi_death = 999;
		end;
		date_num_start = (start_date - ep_beg);
		date_num_end = min((end_date - ep_beg),epi_length);
		
		array d(*) d1-d184 ; 
		array rank_d(*) rank_d1-rank_d184 ;
		 
		do i=1 to 184;
			if date_num_start <= i-1 <= date_num_end then do;
				if d{i} = '' then d{i} =  strip(strip(label2)||": "||strip(provider_name_use));
				if rank_d{i}= '' then rank_d{i}=rank;

				else if d{i} ^= '' then do;
					if rank2 = '3' and rank = '4' then do;
						d{i} = strip(strip(label2_2)||" & "||strip(label2)||": "||strip(provider_name2)||", "||strip(provider_name_use));
						rank_use = '3.5';
						rank_d{i} = '3.5';
					end;
				end;
			end;
			else if i-1 >= epi_death then do;
				if d{i} = '' then d{i} = 'Deceased';
				rank_use = '6';
				rank_d{i} = '6';
			end;
		end;


		rank2 = rank;
		provider_name2 = provider_name_use;
		label2_2 = label2;
		if rank_use = '' then rank_use = rank;

	if last.ep_id2 then output;

	run;


%end;

%mend claims;

*************************************************************************************************************;
***************************************** END CLAIMS PROCESSING *********************************************;
*************************************************************************************************************;


*----------- Main interface claims files -----------*;
%claims(255,50179,'MSMC Oncology LLC', interface);
%claims(257,50195,'Cancer Center of East Alabama', interface);
%claims(480,50185,'Peninsula Cancer Institute LLC', interface);
%claims(396,50258,'GHS DBA University Medical Group', interface);
%claims(278,50193,'Upstate Oncology Associates', interface);
%claims(290,50202,'BSHSI St. Francis Medical Center', interface);
%claims(523,50330,'Memorial Cancer Institute', interface);
%claims(280,50115,'Warren Clinic Saint Francis Cancer Center', interface);
%claims(401,50228,'Mountain States Regional Cancer Center', interface);
%claims(468,50227,'Johnson City Regional Cancer Center', interface);
%claims(459,50243,'University Hospitals Medical Group', interface);
%claims(137,50136,'Regional Cancer Care Associates', interface);


/**----------- Emerge claims files -----------*;*/
/*%claims(255,50179,'MSMC Oncology LLC', emerge);*/
/*%claims(257,50195,'Cancer Center of East Alabama', emerge);*/
/*%claims(480,50185,'Peninsula Cancer Institute LLC', emerge);*/
/*%claims(396,50258,'GHS DBA University Medical Group', emerge);*/
/*%claims(278,50193,'Upstate Oncology Associates', emerge);*/
/*%claims(290,50202,'BSHSI St. Francis Medical Center', emerge);*/
/*%claims(523,50330,'Memorial Cancer Institute', emerge);*/
/*%claims(280,50115,'Warren Clinic Saint Francis Cancer Center', emerge);*/
/*%claims(401,50228,'Mountain States Regional Cancer Center', emerge);*/
/*%claims(468,50227,'Johnson City Regional Cancer Center', emerge);*/
/*%claims(459,50243,'University Hospitals Medical Group', emerge);*/
/*%claims(137,50136,'Regional Cancer Care Associates', emerge);*/
/**/
/**----------- MEOS claims files -----------*;*/
/*%claims(255,50179,'MSMC Oncology LLC', MEOS);*/
/*%claims(257,50195,'Cancer Center of East Alabama', MEOS);*/
/*%claims(480,50185,'Peninsula Cancer Institute LLC', MEOS);*/
/*%claims(396,50258,'GHS DBA University Medical Group', MEOS);*/
/*%claims(278,50193,'Upstate Oncology Associates', MEOS);*/
/*%claims(290,50202,'BSHSI St. Francis Medical Center', MEOS);*/
/*%claims(523,50330,'Memorial Cancer Institute', MEOS);*/
/*%claims(280,50115,'Warren Clinic Saint Francis Cancer Center', MEOS);*/
/*%claims(401,50228,'Mountain States Regional Cancer Center', MEOS);*/
/*%claims(468,50227,'Johnson City Regional Cancer Center', MEOS);*/
/*%claims(459,50243,'University Hospitals Medical Group', MEOS);*/
/*%claims(137,50136,'Regional Cancer Care Associates', MEOS);*/



*112,50203,'Baystate Regional Cancer Program' removed 2/5/2018
567,50200,'St. Marys Hospital' and
568,50201,'Memorial Regional Medical Center' merged into 290 and removed 2/5/2018;



**	Stack all datasets and output	**;
/*data out.episode_detail_combined;*/
/*	length OCM_NAME $255;*/
/*	set out.epi_detail_combined_&set_name: (drop=ep_id EPI_TIN_MATCH);*/
/*run;*/

%macro claimsoutput(report,report2,report3);

data  out.claims_detail_&report2.;
	length OCM_NAME $255 ;
	set out.clm_detail_&report._&set_name:(in=a drop=ep_id)
		%if &report2. = interf_em %then %do;
			out.clm_detail_&report3._&set_name:(in=b drop=ep_id)
			out.clm_detail_&report._&set_name_base:(in=c drop=ep_id);

if a then file="&report.";
if b then file="&report3.";
if c then file="&report."

		%end;
		;
run;

%if &report. = interface %then %do;

data  out.patient_journey_&report.;
	length OCM_NAME $255;
	set out.patjourney_&report._&set_name:
		out.patjourney_&report._&set_name_base:;
run;

data  out.util_filter_&report.;
	set	out.util_filter_&report._&set_name:
		out.util_filter_&report._&set_name_base:;
run;

%end;

%mend claimsoutput;


*Claims Output*;
/*%claimsoutput(interface, interf_em, emerge);*/
/*%claimsoutput(MEOS,MEOS,MEOS);*/


**Demo Output**;
**De-identify demos in SAS instead of QVW as of 201902 posting**;
data episode_detail_combined_demo;
	length OCM_NAME $255 ;
	set out.epi_detail_combined_&set_name._255 (drop=ep_id EPI_TIN_MATCH)
		out.epi_detail_combined_&set_name._480 (drop=ep_id EPI_TIN_MATCH)
		out.epi_detail_combined_&set_name._278 (drop=ep_id EPI_TIN_MATCH)
		;
		HIC_NUMBER_DEMO = '999999999X';
run;

data out.episode_detail_combined_demo;
	set episode_detail_combined_demo (rename=(EP_BEG=EP_BEG0 EP_BEG_prior=EP_BEG_prior0
											 EP_END=EP_END0 EP_END_prior=EP_END_prior0
											 ANCHOR_YEAR=ANCHOR_YEAR0 
											 ANCHOR_QUARTER=ANCHOR_QUARTER0 
											 ANCHOR_MONTH=ANCHOR_MONTH0
											 EP_END_YEAR=EP_END_YEAR0
											 EP_END_QUARTER=EP_END_QUARTER0
											 EP_END_MONTH=EP_END_MONTH0
											 PERFORMANCE_QUARTER=PERFORMANCE_QUARTER0
											 CHEMO_DATE = CHEMO_DATE0
											 DOB=DOB0
											 DOD=DOD0
											 REC_EP_END = REC_EP_END0	
											 OCM_ID=OCM_ID0
				  							 OCM_NAME=OCM_NAME0
											 DUAL_PTD_LIS_USE=DUAL_PTD_LIS_USE0
											 JOIN_VAR=JOIN_VAR0	
											 REC_OCM_ID=REC_OCM_ID0  
																				));

	**Randomly change the episode start date by a value in -30 to +30 days**;
	**Change the episode year to a year not covered by the models**;
	**Apply to all dates of service**;
	format EP_BEG EP_END DOB DOD REC_EP_END mmddyy10. 
		   ANCHOR_YEAR ANCHOR_QUARTER ANCHOR_MONTH EP_END_YEAR EP_END_QUARTER EP_END_MONTH 
		   EMERGING_QUARTER PERFORMANCE_QUARTER $19.
		   SEX DUAL_PTD_LIS_USE

		   ;
	EP_BEG = intnx('year',intnx('day', EP_BEG0, floor(ranuni(7)*60)),10,'sameday');	

	increment = EP_BEG - EP_BEG0;

	%macro date(date);
		&date. = &date.0 + increment;
	%mend date;

	%date(EP_END);
	%date(CHEMO_DATE);
	%date(DOB);
	%date(DOD);
	%date(REC_EP_END);

    if MEOS_episode = 1 and main_episode ^= 1 and emerge_episode ^= 1 and recon_episode ^=1 and attrib_episode ^=1 then ANCHOR_YEAR = '';
        else ANCHOR_YEAR = put(year(ep_beg), 4.);
    if MEOS_episode = 1 and main_episode ^= 1 and emerge_episode ^= 1 and recon_episode ^=1 and attrib_episode ^=1 then ANCHOR_QUARTER = '';
        else ANCHOR_QUARTER = put(year(ep_beg), 4.)||' Q'||strip(qtr(ep_beg));
    if MEOS_episode = 1 and main_episode ^= 1 and emerge_episode ^= 1 and recon_episode ^=1 and attrib_episode ^=1 then ANCHOR_MONTH = '';
        else if month(ep_beg) < 10 then ANCHOR_MONTH = put(year(ep_beg), 4.)||' M0'||strip(month(ep_beg));
        else ANCHOR_MONTH = put(year(ep_beg), 4.)||' M'||strip(month(ep_beg));
    if main_episode = 1 then do;
        ANCHOR_YEAR = put(year(ep_beg), 4.);
        ANCHOR_QUARTER = put(year(ep_beg), 4.)||' Q'||strip(qtr(ep_beg));
        if month(ep_beg) < 10 then ANCHOR_MONTH = put(year(ep_beg), 4.)||' M0'||strip(month(ep_beg));
        else ANCHOR_MONTH = put(year(ep_beg), 4.)||' M'||strip(month(ep_beg));

        EP_END_YEAR = put(year(ep_end),4.);
        EP_END_QUARTER=put(year(ep_end),4.)||' Q'||strip(qtr(ep_end));
        if month(ep_end) < 10 then EP_END_MONTH = put(year(ep_end), 4.)||' M0'||strip(month(ep_end));
                else EP_END_MONTH = put(year(ep_end), 4.)||' M'||strip(month(ep_end));
    end;
    else do;
        ANCHOR_YEAR = '';
        ANCHOR_QUARTER = '';
        ANCHOR_MONTH = '';

        EP_END_YEAR = '';
        EP_END_QUARTER = '';
        EP_END_MONTH = '';
    end;

    if emerge_episode = 1 then do;
        EMERGING_QUARTER = put(year(ep_beg), 4.)||' Q'||strip(qtr(ep_beg));
    end;
    else do;
        EMERGING_QUARTER = '';
    end;

    if recon_episode = 1 then do;
        PERFORMANCE_QUARTER = put(year(ep_beg), 4.)||' Q'||strip(qtr(ep_beg));
    end;
    else do;
        PERFORMANCE_QUARTER = '';
    end;

	**Manually change the names/labels for the OCM practices**;
	if OCM_ID0 = '255' then do; OCM_ID = '111'; OCM_NAME = 'Practice 1 (OCM 111)'; end;
		else if OCM_ID0 = '480' then do;  OCM_ID = '222'; OCM_NAME = 'Practice 2 (OCM 222)'; end;
		else if OCM_ID0 = '278' then do; OCM_ID = '333'; OCM_NAME = 'Practice 3 (OCM 333)'; end;

	JOIN_VAR = OCM_ID || EPISODE_PERIOD;

	**Manually change the names/labels for the OCM practices**;
	if REC_OCM_ID0 = '255' then do; REC_OCM_ID = '111'; OCM_NAME = 'Practice 1 (OCM 111)'; end;
		else if REC_OCM_ID0 = '480' then do;  REC_OCM_ID = '222'; OCM_NAME = 'Practice 2 (OCM 222)'; end;
		else if REC_OCM_ID0 = '278' then do; REC_OCM_ID = '333'; OCM_NAME = 'Practice 3 (OCM 333)'; end;

	**Switch to show as single letter then scramble**;
	if DUAL_PTD_LIS_USE0 = 'Non-Dual' then DUAL_PTD_LIS_USE = 'A';
		else if DUAL_PTD_LIS_USE0 = 'Part D, no LIS' then DUAL_PTD_LIS_USE = 'B';
		else if DUAL_PTD_LIS_USE0 = 'No Part D' then DUAL_PTD_LIS_USE = 'C';
		else if DUAL_PTD_LIS_USE0 = 'Dual' then DUAL_PTD_LIS_USE = 'D';
		else if DUAL_PTD_LIS_USE0 = 'Part D, full dual, LIS' then DUAL_PTD_LIS_USE = 'E';
		else if DUAL_PTD_LIS_USE0 = 'Part D, not full dual, LIS' then DUAL_PTD_LIS_USE = 'F';
		else if DUAL_PTD_LIS_USE0 = 'N/A' then DUAL_PTD_LIS_USE = 'G';

run;


%macro demooutput(report,report2,report3);

data claims_detail_&report2._demo;
	length OCM_NAME $255 ;
	set out.clm_detail_&report._&set_name._255(in=a drop=ep_id)
		out.clm_detail_&report._&set_name._480(in=b drop=ep_id)
		out.clm_detail_&report._&set_name._278(in=c drop=ep_id)
	%if &report. = interface %then %do;
			out.clm_detail_&report3._&set_name._255(in=d drop=ep_id)
			out.clm_detail_&report3._&set_name._480(in=e drop=ep_id)
			out.clm_detail_&report3._&set_name._278(in=f drop=ep_id)
				out.clm_detail_&report._&set_name_base._255(in=g drop=ep_id)
				out.clm_detail_&report._&set_name_base._480(in=h drop=ep_id)
				out.clm_detail_&report._&set_name_base._278(in=i drop=ep_id);
		if a then file="&report.";
		if b then file="&report.";
		if c then file="&report.";
		if d then file="&report3.";
		if e then file="&report3.";
		if f then file="&report3.";
		if g then file="&report.";
		if h then file="&report.";
		if i then file="&report."
	%end;
		;
run;

%if &report. = interface %then %do;
	data  out.patient_journey_&report._demo;
		length OCM_NAME $255 ;
		set out.patjourney_&report._&set_name._255
			out.patjourney_&report._&set_name_base._255
			out.patjourney_&report._&set_name._480
			out.patjourney_&report._&set_name_base._480
			out.patjourney_&report._&set_name._278
			out.patjourney_&report._&set_name_base._278;
	run;

	data  out.util_filter_&report._demo;
		set out.util_filter_&report._&set_name._255
			out.util_filter_&report._&set_name_base._255
			out.util_filter_&report._&set_name._480
			out.util_filter_&report._&set_name_base._480
			out.util_filter_&report._&set_name._278
			out.util_filter_&report._&set_name_base._278
		;
	run;
%end;

%mend demooutput;


*Demo Output*;
/*%demooutput(interface, interf_em, emerge);*/
/*%demooutput(MEOS,MEOS,MEOS);*/

*main & emerge*;
proc sql;
	create table claims_demo_join as
	select a.*, b.EP_BEG, b.increment
	from claims_detail_interf_em_demo as A
	left join out.episode_detail_combined_demo as B
	on a.EP_ID2 = b.EP_ID_use;
quit;

data out.claims_detail_interf_em_demo;
	set claims_demo_join (rename = (START_DATE_USE=START_DATE_USE0
									END_DATE=END_DATE0
									ADMIT_DT=ADMIT_DT0
									DSCHRG_DT=DSCHRG_DT0	
									PART_D_SERVICE_DATE = PART_D_SERVICE_DATE0	));

	format START_DATE_USE END_DATE ADMIT_DT DSCHRG_DT PART_D_SERVICE_DATE mmddyy10.;

	%macro date(date);
		&date. = &date.0 + increment;
	%mend date;

	%date(START_DATE_USE);
	%date(END_DATE);
	%date(ADMIT_DT);
	%date(DSCHRG_DT);
	%date(PART_D_SERVICE_DATE);
run;

*MEOS*;
proc sql;
	create table claims_demo_join_meos as
	select a.*, b.EP_BEG, b.increment
	from claims_detail_MEOS_demo as A
	left join out.episode_detail_combined_demo as B
	on a.EP_ID2 = b.EP_ID_use;
quit;

data out.claims_detail_MEOS_demo;
	set claims_demo_join_meos (rename = (START_DATE_USE=START_DATE_USE0));

	format START_DATE_USE mmddyy10.;

	%macro date(date);
		&date. = &date.0 + increment;
	%mend date;

	%date(START_DATE_USE);
run;


***SPLIT INTO PREMIER AND NON-PREMIER***;

%MACRO SPLIT(file, claimfile);

data out.&file.&claimfile._pmr
	 out.&file.&claimfile._other;
	 %if &file. = episode_detail %then %do;
		 set out.episode_detail_combined;
	 %end;
	 %else %do;
		 set out.&file.&claimfile.;
	 %end;

	 if OCM_ID not in &other_flag. then output out.&file.&claimfile._pmr;
	 else output out.&file.&claimfile._other;

run;

%MEND SPLIT;

/*%SPLIT(episode_detail,);*/
/*%SPLIT(claims_detail,_interf_em);*/
/*%SPLIT(claims_detail,_MEOS);*/

%MACRO SPLIT2(file, outfile, claimfile);

data out.&file.&claimfile._pmr;
	set 	out.&outfile._interface_&set_name._255
			out.&outfile._interface_&set_name_base._255
			out.&outfile._interface_&set_name._257
			out.&outfile._interface_&set_name_base._257
			out.&outfile._interface_&set_name._480
			out.&outfile._interface_&set_name_base._480
	 		out.&outfile._interface_&set_name._278
			out.&outfile._interface_&set_name_base._278
			out.&outfile._interface_&set_name._290
			out.&outfile._interface_&set_name_base._290
			out.&outfile._interface_&set_name._523
			out.&outfile._interface_&set_name_base._523
	 		out.&outfile._interface_&set_name._280
			out.&outfile._interface_&set_name_base._280
			out.&outfile._interface_&set_name._401
			out.&outfile._interface_&set_name_base._401
			out.&outfile._interface_&set_name._468
			out.&outfile._interface_&set_name_base._468
			out.&outfile._interface_&set_name._459
			out.&outfile._interface_&set_name_base._459	;
run;

data out.&file.&claimfile._other;
	set 	out.&outfile._interface_&set_name._396
			out.&outfile._interface_&set_name_base._396
			out.&outfile._interface_&set_name._137
			out.&outfile._interface_&set_name_base._137	;
run;

%MEND SPLIT2;

/*%SPLIT2(patient_journey, patjourney, _interface);*/
/*%SPLIT2(util_filter, util_filter, _interface);*/

/***MAIN**;*/
/***Milliman**;*/
/*%sas_2_csv(out.episode_detail_other,episode_detail_combined_other.csv);*/
/*%sas_2_csv(out.claims_detail_interf_em_other,claims_detail_interf_em_other.csv);*/
/*%sas_2_csv(out.claims_detail_MEOS_other,claims_detail_MEOS_other.csv);*/
/*%sas_2_csv(out.patient_journey_interface_other,patient_journey_interface_other.csv);*/
/*%sas_2_csv(out.util_filter_interface_other,util_filter_interface_other.csv);*/
/**/
/***Premier**;*/
/*%sas_2_csv(out.episode_detail_pmr,episode_detail_combined_premier.csv);*/
/*%sas_2_csv(out.claims_detail_interf_em_pmr,claims_detail_interf_em_premier.csv);*/
/*%sas_2_csv(out.claims_detail_MEOS_pmr,claims_detail_MEOS_premier.csv);*/
/*%sas_2_csv(out.patient_journey_interface_pmr,patient_journey_interface_premier.csv);*/
/*%sas_2_csv(out.util_filter_interface_pmr,util_filter_interface_premier.csv);*/
/**/
/***Combined**;*/
/*%sas_2_csv(out.episode_detail_combined,episode_detail_combined.csv);*/
/*%sas_2_csv(out.claims_detail_interf_em,claims_detail_interf_em.csv);*/
/*%sas_2_csv(out.claims_detail_MEOS,claims_detail_MEOS.csv);*/
/*%sas_2_csv(out.patient_journey_interface,patient_journey_interface.csv);*/
/*%sas_2_csv(out.util_filter_interface,util_filter_interface.csv);*/
/**/
/***DEMO**;*/
/***Save demo files**;*/
/*%sas_2_csv(out.episode_detail_combined_demo,episode_detail_combined_demo.csv);*/
/*%sas_2_csv(out.claims_detail_interf_em_demo,claims_detail_interf_em_demo.csv);*/
/*%sas_2_csv(out.claims_detail_MEOS_demo,claims_detail_MEOS_demo.csv);*/
/*%sas_2_csv(out.patient_journey_interface_demo,patient_journey_interface_demo.csv);*/
/*%sas_2_csv(out.util_filter_interface_demo,util_filter_interface_demo.csv);*/
