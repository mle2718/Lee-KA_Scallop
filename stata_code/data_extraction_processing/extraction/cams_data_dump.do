#delimit;


/* Landings */
clear;
	odbc load,  exec("select CAMSID, DOCID, VTRSERNO, DATE_TRIP, DATE, YEAR, MONTH, DLRID, DLR_UTILCD, ITIS_TSN, ITIS_GROUP1, DLR_MKT as market_code, DLR_GRADE as grade_code, DLR_DISP,
		LNDLB, LIVLB, VALUE, PORT, STATE from CAMS_GARFO.CAMS_LAND where year>=2004 and permit in (select permit from mlee.KA_PERMITS);") $oracle_cxn;
	renvarlab, lower;
	destring, replace;
	compress;

save $my_workdir/cams_landings_$today_date_string.dta, replace ;


/* trip level attributes */
odbc load,  exec("select CAMSID, PERMIT, DOCID, SUBTRIP, VTRSERNO, AREA, NEGEAR, VTR_MESH, MESH_CAT
	N_SUBTRIP, RECORD_SAIL, RECORD_LAND, DATE_TRIP, YEAR, VTR_TRIPCATG, VTR_CREW 
	VTR_DEPTH , VTR_IMGID , VTR_GEAR_SIZE, VTR_GEAR_QTY, LAT_DD, LON_DD, DF, DA, ACTIVITY_CODE_1, ACTIVITY_CODE_2 from CAMS_GARFO.CAMS_SUBTRIP where year>=2004 and permit in (select permit from mlee.KA_PERMITS);") $oracle_cxn;
	renvars, lower;
	renvars, presub("VTR_" "");
save $my_workdir/cams_subtrip_$today_date_string.dta, replace ;



/* KEYFILES */




