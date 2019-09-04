
*** Source: OCM Novel Therapies Drug List_v1.27_20190610.xlsx *** ;
*** Novel Therapy *** ;

***************************************************************** ;
***************************************************************** ;
 
%MACRO NT ;

CTYPE=CANCER_TYPE_Milliman ;

Age=year(SRVC_DT)-year(DOB);
if (month(SRVC_DT)*100+day(SRVC_DT)) < (month(DOB)*100+day(DOB)) then Age=year(SRVC_DT)-year(DOB)-1;

**NDC Novel Therapies**;
if (NDC9 in ('595720402','595720405','595720410','595720415','595720420','595720425')) AND CTYPE in ('Lymphoma') AND MDY(5,28,2019) LE SRVC_DT AND EP_END LE MDY(12,31,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780708','000780701','000780715')) AND CTYPE in ('Breast Cancer') AND MDY(5,24,2019) LE SRVC_DT AND EP_END LE MDY(12,31,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000740561','000740566','000740576','000740579')) AND CTYPE in ('Lymphoma') AND MDY(5,15,2019) LE SRVC_DT AND EP_END LE MDY(12,31,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('713340100')) AND CTYPE in ('Acute Leukemia') AND MDY(5,2,2019) LE SRVC_DT AND EP_END LE MDY(12,31,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('596760030','596760040')) AND CTYPE in ('Bladder Cancer') AND MDY(4,12,2019) LE SRVC_DT AND EP_END LE MDY(12,31,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('648421020','648421025')) AND CTYPE in ('Gastro/Esophageal Cancer') AND MDY(2,22,2019) LE SRVC_DT AND EP_END LE MDY(12,31,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('423880023','423880024','423880025')) AND CTYPE in ('Liver Cancer') AND MDY(1,14,2019) LE SRVC_DT AND EP_END LE MDY(12,31,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('003100668','003100679','003100657')) AND CTYPE in ('Ovarian Cancer','Female GU Cancer other than Ovary') AND MDY(12,19,2018) LE SRVC_DT AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('004691425')) AND CTYPE in ('Acute Leukemia') AND MDY(11,28,2018) LE SRVC_DT AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('717770390','717770391','717770392')) AND CTYPE in ('Head and Neck Cancer','Endocrine Tumor','Lung Cancer','Malignant Melanoma','Small Intestine/Colorectal Cancer','Liver Cancer','Pancreatic Cancer','Breast Cancer','Gastro/Esophageal Cancer') AND MDY(11,26,2018) LE SRVC_DT AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000690231','000690227')) AND CTYPE in ('Lung Cancer') AND MDY(11,2,2018) LE SRVC_DT AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000690296','000691195')) AND CTYPE in ('Breast Cancer') AND MDY(10,16,2018) LE SRVC_DT AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000690197','000691198','000692299')) AND CTYPE in ('Lung Cancer') AND MDY(9,27,2018) LE SRVC_DT AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('717790125','717790115')) AND CTYPE in ('Chronic Leukemia','Lymphoma') AND MDY(9,24,2018) LE SRVC_DT AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('628560704','628560708','628560710','628560712','628560714','628560718','628560720','628560724')) AND CTYPE in ('Liver Cancer') AND MDY(8,16,2018) LE SRVC_DT AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('713340100')) AND CTYPE in ('Acute Leukemia') AND MDY(7,20,2018) LE SRVC_DT AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780909','000780916','000780923')) AND CTYPE in ('Breast Cancer') AND MDY(7,18,2018) LE SRVC_DT AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780860','000780867','000780874','000780909','000780916','000780923')) AND CTYPE in ('Breast Cancer') AND MDY(7,18,2018) LE SRVC_DT AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('004690125')) AND CTYPE in ('Prostate Cancer') AND MDY(7,13,2018) LE SRVC_DT AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('702550010')) AND CTYPE in ('Malignant Melanoma') AND MDY(6,27,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('702550020','702550025')) AND CTYPE in ('Malignant Melanoma') AND MDY(6,27,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000740561','000740566','000740576','000740579')) AND CTYPE in ('Chronic Leukemia') AND MDY(6,8,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('473350401')) AND CTYPE in ('Prostate Cancer') AND MDY(5,22,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780682','000780681','001730846','001730847')) AND CTYPE in ('Endocrine Tumor') AND MDY(5,4,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780666','000780668','001730848','001730849')) AND CTYPE in ('Endocrine Tumor') AND MDY(5,4,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780682','000780681','001730846','001730847')) AND CTYPE in ('Malignant Melanoma') AND MDY(4,30,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780666','000780668','001730848','001730849')) AND CTYPE in ('Malignant Melanoma') AND MDY(4,30,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('003101349','003101350')) AND CTYPE in ('Lung Cancer') AND MDY(4,18,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('696600201','696600202','696600203')) AND CTYPE in ('Female GU Cancer other than Ovary') AND MDY(4,6,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000024483','000024815','000025337','000026216')) AND CTYPE in ('Breast Cancer') AND MDY(2,26,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('596760600')) AND CTYPE in ('Prostate Cancer') AND MDY(2,14,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('578940195','578940184','578940150')) AND CTYPE in ('Prostate Cancer') AND MDY(2,7,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('005970138','005970137','005970141')) AND CTYPE in ('Lung Cancer') AND MDY(1,12,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('003100679','003100668','003100657')) AND CTYPE in ('Breast Cancer') AND MDY(1,12,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000690135','000690193','000690136','635390117')) AND CTYPE in ('Chronic Leukemia') AND MDY(12,19,2017) LE SRVC_DT AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('423880023','423880024','423880025','423880011','423880012','423880013')) AND CTYPE in ('Kidney Cancer') AND MDY(12,19,2017) LE SRVC_DT AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000690550','000690770','000690830','000690980')) AND CTYPE in ('Kidney Cancer') AND MDY(11,16,2017) LE SRVC_DT AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('502420130')) AND CTYPE in ('Lung Cancer') AND MDY(11,6,2017) LE SRVC_DT AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('003100512')) AND CTYPE in ('Lymphoma') AND MDY(10,31,2017) LE SRVC_DT AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000024483','000024815','000025337','000026216')) AND CTYPE in ('Breast Cancer') AND MDY(9,28,2017) LE SRVC_DT AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('003100657','003100668','003100679')) AND CTYPE in ('Ovarian Cancer','Female GU Cancer other than Ovary') AND MDY(8,17,2017) LE SRVC_DT AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('595720705','595720710')) AND CTYPE in ('Acute Leukemia') AND MDY(8,1,2017) LE SRVC_DT AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('704370240')) AND CTYPE in ('Breast Cancer') AND MDY(7,17,2017) LE SRVC_DT AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780682','000780681','001730846','001730847')) AND CTYPE in ('Lung Cancer') AND MDY(6,22,2017) LE SRVC_DT AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780666','000780668','001730848','001730849')) AND CTYPE in ('Lung Cancer') AND MDY(6,22,2017) LE SRVC_DT AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780640')) AND CTYPE in ('Lung Cancer') AND MDY(5,26,2017) LE SRVC_DT AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('595720402','595720405','595720410','595720415','595720420','595720425')) AND CTYPE in ('Multiple Myeloma') AND MDY(2,22,2017) LE SRVC_DT AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('504190171')) AND CTYPE in ('Liver Cancer') AND MDY(4,27,2017) LE SRVC_DT AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780860','000780867','000780874','000780909','000780916','000780923')) AND CTYPE in ('Breast Cancer') AND MDY(3,13,2017) LE SRVC_DT AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('761890113')) AND CTYPE in ('Lung Cancer') AND MDY(4,28,2017) LE SRVC_DT AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('696560103')) AND CTYPE in ('Ovarian Cancer') AND MDY(3,27,2017) LE SRVC_DT AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('696600201','696600203')) AND CTYPE in ('Ovarian Cancer') AND MDY(12,19,2016) LE SRVC_DT AND EP_END LE MDY(6,30,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('628560708','628560710','628560714','628560718','628560720','628560724','628560704','628560712')) AND CTYPE in ('Kidney Cancer') AND MDY(5,13,2016) LE SRVC_DT AND EP_END LE MDY(12,31,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('423880023','423880024','423880025','423880011','423880012','423880013')) AND CTYPE in ('Kidney Cancer') AND MDY(4,25,2016) LE SRVC_DT AND EP_END LE MDY(12,31,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000740561','000740566','000740576','000740579')) AND CTYPE in ('Chronic Leukemia') AND MDY(4,11,2016) LE SRVC_DT AND EP_END LE MDY(12,31,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000698140','000698141')) AND CTYPE in ('Lung Cancer') AND MDY(3,11,2016) LE SRVC_DT AND EP_END LE MDY(12,31,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780566','000780567','000780594','000780620','000780626','000780627','000780628')) AND CTYPE in ('Endocrine Tumor') AND MDY(2,26,2016) LE SRVC_DT AND EP_END LE MDY(12,31,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('502420130')) AND CTYPE in ('Lung Cancer') AND MDY(12,11,2015) LE SRVC_DT AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780682','000780681','001730846','001730847')) AND CTYPE in ('Malignant Melanoma') AND MDY(11,20,2015) LE SRVC_DT AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780666','000780668','001730848','001730849')) AND CTYPE in ('Malignant Melanoma') AND MDY(11,20,2015) LE SRVC_DT AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('630200078','630200079','630200080')) AND CTYPE in ('Multiple Myeloma') AND MDY(11,20,2015) LE SRVC_DT AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('003101349','003101350')) AND CTYPE in ('Lung Cancer') AND MDY(11,13,2015) LE SRVC_DT AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('502420717')) AND CTYPE in ('Malignant Melanoma') AND MDY(11,10,2015) LE SRVC_DT AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('648421020','648421025')) AND CTYPE in ('Small Intestine / Colorectal Cancer') AND MDY(9,22,2015) LE SRVC_DT AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('595720402','595720405','595720410','595720415','595720420','595720425')) AND CTYPE in ('Multiple Myeloma') AND MDY(2,18,2015) LE SRVC_DT AND EP_END LE MDY(12,31,2017) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('628560710','628560708','628560714','628560718','628560720','628560724')) AND CTYPE in ('Endocrine Tumor') AND MDY(2,13,2015) LE SRVC_DT AND EP_END LE MDY(12,31,2017) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('635390189','000690187','000690188','000690189')) AND CTYPE in ('Breast Cancer') AND MDY(2,3,2015) LE SRVC_DT AND EP_END LE MDY(12,31,2017) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('579620140')) AND CTYPE in ('Lymphoma') AND MDY(1,29,2015) LE SRVC_DT AND EP_END LE MDY(12,31,2017) THEN NOVEL_THERAPY='YES' ;

