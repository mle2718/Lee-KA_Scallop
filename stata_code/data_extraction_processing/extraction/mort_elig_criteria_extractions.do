#delimit;
clear;
/* DAS table only has has Multispecies in it. 
*/



/* DAS2 tables have been taken offline.  Not sure how to get allocations of DAS prior to 2007 
clear;
odbc load,  exec("select * from das2.allocation@GARFO_NEFSC where plan='MUL' and category_name='A';") $oracle_cxn;  
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
tempfile ams;
odbc load,  exec("select fishing_year ,unit, das_type, root_mri, fmp, sum(quantity) as quantity  from NEFSC_GARFO.AMS_ALLOCATION_TX where FMP in ('SCAL', 'SCAG') and allocation_type in ('BASE', 'BASE ADJUST', 'CARRY OVER', 'CARRY OVER ADJUST', OVERAGE', 'SANCTION') 
	group by fishing_year ,unit, das_type, root_mri, fmp
	order by fishing_year, root_mri, fmp, das_type, unit;") $oracle_cxn;  
destring, replace;
keep if fishing_year>=2007;
rename allocation_type credit_type;
rename root_mri right_id;
compress;
save `ams', replace;
clear;










/*

odbc load,  exec("select per_num, right_id, hull_id, vessel, date_eligible, date_cancelled, auth_type, remark, len, hp , fishery from mqrs.mort_elig_criteria@GARFO_NEFSC mq  
where fishery in ('SCALLOP', 'GENERAL CATEGORY SCALLOP') 
AND date_eligible is not null 
AND (date_cancelled>=to_date('05/01/2000','MM/DD/YYYY') or date_cancelled is null) 
AND ((date_cancelled > date_eligible) or date_cancelled is null);") $oracle_cxn;  
preserve;


*/



replace auth_type="CPH" if strmatch(auth_type,"HISTORY RETENTION");
replace auth_type="CPH" if auth_type=="HISTORY RETENTION" ;



saveold $my_workdir/mqrs_old_$today_date_string.dta, replace version(12);

#delimit;
drop remark* vessel hull;
dups, drop terse;
drop _expand;
forvalues j=2000(1)$lastyr{;
	gen a`j'=0;
	local k=`j'+1;
	replace a`j'=1 if dofc(date_eligible)<mdy(5,1,`k') & dofc(date_cancelled)>=mdy(5,1,`j');
	bysort right_id (date_eligible) : gen t`j'=sum(a`j');
	replace a`j'=0 if t`j'>1;
	drop t`j';
};

rename auth_type type_auth;
collapse (sum) a*, by(per right type_auth);


compress;
reshape long a, i(per_num right_id type_auth) j(fishing_year);
drop auth_id;
replace a=1 if a>=1;
drop if a==0;


drop a;
rename per_num permit;
qui compress;
notes: made by "mort_elig_criteria-extractions.do";
rename right_id mri;
merge 1:1 mri fishing_year using `ams';
keep if fishing_year>=2004;
drop if type_auth=="";
notes: A permit number doesn't get detached from a MRI in CPH until that MRI comes out of CPH. An owner can sells a permit separate from history, putting the history into CPH.  If this happens there may be 2 links between a right_id and a permit. The actual one is the one NOT IN CPH.  ;

drop _merge;
saveold $my_workdir/mqrs_annual_$today_date_string.dta, replace version(12);
