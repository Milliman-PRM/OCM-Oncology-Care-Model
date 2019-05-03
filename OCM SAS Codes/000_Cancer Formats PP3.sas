
********************************************************************************** ;
***************** ICD-9 Diagnosis Codes for Cancer Types  ************************ ;
*** Source: OCM Cancer Type Mapping and Codes Effective 07.02.17_20170501.xlsx *** ;
********************************************************************************** ;

*** Acute Leukemia *** ;
proc format; value $Acute_leukemia_49_
'2040' = 'Y'
'2053' = 'Y'
'2060' = 'Y'
'2070' = 'Y'
'2072' = 'Y'
'2080' = 'Y'
Other='N'
;

*** Acute Leukemia *** ;
proc format; value $Acute_leukemia_59_
'20500' = 'Y'
'20501' = 'Y'
'20502' = 'Y'
Other='N'
;

*** Anal Cancer*** ;
proc format; value $Anal_49_
'1542' = 'Y'
'1543' = 'Y'
'1548' = 'Y'
Other='N'
;

*** Bladder Cancer *** ;
proc format; value $Bladder_39_
'188' = 'Y'
Other='N'
;

*** Bladder Cancer *** ;
proc format; value $Bladder_49_
'1891' = 'Y'
'1892' = 'Y'
'1893' = 'Y'
'1894' = 'Y'
'1898' = 'Y'
'1899' = 'Y'
Other='N'
;

*** Breast Cancer *** ;
proc format; value $BREAST_39_
'174' = 'Y'
'175' = 'Y'
Other='N'
;

*** Chronic Leukemia *** ;
proc format; value $Chronic_Leukemia_49_
'2041' = 'Y'
'2051' = 'Y'
Other='N'
;

*** CNS Tumor *** ;
proc format; value $CNS_39_
'191' = 'Y'
Other='N'
;

*** CNS Tumor *** ;
proc format; value $CNS_49_
'1920' = 'Y'
'1921' = 'Y'
'1922' = 'Y'
'1923' = 'Y'
'1928' = 'Y'
'1929' = 'Y'
Other='N'
;

*** Endocrine Tumor *** ;
proc format; value $Endo_39_
'193' = 'Y'
Other='N'
;

*** Endocrine Tumor *** ;
proc format; value $Endo_49_
'1940' = 'Y'
'1941' = 'Y'
'1943' = 'Y'
'1944' = 'Y'
'1945' = 'Y'
'1946' = 'Y'
'1948' = 'Y'
'1949' = 'Y'
'2090' = 'Y'
'2091' = 'Y'
'2092' = 'Y'
Other='N'
;

*** Endocrine Tumor *** ;
proc format; value $Endo_59_
'20930' = 'Y'
Other='N'
;

*** Female GU Cancer other than Ovary  *** ;
proc format; value $Female_GU_39_
'179' = 'Y'
'180' = 'Y'
'182' = 'Y'
Other='N'
;

*** Female GU Cancer other than Ovary  *** ;
proc format; value $Female_GU_49_
'1840' = 'Y'
'1841' = 'Y'
'1842' = 'Y'
'1843' = 'Y'
'1844' = 'Y'
Other='N'
;

*** Gastro/Esophageal Cancer *** ;
proc format; value $Gastro_39_
'150' = 'Y'
'151' = 'Y'
Other='N'
;

*** Head and Neck Cancer *** ;
proc format; value $HeadNeck_39_
'140' = 'Y'
'143' = 'Y'
'144' = 'Y'
'147' = 'Y'
'149' = 'Y'
'161' = 'Y'
'190' = 'Y'
Other='N'
;

