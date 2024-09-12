*********************************************************************************
*																				*
*	PROGRAM: 	Cleans Wave 1 Survey											*
*	PURPOSE: 	Creates missing values & scales, checks summary stats Fall 2022 *
*   AUTHOR:		Allan Lee										*
*	CREATED:	12/27/22														*
*	UPDATED: 	03/13/23	14:35PM												*
*	NOTES: 		Do Not Write Over the Original Datasets							*
*																				*				
*********************************************************************************

/************************* START PRELIMINARY SETUP ****************************/
clear all
macro drop _all

*Set initial:
global initials al

*date tag
global 		datetag: 	display %td!(NN!_DD!_YY!) date(c(current_date), "DMY")

*Allan's file locations
global aloffice "Z:\Dropbox"
global aldata "$aloffice/01 XXX/Data Files"
global aloutput "$aloffice/01 XXX/Output Files"
global allog "$aloffice/01 XXX/Log Files"
global alraw "$aloffice/01 XXX/Raw Files"
global algrph "$aloffice/01 XXX/Graph Files"

*start logging
capture log close

log using "${${initials}log}/Log_12_clean_survey_responses_$datetag.txt", append

/************************** END PRELIMINARY SETUP *****************************/
/* (1) High quality data checks
   (2) Merge with baseline admin data
   (3) Rename and label variables
   (4) Compare respondents with non-respondents
   (5) Missingness and summary statistics
   (6) Create scales for USDA, housing, and mental health
*/

********************************************************************************
* STEP 1 - High quality data checks
********************************************************************************

use "${${initials}data}/col_fall22_survey_raw" , clear

// Check for which rows are duplicates

 sort id
// list id progress if dup>0

// Evaluate duplicates //

// S200427: completed only 10% of the survey both times, once in mid Nov and mid Dec. Survey responses are both empty.
// S200287: completed only 10% of the survey in mid Nov but finished the full survey in mid Dec. They did skip Q8, however. The second observation should be kept. First response essentially only completed the survey administration questions.
// S200295: finished 52% of the survey in mid Nov and 100% of the survey in mid Dec. When comparing the survey responses, they are mostly consistent but some questions are responded to differently in both times, including q1_1, q6_4, q6_6, q6_7, q7_2, q11_1, q11_2, q11_4, q12_1, q12_2, q12_3, q12_4. Some of the responses changed from "don't know" to a definitive yes or not answer (q6s). Some of the responses (q12s) changed in frequency, such as the mental health questions, which could be due to the fact that the respondent responded later during final exam season. My personal intuition suggests that the second response should be kept because it is fully answered and it seems like more responses are fully filled out in the mid Dec date.
// S20097: completed 10% of the survey the first time and 100% of the survey the second time. The first response essentially only completed the survey administration questions. Keep the fully completed response.
// S2006: completed 10% of the survey the first time and 100% of the survey the second time. The first response essentially only completed the survey administration questions. Keep the fully completed response.
// S200386: completed 100% of the survey the first time and 10% the second time. On the second time, some of the responses have a period. The first response, however, has fully completed answers, which should be kept.
// S2008: completed 97% of the survey the first time and 100% of the survey the second time. A substantial minority of the responses are different (including some of the beginnning continuous questions, frequency questions, and later binary questions). These questions were: q1s, q2_5, q6_4-q6_5, q7_3, q11_2-q11_4, q12_2, q13_1-q13_2, q22, q24
// S200406: completed 10% of the survey the first time and 100% of the survey the second time. The first response essentially only completed the survey administration questions. Keep the fully completed response.
// S200469: completed only 10% of the survey both times, once in mid Nov and mid Dec. Survey responses are both empty.

// Drop the duplicate rows //
drop if id=="S200287" & progress==10
drop if id=="S200295" & progress==52
drop if id=="S200386" & progress==10
drop if id=="S200406" & progress==10
drop if id=="S200427" & dup==2
drop if id=="S200469" & dup==1
drop if id=="S2006" & progress==10
drop if id=="S2008" & progress==100
drop if id=="S20097" & progress==10

drop dup
 
