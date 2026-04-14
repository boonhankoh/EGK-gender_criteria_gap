*** Gender Criteria Gap in Evaluation: Role of Perceived Intentions and Outcomes ***

/*
Authors:
Nisvan ERKAL
Lata GANGADHARAN
Boon Han KOH
*/

** DO file: Additional analysis (appendix)

*******************************************************************************

**# CHANGE DIRECTORY HERE

local path "..."
cd "`path'"

*******************************************************************************

**# INITIALISATION

log close _all
clear all
set more off
set scheme s2color

cap mkdir "Tables"
cap mkdir "Figures"
cap mkdir "Logs"

// Packages to install
*ssc install distplot
*ssc install addplot

log using "Logs/appendix.log", replace name(logAppendix)

*******************************************************************************

**# Table C1: OLS regressions of discretionary payments (pooling across both leader's gender)

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember

* Define controls
global base_covariates "c.DGGivePerc ib0.surveyDGBelief ParameterReturnDiff i.ParameterZero"
global covariates "Age i.Economics i.UG i.Australian PastExp CRTScore"

* Formatting of variables in output table
global var_drop "2.Round 3.Round 4.Round 5.Round 1.Revision Age 1.Economics 1.UG 1.Australian PastExp CRTScore 1.surveyDGBelief 2.surveyDGBelief 3.surveyDGBelief 4.surveyDGBelief 5.surveyDGBelief 6.surveyDGBelief 7.surveyDGBelief"

global var_order "1.surveyLeaderFemale 1.StateSuccess 1.surveyLeaderFemale#1.StateSuccess LTBeliefPosterior 1.surveyLeaderFemale#c.LTBeliefPosterior 1.LTInconNonupdater DGGivePerc ParameterReturnDiff 1.ParameterZero _cons"

global var_labels "1.surveyLeaderFemale "Female leader" 1.StateSuccess "High outcome" 1.surveyLeaderFemale#1.StateSuccess "Female leader x High outcome" LTBeliefPosterior "Posterior belief" 1.surveyLeaderFemale#c.LTBeliefPosterior "Female leader x Posterior belief" 1.LTInconNonupdater "Inconsistent or non-updater" DGGivePerc "% endowment transferred in DG" ParameterReturnDiff "High Return - Low Return" 1.ParameterZero "Zero return if investment fails" _cons "Constant""

* Regressions
eststo clear

// Full sample
eststo, title("Full Sample"): reg LTAdjAmt i.surveyLeaderFemale##i.StateSuccess i.surveyLeaderFemale##c.LTBeliefPosterior i.LTInconNonupdater i.Round i.Revision $base_covariates, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"
estadd local DGbelief "Y"

eststo, title("Full Sample"): reg LTAdjAmt i.surveyLeaderFemale##i.StateSuccess i.surveyLeaderFemale##c.LTBeliefPosterior i.LTInconNonupdater i.Round i.Revision $base_covariates $covariates, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"
estadd local DGbelief "Y"
estadd local controls "Y"

// Exclude non-updaters
eststo, title("Exclude Non-updaters"): reg LTAdjAmt i.surveyLeaderFemale##i.StateSuccess i.surveyLeaderFemale##c.LTBeliefPosterior i.Round i.Revision $base_covariates if !LTNonupdater, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"
estadd local DGbelief "Y"
estadd local dropnon "Y"

eststo, title("Exclude Non-updaters"): reg LTAdjAmt i.surveyLeaderFemale##i.StateSuccess i.surveyLeaderFemale##c.LTBeliefPosterior i.Round i.Revision $base_covariates $covariates if !LTNonupdater, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"
estadd local DGbelief "Y"
estadd local controls "Y"
estadd local dropnon "Y"

// Exclude inconsistent updaters
eststo, title("Exclude Both"): reg LTAdjAmt i.surveyLeaderFemale##i.StateSuccess i.surveyLeaderFemale##c.LTBeliefPosterior i.Round i.Revision $base_covariates if !LTInconNonupdater, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"
estadd local DGbelief "Y"
estadd local dropnon "Y"
estadd local dropinc "Y"

eststo, title("Exclude Both"): reg LTAdjAmt i.surveyLeaderFemale##i.StateSuccess i.surveyLeaderFemale##c.LTBeliefPosterior i.Round i.Revision $base_covariates $covariates if !LTInconNonupdater, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"
estadd local DGbelief "Y"
estadd local controls "Y"
estadd local dropnon "Y"
estadd local dropinc "Y"

* Output table
esttab using "Tables/Paper-regression-payment_channels-interaction_leader_gender" ///
	, ///
	label title("OLS regressions of discretionary payments by the leader's gender") ///
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

**# Figure C2: Distribution of non-updates and inconsistent updates by evaluators

macro drop _all
use "Data/beliefs_gender-merged.dta", clear
keep if LTRoleMember

