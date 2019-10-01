
/*
OBJECTIVE: GENERATE GRAPHS AND STRINGS FOR ONE-PAGER ON SES DISSAGREGATED HCI
AUTHOR: ZELALEM YILMA DEBEBE
DATE: AUGUST 28 2019

*/

clear
set more off	
set maxvar 32000


if (lower("`c(username)'") == "wb538904") {
	global root "C:\Users\WB538904\OneDrive - WBG\HCI_AM19"
}
if (lower("`c(username)'") == "wb384996") {
	global root "c:\Users\wb384996\OneDrive - WBG\WorldBank\HCI_AM19"
}

global charts "${root}/charts"
local outputfilepath "${root}/input"
cd "${root}"

local date: disp %tdCY-m-D date("`c(current_date)'", "DMY")
disp "`date'"
use "input\SHCI_DataTable_27Aug2019.dta"



graph set window fontface "Baskerville Old Face"

//preliminaries 
drop if wbcountryname=="Brazil"
egen latest=max(year), by(wbcode) //keep only the latest round of data for inequality assessment 
drop if year!=latest

gen a=1 //scalar for twoway scatter 


///rename and generate vars to make vars consistent with earlier version of the data upon which the dofile is written

foreach k of numlist 1/5 {
	foreach j of varlist u5mr_q`k' {
		gen psurv_q`k'=1-`j'
	}
}

foreach k of numlist 1/5 {
	foreach j of varlist stunt_q`k' {
		gen nostu_q`k'=1-`j'
	}
}

foreach k of numlist 1/5 {
	foreach j of varlist eys_q`k' {
		rename `j' eyrs_q`k'
	}
}

foreach k of numlist 1/5 {
	foreach j of varlist hlo_q`k' {
		rename `j' test_q`k'
	}
}


/// vars for text of the one-pager
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



//EXPORTING RMARKDOWN TEXT
///cond(exp, true, false)

gen hcirank_text = "" + wbcountrynamet + " was ranked "  + strofreal(round(hcirank, 1)) + " out of 157 countries in the global HCI."

gen hci_gap_size = ///
cond(hci_gap_diff == -1, "slightly smaller than",   ///
cond(hci_gap_diff  < -1, "smaller than",           ///
cond(hci_gap_diff  >  1, "larger than",            ///
cond(hci_gap_diff == 1, "slightly larger than", ///
"about the same as"))))


gen hci_text = " **SES-Disaggregated Human Capital Index (SES-HCI).** In " + wbcountrynameb +       ///
", the productivity as a future worker of a child born today in the " + ///
"richest 20 percent of households is **" + strofreal(round(hci_q5*100, 1)) ///
+ " percent** while it is **" + strofreal(round(hci_q1*100, 1)) +     ///
" percent** for a child born in the poorest 20 percent, a gap of **"  ///
+strofreal(round(hci_gap*100, 1)) + "** percentage points. This gap " + ///
"is " + hci_gap_size +  " the typical gap across the 50 countries (" ///
+strofreal(round(hci_gap_mean*100, 1)) + " percentage points)."




gen nostu_gap_size = ///
cond(nostu_gap_diff == -1, "slightly smaller than",   ///
cond(nostu_gap_diff  < -1, "smaller than",           ///
cond(nostu_gap_diff  >  1, "larger than",            ///
cond(nostu_gap_diff == 1, "slightly larger than", ///
"about the same as"))))



gen nostu_text=" **Healthy Growth (Not Stunted Rate).** In " + wbcountrynameb +  ///
", the percentage of children in the top 20 percent of households who " +  ///
"are not stunted is **" + strofreal(round(nostu_q5*100,1)) ///
+ " percent** while it is **" + strofreal(round(nostu_q1*100,1)) +  ///
" percent** among the poorest 20 percent, a gap of **"  ///
+strofreal(round(nostu_gap*100,1)) + "** percentage points. This gap " + ///
"is " + nostu_gap_size + " the typical gap across the 50 countries (" ///
+ strofreal(round(nostu_gap_mean*100,1))+ " percentage points)."	   



gen psurv_gap_size = ///
cond(psurv_gap_diff == -1, "slightly smaller than",   ///
cond(psurv_gap_diff  < -1, "smaller than",           ///
cond(psurv_gap_diff  >  1, "larger than",            ///
cond(psurv_gap_diff == 1, "slightly larger than", ///
"about the same as"))))



gen psurv_text=" **Probability of Survival to Age 5.** In " + wbcountrynameb + ///
", the probability of survival of a child born today in the richest 20 percent" + ///
" of households is **" + strofreal(round(psurv_q5*100, 1)) +  ///
" percent** while it is **" +strofreal(round(psurv_q1*100,1)) + ///
" percent** for a child born in the poorest 20 percent, a gap of **" ///
+ strofreal(round(psurv_gap*100,1)) + "** percentage points. This gap " + ///
"is " + psurv_gap_size + " the typical gap across the 50 countries ("  ///
+ strofreal(round(psurv_gap_mean*100,1)) + " percentage points)."	   