*** Head and Neck Cancer *** ;
proc format; value $HeadNeck_49_
'1410' = 'Y'
'1411' = 'Y'
'1412' = 'Y'
'1413' = 'Y'
'1414' = 'Y'
'1415' = 'Y'
'1416' = 'Y'
'1418' = 'Y'
'1419' = 'Y'
'1420' = 'Y'
'1421' = 'Y'
'1422' = 'Y'
'1428' = 'Y'
'1429' = 'Y'
'1450' = 'Y'
'1451' = 'Y'
'1452' = 'Y'
'1453' = 'Y'
'1454' = 'Y'
'1455' = 'Y'
'1456' = 'Y'
'1458' = 'Y'
'1459' = 'Y'
'1460' = 'Y'
'1461' = 'Y'
'1462' = 'Y'
'1463' = 'Y'
'1464' = 'Y'
'1465' = 'Y'
'1466' = 'Y'
'1467' = 'Y'
'1468' = 'Y'
'1469' = 'Y'
'1480' = 'Y'
'1481' = 'Y'
'1482' = 'Y'
'1483' = 'Y'
'1488' = 'Y'
'1489' = 'Y'
'1600' = 'Y'
'1601' = 'Y'
'1602' = 'Y'
'1603' = 'Y'
'1604' = 'Y'
'1605' = 'Y'
'1608' = 'Y'
'1609' = 'Y'
'1620' = 'Y'
'1950' = 'Y'
Other='N'
;

*** Intestinal Cancer *** ;
proc format; value $Intestinal_39_
'152' = 'Y'
'153' = 'Y'
Other='N'
;

*** Intestinal Cancer *** ;
proc format; value $Intestinal_49_
'1540' = 'Y'
'1541' = 'Y'
Other='N'
;

*** Kidney Cancer *** ;
proc format; value $Kidney_49_
'1890' = 'Y'
Other='N'
;

*** Liver Cancer *** ;
proc format; value $Liver_39_
'155' = 'Y'
Other='N'
;

*** Liver Cancer *** ;
proc format; value $Liver_49_
'1560' = 'Y'
'1561' = 'Y'
'1562' = 'Y'
'1568' = 'Y'
'1569' = 'Y'
Other='N'
;

*** Lung Cancer *** ;
proc format; value $Lung_39_
'165' = 'Y'
Other='N'
;

*** Lung Cancer *** ;
proc format; value $Lung_49_
'1622' = 'Y'
'1623' = 'Y'
'1624' = 'Y'
'1625' = 'Y'
'1628' = 'Y'
'1629' = 'Y'
Other='N'
;

*** Lymphoma *** ;
proc format; value $Lymphoma_39_
'201' = 'Y'
Other='N'
;

*** Lymphoma *** ;
proc format; value $Lymphoma_49_
'2000' = 'Y'
'2001' = 'Y'
'2002' = 'Y'
'2003' = 'Y'
'2004' = 'Y'
'2005' = 'Y'
'2006' = 'Y'
'2007' = 'Y'
'2020' = 'Y'
'2021' = 'Y'
'2022' = 'Y'
'2024' = 'Y'
'2027' = 'Y'
'2008' = 'Y'
'2733' = 'Y'
Other='N'
;

*** Lymphoma *** ;
proc format; value $Lymphoma_59_
'20280' = 'Y'
'20281' = 'Y'
'20282' = 'Y'
'20283' = 'Y'
'20284' = 'Y'
'20285' = 'Y'
'20286' = 'Y'
'20287' = 'Y'
'20288' = 'Y'
'20380' = 'Y'
'20382' = 'Y'
Other='N'
;

*** Malignant Melanoma *** ;
proc format; value $MaligMel_39_
'172' = 'Y'
Other='N'
;

*** Multiple Myeloma *** ;
proc format; value $MultMyeloma_49_
'2030' = 'Y'
'2031' = 'Y'
Other='N'
;

*** Multiple Myeloma *** ;
proc format; value $MultMyeloma_59_
'20381' = 'Y'
Other='N'
;

*** Ovarian Cancer *** ;
proc format; value $Ovarian_49_
'1830' = 'Y'
Other='N'
;