********************************************************************************
* STEP 2 - Merge with demographic and treatment status data
********************************************************************************


/*merge survey file with the file we used to do the balance checks
"${${initials}data}/4_initial_data_combined"
*/

merge 1:1 id using "${${initials}data}/4_initial_data_combined", gen(_mergebaseline) keep(1 3) /* drop ==2 bc opt out*/



********************************************************************************
* STEP 3 - Variable harmony
********************************************************************************

/* (a) update the variable labels so we know which questions we are looking at */

label variable q1_1 "Hours studying and working for class (excluding time spent in class)"
label variable q1_2 "Hours spent on-campus"
label variable q2_1 "Used faculty office hours"
label variable q2_2 "Attended new student orientation"
label variable q2_3 "Attended campus events (e.g. job fair; social event; guest speaker etc.)"
label variable q2_4 "Attended career assessment and counseling"
label variable q2_5 "Attended career exploration programs or activities"
label variable q2_6 "Attended advising on course selection and educational planning"
label variable q2_7 "Attended advising on academic problems"
label variable q2_8 "Used academic support or tutoring"
label variable q3   "Did you work for pay during the semester"
label variable q4_4 "Weekly hours of work"
label variable q5   "Did you choose class times based on your work schedule?"
label variable q6_1 "Received federal Grants (e.g. Pell or SEOG)"
label variable q6_2 "Received federal loans"
label variable q6_3 "Received federal work study"
label variable q6_4 "Received Cost of Living Pilot Grant"
label variable q6_5 "Received Massachusetts Need Based Tuition Waiver"
label variable q6_6 "Received Cash Grant"
label variable q6_7 "Received other federal/state/local government grants or scholarships"
label variable q7_1 "Finaid helped me stay enrolled in college"
label variable q7_2 "Finaid reduced stress/anxiety"
label variable q7_3 "Finaid paid for class materials"
label variable q7_4 "Finaid paid for a laptop/computer"
label variable q7_5 "Finaid helped me pay down a student loan/avoid taking more debt"
label variable q7_6 "Finaid paid for transportation"
label variable q7_7 "Finaid paid bills/family bills"
label variable q7_8 "Finaid paid healthcare expenses"
label variable q7_9 "Finaid paid for housing"
label variable q7_10 "Finaid paid for childcare"
label variable q8_1 "2.0 GPA is required to renew COL grant"
label variable q8_2 "3.0 GPA is required to renew COL grant"
label variable q8_3 "Being enrolled at least part-time (3+ credits) is required to renew COL grant"
label variable q8_4 "Being enrolled full-time (9+ credits) is required to renew COL grant"
label variable q8_5 "Other criteria is required to renew COL grant"
label variable q8_5_text "Response to q8_5"
label variable q9    "Receive public assistance to purchase food"
label variable q10   "Receive public housing assistance"
label variable q11_1 "Felt you couldn't control the important things in your life in the last month"
label variable q11_2 "Felt confident you could handle personal problems in the last month"
label variable q11_3 "Felt like things were going your way in the last month"
label variable q11_4 "Felt like difficulties were insurmountable in the last month"
label variable q12_1 "Experienced little interest or pleasure in doing things in the last 2 weeks"
label variable q12_2 "Felt down/depressed/hopeless in the last 2 weeks"
label variable q12_3 "Felt nervous/anxious/on edge in the last 2 weeks"
label variable q12_4 "Could not stop worrying in the last 2 weeks"
label variable q13_1 "Lacked sufficient food/money to purchase food in the past year"
label variable q13_2 "Couldn't afford balanced meals in the past year"
label variable q14   "Cut the size of meals in the past year"
label variable q15   "Frequency of cutting the sizes of meals in the past year"
label variable q16   "Ate less due to food insecurity in the past year"
label variable q17   "Was hungry but didn't eat in the past year"
label variable q18   "Financial situation made it difficult to pay rent/mortgage in the past year"
label variable q19   "Household moved twice or more in the past year"
label variable q20   "Household moved in with others due to financial problems in the past year"
label variable q21   "Experienced homelessness in the past year"
label variable q22   "Not pay the full amount of a utility bill (i.e. gas or electric) in the past year"
label variable q23   "How safe do you feel where you currently live?"
label variable q24   "identify as FGLI"
label variable q25   "Parent/guardian highest level of education"
label variable q25_12_text "Response to q25"