gen eyrs_gap_size = ///
cond(eyrs_gap_diff  <= -0.3, "smaller than",           ///
cond(eyrs_gap_diff  >= 0.3, "larger than",            ///
"about the same as"))


gen eyrs_text=" **Expected Years of School.** In " + wbcountrynameb + ///
", a child in the richest 20 percent of households who starts school at age 6" + ///
" can expect to complete **" + strofreal(round(eyrs_q5, 0.1))+ ///
" years** of school by her 18th birthday while a child from the poorest 20 percent" + ///
" can expect to complete **" + strofreal(round(eyrs_q1,0.1)) + ///
" years** of school, a gap of **" + strofreal(round(eyrs_gap, 0.1))+ ///
" years** of school. This gap " + ///
"is " + eyrs_gap_size + " the typical gap across the 50 countries (" ///
+ strofreal(round(eyrs_gap_mean, 0.1)) + " years)."   




gen test_gap_size = ///
cond(test_gap_diff  <= -5, "smaller than",           ///
cond(test_gap_diff  >= 5, "larger than",            ///
"about the same as"))



gen test_text=" **Harmonized Test Scores.** Students from the richest 20 percent" + ///
" of households in " + wbcountrynameb + ///
" score **" + strofreal(round(test_q5,1))+ "** while those from the poorest 20 percent score **" ///
+ strofreal(round(test_q1,1))+ ///
"**, a gap of **" + strofreal(round(test_gap,1)) + " points** on a scale that ranges from 300 (minimal attainment) to 625 (high attainment). This gap " + ///
"is " + test_gap_size+ " the typical gap across the 50 countries (" ///
+strofreal(round(test_gap_mean,1)) + " points)."


///// String vars for source of data




foreach j of varlist source_u5mr source_enr source_stunt {
replace `j'="Demographic and Health Survey" if `j'=="DHS"
replace `j'="Multiple Indicator Cluster Survey" if `j'=="MICS"
}

replace source_hlo="Early Grade Reading Assessment" if source_hlo=="EGRA"
replace source_hlo="Latin American Laboratory for Assessment of the Quality of Education" if source_hlo=="LLECE"
replace source_hlo="Programme for the Analysis of Education Systems"  if source_hlo=="PASEC"
replace source_hlo="Progress in International Reading Literacy Study" if source_hlo=="PIRLS"
replace source_hlo="Programme for International Student Assessment" if source_hlo=="PISA"
replace source_hlo="Southern and Eastern Africa Consortium for Monitoring Educational Quality" if source_hlo=="SACMEQ"
replace source_hlo="Trends in International Mathematics and Science Study" if source_hlo=="TIMSS"
replace source_hlo="Trends in International Mathematics and Science Study/Progress in International Reading Literacy Study" if source_hlo=="TIMSS/PIRLS"

gen psurv_source="" + source_u5mr + " " + strofreal(year_u5mr) + ""
gen eyrs_source="" + source_enr + " " + strofreal(year_enr) + ""
gen nostu_source="" + source_stunt + " " + strofreal(year_stunt) + ""
gen test_source="" + source_hlo + " " + strofreal(year_hlo) + ""




save "input/hci_ses_toshare_`date'", replace
save "input/hci_ses", replace



*******************
*******************SLIDER WITH PLOTPLAINBLIND COLOR OPTIONS CHOSEN 

