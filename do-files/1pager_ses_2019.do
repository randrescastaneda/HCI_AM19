
/*
OBJECTIVE: GENERATE GRAPHS FOR ONE-PAGER ON SES DISSAGREGATED HCI
AUTHOR: ZELALEM YILMA DEBEBE
DATE: AUGUST 07 2019

*/

clear
set more off	
set maxvar 32000

*set up directory and filepath to database 
global charts "C:\Users\WB469563\OneDrive - WBG\Documents (zdebebe@worldbank.org)\OneDrive - WBG\Documents (zdebebe@worldbank.org)\Human Capital Project\HCI SES 2019\Two pagers 2019\charts"
local outputfilepath "C:\Users\WB469563\OneDrive - WBG\Documents (zdebebe@worldbank.org)\OneDrive - WBG\Documents (zdebebe@worldbank.org)\Human Capital Project\HCI SES 2019\Two pagers 2019"
use hci_ses_toshare_19Jul2019, clear 
graph set window fontface "Baskerville Old Face"

//preliminaries 
egen latest=max(year), by(wbcode) //keep only the latest round of data for inequality assessment 
drop if year!=latest

encode wbregion, gen(region)
encode wbincomegroup, gen(income)
gen a=1 //scalar for twoway scatter 


foreach j of numlist 1/5 {
 foreach var in psurv_q`j' eyrs_q`j' test_q`j' nostu_q`j' hci_q`j' {
 egen `var'_mean=mean(`var') //cross-country mean for each quintile (not used in this version of the one-pager)
}
}

foreach var in psurv eyrs test nostu hci {
gen `var'_gap=`var'_q5-`var'_q1 // Gap for each country to be used in the text
}

foreach j of varlist psurv_gap eyrs_gap test_gap nostu_gap hci_gap { 
egen `j'_mean=mean(`j') //typical gap for each var to be used in the text for comparison.
}

foreach j of varlist psurv_gap nostu_gap hci_gap {
gen `j'_diff=round((`j'-`j'_mean)*100,1)
}

foreach j of varlist eyrs_gap {
gen `j'_diff=round((`j'-`j'_mean),0.1)
}

foreach j of varlist test_gap {
gen `j'_diff=round((`j'-`j'_mean),1)
}



//EXPORTING RMARKDOWN TEXT

///cond(exp, true, false)



gen hci_gap_size = ///
  cond(hci_gap_diff == -1, "slightly smaller than",   ///
     cond(hci_gap_diff  < -1, "smaller than",           ///
     cond(hci_gap_diff  >  1, "larger than",            ///
     cond(hci_gap_diff == 1, "slightly larger than", ///
           "about the same as"))))


gen hci_text = " **Human Capital Index (HCI).** In " + wbcountryname +       ///
", the productivity as a future worker of a child born today in the " + ///
"richest 20 percent of households is **" + strofreal(round(hci_q5*100, 1)) ///
+ " percent** while it is **" + strofreal(round(hci_q1*100, 1)) +     ///
" percent** for a child born in the poorest 20 percent, a gap of **"  ///
+strofreal(round(hci_gap*100, 1)) + "** percentage points. This gap " + ///
"is " + hci_gap_size +  " the typical gap across the 51 countries (" ///
+strofreal(round(hci_gap_mean*100, 1)) + " percentage points)."




gen nostu_gap_size = ///
  cond(nostu_gap_diff == -1, "slightly smaller than",   ///
     cond(nostu_gap_diff  < -1, "smaller than",           ///
     cond(nostu_gap_diff  >  1, "larger than",            ///
     cond(nostu_gap_diff == 1, "slightly larger than", ///
           "about the same as"))))

 
		   
gen nostu_text=" **Healthy Growth (Not Stunted Rate).** In " + wbcountryname +  ///
", the percentage of children in the top 20 percent of households who " +  ///
"are not stunted is **" + strofreal(round(nostu_q5*100,1)) ///
+ " percent** while it is **" + strofreal(round(nostu_q1*100,1)) +  ///
" percent** among the poorest 20 percent, a gap of **"  ///
+strofreal(round(nostu_gap*100,1)) + "** percentage points. This gap " + ///
"is " + nostu_gap_size + " the typical gap across the 51 countries (" ///
 + strofreal(round(nostu_gap_mean*100,1))+ " percentage points)."	   
		   
		   
		   
gen psurv_gap_size = ///
  cond(psurv_gap_diff == -1, "slightly smaller than",   ///
     cond(psurv_gap_diff  < -1, "smaller than",           ///
     cond(psurv_gap_diff  >  1, "larger than",            ///
     cond(psurv_gap_diff == 1, "slightly larger than", ///
           "about the same as"))))


		   
gen psurv_text=" **Probability of Survival to Age 5.** In " + wbcountryname + ///
", the probability of survival of a child born today in the richest 20 percent" + ///
" of households is **" + strofreal(round(psurv_q5*100, 1)) +  ///
" percent** while it is **" +strofreal(round(psurv_q1*100,1)) + ///
" percent** for a child born in the poorest 20 percent, a gap of **" ///
+ strofreal(round(psurv_gap*100,1)) + "** percentage points. This gap " + ///
"is " + psurv_gap_size + " the typical gap across the 51 countries ("  ///
+ strofreal(round(psurv_gap_mean*100,1)) + "percentage points)."	   
		   
		   
gen eyrs_gap_size = ///
     cond(eyrs_gap_diff  <= -0.3, "smaller than",           ///
     cond(eyrs_gap_diff  >= 0.3, "larger than",            ///
           "about the same as"))

	   
