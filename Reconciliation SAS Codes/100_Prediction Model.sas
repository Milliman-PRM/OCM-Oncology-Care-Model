/*proc printto log="H:\OCM - Oncology Care Model\44 - Oncology Care Model 2018\Work Papers\SAS\Reconciliation Programs\Logs\100 Prediction Model" print=print new;*/
/*run;*/

********************************************************** ;
********************************************************** ;
**** Program: 100_Prediction Model     ******************* ;
**** Programmer: Harsha Mirchandani    ******************* ;
**** Checker: Daniel Muldoon           ******************* ;
**** Project: OCM Reconciliation       ******************* ;
**** Billing Code: 0299PRM01-44        ******************* ;
********************************************************** ;
********************************************************** ;

libname in1 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP1';
libname in2 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP2';
libname in3 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP3';
libname out 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\80 - QlikView\Qlik_Sasout';

%include "H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\SAS\Reconciliation Programs\000_Prediction Model Coefficients.sas";

%let label = recon; ** base = baseline, recon = reconciliation **;
%let version = calc; ** check = checking to make sure our baseline prices are the same as CMS' baseline prices,
						calc = calculate baseline price for interface **;

options ls=132 ps=70 obs = max mlogic mprint;

** Import Trend Factors **;
proc import datafile="R:\data\HIPAA\OCM_Oncology_Care_Model_PP\09 - Reconciliation Reports\PP1 True-up 2\Trend Factors.csv"
     out=Trend_Factors_PP1
     dbms=csv
     replace;
     getnames=yes;
run;

proc import datafile="R:\data\HIPAA\OCM_Oncology_Care_Model_PP\09 - Reconciliation Reports\PP2 True-up 1\Trend Factors.csv"
     out=Trend_Factors_PP2
     dbms=csv
     replace;
     getnames=yes;
run;

proc import datafile="R:\data\HIPAA\OCM_Oncology_Care_Model_PP\09 - Reconciliation Reports\PP3\Trend Factors.csv"
     out=Trend_Factors_PP3
     dbms=csv
     replace;
     getnames=yes;
run;

%MACRO TARGET(OCMID, OCMID2, fdate, path, dlm, recperiod);

data OCM_&OCMID._age_gender;
	set 
		%if &recperiod. = PP1 %then %do;
			in1.Recon2_interface_p1r2_&OCMID._&OCMID2. ;
		%end;
		%else %if &recperiod. = PP2 %then %do;
			in2.Recon1_interface_p2r1_&OCMID._&OCMID2. ;
		%end;
		%else %if &recperiod. = PP3 %then %do;
			in3.Recon0_interface_p3r0_&OCMID._&OCMID2. ;
		%end;

	if SEX = 1 then do;
		if 18 <= AGE <= 64 then male_age_18_64 = 1;
			else if 65 <= AGE <= 69 then male_age_65_69 = 1;
			else if 70 <= AGE <= 74 then male_age_70_74 = 1;
			else if 75 <= AGE <= 79 then male_age_75_79 = 1;
			else if AGE >= 80 then male_age_80 = 1;
		end;
	else if SEX = 2 then do;
		if 18 <= AGE <= 64 then female_age_18_64 = 1;
			else if 65 <= AGE <= 69 then female_age_65_69 = 1;
			else if 70 <= AGE <= 74 then female_age_70_74 = 1;
			else if 75 <= AGE <= 79 then female_age_75_79 = 1;
			else if AGE >= 80 then female_age_80 = 1;
		end;
run;