*** Pancreatic Cancer *** ;
proc format; value $Pancreatic_39_
'157' = 'Y'
Other='N'
;

*** Prostate Cancer *** ;
proc format; value $Prostate_39_
'185' = 'Y'
Other='N'
;

*** Atypical chronic myeloid leukemia, BCR/ABL negative *** ;
proc format; value $ACML_49_
'2052' = 'Y'
Other='N'
;

*** Carcinoma in situ of breast *** ;
proc format; value $Insitu_B_49_
'2330' = 'Y'
Other='N'
;

*** Carcinoma in situ of cervix uteri *** ;
proc format; value $Insitu_CU_49_
'2331' = 'Y'
Other='N'
;

*** Carcinoma in situ of middle ear and respiratory system *** ;
proc format; value $Insitu_Resp_39_
'231' = 'Y'
Other='N'
;

*** Carcinoma in situ of oral cavity, esophagus and stomach *** ;
proc format; value $Insitu_OES_49_
'2300' = 'Y'
'2301' = 'Y'
'2302' = 'Y'
Other='N'
;

*** Carcinoma in situ of other and unspecified digestive organs *** ;
proc format; value $Insitu_DIG_49_
'2303' = 'Y'
'2304' = 'Y'
'2305' = 'Y'
'2306' = 'Y'
'2307' = 'Y'
'2308' = 'Y'
'2309' = 'Y'
Other='N'
;

*** Carcinoma in situ of other and unspecified genital organs *** ;
proc format; value $Insitu_Gen_49_
'2332' = 'Y'
'2333' = 'Y'
'2334' = 'Y'
'2335' = 'Y'
'2336' = 'Y'
Other='N'
;

*** Carcinoma in situ of other and unspecified sites *** ;
proc format; value $Insitu_OTH_39_
'234' = 'Y'
Other='N'
;

*** Carcinoma in situ of other and unspecified sites *** ;
proc format; value $Insitu_OTH_49_
'2337' = 'Y'
'2339' = 'Y'
Other='N'
;

*** Carcinoma in situ of skin *** ;
proc format; value $Insitu_Skin_39_
'232' = 'Y'
Other='N'
;

*** Chronic leukemia of unspecified cell type *** ;
proc format; value $CLeuk_49_
'2081' = 'Y'
Other='N'
;

*** Chronic myelomonocytic leukemia *** ;
proc format; value $CMLeuk_49_
'2061' = 'Y'
Other='N'
;

*** Kaposi's sarcoma *** ;
proc format; value $Kaposi_39_
'176' = 'Y'
Other='N'
;

*** Leukemia, unspecified *** ;
proc format; value $LeukUS_49_
'2082' = 'Y'
'2088' = 'Y'
'2089' = 'Y'
Other='N'
;

*** Lymphoid Leukemia, unspecified *** ;
proc format; value $LymphLeukUS_49_
'2049' = 'Y'
Other='N'
;

*** Malignant neoplasm of abdomen *** ;
proc format; value $MN_Abdomen_49_
'1952' = 'Y'
Other='N'
;

*** Malignant neoplasm of bone and articular cartilage of limbs *** ;
proc format; value $MN_Limb_49_
'1704' = 'Y'
'1705' = 'Y'
'1707' = 'Y'
'1708' = 'Y'
Other='N'
;

*** Malignant neoplasm of bone and articular cartilage of other and unspecified sites *** ;
proc format; value $MN_OthBone_49_
'1700' = 'Y'
'1701' = 'Y'
'1702' = 'Y'
'1703' = 'Y'
'1706' = 'Y'
'1709' = 'Y'
Other='N'
;

*** Malignant neoplasm of heart, mediastinum and pleura *** ;
proc format; value $MN_Heart_39_
'163' = 'Y'
Other='N'
;