gen eyrs_text=" **Expected Years of School.** In " + wbcountryname + ///
", a child in the richest 20 percent of households who starts school at age 6" + ///
" can expect to complete **" + strofreal(round(eyrs_q5, 0.1))+ ///
" years** of school by her 18th birthday while a child from the poorest 20 percent" + ///
" can expect to complete **" + strofreal(round(eyrs_q1,0.1)) + ///
" years** of school, a gap of **" + strofreal(round(eyrs_gap, 0.1))+ ///
" years** of school. This gap " + ///
"is " + eyrs_gap_size + " the typical gap across the 51 countries (" ///
+ strofreal(round(eyrs_gap_mean, 0.1)) + "years)."   
		   


	   
gen test_gap_size = ///
     cond(test_gap_diff  <= -5, "smaller than",           ///
     cond(test_gap_diff  >= 5, "larger than",            ///
           "about the same as"))

	   
		   
gen test_text=" **Harmonized Test Scores.** Students from the richest 20 percent" + ///
" of households in " + wbcountryname + ///
" score **" + strofreal(round(test_q5,1))+ "** while those from the poorest 20 percent score **" ///
+ strofreal(round(test_q1,1))+ ///
"**, a gap of **" + strofreal(round(test_gap,1)) + " points**. This gap " + ///
"is " + test_gap_size+ " the typical gap across the 51 countries (" ///
+strofreal(round(test_gap_mean,1)) + "points)."
	   

	   
	   
//Generate alternative country names for use in the title and body of the one-pager  
	   
gen wbcountrynameb=""
replace wbcountrynameb="the Comoros" if wbcode=="COM"
replace wbcountrynameb="the Democratic Republic of Congo" if wbcode=="COD"
replace wbcountrynameb="the Republic of Congo" if wbcode=="COG"
replace wbcountrynameb="the Arabic Republic of Egypt" if wbcode=="EGY"
replace wbcountrynameb="the Gambia" if wbcode=="GMB"
replace wbcountrynameb="the Kyrgyz Republic" if wbcode=="KGZ"
replace wbcountrynameb="the West Bank and Gaza" if wbcode=="PSE"
replace wbcountrynameb=wbcountryname if wbcountrynameb==""
label var wbcountrynameb "country name for use in the body of the 1 pager"

gen wbcountrynamet=""
replace wbcountrynamet="Comoros" if wbcode=="COM"
replace wbcountrynamet="The Democratic Republic of Congo" if wbcode=="COD"
replace wbcountrynamet="The Republic of Congo" if wbcode=="COG"
replace wbcountrynamet="The Arabic Republic of Egypt" if wbcode=="EGY"
replace wbcountrynamet="The Gambia" if wbcode=="GMB"
replace wbcountrynamet="Kyrgyz Republic" if wbcode=="KGZ"
replace wbcountrynamet="West Bank and Gaza" if wbcode=="PSE"
replace wbcountrynamet=wbcountryname if wbcountrynamet==""
label var wbcountrynamet "country name for use in the title of the 1 pager"


save "hci_ses_toshare_2019-08-13", replace

exit

*******************
*******************SLIDER WITH PLOTPLAINBLIND COLOR OPTIONS CHOSEN 
gen psurv_source=""
gen eyrs_source=""
gen test_source=""
gen nostu_source=""


