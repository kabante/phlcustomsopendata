/*

An Open Data Set of Twenty Million Import Transactions
from the Bureau of Customs of the Philippines from 2012 to 2019.

Author: 		Kenneth Isaiah Ibasco Abante
				Research Faculty
				Department of Interdisciplinary Studies, School of Humanities
				Ateneo de Manila University, Philippines
				kabante@ateneo.edu

Do file: 		clean.do
Description: 	Clean publicly available import data from the Bureau of Customs
				for 2012-2013 (quarterly) and 2014-2019(monthly)
				
Paper:			https://www.researchgate.net/publication/339066219
Data:			bit.ly/phlcustomsopendata

Created: 		1 August 2019
Last updated:	6 February 2020

Input:			2012_Q1.dta to 2013_Q4.dta, 2014_01.dta to 2019_09.dta
Output:			boc_all_complete.dta, boc_all_lite.dta

																			  */

********************************************************************************
*table of contents
*00 put file path and log
*01 fix misaligned elements for certain months and quarters
*02 check availability of variables of raw data
*03 drop unnecessary variables and standardize variable names across data sets
*04 append the data sets into annual files
*05 clean country variables
*06 clean port variables
*07 clean entry variables
*08 clean currency and generate value, quantity, and price variables
*09 append annual files into one file
*10 encode categorical variables
*11 clean time variables
*12 save final complete file; save annual complete files
*13 save final lite file; save annual lite files (fewer variables)

********************************************************************************

clear
capture log close
set more off

*00 put file path and log

	capture cd "put your file name here where the raw .dta files can be found" 

	capture log using "put your log file name here", replace

********************************************************************************

