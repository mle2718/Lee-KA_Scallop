#delimit;

local land_vars CAMSID, SUBTRIP, DOCID, VTRSERNO, DATE_TRIP, DLR_DATE, YEAR, MONTH, DLRID, DLR_UTILCD, ITIS_TSN, NEGEAR, GEAR_SOURCE, MESH_SOURCE, VTR_MESH, MESH_IMP_METHOD,AREA,
	ITIS_GROUP1, DLR_MKT, DLR_GRADE, DLR_DISP, LNDLB, LIVLB, VALUE, PORT, STATE,STATUS;



/* Landings -- we can ignore landings from the recreational fleet. */
clear;
timer clear 99;
timer on 99;
	odbc load,  exec("select `land_vars' from CAMS_GARFO.CAMS_LAND where year>=2004 and REC=0;") $oracle_cxn;
timer off 99;
	renvarlab, lower;
	destring subtrip docid dlrid dlr_utilcd itis_tsn negear area dlr_mkt dlr_grade dlr_disp port, replace;
	format port %06.0fc;
	compress;

save $my_workdir/cams_land_$today_date_string.dta, replace ;
/* VTR ORPHAN landings -- we can ignore landings from the recreational fleet. */

clear;
timer clear 98;
timer on 98;

	odbc load,  exec("select `land_vars' from CAMS_GARFO.CAMS_VTR_ORPHANS where year>=2004 and REC=0;") $oracle_cxn;
timer off 98;

	renvarlab, lower;
	destring subtrip docid dlrid dlr_utilcd itis_tsn negear area dlr_mkt dlr_grade dlr_disp port, replace;
	format port %06.0fc;
	compress;
save $my_workdir/cams_land_vtr_orphans_$today_date_string.dta, replace ;


odbc load, exec("select table_name, column_name, comments from all_col_comments where owner='CAMS_GARFO' and table_name='CAMS_LAND' order by column_name;") $oracle_cxn ; 

save $my_workdir/cams_land_description_$today_date_string.dta, replace ;


# delimit ; 
/* subtrip level attributes */



local trip_vars CAMSID, PERMIT, DOCID, SUBTRIP, VTRSERNO, AREA, NEGEAR, VTR_MESH, MESH_CAT, N_SUBTRIP, RECORD_SAIL, VES_LEN, VES_GTONS,
	RECORD_LAND, DATE_TRIP, YEAR, VTR_TRIPCATG, VTR_CREW, VTR_DEPTH , VTR_IMGID , VTR_ACTIVITY, VTR_ACTIVITY_DESC, VTR_GEAR_SIZE, 
	VTR_GEAR_QTY, LAT_DD, LON_DD, DF, DA, EFFORT_IMP, ACTIVITY_CODE_1, ACTIVITY_CODE_2, SECTID, TRIPCATEGORY, ACCESSAREA, GEARTYPE ;

clear;
timer clear 97;
timer on 97;

odbc load,  exec("select `trip_vars' from CAMS_GARFO.CAMS_SUBTRIP where year>=2004 and permit in (select permit from mlee.KA_PERMITS);") $oracle_cxn;
timer off 97;
	renvars, lower;
	destring permit docid subtrip area negear vtr_activity effort_imp sectid, replace;
	compress;

save $my_workdir/cams_subtrip_$today_date_string.dta, replace ;


/* subtrip level attributes for VTR Orphans*/

clear;
timer clear 96;
timer on 96;


clear;
odbc load,  exec("select `trip_vars' from CAMS_GARFO.CAMS_VTR_ORPHANS_SUBTRIP where year>=2004 and permit in (select permit from mlee.KA_PERMITS);") $oracle_cxn;
timer off 96;
renvars, lower;
destring permit docid subtrip area negear vtr_activity effort_imp sectid, replace;
compress;
save $my_workdir/cams_vtr_orphans_subtrip_$today_date_string.dta, replace ;





clear;
odbc load, exec("select table_name, column_name, comments from all_col_comments where owner='CAMS_GARFO' and table_name='CAMS_SUBTRIP' order by column_name;") $oracle_cxn ; 

save $my_workdir/cams_subtrip_description_$today_date_string.dta, replace ;


timer list;