data OCM_&OCMID._cancer_surgery;
	set OCM_&OCMID._age_gender;
	%if &version. = check %then %do;

		** cancer/surgery type **;
		if SURGERY = 0 then do;

				if CANCER_TYPE in ('Bladder Cancer', 'Bladder Cancer - High Risk', 'Bladder Cancer - Low Risk') then do;
					%if &PP. = P3 %then %do;
						if LOW_RISK_BLAD = 0 then bladder_without_surg_hi_risk = 1;
						if LOW_RISK_BLAD = 1 then bladder_without_surg_lo_risk = 1;
					%end;
				 	%else %if &PP. = P1_2 %then %do;
						bladder_without_surg = 1;
					%end;
				end;

				%if &label. = recon %then %do;
					if CANCER_TYPE = 'Small Intestine / Colorectal Cancer' then intestinal_without_surg = 1;
				%end;
				%else %do;
					if CANCER_TYPE = 'Intestinal' then intestinal_without_surg = 1;
				%end;

				else if CANCER_TYPE in ('Breast Cancer', 'Breast Cancer - High Risk', 'Breast Cancer - Low Risk') then do;
						if PTD_CHEMO = 0 then breast_part_b_without_surg = 1;
						if PTD_CHEMO = 1 then breast_part_d_only_without_surg = 1;
				end;

				else if CANCER_TYPE = 'Gastro/Esophageal Cancer' then gastro_without_surg = 1;
				else if CANCER_TYPE = 'Liver Cancer' then liver_without_surg = 1;
				else if CANCER_TYPE = 'Lung Cancer' then lung_without_surg = 1;
				else if CANCER_TYPE = 'Ovarian Cancer' then ovary_without_surg = 1;
				else if CANCER_TYPE = 'Female GU Cancer other than Ovary' then female_gu_without_surg = 1;
				else if CANCER_TYPE = 'Pancreatic Cancer' then pancreas_without_surg = 1;

				if CANCER_TYPE in ('Prostate Cancer', 'Prostate Cancer - High Intensity', 'Prostate Cancer - Low Intensity') then do;
					%if &PP. = P3 %then %do;
						if CAST_SENS_PROS = 0 then prostate_without_surg_res = 1;
						if CAST_SENS_PROS = 1 then prostate_without_surg_sens = 1;
					%end;
					%else %if &PP. = P1_2 %then %do;
					 	prostate_without_surg = 1;
					%end;
				end;

				if CANCER_TYPE = 'Head and Neck Cancer' then head_neck_without_surg = 1;
				else if CANCER_TYPE = 'Anal Cancer' then anal_without_surg = 1;

				**not eligible for surgery in PP1-2**;
				**for variable consistency**;

				if CANCER_TYPE = 'Kidney Cancer' then do;
					%if &PP. = P3 %then %do;
						kidney_without_surg = 1;
					%end;
					%else %if &PP. = P1_2 %then %do;
						if CANCER_TYPE = 'Kidney Cancer' then kidney = 1;
					%end;
				end;

				**not eligible for surgery at all**;
				if CANCER_TYPE = 'CNS Tumor' then CNS = 1;
				else if CANCER_TYPE = 'Chronic Leukemia' then chronic_leukemia = 1;
				else if CANCER_TYPE = 'Acute Leukemia' then acute_leukemia = 1;
				else if CANCER_TYPE = 'Lymphoma' then lymphoma = 1;
				else if CANCER_TYPE = 'Multiple Myeloma' then myeloma = 1;
				else if CANCER_TYPE = 'MDS' then MDS = 1;
				else if CANCER_TYPE = 'Endocrine Tumor' then endocrine = 1;
				else if CANCER_TYPE = 'Malignant Melanoma' then melanoma = 1;
		end;
		else if SURGERY = 1 then do;

				if CANCER_TYPE in ('Bladder Cancer', 'Bladder Cancer - High Risk', 'Bladder Cancer - Low Risk') then do;
					%if &PP. = P3 %then %do;
						if LOW_RISK_BLAD = 0 then bladder_with_surg_hi_risk = 1;
						if LOW_RISK_BLAD = 1 then bladder_with_surg_lo_risk = 1;
					%end;
				 	%else %if &PP. = P1_2 %then %do;
						bladder_with_surg = 1;
					%end;
				end;

				%if &label. = recon %then %do;
					if CANCER_TYPE = 'Small Intestine / Colorectal Cancer' then intestinal_with_surg = 1;
				%end;
				%else %do;
					if CANCER_TYPE = 'Intestinal' then intestinal_with_surg = 1;
				%end;

				else if CANCER_TYPE in ('Breast Cancer', 'Breast Cancer - High Risk', 'Breast Cancer - Low Risk') then do;
						if PTD_CHEMO = 0 then breast_part_b_with_surg = 1;
						if PTD_CHEMO = 1 then breast_part_d_only_with_surg = 1;
				end;

				else if CANCER_TYPE = 'Gastro/Esophageal Cancer' then gastro_with_surg = 1;
				else if CANCER_TYPE = 'Liver Cancer' then liver_with_surg = 1;
				else if CANCER_TYPE = 'Lung Cancer' then lung_with_surg = 1;
				else if CANCER_TYPE = 'Ovarian Cancer' then ovary_with_surg = 1;
				else if CANCER_TYPE = 'Female GU Cancer other than Ovary' then female_gu_with_surg = 1;
				else if CANCER_TYPE = 'Pancreatic Cancer' then pancreas_with_surg = 1;

				if CANCER_TYPE in ('Prostate Cancer', 'Prostate Cancer - High Intensity', 'Prostate Cancer - Low Intensity') then do;
					%if &PP. = P3 %then %do;
						if CAST_SENS_PROS = 0 then prostate_with_surg_res = 1;
						if CAST_SENS_PROS = 1 then prostate_with_surg_sens = 1;
					%end;
					%else %if &PP. = P1_2 %then %do;
					 	prostate_with_surg = 1;
					%end;
				end;

				if CANCER_TYPE = 'Head and Neck Cancer' then head_neck_with_surg = 1;
				else if CANCER_TYPE = 'Anal Cancer' then anal_with_surg = 1;

				if CANCER_TYPE = 'Kidney Cancer' then do;
					%if &PP. = P3 %then %do;
						kidney_with_surg = 1;
					%end;
				end;
		end;

	%end;
	%else %do;
			** cancer/surgery type **;
		if SURGERY_MILLIMAN = 0 then do;

				if CANCER_TYPE_MILLIMAN in ('Bladder Cancer', 'Bladder Cancer - High Risk', 'Bladder Cancer - Low Risk') then do;
					%if &PP. = P3 %then %do;
						if LOW_RISK_BLAD_MILLIMAN = 0 then bladder_without_surg_hi_risk = 1;
						if LOW_RISK_BLAD_MILLIMAN = 1 then bladder_without_surg_lo_risk = 1;
					%end;
				 	%else %if &PP. = P1_2 %then %do;
						bladder_without_surg = 1;
					%end;
				end;

				%if &label. = recon %then %do;
					if CANCER_TYPE_MILLIMAN = 'Small Intestine / Colorectal Cancer' then intestinal_without_surg = 1;
				%end;
				%else %do;
					if CANCER_TYPE_MILLIMAN = 'Intestinal' then intestinal_without_surg = 1;
				%end;

				else if CANCER_TYPE_MILLIMAN in ('Breast Cancer', 'Breast Cancer - High Risk', 'Breast Cancer - Low Risk') then do;
						if PTD_CHEMO_MILLIMAN = 0 then breast_part_b_without_surg = 1;
						if PTD_CHEMO_MILLIMAN = 1 then breast_part_d_only_without_surg = 1;
				end;

				else if CANCER_TYPE_MILLIMAN = 'Gastro/Esophageal Cancer' then gastro_without_surg = 1;
				else if CANCER_TYPE_MILLIMAN = 'Liver Cancer' then liver_without_surg = 1;
				else if CANCER_TYPE_MILLIMAN = 'Lung Cancer' then lung_without_surg = 1;
				else if CANCER_TYPE_MILLIMAN = 'Ovarian Cancer' then ovary_without_surg = 1;
				else if CANCER_TYPE_MILLIMAN = 'Female GU Cancer other than Ovary' then female_gu_without_surg = 1;
				else if CANCER_TYPE_MILLIMAN = 'Pancreatic Cancer' then pancreas_without_surg = 1;

				if CANCER_TYPE_MILLIMAN in ('Prostate Cancer', 'Prostate Cancer - High Intensity', 'Prostate Cancer - Low Intensity') then do;
					%if &PP. = P3 %then %do;
						if CAST_SENS_PROS_MILLIMAN = 0 then prostate_without_surg_res = 1;
						if CAST_SENS_PROS_MILLIMAN = 1 then prostate_without_surg_sens = 1;
					%end;
					%else %if &PP. = P1_2 %then %do;
					 	prostate_without_surg = 1;
					%end;
				end;

				if CANCER_TYPE_MILLIMAN = 'Head and Neck Cancer' then head_neck_without_surg = 1;
				else if CANCER_TYPE_MILLIMAN = 'Anal Cancer' then anal_without_surg = 1;

				**not eligible for surgery in PP1-2**;
				**for variable consistency**;

				if CANCER_TYPE_MILLIMAN = 'Kidney Cancer' then do;
					%if &PP. = P3 %then %do;
						kidney_without_surg = 1;
					%end;
					%else %if &PP. = P1_2 %then %do;
						if CANCER_TYPE_MILLIMAN = 'Kidney Cancer' then kidney = 1;
					%end;
				end;

				**not eligible for surgery at all**;
				if CANCER_TYPE_MILLIMAN = 'CNS Tumor' then CNS = 1;
				else if CANCER_TYPE_MILLIMAN = 'Chronic Leukemia' then chronic_leukemia = 1;
				else if CANCER_TYPE_MILLIMAN = 'Acute Leukemia' then acute_leukemia = 1;
				else if CANCER_TYPE_MILLIMAN = 'Lymphoma' then lymphoma = 1;
				else if CANCER_TYPE_MILLIMAN = 'Multiple Myeloma' then myeloma = 1;
				else if CANCER_TYPE_MILLIMAN = 'MDS' then MDS = 1;
				else if CANCER_TYPE_MILLIMAN = 'Endocrine Tumor' then endocrine = 1;
				else if CANCER_TYPE_MILLIMAN = 'Malignant Melanoma' then melanoma = 1;
		end;
		else if SURGERY_MILLIMAN = 1 then do;

				if CANCER_TYPE_MILLIMAN in ('Bladder Cancer', 'Bladder Cancer - High Risk', 'Bladder Cancer - Low Risk') then do;
					%if &PP. = P3 %then %do;
						if LOW_RISK_BLAD_MILLIMAN = 0 then bladder_with_surg_hi_risk = 1;
						if LOW_RISK_BLAD_MILLIMAN = 1 then bladder_with_surg_lo_risk = 1;
					%end;
				 	%else %if &PP. = P1_2 %then %do;
						bladder_with_surg = 1;
					%end;
				end;

				%if &label. = recon %then %do;
					if CANCER_TYPE_MILLIMAN = 'Small Intestine / Colorectal Cancer' then intestinal_with_surg = 1;
				%end;
				%else %do;
					if CANCER_TYPE_MILLIMAN = 'Intestinal' then intestinal_with_surg = 1;
				%end;

				else if CANCER_TYPE_MILLIMAN in ('Breast Cancer', 'Breast Cancer - High Risk', 'Breast Cancer - Low Risk') then do;
						if PTD_CHEMO_MILLIMAN = 0 then breast_part_b_with_surg = 1;
						if PTD_CHEMO_MILLIMAN = 1 then breast_part_d_only_with_surg = 1;
				end;

				else if CANCER_TYPE_MILLIMAN = 'Gastro/Esophageal Cancer' then gastro_with_surg = 1;
				else if CANCER_TYPE_MILLIMAN = 'Liver Cancer' then liver_with_surg = 1;
				else if CANCER_TYPE_MILLIMAN = 'Lung Cancer' then lung_with_surg = 1;
				else if CANCER_TYPE_MILLIMAN = 'Ovarian Cancer' then ovary_with_surg = 1;
				else if CANCER_TYPE_MILLIMAN = 'Female GU Cancer other than Ovary' then female_gu_with_surg = 1;
				else if CANCER_TYPE_MILLIMAN = 'Pancreatic Cancer' then pancreas_with_surg = 1;

				if CANCER_TYPE_MILLIMAN in ('Prostate Cancer', 'Prostate Cancer - High Intensity', 'Prostate Cancer - Low Intensity') then do;
					%if &PP. = P3 %then %do;
						if CAST_SENS_PROS_MILLIMAN = 0 then prostate_with_surg_res = 1;
						if CAST_SENS_PROS_MILLIMAN = 1 then prostate_with_surg_sens = 1;
					%end;
					%else %if &PP. = P1_2 %then %do;
					 	prostate_with_surg = 1;
					%end;
				end;

				if CANCER_TYPE_MILLIMAN = 'Head and Neck Cancer' then head_neck_with_surg = 1;
				else if CANCER_TYPE_MILLIMAN = 'Anal Cancer' then anal_with_surg = 1;

				if CANCER_TYPE_MILLIMAN = 'Kidney Cancer' then do;
					%if &PP. = P3 %then %do;
						kidney_with_surg = 1;
					%end;
				end;

				**not eligible for surgery at all**;
				if CANCER_TYPE_MILLIMAN = 'CNS Tumor' then CNS = 1;
					else if CANCER_TYPE_MILLIMAN = 'Chronic Leukemia' then chronic_leukemia = 1;
					else if CANCER_TYPE_MILLIMAN = 'Acute Leukemia' then acute_leukemia = 1;
					else if CANCER_TYPE_MILLIMAN = 'Lymphoma' then lymphoma = 1;
					else if CANCER_TYPE_MILLIMAN = 'Multiple Myeloma' then myeloma = 1;
					else if CANCER_TYPE_MILLIMAN = 'MDS' then MDS = 1;
					else if CANCER_TYPE_MILLIMAN = 'Endocrine Tumor' then endocrine = 1;
					else if CANCER_TYPE_MILLIMAN = 'Malignant Melanoma' then melanoma = 1;
		end;

	%end;

