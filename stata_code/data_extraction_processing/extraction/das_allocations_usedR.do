

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



/* DAS schema data */
/* usage */
#delimit ;
clear;


jdbc connect, jar("$jar")  driverclass("$classname")  url("$GARFO_URL")  user("$myuid") password("$mygarfopwd");

jdbc load, exec("select du.das_trip_id, dt.vms_trip_id, du.permit_debited as permit,  dt.activity_code,  dt.trip_start as date_sail, dt.trip_end as date_land,  dt.observer , du.fishing_year,
du.allocation_use_type, du.credit_type as das_type, du.quantity as charge, du.category_name as fishing_area, du.credit_type from das2.allocation_use du , das2.das_trip dt
    where du.das_trip_id=dt.das_trip_id
    and 
    du.plan='SC' and du.quantity>0 order by date_sail") case(lower);  

gen source="DAS2G";
gen fishing_hours=hours(date_land-date_sail);
gen fishing_days=fishing_hours/24;


save $my_workdir/das2_usage_$today_date_string.dta, replace;



/* this query works */

#delimit ;

clear;
odbc load,  exec("select das_id as ams_das_id, trip_id as ams_trip_id, permit_nbr as permit, activity_code, date_sail, date_land, observer, fishing_year, fishing_area, das_type, charge from NEFSC_GARFO.AMS_TRIP_AND_CHARGE where fmp='SCAL' and charge<>0 and fishing_year>=2007;") $myNEFSC_USERS_conn;  
destring, replace;
compress;
gen fishing_hours=hours(date_land-date_sail);
gen fishing_days=fishing_hours/24;


gen source="AMS";
tempfile ams; 
save $my_workdir/ams_usage_$today_date_string.dta, replace;



 /* Code above works. Need to stack together and makes sure the variables are the same */






