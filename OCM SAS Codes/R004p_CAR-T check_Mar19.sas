********************************************************************** ;
****************** R004p_CAR-T check_Mar19.sas *********************** ;
****************** Doer: Dan Muldoon		   *********************** ;
****************** Checker: 				   *********************** ;
********************************************************************** ;

***Set Libraries where we store reconciliation claims;
libname recraw "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP1";
libname recraw2 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP2";
libname recraw3 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\06 - Read-In Raw Data\Reconciliation\PP3";
libname recpro "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP1";
libname recpro2 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP2";
libname recpro3 "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP3";


/*CMS CAR-T Logic
	An episode is identified as having CAR-T therapy if at least one CAR-T claim is found during the episode
	in either the inpatient or outpatient file, utilizing procedure codes as opposed to NDC or drug codes.

	It is important to note that the episode must have already been defined according to the existing methodology and that the CAR-T does not initiate an episode. 
	
	An inpatient claim must 
		(1) have an admission date during the episode,
		(2) have either ICD10 procedure code XW033C3 or XW043C3, and
		(3) have a blank value in the Medicare nonpayment reason code field. 
	
	An outpatient claim must
	(1) have a from or through date during the episode
	(2) a HCPCS procedure code of Q2040 or Q2041
	(3) have a blank value in the Medicare nonpayment reason code field. 
*/

/* Note from Dan:
	Before chekcing for nonpayment reason codes, just check to see if we observe any of the ICD10 procedure or HCPCS codes for any episodes
	beyond the two that CMS flags as being CAR-T:
		1. OCM 137 PP3 - ep_id 492133182241
		2. OCM 137 PP3 - ep_id 554204019718

	If no, then we agree with CMS for recon. If we observe other episodes, then look at other criteria.
*/


/**********************
***INPATIENT
***********************/
data car_t_ip_pre;
set 
	recraw3.iphdr_137_50136 (in=a)
	recraw3.iphdr_255_50179 (in=b)
	recraw3.iphdr_257_50195 (in=c)
	recraw3.iphdr_278_50193 (in=d)
	recraw3.iphdr_280_50115 (in=e)
	recraw3.iphdr_290_50202 (in=f)
	recraw3.iphdr_396_50258 (in=g)
	recraw3.iphdr_401_50228 (in=h)
	recraw3.iphdr_459_50243 (in=i)
	recraw3.iphdr_468_50227 (in=j)
	recraw3.iphdr_480_50185 (in=k)
	recraw3.iphdr_523_50330 (in=l)
	;

	if a then ocm_id='137';
	if b then ocm_id='255';
	if c then ocm_id='257';
	if d then ocm_id='278';
	if e then ocm_id='280';
	if f then ocm_id='290';
	if g then ocm_id='396';
	if h then ocm_id='401';
	if i then ocm_id='459';
	if j then ocm_id='468';
	if k then ocm_id='480';
	if l then ocm_id='523';	

	source='IP';

	*initialize car-t variable;
	car_t=0;
	
	* loop through procedure codes and flag for car_t;
	ARRAY d2 (z) ICD_PRCDR_CD1-ICD_PRCDR_CD25 ;
	DO z = 1 TO dim(d2) ;
		if d2 in ('XW033C3','XW043C3') then car_t=1;
	end;

	if car_t=1;

run;

proc sort data=car_t_ip_pre (keep=ocm_id ep_id nopay_cd source) out=car_t_ip nodupkey; by ocm_id ep_id;
run;


/**********************
***OUTPATIENT
***********************/
data car_t_op_pre;
set 
	recraw3.outrev_137_50136 (in=a)
	recraw3.outrev_255_50179 (in=b)
	recraw3.outrev_257_50195 (in=c)
	recraw3.outrev_278_50193 (in=d)
	recraw3.outrev_280_50115 (in=e)
	recraw3.outrev_290_50202 (in=f)
	recraw3.outrev_396_50258 (in=g)
	recraw3.outrev_401_50228 (in=h)
	recraw3.outrev_459_50243 (in=i)
	recraw3.outrev_468_50227 (in=j)
	recraw3.outrev_480_50185 (in=k)
	recraw3.outrev_523_50330 (in=l)
	;

	if a then ocm_id='137';
	if b then ocm_id='255';
	if c then ocm_id='257';
	if d then ocm_id='278';
	if e then ocm_id='280';
	if f then ocm_id='290';
	if g then ocm_id='396';
	if h then ocm_id='401';
	if i then ocm_id='459';
	if j then ocm_id='468';
	if k then ocm_id='480';
	if l then ocm_id='523';	

	source='OP';

	*initialize car-t variable;
	car_t=0;
	
	* flag hcpcs codes for car_t;
	if hcpcs_cd in ('Q2040','Q2041') then car_t=1;
	
	if car_t=1;

run;

proc sort data=car_t_op_pre (keep=ocm_id ep_id source) out=car_t_op nodupkey; by ocm_id ep_id;
run;


/**********************
***Combine IP and OP
***********************/
data car_t_all;
set
	car_t_ip
	car_t_op
	;
run;

proc sort data=car_t_all ; by ocm_id ep_id;
run;


/**********************
***Export
***********************/
PROC EXPORT DATA=car_t_all
    OUTFILE = "R:\data\HIPAA\OCM_Oncology_Care_Model_PP\07 - Processed Data\Reconciliation\PP3\Recon Reports\recon_pp3_car_t_check_20190313"
    dbms=xlsx replace ;
    quit ;