run;

data OCM_&OCMID._BMT;
	set OCM_&OCMID._cancer_surgery;

	%if &version. = check %then %do;
		if BMT = 1 then bmt_autologous = 1;
			else if BMT = 2 then bmt_allogeneic = 1;
			else if BMT = 3 then bmt_allogeneic = 1;
	%end;
	%else %do;
		if BMT_MILLIMAN = 1 then bmt_autologous = 1;
			else if BMT_MILLIMAN = 2 then bmt_allogeneic = 1;
			else if BMT_MILLIMAN = 3 then bmt_allogeneic = 1;
	%end;

run;

data OCM_&OCMID._epi_length;
	set OCM_&OCMID._BMT;
	
	%if &PP. = P3 %then %do;
		if EP_LENGTH in (181 182) then ep_181_182 = 1;
			else if EP_LENGTH in (183 184) then ep_183_184 = 1;
	%end;
	%else %if &PP. = P1_2 %then %do;
		if EP_LENGTH in (181 182) then ep_180_181 = 1;
			else if EP_LENGTH in (183 184) then ep_182_183 = 1;
	%end;

run;

data OCM_&OCMID._clean_period;
	set OCM_&OCMID._epi_length;

	if CLEAN_PD = 1 then clean_1_61 = 1;
		else if CLEAN_PD = 2 then clean_62_730 = 1;
		else if CLEAN_PD = 3 then clean_731 = 1;