*** Malignant neoplasm of heart, mediastinum and pleura *** ;
proc format; value $MN_Heart_49_
'1641' = 'Y'
'1642' = 'Y'
'1643' = 'Y'
'1648' = 'Y'
'1649' = 'Y'
Other='N'
;

*** Malignant neoplasm of lower limb *** ;
proc format; value $MN_LL_49_
'1955' = 'Y'
Other='N'
;

*** Malignant neoplasm of other and ill-defined digestive organs *** ;
proc format; value $MN_OTHDIG_39_
'159' = 'Y'
Other='N'
;

*** Malignant neoplasm of other and unspecified female genital organs *** ;
proc format; value $MN_OTHFEM_49_
'1832' = 'Y'
'1833' = 'Y'
'1834' = 'Y'
'1835' = 'Y'
'1838' = 'Y'
'1839' = 'Y'
'1848' = 'Y'
'1849' = 'Y'
Other='N'
;

*** Malignant neoplasm of other specified ill-defined sites *** ;
proc format; value $MN_OTH_49_
'1958' = 'Y'
Other='N'
;

*** Malignant neoplasm of pelvis *** ;
proc format; value $MN_Pelvis_49_
'1953' = 'Y'
Other='N'
;

*** Malignant neoplasm of penis, other, and unspecific male organs *** ;
proc format; value $MN_Male_49_
'1871' = 'Y'
'1872' = 'Y'
'1873' = 'Y'
'1874' = 'Y'
'1875' = 'Y'
'1876' = 'Y'
'1877' = 'Y'
'1878' = 'Y'
'1879' = 'Y'
Other='N'
;

*** Malignant neoplasm of peripheral nerves, autonomic nervous system, and other and connective soft tissue *** ;
proc format; value $MN_Nerves_49_
'1710' = 'Y'
'1712' = 'Y'
'1713' = 'Y'
'1714' = 'Y'
'1715' = 'Y'
'1716' = 'Y'
'1717' = 'Y'
'1718' = 'Y'
'1719' = 'Y'
Other='N'
;

*** Malignant neoplasm of placenta *** ;
proc format; value $MN_Placenta_39_
'181' = 'Y'
Other='N'
;

*** Malignant neoplasm of retroperitoneum and peritoneum *** ;
proc format; value $MN_RP_39_
'158' = 'Y'
Other='N'
;

*** Malignant neoplasm of testis *** ;
proc format; value $MN_Testis_39_
'186' = 'Y'
Other='N'
;

*** Malignant neoplasm of thorax *** ;
proc format; value $MN_Thorax_49_
'1951' = 'Y'
Other='N'
;

*** Malignant neoplasm of thymus *** ;
proc format; value $MN_Thymus_49_
'1640' = 'Y'
Other='N'
;

*** Malignant neoplasm of upper limb *** ;
proc format; value $MN_UL_49_
'1954' = 'Y'
Other='N'
;

*** Malignant neoplasm without specification of site *** ;
proc format; value $MN_wospec_39_
'199' = 'Y'
Other='N'
;

*** MDS *** ;
proc format; value $MDS_59_
'23872' = 'Y'
'23873' = 'Y'
'23874' = 'Y'
'23875' = 'Y'
Other='N'
;

*** Merkel cell carcinoma *** ;
proc format; value $Merkel_59_
'20931' = 'Y'
'20932' = 'Y'
'20933' = 'Y'
'20934' = 'Y'
'20935' = 'Y'
'20936' = 'Y'
Other='N'
;

*** Monocytic leukemia, unspecified *** ;
proc format; value $MonoLeukU_49_
'2062' = 'Y'
'2069' = 'Y'
Other='N'
;

*** Myeloid leukemia, unspecified *** ;
proc format; value $MyeLeukU_49_
'2059' = 'Y'
Other='N'
;

*** Other and unspecified malignant neoplasm of skin *** ;
proc format; value $OthSkin_39_
'173' = 'Y'
Other='N'
;