// (a) non-updates
twoway histogram LTBeliefNonTotal, discrete width(1) start(0) percent ///
	yscale(range(0 60)) ylabel(0(20)60, labsize(medlarge) angle(horizontal)) ///
	xscale(range(0 10)) xlabel(0(1)10, labsize(medlarge)) ///
	xtitle("# non-updates", size(medlarge)) ///
	ytitle("% evaluators", size(medlarge)) ///
	graphregion(color(white)) bgcolor(white) fcolor(gs6) lcolor(gs12)
graph export "Figures/Paper-updating-non_updates.png", replace
window manage close graph _all

// (b) inconsistent updates
twoway histogram LTBeliefIncTotal, discrete width(1) start(0) percent ///
	yscale(range(0 60)) ylabel(0(20)60, labsize(medlarge) angle(horizontal)) ///
	xscale(range(0 10)) xlabel(0(1)10, labsize(medlarge)) ///
	xtitle("# updates in wrong direction", size(medlarge)) ///
	ytitle("% evaluators", size(medlarge)) ///
	graphregion(color(white)) bgcolor(white) fcolor(gs6) lcolor(gs12)
graph export "Figures/Paper-updating-inc_updates.png", replace
window manage close graph _all

// tabulation
tab LTNonupdater
tab LTInconsistent

*******************************************************************************

**# Figure C3: Distributions of discretionary payments, by the leader's gender (excluding non-updaters and inconsistent updaters)

// (a) Empirical cumulative distributions of discretionary payments

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember
keep if !LTNonupdater

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
graph export "Figures/Paper-payments-CDF-by_gender_leader-excl_non_types.png", replace
window manage close graph _all

* Non-parametric test of gender difference in payment amounts
ksmirnov LTAdjAmt, by(surveyLeaderFemale)

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember
keep if !LTInconNonupdater

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
graph export "Figures/Paper-payments-CDF-by_gender_leader-excl_inc_non_types.png", replace
window manage close graph 

* Non-parametric test of gender difference in payment amounts
ksmirnov LTAdjAmt, by(surveyLeaderFemale)

// (b) Histograms of discretionary payments

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember
keep if !LTNonupdater

twoway (hist LTAdjAmt if !surveyLeaderFemale, percent start(-105) width(10) fcolor(gs8) lcolor(none)) ///
	(hist LTAdjAmt if surveyLeaderFemale, percent start(-105) width(10) fcolor(none%0) lcolor(black)) ///
	, ///
	ylabel(0(5)25, angle(horizontal) labsize(medlarge)) ///
	ytitle("% evaluators", size(medlarge)) ///
	xlabel(-100(25)100, labsize(medlarge)) ///
	xtitle("Discretionary Payment", size(medlarge)) ///
	legend(order(1 "Male Leader" 2 "Female Leader" ) rows(1)) ///
	graphregion(color(white)) bgcolor(white)
graph export "Figures/Paper-payments-hist-by_gender_leader-excl_non_types.png", replace
window manage close graph _all

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember
keep if !LTInconNonupdater

twoway (hist LTAdjAmt if !surveyLeaderFemale, percent start(-105) width(10) fcolor(gs8) lcolor(none)) ///
	(hist LTAdjAmt if surveyLeaderFemale, percent start(-105) width(10) fcolor(none%0) lcolor(black)) ///
	, ///
	ylabel(0(5)25, angle(horizontal) labsize(medlarge)) ///
	ytitle("% evaluators", size(medlarge)) ///
	xlabel(-100(25)100, labsize(medlarge)) ///
	xtitle("Discretionary Payment", size(medlarge)) ///
	legend(order(1 "Male Leader" 2 "Female Leader" ) rows(1)) ///
	graphregion(color(white)) bgcolor(white)
graph export "Figures/Paper-payments-hist-by_gender_leader-excl_inc_non_types.png", replace
window manage close graph _all

*******************************************************************************

