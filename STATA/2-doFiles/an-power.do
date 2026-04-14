*** Gender Criteria Gap in Evaluation: Role of Perceived Intentions and Outcomes ***

/*
Authors:
Nisvan ERKAL
Lata GANGADHARAN
Boon Han KOH
*/

** DO file: Power calculations

*******************************************************************************

**# CHANGE DIRECTORY HERE

local path "..."
cd "`path'"

*******************************************************************************

**# INITIALISATION

capture log close _all
clear all
set more off

cap mkdir "Logs"
cap mkdir "Simulations"

log using "Logs/power.log", replace name(logPower)

*******************************************************************************

**# Prior Beliefs and Discretionary Payments

/* Used GPower */

// Determine resulting sample size
use "Data/beliefs_gender-merged-long.dta", clear
keep if LTRoleMember
tab surveyLeaderFemale

*******************************************************************************

**#  Updating Behavior

// Determine resulting sample size
use "Data/beliefs_gender-merged-long.dta", clear
keep if LTRoleMember
count
global samplesize=r(N)

// Extract past updating data from ExpEcon paper
use "1-RawData/leadershipEL-cleaned-long.dta", clear

keep if b_Group3
keep LogitUnconditional LogitSuccess LogitFail LogitStateGood LogitStateBad ID

rename LogitSuccess LogitPosterior1
rename LogitFail LogitPosterior0
rename ID IDOriginal

gen ID=_n

global NSim=_N

save "Data/beliefs_gender-sim-update.dta", replace

// reproduce estimates of main logit regression (no gender)
qui reshape long LogitPosterior, i(ID) j(StateSuccess)
qui replace LogitStateGood=StateSuccess*LogitStateGood
qui replace LogitStateBad=(1-StateSuccess)*LogitStateBad
				
reg LogitPosterior LogitUnconditional LogitStateGood LogitStateBad, nocons vce(cluster IDOriginal)