**HCPCS Novel Therapies**;
if (NDC9 in ('440873535') OR HCPCS_CD in ('C9491','J9023')) AND CTYPE in ('Kidney Cancer') AND MDY(5,14,2019) LE START_DATE AND EP_END LE MDY(12,31,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000027669','000027678') OR HCPCS_CD in ('C9025','J9308')) AND CTYPE in ('Liver Cancer') AND MDY(5,10,2019) LE START_DATE AND EP_END LE MDY(12,31,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('502420088','502420087') OR HCPCS_CD in ('J9354')) AND CTYPE in ('Breast Cancer') AND MDY(5,3,2019) LE START_DATE AND EP_END LE MDY(12,31,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Kidney Cancer') AND MDY(4,19,2019) LE START_DATE AND EP_END LE MDY(12,31,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Lung Cancer') AND MDY(4,11,2019) LE START_DATE AND EP_END LE MDY(12,31,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Malignant Melanoma') AND MDY(2,15,2019) LE START_DATE AND EP_END LE MDY(12,31,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('721870401') OR HCPCS_CD in ('J9999')) AND CTYPE in ('Lymphoma') AND MDY(12,21,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('726940515') OR HCPCS_CD in ('J9999')) AND CTYPE in ('Acute Leukemia') AND MDY(12,20,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('511440050') OR HCPCS_CD in ('J9042','C9287')) AND CTYPE in ('Lymphoma') AND MDY(11,16,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Liver Cancer') AND MDY(11,9,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000034522','000032291') OR HCPCS_CD in ('J9176','C9477')) AND CTYPE in ('Multiple Myeloma') AND MDY(11,6,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('003104700') OR HCPCS_CD in ('J9999')) AND CTYPE in ('Chronic Leukemia') AND MDY(9,13,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Lung Cancer') AND MDY(8,20,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000033772','000033774','000033734') OR HCPCS_CD in ('C9453','J9299')) AND CTYPE in ('Lung Cancer') AND MDY(8,16,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('712580015') OR HCPCS_CD in ('J9999')) AND CTYPE in ('Endocrine Tumor') AND MDY(7,30,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Lymphoma') AND MDY(6,13,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Female GU Cancer other than Ovary') AND MDY(6,12,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('578940502') OR HCPCS_CD in ('C9476','J9145')) AND CTYPE in ('Multiple Myeloma') AND MDY(5,7,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('555130160') OR HCPCS_CD in ('C9449','J9039')) AND CTYPE in ('Acute Leukemia') AND MDY(3,29,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('511440050') OR HCPCS_CD in ('J9042','C9287')) AND CTYPE in ('Lymphoma') AND MDY(3,20,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('003104611','003104500') OR HCPCS_CD in ('C9492')) AND CTYPE in ('Lung Cancer') AND MDY(2,16,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('694880003') OR HCPCS_CD in ('C9031')) AND CTYPE in ('Endocrine Tumor') AND MDY(1,26,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('555130730') OR HCPCS_CD in ('J0897')) AND CTYPE in ('Multiple Myeloma') AND MDY(1,5,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000033772','000033774','000033734') OR HCPCS_CD in ('C9453','J9299')) AND CTYPE in ('Malignant Melanoma') AND MDY(12,20,2017) LE START_DATE AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('502420070') OR HCPCS_CD in ('C9021','J9301')) AND CTYPE in ('Lymphoma') AND MDY(11,16,2017) LE START_DATE AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('511440050') OR HCPCS_CD in ('C9287','J9042')) AND CTYPE in ('Lymphoma') AND MDY(11,9,2017) LE START_DATE AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000033772','000033774','000033734') OR HCPCS_CD in ('C9453','J9299')) AND CTYPE in ('Liver Cancer') AND MDY(9,22,2017) LE START_DATE AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Gastro/Esophageal Cancer') AND MDY(9,22,2017) LE START_DATE AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('504190385') OR HCPCS_CD in ('C9030')) AND CTYPE in ('Lymphoma') AND MDY(9,14,2017) LE START_DATE AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000084510') OR HCPCS_CD in ('J9300')) AND CTYPE in ('Acute Leukemia') AND MDY(9,1,2017) LE START_DATE AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000080100') OR HCPCS_CD in ('C9028')) AND CTYPE in ('Acute Leukemia') AND MDY(8,17,2017) LE START_DATE AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('687270745') OR HCPCS_CD in ('C9024')) AND CTYPE in ('Acute Leukemia') AND MDY(8,3,2017) LE START_DATE AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000033772','000033774','000033734') OR HCPCS_CD in ('C9453','J9299')) AND CTYPE in ('Small Intestine / Colorectal Cancer') AND MDY(8,1,2017) LE START_DATE AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('555130160') OR HCPCS_CD in ('C9449','J9039')) AND CTYPE in ('Acute Leukemia') AND MDY(7,11,2017) LE START_DATE AND EP_END LE MDY(6,30,2020) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Lymphoma') AND MDY(3,14,2017) LE START_DATE AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('440873535') OR HCPCS_CD in ('C9491','J9023')) AND CTYPE in ('Bladder Cancer') AND MDY(5,9,2017) LE START_DATE AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Gastro/Esophageal Cancer','Small Intestine / Colorectal Cancer','Kidney Cancer','Pancreatic Cancer','Lung Cancer','Breast Cancer','Female GU Cancer other than the Ovary','Prostate Cancer','Bladder Cancer','Endocrine Tumor') AND MDY(5,23,2017) LE START_DATE AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Bladder Cancer') AND MDY(5,18,2017) LE START_DATE AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Lung Cancer') AND MDY(5,10,2017) LE START_DATE AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000033772','000033774','000033734') OR HCPCS_CD in ('C9453','J9299')) AND CTYPE in ('Bladder Cancer') AND MDY(2,2,2017) LE START_DATE AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('003104500','003104611') OR HCPCS_CD in ('C9492')) AND CTYPE in ('Bladder Cancer') AND MDY(5,1,2017) LE START_DATE AND EP_END LE MDY(12,31,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('578940502') OR HCPCS_CD in ('C9476','J9145')) AND CTYPE in ('Multiple Myeloma') AND MDY(11,21,2016) LE START_DATE AND EP_END LE MDY(6,30,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000033772','000033774','000033734') OR HCPCS_CD in ('C9453','J9299')) AND CTYPE in ('Head and Neck Cancer') AND MDY(11,10,2016) LE START_DATE AND EP_END LE MDY(6,30,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Lung Cancer') AND MDY(10,24,2016) LE START_DATE AND EP_END LE MDY(6,30,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('502420917') OR HCPCS_CD in ('C9483','J9022')) AND CTYPE in ('Lung Cancer') AND MDY(10,18,2016) LE START_DATE AND EP_END LE MDY(6,30,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Head and Neck Cancer') AND MDY(8,5,2016) LE START_DATE AND EP_END LE MDY(6,30,2019) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('502420917') OR HCPCS_CD in ('C9483','J9022')) AND CTYPE in ('Bladder Cancer') AND MDY(5,18,2016) LE START_DATE AND EP_END LE MDY(12,31,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000033772','000033774','000033734') OR HCPCS_CD in ('C9453','J9299')) AND CTYPE in ('Lymphoma') AND MDY(5,17,2016) LE START_DATE AND EP_END LE MDY(12,31,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('502420070') OR HCPCS_CD in ('C9021','J9301')) AND CTYPE in ('Lymphoma') AND MDY(2,26,2016) LE START_DATE AND EP_END LE MDY(12,31,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000033772','000033774','000033734') OR HCPCS_CD in ('C9453','J9299')) AND CTYPE in ('Malignant Melanoma') AND MDY(1,23,2016) LE START_DATE AND EP_END LE MDY(12,31,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000780669','000780690','001730821','001730821') OR HCPCS_CD in ('J9302')) AND CTYPE in ('Chronic Leukemia') AND MDY(1,19,2016) LE START_DATE AND EP_END LE MDY(12,31,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Malignant Melanoma') AND MDY(12,18,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000032291','000034522') OR HCPCS_CD in ('J9176','C9477')) AND CTYPE in ('Multiple Myeloma') AND MDY(11,30,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000033772','000033774','000033734') OR HCPCS_CD in ('C9453','J9299')) AND CTYPE in ('Kidney Cancer') AND MDY(11,23,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('578940502') OR HCPCS_CD in ('C9476','J9145')) AND CTYPE in ('Multiple Myeloma') AND MDY(11,16,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000032327','000032328') OR HCPCS_CD in ('J9228')) AND CTYPE in ('Malignant Melanoma') AND MDY(10,28,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('555130078','555130079') OR HCPCS_CD in ('C9472','J9325')) AND CTYPE in ('Malignant Melanoma') AND MDY(10,27,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000033772','000033774','000033734') OR HCPCS_CD in ('C9453','J9299')) AND CTYPE in ('Lung Cancer') AND MDY(10,9,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000063026','000063029') OR HCPCS_CD in ('C9027','J9271')) AND CTYPE in ('Lung Cancer') AND MDY(10,2,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000033772','000033774','000033734') OR HCPCS_CD in ('C9453','J9299')) AND CTYPE in ('Malignant Melanoma') AND MDY(9,30,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('760750101','760750102') OR HCPCS_CD in ('C9295','J9047')) AND CTYPE in ('Multiple Myeloma') AND MDY(7,24,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('003100482') OR HCPCS_CD in ('J8565')) AND CTYPE in ('Lung Cancer') AND MDY(7,13,2015) LE SRVC_DT AND EP_END LE MDY(6,30,2018) THEN NOVEL_THERAPY='YES' ;
if (NDC9 in ('000033772','000033774','000033734') OR HCPCS_CD in ('C9453','J9299')) AND CTYPE in ('Lung Cancer') AND MDY(3,4,2015) LE START_DATE AND EP_END LE MDY(12,31,2017) THEN NOVEL_THERAPY='YES' ;


