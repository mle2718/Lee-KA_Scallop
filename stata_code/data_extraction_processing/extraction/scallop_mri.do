/* THIS BIT OF CODE IS USED TO EXTRACT VESSEL PERMITS*/
#delimit;

clear;
/*odbc load,  exec("select * from bgaluardi.ifq_scal_combo;") $mygarfo_conn;   */
odbc load,  exec("select * from mlee.IFQ_MRI;") $oracle_cxn;
rename mri right_id;
gen das_ifq=1;
tempfile dual;
save `dual';


clear;
odbc load,  exec("select right_id, hull_id, per_num as permit, vessel, date_eligible, date_cancelled, auth_type, fishery from nefsc_garfo.mqrs_mort_elig_criteria mq  
where fishery in ('SCALLOP','GENERAL CATEGORY SCALLOP') AND date_eligible is not null 
AND (date_cancelled>=to_date('05/01/2000','MM/DD/YYYY') or date_cancelled is null) 
AND ((date_cancelled > date_eligible) or date_cancelled is null);") $oracle_cxn;  


    destring, replace;
    renvars, lower;
    

	merge m:1 right_id using `dual';
	drop _merge;
	sort right_id date_eligible date_cancelled;
	
save $my_workdir/scallop_rights_$today_date_string, replace;