run;

data OCM_&OCMID._inst;
	set OCM_&OCMID._clean_period;

	if INST = 1 then institutional_status = 1;

run;

data OCM_&OCMID._enroll;
	set OCM_&OCMID._inst;

	if DUAL_PTD_LIS = 0 then no_part_d = 1;
		else if DUAL_PTD_LIS = 1 then part_d_no_lis = 1;
		else if DUAL_PTD_LIS = 2 then part_d_lis = 1;
		else if DUAL_PTD_LIS = 3 then full_dual = 1;
run;

data OCM_&OCMID._HCC;
	set OCM_&OCMID._enroll;

	if HCC_GRP = '00' then hcc_none = 1;
		else if HCC_GRP = '01' then hcc_1 = 1;
		else if HCC_GRP = '02' then hcc_2 = 1;
		else if HCC_GRP = '03' then hcc_3 = 1;
		else if HCC_GRP = '4-5' then hcc4_5 = 1;
		else if HCC_GRP = '6+' then hcc_6_or_more = 1;
		else if HCC_GRP = '98' then hcc_new = 1;
		else if HCC_GRP = '99' then hcc_none = 1;
	if HCC_GRP = '0' then hcc_none = 1;
		else if HCC_GRP = '1' then hcc_1 = 1;
		else if HCC_GRP = '2' then hcc_2 = 1;
		else if HCC_GRP = '3' then hcc_3 = 1;
		else if HCC_GRP = '5-Apr' then hcc4_5 = 1;
		else if HCC_GRP = '6+' then hcc_6_or_more = 1;
		else if HCC_GRP = '98' then hcc_new = 1;
		else if HCC_GRP = '99' then hcc_none = 1;

