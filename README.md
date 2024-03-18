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

The VMS data from 2008 to present is storedin VMS1_.Rds.  Older data (pre 2008) is stored in VMSold_.Rds  I have constrained the datasets to permits that held a scallop permit.
These two datasets contain the permit number, lat and lon, and a timestamp. I used Oracle's to_char(POS_SENT_DATE,'YYYY MON DD HH24:MI:SS'), I believe the underlying data is timezone encoded and this should handle daylight savings time automatically.







## Trips and Landings
This is extracted from CAMS_LAND and CAMS_SUBTRIP.  Each CAMSID represents a trip.  



# NOAA Requirements
This repository is a scientific product and is not official communication of the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code is provided on an *as is* basis and the user assumes responsibility for its use. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.


1. who worked on this project:  Min-Yang Lee
1. when this project was created: 2015, uploaded to github in August 2023. 
1. what the project does: extracts data for the Karl Aspelund's project.
1. why the project is useful:  Gets data 
1. how users can get started with the project: Download and follow the readme
1. where users can get help with your project:  email me or open an issue
1. who maintains and contributes to the project. Min-Yang

# License file
See here for the [license file](License.txt)