*****Combo Novel Therapies;
tecentriq=0;
abraxane=0;
yervoy=0;
opdivo=0;
yervoy2=0;
opdivo2=0;
yervoy3=0;
opdivo3=0;
yervoy4=0;
opdivo4=0;
perjeta=0;
herceptin=0;
onivyde=0;
adrucil=0;

daurismo=0;
cytarabine2=0;
rydapt=0;
cytarabine=0;
ibrance=0;
faslodex=0;
farydak=0;
velcade=0;

tecentriq2=0;
paraplatin3=0;
etoposide=0;
tecentriq3=0;
avastin2=0;
taxol2=0;
paraplatin4=0;
avastin=0;
paraplatin=0;
taxol=0;
alimta=0;
keytruda=0;
paraplatin2=0;
portrazza=0;
gemzar=0;
platinol=0;
cyramza=0;
camptosar=0;
adrucil2=0;
unituxin=0;
proleukin=0;


*** Beneficiary must be <= 18 years old *** ;

IF NDC9 IN ('000780951','000780592','000780526') AND 
	CTYPE IN ('Chronic Leukemia') AND 
	MDY(3,22,2018) LE SRVC_DT AND EP_END LE MDY(12,31,2020) AND 
	Age LE 18 THEN NOVEL_THERAPY='YES' ;

