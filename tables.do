/*

An Open Data Set of Twenty Million Import Transactions
from the Bureau of Customs of the Philippines from 2012 to 2019

Author: 		Kenneth Isaiah Ibasco Abante
				Research Faculty
				Department of Interdisciplinary Studies, School of Humanities
				Ateneo de Manila University, Philippines
				kabante@ateneo.edu

Do file: 		tables.do
Description: 	Generate tables and summary reports

Paper:			https://www.researchgate.net/publication/339066219
Data:			bit.ly/phlcustomsopendata

Created: 		1 August 2019
Last updated:	6 February 2020

Input:			boc_all_complete.dta
Output:			summary.xls, codebook.log, missing.log

																			  */

********************************************************************************
*table of contents

*v. codebook of variables
*m. missing values
*s. summary of all values
*t. tabulation of quant variables by year, by entry type
*n. count of all transactions by year, by entry type
*f. quant variables by factor variables like country of origin and the preferential trade agreements
*p. quant variables by port of entry
*c. currency and exchange rate 
*r. rice imports (6-digit HS code)

********************************************************************************

*put your file location here

clear
capture log close
set more off

cap cd "put your file location here where boc_all_complete.dta can be found"

********************************************************************************

*v. codebook of variables

use boc_all_complete, clear
	
asdoc des, position type format vallab replace save(codebook.doc)

cap log using codebook.log, replace

	codebook m_cif_factor
	
cap log close

********************************************************************************

*m. missing values

cap log using missing.log, replace

use boc_all_complete, clear

*m1. missing values
	misstable sum, all show
	
*m2. check pattern of missing data
	misstable patterns, asis
	
*m3. missing tree
	misstable tree, asis

*m4. summary of missing values, including string values
	tabmiss	_all
	
cap log close

********************************************************************************

*s. summary of all values

cap log using summary.log, replace

*s1. summarize
	sum _all, format
	
*s2. detailed summary per variable
	sum _all, detail format
	
cap log close
	
********************************************************************************

cap log check.log, replace

*t. tabulation of quant variables by year, by entry type

*t1. by entry and year

use boc_all_complete, clear

	collapse (sum) 	q netmasskgs grossmasskgs m_fob m_cif customsvalue insurance ///
					freight arrastre wharfage othercost dutiablevaluephp ///
					dutypaid exciseadvalorem vatbase vatpaid othertax ///
					finesandpenalties dutiestaxes dutyforgone, by(ty entry)

	save t1, replace
	
*t2. consumption only

	use t1, clear
	
	drop if entry != 2 
		
	save t2, replace

*t3. consumption + missing

	use t1, clear
	
	replace entry = 2 if entry == 3 | entry == .
	drop if entry != 2

	collapse (sum) q netmasskgs grossmasskgs m_fob m_cif customsvalue insurance ///
					freight arrastre wharfage othercost dutiablevaluephp ///
					dutypaid exciseadvalorem vatbase vatpaid othertax ///
					finesandpenalties dutiestaxes dutyforgone, by(ty)

	save t3, replace

	
*t4. transshipment only (entry = 4)

	use t1, clear
	
	drop if entry != 4
	
	collapse (sum) q netmasskgs grossmasskgs m_fob m_cif customsvalue insurance ///
					freight arrastre wharfage othercost dutiablevaluephp ///
					dutypaid exciseadvalorem vatbase vatpaid othertax ///
					finesandpenalties dutiestaxes dutyforgone, by(ty)
					
	save t4, replace

*t5. warehousing only (entry = 5)

	use t1, clear
	
	drop if entry != 5
	
		collapse (sum) q netmasskgs grossmasskgs m_fob m_cif customsvalue insurance ///
					freight arrastre wharfage othercost dutiablevaluephp ///
					dutypaid exciseadvalorem vatbase vatpaid othertax ///
					finesandpenalties dutiestaxes dutyforgone, by(ty)

	save t5, replace

*t6. all entries

	use t1, clear
	
	collapse (sum) q netmasskgs grossmasskgs m_fob m_cif customsvalue insurance ///
					freight arrastre wharfage othercost dutiablevaluephp ///
					dutypaid exciseadvalorem vatbase vatpaid othertax ///
					finesandpenalties dutiestaxes dutyforgone, by(ty)
					
	save t6, replace
	
*m_fob by entry

	use t1, clear
	
	keep ty entry m_fob
	
	reshape wide m_fob, i(entry) j(ty)
	
	save t7, replace


*tn. generate summary report

forvalues n = 1(1)7 {

	use t`n', clear
	export excel using summary, sheet("t`n'") sheetrep firstrow(var) datestring(%ty)
	
	}

********************************************************************************

*n. count of all transactions by year, by entry type

use boc_all_complete, clear

	gen n = _n
	collapse (count) n, by(ty entry)
	
	save n1, replace
	
	export excel using summary, sheet("n1") sheetrep firstrow(var) datestring(%ty)

********************************************************************************

*f. quant variables by factor variables like country of origin and the preferential trade agreements

use boc_all_complete, clear

*f1. by country of origin and preference code

	collapse (sum) q netmasskgs grossmasskgs m_fob m_cif customsvalue insurance ///
				freight arrastre wharfage othercost dutiablevaluephp ///
				dutypaid exciseadvalorem vatbase vatpaid othertax ///
				finesandpenalties dutiestaxes dutyforgone, by(countryorigin_wits prefcode ty)

	save f1, replace

*f2. by country of origin (2012 to 2019, C+C-Temp+T+W+.)

	collapse (sum) q netmasskgs grossmasskgs m_fob m_cif customsvalue insurance ///
				freight arrastre wharfage othercost dutiablevaluephp ///
				dutypaid exciseadvalorem vatbase vatpaid othertax ///
				finesandpenalties dutiestaxes dutyforgone, by(countryorigin_wits)
	
	gsort -m_fob
	
	save f2, replace

