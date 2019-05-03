********************************************************************** ;
********************************************************************** ;
********************************************************************** ;
**** To prepare data for this program:
	 (1) Files received in Excel form.
	 (2) Copy rows beginning with navy blue column headers down to end of data into a blank excel.
	 (3) Format date fields to be 03/14/14 - DOB, Episode Beginning Date, Episode Ending Date, Most Recent E&M.
	 (4) Save file as tab delimited text file with same file name as original Excel . *** ;

%let indir1 =R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Attribution_PP1_TrueUp2 ;
%let outdir = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP1" ;
libname r2 &outdir. ;

options ls=132 ps=70 obs =max;

********************************************************************** ;
********************************************************************** ;
%let cdate1 = 20181107;  *** date in file names *** ;

%let pp = 1 ;
%let version = TrueUp2 ;

/*
%let pp = 2 ;
%let version = TrueUp1 ;
*/
/*
%let pp = 3 ;
%let version = Initial ;
*/
********************************************************************** ;
********************************************************************** ;

%macro reads(dsid,ds) ;

data r2.ATT_PP&pp.&version._&dsid. ;
    infile "&indir1.\OCM_&ds.\OCM_&dsid._attribution_PP&pp.&version._&cdate1..txt" lrecl=10000 dlm='09'x dsd missover firstobs=2;
    input
		BENE_HICN 				:$12.
		MBI						:$50.
		EP_ID					:best32.
		BENE_ID					:$15.
		FIRST_NAME				:$15.
		LAST_NAME				:$24.
		DOB						:MMDDYY8.
		SEX						:$1.
		EP_BEG_A				:MMDDYY8.
		EP_END_A				:MMDDYY8.
		CANCER_TYPE_A				:$100.
		RECON_ELIG_A				:$1.
		EM_VISIT_FOR_CANC			:8.
		MOST_RECENT_EM				:MMDDYY8./*
		OCM_REGISTRY				:$1.  */;

		FORMAT DOB EP_BEG_A EP_END_A MOST_RECENT_EM MMDDYY10. ;	
		
proc freq data=r2.ATT_PP&pp.&version._&dsid.  ;
	tables EP_BEG_A MOST_RECENT_EM DOB;
	FORMAT EP_BEG_A MOST_RECENT_EM YYMM6. DOB YEAR4. ;
TITLE "&DSID." ; RUN ;

%mend reads ; run ;
********************************************************************** ;
********************************************************************** ;
********************************************************************** ;

%reads(137_50136,137) ; run ;
%reads(255_50179,255) ; run ;
%reads(257_50195,257) ; run ;
%reads(278_50193,278) ; run ;
%reads(280_50115,280) ; run ;
%reads(290_50202,290) ; run ;
%reads(396_50258,396) ; run ;
%reads(401_50228,401) ; run ;
%reads(459_50243,459) ; run ;
%reads(468_50227,468) ; run ;
%reads(480_50185,480) ; run ;
%reads(523_50330,523) ; run ;

***OCMs 567 and 568 are only ran for PP1***;
%reads(567_50200,567) ; run ;
%reads(568_50201,568) ; run ;