// Rename q25_12_text variable to q25_text
rename q25_12_text q25_text

/*   (b) transforming all the question responses into quantitative answers */

// Define the relevant binary variables//
global binary_var q2_1 q2_2 q2_3 q2_4 q2_5 q2_6 q2_7 q2_8 q5 q6_1 q6_2 q6_3 q6_4 q6_5 q6_6 q6_7 q7_1 q7_2 q7_3 q7_4 q7_5 q7_6 q7_7 q7_8 q7_9 q7_10 q8_1 q8_2 q8_3 q8_4 q8_5 q9 q10 q14 q16 q17 q18 q19 q20 q21 q22 q24

// For each binary variable, turn yes into 1, no into 0, Don't Know into .d, and missing answer into .m
foreach var of global binary_var {
    replace `var' = strtrim(strproper(`var'))
    replace `var' = "0" if `var' == "No"
    replace `var' = "1" if `var' == "Yes"
    replace `var' = ".d" if `var' == "Don'T Know"
	replace `var' = ".d" if `var' == "Do Not Know"
	replace `var' = ".m" if `var' == ""
	replace `var' = ".m" if `var' == "."
	replace `var' = ".u" if `var' == "Unsure"
}

// For Q3, turn yes into 2, No, but I am looking for a job into 1, No, and I am not looking for a job into 0, Don't Know into .d, and missing answer into .m
global job_var q3