*01 fix misaligned elements for certain months and quarters

	*those not opened here have been inspected and are okay.

	use 2012_q3_raw, clear
		replace goodsdescription = goodsdescription + var21 if var21 != ""
		drop var21
		save 2012_q3, replace
		
	use 2013_q1_raw, clear
		drop if hscode == "HSCODE"
		save 2013_q1, replace

	use 2013_q4_raw, clear
		replace goodsdescription = goodsdescription + var21 if var21 != ""
		drop var21
		save 2013_q4, replace
	
	use 2015_09_raw, clear
	
		replace normalduty = trim(normalduty)
		destring normalduty, gen(temp2) force
			replace grossmasskgs = netmasskgs if temp2 == .
			replace netmasskgs = customsvalue if temp2 == .
			replace customsvalue = currency if temp2 == .
			replace currency = dutiablevalueforeigncurrency if temp2 == .
			replace dutiablevalueforeigncurrency = exchangerate if temp2 == .
			replace exchangerate = string(dutiablevaluephp) if temp2 == .
			
		replace preferentialcode = trim(preferentialcode)
		destring preferentialcode, gen(temp) ignore(",") force
			replace dutiablevaluephp = temp if temp2 == .
			replace preferentialcode = normalduty if temp2 == .
			replace normalduty = string(actualduty) if temp2 == .

		replace dutypaid = trim(dutypaid) 
		replace dutypaid = "0" if dutypaid == "-"	
		destring dutypaid, gen(temp3) ignore(",") force
			replace dutyforgone = trim(dutyforgone)
			replace dutyforgone = "0" if dutyforgone == "-"
		
		destring dutyforgone, gen(temp4) ignore(",") force
			replace actualduty = temp3 if temp2 == .				
			replace dutypaid = dutyforgone if temp2 == .
			replace dutyforgone = vatbase if temp2 == .
			replace vatbase = vatpaid if temp2 == .
			replace vatpaid = exciseadvalorem if temp2 == .
			replace exciseadvalorempaid = finesandpenalties if temp2 == .
			replace finesandpenalties = othertax if temp2 == .
			replace othertax = dutiestaxes if temp2 == . 
			replace dutiestaxes = entrycode if temp2 == .
			replace entrycode = port if temp2 == .
			replace entrycode = "" if temp2 == .
			replace port = "" if temp2 == .		
			replace *4digit = hscodeanddescription6digit if temp2 ==.
			replace *6digit = hscodeanddescription11digit if temp2 == .
			replace *11digit = typeofentry if temp2 == .
			replace typeofentry = "" if temp2 == .

		gen error2 = 1 if typeofentry != "C" & typeofentry != "T" & typeofentry != "W" & typeofentry != "C-Temp" & typeofentry != ""
			replace goodsdescription = netmasskgs if error2 == 1
			replace grossmasskgs = customsvalue if error2 == 1
			replace netmasskgs = currency if error2 == 1
			replace customsvalue = dutiablevalueforeigncurrency if error2 == 1
			replace currency = exchangerate if error2 == 1
			replace dutiablevalueforeigncurrency = string(dutiablevaluephp) if error2 == 1
			replace exchangerate = preferentialcode if error2 == 1
			replace dutiablevaluephp = temp2 if error2 == 1
			replace preferentialcode = string(actualduty) if error2 == 1
			replace preferentialcode = "" if preferentialcode == "."
			replace normalduty = dutypaid if error2 == 1
			replace actualduty = temp4 if error2 == 1
			replace dutypaid = vatbase if error2 == 1
			replace dutyforgone = vatpaid if error2 == 1
			replace vatbase = exciseadvalorempaid if error2 == 1
			replace vatpaid = finesandpenalties if error2 == 1
			replace exciseadvalorempaid = othertax if error2 == 1
			replace finesandpenalties = dutiestaxes if error2 == 1
			replace othertax = entrycode if error2 == 1
			replace dutiestaxes = entrycode if error2 == 1
			replace entrycode = port if error2 == 1
			replace *4digit = hscodeanddescription6digit if error2 == 1
			replace *6digit = hscodeanddescription11digit if error2 == 1
			replace *11digit = typeofentry if error2 == 1
			replace typeofentry = "" if error2 == 1
			drop temp* error*
		
		save 2015_09, replace
	
	use 2016_04, clear
		drop if control_no == ""
		save 2016_04, replace
	
	use 2016_05, clear
		drop if control_no == ""
		save 2016_05, replace
		
	use 2016_06, clear
		drop if control_no == ""
		save 2016_06, replace
	
	use 2016_07, clear
		drop if control_no == ""
		save 2016_07, replace
		
	use 2016_08, clear
		drop if control_no == ""
		save 2016_08, replace
	
	use 2016_09, clear
		capture gen entry = substr(entry_code, -8, 1)
		save 2016_09, replace
		
	use 2016_10, clear
		capture gen entry = substr(entry_code, -8, 1)
		save 2016_10, replace
		
	use 2016_11, clear
		capture gen entry = substr(entry_code, -8, 1)
		save 2016_11, replace
		
	use 2016_12, clear
		capture gen entry = substr(entry_code, -8, 1)
		save 2016_12, replace
		
	use 2017_01, clear
		capture gen entry = substr(entry_code, -8, 1)
		capture replace goods_description = goods_description + var36 if var36 != ""
		capture drop var36
		save 2017_01, replace
		
	use 2017_02, clear
		capture gen entry = substr(entry_code, -8, 1)
		capture replace goods_description = goods_description + var36 if var36 != ""
		capture drop var36
		save 2017_02, replace
	
	use 2017_03, clear
		capture gen entry = substr(entry_code, -8, 1)
		capture replace goods_description = goods_description + var36 if var36 != ""
		capture drop var36
		save 2017_03, replace

	use 2017_04, clear
		capture gen entry = substr(entry_code, -8, 1)
		capture replace goods_description = goods_description + var36 if var36 != ""
		capture drop var36
		save 2017_04, replace
		
	use 2017_05, clear
		capture gen entry = substr(entry_code, -8, 1)
		save 2017_05, replace

	use 2017_06, clear
		capture gen entry = substr(entry_code, -8, 1)
		capture replace goods_description = goods_description + var36 if var36 != ""
		capture drop var36
		save 2017_06, replace

	use 2017_07, clear	
		capture gen entry = substr(entry_code, -8, 1)
		capture replace goods_description = goods_description + var36 if var36 != ""
		capture drop var36
		save 2017_07, replace
		
	use 2017_08, clear	
		capture gen entry = substr(entry_code, -8, 1)
		capture replace goods_description = goods_description + var36 if var36 != ""
		capture drop var36
		save 2017_08, replace
		
	use 2017_09, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2017_09, replace

	use 2017_10, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2017_10, replace

	use 2017_11, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2017_11, replace
	
	use 2017_12, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2017_12, replace

	use 2018_01, clear
		capture drop u
		save 2018_01, replace
		
	use 2018_05, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2018_05, replace
	
	use 2018_06, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2018_06, replace
		
	use 2018_07, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2018_07, replace
		
	use 2018_08, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2018_08, replace
		
	use 2018_09, clear
		capture gen var22b = string(var22) if var22 != .
		capture replace goodsdescription = goodsdescription + var21 + var22b + var23 if var21 != ""
		capture drop var21 var22 var22b var23
		save 2018_09, replace

	use 2018_10, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2018_10, replace

	use 2018_11, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2018_11, replace
		
	use 2018_12, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2018_12, replace

	use 2019_01, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2019_01, replace

	use 2019_02, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2019_02, replace
	
	use 2019_03, clear		
		capture replace goodsdescription = goodsdescription + var21 + var22 if var21 != "" | var22 != ""
		capture drop var21 var22
		save 2019_03, replace
	
	use 2019_04, clear
		capture replace goodsdescription = goodsdescription + var21 + var22 if var21 != "" | var22 != ""
		capture drop var21 var22
		save 2019_04, replace

	use 2019_05, clear
		capture replace goodsdescription = goodsdescription + var21 + var22 if var21 != "" | var22 != ""
		capture drop var21 var22
		save 2019_05, replace

	use 2019_06, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2019_06, replace
		
	use 2019_07, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2019_07, replace
		
	use 2019_08, clear
		capture replace goodsdescription = goodsdescription + var21 + var22 + var23 if var21 != "" | var22 != "" | var23 != ""
		capture drop var21 var22 var23
		save 2019_08, replace
		
	use 2019_09, clear
		capture replace goodsdescription = goodsdescription + var21 + var22 + var23 if var21 != "" | var22 != "" | var23 != ""
		capture drop var21 var22 var23
		save 2019_09, replace
	
	use 2019_10, clear
		capture replace goodsdescription = goodsdescription + var21 + var22 + var23 + var24 if var21 != "" | var22 != "" | var23 != "" | var24 != ""
		capture drop var21 var22 var23 var24
		save 2019_10, replace
		
	use 2019_11, clear
		capture replace goodsdescription = goodsdescription + var21 if var21 != ""
		capture drop var21
		save 2019_11, replace
		
	use 2019_12, clear
		capture replace goodsdescription = goodsdescription + var21 + var22 if var21 != "" | var22 != ""
		capture drop var21 var22
		save 2019_12, replace
	
********************************************************************************