IF NDC9 IN ('000030527','000030528','000030524','000030855','000030852','000030857') AND 
	CTYPE IN ('Chronic Leukemia') AND
	MDY(11,9,2017) LE SRVC_DT AND EP_END LE MDY(6,30,2020) AND 
	Age LE 18 THEN NOVEL_THERAPY='YES' ;

**Used as a combo drug**;
IF (NDC9 IN ('663020014') OR HCPCS_CD IN ('J9999')) AND
	CTYPE IN ('Endocrine Tumor') AND
	MDY(3,10,2015) LE START_DATE AND EP_END LE MDY(12,31,2017) AND
	Age LE 18 THEN unituxin=1 ;
IF (HCPCS_CD IN('J9015')) AND 
	CTYPE IN ('Endocrine Tumor') AND
	MDY(3,10,2015) LE START_DATE AND EP_END LE MDY(12,31,2017) THEN proleukin=1 ;

*End of age sensitive drugs ;
***************************************************************** ;

*** Combo Novel Therapies ***;

IF (NDC9 IN('502420917','502420918') OR HCPCS_CD IN('C9483','J9022')) AND 
    CTYPE IN('Breast Cancer') AND 
    MDY(3,8,2019) LE START_DATE AND EP_END LE MDY(12,31,2021) THEN tecentriq=1 ;