*** Other and unspecified malignant neoplasms of lymphoid, hematopoietic and related tissue *** ;
proc format; value $OthMNLymph_49_
'2023' = 'Y'
'2025' = 'Y'
'2026' = 'Y'
'2029' = 'Y'
Other='N'
;


*** Other lymphoid leukemia *** ;
proc format; value $Oth_LympLeuk_49_
'2042' = 'Y'
'2048' = 'Y'
Other='N'
;

*** Other monocytic leukemia *** ;
proc format; value $Oth_MonoLeuk_49_
'2068' = 'Y'
Other='N'
;

*** Other myeloid leukemia *** ;
proc format; value $Oth_MyeLeuk_49_
'2058' = 'Y'
Other='N'
;

*** Other specified leukemias *** ;
proc format; value $Oth_SpeLeuk_49_
'2078' = 'Y'
Other='N'
;


*** Secondary: NOS malignant neoplasm of lymph nodes *** ;
proc format; value $Sec_MN_Lymph_39_
'196' = 'Y' 
Other='N'
;

*** Secondary: malignant neoplasm of lymph nodes *** ;
proc format; value $Sec_MN_RespDig_39_
'197' = 'Y' 
Other='N'
;

*** Secondary: malignant neoplasm NOS *** ;
proc format; value $Sec_MN_NOS_39_
'198' = 'Y' 
Other='N'
;

*** Secondary: neuroendocrine tumors *** ;
proc format; value $Sec_neuro_49_
'2097' = 'Y' 
Other='N'
;

/* Added these 8 ICD9 Codes - SGG - H:\OCM - Oncology Care Model\44 - Oncology Care Model 2018\Data from Other Sources\CMS\20170502 - PP3 Updated Materials\OCM Cancer Type Mapping and Codes Effective 07.02.17_20170501.xlsx
*/

*** Essential (hemorrhagic) thrombocythemia *** ;
proc format; value $Ess_Thromb_59_
'23871' = 'Y'
Other='N'
;

*** Osteomyelofibrosis *** ;
proc format; value $Osteo_myelo_59_
'23876' = 'Y'
'28989' = 'Y'
Other='N'
;

*** Myelofibrosis *** ;
proc format; value $Myelo_Fibro_59_
'28983' = 'Y'
Other='N'
;

*** Polycythemia vera *** ;
proc format; value $Poly_Vera_59_
'20710' = 'Y'
'20711' = 'Y'
'20712' = 'Y'
Other='N'
;

*** Polycythemia vera *** ;
proc format; value $Poly_Vera_49_
'2384' = 'Y'
Other='N'
;




********************************************************************************** ;
***************** ICD-10 Diagnosis Codes for Cancer Types ************************ ;
*** Source: OCM Cancer Type Mapping and Codes Effective 07.02.17_20170501.xlsx *** ;
********************************************************************************** ;

*** Acute Leukemia *** ;
proc format; value $Acute_leukemia_410_
'C910'='Y' 
'C913'='Y' 
'C915'='Y' 
'C916'='Y' 
'C91a'='Y' 
'C91A'='Y' 
'C920'='Y' 
'C923'='Y' 
'C924'='Y' 
'C925'='Y' 
'C926'='Y' 
'C92a'='Y' 
'C92A'='Y' 
'C930'='Y' 
'C940'='Y' 
'C942'='Y' 
'C943'='Y' 
'C950'='Y' 
Other='N'
;

*** Anal Cancer*** ;
proc format; value $Anal_310_
'C21'='Y' 
Other='N'
;

*** Bladder Cancer *** ;
proc format; value $Bladder_310_
'C65'='Y' 
'C66'='Y' 
'C67'='Y' 
'C68'='Y' 
Other='N'
;

*** Breast Cancer *** ;
proc format; value $BREAST_310_
'C50'='Y' 
Other='N'
;

*** Chronic Leukemia *** ;
proc format; value $Chronic_Leukemia_410_
'C911'='Y' 
'C921'='Y' 
Other='N'
;