**# Table C2: OLS regressions of evaluators' posterior belief that the leader has chosen Investment X, by both the leader's and evaluator's gender

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
foreach gM in "Female" "Male" {
	foreach gL in "Female" "Male" {
		
		eststo, title("`gM' Evaluator, `gL' Leader, Full Sample"): reg LogitPosterior LogitPrior LogitStateGood LogitStateBad if Gender`gM' & surveyLeader`gL', nocon vce(cluster ID)

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
}

// exclude non-updaters
foreach gM in "Female" "Male" {
	foreach gL in "Female" "Male" {
		
		eststo, title("`gM' Evaluator, `gL' Leader, Exclude Non-updaters"): reg LogitPosterior LogitPrior LogitStateGood LogitStateBad if Gender`gM' & surveyLeader`gL' & !LTNonupdater, nocon vce(cluster ID)

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
}

// exclude non-updaters and inconsistent updaters
foreach gM in "Female" "Male" {
	foreach gL in "Female" "Male" {
		
		eststo, title("`gM' Evaluator, `gL' Leader, Exclude Both"): reg LogitPosterior LogitPrior LogitStateGood LogitStateBad if Gender`gM' & surveyLeader`gL' & !LTInconNonupdater, nocon vce(cluster ID)

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
}

* Output table
esttab using "Tables/Paper-regression-updating-by_gender_leader-by_gender_eval" ///
	, ///
	label title("OLS regressions of evaluators' posterior belief that the leader has chosen Investment X, by both the leader's and evaluator's gender") ///
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
foreach gM in "Female" "Male" {
	reg LogitPosterior i.surveyLeaderFemale#c.LogitPrior i.surveyLeaderFemale#c.LogitStateGood i.surveyLeaderFemale#c.LogitStateBad if Gender`gM', nocon vce(cluster ID)
	testparm surveyLeaderFemale#c.LogitPrior, equal
	testparm surveyLeaderFemale#c.LogitStateGood, equal
	testparm surveyLeaderFemale#c.LogitStateBad, equal
}

*exclude non-updaters
foreach gM in "Female" "Male" {
	reg LogitPosterior i.surveyLeaderFemale#c.LogitPrior i.surveyLeaderFemale#c.LogitStateGood i.surveyLeaderFemale#c.LogitStateBad if Gender`gM' & !LTNonupdater, nocon vce(cluster ID)
	testparm surveyLeaderFemale#c.LogitPrior, equal
	testparm surveyLeaderFemale#c.LogitStateGood, equal
	testparm surveyLeaderFemale#c.LogitStateBad, equal
}

*exclude non-updaters and inconsistent updaters
foreach gM in "Female" "Male" {
	reg LogitPosterior i.surveyLeaderFemale#c.LogitPrior i.surveyLeaderFemale#c.LogitStateGood i.surveyLeaderFemale#c.LogitStateBad if Gender`gM' & !LTInconNonupdater, nocon vce(cluster ID)
	testparm surveyLeaderFemale#c.LogitPrior, equal
	testparm surveyLeaderFemale#c.LogitStateGood, equal
	testparm surveyLeaderFemale#c.LogitStateBad, equal
}

*******************************************************************************

**# Figure C4: Evaluators' beliefs about amounts transferred by leaders in the dictator game, by the leader's gender

macro drop _all
use "Data/beliefs_gender-merged.dta", clear
keep if LTRoleMember

* Create categories
tab surveyDGBelief, gen(DGBeliefCat)

* Collapse data
collapse (mean) DGBeliefCat*, by(surveyLeaderFemale)

* Reshape data
reshape long DGBeliefCat, i(surveyLeaderFemale) j(Cat)

* Set up position of bars
gen group=.
replace group=3*(Cat-1)+1+surveyLeaderFemale

* Plot graph
twoway (bar DGBeliefCat group if surveyLeaderFemale==0, fcolor(gs2) lcolor(gs2) barwidth(0.75)) ///
	(bar DGBeliefCat group if surveyLeaderFemale==1, fcolor(gs10) lcolor(gs10) barwidth(0.75)) ///
	, ///
	xtitle(" ") xlabel( ///
		1.5 "0" ///
		4.5 "1-50" ///
		7.5 "51-100" ///
		10.5 "101-149" ///
		13.5 "150" ///
		16.5 "151-200" ///
		19.5 "201-250" ///
		22.5 "251-300" ///
		, noticks labsize(small)) ///
	xscale(range(0 24)) ///
	yscale(range(0 0.3)) ylabel(0(0.05)0.3, labsize(medlarge) angle(horizontal)) ///
	ytitle("% endowment transferred in dictator game", size(medlarge)) ///
	legend(order(1 "Male leaders" 2 "Female leaders")) ///
	graphregion(color(white)) bgcolor(white)
graph export "Figures/Paper-belief_dictator_give-hist-by_gender_leader.png", replace
window manage close graph _all

// Non-parametric tests and parametric tests
macro drop _all
use "Data/beliefs_gender-merged.dta", clear
keep if LTRoleMember

ksmirnov surveyDGBelief, by(surveyLeaderFemale)

*******************************************************************************

**# Figure C5: Bubble plots and fitted lines of discretionary payments against evaluators' posterior belief that the leader has chosen Investment X and leader's outcomes, by the leader's gender (with smaller bins)

global covariates "c.DGGivePerc ib0.surveyDGBelief ParameterReturnDiff i.ParameterZero"

local round_value=5

// fitted only, full sample
foreach gL in "Female" "Male" {
	
	use "Data/beliefs_gender-merged-state.dta", clear
	keep if LTRoleMember
	keep if surveyLeader`gL'
	
	gen Posterior_rounded = round(LTBeliefPosterior,`round_value')

	reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.LTInconNonupdater i.Round i.Revision $covariates, ///
		vce(cluster ID)
	margins, at(StateSuccess=1 LTBeliefPosterior=(0(10)100)) saving(x1, replace)
	margins, at(StateSuccess=0 LTBeliefPosterior=(0(10)100)) saving(x2, replace)

	contract LTAdjAmt Posterior_rounded StateSuccess StateFailure

	twoway (scatter LTAdjAmt Posterior_rounded if StateSuccess==1 [fw=_freq], mfcolor(gs8%20) mlcolor(none)) ///
		(scatter LTAdjAmt Posterior_rounded if StateFailure==1 [fw=_freq], mfcolor(none) mlcolor(gs2%20)), ///
		yscale(range(-100 100)) ylabel(-100(50)100, angle(horizontal)) ytitle("Discretionary Payment") ///
		xscale(range(0 100)) xlabel(0(20)100) xtitle("Posterior Belief") ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1)) ///
		graphregion(color(white)) bgcolor(white) ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1))

	use x1.dta, clear

	addplot: (line _ci_ub _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)) ///
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
		legend(order(1 "High outcome" 7 "Fitted line (High outcome)" 2 "Low outcome" 8 "Fitted line (Low outcome)") rows(2))
		
	graph export "Figures/Paper-payment_channels-bubble_fitted-leader_`gL'-full_sample-smaller_bins.png", replace

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
	
	gen Posterior_rounded = round(LTBeliefPosterior,`round_value')

	reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates, ///
		vce(cluster ID)
	margins, at(StateSuccess=1 LTBeliefPosterior=(0(10)100)) saving(x1, replace)
	margins, at(StateSuccess=0 LTBeliefPosterior=(0(10)100)) saving(x2, replace)

	contract LTAdjAmt Posterior_rounded StateSuccess StateFailure

	twoway (scatter LTAdjAmt Posterior_rounded if StateSuccess==1 [fw=_freq], mfcolor(gs8%20) mlcolor(none)) ///
		(scatter LTAdjAmt Posterior_rounded if StateFailure==1 [fw=_freq], mfcolor(none) mlcolor(gs2%20)), ///
		yscale(range(-100 100)) ylabel(-100(50)100, angle(horizontal)) ytitle("Discretionary Payment") ///
		xscale(range(0 100)) xlabel(0(20)100) xtitle("Posterior Belief") ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1)) ///
		graphregion(color(white)) bgcolor(white) ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1))

	use x1.dta, clear

	addplot: (line _ci_ub _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)) ///
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
		legend(order(1 "High outcome" 7 "Fitted line (High outcome)" 2 "Low outcome" 8 "Fitted line (Low outcome)") rows(2))
		
	graph export "Figures/Paper-payment_channels-bubble_fitted-leader_`gL'-excl_non_types-smaller_bins.png", replace

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
	
	gen Posterior_rounded = round(LTBeliefPosterior,`round_value')

	reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates, ///
		vce(cluster ID)
	margins, at(StateSuccess=1 LTBeliefPosterior=(0(10)100)) saving(x1, replace)
	margins, at(StateSuccess=0 LTBeliefPosterior=(0(10)100)) saving(x2, replace)

	contract LTAdjAmt Posterior_rounded StateSuccess StateFailure

	twoway (scatter LTAdjAmt Posterior_rounded if StateSuccess==1 [fw=_freq], mfcolor(gs8%20) mlcolor(none)) ///
		(scatter LTAdjAmt Posterior_rounded if StateFailure==1 [fw=_freq], mfcolor(none) mlcolor(gs2%20)), ///
		yscale(range(-100 100)) ylabel(-100(50)100, angle(horizontal)) ytitle("Discretionary Payment") ///
		xscale(range(0 100)) xlabel(0(20)100) xtitle("Posterior Belief") ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1)) ///
		graphregion(color(white)) bgcolor(white) ///
		legend(order(1 "High outcome" 2 "Low outcome") rows(1))

	use x1.dta, clear

	addplot: (line _ci_ub _at2, lcolor(gs0%75) lwidth(medium) lpattern(-)) ///
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
		legend(order(1 "High outcome" 7 "Fitted line (High outcome)" 2 "Low outcome" 8 "Fitted line (Low outcome)") rows(2))
		
	graph export "Figures/Paper-payment_channels-bubble_fitted-leader_`gL'-excl_inc_non_types-smaller_bins.png", replace

	cap erase x1.dta
	cap erase x2.dta

	window manage close graph _all
}

*******************************************************************************

**# Table C3: OLS regressions of discretionary payments by the leader's gender (with controls for individual characteristics)

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember

* Define controls
global covariates "c.DGGivePerc ib0.surveyDGBelief ParameterReturnDiff i.ParameterZero Age i.Economics i.UG i.Australian PastExp CRTScore"

* Formatting of variables in output table
global var_drop "2.Round 3.Round 4.Round 5.Round 1.Revision 1.surveyDGBelief 2.surveyDGBelief 3.surveyDGBelief 4.surveyDGBelief 5.surveyDGBelief 6.surveyDGBelief 7.surveyDGBelief Age 1.Economics 1.UG 1.Australian PastExp CRTScore"

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
	estadd local controls "Y"
	
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
	estadd local controls "Y"
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
	estadd local controls "Y"
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
esttab using "Tables/Paper-regression-payment_channels-by_gender_leader-with_controls" ///
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
		taskorder wave2 DGbelief controls ///
		dropnon dropinc ///
		N N_clust r2, ///
		fmt( ///
			%9.0f ///
			%9.1f %9.3f ///
			%9.0f ///
			%9s %9s %9s %9s ///
			%9s %9s ///
			%9.0fc %9.0f %9.3f ///
			) ///
		layout( ///
			@ ///
			@ @ ///
			@ ///
			@ @ @ @ ///
			@ @ ///
			@ @ @ ///
			) ///
		labels( ///
			" " ///
			"Outcome/Belief: Coefficient" ///
			"Test of High outcome = 100 x Belief: p-value" ///
			" " ///
			"Control for task order" "Control for Wave 2 data" "Control for beliefs about leader's DG behavior" "Individual controls" ///
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

**# Table C4: OLS regressions of discretionary payments by the leader's gender (against prior beliefs)

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember

* Define controls
global covariates "c.DGGivePerc ib0.surveyDGBelief ParameterReturnDiff i.ParameterZero"

* Formatting of variables in output table
global var_drop "2.Round 3.Round 4.Round 5.Round 1.Revision 1.surveyDGBelief 2.surveyDGBelief 3.surveyDGBelief 4.surveyDGBelief 5.surveyDGBelief 6.surveyDGBelief 7.surveyDGBelief"

global var_order "1.StateSuccess LTBeliefPrior 1.LTInconNonupdater DGGivePerc ParameterReturnDiff 1.ParameterZero _cons"

global var_labels "1.StateSuccess "High outcome" LTBeliefPrior "Prior belief" 1.LTInconNonupdater "Inconsistent or non-updater" DGGivePerc "% endowment transferred in DG" ParameterReturnDiff "High Return - Low Return" 1.ParameterZero "Zero return if investment fails" _cons "Constant""

* Regressions
eststo clear

// Full sample
foreach gL in "Female" "Male" {
	eststo, title("`gL' Leader, Full Sample"): reg LTAdjAmt i.StateSuccess c.LTBeliefPrior i.LTInconNonupdater i.Round i.Revision $covariates if surveyLeader`gL', vce(cluster ID)
	estadd local taskorder "Y"
	estadd local wave2 "Y"
	estadd local DGbelief "Y"
	estadd local controls "Y"
	
	test 100*LTBeliefPrior=1.StateSuccess
	estadd scalar pval r(p)
	
	* Compute ratio and its CI via nlcom
	nlcom (ratio:_b[1.StateSuccess]/_b[LTBeliefPrior])
	
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
	eststo, title("`gL' Leader, Exclude Non-updaters"): reg LTAdjAmt i.StateSuccess c.LTBeliefPrior i.Round i.Revision $covariates if surveyLeader`gL' & !LTNonupdater, vce(cluster ID)
	estadd local taskorder "Y"
	estadd local wave2 "Y"
	estadd local DGbelief "Y"
	estadd local controls "Y"
	estadd local dropnon "Y"
	
	test 100*LTBeliefPrior=1.StateSuccess
	estadd scalar pval r(p)
	
	* Compute ratio and its CI via nlcom
	nlcom (ratio:_b[1.StateSuccess]/_b[LTBeliefPrior])
	
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
	eststo, title("`gL' Leader, Exclude Both"): reg LTAdjAmt i.StateSuccess c.LTBeliefPrior i.Round i.Revision $covariates if surveyLeader`gL' & !LTInconNonupdater, vce(cluster ID)
	estadd local taskorder "Y"
	estadd local wave2 "Y"
	estadd local DGbelief "Y"
	estadd local controls "Y"
	estadd local dropnon "Y"
	estadd local dropinc "Y"
	
	test 100*LTBeliefPrior=1.StateSuccess
	estadd scalar pval r(p)
	
	* Compute ratio and its CI via nlcom
	nlcom (ratio:_b[1.StateSuccess]/_b[LTBeliefPrior])
	
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
esttab using "Tables/Paper-regression-payment_channels-by_gender_leader-no_controls-prior_belief" ///
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
		taskorder wave2 DGbelief controls ///
		dropnon dropinc ///
		N N_clust r2, ///
		fmt( ///
			%9.0f ///
			%9.1f %9.3f ///
			%9.0f ///
			%9s %9s %9s %9s ///
			%9s %9s ///
			%9.0fc %9.0f %9.3f ///
			) ///
		layout( ///
			@ ///
			@ @ ///
			@ ///
			@ @ @ @ ///
			@ @ ///
			@ @ @ ///
			) ///
		labels( ///
			" " ///
			"Outcome/Belief: Coefficient" ///
			"Test of High outcome = 100 x Belief: p-value" ///
			" " ///
			"Control for task order" "Control for Wave 2 data" "Control for beliefs about leader's DG behavior" "Individual controls" ///
			"Exclude non-updaters" "Exclude inconsistent updaters" ///
			"Observations" "# participants (clusters)" "R-squared" ///
			) ///
		) ///
	rtf type replace

// Pairwise tests
*full sample
foreach gL in "Female" "Male" {
	reg LTAdjAmt i.StateSuccess c.LTBeliefPrior i.LTInconNonupdater i.Round i.Revision $covariates if surveyLeader`gL'
	est store `gL'
}
suest Female Male, vce(cluster ID)
test [Female_mean]1.StateSuccess=[Male_mean]1.StateSuccess
test [Female_mean]LTBeliefPrior=[Male_mean]LTBeliefPrior

*exclude non-updaters
foreach gL in "Female" "Male" {
	reg LTAdjAmt i.StateSuccess c.LTBeliefPrior i.Round i.Revision $covariates if surveyLeader`gL' & !LTNonupdater
	est store `gL'
}
suest Female Male, vce(cluster ID)
test [Female_mean]1.StateSuccess=[Male_mean]1.StateSuccess
test [Female_mean]LTBeliefPrior=[Male_mean]LTBeliefPrior

*exclude both
foreach gL in "Female" "Male" {
	reg LTAdjAmt i.StateSuccess c.LTBeliefPrior i.Round i.Revision $covariates if surveyLeader`gL' & !LTInconNonupdater
	est store `gL'
}
suest Female Male, vce(cluster ID)
test [Female_mean]1.StateSuccess=[Male_mean]1.StateSuccess
test [Female_mean]LTBeliefPrior=[Male_mean]LTBeliefPrior

*******************************************************************************

**# Table C5: OLS regressions of positive or negative discretionary payments by the leader's gender

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember

* Define controls
global covariates "c.DGGivePerc ib0.surveyDGBelief ParameterReturnDiff i.ParameterZero"

* Formatting of variables in output table
global var_drop "2.Round 3.Round 4.Round 5.Round 1.Revision 1.surveyDGBelief 2.surveyDGBelief 3.surveyDGBelief 4.surveyDGBelief 5.surveyDGBelief 6.surveyDGBelief"

global var_order "1.StateSuccess LTBeliefPosterior DGGivePerc ParameterReturnDiff 1.ParameterZero _cons"

global var_labels "1.StateSuccess "High outcome" LTBeliefPosterior "Posterior belief" DGGivePerc "% endowment transferred in DG" ParameterReturnDiff "High Return - Low Return" 1.ParameterZero "Zero return if investment fails" _cons "Constant""

* Regressions
eststo clear

// Positive - Exclude inconsistent and non-updaters
foreach gL in "Female" "Male" {
	reg LTAdjBonus i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates if surveyLeader`gL' & !LTInconNonupdater, vce(cluster ID)
	
	test 100*LTBeliefPosterior=1.StateSuccess
	local pval = r(p)
	
	* Compute ratio via nlcom
	nlcom (ratio:_b[1.StateSuccess]/_b[LTBeliefPosterior])
	matrix b = r(b)
    local ratio      = b[1,1]
	
	eststo
	estadd local taskorder "Y"
	estadd local wave2 "Y"
	estadd local DGbelief "Y"
	estadd local dropnon "Y"
	estadd local dropinc "Y"
	estadd scalar pval = `pval'
	estadd scalar ratio_b  = `ratio'
}

// Negative - Exclude inconsistent and non-updaters
foreach gL in "Female" "Male" {
	reg LTAdjPenalty i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates if surveyLeader`gL' & !LTInconNonupdater, vce(cluster ID)
	
	test 100*LTBeliefPosterior=1.StateSuccess
	local pval = r(p)
	
	* Compute ratio via nlcom
	nlcom (ratio:_b[1.StateSuccess]/_b[LTBeliefPosterior])
	matrix b = r(b)
    local ratio      = b[1,1]
	
	eststo
	estadd local taskorder "Y"
	estadd local wave2 "Y"
	estadd local DGbelief "Y"
	estadd local dropnon "Y"
	estadd local dropinc "Y"
	estadd scalar pval = `pval'
	estadd scalar ratio_b  = `ratio'
}

* Output table
esttab using "Tables/Paper-regression-payment_channels-positive_negative_payment-by_gender_leader-no_controls" ///
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
*Positive payment - exclude both
foreach gL in "Female" "Male" {
	reg LTAdjBonus i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates if surveyLeader`gL' & !LTInconNonupdater
	est store `gL'
}
suest Female Male, vce(cluster ID)
test [Female_mean]1.StateSuccess=[Male_mean]1.StateSuccess
test [Female_mean]LTBeliefPosterior=[Male_mean]LTBeliefPosterior

*Negative payment - exclude both
foreach gL in "Female" "Male" {
	reg LTAdjPenalty i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates if surveyLeader`gL' & !LTInconNonupdater
	est store `gL'
}
suest Female Male, vce(cluster ID)
test [Female_mean]1.StateSuccess=[Male_mean]1.StateSuccess
test [Female_mean]LTBeliefPosterior=[Male_mean]LTBeliefPosterior

*******************************************************************************

**# Table C6: OLS regressions of discretionary payments, by the leader's gender (excluding evaluators who incorrectly predicted leader's gender)

macro drop _all
use "Data/beliefs_gender-merged-state.dta", clear
keep if LTRoleMember
keep if LeaderFemaleCorrect

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
	estadd local controls "Y"
	
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
	estadd local controls "Y"
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
	estadd local controls "Y"
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
esttab using "Tables/Paper-regression-payment_channels-by_gender_leader-no_controls-keep_leader_gender_correct" ///
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
		taskorder wave2 DGbelief controls ///
		dropnon dropinc ///
		N N_clust r2, ///
		fmt( ///
			%9.0f ///
			%9.1f %9.3f ///
			%9.0f ///
			%9s %9s %9s %9s ///
			%9s %9s ///
			%9.0fc %9.0f %9.3f ///
			) ///
		layout( ///
			@ ///
			@ @ ///
			@ ///
			@ @ @ @ ///
			@ @ ///
			@ @ @ ///
			) ///
		labels( ///
			" " ///
			"Outcome/Belief: Coefficient" ///
			"Test of High outcome = 100 x Belief: p-value" ///
			" " ///
			"Control for task order" "Control for Wave 2 data" "Control for beliefs about leader's DG behavior" "Individual controls" ///
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

**# Table C7: OLS regressions of discretionary payments, by the leader's and evaluator's gender

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
foreach gM in "Female" "Male" {
	foreach gL in "Female" "Male" {
		eststo, title("`gM' Evaluator, `gL' Leader, Full Sample"): reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.LTInconNonupdater i.Round i.Revision $covariates if Gender`gM' & surveyLeader`gL', vce(cluster ID)
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
}

// Exclude non-updaters
foreach gM in "Female" "Male" {
	foreach gL in "Female" "Male" {
		eststo, title("`gM' Evaluator, `gL' Leader, Exclude Non-updaters"): reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates if Gender`gM' & surveyLeader`gL' & !LTNonupdater, vce(cluster ID)
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
}

// Exclude inconsistent and non-updaters
foreach gM in "Female" "Male" {
	foreach gL in "Female" "Male" {
		eststo, title("`gM' Evaluator, `gL' Leader, Exclude Both"): reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates if Gender`gM' & surveyLeader`gL' & !LTInconNonupdater, vce(cluster ID)
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
}

* Output table
esttab using "Tables/Paper-regression-payment_channels-by_gender_leader-no_controls-by_gender_eval" ///
	, ///
	label title("OLS regressions of discretionary payments, by the leader's and evaluator's gender") ///
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
		N N_clust r2, ///
		fmt( ///
			%9.0f ///
			%9.1f %9.3f ///
			%9.0f ///
			%9s %9s %9s ///
			%9.0fc %9.0f %9.3f ///
			) ///
		layout( ///
			@ ///
			@ @ ///
			@ ///
			@ @ @ ///
			@ @ @ ///
			) ///
		labels( ///
			" " ///
			"Outcome/Belief: Coefficient" ///
			"Test of High outcome = 100 x Belief: p-value" ///
			" " ///
			"Control for task order" "Control for Wave 2 data" "Control for beliefs about leader's DG behavior" ///
			"Observations" "# participants (clusters)" "R-squared" ///
			) ///
		) ///
	rtf type replace

// Pairwise tests
*full sample
foreach gM in "Female" "Male" {
	disp("`gM' Evaluator")
	foreach gL in "Female" "Male" {
		reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.LTInconNonupdater i.Round i.Revision $covariates if Gender`gM' & surveyLeader`gL'
		est store `gL'
	}
	suest Female Male, vce(cluster ID)
	test [Female_mean]1.StateSuccess=[Male_mean]1.StateSuccess
	test [Female_mean]LTBeliefPosterior=[Male_mean]LTBeliefPosterior
}

*exclude non-updaters
foreach gM in "Female" "Male" {
	disp("`gM' Evaluator")
	foreach gL in "Female" "Male" {
		reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates if Gender`gM' & surveyLeader`gL' & !LTNonupdater
		est store `gL'
	}
	suest Female Male, vce(cluster ID)
	test [Female_mean]1.StateSuccess=[Male_mean]1.StateSuccess
	test [Female_mean]LTBeliefPosterior=[Male_mean]LTBeliefPosterior
}

*exclude both
foreach gM in "Female" "Male" {
	disp("`gM' Evaluator")
	foreach gL in "Female" "Male" {
		reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.Round i.Revision $covariates if Gender`gM' & surveyLeader`gL' & !LTInconNonupdater
		est store `gL'
	}
	suest Female Male, vce(cluster ID)
	test [Female_mean]1.StateSuccess=[Male_mean]1.StateSuccess
	test [Female_mean]LTBeliefPosterior=[Male_mean]LTBeliefPosterior
}

*******************************************************************************

**# Table D1: OLS regressions of leaders' investment choice

macro drop _all
use "Data/beliefs_gender-merged-long.dta", clear

* Define controls
global covariates "Age i.Economics i.UG i.Australian PastExp CRTScore"

* Formatting of variables in output table
global var_drop "2.Round 3.Round 4.Round 5.Round 1.Revision Age 1.Economics 1.UG 1.Australian PastExp CRTScore"

global var_order "1.GenderFemale DGGivePerc RGNumRiskyChoice ParameterReturnDiff 1.ParameterZero LTBeliefRewardSuccess 1.GenderFemale#c.LTBeliefRewardSuccess LTBeliefRewardFailure 1.GenderFemale#c.LTBeliefRewardFailure _cons"

global var_labels "1.GenderFemale "Female leader" DGGivePerc "% endowment transferred in DG" RGNumRiskyChoice "# risky choices in RT" ParameterReturnDiff "High Return - Low Return" 1.ParameterZero "Zero return if investment fails" LTBeliefRewardSuccess "Expected payment for high outcome" LTBeliefRewardFailure "Expected payment for low outcome" 1.GenderFemale#c.LTBeliefRewardSuccess "Female leader × Expected payment for high outcome" 1.GenderFemale#c.LTBeliefRewardFailure "Female leader × Expected payment for low outcome" _cons "Constant""

* Regressions
eststo clear

eststo, title("All"): reg LTHighEff i.GenderFemale DGGivePerc RGNumRiskyChoice ParameterReturnDiff i.ParameterZero i.Round i.Revision, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"

eststo, title("All"): reg LTHighEff i.GenderFemale DGGivePerc RGNumRiskyChoice ParameterReturnDiff i.ParameterZero i.Round i.Revision $covariates, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"
estadd local controls "Y"

eststo, title("Actual leaders"): reg LTHighEff i.GenderFemale DGGivePerc RGNumRiskyChoice ParameterReturnDiff i.ParameterZero i.Round i.Revision if LTRoleLeader, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"

eststo, title("Actual leaders"): reg LTHighEff i.GenderFemale DGGivePerc RGNumRiskyChoice ParameterReturnDiff i.ParameterZero i.Round i.Revision $covariates if LTRoleLeader, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"
estadd local controls "Y"

eststo, title("Actual leaders"): reg LTHighEff i.GenderFemale DGGivePerc RGNumRiskyChoice ParameterReturnDiff i.ParameterZero i.Round i.Revision $covariates LTBeliefRewardSuccess LTBeliefRewardFailure if LTRoleLeader, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"
estadd local controls "Y"

eststo, title("Actual leaders"): reg LTHighEff i.GenderFemale##c.LTBeliefRewardSuccess i.GenderFemale##c.LTBeliefRewardFailure DGGivePerc RGNumRiskyChoice ParameterReturnDiff i.ParameterZero i.Round i.Revision $covariates if LTRoleLeader, vce(cluster ID)
estadd local taskorder "Y"
estadd local wave2 "Y"
estadd local controls "Y"

lincom c.LTBeliefRewardSuccess + 1.GenderFemale#c.LTBeliefRewardSuccess
lincom c.LTBeliefRewardFailure + 1.GenderFemale#c.LTBeliefRewardFailure

* Output table
esttab using "Tables/Paper-regression-effort" ///
	, ///
	label title("OLS regressions of leaders' investment choice") ///
	mtitles ///
	star(* 0.10 ** 0.05 *** 0.01) ///
	se(3) b(3) nogaps noomit nobase ///
	drop($var_drop) ///
	order($var_order) ///
	varlabels($var_labels) ///
	stats( ///
		taskorder wave2 controls ///
		N N_clust r2 ///
		, ///
		fmt( ///
			%9s %9s %9s  ///
			%9.0fc %9.0f %9.3f ///
			) ///
		layout( ///
			@ @ @ ///
			@ @ @ ///
			) ///
		labels( ///
			"Control for task order" "Control for Wave 2 data" "Individual controls" ///
			"Observations" "# participants (clusters)" "R-squared" ///
			) ///
		) ///
	rtf type replace

*******************************************************************************

capture log close _all