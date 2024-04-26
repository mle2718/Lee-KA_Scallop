global data_vintage 2024_04_26



/* I have my data stored in the folder $data_main */
use $data_main/cams_subtrip_${data_vintage}.dta
merge  1:m camsid subtrip using $data_main/cams_land_${data_vintage}
keep if itis_tsn==79718


/* checkout what's going on with the mis-merge */
tab status if _merge==2


browse if status=="PZERO" & _merge==2
tab state if status=="PZERO" & _merge==2
tab year state if status=="PZERO" & _merge==2
summ lndlb if status=="PZERO"& _merge==2, detail
centile lndlb if status=="PZERO" & _merge==2, centile(1 2 5 10 25 50 90 95 99)