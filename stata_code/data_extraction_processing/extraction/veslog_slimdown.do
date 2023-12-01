#delimit;

/* Slim down the Veslog data to just include vessels that have ever had a scallop permit*/

use  $my_workdir/veslog_T$today_date_string.dta, replace ;

merge m:1 permit using $my_workdir/permit_population_$today_date_string;
keep if _merge==3;
save  $my_workdir/veslog_Tslim_$today_date_string.dta, replace ;

keep tripid;
duplicates drop;
tempfile tripids;
save `tripids', replace;


use $my_workdir/veslog_G$today_date_string.dta, replace ;
merge m:1 tripid using `tripids';
keep if _merge==3;
drop _merge;
save  $my_workdir/veslog_Gslim_$today_date_string.dta, replace ;



use $my_workdir/veslog_S$today_date_string.dta, replace ;
merge m:1 tripid using `tripids';
keep if _merge==3;
drop _merge;
save  $my_workdir/veslog_Sslim_$today_date_string.dta, replace ;

	
