

/*

	DAS (2004-2006)
	AMS (2007-present)



For 2009 to present,
	AMS.TRIP_AND_CHARGE has permit_nbr, datesail and dateland and the charge.
		Charge type is T, C, S.
			1 'C' entry and it's negative. (Compensation?)
			4 'S' entries.  All from FY 2016. MULT_MONK_USAGE.
		Running clock is Y/N

		AMS.lease_exch_applic
 */

#delimit;


*quietly do "/home/mlee/Documents/Workspace/technical folder/do file scraps/odbc_connection_macros.do";
*global oracle_cxn "conn("$mysole_conn") lower";
local date: display %td_CCYY_NN_DD date(c(current_date), "DMY");
global today_date_string = subinstr(trim("`date'"), " " , "_", .);
clear;

tempfile das2_usage das1_usage reg_use2006 das2a initial vaf;



/* DAS schema data*/
/* usage */
#delimit ;
clear;

odbc load,  exec("select du.fishing_year, du.das_transaction_id, du.permit_number as permit, du.das_charged_days as charge, tr.sail_date_time as date_sail, tr.landing_date_time as date_land, tr.observer_onboard, tr.fishery_code as activity_code, tr.vessel_name, du.trip_length_days 		
	from das.das_used@GARFO_NEFSC du, das.trips@GARFO_NEFSC tr where du.das_transaction_id=tr.das_transaction_id and du.permit_number=tr.permit_number and du.fishery='SCA' and fishing_year between 2004 and 2006 and charge>0;") $oracle_cxn;  

gen schema="DAS";

save `das1_usage',replace;


/* this query works */


clear;
odbc load,  exec("select das_id as ams_das_id, trip_id as ams_trip_id, permit_nbr as permit, activity_code, date_sail, date_land, observer, fishing_year, fishing_area, das_type, charge from AMS.TRIP_AND_CHARGE@GARFO_NEFSC where fmp='SCAL' and charge<>0 and fishing_year>=2007;") $oracle_cxn;  
destring, replace;
compress;


gen schema="AMS";
tempfile ams; 
save `ams', replace;



 /* Code above works. Need to stack together and makes sure the variables are the same */



/* not sure where this dataset comes from  */
use $my_workdir/ams_activity_codes.dta, replace;
keep if fmp=="SCAL";
keep activity_code activity_description charge_name das_category;
gen str4 schema="AMS";

tempfile ams_das2;
save `ams_das2';

use `ams', replace;
merge m:1 schema activity_code using `ams_das2', keep( 1 3);
assert _merge==3;
drop _merge;
save `ams', replace;
append using `das2_usage';


gen fishing_hours=hours(date_land-date_sail);

order fishing_days charge_by_hand external_charge, after(charge);
compress;
rename das_trip_id das2_trip_id;
order das_transaction das2_trip_id ams_trip_id ams_das_id;
drop plan category_name;


save $my_workdir/das_usage_$today_date_string.dta, replace;




/*
/*AMS lease data */

odbc load,  exec("select lease_exch_id,from_permit, to_permit, from_right, to_right, fishing_year, quantity, price, approval_date from ams.lease_exch_applic@das08_11g.nero.gl.nmfs.gov 
	where FMP='MULT' and from_das_type='A-DAYS' and approval_status='APPROVED' and fishing_year>=2009;") dsn("cuda") user(mlee) password($mynero_pwd) lower clear;
destring, replace;
rename to_permit permit_buyer;
rename from_permit permit_seller;
rename to_right right_id_buyer;
rename from_right right_id_seller;
compress;
rename approval_date date_of_trade;
rename price dollar_value;
replace date_of_trade=dofc(date_of_trade);
format date_of_trade %td;


gen schema="AMS" ;



/*stack on DAS2 and DAS leases */
append using `das2_leases';
append using `dl1';
/* fix another broken entry */

replace date=mdy(month(date),day(date),2004)    if transfer_id==815
saveold $my_workdir/leases_$today_date_string.dta, replace version(12);



*/