IF (HCPCS_CD IN('J9264')) AND 
    CTYPE IN('Breast Cancer') AND 
    MDY(3,8,2019) LE START_DATE AND EP_END LE MDY(12,31,2021) THEN abraxane=1 ;

IF (NDC9 IN('000032327','000032328') OR HCPCS_CD IN('J9228')) AND 
    CTYPE IN('Small Intestine / Colorectal Cancer') AND 
    MDY(7,10,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN yervoy=1 ;
IF (HCPCS_CD IN('C9453','J9299')) AND 
    CTYPE IN('Small Intestine / Colorectal Cancer') AND 
    MDY(7,10,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN opdivo=1 ;

IF (NDC9 IN('000033772','000033774','000033734') OR HCPCS_CD IN('C9453','J9299')) AND 
    CTYPE IN('Small Intestine / Colorectal Cancer') AND 
    MDY(7,10,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN opdivo2=1 ;
IF (HCPCS_CD IN('J9228')) AND 
    CTYPE IN('Small Intestine / Colorectal Cancer') AND 
    MDY(7,10,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN yervoy2=1 ;

IF (NDC9 IN('000033772','000033774','000033734') OR HCPCS_CD IN('C9453','J9299')) AND 
    CTYPE IN('Kidney Cancer') AND 
    MDY(4,16,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN opdivo3=1 ;
IF (HCPCS_CD IN('J9228')) AND 
    CTYPE IN('Kidney Cancer') AND 
    MDY(4,16,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN yervoy3=1 ;

IF (NDC9 IN('000032327','000032328') OR HCPCS_CD IN('J9228')) AND 
    CTYPE IN('Kidney Cancer') AND 
    MDY(4,16,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN yervoy4=1 ;
IF (HCPCS_CD IN('C9453','J9299')) AND 
    CTYPE IN('Kidney Cancer') AND 
    MDY(4,16,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN opdivo4=1 ;

IF (NDC9 IN('502420145') OR HCPCS_CD IN('J9306')) AND 
    CTYPE IN('Breast Cancer') AND 
    MDY(12,20,2017) LE START_DATE AND EP_END LE MDY(6,30,2020) THEN perjeta=1 ;
IF (HCPCS_CD IN('J9355')) AND 
    CTYPE IN('Breast Cancer') AND 
    MDY(12,20,2017) LE START_DATE AND EP_END LE MDY(6,30,2020) THEN herceptin=1 ;

IF (NDC9 IN('691710398') OR HCPCS_CD IN('J9205')) AND 
    CTYPE IN('Pancreatic Cancer') AND 
    MDY(10,22,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN onivyde=1 ;
IF (HCPCS_CD IN('J9190')) AND 
    CTYPE IN('Pancreatic Cancer') AND 
    MDY(10,22,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN adrucil=1 ;


IF (NDC9 IN('000691531','000690298')) AND 
    CTYPE IN('Acute Leukemia') AND 
    MDY(11,21,2018) LE SRVC_DT AND EP_END LE MDY(6,30,2021) THEN daurismo=1 ;
IF (HCPCS_CD IN('J9100')) AND 
    CTYPE IN('Acute Leukemia') AND 
    MDY(11,21,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN cytarabine2=1 ;

IF (NDC9 IN('000780698')) AND 
    CTYPE IN('Acute Leukemia') AND 
    MDY(4,28,2017) LE SRVC_DT AND EP_END LE MDY(12,31,2019) THEN rydapt=1 ;
IF (HCPCS_CD IN('J9100')) AND 
    CTYPE IN('Acute Leukemia') AND 
    MDY(4,28,2017) LE START_DATE AND EP_END LE MDY(12,31,2019) THEN cytarabine=1 ;

IF (NDC9 IN('000690187','000690188','000690189','635390189')) AND 
    CTYPE IN('Breast Cancer') AND 
    MDY(2,19,2016) LE SRVC_DT AND EP_END LE MDY(12,31,2018) THEN ibrance=1 ;
IF (HCPCS_CD IN('J9395')) AND 
    CTYPE IN('Breast Cancer') AND 
    MDY(2,19,2016) LE START_DATE AND EP_END LE MDY(12,31,2018) THEN faslodex=1 ;

IF (NDC9 IN('000780650','000780651','000780652')) AND 
    CTYPE IN('Multiple Myeloma') AND 
    MDY(2,23,2015) LE SRVC_DT AND EP_END LE MDY(12,31,2017) THEN farydak=1 ;
IF (HCPCS_CD IN('J9041')) AND 
    CTYPE IN('Multiple Myeloma') AND 
    MDY(2,23,2015) LE START_DATE AND EP_END LE MDY(12,31,2017) THEN velcade=1 ;


IF (NDC9 IN('502420917','502420918') OR HCPCS_CD IN('C9483','J9022')) AND 
    CTYPE IN('Lung Cancer') AND 
    MDY(3,18,2019) LE START_DATE AND EP_END LE MDY(12,31,2021) THEN tecentriq2=1 ;
IF (HCPCS_CD IN('J9045')) AND 
    CTYPE IN('Lung Cancer') AND 
    MDY(3,18,2019) LE START_DATE AND EP_END LE MDY(12,31,2021) THEN paraplatin3=1 ;
IF (HCPCS_CD IN('J9181')) AND 
    CTYPE IN('Lung Cancer') AND 
    MDY(3,18,2019) LE START_DATE AND EP_END LE MDY(12,31,2021) THEN etoposide=1 ;

IF (NDC9 IN('502420917','502420918') OR HCPCS_CD IN('C9483','J9022')) AND 
    CTYPE IN('Lung Cancer') AND 
    MDY(12,6,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN tecentriq3=1 ;
IF (HCPCS_CD IN('J9035')) AND 
    CTYPE IN('Lung Cancer') AND 
    MDY(12,6,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN avastin2=1 ;
IF (HCPCS_CD IN('J9265','J9267')) AND 
    CTYPE IN('Lung Cancer') AND 
    MDY(12,6,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN taxol2=1 ;
IF (HCPCS_CD IN('J9045')) AND 
    CTYPE IN('Lung Cancer') AND 
    MDY(12,6,2018) LE START_DATE AND EP_END LE MDY(6,30,2021) THEN paraplatin4=1 ;

IF (NDC9 IN('502420060','502420061') OR HCPCS_CD IN('J9035')) AND 
    CTYPE IN('Ovarian Cancer') AND 
    MDY(6,13,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN avastin=1 ;
IF (HCPCS_CD IN('J9045')) AND 
    CTYPE IN('Ovarian Cancer') AND 
    MDY(6,13,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN paraplatin=1 ;
IF (HCPCS_CD IN('J9265','J9267')) AND 
    CTYPE IN('Ovarian Cancer') AND 
    MDY(6,13,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN taxol=1 ;

IF (NDC9 IN('000027623','000027640') OR HCPCS_CD IN('J9305')) AND 
    CTYPE IN('Lung Cancer') AND 
    MDY(6,4,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN alimta=1 ;
IF (HCPCS_CD IN('C9027','J9271')) AND 
    CTYPE IN('Lung Cancer') AND 
    MDY(6,4,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN keytruda=1 ;
IF (HCPCS_CD IN('J9045')) AND 
    CTYPE IN('Lung Cancer') AND 
    MDY(6,4,2018) LE START_DATE AND EP_END LE MDY(12,31,2020) THEN paraplatin2=1 ;

IF (NDC9 IN('000027716') OR HCPCS_CD IN('J9295','C9475')) AND 
    CTYPE IN('Lung Cancer') AND 
    MDY(11,24,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN portrazza=1 ;
IF (HCPCS_CD IN('J9201')) AND 
    CTYPE IN('Lung Cancer') AND 
    MDY(11,24,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN gemzar=1 ;
IF (HCPCS_CD IN('J9060')) AND 
    CTYPE IN('Lung Cancer') AND 
    MDY(11,24,2015) LE START_DATE AND EP_END LE MDY(6,30,2018) THEN platinol=1 ;

IF (NDC9 IN('000027669','000027678') OR HCPCS_CD IN('C9025','J9308')) AND 
    CTYPE IN('Small Intestine / Colorectal Cancer') AND 
    MDY(4,24,2015) LE START_DATE AND EP_END LE MDY(12,31,2017) THEN cyramza=1 ;
IF (HCPCS_CD IN('J9206')) AND 
    CTYPE IN('Small Intestine / Colorectal Cancer') AND 
    MDY(4,24,2015) LE START_DATE AND EP_END LE MDY(12,31,2017) THEN camptosar=1 ;
IF (HCPCS_CD IN('J9190')) AND 
    CTYPE IN('Small Intestine / Colorectal Cancer') AND 
    MDY(4,24,2015) LE START_DATE AND EP_END LE MDY(12,31,2017) THEN adrucil2=1 ;


%MEND NT ;


*****END Combo Novel Therapies;
**********************************************;
%MACRO NT_COMBO ;

proc sql;
	create table t1 as
	select bene_id, EP_ID, CTYPE,
		max(tecentriq) as tecentriq,
		max(abraxane) as abraxane,
		max(yervoy) as yervoy,
		max(opdivo) as opdivo,
		max(yervoy2) as yervoy2,
		max(opdivo2) as opdivo2,
		max(yervoy3) as yervoy3,
		max(opdivo3) as opdivo3,
		max(yervoy4) as yervoy4,
		max(opdivo4) as opdivo4,
		max(perjeta) as perjeta,
		max(herceptin) as herceptin,
		max(onivyde) as onivyde,
		max(adrucil) as adrucil,

		max(daurismo) as daurismo,
		max(cytarabine2) as cytarabine2,
		max(rydapt) as rydapt,
		max(cytarabine) as cytarabine,
		max(ibrance) as ibrance,
		max(faslodex) as faslodex,
		max(farydak) as farydak,
		max(velcade) as velcade,

		max(tecentriq2) as tecentriq2,
		max(paraplatin3) as paraplatin3,
		max(etoposide) as etoposide,
		max(tecentriq3) as tecentriq3,
		max(avastin2) as avastin2,
		max(taxol2) as taxol2,
		max(paraplatin4) as paraplatin4,
		max(avastin) as avastin,
		max(paraplatin) as paraplatin,
		max(taxol) as taxol,
		max(alimta) as alimta,
		max(keytruda) as keytruda,
		max(paraplatin2) as paraplatin2,
		max(portrazza) as portrazza,
		max(gemzar) as gemzar,
		max(platinol) as platinol,
		max(cyramza) as cyramza,
		max(camptosar) as camptosar,
		max(adrucil2) as adrucil2,
		max(unituxin) as unituxin,
		max(proleukin) as proleukin
	from t0
	group by bene_id, EP_ID, CTYPE;
quit;

data t2 (keep= bene_id EP_ID CTYPE NOVEL_THERAPYe 
			tec_abr dau_cyt tec_par_eto tec_ava_tax_par
			yer_opd1 opd_yer1 opd_yer2 yer_opd2 per_her oni_adr ryd_cyt 
			ibr_fas far_vel ava_par_tax ali_key_par por_gem_pla cyr_cam_adr uni_pro );
	set t1;

	tec_abr=0;
	if ctype = 'Breast Cancer' and tecentriq=1 and abraxane=1 then tec_abr=1;
	yer_opd1=0;
	if ctype = 'Small Intestine / Colorectal Cancer' and yervoy=1 and opdivo=1 then yer_opd1=1;
	opd_yer1=0;
	if ctype = 'Small Intestine / Colorectal Cancer' and yervoy2=1 and opdivo2=1 then opd_yer1=1;
	opd_yer2=0;
	if ctype = 'Kidney Cancer' and yervoy3=1 and opdivo3=1 then opd_yer2=1;
	yer_opd2=0;
	if ctype = 'Kidney Cancer' and yervoy4=1 and opdivo4=1 then yer_opd2=1;
	per_her=0;
	if ctype = 'Breast Cancer' and perjeta=1 and herceptin=1 then per_her=1;
	oni_adr=0;
	if ctype = 'Pancreatic Cancer' and onivyde=1 and adrucil=1 then oni_adr=1;

	dau_cyt=0;
	if ctype = 'Acute Leukemia' and daurismo=1 and cytarabine2=1 then dau_cyt=1;
	ryd_cyt=0;
	if ctype = 'Acute Leukemia' and rydapt=1 and cytarabine=1 then ryd_cyt=1;
	ibr_fas=0;
	if ctype = 'Breast Cancer' and ibrance=1 and faslodex=1 then ibr_fas=1;
	far_vel=0;
	if ctype = 'Multiple Myeloma' and farydak=1 and velcade=1 then far_vel=1;

	tec_par_eto=0;
	if ctype = 'Lung Cancer' and tecentriq2=1 and paraplatin3=1 and etoposide=1 then tec_par_eto=1;
	tec_ava_tax_par=0;
	if ctype = 'Lung Cancer' and tecentriq3=1 and avastin2=1 and taxol2=1 and paraplatin4=1 then tec_ava_tax_par=1;
	ava_par_tax=0;
	if ctype = 'Ovarian Cancer' and avastin=1 and paraplatin=1 and taxol=1 then ava_par_tax=1;
	ali_key_par=0;
	if ctype = 'Lung Cancer' and alimta=1 and keytruda=1 and paraplatin2=1 then ali_key_par=1;
	por_gem_pla=0;
	if ctype = 'Lung Cancer' and portrazza=1 and gemzar=1 and platinol=1 then por_gem_pla=1;
	cyr_cam_adr=0;
	if ctype = 'Small Intestine / Colorectal Cancer' and cyramza=1 and camptosar=1 and adrucil2=1 then cyr_cam_adr=1;
	uni_pro=0;
	if ctype = 'Endocrine Tumor' and unituxin=1 and proleukin=1 then uni_pro=1;


	if CTYPE='Breast Cancer' and tec_abr=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Small Intestine / Colorectal Cancer' and yer_opd1=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Small Intestine / Colorectal Cancer' and opd_yer1=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Kidney Cancer' and opd_yer2=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Kidney Cancer' and yer_opd2=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Breast Cancer' and per_her=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Pancreatic Cancer' and oni_adr=1 then NOVEL_THERAPYe='YES' ;

	if CTYPE='Acute Leukemia' and dau_cyt=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Acute Leukemia' and ryd_cyt=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Breast Cancer' and ibr_fas=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Multiple Myeloma' and far_vel=1 then NOVEL_THERAPYe='YES' ;

	if CTYPE='Lung Cancer' and tec_par_eto=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Lung Cancer' and tec_ava_tax_par=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Ovarian Cancer' and ava_par_tax=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Lung Cancer' and ali_key_par=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Lung Cancer' and por_gem_pla=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Small Intestine / Colorectal Cancer' and cyr_cam_adr=1 then NOVEL_THERAPYe='YES' ;
	if CTYPE='Endocrine Tumor' and uni_pro=1 then NOVEL_THERAPYe='YES' ;

proc sort data=t2 ; by bene_id ep_id ;

%MEND NT_COMBO ;

*** For line assignments to novel therapy *** ;

%MACRO NT2 ;

	if CTYPE = 'Breast Cancer' and tec_abr=1 then do ;
			if tecentriq=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Small Intestine / Colorectal Cancer' and yer_opd1=1 then do ;
			if yervoy=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Small Intestine / Colorectal Cancer' and opd_yer1=1 then do ;
			if opdivo2=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Kidney Cancer' and opd_yer2=1 then do ;
			if opdivo3=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Kidney Cancer' and yer_opd2=1 then do ;
			if yervoy4=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Breast Cancer' and per_her=1 then do ;
			if perjeta=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Pancreatic Cancer' and oni_adr=1 then do ;
			if onivyde=1 then NOVEL_THERAPY = "YES" ;
	end ;

	if CTYPE = 'Acute Leukemia' and dau_cyt=1 then do ;
			if daurismo=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Acute Leukemia' and ryd_cyt=1 then do ;
			if rydapt=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Breast Cancer' and ibr_fas=1 then do ;
			if ibrance=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Multiple Myeloma' and far_vel=1 then do ;
			if farydak=1 then NOVEL_THERAPY = "YES" ;
	end ;

	if CTYPE = 'Lung Cancer' and tec_par_eto=1 then do ;
			if tecentriq2=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Lung Cancer' and tec_ava_tax_par=1 then do ;
			if tecentriq3=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Ovarian Cancer' and ava_par_tax=1 then do ;
			if avastin=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Lung Cancer' and ali_key_par=1 then do ;
			if alimta=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Lung Cancer' and por_gem_pla=1 then do ;
			if portrazza=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Small Intestine / Colorectal Cancer' and cyr_cam_adr=1 then do ;
			if cyramza=1 then NOVEL_THERAPY = "YES" ;
	end ;
	if CTYPE = 'Endocrine Tumor' and uni_pro=1 then do ;
			if unituxin=1 then NOVEL_THERAPY = "YES" ;
	end ;

%MEND NT2 ;