foreach var of global job_var {
    replace `var' = strtrim(strproper(`var'))
    replace `var' = "0" if `var' == "No, And I Am Not Looking For A Job"
    replace `var' = "1" if `var' == "No, But I Am Looking For A Job"
	replace `var' = "2" if `var' == "Yes"
    replace `var' = ".d" if `var' == "Don'T Know"
	replace `var' = ".d" if `var' == "Do Not Know"
	replace `var' = ".m" if `var' == ""
	replace `var' = ".m" if `var' == "."
	destring `var', replace
}

// For Q4_4 change paid work hours to zero if they report not engaging in paid work
replace q4_4 = 0 if inlist(q3,0,1) & !missing(q3)

*******************************************************************************
// Perceived Stress Scale PSS-4  //
// Define the relevant q11 variables- //
global eleven_var q11_1 q11_2 q11_3 q11_4

// For each q11 variable, turn very often into 4, fairly often into 3, sometimes into 2, almost never into 1, never into 0, Don't Know into .d, and missing answer into .m
foreach var of global eleven_var {
    replace `var' = strtrim(strproper(`var'))
    replace `var' = "0" if `var' == "Never"
    replace `var' = "1" if `var' == "Almost Never"
	replace `var' = "2" if `var' == "Sometimes"
	replace `var' = "3" if `var' == "Fairly Often"
	replace `var' = "4" if `var' == "Very Often"
    replace `var' = ".d" if `var' == "Don'T Know"
	replace `var' = ".d" if `var' == "Do Not Know"
	replace `var' = ".m" if `var' == "."
	replace `var' = ".m" if `var' == ""
	destring `var', replace
}

*******************************************************************************
// Patient Health Questionnaire Anxiety & Depression PHQ-4 //
// Define the relevant q12 variables//
global twelve_var q12_1 q12_2 q12_3 q12_4

// For each q12 variable, turn nearly everyday into 3, more than half the days into 2, several days into 1, not at all into 0, Don't Know into .d, and missing answer into .m
foreach var of global twelve_var {
    replace `var' = strtrim(strproper(`var'))
    replace `var' = "0" if `var' == "Not At All"
    replace `var' = "1" if `var' == "Several Days"
	replace `var' = "2" if `var' == "More Than Half The Days"
	replace `var' = "3" if `var' == "Nearly Every Day"
    replace `var' = ".d" if `var' == "Don'T Know"
	replace `var' = ".d" if `var' == "Do Not Know"
	replace `var' = ".m" if `var' == "."
	replace `var' = ".m" if `var' == ""
	destring `var', replace
}

*******************************************************************************
// USDA 6-Item Food Questionnaire - items 13-17 //
// For Q13, turn often true into 2, sometimes true into 1, never true into 0, Don't Know into .d, and missing answer into .m
global thirteen_var q13_1 q13_2

foreach var of global thirteen_var {
    replace `var' = strtrim(strproper(`var'))
    replace `var' = "0" if `var' == "Never True"
    replace `var' = "1" if `var' == "Sometimes True"
	replace `var' = "2" if `var' == "Often True"
    replace `var' = ".d" if `var' == "Don'T Know"
	replace `var' = ".d" if `var' == "Do Not Know"
	replace `var' = ".m" if `var' == ""
	replace `var' = ".m" if `var' == "."
	destring `var', replace
}

*******************************************************************************
// For Q15, turn Almost every month into 2, Some months but not every months into 1, Only 1 or 2 months into 0, Don't Know into .d, and missing answer into .m
global fifteen_var q15

foreach var of global fifteen_var {
    replace `var' = strtrim(strproper(`var'))
    replace `var' = "0" if `var' == "Only 1 Or 2 Months"
    replace `var' = "1" if `var' == "Some Months But Not Every Month"
	replace `var' = "2" if `var' == "Almost Every Month"
    replace `var' = ".d" if `var' == "Do Not Know"
	replace `var' = ".d" if `var' == "Do Not Know"
	replace `var' = ".m" if `var' == "."
	replace `var' = ".m" if `var' == ""
	destring `var', replace
}

*******************************************************************************
// For Q23, turn Extremely Safe into 4, Very Safe into 3, Somewhat Safe into 2, A Little Bit Safe into 1, Not At All Safe into 0, Don't Know into .d, and missing answer into .m
global twenty_three_var q23

foreach var of global twenty_three_var {
    replace `var' = strtrim(strproper(`var'))
    replace `var' = "0" if `var' == "Not At All Safe"
    replace `var' = "1" if `var' == "A Little Bit Safe"
	replace `var' = "2" if `var' == "Somewhat Safe"
	replace `var' = "3" if `var' == "Very Safe"
	replace `var' = "4" if `var' == "Extremely Safe"
    replace `var' = ".d" if `var' == "Don'T Know"
	replace `var' = ".d" if `var' == "Do Not Know"
	replace `var' = ".m" if `var' == "."
	replace `var' = ".m" if `var' == ""
	destring `var', replace
}



*******************************************************************************
// For Q25, turn Earned a postgraduate degree (Master's, Professional Degree like JD or MBA, PhD, etc.) into 5, Earned a four-year college degree into 4, Earned a two-year college degree into 3, Attended college but did not complete a degree into 2, Did not enter any form of higher education, Other into 0, Don't Know into .d, and missing answer into .m
global twenty_five_var q25

foreach var of global twenty_five_var {
    replace `var' = strtrim(strproper(`var'))
    replace `var' = "0" if `var' == "Other:"
    replace `var' = "1" if `var' == "Did Not Enter Any Form Of Higher Education"
	replace `var' = "2" if `var' == "Attended College But Did Not Complete A Degree"
	replace `var' = "3" if `var' == "Earned A Two-Year College Degree"
	replace `var' = "4" if `var' == "Earned A Four-Year College Degree"
	replace `var' = "5" if `var' == "Earned A Postgraduate Degree (Master'S, Professional Degree Like Jd Or Mba, Phd, Etc.)"
    replace `var' = ".d" if `var' == "Do Not Know"
	replace `var' = ".m" if `var' == "."
	replace `var' = ".m" if `var' == ""
	destring `var', replace
}

// Define global continuous variables and change missing responses to ".m"
global cont_var q1_1 q1_2 q4_4

foreach var of global cont_var {
	replace `var' = .m if `var' == .
	destring `var', replace
}

// Define global text variables and change missing responses to ".m"
global text_var q8_5_text q25_text

foreach var of global text_var {
	replace `var' = ".m" if `var' == "."
	replace `var' = ".m" if `var' == ""
	destring `var', replace
}


gen responded = (progress ~= .)


  
********************************************************************************
* STEP 4 - Check Missingness and means, mins, max etc.
********************************************************************************

/*Item missingness 
ranges of responses (think table 1 in the table document) */

* Define global for all variables
global all_var q1_1 q1_2 q2_1 q2_2 q2_3 q2_4 q2_5 q2_6 q2_7 q2_8 q3 q4_4 q5 q6_1 q6_2 q6_3 q6_4 q6_5 q6_6 q6_7 q7_1 q7_2 q7_3 q7_4 q7_5 q7_6 q7_7 q7_8 q7_9 q7_10 q8_1 q8_2 q8_3 q8_4 q8_5 q8_5_text q9 q10 q11_1 q11_2 q11_3 q11_4 q12_1 q12_2 q12_3 q12_4 q13_1 q13_2 q14 q15 q16 q17 q18 q19 q20 q21 q22 q23 q24 q25 q25_text

* Ensure all variables are destringed
foreach var of global all_var {
	qui destring `var', replace
}