local x= 50 
forvalues i=1/`x' {
local year1=year in `i'
local ctry=wbcode in `i'
local psurv_source=psurv_source in `i'
local eyrs_source=eyrs_source in `i'
local test_source=test_source in `i'
local nostu_source=nostu_source in `i'


twoway (scatter a psurv_q1, msymbol(Oh) msize(huge) mcolor(reddish) mlwidth(vthick))  /// 
(scatter a psurv_q2, msymbol(Oh) msize(huge) mcolor(orangebrown) mlwidth(vthick)) ///
(scatter a psurv_q3, msymbol(Oh) msize(huge) mcolor(sky) mlwidth(vthick)) ///
(scatter a psurv_q4, msymbol(Oh) msize(huge) mcolor(eltgreen) mlwidth(vthick)) ///
(scatter a psurv_q5, msymbol(Oh) msize(huge) mcolor(green) mlwidth(vthick)) ///
in `i', legend(off) title("Probability of Survival to Age 5", size(vlarge) pos(11)) subtitle("Source: `psurv_source'", size(small) pos(11)) xtitle("") ytitle("") yscale(range(0 2)) ylabel(none) xlabel(,labsize(large)) xlabel(0.8 (0.05) 1,labsize(large)) 	
graph save psurv_`ctry', replace 


twoway (scatter a eyrs_q1, msymbol(Oh) msize(huge) mcolor(reddish) mlwidth(vthick)) /// 
(scatter a eyrs_q2, msymbol(Oh) msize(huge) mcolor(orangebrown) mlwidth(vthick)) ///
(scatter a eyrs_q3, msymbol(Oh) msize(huge) mcolor(sky) mlwidth(vthick)) ///
(scatter a eyrs_q4, msymbol(Oh) msize(huge) mcolor(eltgreen) mlwidth(vthick)) ///
(scatter a eyrs_q5, msymbol(Oh) msize(huge) mcolor(green) mlwidth(vthick)) ///
in `i', legend(off) title("Expected Years of School", size(vlarge) pos(11)) subtitle("Source: `eyrs_source'", size(small) pos(11)) xtitle("") ytitle("") yscale(range(0 2)) ylabel(none) xlabel(,labsize(large)) xlabel(2 (2) 14,labsize(large)) 
graph save eyrs_`ctry', replace

twoway (scatter a test_q1, msymbol(Oh) msize(huge) mcolor(reddish) mlwidth(vthick)) /// 
(scatter a test_q2, msymbol(Oh) msize(huge) mcolor(orangebrown) mlwidth(vthick)) ///
(scatter a test_q3, msymbol(Oh) msize(huge) mcolor(sky) mlwidth(vthick)) ///
(scatter a test_q4, msymbol(Oh) msize(huge) mcolor(eltgreen) mlwidth(vthick)) ///
(scatter a test_q5, msymbol(Oh) msize(huge) mcolor(green) mlwidth(vthick)) ///
in `i', legend(off) title("Harmonized Test Scores", size(vlarge) pos(11)) subtitle("Source: `test_source'", size(small) pos(11)) xtitle("") ytitle("") yscale(range(0 2)) ylabel(none) xlabel(,labsize(large)) xlabel(250 350 450 550 625,labsize(large)) 	
graph save test_`ctry', replace


twoway (scatter a nostu_q1, msymbol(Oh) msize(huge) mcolor(reddish) mlwidth(vthick)) /// 
(scatter a nostu_q2, msymbol(Oh) msize(huge) mcolor(orangebrown) mlwidth(vthick)) ///
(scatter a nostu_q3, msymbol(Oh) msize(huge) mcolor(sky) mlwidth(vthick)) ///
(scatter a nostu_q4, msymbol(Oh) msize(huge) mcolor(eltgreen) mlwidth(vthick)) ///
(scatter a nostu_q5, msymbol(Oh) msize(huge) mcolor(green) mlwidth(vthick)) ///
in `i', legend(label(1 "Poorest quintile") label(2 "2nd quintile") label(3 "3rd quintile") label(4 "4th quintile") label(5 "Richest quintile")) legend(order(1 2 3 4 5) pos(6)col(5) row(1) symxsize(*.7) symysize(*.5)) title("Fraction of Children Under 5 Not Stunted", size(vlarge) pos(11)) subtitle("Source: `nostu_source'", size(small) pos(11)) xtitle("") ytitle("") yscale(range(0 2)) ylabel(none) xlabel(,labsize(large)) xlabel(0.2 (0.2) 1,labsize(large)) 
graph save nostu_`ctry', replace

twoway (scatter a hci_q1, msymbol(Oh) msize(huge) mcolor(reddish) mlwidth(vthick)) /// 
(scatter a hci_q2, msymbol(Oh) msize(huge) mcolor(orangebrown) mlwidth(vthick)) ///
(scatter a hci_q3, msymbol(Oh) msize(huge) mcolor(sky) mlwidth(vthick)) ///
(scatter a hci_q4, msymbol(Oh) msize(huge) mcolor(eltgreen) mlwidth(vthick)) ///
(scatter a hci_q5, msymbol(Oh) msize(huge) mcolor(green) mlwidth(vthick)) ///
in `i', legend(off) title("SES-Disaggregated Human Capital Index (SES-HCI)", size(vlarge) pos(11)) subtitle("Source: World Bank Staff Calculations", size(small) pos(11)) xtitle("") xtitle("") ytitle("") yscale(range(0 2)) ylabel(none) xlabel(,labsize(large)) xlabel(0.2 (0.2) 1,labsize(large)) 
graph save hci_`ctry', replace


graph combine hci_`ctry'.gph psurv_`ctry'.gph eyrs_`ctry'.gph test_`ctry'.gph nostu_`ctry'.gph  , colfirst rows(5) cols(1) ysize(6) xsize(4) graphregion(fcolor(white))  ///
title("{bf: HCI By Quintile of Socioeconomic Status}", suffix color(black) size(large) linegap(3) pos(11) span) 
graph export "$charts\ses_`ctry'.pdf", replace
graph save "$charts\ses_`ctry'", replace 


erase psurv_`ctry'.gph
erase eyrs_`ctry'.gph
erase test_`ctry'.gph
erase nostu_`ctry'.gph
erase hci_`ctry'.gph

}

exit


///////////////////////////////////////////////////////////END








