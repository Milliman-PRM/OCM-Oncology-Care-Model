********************************************************************** ;
*****Code to create HCPCS-BETOS crosswalk for PP1 Recon Processing*****;
********************************************************************** ;

libname in "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Performance\FBQ05";
libname out "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\90 - Investigations\HCPCS_BETOS";

options ls=132 ps=70 obs =max;

%macro stack(claim) ;

data stacked_&claim. (keep=HCPCS_CD BETOS);
	set in.&claim._137_50136
		in.&claim._255_50179
		in.&claim._257_50195
		in.&claim._278_50193
		in.&claim._280_50115
		in.&claim._290_50202
		in.&claim._396_50258
		in.&claim._401_50228
		in.&claim._459_50243
		in.&claim._468_50227
		in.&claim._480_50185
		in.&claim._523_50330;
run;
%mend stack; run;

%stack(phyline); run;
%stack(dmeline); run;

data stacked_all;
	set stacked_phyline
		stacked_dmeline;

	Combined=HCPCS_CD||"-"||BETOS;
run;

proc sort data=stacked_all
		out=out.HCPCS_BETOS_Crosswalk
		NODUPKEY;
	by Combined;
run;
