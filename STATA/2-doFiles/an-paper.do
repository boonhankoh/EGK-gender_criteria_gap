*** Gender Criteria Gap in Evaluation: Role of Perceived Intentions and Outcomes ***

/*
Authors:
Nisvan ERKAL
Lata GANGADHARAN
Boon Han KOH
*/

** DO file: Main analysis for main text

*******************************************************************************

**# CHANGE DIRECTORY HERE

local path "..."
cd "`path'"

*******************************************************************************

**# INITIALISATION

capture log close _all
clear all
set more off
set scheme s2color

cap mkdir "Tables"
cap mkdir "Figures"
cap mkdir "Logs"

// Packages to install
*ssc install distplot
*ssc install addplot

log using "Logs/paper.log", replace name(logPaper)

*******************************************************************************

**# Footnote 12: % of evaluators getting leader's gender correct

macro drop _all
use "Data/beliefs_gender-merged.dta", clear
keep if LTRoleMember

tab LeaderFemaleCorrect
reg LeaderFemaleCorrect i.LTFemaleLeader i.GenderFemale, vce(robust)

*******************************************************************************

**# In-text (p.9): Proportion of groups with mixed-gender pairs of evaluators

macro drop _all
use "Data/beliefs_gender-merged.dta", clear
keep if LTRoleMember

bys Session LTGroup: egen numfemale=sum(GenderFemale)
bys Session LTGroup: egen countmembers=count(LTGroup)
gen percfemale=numfemale/countmembers
tab percfemale

*******************************************************************************

**# Footnote 13: Text analysis of response to question about clarity of instructions

clear all
import delimited "1-RawData/surveyExpUnderstanding-for_text_analysis-Xiao-251110.csv", clear
rename id ID

foreach x in allclear payoffmechanismisnotclearenoughi {
	replace `x'=0 if `x'==.
}

rename payoffmechanismisnotclearenoughi unclear_mechanism

save "Data/surveyExpUnderstanding-coded.dta", replace

macro drop _all
use "Data/beliefs_gender-merged.dta", clear

merge 1:1 ID using "Data/surveyExpUnderstanding-coded.dta", force

tab unclear_mechanism

reg ctrl1stattempttotal i.unclear_mechanism, vce(robust)

*******************************************************************************

**# In-text (p.10): Average earnings

macro drop _all
use "Data/beliefs_gender-merged.dta", clear

sum FinalEarningsAUD, detail

*******************************************************************************

**# In-text (p.10): Number of participants by wave and role

macro drop _all
use "Data/beliefs_gender-merged.dta", clear

count
tab Revision
tab LTRoleLeader
tab Revision LTRoleLeader

*******************************************************************************

**# In-text (p.13): % leaders receiving either positive or negative payments

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember

tab LTAdjNone
tab LTAdjNone surveyLeaderFemale, col

reg LTAdjNone i.surveyLeaderFemale, vce(cluster ID)

*******************************************************************************

**# Footnote 22: Comprehension question performance, time spent, and CRT performance of non-updaters and inconsistent updaters

macro drop _all
use "Data/beliefs_gender-merged.dta", clear
keep if LTRoleMember

// Comprehension question performance of non-updaters and inconsistent updaters
foreach x in ctrl1stattempttotal LTTimeBeliefPrior_mean LTTimeBeliefPosterior_mean LTTimeReward_mean CRTScore {
	disp "********************"
	disp "`x'"
	bys LTNonupdater: sum `x' if !LTInconsistent
	bys LTInconsistent: sum `x' if !LTNonupdater
	ranksum `x' if !LTInconsistent, by(LTNonupdater)
	ranksum `x' if !LTNonupdater, by(LTInconsistent)
}

*******************************************************************************

**# Footnote 25: Prior beliefs separately by the evaluator's gender

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember

foreach x in "Female" "Male" {
	disp "***************"
	disp "`x' evaluators"
	reg LTBeliefPrior i.surveyLeaderFemale if Gender`x', vce(cluster ID)
}

*******************************************************************************

**# In-text (p.18): Gender difference in posterior beliefs

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember

reg LTBeliefPosterior i.surveyLeaderFemale if StateSuccess, vce(cluster ID)
reg LTBeliefPosterior i.surveyLeaderFemale if StateFailure, vce(cluster ID)

*******************************************************************************

**# Footnote 28: Gender difference in DG behavior

macro drop _all
use "Data/beliefs_gender-merged.dta", clear

reg DGGivePerc i.GenderFemale, vce(robust)

*******************************************************************************

**# In-text (p.21) and footnote 35: Positive payment for low outcome and negative payment for high outcome

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember

tab LTAdjBonus if StateFailure
tab LTAdjBonus surveyLeaderFemale if StateFailure, col exact

tab LTAdjPenalty if StateSuccess
tab LTAdjPenalty surveyLeaderFemale if StateSuccess, col exact

*******************************************************************************

**# Table 2: OLS regressions of evaluators' prior belief that the leader has chosen Investment X

macro drop _all
use "Data/beliefs_gender-merged-long.dta", clear
keep if LTRoleMember

* Define controls
global covariates "Age i.Economics i.UG i.Australian PastExp CRTScore"

* Formatting of variables in output table
global var_drop "2.Round 3.Round 4.Round 5.Round 1.Revision 1.surveyDGBelief 2.surveyDGBelief 3.surveyDGBelief 4.surveyDGBelief 5.surveyDGBelief 6.surveyDGBelief 7.surveyDGBelief Age 1.Economics 1.UG 1.Australian PastExp CRTScore" // "2.Round 3.Round 4.Round 5.Round 1.Revision 1.surveyDGBelief 2.surveyDGBelief 3.surveyDGBelief 4.surveyDGBelief 5.surveyDGBelief 6.surveyDGBelief 7.surveyDGBelief Age 1.Economics 1.UG 1.Australian PastExp CRTScore"

global var_order "1.surveyLeaderFemale 1.LTHighEff ParameterReturnDiff 1.ParameterZero 1.LTInconNonupdater _cons"

global var_labels "1.surveyLeaderFemale "Female leader" 1.LTHighEff "Chose Investment X as leader" ParameterReturnDiff "High Return - Low Return" 1.ParameterZero "Zero return if investment fails" 1.LTInconNonupdater "Inconsistent or non-updater" _cons "Constant""

* Regressions
eststo clear

eststo, title("Full Sample"): reg LTBeliefPrior i.surveyLeaderFemale i.LTHighEff ParameterReturnDiff i.ParameterZero ib0.surveyDGBelief i.Round i.Revision, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"
estadd local DGbelief "Y"

eststo, title("Full Sample"): reg LTBeliefPrior i.surveyLeaderFemale i.LTHighEff ParameterReturnDiff i.ParameterZero i.LTInconNonupdater ib0.surveyDGBelief i.Round i.Revision $covariates, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"
estadd local DGbelief "Y"
estadd local controls "Y"

eststo, title("Exclude Non-updaters"): reg LTBeliefPrior i.surveyLeaderFemale i.LTHighEff ParameterReturnDiff i.ParameterZero ib0.surveyDGBelief i.Round i.Revision $covariates if !LTNonupdater, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"
estadd local DGbelief "Y"
estadd local controls "Y"
estadd local dropnon "Y"

eststo, title("Exclude Both"): reg LTBeliefPrior i.surveyLeaderFemale i.LTHighEff ParameterReturnDiff i.ParameterZero ib0.surveyDGBelief i.Round i.Revision $covariates if !LTInconNonupdater, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"
estadd local DGbelief "Y"
estadd local controls "Y"
estadd local dropnon "Y"
estadd local dropinc "Y"

* Output table
esttab using "Tables/Paper-regression-prior" ///
	, ///
	label title("OLS regressions of evaluators' prior belief that the leader has chosen Investment X") ///
	mtitles ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	se(3) b(3) nogaps noomit nobase ///
	drop($var_drop) ///
	order($var_order) ///
	varlabels($var_labels) ///
	stats( ///
		taskorder wave2 DGbelief controls ///
		dropnon dropinc ///
		N N_clust r2, ///
		fmt( ///
			%9s %9s %9s %9s ///
			%9s %9s ///
			%9.0fc %9.0f %9.3f ///
			) ///
		layout( ///
			@ @ @ @ ///
			@ @ ///
			@ @ @ ///
			) ///
		labels( ///
			"Control for task order" "Control for Wave 2 data" "Control for beliefs about leader's DG behavior" "Individual controls" ///
			"Exclude non-updaters" "Exclude inconsistent updaters" ///
			"Observations" "# participants (clusters)" "R-squared" ///
			) ///
		) ///
	rtf type replace

*******************************************************************************

**# Table 3: OLS regressions of evaluators' posterior belief that the leader has chosen Investment X, by the leader's gender

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember

* Formatting of variables in output table
global var_drop " "

global var_order "LogitPrior LogitStateGood LogitStateBad"

global var_labels "LogitPrior "Logit (prior belief)" LogitStateGood "High outcome × logit(p)" LogitStateBad "Low outcome × logit(1-p)""

* Regressions
eststo clear

// full sample
foreach g in "Female" "Male" {
	
	eststo, title("`g' Leader, Full Sample"): reg LogitPosterior LogitPrior LogitStateGood LogitStateBad if surveyLeader`g', nocon vce(cluster ID)

	lincom LogitPrior-1
	local prior_num = r(estimate) + 1
	local prior_num_disp = trim(string(`prior_num', "%9.3f"))
	local prior_stars = cond(r(p)<0.01,"***", cond(r(p)<0.05,"**", cond(r(p)<0.10,"*","")))
	estadd local prior_est "`prior_num_disp'`prior_stars'"
	estadd scalar prior_se r(se)
	estadd scalar prior_pval r(p)
	
	lincom LogitStateGood-1
	local good_num = r(estimate) + 1
	local good_num_disp = trim(string(`good_num', "%9.3f"))
	local good_stars = cond(r(p)<0.01,"***", cond(r(p)<0.05,"**", cond(r(p)<0.10,"*","")))
	estadd local good_est "`good_num_disp'`good_stars'"
	estadd scalar good_se r(se)
	estadd scalar good_pval r(p)
	
	lincom LogitStateBad-1
	local bad_num = r(estimate)+1
	local bad_num_disp = trim(string(`bad_num', "%9.3f"))
	local bad_stars = cond(r(p)<0.01,"***", cond(r(p)<0.05,"**", cond(r(p)<0.10,"*","")))
	estadd local bad_est "`bad_num_disp'`bad_stars'"
	estadd scalar bad_se r(se)
	estadd scalar bad_pval r(p)
	
	lincom LogitStateGood-LogitStateBad
	local diff_num = r(estimate)
	local diff_num_disp = trim(string(`diff_num', "%9.3f"))
	local diff_stars = cond(r(p)<0.01,"***", cond(r(p)<0.05,"**", cond(r(p)<0.10,"*","")))
	estadd local diff_est "`diff_num_disp'`diff_stars'"
	estadd scalar diff_se r(se)
	estadd scalar diff_pval r(p)
	
}

// exclude non-updaters
foreach g in "Female" "Male" {
	
	eststo, title("`g' Leader, Exclude Non-updaters"): reg LogitPosterior LogitPrior LogitStateGood LogitStateBad if surveyLeader`g' & !LTNonupdater, nocon vce(cluster ID)

	lincom LogitPrior-1
	local prior_num = r(estimate) + 1
	local prior_num_disp = trim(string(`prior_num', "%9.3f"))
	local prior_stars = cond(r(p)<0.01,"***", cond(r(p)<0.05,"**", cond(r(p)<0.10,"*","")))
	estadd local prior_est "`prior_num_disp'`prior_stars'"
	estadd scalar prior_se r(se)
	estadd scalar prior_pval r(p)
	
	lincom LogitStateGood-1
	local good_num = r(estimate) + 1
	local good_num_disp = trim(string(`good_num', "%9.3f"))
	local good_stars = cond(r(p)<0.01,"***", cond(r(p)<0.05,"**", cond(r(p)<0.10,"*","")))
	estadd local good_est "`good_num_disp'`good_stars'"
	estadd scalar good_se r(se)
	estadd scalar good_pval r(p)
	
	lincom LogitStateBad-1
	local bad_num = r(estimate)+1
	local bad_num_disp = trim(string(`bad_num', "%9.3f"))
	local bad_stars = cond(r(p)<0.01,"***", cond(r(p)<0.05,"**", cond(r(p)<0.10,"*","")))
	estadd local bad_est "`bad_num_disp'`bad_stars'"
	estadd scalar bad_se r(se)
	estadd scalar bad_pval r(p)
	
	lincom LogitStateGood-LogitStateBad
	local diff_num = r(estimate)
	local diff_num_disp = trim(string(`diff_num', "%9.3f"))
	local diff_stars = cond(r(p)<0.01,"***", cond(r(p)<0.05,"**", cond(r(p)<0.10,"*","")))
	estadd local diff_est "`diff_num_disp'`diff_stars'"
	estadd scalar diff_se r(se)
	estadd scalar diff_pval r(p)
	
}

// exclude non-updaters and inconsistent updaters
foreach g in "Female" "Male" {
	
	eststo, title("`g' Leader, Exclude Both"): reg LogitPosterior LogitPrior LogitStateGood LogitStateBad if surveyLeader`g' & !LTInconNonupdater, nocon vce(cluster ID)

	lincom LogitPrior-1
	local prior_num = r(estimate) + 1
	local prior_num_disp = trim(string(`prior_num', "%9.3f"))
	local prior_stars = cond(r(p)<0.01,"***", cond(r(p)<0.05,"**", cond(r(p)<0.10,"*","")))
	estadd local prior_est "`prior_num_disp'`prior_stars'"
	estadd scalar prior_se r(se)
	estadd scalar prior_pval r(p)
	
	lincom LogitStateGood-1
	local good_num = r(estimate) + 1
	local good_num_disp = trim(string(`good_num', "%9.3f"))
	local good_stars = cond(r(p)<0.01,"***", cond(r(p)<0.05,"**", cond(r(p)<0.10,"*","")))
	estadd local good_est "`good_num_disp'`good_stars'"
	estadd scalar good_se r(se)
	estadd scalar good_pval r(p)
	
	lincom LogitStateBad-1
	local bad_num = r(estimate)+1
	local bad_num_disp = trim(string(`bad_num', "%9.3f"))
	local bad_stars = cond(r(p)<0.01,"***", cond(r(p)<0.05,"**", cond(r(p)<0.10,"*","")))
	estadd local bad_est "`bad_num_disp'`bad_stars'"
	estadd scalar bad_se r(se)
	estadd scalar bad_pval r(p)
	
	lincom LogitStateGood-LogitStateBad
	local diff_num = r(estimate)
	local diff_num_disp = trim(string(`diff_num', "%9.3f"))
	local diff_stars = cond(r(p)<0.01,"***", cond(r(p)<0.05,"**", cond(r(p)<0.10,"*","")))
	estadd local diff_est "`diff_num_disp'`diff_stars'"
	estadd scalar diff_se r(se)
	estadd scalar diff_pval r(p)
	
}

* Output table
esttab using "Tables/Paper-regression-updating-by_gender_leader" ///
	, ///
	label title("OLS regressions of evaluators' posterior belief that the leader has chosen Investment X, by the leader's gender") ///
	mtitles ///
	nostar ///
	se(3) b(3) nogaps noomit nobase ///
	drop($var_drop) ///
	order($var_order) ///
	varlabels($var_labels) ///
	stats( ///
		prior_est prior_se ///
		good_est good_se ///
		bad_est bad_se ///
		diff_est diff_se ///
		prior_pval good_pval bad_pval diff_pval ///
		N N_clust r2, ///
		fmt( ///
			%s %9.3f ///
			%s %9.3f ///
			%s %9.3f ///
			%s %9.3f ///
			%9.3f %9.3f %9.3f %9.3f ///
			%9.0fc %9.0f %9.3f ///
			) ///
		layout( ///
			@ (@) ///
			@ (@) ///
			@ (@) ///
			@ (@) ///
			@ @ @ @ ///
			@ @ @ ///
			) ///
		labels( ///
			"Logit (prior belief)" " " ///
			"High outcome × logit(p)" " " ///
			"Low outcome × logit(1-p)" " " ///
			"gamma_H - gamma_L" " " ///
			"p-value (prior)" "p-value (good)" "p-value (bad)" "p-value (diff)" ///
			"Observations" "# participants (clusters)" "R-squared" ///
			) ///
		) ///
	rtf type replace

// F vs. M test of equality of coefficients
*full sample
reg LogitPosterior i.surveyLeaderFemale#c.LogitPrior i.surveyLeaderFemale#c.LogitStateGood i.surveyLeaderFemale#c.LogitStateBad, nocon vce(cluster ID)
testparm surveyLeaderFemale#c.LogitPrior, equal
testparm surveyLeaderFemale#c.LogitStateGood, equal
testparm surveyLeaderFemale#c.LogitStateBad, equal

*exclude non-updaters
reg LogitPosterior i.surveyLeaderFemale#c.LogitPrior i.surveyLeaderFemale#c.LogitStateGood i.surveyLeaderFemale#c.LogitStateBad if !LTNonupdater, nocon vce(cluster ID)
testparm surveyLeaderFemale#c.LogitPrior, equal
testparm surveyLeaderFemale#c.LogitStateGood, equal
testparm surveyLeaderFemale#c.LogitStateBad, equal

*exclude non-updaters and inconsistent updaters
reg LogitPosterior i.surveyLeaderFemale#c.LogitPrior i.surveyLeaderFemale#c.LogitStateGood i.surveyLeaderFemale#c.LogitStateBad if !LTInconNonupdater, nocon vce(cluster ID)
testparm surveyLeaderFemale#c.LogitPrior, equal
testparm surveyLeaderFemale#c.LogitStateGood, equal
testparm surveyLeaderFemale#c.LogitStateBad, equal

*******************************************************************************

**# Table 4: OLS regressions of discretionary payments by the leader's gender

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember

* Define controls
global covariates "c.DGGivePerc ib0.surveyDGBelief ParameterReturnDiff i.ParameterZero"

* Formatting of variables in output table
global var_drop "2.Round 3.Round 4.Round 5.Round 1.Revision 1.surveyDGBelief 2.surveyDGBelief 3.surveyDGBelief 4.surveyDGBelief 5.surveyDGBelief 6.surveyDGBelief 7.surveyDGBelief"

global var_order "1.StateSuccess LTBeliefPosterior 1.LTInconNonupdater DGGivePerc ParameterReturnDiff 1.ParameterZero _cons"

global var_labels "1.StateSuccess "High outcome" LTBeliefPosterior "Posterior belief" 1.LTInconNonupdater "Inconsistent or non-updater" DGGivePerc "% endowment transferred in DG" ParameterReturnDiff "High Return - Low Return" 1.ParameterZero "Zero return if investment fails" _cons "Constant""

* Regressions
eststo clear

// Full sample
foreach gL in "Female" "Male" {
	eststo, title("`gL' Leader, Full Sample"): reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.LTInconNonupdater i.Round i.Revision $covariates if surveyLeader`gL', vce(cluster ID)
	estadd local taskorder "Y"
	estadd local wave2 "Y"
	estadd local DGbelief "Y"
	
	test 100*LTBeliefPosterior=1.StateSuccess
	estadd scalar pval r(p)
	
	* Compute ratio and its CI via nlcom
	nlcom (ratio:_b[1.StateSuccess]/_b[LTBeliefPosterior])
	
	* Extract point estimate, SE, and CI bounds
    matrix b = r(b)
    matrix V = r(V)
    local ratio      = b[1,1]
    local ratio_se   = sqrt(V[1,1])
    local ratio_lb   = r(b)[1,1] - invnormal(0.975)*`ratio_se'
    local ratio_ub   = r(b)[1,1] + invnormal(0.975)*`ratio_se'
	
	* Make one string: [lb, ub]
	local ratio_ci : display "[" %4.1f `ratio_lb' ", " %4.1f `ratio_ub' "]"
	estadd scalar ratio_b  = `ratio'
    estadd local ratio_ci = "`ratio_ci'"
}

// Exclude non-updaters
foreach gL in "Female" "Male" {
	eststo, title("`gL' Leader, Exclude Non-updaters"): reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates if surveyLeader`gL' & !LTNonupdater, vce(cluster ID)
	estadd local taskorder "Y"
	estadd local wave2 "Y"
	estadd local DGbelief "Y"
	estadd local dropnon "Y"
	
	test 100*LTBeliefPosterior=1.StateSuccess
	estadd scalar pval r(p)
	
	* Compute ratio and its CI via nlcom
	nlcom (ratio:_b[1.StateSuccess]/_b[LTBeliefPosterior])
	
	* Extract point estimate, SE, and CI bounds
    matrix b = r(b)
    matrix V = r(V)
    local ratio      = b[1,1]
    local ratio_se   = sqrt(V[1,1])
    local ratio_lb   = r(b)[1,1] - invnormal(0.975)*`ratio_se'
    local ratio_ub   = r(b)[1,1] + invnormal(0.975)*`ratio_se'
	
	* Make one string: [lb, ub]
	local ratio_ci : display "[" %4.1f `ratio_lb' ", " %4.1f `ratio_ub' "]"
	estadd scalar ratio_b  = `ratio'
    estadd local ratio_ci = "`ratio_ci'"
}

// Exclude inconsistent and non-updaters
foreach gL in "Female" "Male" {
	eststo, title("`gL' Leader, Exclude Both"): reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates if surveyLeader`gL' & !LTInconNonupdater, vce(cluster ID)
	estadd local taskorder "Y"
	estadd local wave2 "Y"
	estadd local DGbelief "Y"
	estadd local dropnon "Y"
	estadd local dropinc "Y"
	
	test 100*LTBeliefPosterior=1.StateSuccess
	estadd scalar pval r(p)
	
	* Compute ratio and its CI via nlcom
	nlcom (ratio:_b[1.StateSuccess]/_b[LTBeliefPosterior])
	
	* Extract point estimate, SE, and CI bounds
    matrix b = r(b)
    matrix V = r(V)
    local ratio      = b[1,1]
    local ratio_se   = sqrt(V[1,1])
    local ratio_lb   = r(b)[1,1] - invnormal(0.975)*`ratio_se'
    local ratio_ub   = r(b)[1,1] + invnormal(0.975)*`ratio_se'
	
	* Make one string: [lb, ub]
	local ratio_ci : display "[" %4.1f `ratio_lb' ", " %4.1f `ratio_ub' "]"
	estadd scalar ratio_b  = `ratio'
    estadd local ratio_ci = "`ratio_ci'"
}


* Output table
esttab using "Tables/Paper-regression-payment_channels-by_gender_leader-no_controls" ///
	, ///
	label title("OLS regressions of discretionary payments by the leader's gender") ///
	mtitles ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	se(3) b(3) nogaps noomit nobase ///
	drop($var_drop) ///
	order($var_order) ///
	varlabels($var_labels) ///
	stats( ///
		blank /// 
		ratio_b pval ///
		blank ///
		taskorder wave2 DGbelief ///
		dropnon dropinc ///
		N N_clust r2, ///
		fmt( ///
			%9.0f ///
			%9.1f %9.3f ///
			%9.0f ///
			%9s %9s %9s ///
			%9s %9s ///
			%9.0fc %9.0f %9.3f ///
			) ///
		layout( ///
			@ ///
			@ @ ///
			@ ///
			@ @ @ ///
			@ @ ///
			@ @ @ ///
			) ///
		labels( ///
			" " ///
			"Outcome/Belief: Coefficient" ///
			"Test of High outcome = 100 x Belief: p-value" ///
			" " ///
			"Control for task order" "Control for Wave 2 data" "Control for beliefs about leader's DG behavior" ///
			"Exclude non-updaters" "Exclude inconsistent updaters" ///
			"Observations" "# participants (clusters)" "R-squared" ///
			) ///
		) ///
	rtf type replace

// Pairwise tests
*full sample
foreach gL in "Female" "Male" {
	reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.LTInconNonupdater i.Round i.Revision $covariates if surveyLeader`gL'
	est store `gL'
}
suest Female Male, vce(cluster ID)
test [Female_mean]1.StateSuccess=[Male_mean]1.StateSuccess
test [Female_mean]LTBeliefPosterior=[Male_mean]LTBeliefPosterior

*exclude non-updaters
foreach gL in "Female" "Male" {
	reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates if surveyLeader`gL' & !LTNonupdater
	est store `gL'
}
suest Female Male, vce(cluster ID)
test [Female_mean]1.StateSuccess=[Male_mean]1.StateSuccess
test [Female_mean]LTBeliefPosterior=[Male_mean]LTBeliefPosterior

*exclude both
foreach gL in "Female" "Male" {
	reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates if surveyLeader`gL' & !LTInconNonupdater
	est store `gL'
}
suest Female Male, vce(cluster ID)
test [Female_mean]1.StateSuccess=[Male_mean]1.StateSuccess
test [Female_mean]LTBeliefPosterior=[Male_mean]LTBeliefPosterior

*******************************************************************************

**# Figure 1: Distributions of discretionary payments, by the leader's gender

// (a) Empirical cumulative distributions of discretionary payments

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember

distplot LTAdjAmt, over(surveyLeaderFemale) ///
	scheme(s1color) ///
	c(J J) ///
	lcolor(gs10 gs0) lpattern(solid dash) ///
	ylabel(0(0.2)1, angle(horizontal) labsize(medlarge)) ///
	ytitle("Cumulative Probability", size(medlarge)) ///
	xlabel(-100(25)100, labsize(medlarge)) ///
	xtitle("Discretionary Payment", size(medlarge)) ///
	legend(order(1 "Male Leader" 2 "Female Leader" ) rows(1)) ///
	xline(0, lcolor(gs0)) ///
	graphregion(color(white)) bgcolor(white)
graph export "Figures/Paper-payments-CDF-by_gender_leader-full_sample.png", replace
window manage close graph _all

// (b) Histograms of discretionary payments

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember

twoway (hist LTAdjAmt if !surveyLeaderFemale, percent start(-105) width(10) fcolor(gs8) lcolor(none)) ///
	(hist LTAdjAmt if surveyLeaderFemale, percent start(-105) width(10) fcolor(none%0) lcolor(black)) ///
	, ///
	ylabel(0(5)25, angle(horizontal) labsize(medlarge)) ///
	ytitle("% evaluators", size(medlarge)) ///
	xlabel(-100(25)100, labsize(medlarge)) ///
	xtitle("Discretionary Payment", size(medlarge)) ///
	legend(order(1 "Male Leader" 2 "Female Leader" ) rows(1)) ///
	graphregion(color(white)) bgcolor(white)
graph export "Figures/Paper-payments-hist-by_gender_leader-full_sample.png", replace
window manage close graph _all

// Non-parametric test of gender difference in payment amounts
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember

ksmirnov LTAdjAmt, by(surveyLeaderFemale)

*******************************************************************************

**# Figure 2: Leaders' expectations about evaluators' discretionary payment decisions, by the leader's gender

// (a) Male versus female leaders (expectations about payments)

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleLeader

distplot LTBeliefReward, over(GenderFemale) ///
	scheme(s1color) ///
	c(J J) ///
	lcolor(gs10 gs0) lpattern(solid dash) ///
	ylabel(0(0.2)1, angle(horizontal) labsize(medlarge)) ///
	ytitle("Cumulative Probability", size(medlarge)) ///
	xlabel(-100(25)100, labsize(medlarge)) ///
	xtitle("Discretionary Payment", size(medlarge)) ///
	legend(order(1 "Male Leader" 2 "Female Leader" ) rows(1)) ///
	xline(0, lcolor(gs0)) ///
	graphregion(color(white)) bgcolor(white)
graph export "Figures/Paper-belief_payments-CDF-by_gender_leader.png", replace
window manage close graph _all

// (b) and (c) Expectations versus actual (female leaders; male leaders)

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear

gen DPamt=.
replace DPamt=LTAdjAmt if LTRoleMember
replace DPamt=LTBeliefReward if LTRoleLeader
gen leaderfemale=.
replace leaderfemale=surveyLeaderFemale if LTRoleMember
replace leaderfemale=GenderFemale if LTRoleLeader

distplot DPamt if leaderfemale, over(LTRoleLeader) ///
	scheme(s1color) ///
	c(J J) ///
	lcolor(gs10 gs0) lpattern(solid dash) ///
	ylabel(0(0.2)1, angle(horizontal) labsize(medlarge)) ///
	ytitle("Cumulative Probability", size(medlarge)) ///
	xlabel(-100(25)100, labsize(medlarge)) ///
	xtitle("Discretionary Payment", size(medlarge)) ///
	legend(order(1 "Actual payments" 2 "Expectations of payments" ) rows(1)) ///
	xline(0, lcolor(gs0)) ///
	graphregion(color(white)) bgcolor(white)
graph export "Figures/Paper-payments_actual_perceived-CDF-leader_female.png", replace
window manage close graph _all

distplot DPamt if !leaderfemale, over(LTRoleLeader) ///
	scheme(s1color) ///
	c(J J) ///
	lcolor(gs10 gs0) lpattern(solid dash) ///
	ylabel(0(0.2)1, angle(horizontal) labsize(medlarge)) ///
	ytitle("Cumulative Probability", size(medlarge)) ///
	xlabel(-100(25)100, labsize(medlarge)) ///
	xtitle("Discretionary Payment", size(medlarge)) ///
	legend(order(1 "Actual payments" 2 "Expectations of payments" ) rows(1)) ///
	xline(0, lcolor(gs0)) ///
	graphregion(color(white)) bgcolor(white)
graph export "Figures/Paper-payments_actual_perceived-CDF-leader_male.png", replace
window manage close graph _all

// Non-parametric test of difference in beliefs about payment amounts versus actual payment amounts, by leader's gender

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear

gen DPamt=.
replace DPamt=LTAdjAmt if LTRoleMember
replace DPamt=LTBeliefReward if LTRoleLeader
gen leaderfemale=.
replace leaderfemale=surveyLeaderFemale if LTRoleMember
replace leaderfemale=GenderFemale if LTRoleLeader

ksmirnov DPamt if LTRoleLeader, by(leaderfemale)
ksmirnov DPamt if leaderfemale, by(LTRoleLeader)
ksmirnov DPamt if !leaderfemale, by(LTRoleLeader)

*******************************************************************************

**# Figure 3: Evaluators' prior belief that the leader has chosen Investment X, by the leader's gender

// Bar graph - with CI (participant clustered SEs)

macro drop _all
use "Data/beliefs_gender-merged-long.dta", clear
keep if LTRoleMember

* Generate CIs
gen r_lb=.
gen r_ub=.

foreach x of numlist 0/1 {
	local cond "if surveyLeaderFemale==`x'"
	
	reg LTBeliefPrior `cond', vce(cluster ID)
	
	lincom _cons
	replace r_lb=r(lb) `cond'
	replace r_ub=r(ub) `cond'
}

* Collapse data
collapse (mean) LTBeliefPrior r_lb r_ub (count) n_prior=LTBeliefPrior, by(surveyLeaderFemale)

* Set up position of bars
gen group=.
replace group=1 if surveyLeaderFemale==0
replace group=2 if surveyLeaderFemale==1

* Plot graph
twoway (bar LTBeliefPrior group, fcolor(gs6) lcolor(gs6) barwidth(0.75)) ///
	(rcap r_lb r_ub group, lcolor(black)), ///
	xtitle(" ") xlabel(1 "Male Leader" 2 "Female Leader", noticks) ///
	xscale(range(0.25 2.75)) ///
	yscale(range(0 60)) ylabel(0(10)60, labsize(medlarge) angle(horizontal)) ///
	ytitle("Average prior belief that leader chose Investment X", size(medsmall)) ///
	legend(off) ///
	graphregion(color(white)) bgcolor(white)
graph export "Figures/Paper-prior-bar-by_gender_leader-full_sample.png", replace
window manage close graph _all

// Non-parametric tests and parametric tests

use "Data/beliefs_gender-merged-long.dta", clear
keep if LTRoleMember

reg LTBeliefPrior i.surveyLeaderFemale, vce(cluster ID)

*******************************************************************************

**# Figure 4: Fitted line of discretionary payments against evaluators' posterior belief that the leader has chosen Investment X and leader's outcomes, by the leader's gender

global covariates "c.DGGivePerc ib0.surveyDGBelief ParameterReturnDiff i.ParameterZero"

// fitted only, full sample
foreach gL in "Female" "Male" {
	
	use "Data/beliefs_gender-merged-state.dta", clear
	keep if LTRoleMember
	keep if surveyLeader`gL'

	reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.LTInconNonupdater i.Round i.Revision $covariates, ///
		vce(cluster ID)
	margins, at(StateSuccess=1 LTBeliefPosterior=(0(10)100)) saving(x1, replace)
	margins, at(StateSuccess=0 LTBeliefPosterior=(0(10)100)) saving(x2, replace)

	use x1.dta, clear

	twoway (line _ci_ub _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)) ///
		(line _ci_lb _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)),  ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1))

	use x2.dta, clear

	addplot: (line _ci_ub _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)) ///
		(line _ci_lb _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)), ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1))

	use x1.dta, clear

	addplot: (line _margin _at2, lcolor(gs0) lwidth(thick) lpattern(_.)),  ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1))

	use x2.dta, clear

	addplot: (line _margin _at2, lcolor(gs0) lwidth(thick)), ///
		yscale(range(-100 100)) ylabel(-100(50)100, angle(horizontal)) ytitle("Discretionary Payment") ///
		xscale(range(0 100)) xlabel(0(20)100) xtitle("Posterior Belief") ///
		graphregion(color(white)) bgcolor(white) ///
		title(" ") ///
		legend(order(5 "High outcome" 6 "Low outcome") rows(1))
		
	graph export "Figures/Paper-payment_channels-fitted-leader_`gL'-full_sample.png", replace

	cap erase x1.dta
	cap erase x2.dta

	window manage close graph _all
}

// fitted only, exclude non-updaters
foreach gL in "Female" "Male" {
	
	use "Data/beliefs_gender-merged-state.dta", clear
	keep if LTRoleMember
	keep if surveyLeader`gL'
	keep if !LTNonupdater

	reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates, ///
		vce(cluster ID)
	margins, at(StateSuccess=1 LTBeliefPosterior=(0(10)100)) saving(x1, replace)
	margins, at(StateSuccess=0 LTBeliefPosterior=(0(10)100)) saving(x2, replace)

	use x1.dta, clear

	twoway (line _ci_ub _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)) ///
		(line _ci_lb _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)),  ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1))

	use x2.dta, clear

	addplot: (line _ci_ub _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)) ///
		(line _ci_lb _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)), ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1))

	use x1.dta, clear

	addplot: (line _margin _at2, lcolor(gs0) lwidth(thick) lpattern(_.)),  ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1))

	use x2.dta, clear

	addplot: (line _margin _at2, lcolor(gs0) lwidth(thick)), ///
		yscale(range(-100 100)) ylabel(-100(50)100, angle(horizontal)) ytitle("Discretionary Payment") ///
		xscale(range(0 100)) xlabel(0(20)100) xtitle("Posterior Belief") ///
		graphregion(color(white)) bgcolor(white) ///
		title(" ") ///
		legend(order(5 "High outcome" 6 "Low outcome") rows(1))
		
	graph export "Figures/Paper-payment_channels-fitted-leader_`gL'-excl_non_types.png", replace

	cap erase x1.dta
	cap erase x2.dta

	window manage close graph _all
}

// fitted only, exclude inconsistent and non-updaters
foreach gL in "Female" "Male" {
	
	use "Data/beliefs_gender-merged-state.dta", clear
	keep if LTRoleMember
	keep if surveyLeader`gL'
	keep if !LTInconNonupdater

	reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates, ///
		vce(cluster ID)
	margins, at(StateSuccess=1 LTBeliefPosterior=(0(10)100)) saving(x1, replace)
	margins, at(StateSuccess=0 LTBeliefPosterior=(0(10)100)) saving(x2, replace)

	use x1.dta, clear

	twoway (line _ci_ub _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)) ///
		(line _ci_lb _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)),  ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1))

	use x2.dta, clear

	addplot: (line _ci_ub _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)) ///
		(line _ci_lb _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)), ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1))

	use x1.dta, clear

	addplot: (line _margin _at2, lcolor(gs0) lwidth(thick) lpattern(_.)),  ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1))

	use x2.dta, clear

	addplot: (line _margin _at2, lcolor(gs0) lwidth(thick)), ///
		yscale(range(-100 100)) ylabel(-100(50)100, angle(horizontal)) ytitle("Discretionary Payment") ///
		xscale(range(0 100)) xlabel(0(20)100) xtitle("Posterior Belief") ///
		graphregion(color(white)) bgcolor(white) ///
		title(" ") ///
		legend(order(5 "High outcome" 6 "Low outcome") rows(1))
		
	graph export "Figures/Paper-payment_channels-fitted-leader_`gL'-excl_inc_non_types.png", replace

	cap erase x1.dta
	cap erase x2.dta

	window manage close graph _all
}

*******************************************************************************

capture log close _all