*** CNS Tumor *** ;
proc format; value $CNS_310_
'C70'='Y' 
'C71'='Y' 
'C72'='Y' 
Other='N'
;

*** Endocrine Tumor *** ;
proc format; value $Endo_310_
'C73'='Y' 
'C74'='Y' 
'C75'='Y' 
'C7A'='Y' 
'C7a'='Y'
Other='N'
;

*** Female GU Cancer other than Ovary  *** ;
proc format; value $Female_GU_310_
'C51'='Y' 
'C52'='Y' 
'C53'='Y' 
'C54'='Y' 
'C55'='Y' 
Other='N'
;

*** Gastro/Esophageal Cancer *** ;
proc format; value $Gastro_310_
'C15'='Y' 
'C16'='Y' 
Other='N'
;

*** Head and Neck Cancer *** ;
proc format; value $HeadNeck_310_
'C00'='Y' 
'C01'='Y' 
'C02'='Y' 
'C03'='Y' 
'C04'='Y' 
'C05'='Y' 
'C06'='Y' 
'C07'='Y' 
'C08'='Y' 
'C09'='Y' 
'C10'='Y' 
'C11'='Y' 
'C12'='Y' 
'C13'='Y' 
'C14'='Y' 
'C30'='Y' 
'C31'='Y' 
'C32'='Y' 
'C33'='Y' 
'C69'='Y' 
Other='N'
;

*** Head and Neck Cancer *** ;
proc format; value $HeadNeck_410_
'C760'='Y' 
Other='N'
;

*** Intestinal Cancer *** ;
proc format; value $Intestinal_310_
'C17'='Y' 
'C18'='Y' 
'C19'='Y' 
'C20'='Y' 
Other='N'
;

*** Kidney Cancer *** ;
proc format; value $Kidney_310_
'C64'='Y' 
Other='N'
;

*** Liver Cancer *** ;
proc format; value $Liver_310_
'C22'='Y' 
'C23'='Y' 
'C24'='Y' 
Other='N'
;

*** Lung Cancer *** ;
proc format; value $Lung_310_
'C34'='Y' 
'C39'='Y' 
'C45'='Y' 
Other='N'
;

*** Lymphoma *** ;
proc format; value $Lymphoma_310_
'C81'='Y' 
'C82'='Y' 
'C83'='Y' 
'C84'='Y' 
'C85'='Y' 
'C86'='Y' 
'C88'='Y' 
Other='N'
;

*** Lymphoma *** ;
proc format; value $Lymphoma_410_
'C914'='Y' 
Other='N'
;

*** Malignant Melanoma *** ;
proc format; value $MaligMel_310_
'C43'='Y' 
Other='N'
;

*** MDS *** ;
proc format; value $MDS_310_
'D46'='Y' 
Other='N'
;

*** MDS *** ;
proc format; value $MDS_410_
'C946'='Y' 
Other='N'
;

*** Multiple Myeloma *** ;
proc format; value $MultMyeloma_310_
'C90'='Y' 
Other='N'
;

*** Ovarian Cancer *** ;
proc format; value $Ovarian_310_
'C56'='Y'  
Other='N'
;

*** Pancreatic Cancer *** ;
proc format; value $Pancreatic_310_
'C25'='Y' 
Other='N'
;

*** Prostate Cancer *** ;
proc format; value $Prostate_310_
'C61'='Y' 
Other='N'
;

*** Acute panmyelosis with myelofibrosis *** ;
proc format; value $AcutePan_410_
'C944'='Y' 
Other='N'
;

*** Atypical chronic myeloid leukemia, BCR/ABL negative *** ;
proc format; value $ACML_410_
'C922'='Y' 
Other='N'
;

*** Carcinoma in situ of breast *** ;
proc format; value $Insitu_B_310_
'D05'='Y' 
Other='N'
;