*02 check availability of variables of raw data

	*output: variable_clean.xlsx, which shows the variable list per file
	
	local k = 0

	forvalues y = 2012(1)2013{

		forvalues j = 1(1)4 {

			local k = `k' + 1
			
			use `y'_q`j', clear

				ds, alpha 
				
				putexcel A`k'=("`y'_q`j'") B`k'=("`r(varlist)'") using variable_clean, modify
				
		}

	}


	local month "01 02 03 04 05 06 07 08 09 10 11 12"

	forvalues y = 2014(1)2019{

		foreach j of local month {

			local k = `k' + 1

			capture noisily use `y'_`j', clear
				capture noisily ds, alpha
				capture noisily putexcel A`k'=("`y'_`j'") B`k'=("`r(varlist)'") using variable_clean, modify

		}
		
	}

********************************************************************************

*03 drop unnecessary variables and standardize variable names across data sets

*03-a quarterly (2012q1 to 2013q4)

	forvalues y = 2012(1)2013 {

		forvalues i = 1(1)4 {

			use `y'_q`i', clear

		*generate time variable
			capture noisily gen time = "`y'" + "q" + "`i'"
			
		*drop blank rows
			capture noisily drop if hscode == ""

		*drop variables
			capture noisily drop control*
			capture noisily drop item_no
			capture noisily drop insurancecurrency	
			capture noisily drop freightcurrency
			capture noisily drop othercostcurrency
			
			capture noisily drop hscode2
			capture noisily drop description_11digit	
			capture noisily drop description11digit	
			capture noisily drop hscodeanddescription11digi
			capture noisily drop hscodeanddescription11digit
			capture noisily drop hscodedesc
			
			capture noisily drop description_4digit
			capture noisily drop description4digit
			capture noisily drop hscodeanddescription4digit
			capture noisily drop hscode4

			capture noisily drop description_6digit	
			capture noisily drop description6digit	
			capture noisily drop hscodeanddescription6digit 
			capture noisily drop hscode6

		*standardize variables across data sets
			capture noisily rename typeofentry 			entry
			capture noisily rename eserial 				entry
			capture noisily rename entry_code 			entrycode

			capture noisily rename country_export 		countryexport
			
			capture noisily rename country_origin 		countryorigin
			capture noisily rename countryoforigin 		countryorigin

			capture noisily rename pref_code 			prefcode
			capture noisily rename preferrentialcode 	prefcode
			capture noisily rename preferentialcode 	prefcode

			capture noisily rename dutyforegone 		dutyforgone
			capture noisily rename duty_forgone 		dutyforgone

			capture noisily rename actualduty 			actualdutyrate
			capture noisily rename actual_duty 			actualdutyrate

			capture noisily rename normalduty 			normaldutyrate
			capture noisily rename normal_duty 			normaldutyrate

			capture noisily rename netmass				netmasskgs
			capture noisily rename grossmass			grossmasskgs

			capture noisily rename customsvalue			customsvalue

			capture noisily rename currency				currency

			capture noisily rename exchange_rate		exchangerate

			capture noisily rename arrastre				arrastre
			capture noisily rename insurance			insurance
			capture noisily rename freight				freight
			capture noisily rename othercost			othercost
			capture noisily rename wharfage				wharfage

			capture noisily rename dutiable_foreign 	dutiablevalueforeign
			capture noisily rename dutiablevalueforeigncurrency dutiablevalueforeign

			capture noisily rename dutiablevalue_php	dutiablevaluephp

			capture noisily rename duty_paid			dutypaid

			capture noisily rename exciseadvalorempaid	exciseadvalorem
			capture noisily rename excise_advalorem_paid exciseadvalorem

			capture noisily rename vattaxbase			vatbase
			capture noisily rename vat_base				vatbase
			capture noisily rename vat_paid				vatpaid

			capture noisily rename penalties			finesandpenalties

			capture noisily rename goodsdescriptiondeclared goodsdescription
			capture noisily rename goods_description	goodsdescription
			
		
		*change string into numeric variables
		
			local numeric "dutyforgone actualdutyrate normaldutyrate netmasskgs grossmasskgs customsvalue exchangerate arrastre insurance freight othercost wharfage dutiablevalueforeign dutiablevaluephp dutypaid exciseadvalorem vatbase vatpaid othertax finesandpenalties dutiestaxes"
			
				foreach j of local numeric {
					capture noisily replace `j' = trim(`j')
					capture noisily replace `j' = "0" if `j' == "-"
					capture noisily destring `j', replace ignore(",")
				}			

		*change numeric into string variables
			
			local string "entry entrycode natl_proc_code extended_proc_code port countryexport countryorigin prefcode currency hscode goodsdescription"

				foreach j of local string {
					capture noisily tostring `j', replace
					capture noisily replace `j' = trim(`j')
				}
	
		*force destring dutyforgone and netmasskgs with negative values
		
			capture noisily destring dutyforgone, replace ignore(",") force		// See *03-c for individual checks
			capture noisily destring netmasskgs, replace ignore(",") force		// See *03-c for individual checks
		
		*generate unique identification numbers
		
			capture gen id = _n
			capture tostring id, replace format(%08.0f)
			
			capture gen uid = time + " " + id
			capture drop id
	
			save `y'_q`i'_varnamesclean, replace
			
		}
	}


