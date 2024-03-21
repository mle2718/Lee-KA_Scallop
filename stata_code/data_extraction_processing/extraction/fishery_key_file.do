#delimit;
/*This is code to extract key-files or support tables. 
Part A. PLAN and Category - DOne
Part B. Species Codes -DONE
Part C. Port codes

*/


/* Part A. PLAN and Category */
clear;
odbc load, exec("select fishery_id, plan, cat, permit_year, descr, moratorium_fishery, mandatory_reporting, per_yr_start_date, per_yr_end_date from nefsc_garfo.permit_valid_fishery;")  $oracle_cxn; 
renvars, lower;
notes: made by "fishery_key_file.do";
notes: moratorium_fishery=T means limited access. You can also verify this from the "descr" field. ;
notes: While SF and OQ (Surfclam and Ocean Quahog) are open acces, they are also IFQ fisheries. Anyone can get an open access permit, but an operator would need to hold IFQ to fish for surfclam or ocean quahog;
save $my_workdir/fishery_keyfile_$today_date_string.dta, replace;


/* Part B. Species Codes*/
clear;
odbc load,  exec("select distinct species_itis as itis_tsn, common_name, scientific_name, grade_code, grade_desc, market_code, market_desc, cf_lndlb_livlb from nefsc_garfo.cfdbs_species_itis_ne;") $oracle_cxn;
destring, replace;
compress;
renvars, lower;
notes: made by "fishery_key_file.do";

save  $my_workdir/species_keyfile_$today_date_string.dta, replace;