// simulation begins here
qui foreach x of numlist 0.1 0.15 0.2 0.25 0.3 {
    qui foreach y of numlist 0.05 { // 0.1 
	    
		// Run simulations with T trials
		clear
		set seed 12345

		global T=1000 // number of simulations
		global N=$samplesize // sample size (number of subject-rounds in paper)
		global R=5 // number of rounds per subject
		global alpha=`y' // Type I error

		global eff=`x' // treatment difference (difference in updating parameter)

		mat pvals=J($T,1,.) // vector for storing p-values

		qui forvalues j=1(1)$T{
			clear
			set obs $N
			gen ID=ceil($NSim*uniform()) // generate IDs randomly from 1-# in original dataset (repeats allowed)
			
			merge m:1 ID using "Data/beliefs_gender-sim-update.dta" // extract data from original dataset
			drop if _merge==2 // dropped unmatched observations from original dataset
			drop _merge
			
			replace ID=ceil(_n/$R) // regenerate ID numbers to be unique, accounting for R rounds per subject
			gen IDRound=_n // generate unique identifiers for the purpose of re-shaping
			
			gen female=0 if ID<=$N/($R*2) // assign half the group to treatment (gender)
			replace female=1 if ID>$N/($R*2)
			
			replace LogitPosterior1=LogitPosterior1+$eff*LogitStateGood if female!=1 // males have higher posterior beliefs given good outcomes
			
			// reshape data below
			reshape long LogitPosterior, i(IDRound) j(StateSuccess)
			replace LogitStateGood=StateSuccess*LogitStateGood
			replace LogitStateBad=(1-StateSuccess)*LogitStateBad
				
			// main logit regression
			reg LogitPosterior i.female#c.LogitUnconditional i.female#c.LogitStateGood i.female#c.LogitStateBad, nocons vce(cluster ID)
			
			testparm female#c.LogitUnconditional, equal
			testparm female#c.LogitStateGood, equal // this is the main test of interest
			scalar pvalue=r(p)
			testparm female#c.LogitStateBad, equal
			
			matrix pvals[`j',1] = pvalue
			
			display `j'
			
		}

		svmat pvals, names(pvalues) // retrieves (and adds to our dataset) the Tx1 matrix with the p-values of all the simulated experiments.

		gen significant=.
		replace significant=1 if pvalues!=. & pvalues<$alpha // Creates a variable with value 1 if the experiment was significant.
		replace significant=0 if pvalues!=. & pvalues>=$alpha

		noisily disp "----------"
		noisily disp "Effect size = `x', Type I error rate = `y'"
		noisily ci means significant // displays the percentage of experiments in which the test was significant (power) and its confidence interval.

	}
}

*******************************************************************************

**#  Gender Criteria Gap

set seed 12345

// Store estimates from original OLS regressions (without controls)
use "Data/beliefs_gender-merged-state.dta", clear
keep if TreatGender
keep if TreatS
keep if LTRoleMember
keep if !Revision

** (A) Discretionary payments by channels - by Leaders' gender
foreach g in "Female" "Male" {
    reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.Round if surveyLeader`g', ///
	vce(cluster ID)
	
	global b_success_`g' = _b[1.StateSuccess]
	global b_posterior_`g' = _b[LTBeliefPosterior]
	global b_cons_`g' = _b[_cons]
	global b_round2_`g' = _b[2.Round]
	global b_round3_`g' = _b[3.Round]
	global b_round4_`g' = _b[4.Round]
	global b_round5_`g' = _b[5.Round]
	global ermse_`g' = e(rmse)
	
	sum LTBeliefPosterior if surveyLeader`g' & StateSuccess
	global postsuccess_mean_`g'=r(mean)
	global postsuccess_sd_`g'=r(sd)
	
	sum LTBeliefPosterior if surveyLeader`g' & StateFailure
	global postfailure_mean_`g'=r(mean)
	global postfailure_sd_`g'=r(sd)
		
}

global T=1000 // number of simulations
global R=5*2 // number of rounds-states per subject
global alpha_range "1 5" // Type I error

global nobs_range "100(10)300"

qui foreach nobs of numlist $nobs_range {

	mat pvals_outcome=J($T,1,.) // vector for storing p-values
	mat pvals_belief=J($T,1,.) // vector for storing p-values
	
	qui forvalues j=1(1)$T{
		// Step 1: Set sample size
		clear
		global n=`nobs' // sample size per gender (target number of subjects)
		global n_g=$n * 2 // double sample size (gender-balanced)
		global N=$n_g * $R // total sample size (number of subject-state-rounds)

		set obs $N

		// Step 2: Generate predictors
		gen ID=ceil(_n/$R) // generate ID numbers to be unique, accounting for R rounds per subject
		gen StateSuccess=mod(ceil(_n*2/$R),2) // assign half of each subject's observations to a good state, and half to a bad state
		gen surveyLeaderFemale=0 if ID<=$N/($R*2) // assign half the group to female leader (treatment)
		replace surveyLeaderFemale=1 if ID>$N/($R*2)
		gen surveyLeaderMale=1-surveyLeaderFemale
		gen Round=. // generate round number
		bys ID StateSuccess: replace Round=_n

		gen LTBeliefPosterior=. // generate variable for posterior beliefs
		* generate posteriors using past data separately by gender
		foreach g in "Female" "Male" {
			disp("${postsuccess_mean_`g'}")
			disp("${postsuccess_sd_`g'}")
			disp("${postfailure_mean_`g'}")
			disp("${postfailure_sd_`g'}")

			replace LTBeliefPosterior=rnormal(${postsuccess_mean_`g'},${postsuccess_sd_`g'}) if StateSuccess==1 & surveyLeader`g'
			replace LTBeliefPosterior=rnormal(${postfailure_mean_`g'},${postfailure_sd_`g'}) if StateSuccess==0 & surveyLeader`g'
		}
		replace LTBeliefPosterior=0 if LTBeliefPosterior<0
		replace LTBeliefPosterior=100 if LTBeliefPosterior>100

		// Step 3: Generate outcome variable
		gen LTAdjAmt=. // generate variable for discretionary payments
		* simulated discretionary payments using estimated model separately by gender
		foreach g in "Female" "Male" {
			disp("${b_cons_`g'}")
			disp("${b_success_`g'}")
			disp("${b_posterior_`g'}")
			disp("${b_round2_`g'}")
			disp("${b_round3_`g'}")
			disp("${b_round4_`g'}")
			disp("${b_round5_`g'}")
			disp("${ermse_`g'}")
			
			replace LTAdjAmt = ${b_cons`g'} + ///
				${b_success_`g'} * StateSuccess + ///
				${b_posterior_`g'} * LTBeliefPosterior + ///
				${b_round2_`g'} * 2.Round + ///
				${b_round3_`g'} * 3.Round + ///
				${b_round4_`g'} * 4.Round + ///
				${b_round5_`g'} * 5.Round + ///
				rnormal(0, ${ermse_`g'}) ///
				if surveyLeader`g'
		}
		replace LTAdjAmt=100 if LTAdjAmt>100
		replace LTAdjAmt=-100 if LTAdjAmt<-100

		// Step 4: Run regressions and store p-values in matrix
		foreach g in "Female" "Male" {
			reg LTAdjAmt i.StateSuccess c.LTBeliefPosterior i.Round if surveyLeader`g'
			est store `g'
		}
		suest Female Male, vce(cluster ID)
		test [Female_mean]1.StateSuccess=[Male_mean]1.StateSuccess
		scalar pvalue=r(p)
		matrix pvals_outcome[`j',1] = pvalue
		test [Female_mean]LTBeliefPosterior=[Male_mean]LTBeliefPosterior
		scalar pvalue=r(p)
		matrix pvals_belief[`j',1] = pvalue
	}
	
	// Run simulation J times for a given number of observations, store as a dataset
	clear
	gen nobs=.
	foreach outcomevar in "outcome" "belief" {
		svmat pvals_`outcomevar', names(pvalues_`outcomevar') // retrieves (and adds to our dataset) the Tx1 matrix with the p-values of all the simulated experiments.
		foreach alpha in $alpha_range {
			gen significant_`outcomevar'_`alpha'=.
			replace significant_`outcomevar'_`alpha'=1 if pvalues_`outcomevar'!=. & pvalues_`outcomevar'<0.0`alpha' // Creates a variable with value 1 if the experiment was significant.
			replace significant_`outcomevar'_`alpha'=0 if pvalues_`outcomevar'!=. & pvalues_`outcomevar'>=0.0`alpha'
		}
		replace nobs=`nobs'
		save "Simulations/sim_channels_`nobs'.dta", replace
	}
}

clear
qui foreach nobs of numlist $nobs_range {
	append using "Simulations/sim_channels_`nobs'.dta"	
}
save "Simulations/sim_channels_all.dta", replace
collapse significant_outcome* significant_belief*, by(nobs)

sum nobs
global nobs_min=r(min)
global nobs_max=r(max)

twoway (scatter significant_outcome_5 nobs, connect(L) color(maroon) lpattern(solid) msymbol(O)) ///
	(scatter significant_outcome_1 nobs, connect(L) color(maroon) lpattern(dash) msymbol(T)) ///
	(scatter significant_belief_5 nobs, connect(L) color(navy) lpattern(solid) msymbol(T)) ///
	(scatter significant_belief_1 nobs, connect(L) color(navy) lpattern(dash) msymbol(T)) ///
	, ///
	legend(order(1 "Diff in outcome: {&alpha} < 0.05" 2 "Diff in outcome: {&alpha} < 0.01" 3 "Diff in belief: {&alpha} < 0.05" 4 "Diff in belief: {&alpha} < 0.01") cols(2)) ///
	yline(0.8, lcolor(black)) ///
	xscale(range($nobs_min $nobs_max)) xlabel($nobs_min(20)$nobs_max) xtitle("# observations (per leader gender)") ///
	yscale(range(0.4 1)) ylabel(0.4(0.1)1, angle(horizontal)) ytitle("Power") ///
	graphregion(color(white)) bgcolor(white)
graph export "Simulations/power_calc_channels.png", replace
window manage close graph _all

*******************************************************************************

log close _all