*03-b monthly (2014 01 to 2019 09)

	forvalues y = 2014(1)2019 {
	
	local month "01 02 03 04 05 06 07 08 09 10 11 12"
	
		foreach m of local month {

			capture noisily use `y'_`m', clear

		*generate time variable
			capture noisily gen time = "`y'" + "`m'"

		*drop blank rows
			capture noisily drop if hscode == ""

		*drop variables
			capture noisily drop control*
			capture noisily drop item_no
			capture noisily drop insurancecurrency	
			capture noisily drop freightcurrency
			capture noisily drop othercostcurrency
			
			capture noisily drop hscode2
			capture noisily drop description_11digit	
			capture noisily drop description11digit	
			capture noisily drop hscodeanddescription11digi
			capture noisily drop hscodeanddescription11digit
			capture noisily drop hscodedesc	
			capture noisily drop description_4digit
			capture noisily drop description4digit
			capture noisily drop hscodeanddescription4digit
			capture noisily drop hscode4

			capture noisily drop description_6digit	
			capture noisily drop description6digit	
			capture noisily drop hscodeanddescription6digit 
			capture noisily drop hscode6

		*standardize variable names across data sets
			capture noisily rename typeofentry 			entry
			capture noisily rename eserial 				entry
			capture noisily rename entry_code 			entrycode

			capture noisily rename country_export 		countryexport
			
			capture noisily rename country_origin 		countryorigin
			capture noisily rename countryoforigin 		countryorigin

			capture noisily rename pref_code 			prefcode
			capture noisily rename preferrentialcode 	prefcode
			capture noisily rename preferentialcode 	prefcode

			capture noisily rename dutyforegone 		dutyforgone
			capture noisily rename duty_forgone 		dutyforgone

			capture noisily rename actualduty 			actualdutyrate
			capture noisily rename actual_duty 			actualdutyrate

			capture noisily rename normalduty 			normaldutyrate
			capture noisily rename normal_duty 			normaldutyrate

			capture noisily rename netmass				netmasskgs
			capture noisily rename grossmass			grossmasskgs

			capture noisily rename customsvalue			customsvalue

			capture noisily rename currency				currency

			capture noisily rename exchange_rate		exchangerate
			capture noisily rename exchangerate			exchangerate

			capture noisily rename arrastre				arrastre
			capture noisily rename insurance			insurance
			capture noisily rename freight				freight
			capture noisily rename othercost			othercost
			capture noisily rename wharfage				wharfage

			capture noisily rename dutiable_foreign 	dutiablevalueforeign
			capture noisily rename dutiablevalueforeigncurrency dutiablevalueforeign

			capture noisily rename dutiablevalue_php	dutiablevaluephp

			capture noisily rename duty_paid			dutypaid

			capture noisily rename exciseadvalorempaid	exciseadvalorem
			capture noisily rename excise_advalorem_paid exciseadvalorem

			capture noisily rename vattaxbase			vatbase
			capture noisily rename vat_base				vatbase
			capture noisily rename vat_paid				vatpaid

			capture noisily rename othertax				othertax
			capture noisily rename penalties			finesandpenalties
			capture noisily rename dutiestaxes			dutiestaxes

			capture noisily rename goodsdescriptiondeclared goodsdescription
			capture noisily rename goods_description	goodsdescription
		
		*change strings into numeric variables
		
			local numeric "dutyforgone actualdutyrate normaldutyrate netmasskgs grossmasskgs customsvalue exchangerate arrastre insurance freight othercost wharfage dutiablevalueforeign dutiablevaluephp dutypaid exciseadvalorem vatbase vatpaid othertax finesandpenalties dutiestaxes"
			
				foreach j of local numeric {
					capture noisily replace `j' = trim(`j')
					capture noisily replace `j' = "0" if `j' == "-"
					capture noisily destring `j', replace ignore(",")
				}
		
		*change numeric into string variables
			
			local string "entry entrycode natl_proc_code extended_proc_code port countryexport countryorigin prefcode currency hscode goodsdescription"

				foreach j of local string {
					capture noisily tostring `j', replace
					capture noisily replace `j' = trim(`j')
				}
		
		*force destring dutyforgone values with negative values
		
			capture noisily destring dutyforgone, replace ignore(",") force		// See *04-c for individual checks
			capture noisily destring netmasskgs, replace ignore(",") force		// Only for 2019 09
			
		*generate unique identification numbers
		
			capture gen id = _n
			capture tostring id, replace format(%08.0f)
			
			capture gen uid = time + " " + id
			capture drop id

			save `y'_`m'_varnamesclean, replace
			
		}
	}

***********I muted this section to make the run time more efficient*************

/*03-c force to numeric some variables with negative numbers (very little impact)
	
	*note: 	I included the destring commands in the loop after checking these individually.
			
	*2012_q3
		use 2012_q3_varnamesclean, clear
		destring netmasskgs, replace ignore(",") force
		save 2012_q3_varnamesclean, replace

			/*	netmasskgs (total w/o force command): 14,274,862,038.22
				netmasskgs (total w/ force command):  14,274,734,848.44
				netmasskgs w/ force is larger because row 291,807 has negative net mass.
				The force command treats these netmasskgs figures as missing.							*/	
		
	*2013_q2:
		use 2013_q2_varnamesclean, clear		
		destring netmasskgs, replace ignore(",") force
		save 2013_q2_varnamesclean, replace	

			/*	netmasskgs (total w/o force command): 2,945,962,231.36 
				netmasskgs (total w/ force command):  2,945,970,537.49 
				netmasskgs w/ force is larger because rows 53210 and 305109 have negative net mass.
				the force command treats these netmasskgs figures as missing.							*/

	*2014_01
	
		use 2014_01_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2014_01_varnamesclean, replace
		
	*2014_02
	
		use 2014_02_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2014_02_varnamesclean, replace
			
			*3 negative values
	
	*2015_03
	
		use 2015_03_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2015_03_varnamesclean, replace

			/*	total w/o force command:  6,637,843,157.00 
				total w/ force command:   6,665,092,844.00 
				total w/ force is larger because rows 25980, 28957, 29157, 38977, 52501, 55398, 57621, 64313, 65564, 67470 have negative values.
				The force command treats these figures as missing.							*/	

	*2015_04
	
		use 2015_04_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2015_04_varnamesclean, replace

			/*	total w/o force command:  9,681,578,437.00
				total w/ force command:   9,682,006,650.00 
				total w/ force is larger because rows 77736, 78062, 82773 have negative values.
				The force command treats these figures as missing.							*/	

	
	*2015_06
	
		use 2015_06_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2015_06_varnamesclean, replace
		
			/*	total w/o force command:  10,252,916,944.00 
				total w/ force command:   10,271,485,574.00
				total w/ force is larger because rows 14507 24743 65976 70722 100856 149452 150817 151693 151694 have negative values.
				The force command treats these figures as missing.							*/	
		

	*2015_07
	
		use 2015_07_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2015_07_varnamesclean, replace

			/*	total w/o force command:  10,676,676,977.00
				total w/ force command:   10,680,029,052.00
				total w/ force is larger because rows 11183 20870 75148 106761 113324 170534 198918 231451 have negative values.
				The force command treats these figures as missing.							*/	

	*2015_09	

		use 2015_09_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2015_09_varnamesclean, replace

			/*	total w/o force command:   11,465,756,989.00 
				total w/ force command:    11,467,561,345.00 
				total w/ force is larger because rows 814 14293 18163 45777 46007 57457 58088 72182 75491 76952 125903 148089 148196 have negative values.
				The force command treats these figures as missing.							*/	


	*2015_10

		use 2015_10_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2015_10_varnamesclean, replace

			/*	total w/o force command:   10,600,242,621.00 	
				total w/ force command:    10,601,203,938.00 
				total w/ force is larger because rows 75389 77687 82737 82922 168329 168410 have negative values.
				The force command treats these figures as missing.							*/	

	*2015_11
	
		use 2015_11_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2015_11_varnamesclean, replace
	
			*5 negative values
			
			
	*2015_12
	
		use 2015_12_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2015_12_varnamesclean, replace
	
			*8 negative values
			
	
	*2017_01
	
		use 2017_01_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2017_01_varnamesclean, replace

			*4 negative values
	
	*2017_02
	
		use 2017_02_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2017_02_varnamesclean, replace

			*23 missing values generated from dutyforgone
	
	*2017_03
		
		use 2017_03_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2017_03_varnamesclean, replace
	
			*8 missing values generated from dutyforgone
			
	*2017_04
		
		use 2017_04_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2017_04_varnamesclean, replace

			*9 missing values generated from dutyforgone (negative)

	*2017_05
		
		use 2017_05_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2017_05_varnamesclean, replace
		
			*6 missing values in dutyforgone
				*8,740 missing values generated from dutyforgone (?)
				*8,734 of which are empty rows (deleted)

	*2017_06
		use 2017_06_varnamesclean, clear		
		destring dutyforgone, replace ignore(",") force
		save 2017_06_varnamesclean, replace

			*5 missing values generated (negative) in dutyforgone
 	
	*2017_07
		use 2017_07_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2017_07_varnamesclean, replace
		
			*23 missing values (negative) in dutyforgone
			
	*2017_08
		use 2017_08_varnamesclean, clear
		destring dutyforgone, replace ignore(",") force
		save 2017_08_varnamesclean, replace
		
			*38 negative values in dutyforgone
			
	*2017_09 to 2019_08 clean
		
	*2019_09
		use 2019_09_varnamesclean, clear
		destring netmasskgs, replace ignore(",") force
		save 2019_09_varnamesclean, replace
		
			*1 negative value, 3 other missing values in netmasskgs 

			
