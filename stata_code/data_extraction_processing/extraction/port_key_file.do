#delimit;
clear;

odbc load,  exec("select port, port_name, state_abb, county_name, port_GRP from CAMS_GARFO.CFG_PORT;") $oracle_cxn;
renvars, lower;

destring, replace;
notes: made by "port_key_file.do" ;

save $my_workdir/cams_port_codes_$today_date_string.dta, replace ;