run;

data OCM_&OCMID._clinical_trial;
	set OCM_&OCMID._HCC;

	%if &version. = check %then %do;
		if CLINICAL_TRIAL = 1 then clinical_trial_milliman = 1;
		if CLINICAL_TRIAL = 0 then clinical_trial_milliman = 0;
	%end;
	%else %do;
		if CLINICAL_TRIAL_MILLIMAN = 1 then clinical_trial_milliman = 1;
	%end;

run;

data OCM_&OCMID._radiation;
	set OCM_&OCMID._clinical_trial;

	%if &version. = check %then %do;
		if RADIATION = 1 then radiation_milliman = 1;
		if RADIATION = 0 then radiation_milliman = 0;
	%end;
	%else %do;
		if RADIATION_MILLIMAN = 1 then radiation_milliman = 1;
	%end;
run;

**calculate baseline price**;
data OCM_&OCMID._baseline_price;
	set OCM_&OCMID._radiation;

	array change _numeric_;
        do over change;
            if change= . then change=0;
        end;

	exponent = 
		&&P&PP._Intercept. +

		(&&P&PP._male_age_18_64. * male_age_18_64) +
		(&&P&PP._male_age_65_69. * male_age_65_69) +
		(&&P&PP._male_age_70_74. * male_age_70_74) +
		(&&P&PP._male_age_75_79. * male_age_75_79) +
		(&&P&PP._male_age_80. * male_age_80) +

		(&&P&PP._female_age_18_64. * female_age_18_64) +
		(&&P&PP._female_age_70_74. * female_age_70_74) +
		(&&P&PP._female_age_75_79. * female_age_75_79) +
		(&&P&PP._female_age_80. * female_age_80) +

		%if &PP. = P3 %then %do;
			(&&P&PP._bladder_with_surg_lo_risk. * bladder_with_surg_lo_risk) +
			(&&P&PP._bladder_without_surg_lo_risk. * bladder_without_surg_lo_risk) +
			(&&P&PP._bladder_with_surg_hi_risk. * bladder_with_surg_hi_risk) +
			(&&P&PP._bladder_without_surg_hi_risk. * bladder_without_surg_hi_risk) +
		%end;
		%else %if &PP. = P1_2 %then %do;
			(&&P&PP._bladder_with_surg. * bladder_with_surg) +
			(&&P&PP._bladder_without_surg. * bladder_without_surg) +
		%end;

		(&&P&PP._intestinal_with_surg. * intestinal_with_surg) +
		(&&P&PP._intestinal_without_surg. * intestinal_without_surg) +

		(&&P&PP._breast_part_b_with_surg. * breast_part_b_with_surg) +
		(&&P&PP._breast_part_b_without_surg. * breast_part_b_without_surg) +

		(&&P&PP._breast_part_d_only_w_surg. * breast_part_d_only_with_surg) +

		(&&P&PP._gastro_with_surg. * gastro_with_surg) +
		(&&P&PP._gastro_without_surg. * gastro_without_surg) +

		(&&P&PP._liver_with_surg. * liver_with_surg) +
		(&&P&PP._liver_without_surg. * liver_without_surg) +

		(&&P&PP._lung_with_surg. * lung_with_surg) +
		(&&P&PP._lung_without_surg. * lung_without_surg) +

		(&&P&PP._ovary_with_surg. * ovary_with_surg) +
		(&&P&PP._ovary_without_surg. * ovary_without_surg) +

		(&&P&PP._female_gu_with_surg. * female_gu_with_surg) +
		(&&P&PP._female_gu_without_surg. * female_gu_without_surg) +

		(&&P&PP._pancreas_with_surg. * pancreas_with_surg) +
		(&&P&PP._pancreas_without_surg. * pancreas_without_surg) +

		%if &PP. = P3 %then %do;
			(&&P&PP._prostate_with_surg_sens. * prostate_with_surg_sens) +
			(&&P&PP._prostate_without_surg_sens. * prostate_without_surg_sens) +
			(&&P&PP._prostate_with_surg_res. * prostate_with_surg_res) +
			(&&P&PP._prostate_without_surg_res. * prostate_without_surg_res) +
		%end;
		%else %if &PP. = P1_2 %then %do;
			(&&P&PP._prostate_with_surg. * prostate_with_surg) +
			(&&P&PP._prostate_without_surg. * prostate_without_surg) +
		%end;

		(&&P&PP._head_neck_with_surg. * head_neck_with_surg) +
		(&&P&PP._head_neck_without_surg. * head_neck_without_surg) +

		(&&P&PP._anal_with_surg. * anal_with_surg) +
		(&&P&PP._anal_without_surg. * anal_without_surg) +

		%if &PP. = P3 %then %do;
			(&&P&PP._kidney_with_surg. * kidney_with_surg) +
			(&&P&PP._kidney_without_surg. * kidney_without_surg) +
		%end;
		%else %if &PP. = P1_2 %then %do;
			(&&P&PP._kidney. * kidney) +
		%end;

		(&&P&PP._CNS. * CNS) +
		(&&P&PP._chronic_leukemia. * chronic_leukemia) +
		(&&P&PP._acute_leukemia. * acute_leukemia) +
		(&&P&PP._lymphoma. * lymphoma) +
		(&&P&PP._myeloma. * myeloma) +
		(&&P&PP._MDS. * MDS) +
		(&&P&PP._endocrine. * endocrine) +
		(&&P&PP._melanoma. * melanoma) +

		(&&P&PP._bmt_allogeneic. * bmt_allogeneic) +
		(&&P&PP._bmt_autologous. * bmt_autologous) +

		%if &PP. = P3 %then %do;
			(&&P&PP._ep_183_184. * ep_183_184) +
		%end;
		%else %if &PP. = P1_2 %then %do;
			(&&P&PP._ep_182_183. * ep_182_183) +
		%end;

		(&&P&PP._clean_1_61. * clean_1_61) +
		(&&P&PP._clean_62_730. * clean_62_730) +

		(&&P&PP._institutional_status. * institutional_status) +

		(&&P&PP._full_dual. * full_dual) +
		(&&P&PP._part_d_lis. * part_d_lis) +
		(&&P&PP._part_d_no_lis. * part_d_no_lis) +

		(&&P&PP._new_enrollee. * hcc_new) +
		(&&P&PP._hcc_1. * hcc_1) +
		(&&P&PP._hcc_2. * hcc_2) +
		(&&P&PP._hcc_3. * hcc_3) +
		(&&P&PP._hcc4_5. * hcc4_5) +
		(&&P&PP._hcc6_or_more. * hcc_6_or_more) +

		(&&P&PP._clinical_trial. * clinical_trial_milliman) +

		(&&P&PP._radiation. * radiation_milliman) +

		(&&P&PP._hrr_relative_cost. * (HRR_REL_COST));

	format baseline_price_milliman difference dollar12.2;
	
	%if &label. = base %then %do;
		baseline_price_milliman = exp(exponent) * (0.5 + 0.5*EXPERIENCE_ADJ); ** THIS IS ROW D OF [TAB 2 - RECONCILIATION CALC] OF RECON REPORT **;
	%end;
	%else %do;
		baseline_price_milliman = exp(exponent) * (EXPERIENCE_ADJ); ** THIS IS ROW D OF [TAB 2 - RECONCILIATION CALC] OF RECON REPORT **;
	%end;

	difference = baseline_price_milliman - baseline_price;

