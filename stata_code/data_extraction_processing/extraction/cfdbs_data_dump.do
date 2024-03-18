#delimit;

/* should probably replace this with CAMS_LAND (and CAMS_DISCARD)*/ 
clear;

	odbc load,  exec("select sum(spplndlb) as landings, sum(spplivlb) as live, sum(sppvalue) as value, port, year,  month, day, nespp4,  species_itis, grade_code, market_code  from NEFSC_GARFO.CFDERS_ALL_YEARS
		where spplndlb is not null and dealnum<>1385 and (dealnum<>4062 and permit<>241397)
		and spplndlb>=1 and sppvalue/spplndlb<=40
		and year between $firstders and $lastyr
		group by port, year, month, day, nespp4, species_itis, grade_code, market_code ;") $oracle_cxn;
	renvarlab, lower;
	destring, replace;
	compress;

gen date=mdy(month, day, year);
format date %td;
compress;

save $my_workdir/cfdbs_$today_date_string.dta, replace ;