* Calculate the number of missing responses for each survey question
foreach v of var q* {
    capture confirm numeric variable `v'
    if !_rc {
        quietly count if `v' == .m & responded == 1
        di "`v'{col 20}" %5.0f r(N)
    }
    else {
        quietly count if `v' == ".m" & responded == 1 
        di "`v'{col 20}" %5.0f r(N)
    }
}

/*Sade's approach for determining missingness*/
 foreach v of var q* {
	capture gen miss_`v' = (`v'==.m ) if responded==1
	capture gen dkmiss_`v' = (`v'==.d | `v'==.u) if responded==1
  }
  
  /*Fixes the conditional Financial Aid questions for those who responded to COL*/
  foreach v of var q8_1 - q8_5 {
  	replace miss_`v'= . if q6_4!=1 & responded==1
	replace dkmiss_`v'= . if q6_4!=1 & responded==1
  }
 
  /*Fixes the Work Schedule questions for those who worked during the semester*/
replace miss_q5= . if q3!=2 & responded==1
replace dkmiss_q5= . if q3!=2 & responded==1



  /*Fixes frequency of cuting the size of meals q15 based off those who responded to q14==1*/
replace miss_q15= . if q14!=1 & responded==1
replace dkmiss_q15= . if q14!=1 & responded==1
  


********************************************************************************
* STEP 5 - Create index for mental health, food & housing insecurity scales
********************************************************************************

*******************************************************************************
/*  1. Anxiety and Depression Scale.*/
********************************************************************************

egen phq4_anx_dep = rowtotal(q12_1 q12_2 q12_3 q12_4) if responded==1
	replace phq4_anx_dep = . if missing(q12_1) | missing(q12_2) | missing(q12_3) | missing(q12_4)
label variable phq4_anx_dep "PHQ-4 Anxiety and Depression Scale"

 egen phq_depression = rowtotal(q12_1 q12_2) if responded==1 & !missing(q12_1) & !missing(q12_2)
		label var phq_depression "PHQ-4 Depression Score"
 egen phq_anxiety = rowtotal(q12_3 q12_4) if responded==1 & !missing(q12_3) & !missing(q12_4)
		label var phq_anxiety "PHQ-4 Anxiety Score"
*create a binary indicator for moderate & severe anx/dep. 
gen anxiety = (phq_anxiety>=3) if !missing(q12_3) & !missing(phq_anxiety) & responded==1
gen depression = (phq_depression>=3) if !missing(q12_2) & !missing(phq_depression) & responded==1

label var anxiety "Anxiety indicator from PHQ-4"
label var depression "Depression indicator from PHQ-4"

*******************************************************************************
/*  2. Food Security Scale.*/
********************************************************************************

* First, create indicator variables for the FS questions to be changed to the scale form
 foreach v of var q13_1 q13_2 q15 {
	capture gen scale_`v' = (`v'==2| `v'==1) if responded==1
  }
 
  foreach v of var q13_1 q13_2 q15 {
   replace scale_`v' = .m if responded==1 & `v'==.m
}
  
* Calculate the raw FS scale score for each person
 