*** Carcinoma in situ of cervix uteri *** ;
proc format; value $Insitu_CU_310_
'D06'='Y' 
Other='N'
;

*** Carcinoma in situ of middle ear and respiratory system *** ;
proc format; value $Insitu_Resp_310_
'D02'='Y' 
Other='N'
;

*** Carcinoma in situ of oral cavity, esophagus and stomach *** ;
proc format; value $Insitu_OES_310_
'D00'='Y' 
Other='N'
;

*** Carcinoma in situ of other and unspecified digestive organs *** ;
proc format; value $Insitu_DIG_310_
'D01'='Y' 
Other='N'
;

*** Carcinoma in situ of other and unspecified genital organs *** ;
proc format; value $Insitu_Gen_310_
'D07'='Y' 
Other='N'
;

*** Carcinoma in situ of other and unspecified sites *** ;
proc format; value $Insitu_OTH_310_
'D09'='Y' 
Other='N'
;

*** Carcinoma in situ of skin *** ;
proc format; value $Insitu_Skin_310_
'D04'='Y'  
Other='N'
;

*** Chronic leukemia of unspecified cell type *** ;
proc format; value $CLeuk_410_
'C951'='Y' 
Other='N'
;

*** Chronic myelomonocytic leukemia *** ;
proc format; value $CMLeuk_410_
'C931'='Y' 
Other='N'
;

*** Juveline myelomonocytic leukemia *** ;
proc format; value $JMLeuk_410_
'C933'='Y' 
Other='N'
;

*** Kaposi's sarcoma *** ;
proc format; value $Kaposi_310_
'C46'='Y' 
Other='N'
;

*** Leukemia, unspecified *** ;
proc format; value $LeukUS_410_
'C959'='Y' 
Other='N'
;

*** Lymphoid Leukemia, unspecified *** ;
proc format; value $LymphLeukUS_410_
'C919'='Y' 
Other='N'
;

*** Malignant neoplasm of abdomen *** ;
proc format; value $MN_Abdomen_410_
'C762'='Y' 
Other='N'
;

*** Malignant neoplasm of bone and articular cartilage of limbs *** ;
proc format; value $MN_Limb_310_
'C40'='Y' 
Other='N'
;

*** Malignant neoplasm of bone and articular cartilage of other and unspecified sites *** ;
proc format; value $MN_OthBone_310_
'C41'='Y' 
Other='N'
;

*** Malignant neoplasm of heart, mediastinum and pleura *** ;
proc format; value $MN_Heart_310_
'C38'='Y' 
Other='N'
;

*** Malignant neoplasm of lower limb *** ;
proc format; value $MN_LL_410_
'C765'='Y' 
Other='N'
;

*** Malignant neoplasm of other and ill-defined digestive organs *** ;
proc format; value $MN_OTHDIG_310_
'C26'='Y' 
Other='N'
;

*** Malignant neoplasm of other and unspecified female genital organs *** ;
proc format; value $MN_OTHFEM_310_
'C57'='Y' 
Other='N'
;

*** Malignant neoplasm of other specified ill-defined sites *** ;
proc format; value $MN_OTH_410_
'C768'='Y' 
Other='N'
;

*** Malignant neoplasm of pelvis *** ;
proc format; value $MN_Pelvis_410_
'C763'='Y' 
Other='N'
;

*** Malignant neoplasm of penis, other, and unspecific male organs *** ;
proc format; value $MN_Male_310_
'C60'='Y' 
'C63'='Y' 
Other='N'
;

*** Malignant neoplasm of peripheral nerves, autonomic nervous system, and other and connective soft tissue *** ;
proc format; value $MN_Nerves_310_
'C47'='Y' 
'C49'='Y' 
Other='N'
;

*** Malignant neoplasm of placenta *** ;
proc format; value $MN_Placenta_310_
'C58'='Y' 
Other='N'
;

*** Malignant neoplasm of retroperitoneum and peritoneum *** ;
proc format; value $MN_RP_310_
'C48'='Y' 
Other='N'
;