*f3. fob value by country of origin, by year

	use f1, clear

	collapse (sum) m_fob, by(countryorigin_wits ty)

	bysort countryorigin_wits: egen m_fob_total = sum(m_fob)

	reshape wide m_fob, i(countryorigin_wits) j(ty)
	
	gsort -m_fob_total
	
	save f3, replace

*f4. preference code

	use f1, clear
	
	collapse (sum) q netmasskgs grossmasskgs m_fob m_cif customsvalue insurance ///
				freight arrastre wharfage othercost dutiablevaluephp ///
				dutypaid exciseadvalorem vatbase vatpaid othertax ///
				finesandpenalties dutiestaxes dutyforgone, by(prefcode)
				
	drop if prefcode == .
	
	gsort -dutyforgone
	
	save f4, replace

*fn. generate summary report

	forvalues n = 1(1)4 {

		use f`n', clear
		export excel using summary, sheet("f`n'") sheetrep firstrow(var) datestring(%ty)
		
		}

*********************************************************************************

*p. quant variables by port of entry

*p1. total collections by port, by year, by entry

	*note: negligible difference between p2, p3, and p4
	*since dutiesandtaxes are levied only on consumption entries

use boc_all_complete, clear

	collapse (sum) 	dutiestaxes dutypaid exciseadvalorem vatpaid othertax ///
					finesandpenalties, by(ty portcode port entry)
					
	save p1, replace
	
*p2. consumption only

	use p1, clear
		drop if entry != 2 
		drop if portcode == ""
		keep ty portcode port dutiestaxes
		
	reshape wide dutiestaxes, i(portcode) j(ty)

	save p2, replace
	
*p3. consumption + missing

	use p1, clear
		replace entry = 2 if entry == 3 | entry == .
		drop if entry != 2
		
	collapse (sum) 	dutiestaxes dutypaid exciseadvalorem vatpaid othertax ///
					finesandpenalties, by(ty portcode port)
	
		drop if portcode == ""
		keep ty portcode port dutiestaxes

	reshape wide dutiestaxes, i(portcode) j(ty)

	save p3, replace

*p4. all entries

	use p1, clear
	
	collapse (sum) 	dutiestaxes dutypaid exciseadvalorem vatpaid othertax ///
					finesandpenalties, by(ty portcode port)
	
		drop if portcode == ""
		keep ty portcode port dutiestaxes

	reshape wide dutiestaxes, i(portcode) j(ty)

	save p4, replace
		
*pn. generate summary port reports

	forvalues n = 1(1)4 {

	use p`n', clear
	export excel using summary, sheet("p`n'") sheetrep firstrow(var) datestring(%ty)
	
	}
	
*********************************************************************************

*c. currency and exchange rate checks
*us cross-rates and php cross-rates

*c1. weighted average exchange rate (by entry and year)

use boc_all_complete, clear
	
	collapse (mean) fx_usd exchangerate exchangerate2 [aw = dutiablevaluephp], by(ty currency)
	
	save c1, replace

	use c1, clear
	
	rename currency c
	decode c, gen(currency)

	replace fx_usd = 1 / fx_usd
	rename fx_usd boc_fxusd
	rename exchangerate boc_fxphp
	rename exchangerate2 boc_fxphp2
	
	reshape wide boc_*, i(currency) j(ty)
	
	save c1, replace

*c2. check usd-cross rates (boc vs. bsp)

	use c1, clear
	keep currency boc_fxusd*

	merge 1:1 currency using bsp_fxusd
		drop if _merge == 2
		
	save c2, replace
	
	export excel using currency, sheet("usdcross") sheetrep firstrow(var)
			
*c3. check peso-cross rates (boc vs. bsp)

	use c1, clear
	
	keep currency boc_fxphp*
	
	merge 1:1 currency using bsp_fxphp
		drop if _merge == 2
		
	order currency boc_fxphp20* boc_fxphp220*
		
	save c3, replace
	
	export excel using currency, sheet("pesocross") sheetrep firstrow(var)

*c4. summary of m_fob 

use boc_all_complete, clear

	collapse (sum) m_fob, by(currency ty)
	
	bysort currency: egen m_fob_total = sum(m_fob)
	
	reshape wide m_fob, i(currency) j(ty)
	
	gsort -m_fob_total
	
	save c4, replace

*cn. generate summary report

forvalues n = 1(1)4 {

	use c`n', clear
	export excel using summary, sheet("c`n'") sheetrep firstrow(var) datestring(%ty)
	
	}

*r. rice imports (6-digit HS code)

use boc_all_complete, clear

*r1. sum of all quant variables (by hs6, entry, year)

	keep if substr(hscode, 1, 4) == "1006"
	gen hs6 = substr(hscode, 1, 6)
	
	collapse (sum) q netmasskgs grossmasskgs m_fob m_cif customsvalue insurance ///
				freight arrastre wharfage othercost dutiablevaluephp ///
				dutypaid exciseadvalorem vatbase vatpaid othertax ///
				finesandpenalties dutiestaxes dutyforgone, by(hs6 ty entry)


	save r1, replace
	
	keep hs6 q ty entry

*r2. rice import volumes (by hs6, entry, year)

	reshape wide q, i(hs6 entry) j(ty)
	
	save r2, replace

*r3. rice import volumes (by hs6, year)

	collapse (sum) q*, by(hs6)
	
	save r3, replace

*rn. generate summary report

	forvalues n = 1(1)3 {

	use r`n', clear
	export excel using summary, sheet("r`n'") sheetrep firstrow(var) datestring(%ty)
			
	}


cap log close