egen fs_scale_raw = rowtotal(scale_q13_1 scale_q13_2 q14 scale_q15 q16 q17) if responded==1
	*do we need to replace the raw scale as missing if they are missing any one of the responses? 
	replace fs_scale_raw=. if missing(scale_q13_1) | missing(scale_q13_2) 
label variable fs_scale_raw "Food Security Scale: Raw"

/*Alternate strategy
egen fs_scale_raw_v2 = rowtotal(scale_q13_1 scale_q13_2 q14 scale_q15 q16 q17) if responded==1
replace fs_scale_raw_v2=. if missing(scale_q13_1) & missing(scale_q13_2) & missing(q14) &  missing(q16) & missing(q17)
*/

* Calculate the FS scale score Editted for each person. Note, the scale score assigns "NA" to 0. Given that NA is not an option in Stata, I kept 0 as 0.

recode fs_scale_raw (0=0) (1=2.86) (2=4.19) (3=5.27) (4=6.30) (5=7.54) (6=8.48), gen(fs_scale_editted)
label variable fs_scale_editted "Food Security Scale: Editted"

*******************************************************************************
/*  3. Perceived Stress Scale.*/
********************************************************************************

* First, create new scale variables for the stress questions to be changed to the scale form
 foreach v of var q11_2 q11_3 {
	recode `v' (0=4) (1=3) (2=2) (3=1) (4=0), gen(scale_`v')
  }
 
* Calculate the perceived stress scale score for each person
egen pss_stress = rowtotal(q11_1 scale_q11_2 scale_q11_3 q11_4) if responded==1
replace pss_stress = . if missing(q11_1) | missing(q11_2) | missing(q11_3) | missing(q11_4)

label variable pss_stress "PSS-4 Perceived Stress Scale"

* Determine missing variables 
egen miss_ps_scale=rowmax(miss_q11_1 miss_q11_2 miss_q11_3 miss_q11_4) if responded==1


*******************************************************************************
/*  4. Raw housing "scale".*/
********************************************************************************

recode q23 (0=4) (1=3) (2=2) (3=1) (4=0), gen(scale_q23)	//reverse code//

gen affirm_q23 = (inlist(q23,0,1,2))

egen housing_raw = rowtotal(affirm_q23 q18 q19 q20 q21 q22 ) if responded==1

	replace housing_raw =. if missing(q19)
	
label var housing_raw "Housing Security Scale: Raw"




********************************************************************************
* STEP 7 - Save a new file with the clean fall 2022 survey data
********************************************************************************

drop startdate enddate ipaddress progress responseid externalreference locationlatitude locationlongitude distributionchannel userlanguage introlanguage inst_name

drop arith_pl_scoremiss - esl_write_scoremiss
drop arith_pl_score - esl_write_score
drop stid indep_s female_s  _mergebaseline rapct rctelg stratum seednum degreetype  
drop admit_term fstenr_term random_num stratum_index stratum_size stratum_tnum stratum_cnum stratum_sizexpct
drop stratum_actrapct collegewritingplacement collegemathplacement collegereadingplacement 
drop tookenglishlanguagecourseeve admitlevel status recordeddate
drop scale_q* macasorstateexam apexamscotes satactscores

label var responded "Responded to baseline fall survey"
rename responded responded_svy_fa1_1

label var aian "If American Indian/Alaskan Native"
label var hwpi "If Hawaiian/Pacific Islander"
label var hs_gpa_imp "0 if HS GPA missing to use w/hsgpamiss"

rename durationinseconds duration_svy_fa1_1
rename finished finish_svy_fa1_1

replace finish_svy_fa1_1 = "0" if finish_svy_fa1_1=="False"
replace finish_svy_fa1_1 = "1" if finish_svy_fa1_1=="True"
destring finish_svy_fa1_1, replace

order id institution unitid treatment control _Iinst_stra_* inst_stratum indep-rctelg_efcenr, first
order  aa_degree aas_degree as_degree, after(program)
order aid_applied , after(unmet_need)
order responded_svy_fa1_1, after(rctelg_efcenr)

save "${${initials}data}/col_fall22_survey_clean" ,replace