local x= 16 
forvalues i=16/`x' {
local year1=year in `i'
local ctry=wbcode in `i'
local psurv_source=psurv_source in `i'
local eyrs_source=eyrs_source in `i'
local test_source=test_source in `i'
local nostu_source=nostu_source in `i'

	
		twoway (scatter a psurv_q1, msymbol(Oh) msize(huge) mcolor(reddish) mlwidth(medthick))  /// 
		(scatter a psurv_q2, msymbol(Oh) msize(huge) mcolor(orangebrown) mlwidth(medthick)) ///
		(scatter a psurv_q3, msymbol(Oh) msize(huge) mcolor(sky) mlwidth(medthick)) ///
		(scatter a psurv_q4, msymbol(Oh) msize(huge) mcolor(eltgreen) mlwidth(medthick)) ///
		(scatter a psurv_q5, msymbol(Oh) msize(huge) mcolor(green) mlwidth(medthick)) ///
		in `i', legend(off) title("Probability of Survival to Age 5", size(vlarge) pos(11)) subtitle("`psurv_source'", size(small) pos(11)) xtitle("") ytitle("") yscale(range(0 2)) ylabel(none) xlabel(,labsize(large)) xlabel(0.8 (0.05) 1,labsize(large)) 	
		graph save psurv_`ctry', replace 
		
				
		twoway (scatter a eyrs_q1, msymbol(Oh) msize(huge) mcolor(reddish) mlwidth(medthick)) /// 
		(scatter a eyrs_q2, msymbol(Oh) msize(huge) mcolor(orangebrown) mlwidth(medthick)) ///
		(scatter a eyrs_q3, msymbol(Oh) msize(huge) mcolor(sky) mlwidth(medthick)) ///
		(scatter a eyrs_q4, msymbol(Oh) msize(huge) mcolor(eltgreen) mlwidth(medthick)) ///
		(scatter a eyrs_q5, msymbol(Oh) msize(huge) mcolor(green) mlwidth(medthick)) ///
		in `i', legend(off) title("Expected Years of School", size(vlarge) pos(11)) subtitle("`eyrs_source'", size(small) pos(11)) xtitle("") ytitle("") yscale(range(0 2)) ylabel(none) xlabel(,labsize(large)) xlabel(2 (2) 14,labsize(large)) 
		graph save eyrs_`ctry', replace
		
		twoway (scatter a test_q1, msymbol(Oh) msize(huge) mcolor(reddish) mlwidth(medthick)) /// 
		(scatter a test_q2, msymbol(Oh) msize(huge) mcolor(orangebrown) mlwidth(medthick)) ///
		(scatter a test_q3, msymbol(Oh) msize(huge) mcolor(sky) mlwidth(medthick)) ///
		(scatter a test_q4, msymbol(Oh) msize(huge) mcolor(eltgreen) mlwidth(medthick)) ///
		(scatter a test_q5, msymbol(Oh) msize(huge) mcolor(green) mlwidth(medthick)) ///
		in `i', legend(off) title("Harmonized Test Scores", size(vlarge) pos(11)) subtitle("`test_source'", size(small) pos(11)) xtitle("") ytitle("") yscale(range(0 2)) ylabel(none) xlabel(,labsize(large)) xlabel(250 350 450 550 625,labsize(large)) 	
		graph save test_`ctry', replace


		twoway (scatter a nostu_q1, msymbol(Oh) msize(huge) mcolor(reddish) mlwidth(medthick)) /// 
		(scatter a nostu_q2, msymbol(Oh) msize(huge) mcolor(orangebrown) mlwidth(medthick)) ///
		(scatter a nostu_q3, msymbol(Oh) msize(huge) mcolor(sky) mlwidth(medthick)) ///
		(scatter a nostu_q4, msymbol(Oh) msize(huge) mcolor(eltgreen) mlwidth(medthick)) ///
		(scatter a nostu_q5, msymbol(Oh) msize(huge) mcolor(green) mlwidth(medthick)) ///
		in `i', legend(off) title("Fraction of Children Under 5 Not Stunted", size(vlarge) pos(11)) subtitle("`nostu_source'", size(small) pos(11)) xtitle("") ytitle("") yscale(range(0 2)) ylabel(none) xlabel(,labsize(large)) xlabel(0.2 (0.2) 1,labsize(large)) 
		graph save nostu_`ctry', replace

       	twoway (scatter a hci_q1, msymbol(Oh) msize(huge) mcolor(reddish) mlwidth(medthick)) /// 
		(scatter a hci_q2, msymbol(Oh) msize(huge) mcolor(orangebrown) mlwidth(medthick)) ///
		(scatter a hci_q3, msymbol(Oh) msize(huge) mcolor(sky) mlwidth(medthick)) ///
		(scatter a hci_q4, msymbol(Oh) msize(huge) mcolor(eltgreen) mlwidth(medthick)) ///
		(scatter a hci_q5, msymbol(Oh) msize(huge) mcolor(green) mlwidth(medthick)) ///
		in `i', legend(off) title("SES-Disaggregated Human Capital Index", size(vlarge) pos(11)) subtitle("Source: World Bank Staff Calculations", size(small) pos(11)) xtitle("") xtitle("") ytitle("") yscale(range(0 2)) ylabel(none) xlabel(,labsize(large)) xlabel(0.2 (0.2) 1,labsize(large)) 
		graph save hci_`ctry', replace
		
		
	    graph combine hci_`ctry'.gph psurv_`ctry'.gph eyrs_`ctry'.gph test_`ctry'.gph nostu_`ctry'.gph  , colfirst rows(5) cols(1) ysize(6) xsize(4) graphregion(fcolor(white))  ///
		title("{bf: HCI By Quintile of Socioeconomic Status}", suffix color(black) size(large) linegap(3) pos(11) span) /// 
		note( ///
		"{it:- Color code for quintiles (poorest=red, 2nd poorest=orange,}" "{it:middle=blue, 2nd richest=gray, richest=green)}", size (medium) color(gray))
		graph export "$charts\ses_`ctry'.pdf", replace
		graph save "$charts\ses_`ctry'", replace 

	
	erase psurv_`ctry'.gph
	erase eyrs_`ctry'.gph
	erase test_`ctry'.gph
	erase nostu_`ctry'.gph
	erase hci_`ctry'.gph
		
}
///////////////////////////////////////////////THE ABOVE IS THE ONLY GRAPH WE DECIDED TO INCLUDE /////////////////////////////////

exit


///////////////////////////////////////////////////////////END








