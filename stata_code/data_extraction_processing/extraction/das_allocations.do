#delimit;

/* gone from sole and no dblink
clear;
odbc load,  exec("select * from das2.allocation where plan='MUL' and category_name='A';") $oracle_cxn;  
rename plan fmp;
rename category_name das_type;

destring, replace;
keep if fishing_year>=2006 & fishing_year<=2008;

tempfile das2;
collapse (sum) quantity, by(right_id credit_type fishing_year);
compress;
save `das2', replace;
*/


/*AMS -- 2007 to Present */
clear;

odbc load,  exec("select *  from ams.allocation_tx@GARFO_NEFSC where FMP in ('SCAL', 'SCAG') ;") $oracle_cxn;  
destring, replace;
keep if fishing_year>=2007;

collapse (sum) quantity, by(fishing_year fmp allocation_type root_mri unit) ;
rename allocation_type credit_type;
rename root_mri right_id;
compress;
rename right_id mri;
preserve;
keep if inlist(credit_type,"LEASE IN", "LEASE OUT");
save $my_workdir/das_leases_$today_date_string.dta, replace ;

restore;
drop if inlist(credit_type,"LEASE IN", "LEASE OUT");
collapse (sum) quantity, by(mri fishing_year);
rename quantity categoryA_DAS;
save `das2', replace;

sort mri fishing_year;
save $my_workdir/das_allocations_$today_date_string.dta, replace ;