run;

proc sql;
	create table check_difference_&OCMID._&recperiod. as 
		select &OCMID. as OCM_ID
			  %if &recperiod. = PP1 %then %do;
				 ,'PP1' as EPISODE_PERIOD
			  %end;
			  %else %if &recperiod. = PP2 %then %do;
				 ,'PP2' as EPISODE_PERIOD
			  %end;
			  %else %do;
				 ,'PP3' as EPISODE_PERIOD
			  %end;
			  ,count(*) as episodes
			  ,sum(difference) as total_diff
			  ,sum(abs(difference)) as abs_total_diff
			  from OCM_&OCMID._baseline_price
		where recon_elig = '1';
quit;

%if &label. = recon %then %do;
	proc sql;
		create table Price_Summary_OCM_&OCMID._&recperiod. as
			select &OCMID. as OCM_ID
				  %if &recperiod. = PP1 %then %do;
					 ,'PP1' as EPISODE_PERIOD
				  %end;
				  %else %if &recperiod. = PP2 %then %do;
					 ,'PP2' as EPISODE_PERIOD
				  %end;
				  %else %do;
					 ,'PP3' as EPISODE_PERIOD
				  %end;
				   ,TRIM(EP_ID_CMS) as EP_ID_CMS
				   ,CANCER_TYPE
				   ,baseline_price as baseline_price_cms
				   ,baseline_price_milliman /** ROW D OF [TAB 2 - RECONCILIATION CALC]**/
				   ,B.TREND /** ROW E OF [TAB 2 - RECONCILIATION CALC]**/
				   ,B.WIN_ADJ_NOVEL_THER
				   ,B.NOVEL_THER_ADJ
			from OCM_&OCMID._baseline_price as A
			left join Trend_Factors_&recperiod. as B
			on &OCMID. = B.OCMID
				where RECON_ELIG = '1';
	quit;
