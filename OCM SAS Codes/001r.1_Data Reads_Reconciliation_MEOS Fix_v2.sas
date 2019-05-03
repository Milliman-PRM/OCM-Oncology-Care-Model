********************************************************************** ;
********************************************************************** ;
********************************************************************** ;
*** Need to recheck with column headers in file each and every submission. *** ;

%let outdir = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP1" ;
*%let outdir = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP2" ;
*%let outdir = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP3" ;

%let indir = R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP1_TrueUp2 ;
*%let indir = R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP2_TrueUp1 ;
*%let indir = R:\data\HIPAA\OCM_Oncology_Care_Model_PP\03 - Reconciliation Data\Recon_PP3 ;

libname out &outdir. ;

options ls=132 ps=70 obs =max;

********************************************************************** ;
********************************************************************** ;
%let cdate = 20190228;  *** date in file names *** ;

%let perf = PP1trueup2 ;  *** performance period file submission *** ;
*%let perf = PP2trueup1 ;  *** performance period file submission *** ;
*%let perf = PP3initial ;  *** performance period file submission *** ;

%let tu = 2 ; *** blank for initial recon, 1 for first true-up, 2 for second true-up *** ;
*%let tu = 1 ; *** blank for initial recon, 1 for first true-up, 2 for second true-up *** ;
*%let tu =  ; *** blank for initial recon, 1 for first true-up, 2 for second true-up *** ;

********************************************************************** ;
********************************************************************** ;

%macro reads_fix(dsid,did,special) ;

data PHYMEOSLINE&tu._&dsid.;
	set out.PHYLINE&tu._&dsid. ;
	where hcpcs_cd ^= 'G9678';
run;

data out.PHYMEOSLINE&tu._&dsid.;
	set PHYMEOSLINE&tu._&dsid.
		out.MEOSLINE&tu._&dsid. ;
run;


data phymeoshdr&tu._&dsid.;
	set out.phyhdr&tu._&dsid. (in=a)
		out.meoshdr&tu._&dsid. (in=b) ;

	format file_source $4.;
	if a then file_source = 'PHY';
	else if b then file_source = 'MEOS';

	proc sort; by bene_id clm_id;
run;

data clmheader out.duplicate_MEOS&tu._&dsid.;
	set phymeoshdr&tu._&dsid.;
	by bene_id clm_id;

	if first.clm_id then output clmheader;
	else output out.duplicate_MEOS&tu._&dsid.;
run;

proc sql;
	create table out.phymeoshdr&tu._&dsid. as
	select a.*
	from clmheader as a
	where a.clm_id in (select distinct clm_id from out.PHYMEOSLINE&tu._&dsid.);
quit;

proc sql;
	create table out.dropped_phymeoshdr&tu._&dsid. as
	select a.*
	from clmheader as a
	where a.clm_id not in (select distinct clm_id from out.PHYMEOSLINE&tu._&dsid.);
quit;


%mend reads_fix ; run ;

%reads_fix(137_50136,137,) ; run ;
%reads_fix(255_50179,255,) ; run ;
%reads_fix(257_50195,257,) ; run ;
%reads_fix(278_50193,278,) ; run ;
%reads_fix(280_50115,280,) ; run ;
%reads_fix(290_50202,290,) ; run ;
%reads_fix(396_50258,396,) ; run ;
%reads_fix(401_50228,401,) ; run ;
%reads_fix(459_50243,459,) ; run ;
%reads_fix(468_50227,468,) ; run ;
%reads_fix(480_50185,480,) ; run ;
%reads_fix(523_50330,523,) ; run ;

*** Only available in PP1 processing *** ;
%reads_fix(567_50200,567,) ; run ;
%reads_fix(568_50201,568,) ; run ;

