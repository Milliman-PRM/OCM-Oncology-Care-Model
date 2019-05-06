
libname in "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Performance\Feb19";
libname metadat "H:\Nonclient\Medicare Bundled Payment Reference\General\SAS Datasets";
libname ms19 "\\chic-win-fs2\Other\Medispan\MDDB\Temp";

%include "H:\_HealthLibrary\SAS\000 - General SAS Macros.sas";
%let exportDir=H:\OCM - Oncology Care Model\44 - Oncology Care Model 2019\Work Papers\Interface Materials;


data claims_ndc;
set in.claims_interface: 
	in.claims_emerge: ;
keep NDC;
run; 

proc sort data = claims_ndc nodupkey;
	by NDC;
run;

proc sql;
create table NDCs_to_add as
	select NDC from claims_ndc
	where NDC not in (select distinct NDC from metadat.NDC_descriptions)
	;
quit;

proc sql;
	create table ndc_medispan as
	select a.NDC, b.productdescriptionabbreviated
	from NDCs_to_add as A
	left join ms19.manufacturer_name as B
	on a.NDC = b.NDC
	;
quit;

%sas_2_xl(ndc_medispan,NDCs_to_add_20190210.xlsx);