%end;

%MEND TARGET;

** Base **;
/*%TARGET(480, 50185, 20160804, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\01 - Baseline Data\V1\201608\OCM_480\OCM_480_50185_episodes_base_20160804.txt', '09'x);*/
/*%TARGET(396, 50258, 20161209, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\01 - Baseline Data\V1\201612\OCM_396\OCM_396_50258_episodes_base_20161209.txt', '7c'x);*/
/*%TARGET(257, 50195, 20160804, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\01 - Baseline Data\V1\201608\OCM_257\OCM_257_50195_episodes_base_20160804.txt', '7c'x);*/
/*%TARGET(255, 50179, 20160804, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\01 - Baseline Data\V1\201608\OCM_255\OCM_255_50179_episodes_base_20160804.txt', '7c'x);*/
/*%TARGET(278, 50193, 20160916, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\01 - Baseline Data\V1\201609\OCM_278\OCM_278_50193_episodes_base_20160916.txt', '7c'x);*/
/*%TARGET(290, 50202, 20161021, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\01 - Baseline Data\V1\201610\OCM_290\OCM_290_50202_episodes_base_20161021.txt', '7c'x);*/
/*%TARGET(523, 50330, 20160819, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\01 - Baseline Data\V1\201608\OCM_523\OCM_523_50330_episodes_base_20160819.txt', '7c'x);*/
/*%TARGET(280, 50115, 20170424, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\01 - Baseline Data\V2\201704-201707\OCM_280\OCM_280_50115_episodes_base_20170424.txt');*/
/*%TARGET(401, 50330, 20170424, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\01 - Baseline Data\V2\201704-201707\OCM_523\OCM_523_50330_episodes_base_20170424.txt');*/
/*%TARGET(468, 50227, 20160819, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\01 - Baseline Data\V1\201608\OCM_468\OCM_468_50227_episodes_base_20160819.txt', '7c'x);*/
/*%TARGET(459, 50243, 20160804, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\01 - Baseline Data\V1\201608\OCM_459\OCM_459_50243_episodes_base_20160804.txt', '7c'x);*/
/*%TARGET(137, 50136, 20160804, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\01 - Baseline Data\V1\201608\OCM_137\OCM_137_50136_episodes_base_20160804.txt', '7c'x);*/

