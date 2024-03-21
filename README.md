# Project Description
This is a data extraction repository for Karl's Scallop project


One of the inputs to this data processing code are "cleaned" ports, which are an output of (https://github.com/NEFSC/READ-SSB-Lee-spacepanels)
# How to use
1. Clone. Run the ``/stata_code/data_extraction_processing/extraction/00_extraction_wrapper.do`` file

# On passwords and other confidential information

You will need to have an NEFSC oracle user/password set up and stored.

For stata users, there is a description [here](/documentation/project_logistics.md). 


# About the Data 

Data vintages -- I append "YYYY_MM_DD"  to the file name to track when I've extracted data

## Keyfiles

The following datasets are keyfiles that are useful for decoding numeric codes into somthing that is intelligible.

1.  ams_activity_codes and das -- the activity code is the type of fishing that a vessel declared into.  For scallop, vessels may declare into days at Sea or access area trips.   
2.  cams_port_codes -- these decode a six digit numeric code to a port name and state
3.  dealer_keyfile -- this converts a dealer identification number to a business with a street address.
4.  fishery_kefile- this is a description of a Plan and Category. The most relevant ones for this project will be plan='SC', 'LGC' and  'SCG'
5.  species keyfile- this contains the itis tsn and the market and grade codes. The most relevant rows are its_tsn=79718.


## Ownership data

There are three datasets

* ownership2010_present_ : This contains one observation per permit number and year, for 2010 to present.  Each row will have a business_name, which is submitted by the permit holder.  GARFO also creates a numeric identifier (business_id).  We have identifiers associated with the business. These are stored in the person_idN columns.  Rows with identical people that own it are further grouped into "affiliate_ids".  The ap_year is the year.  There may be vessels for which we don't have ownership information. For the scallop fishery, this is unlikely.

* ownership_pre2010_ : This is similar to the previous dataset, with 3 differences. 
1.  It only contains information for vessels that held a scallop OR groundfish permit. 
2.  It doesn't have an "affiliate_id"
3.  The names are intermixed with the identifiers.	


* names_ : this contains the business names, person identifiers, and first, middle, and last names.


## Scallop Rights

The dataset "scallop_rights" contains the 
	Right_id, hull_id, and permit and the range of dates for which the right was associated a particular vessel.  This will be useful if you are trying to track either the usage of Scallop Days-at-Sea, the transfer of LA Access Area trips from one vessel to another, or the allocations/transfer/usage of IFQ.


## Permit and Vessel Characteristics

permit_portfolio -- 
	This contains one row per vessel-year. It includes hull_id, permit, vessel name, a mailing address, hailing port, "principal port", vessel size (gross and net tons, length), maximum crew.  It also has a set of categorical variables to indicate the type of permit a vessel held.  The ones to focus on are SC_*, SG_* (scallop general category), and LGC_* (Limited access general category).  I've marked those with the categorical "has_scallop_permit"

## VMS data

The VMS data from 2008 to present is stored in VMS1_.Rds.  Older data (pre 2008) is stored in VMSold_.Rds  I have constrained the datasets to permits that held a scallop permit.
These two datasets contain the permit number, lat and lon, and a timestamp. I used Oracle's to_char(POS_SENT_DATE,'YYYY MON DD HH24:MI:SS'), I believe the underlying data is timezone encoded and this should handle daylight savings time automatically.





## Trips and Landings

Trips and Landings come from [CAMS](http://nerswind/cams/cams_documentation/), which is a new system that matches trip reports, dealer reports, and all sorts of other data.

Records that match at the level of trip and ITIS_GROUP1 are assigned “MATCH” status. VTR records that match at the trip level but not at the ITIS_GROUP1 level are labeled as “VTR_ORPHAN_SPECIES”. VTR records that do not match at the trip level are labeled as “VTR_ORPHAN_TRIP”. Dealer records that match at the trip level but not at the ITIS_GROUP1 level receive a status of “DLR_ORPHAN_SPECIES” and those that do not match at the trip level have a status of “DLR_ORPHAN_TRIP”. There are also VTR records that do not match to dealer records but have zero landings (VTR_KEPT = 0). These are divided into status = ‘VTR_DISCARD’ (VTR_KEPT = 0 & VTR_DISCARD > 0) and status = ‘VTR_NO_CATCH’ (VTR_KEPT = 0 & VTR_DISCARD = 0). These VTR records with no landings are unioned to the combined DLR-VTR landings. Finally, the VTR records with positive landings (VTR_KEPT > 0) that were indicated as not being sold to the dealer (disposition NOT_SOLD and BHC) are unioned to the combined DLR-VTR data and assigned a status of “VTR_NOT_SOLD”.


CAMS_LAND contains transaction level landings. A transaction is the transfer from a vessel to a dealer of a particular market category and grade of fish.  For scallops, the market categories are things like U10, 10-20, 20-30, etc. For cod, this would be something like Scrod, Small, Market, Large, or Whale.  For scallops, the grade codes are "Meat, Shell-on."  For Cod, the grade codes could be "Gutted", "Gutted Head off", "Round", "Gutted Head on."  This will be useful for constructing revenue and prices.  I have extracted *all* records.

CAMS_SUBTRIP contains "logbook level" information on trips.  Each CAMSID represents a trip.  Distinct "CAMSID + SUBTRIP" correspond to a "subtrip."  I have extracted records for permits that have ever had a scallop permit.

CAMS_SUBTRIP and CAMS_LAND should be joined on "CAMSID and SUBTRIP."

```
global data_vintage 2024_03_20
clear
use cams_subtrip_${data_vintage}.dta
bysort camsid subtrip: assert _N==1
merge  1:m camsid subtrip using cams_land_${data_vintage}
```
You should expect this merge to produce:
rows in "subtrip" with no landings (_merge==1) -- this could means a vessel went out fishing, but did not land.See the VTR_ACTIVITY and VTR_ACTIVITY_DESC fields.
rows in "land" with not trip (_merge=2). These are trips by vessels without a scallop permit and are therefore outside the population. They can be dropped when constructing 'trip' information.


VTR trip-level mismatches (status = ‘VTR_ORPHAN_TRIPS’) are considered either preliminary until dealer reports are entered or bad data that might be duplication of dealer trip orphans (status = ‘DLR_ORPHAN_TRIPS’) and are therefore not included in the official record of landings in CAMS_LAND. These VTR trip orphans are separated into their own identical table, CAMS_VTR_ORPHANS and the associated subtrips in CAMS_VTR_ORPHANS_SUBTRIP

I've included these as well.

The cams_land_description dataset describes the columns in ``cams_land'' and ``cams_land_VTR_ORPHANS_''

The cams_subtrip_description datsest describe the columns in ``cams_subtrip'' and ``cams_vtr_orphans_subtrip''. There are additional columns in the raw data that I did not extract. 



# NOAA Requirements
This repository is a scientific product and is not official communication of the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code is provided on an *as is* basis and the user assumes responsibility for its use. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.


1. who worked on this project:  Min-Yang Lee
1. when this project was created: 2023. 
1. what the project does: extracts data for the Karl Aspelund's project.
1. why the project is useful:  Gets data 
1. how users can get started with the project: Download and follow the readme
1. where users can get help with your project:  email me or open an issue
1. who maintains and contributes to the project. Min-Yang

# License file
See here for the [license file](License.txt)