*generate unique identification numbers (uid) per transaction

	forvalues y = 2012(1)2013 {

		forvalues i = 1(1)4 {

		use `y'_q`i'_varnamesclean, clear
			
			capture gen id = _n
			capture tostring id, replace format(%08.0f)
			
			capture gen uid = time + " " + id
			capture drop id
		
		save `y'_q`i'_varnamesclean, replace

		}
			
	}

local month "01 02 03 04 05 06 07 08 09 10 11 12"

	forvalues y = 2014(1)2019 {

		foreach m of local month {
			
		use `y'_`m'_varnamesclean, clear

			capture gen id = _n
			capture tostring id, replace format(%08.0f)
			
			capture gen uid = time + " " + id		
			capture drop id
			
		save `y'_`m'_varnamesclean, replace
		
			}
		}

*/

********************************************************************************

*04 append the data sets into annual files

	forvalues y = 2012(1)2013 {

		use `y'_q1_varnamesclean, clear
		
		forvalues j = 2(1)4 {

			append using `y'_q`j'_varnamesclean
		
		}
		
		save `y'_clean, replace
		
	}


local month "02 03 04 05 06 07 08 09 10 11 12"

	forvalues y = 2014(1)2019 {

		use `y'_01_varnamesclean, clear

			foreach m of local month {

				capture noisily append using `y'_`m'_varnamesclean

			}
			
		save `y'_clean, replace

	}

********************************************************************************

*05 clean country variables

*05-a standardize country ciphers using ISO alpha-2 and ISO alpha-3 codes

	*source file: country_iso.csv from https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes/tree/master/all
	
	import delimited country_iso, clear
		keep name alpha* name*
		rename name countryname_wits
		rename name_customs countryname_boc
		rename alpha2 country_iso2
		rename alpha3 country_iso3
	save country_iso, replace

*05-b make country names uniform

	*note: some countryorigin fields have 2-digit country codes and some have full country names.
	*we use the country cipher from 05-a to make these fields uniform and comparable.

	forvalues y = 2012(1)2019 {

		use `y'_clean, clear
		
		*clean countryorigin and countryexport
		
		local country "countryorigin countryexport"
		
			foreach j of local country {
			
				capture noisily replace `j' = "YEMEN" 					if `j' == "Democratic yemen" // unique observation
				capture noisily replace `j' = "MYANMAR (former BURMA)" 	if `j' == "BURMA (See MM MYANMAR)" // unique observation		
				capture noisily replace `j' = "CZECH REPUBLIC" 			if `j' == "Former Czechoslovakia"		
				capture noisily replace `j' = "NORWAY" 					if `j' == "SVALBARD ISLANDS" // Svalbard Islands (Sovereign State: Norway ISO 3166-2:NO)
				capture noisily replace `j' = "LIBYA" 					if `j' == "LYBIAN ARAB JAMAHIRIYA"
				capture noisily replace `j' = "RUSSIAN FEDERATION" 		if `j' == "Former USSR (for reference)" 
				capture noisily replace `j' = "TIMOR-LESTE" 			if `j' == "EAST TIMOR"
				capture noisily replace `j' = "MACEDONIA"				if `j' == "YUGOSLAV REP. OF MACEDONIA"
				capture noisily replace `j' = "ST. VINCENT AND THE GRENADINES" if `j' == "ST VINCENT AND GRENADINES"
				capture noisily replace `j' = "PITCAIRN"				if `j' == "Pitcairn"
				capture noisily replace `j' = "HEARD ISLAND AND MCDONALD ISLANDS" if `j' == "Heard mcdon. is."
				capture noisily replace `j' = "WALLIS AND FUTUNA" 		if `j' == "WALLIS AND FUTUNA ISLANDS"
				capture noisily replace `j' = "HOLY SEE" 				if `j' == "VATICAN"
				capture noisily replace `j' = "TONGA" 					if `j' == "TONGO"
				capture noisily replace `j' = "UNSPECIFIED" 			if `j' == ""
				capture noisily replace `j' = "MM" 						if `j' == "BU" // Burma 
				capture noisily replace `j' = "TL" 						if `j' == "TP" // East Timor - Timor-Leste
				capture noisily replace `j' = "MM" 						if `j' == "BU" // Burma - Myanmar
				capture noisily replace `j' = "YE" 						if `j' == "YD" // Democratic Yemen
				capture noisily replace `j' = "CD" 						if `j' == "ZR" // Congo (Democratic Republic of the) (ISO 3166-1, replaced)
				capture noisily replace `j' = trim(`j')
				
				}

			*capture noisily replace countryorigin = countryexport if countryorigin == "MANY"	// do not adjust for "MANY" countries

		rename countryorigin country_iso2

	*match countryorigin 2-digit ISO code with 3-digit ISO code in country_iso.dta
		
		*merge countryorigin using ISO Alpha-2 Codes

		merge m:1 country_iso2 using country_iso

			tab _merge, mi

			drop if _merge == 2

			rename countryname_wits countryorigin_wits
			rename countryname_boc countryorigin_boc
			rename country_iso2 countryorigin_iso2
			rename country_iso3 countryorigin_iso3
		
		* merge countryorigin using country names
		
			rename countryorigin_iso2 countryname_boc
			
			rename _merge _mco
			
		merge m:1 countryname_boc using country_iso
			
			replace countryorigin_wits = countryname_wits if _merge == 3
			replace countryorigin_boc = countryname_boc if _merge == 3
			replace countryorigin_iso3 = country_iso3 if _merge == 3

			rename countryname_boc countryorigin_iso2
			replace countryorigin_iso2 = country_iso2 if _merge == 3
			replace _mco = 3 if _merge == 3
			
			drop countryname_wits country_iso2 country_iso3
			
			drop if _merge == 2		
				tab _mco
				drop _merge

		* match countryexport using country names
		
		rename countryexport countryname_boc
			tab countryname_boc

		merge m:1 countryname_boc using country_iso
			tab _merge, mi

			drop if _merge == 2

			rename countryname_wits countryexport_wits
			rename countryname_boc countryexport_boc
			rename country_iso2 countryexport_iso2
			rename country_iso3 countryexport_iso3

			rename _merge _mcx
			
			drop *_iso2 *_boc
		
		save `y'_countryclean, replace

	}

********************************************************************************

*06 clean port variables

	*note: create port cipher to generate port variables for 2014 09 to 2014 12
	*we extract the port data from these months with the entrycode

*06-a create port cipher

	forvalues y = 2015(1)2017 {

		use `y'_countryclean, clear

			keep port entrycode
			gen portcode = trim(substr(entrycode, 5, strpos(entrycode, " ") - 5))
			
			keep portcode port
			duplicates drop port, force
			drop if port == ""
			gsort portcode
			
		save portcode_`y', replace													

	}

	use portcode_2017, clear
	
		append using portcode_2016
		append using portcode_2015
		duplicates drop port, force
		replace portcode = "GREEN" if port == "Re-route to green"
	
	save portcode, replace	
	
		rename port subport
		rename portcode subportcode
		gen portcode = trim(substr(subportcode, 1, 3))

	merge m:m portcode using portcode
	
		drop if _merge == 2
	
		replace portcode = "P02A" if substr(subportcode, 1,4) == "P02A"
		replace port = "Port of Manila" if portcode == "P02A"
		replace portcode = "P02B" if subportcode == "P02B"
		replace port = subport if portcode == "P02B"
		replace portcode = subportcode if subportcode == "GREEN"
		replace port = subport if subportcode == "GREEN"
	
		drop _merge	
		gsort subportcode
		
		duplicates list subportcode

		drop if subport == "Sub-Port of Palupandan"
		drop if subport == "Dumaguete"
		drop if subport == "Sub-Port of Mactan Int'l Airport"
		drop if subport == "Port of Zamboanga (SEA)"
		drop if subport == "Sub-Port of Dadiangas Int'l Airport"
	
		order subportcode subport portcode port 
	
	save subportcode, replace
	

*06-b standardize port and subport labels for 2014-2017, years with port values

	forvalues y = 2014(1)2017 {
	
		use `y'_countryclean, clear

		capture noisily drop port
		
		gen subportcode = trim(substr(entrycode, 5, strpos(entrycode, " ") - 5))

		merge m:1 subportcode using subportcode
		rename _merge _msp
		drop if _msp == 2 
		gsort uid
			
		save `y'_countryclean, replace
	
	}

********************************************************************************

*07 clean entry variables

	*C = consumption, T = transshipment, W = warehousing
	*C-Temp = consumption-temporary, . = unspecified

*07-a values for 2012 and 2013 are consumption entries

	forvalues y = 2012(1)2013 {

		use `y'_countryclean, clear		
		capture noisily gen entry = "C"	
		save `y'_countryclean, replace
		
	}

*07-b entry values for 2014 to 2017 are mixed -- including W, T, C-Temp, and .

	forvalues y = 2014(1)2017 {
	
		use `y'_countryclean, clear			
		capture noisily replace entry = "C" if lower(entry) == "consumption" 
		capture noisily replace entry = "W" if lower(entry) == "warehousing"
		capture noisily replace entry = "T" if lower(entry) == "transshipment" | lower(entry) == "transhipment"
		capture noisily replace entry = "." if entry == "Y"
		capture noisily replace entry = "." if entry == "3" | entry == "316.7" | entry == "4.31" | entry == "51.1"
		capture noisily replace entry = "." if entry == ""
		recast str6 entry
		save `y'_countryclean, replace
		
}

*07-c entry values for 2018 to 2019 are unspecified

	forvalues y = 2018(1)2019 {

		use `y'_countryclean, clear		
		capture noisily gen entry = "."	
		save `y'_countryclean, replace
		
	}

********************************************************************************

*08 clean currency and generate value, quantity, and price variables

	*convert all m_fob and m_cif values in USD, using trade-weighted average exchange rate
		*quarterly for 2012 to 2013
		*monthly for 2014 to 2019
		
	*fx_all.dta - shows trade weighted exchange rates per time period
	*php_usd.dta - shows the php to usd exchange rates per time period

	*estimate m_fob (free on board) and m_cif (cost with insurance and freight)

*08-a check exchange rates used
	*some import entries have fx rates (exchangerate) that do not match the conversion from dutiablevaluephp to dutiablevalueforeign
	*we generate exchangerate2 = dutiablevaluephp / dutiableforeign, to cross-check the exchangerate
	*_cfx flags transactions beyond 2 standard deviations from the difference between exchangerate2 and exchangerate

	forvalues y = 2012(1)2019 {

		use `y'_countryclean, clear	
		replace currency = "USD" if substr(trim(currency), 1, 2) == "US"
		
		gen id_fx = time + currency
		gen exchangerate2 = dutiablevaluephp / dutiablevalueforeign
			gen cfx = exchangerate2 / exchangerate - 1
			egen sd_cfx = sd(cfx)
			egen mean_cfx = mean(cfx)
		gen _cfx = 1 if cfx >= mean_cfx + 2*sd_cfx | cfx <= mean_cfx - 2*sd_cfx
		
		drop cfx sd_cfx mean_cfx
		
		save `y'_countryclean, replace
		
		collapse (mean) exchangerate exchangerate2 [w=dutiablevaluephp], by(id_fx)
		
		save fx_`y', replace

	}


