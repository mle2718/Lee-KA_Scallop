#delimit;

/* When sole goes down, this chunk will break because there is no dblink 
clear;
odbc load,  exec("select * from das.allocation@garfo_nefsc where plan='SC';") $mysole_conn;  
rename plan fmp;
rename category_name das_type;

destring, replace;
keep if fishing_year<2007;

save $my_workdir/das_allocations_$today_date_string.dta, replace ;

*/



/* DAS at GARFO */

clear;

jdbc connect, jar("$jar")  driverclass("$classname")  url("$GARFO_URL")  user("$myuid") password("$mygarfopwd");


jdbc load,  exec("select category_name as fishing_area, right_id as mri, fishing_year, plan as fmp, credit_type, unit_of_measure as unit, sum(quantity) as quantity, category_name as  from das.allocation where plan in 'SC' 
group by right_id, category_name, fishing_year, plan, credit_type, unit_of_measure") case(lower);  
destring, replace;
gen source="DASG";

save $my_workdir/DASG_allocations_$today_date_string.dta, replace ;


clear;
jdbc load,  exec("select category_name as fishing_area, right_id as mri, fishing_year, plan as fmp, credit_type, unit_of_measure as unit, sum(quantity) as quantity from das2.allocation where plan in 'SC' 
group by right_id, category_name, fishing_year, plan, credit_type, unit_of_measure") case(lower);  

destring, replace;

gen source="DAS2G";

save $my_workdir/DAS2G_allocations_$today_date_string.dta, replace ;

#delimit;

/*AMS -- 2007 to Present */
clear;

odbc load,  exec("select *  from NEFSC_GARFO.AMS_ALLOCATION_TX where FMP in ('SCAL', 'SCAG') ;") $myNEFSC_USERS_conn;  
destring, replace;
keep if fishing_year>=2007;

collapse (sum) quantity, by(fishing_year fmp allocation_type root_mri unit allocation_type fishing_area) ;
rename allocation_type credit_type;
rename root_mri right_id;
compress;
rename right_id mri;
gen source="AMS";
preserve;
keep if inlist(credit_type,"LEASE IN", "LEASE OUT", "EXCHANGE IN", "EXCHANGE OUT");
notes: Lease in and Lease out are transfers of IFQ (for dollars or some other kind of compensation) ; 
notes: exchange in and exchange out are 1:1 swaps of Access Area trips or pounds.;

save $my_workdir/ams_leases_$today_date_string.dta, replace ;

restore;
drop if inlist(credit_type,"LEASE IN", "LEASE OUT","EXCHANGE IN", "EXCHANGE OUT");
collapse (sum) quantity, by(mri fishing_year unit credit_type fishing_area);

sort mri fishing_year;
save $my_workdir/ams_allocations_$today_date_string.dta, replace ;