** RAW Recon **;
/*%TARGET(480, 50185, 20180228, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1\OCM_480\OCM_480_50185_episodes_pp1initial_20180228.txt','7c'x);*/
/*%TARGET(396, 50258, 20180228, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1\OCM_396\OCM_396_50258_episodes_pp1initial_20180228.txt','7c'x);*/
/*%TARGET(257, 50195, 20180228, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1\OCM_257\OCM_257_50195_episodes_pp1initial_20180228.txt','7c'x);*/
/*%TARGET(255, 50179, 20180228, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1\OCM_255\OCM_255_50179_episodes_pp1initial_20180228.txt','7c'x);*/
/*%TARGET(278, 50193, 20180228, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1\OCM_278\OCM_278_50193_episodes_pp1initial_20180228.txt','7c'x);*/
/*%TARGET(290, 50202, 20180228, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1\OCM_290\OCM_290_50202_episodes_pp1initial_20180228.txt','7c'x);*/
/*%TARGET(567, 50200, 20180228, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1\OCM_567\OCM_567_50200_episodes_pp1initial_20180228.txt','7c'x);*/
/*%TARGET(568, 50201, 20180228, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1\OCM_568\OCM_568_50201_episodes_pp1initial_20180228.txt','7c'x);*/
/*%TARGET(523, 50330, 20180228, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1\OCM_523\OCM_523_50330_episodes_pp1initial_20180228.txt','7c'x);*/
/*%TARGET(280, 50115, 20180228, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1\OCM_280\OCM_280_50115_episodes_pp1initial_20180228.txt','7c'x);*/
/*%TARGET(401, 50228, 20180228, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1\OCM_401\OCM_401_50228_episodes_pp1initial_20180228.txt','7c'x);*/
/*%TARGET(468, 50227, 20180228, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1\OCM_468\OCM_468_50227_episodes_pp1initial_20180228.txt','7c'x);*/
/*%TARGET(459, 50243, 20180228, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1\OCM_459\OCM_459_50243_episodes_pp1initial_20180228.txt','7c'x);*/
/*%TARGET(137, 50136, 20180228, 'R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1\OCM_137\OCM_137_50136_episodes_pp1initial_20180228.txt','7c'x);*/

** PROCESSED Recon **;
%let PP = P1_2; 
%TARGET(480, 50185,,,,PP1);
%TARGET(396, 50258,,,,PP1);
%TARGET(257, 50195,,,,PP1);
%TARGET(255, 50179,,,,PP1);
%TARGET(278, 50193,,,,PP1);
%TARGET(290, 50202,,,,PP1);
%TARGET(567, 50200,,,,PP1);
%TARGET(568, 50201,,,,PP1);
%TARGET(523, 50330,,,,PP1);
%TARGET(280, 50115,,,,PP1);
%TARGET(401, 50228,,,,PP1);
%TARGET(468, 50227,,,,PP1);
%TARGET(459, 50243,,,,PP1);
%TARGET(137, 50136,,,,PP1);

%TARGET(480, 50185,,,,PP2);
%TARGET(396, 50258,,,,PP2);
%TARGET(257, 50195,,,,PP2);
%TARGET(255, 50179,,,,PP2);
%TARGET(278, 50193,,,,PP2);
%TARGET(290, 50202,,,,PP2);
%TARGET(523, 50330,,,,PP2);
%TARGET(280, 50115,,,,PP2);
%TARGET(401, 50228,,,,PP2);
%TARGET(468, 50227,,,,PP2);
%TARGET(459, 50243,,,,PP2);
%TARGET(137, 50136,,,,PP2);

%let PP = P3; 
%TARGET(480, 50185,,,,PP3);
%TARGET(396, 50258,,,,PP3);
%TARGET(257, 50195,,,,PP3);
%TARGET(255, 50179,,,,PP3);
%TARGET(278, 50193,,,,PP3);
%TARGET(290, 50202,,,,PP3);
%TARGET(523, 50330,,,,PP3);
%TARGET(280, 50115,,,,PP3);
%TARGET(401, 50228,,,,PP3);
%TARGET(468, 50227,,,,PP3);
%TARGET(459, 50243,,,,PP3);
%TARGET(137, 50136,,,,PP3);

data out.Price_Summary;
	set Price_Summary: ;
run;

data out.Difference_Summary;
	set check_difference_: ;
	format avg_diff dollar12.2;
	avg_diff = total_diff / episodes;
run;


/*proc printto;*/
/*run;*/