*08-b append foreign currency matches to convert foreign currency (FCU) into USD

	use fx_2012, clear

	forvalues y = 2013(1)2019 {

		append using fx_`y'
		
	}
	
	save fx_all, replace
		
		gen currency = substr(id_fx, -3, 3)
		gen t = substr(id_fx, 1, 6)
		keep if currency == "USD"
		drop currency id_fx
		rename exchangerate php_usd
		
	save php_usd, replace
	
	use fx_all, clear
	
		gen t = substr(id_fx, 1, 6)
		merge m:1 t using php_usd
			drop _m
	
		gen fx_usd = php_usd / exchangerate
		replace fx_usd = php_usd / exchangerate2 if fx_usd == .
		
			*this fixes a few transactions where the Indonesian Rupiah exchange rate was zero
			
		gen cfx = (exchangerate2 / exchangerate - 1)*100
		gen _cfx = 1 if abs(cfx) > 1
		browse if _cfx == 1
	
	save fx_check, replace
	
			*fx_check shows the foreign exchange rates with discrepancies larger than 1 percent.
			*recall: exchangerate2 = dutiablevaluephp / dutiablevalueforeign
			*these shouldn't be material changes.

		keep id_fx fx_usd
	
	save fx_all, replace

	
*08-c m_cif, m_fob, q, p, variable labels

	forvalues y = 2012(1)2019 {

		use `y'_countryclean, clear
		
		merge m:1 id_fx using fx_all
			drop if _merge == 2
			drop _merge
		
		capture noisily gen m_fob = customsvalue / fx_usd
		capture noisily gen m_cif = dutiablevalueforeign / fx_usd
		capture noisily gen m_cif_factor = m_cif  / m_fob - 1

			*table entry, c(sum m_fob) format(%20.2gc) missing 
			*table entry if m_cif_factor == 0, c(sum m_fob) format(%20.2gc) missing 
		
	*gen p and q variables

		gen q = netmasskgs
		replace q = grossmasskgs if q == . | netmasskgs == 0
		gen p = m_fob / q
		
	*generate variable labels

		capture noisily label var uid "unique identification number of the import transaction"
		capture noisily label var time "time of transaction"
		capture noisily label var entrycode "entry code, identification number from customs"
		capture noisily label var entry "entry type"
		capture noisily label var natl_proc_code "procedure code (DROPPED)"
		capture noisily label var extended_proc_code "extended procedure code (DROPPED)"
		capture noisily label var port "port of entry, name of major collection district"
		capture noisily label var portcode "port code of entry, major collection district"
		capture noisily label var subport "subport of entry, name of minor collection district"
		capture noisily label var subportcode "subport code of entry"
		capture noisily label var _msp "merge results for subport of entry"
		capture noisily label var countryexport_iso3 "country of export, ISO 3-digit code"
		capture noisily label var countryexport_wits "country of export, name according to the World Integrated Trade Solutions (WITS)"
		capture noisily label var _mcx "merge results for country of export"
		capture noisily label var countryorigin_iso3 "country of origin, ISO 3-digit code"
		capture noisily label var countryorigin_wits "country of origin, name according to the World Integrated Trade Solutions (WITS)"
		capture noisily label var _mco "merge results for country of origin"
		capture noisily label var prefcode "preferential or preferential trade agreement (e.g. AFTA, ACFTA, AKFTA, ANZFTA)"
		capture noisily label var dutyforgone "duty forgone due to preferential trade agreement (PHP)"
		capture noisily label var actualdutyrate "actual duty rate with preferential trade agreement (%)"
		capture noisily label var normaldutyrate "normal duty rate (%)"
		capture noisily label var netmasskgs "net mass (kg)"
		capture noisily label var grossmasskgs "gross mass (kg)"
		capture noisily label var q "quantity of import transaction, q = netmass, q = grossmass if netmass == . (kg)"
		capture noisily label var customsvalue "customs value (FCU)"
		capture noisily label var currency "foreign currency used in the transaction (e.g. USD)"
		capture noisily label var exchangerate "exchange rate from foreign currerency unit to Philippine peso (PHP / FCU)"
		capture noisily label var fx_usd "exchange rate from foreign currency unit to US dollar (FCU / USD)"
		capture noisily label var arrastre "arrastre (PHP)"
		capture noisily label var insurance "insurance (FCU)"
		capture noisily label var freight "freight (FCU)"
		capture noisily label var othercost "other import costs (FCU)"
		capture noisily label var wharfage "wharfage (PHP)"
		capture noisily label var dutiablevalueforeign "dutiable value (FCU)"
		capture noisily label var dutiablevaluephp "dutiable value (PHP)"
		capture noisily label var m_fob "estimated free on board import value (customsvalue / fx_usd) (USD)"
		capture noisily label var m_cif "estimated cost with insurance and freight (dutiablevalueforeign / fx_usd) (USD)"
		capture noisily label var m_cif_factor "conversion factor from CIF value to FOB value (m_cif / m_fob - 1)"
		capture noisily label var p "import price, estimated from m_fob / q (USD / kg)"
		capture noisily label var dutypaid "customs duties paid (PHP)"
		capture noisily label var exciseadvalorem "excise and ad valorem taxes paid (PHP)"
		capture noisily label var vatbase "value added tax base, upon which the VAT rate is based (PHP)"
		capture noisily label var vatpaid "value added taxes paid (PHP)"
		capture noisily label var othertax "other taxes paid (PHP)"
		capture noisily label var finesandpenalties "fines and penalties paid (PHP)"
		capture noisily label var dutiestaxes "total duties and taxes paid (PHP)"
		capture noisily label var hscode "11-digit product classification (harmonized system or HS code)"
		capture noisily label var goodsdescription "goods description"
		capture noisily label var exchangerate2 "exchange rate (dutiablevaluephp / dutiablevalueforeign)"
		capture noisily label var _cfx "check if there is a great difference between exchangerate2 and exchangerate"

		save `y'_complete, replace

	}

********************************************************************************

*09 append annual files into one file

	use 2012_complete, clear

		forvalues y = 2013(1)2019 {

		append using `y'_complete

	}

	*clean a few more observations given findings from missing values

		browse if netmasskgs < 0
		replace netmasskgs = abs(netmasskgs) if netmasskgs < 0 						// (uid 2012q1 00087116 and uid 201608 00008105)
		replace q = netmasskgs if uid == "2012q1 00087116" | uid == "201608 00008105"
		replace p = m_fob / q if uid == "2012q1 00087116" | uid == "201608 00008105"
		drop id_fx
		
		replace m_cif_factor = m_cif / m_fob - 1

		sort uid