*** Malignant neoplasm of testis *** ;
proc format; value $MN_Testis_310_
'C62'='Y' 
Other='N'
;

*** Malignant neoplasm of thorax *** ;
proc format; value $MN_Thorax_410_
'C761'='Y' 
Other='N'
;

*** Malignant neoplasm of thymus *** ;
proc format; value $MN_Thymus_310_
'C37'='Y' 
Other='N'
;

*** Malignant neoplasm of upper limb *** ;
proc format; value $MN_UL_410_
'C764'='Y' 
Other='N'
;

*** Malignant neoplasm without specification of site *** ;
proc format; value $MN_wospec_310_
'C80'='Y' 
Other='N'
;

*** Melanoma in situ *** ;
proc format; value $Insitu_Mela_310_
'D03'='Y' 
Other='N'
;

*** Merkel cell carcinoma *** ;
proc format; value $Merkel_310_
'C4A'='Y' 
'C4a'='Y' 
Other='N'
;

*** Monocytic leukemia, unspecified *** ;
proc format; value $MonoLeukU_410_
'C939'='Y' 
Other='N'
;

*** Myeloid leukemia, unspecified *** ;
proc format; value $MyeLeukU_410_
'C929'='Y' 
Other='N'
;

*** Other and unspecified malignant neoplasm of skin *** ;
proc format; value $OthSkin_310_
'C44'='Y' 
Other='N'
;

*** Other and unspecified malignant neoplasms of lymphoid, hematopoietic and related tissue *** ;
proc format; value $OthMNLymph_310_
'C96'='Y' 
Other='N'
;

*** Other lymphoid leukemia *** ;
proc format; value $Oth_LympLeuk_410_
'C91z'='Y' 
'C91Z'='Y' 
Other='N'
;

*** Other monocytic leukemia *** ;
proc format; value $Oth_MonoLeuk_410_
'C93z'='Y' 
'C93Z'='Y' 
Other='N'
;

*** Other myeloid leukemia *** ;
proc format; value $Oth_MyeLeuk_410_
'C92z'='Y' 
'C92Z'='Y' 
Other='N'
;

*** Other specified leukemias *** ;
proc format; value $Oth_SpeLeuk_410_
'C948'='Y' 
Other='N'
;

*** Secondary: NOS malignant neoplasm of lymph nodes *** ;
proc format; value $Sec_MN_Lymph_310_
'C77' = 'Y' 
Other='N'
;

*** Secondary: malignant neoplasm of lymph nodes *** ;
proc format; value $Sec_MN_RespDig_310_
'C78' = 'Y' 
Other='N'
;

*** Secondary: malignant neoplasm NOS *** ;
proc format; value $Sec_MN_NOS_310_
'C79' = 'Y' 
Other='N'
;

*** Secondary: neuroendocrine tumors *** ;
proc format; value $Sec_neuro_310_
'C7B' = 'Y' 
Other='N'
;

/* 5 ICD10 Codes Added - SGG H:\OCM - Oncology Care Model\44 - Oncology Care Model 2018\Work Papers\SAS\000_Formats 20170808.sas
 */

*** Polycythemia vera *** ;
proc format; value $Poly_Vera_310_
'D45' = 'Y'
Other='N'
;

*** Chronic myeloproliferative disease *** ;
proc format; value $Chro_Myelo_410_
'D471' = 'Y'
Other='N'
;

*** Essential (hemorrhagic) thrombocythemia *** ;
proc format; value $Ess_Thrombo_410_
'D473' = 'Y'
Other='N'
;

*** Osteomyelofibrosis *** ;
proc format; value $Osteo_Myelo_410_
'D474' = 'Y'
Other='N'
;

*** Myelofibrosis *** ;
proc format; value $Myelo_Fibro_510_
'D7581' = 'Y'
Other='N'
;


run ;
