
#delimit;
clear;
odbc load,  exec("select * from nefsc_garfo.das_valid_activity_code;") $oracle_cxn;  
save $my_workdir/das_activity_codes_$today_date_string.dta, replace ;


/*AMS -- 2007 to Present */
clear;
odbc load,  exec("select * from nefsc_garfo.ams_das_activity_codes;") $oracle_cxn;  
rename description activity_description;
rename das_type das_category;
save $my_workdir/ams_activity_codes_$today_date_string.dta, replace ;

/* this is broken */

/*


clear;
odbc load,  exec("select * from das2.valid_activity_code;") $oracle_cxn;  
save $my_workdir/das2_activity_codes.dta, replace ;
*/
