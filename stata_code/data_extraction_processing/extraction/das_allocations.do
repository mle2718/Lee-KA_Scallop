#delimit;

/* When sole goes down, this chunk will break because there is not dblink */
clear;
odbc load,  exec("select * from das.allocation@garfo_nefsc where plan='SC';") $mysole_conn;  
rename plan fmp;
rename category_name das_type;

destring, replace;
keep if fishing_year<2007;

save $my_workdir/das_allocations_$today_date_string.dta, replace ;



/*AMS -- 2007 to Present */
clear;

odbc load,  exec("select *  from NEFSC_GARFO.AMS_ALLOCATION_TX where FMP in ('SCAL', 'SCAG') ;") $myNEFSC_USERS_conn;  
destring, replace;
keep if fishing_year>=2007;

collapse (sum) quantity, by(fishing_year fmp allocation_type root_mri unit) ;
rename allocation_type credit_type;
rename root_mri right_id;
compress;
rename right_id mri;
preserve;
keep if inlist(credit_type,"LEASE IN", "LEASE OUT");
save $my_workdir/ams_leases_$today_date_string.dta, replace ;

restore;
drop if inlist(credit_type,"LEASE IN", "LEASE OUT");
collapse (sum) quantity, by(mri fishing_year);
rename quantity categoryA_DAS;

sort mri fishing_year;
save $my_workdir/ams_allocations_$today_date_string.dta, replace ;