********************************************************************************

*10 encode categorical variables

	local categorical "entry currency prefcode countryorigin_wits countryexport_wits subport port"
	
	foreach j of local categorical {
	
		capture noisily rename `j' `j'_str
		encode `j'_str, generate(`j')
		drop `j'_str
	
	}
	
	order uid time entry hscode goodsdescription p q netmasskgs grossmasskgs m_fob m_cif m_cif_factor fx_usd customsvalue insurance freight arrastre wharfage othercost dutiablevalueforeign exchangerate currency dutiablevaluephp dutypaid exciseadvalorem vatbase vatpaid othertax finesandpenalties dutiestaxes prefcode normaldutyrate actualdutyrate dutyforgone countryorigin_iso3 countryorigin_wits _mco countryexport_iso3 countryexport_wits _mcx subportcode subport portcode port _msp entrycode id_fx exchangerate2 _cfx natl_* extended_*

********************************************************************************

*11 clean time variables 

	*generate quarterly time variable
	
	gen tqm = substr(time, -2, 2)
	gen y = substr(time, 1, 4)

	gen tq = time if substr(tqm, -2, 1) == "q"
		replace tq = y + "q1" if tqm == "01" | tqm == "02" | tqm == "03"
		replace tq = y + "q2" if tqm == "04" | tqm == "05" | tqm == "06"
		replace tq = y + "q3" if tqm == "07" | tqm == "08" | tqm == "09"
		replace tq = y + "q4" if tqm == "10" | tqm == "11" | tqm == "12"

	*generate monthly time variable
	gen tm = substr(time, 1, 4) + "m" + substr(time, -2, 2)	
	replace tm = substr(time, 1, 4) + "m" + substr(time, -1, 1) if substr(time, 5, 1) == "0"
	replace tm = "" if substr(tqm, -2, 1) == "q"
		
	gen ttm = monthly(tm, "ym")
	gen ttq = quarterly(tq, "yq")
	
	format ttm %tm
	format ttq %tq

	drop tm tq
	rename ttm tm
	rename ttq tq	
	drop tqm time
		
	gen ty = yearly(substr(uid, 1, 4), "Y")
	
	format ty %ty
	order uid ty tq tm
	
	label var tq "time of entry, quarterly"
	label var tm "time of entry, monthly"
	label var ty "year of entry"

********************************************************************************

*12 save final complete file; save annual complete files

	save boc_all_complete, replace
		
	forvalues y = 2012(1)2019 {
	
		use boc_all_complete, clear
		keep if substr(uid, 1, 4) == "`y'"
		save boc_all_`y', replace

	}

********************************************************************************

*13 save final lite file; save annual lite files (fewer variables)

	use boc_all_complete, clear
	
	keep 	uid ty tq tm entry hscode goodsdescription p q m_fob m_cif fx_usd ///
			dutiablevalueforeign exchangerate currency dutiablevaluephp ///
			dutypaid exciseadvalorem arrastre wharfage vatbase vatpaid ///
			othertax finesandpenalties dutiestaxes prefcode ///
			countryorigin_iso3 countryexport_iso3 ///
			subport port
			
	order 	uid ty tq tm entry hscode goodsdescription p q m_fob m_cif fx_usd ///
			dutiablevalueforeign exchangerate currency dutiablevaluephp ///
			dutypaid exciseadvalorem arrastre wharfage vatbase vatpaid ///
			othertax finesandpenalties dutiestaxes prefcode ///
			countryorigin_iso3 countryexport_iso3 ///
			subport port
			
	save 	boc_all_lite, replace

