*** Gender Criteria Gap in Evaluation: Role of Perceived Intentions and Outcomes ***

/*
Authors:
Nisvan ERKAL
Lata GANGADHARAN
Boon Han KOH
*/

** DO file: Clean raw dataset for analysis

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
cap mkdir "Data"

*******************************************************************************

capture log close _all
log using "Logs/clean.log", replace name(logClean)

// Drop variables, generate variables
use "1-RawData/beliefs_gender-raw.dta", clear

* Drop group ** Session 18 - ID 278635 should be 728635 instead. (Drop entire group)
qui sum LTGroup if Session==18 & RandomID==728635
local g=r(mean)
drop if Session==18 & LTGroup==`g'

* Drop unnecessary variables
drop LTCostHigh LTCostLow LTReturnSuccess LTReturnFailure ///
	LTHighEff LTBeliefInterim LTBeliefSuccess LTBeliefFailure ///
	LTRewardSuccess LTRewardFailure ///
	LTBeliefInvest LTHighEffHyp LTBeliefRewardSuccess LTBeliefRewardFailure ///
	LTTimeEffort LTTimeBeliefInterim LTTimeBeliefPosterior LTTimeReward ///
	LTTimeBeliefInvest LTTimeEffortHyp LTTimeBeliefReward ///
	LTInvestSuccess LTLeaderHighEff LTBeliefPost LTBeliefScoreInt ///
	LTBeliefScorePost LTBeliefPayoffInt LTBeliefPayoffPost LTBeliefPaidQns ///
	LTBeliefPaidInt LTBeliefPaidPost LTMemPaidBelief ///
	LTPayoffInvest LTPayoffBelief LTBSRSuccessInt LTBSRSuccessPost ///
	LTLeaderReward LTMemReward LTMemPaidReward ///
	PayoffLT RollInvest RollBeliefQns RollBeliefPayment RollMemPaidBelief RollMemReward ///
	LTGroupBase
	
drop DH DD TimeTRYAGAINPart1ControlQuestion TimeSUBMITPart2DGInputOK ///
	TimeSUBMITDECISIONSQuestionnaire DU TimeSUBMITDECISIONSPart1PRACTICE PG ///
	TimeSUBMITDECISIONSPart1ACTUALSt PQ AFD TimeSUBMITDECISIONQuestionnaireP DS ///
	TimeSUBMITDECISIONPart1PRACTICES PE PJ TimeSUBMITDECISIONPart1ACTUALSta ///
	TimeSUBMITANSWERQuestionnairePar TimePREVIOUSPAGEPart1ControlQues ///
	TimeNEXTPAGEPart1ControlQuestion TimeMALEPOSITIVEQuestionnairePar ///
	TimeMALENEGATIVEQuestionnairePar TimeINVESTMENTYPart1PRACTICEStag ///
	TimeINVESTMENTYPart1ACTUALStage2 TimeINVESTMENTYPart1ACTUALStage1 ///
	TimeINVESTMENTXPart1PRACTICEStag TimeINVESTMENTXPart1ACTUALStage2 ///
	TimeINVESTMENTXPart1ACTUALStage1 TimeINSECTSGOODQuestionnairePart ///
	TimeINSECTSBADQuestionnairePart6 TimeIAMREADYPart1IntroOK ///
	TimeGOBACKPart1PRACTICEStage1Inv TimeGOBACKPart1ACTUALStage1Inves ///
	TimeFLOWERSGOODQuestionnairePart TimeFLOWERSBADQuestionnairePart6 ///
	TimeFEMALEPOSITIVEQuestionnaireP TimeFEMALENEGATIVEQuestionnaireP ///
	TimeCONTINUEQuestionnairePart61A TimeCONTINUEQuestionnairePart41A ///
	TimeCONTINUEQuestionnairePart31A TimeCONTINUEQuestionnairePart26M ///
	TimeCONTINUEQuestionnairePart25M TimeCONTINUEQuestionnairePart24M ///
	TimeCONTINUEQuestionnairePart23M TimeCONTINUEQuestionnairePart23L ///
	TimeCONTINUEQuestionnairePart22A TimeCONTINUEQuestionnairePart21A ///
	TimeCONTINUEQuestionnairePart1Al TimeCONTINUEPart1PRACTICEStage2I ///
	TimeCONTINUEPart1PRACTICEStage1I TimeCONTINUEPart1ACTUALStage2Tas ///
	TimeCONTINUEPart1ACTUALStage2Inf TimeCONTINUEPart1ACTUALStage1Tas ///
	TimeCONTINUEPart1ACTUALStage1Inf DI DE TimeCHECKANSWERSPart1ControlQues ///
	TimeBEGINROUND2QuestionnairePart TimeBEGINROUND1QuestionnairePart ///
	TimeBEGINQuestionnairePart5AllCR TimeBEGINQUESTIONNAIREQuestionna ///
	TimeBEGINPRACTICEROUND2Questionn TimeBEGINPRACTICEROUND1Questionn ///
	TimeBEGINEXPERIMENTENTERIDNUMBER

* Create ID and treatment variables
gen ID=_n
order ID, first

rename TreatPayoffRelevant TreatS
label var TreatS "TreatS"

* Rename interim beliefs
rename LTBeliefInterimPrac LTBeliefPriorPrac
rename LTBeliefInterim1 LTBeliefPrior1
rename LTBeliefInterim2 LTBeliefPrior2
rename LTBeliefInterim3 LTBeliefPrior3
rename LTBeliefInterim4 LTBeliefPrior4
rename LTBeliefInterim5 LTBeliefPrior5
rename LTTimeBeliefInterim1 LTTimeBeliefPrior1
rename LTTimeBeliefInterim2 LTTimeBeliefPrior2
rename LTTimeBeliefInterim3 LTTimeBeliefPrior3
rename LTTimeBeliefInterim4 LTTimeBeliefPrior4
rename LTTimeBeliefInterim5 LTTimeBeliefPrior5
rename TimeStartBeliefInterim TimeStartBeliefPrior
rename TimeEndBeliefInterim TimeEndBeliefPrior
rename LTBeliefInterimPaidRound LTBeliefPriorPaidRound

* Rename payoff adjustment decisions
foreach x of numlist 1/5 {
rename LTRewardSuccess`x' LTAdjAmtSuccess`x'
rename LTRewardFailure`x' LTAdjAmtFailure`x'

replace LTAdjAmtSuccess`x'=. if LTRoleLeader==1
replace LTAdjAmtFailure`x'=. if LTRoleLeader==1
}

* Binary variable for decision to adjust payoff
foreach x of numlist 1/5 {

gen LTAdjSuccess`x'=.
gen LTAdjFailure`x'=.

replace LTAdjSuccess`x'=1	if LTAdjAmtSuccess`x'!=. & LTAdjAmtSuccess`x' != 0
replace LTAdjFailure`x'=1	if LTAdjAmtFailure`x'!=. & LTAdjAmtFailure`x' != 0

replace LTAdjSuccess`x'=0	if LTAdjAmtSuccess`x'!=. & LTAdjAmtSuccess`x' == 0
replace LTAdjFailure`x'=0	if LTAdjAmtFailure`x'!=. & LTAdjAmtFailure`x' == 0
}

* Ordered categorical variable for adjustment decisions
foreach x of numlist 1/5 {

gen LTAdjBonusSuccess`x'=.
gen LTAdjPenaltySuccess`x'=.
gen LTAdjNoneSuccess`x'=.
gen LTAdjBonusFailure`x'=.
gen LTAdjPenaltyFailure`x'=.
gen LTAdjNoneFailure`x'=.

replace LTAdjBonusSuccess`x'= 1		if LTAdjAmtSuccess`x'!=. & LTAdjAmtSuccess`x' >  0
replace LTAdjBonusSuccess`x'= 0		if LTAdjAmtSuccess`x'!=. & LTAdjAmtSuccess`x' <= 0
replace LTAdjPenaltySuccess`x'= 1	if LTAdjAmtSuccess`x'!=. & LTAdjAmtSuccess`x' <  0
replace LTAdjPenaltySuccess`x'= 0	if LTAdjAmtSuccess`x'!=. & LTAdjAmtSuccess`x' >= 0
replace LTAdjNoneSuccess`x'= 1		if LTAdjAmtSuccess`x'!=. & LTAdjAmtSuccess`x' == 0
replace LTAdjNoneSuccess`x'= 0		if LTAdjAmtSuccess`x'!=. & LTAdjAmtSuccess`x' != 0

replace LTAdjBonusFailure`x'= 1		if LTAdjAmtFailure`x'!=. & LTAdjAmtFailure`x' >  0
replace LTAdjBonusFailure`x'= 0		if LTAdjAmtFailure`x'!=. & LTAdjAmtFailure`x' <= 0
replace LTAdjPenaltyFailure`x'= 1	if LTAdjAmtFailure`x'!=. & LTAdjAmtFailure`x' <  0
replace LTAdjPenaltyFailure`x'= 0	if LTAdjAmtFailure`x'!=. & LTAdjAmtFailure`x' >= 0
replace LTAdjNoneFailure`x'= 1		if LTAdjAmtFailure`x'!=. & LTAdjAmtFailure`x' == 0
replace LTAdjNoneFailure`x'= 0		if LTAdjAmtFailure`x'!=. & LTAdjAmtFailure`x' != 0

gen LTAdjCatSuccess`x'=.
gen LTAdjCatFailure`x'=.

replace LTAdjCatSuccess`x'= -1	if LTAdjAmtSuccess`x'!=. & LTAdjAmtSuccess`x' <  0
replace LTAdjCatSuccess`x'= 1	if LTAdjAmtSuccess`x'!=. & LTAdjAmtSuccess`x' >  0
replace LTAdjCatSuccess`x'= 0	if LTAdjAmtSuccess`x'!=. & LTAdjAmtSuccess`x' == 0

replace LTAdjCatFailure`x'= -1	if LTAdjAmtFailure`x'!=. & LTAdjAmtFailure`x' <  0
replace LTAdjCatFailure`x'= 1	if LTAdjAmtFailure`x'!=. & LTAdjAmtFailure`x' >  0
replace LTAdjCatFailure`x'= 0	if LTAdjAmtFailure`x'!=. & LTAdjAmtFailure`x' == 0

}

order LTAdjBonus* LTAdjPenalty* LTAdjNone* LTAdjCat*, after(LTAdjAmtFailure5)

* Create absolute adjustment amount

foreach x of numlist 1/5 {

gen LTAdjAbsSuccess`x'=abs(LTAdjAmtSuccess`x')
gen LTAdjAbsFailure`x'=abs(LTAdjAmtFailure`x')

}

* Create unconditional bonus/penalty amounts
foreach x of numlist 1/5 {

gen LTUncondBonusSuccess`x'		= LTAdjAbsSuccess`x' if LTAdjBonusSuccess`x'	==1
gen LTUncondBonusFailure`x'		= LTAdjAbsFailure`x' if LTAdjBonusFailure`x'	==1
gen LTUncondPenaltySuccess`x'	= LTAdjAbsSuccess`x' if LTAdjPenaltySuccess`x'	==1
gen LTUncondPenaltyFailure`x'	= LTAdjAbsFailure`x' if LTAdjPenaltyFailure`x'	==1

replace LTUncondBonusSuccess`x'		= 0 if LTAdjBonusSuccess`x'		==0
replace LTUncondBonusFailure`x'		= 0 if LTAdjBonusFailure`x'		==0
replace LTUncondPenaltySuccess`x'	= 0 if LTAdjPenaltySuccess`x'	==0
replace LTUncondPenaltyFailure`x'	= 0 if LTAdjPenaltyFailure`x'	==0

}

* Create conditional bonus/penalty amounts
foreach x of numlist 1/5 {

gen LTCondBonusSuccess`x'	= LTAdjAbsSuccess`x' if LTAdjBonusSuccess`x'	==1
gen LTCondBonusFailure`x'	= LTAdjAbsFailure`x' if LTAdjBonusFailure`x'	==1
gen LTCondPenaltySuccess`x'	= LTAdjAbsSuccess`x' if LTAdjPenaltySuccess`x'	==1
gen LTCondPenaltyFailure`x'	= LTAdjAbsFailure`x' if LTAdjPenaltyFailure`x'	==1

}

order LTAdjAbs* LTUncond* LTCond*, after(LTAdjAmtFailure5)

* Code survey data
tostring CRTInput1 CRTInput2 CRTInput3 CRTInput1trimmed CRTInput2trimmed CRTInput3trimmed, replace

label var PastExp "# previous experiments"

tostring surveyLeaderRace, replace
replace surveyLeaderRace="Australian or New Zealander" if surveyLeaderRace=="1"
replace surveyLeaderRace="Indigenous Australian or Torres Strait Islander" if surveyLeaderRace=="2"
replace surveyLeaderRace="East or Southeast Asian" if surveyLeaderRace=="3"
replace surveyLeaderRace="Indian" if surveyLeaderRace=="4"
replace surveyLeaderRace="Middle Eastern" if surveyLeaderRace=="5"
replace surveyLeaderRace="European" if surveyLeaderRace=="6"
replace surveyLeaderRace="North American" if surveyLeaderRace=="7"
replace surveyLeaderRace="South American" if surveyLeaderRace=="8"
replace surveyLeaderRace="African" if surveyLeaderRace=="9"
replace surveyLeaderRace="-" if surveyLeaderRace=="0"

gen Age=.
replace Age=2019-YearBorn if Session < 42
replace Age=2025-YearBorn if Session >= 42
label var Age "Age"
order Age, after(YearBorn)

gen Female=1 if Gender=="Female"
replace Female=0 if Gender!="Female"
label var Female "Female"
order Female, after(Gender)

gen Economics=1 if FieldStudy=="Commerce (Economics)"
replace Economics=0 if FieldStudy!="Commerce (Economics)"
label var Economics "Study economics"
order Economics, after(FieldStudy)

gen UG=1 if StudyLvl=="1st year undergraduate" | StudyLvl=="2nd year undergraduate" | StudyLvl=="3rd year undergraduate" | StudyLvl=="4th year undergraduate"
replace UG=0 if StudyLvl!="1st year undergraduate" & StudyLvl!="2nd year undergraduate" & StudyLvl!="3rd year undergraduate" & StudyLvl!="4th year undergraduate"
label var UG "Undergraduate student"
gen PG=1 if StudyLvl=="Graduate student"
replace PG=0 if StudyLvl!="Graduate student"
label var PG "Postgraduate student"
order UG PG, after(StudyLvl)

gen Australian=1 if Nationality=="Australian"
replace Australian=0 if Nationality!="Australian"
label var Australian "Australian"
order Australian, after(Nationality)

gen InternationalStu=1 if AusResidence=="Student visa"
replace InternationalStu=0 if AusResidence!="Student visa"
label var InternationalStu "International student"
order InternationalStu, after(AusResidence)

* Leader's ethnicity
preserve
drop if LTRoleMember==1
rename Ethnicity LTLeaderRace
save temp.dta, replace
restore
merge m:1 Session LTGroup using temp.dta , keepusing(LTLeaderRace)
drop _merge
tab surveyLeaderRace LTLeaderRace if LTRoleMember==1
cap erase temp.dta

* Prediction of leader's gender
replace surveyLeaderFemale=. if LTRoleLeader==1
gen surveyLeaderMale=.
replace surveyLeaderMale=1-surveyLeaderFemale if LTRoleMember==1
order surveyLeaderMale, after(surveyLeaderFemale)

* Dummy for member's gender vs. leader's gender
gen Gender_L_M_Actual=.
gen Gender_L_M_Perceived=.

foreach x in "Male" "Female" {
foreach y in "Male" "Female" {

local gX = substr("`x'",1,1)
local gY = substr("`y'",1,1)

gen Gender_L_M_Actual_`gX'_`gY'=.
gen Gender_L_M_Perceived_`gX'_`gY'=.

replace Gender_L_M_Actual_`gX'_`gY'=1 		if LTRoleMember==1 & LT`x'Leader==1 & Gender`y'==1
replace Gender_L_M_Actual_`gX'_`gY'=0 		if LTRoleMember==1 & (LT`x'Leader!=1 | Gender`y'!=1)
replace Gender_L_M_Perceived_`gX'_`gY'=1 	if LTRoleMember==1 & surveyLeader`x'==1 & Gender`y'==1
replace Gender_L_M_Perceived_`gX'_`gY'=0 	if LTRoleMember==1 & (surveyLeader`x'!=1 | Gender`y'!=1)

}
}

replace Gender_L_M_Actual=1 	if Gender_L_M_Actual_M_M==1
replace Gender_L_M_Perceived=1	if Gender_L_M_Perceived_M_M==1

replace Gender_L_M_Actual=2 	if Gender_L_M_Actual_M_F==1
replace Gender_L_M_Perceived=2	if Gender_L_M_Perceived_M_F==1

replace Gender_L_M_Actual=3 	if Gender_L_M_Actual_F_M==1
replace Gender_L_M_Perceived=3	if Gender_L_M_Perceived_F_M==1

replace Gender_L_M_Actual=4 	if Gender_L_M_Actual_F_F==1
replace Gender_L_M_Perceived=4	if Gender_L_M_Perceived_F_F==1

label define Gender_L_Mlbl 1 "Male Leader / Male Member", replace
label define Gender_L_Mlbl 2 "Male Leader / Female Member", add
label define Gender_L_Mlbl 3 "Female Leader / Male Member", add
label define Gender_L_Mlbl 4 "Female Leader / Female Member", add
label values Gender_L_M_Actual Gender_L_Mlbl
label values Gender_L_M_Perceived Gender_L_Mlbl

order Gender_*, after(surveyLeaderMale)

* Accuracy and certainty of prediction about leader's gender and ethnicity
gen LeaderFemaleCorrect=1 if LTRoleMember==1 & surveyLeaderFemale==LTFemaleLeader
replace LeaderFemaleCorrect=0 if LTRoleMember==1 & surveyLeaderFemale!=LTFemaleLeader
gen LeaderRaceCorrect=1 if LTRoleMember==1 & surveyLeaderRace==LTLeaderRace
replace LeaderRaceCorrect=0 if LTRoleMember==1 & surveyLeaderRace!=LTLeaderRace

gen LeaderFemaleCertain=1 if LTRoleMember==1 & surveyLeaderFemaleCertainty>=5
replace LeaderFemaleCertain=0 if LTRoleMember==1 & surveyLeaderFemaleCertainty<5
gen LeaderRaceCertain=1 if LTRoleMember==1 & surveyLeaderRaceCertainty>=5
replace LeaderRaceCertain=0 if LTRoleMember==1 & surveyLeaderRaceCertainty<5

label var LeaderFemaleCorrect "Guessed leader's gender correctly"
label var LeaderRaceCorrect "Guessed leader's ethnicity correctly"

label var LeaderFemaleCertain "Certain about leader's gender"
label var LeaderRaceCertain "Certain about leader's ethnicity"

order LeaderFemaleCorrect LeaderFemaleCertain LeaderRaceCorrect LeaderRaceCertain, after(surveyLeaderRaceCertainty)

* DG behavior
gen DGGivePerc=DGGive/DGEndowment*100
label var DGGivePerc "% endowment transferred in DG"
order DGGivePerc, after(DGGive)

* Catergorize DG behavior
gen DGGiveCat=.
replace DGGiveCat=0 if DGGive==0
label define DGGiveCatlbl 0 "0", replace
foreach x of numlist 0 50 100 150 200 250 300 {
replace DGGiveCat=`x'/50+1 if DGGive>`x' & DGGive<=`x'+50
local x1=`x'/50+1
local x2=`x'+1
local x3=`x'+50
label define DGGiveCatlbl `x1' "`x2' to `x3'", add
}
label values DGGiveCat DGGiveCatlbl
label variable DGGiveCat "DG: Amount transferred to matched partner (category)"
order DGGiveCat, after(DGGive)

* Risk data
gen RGNumRiskyChoice = RGInputRisky1 + RGInputRisky2 + RGInputRisky3 + RGInputRisky4 + RGInputRisky5 + RGInputRisky6 + RGInputRisky7 + RGInputRisky8 + RGInputRisky9
label var RGNumRiskyChoice "# risky choices in RG"

order RGNumRiskyChoice, after(RGInputRisky9)

* Inconsistent and non-updates
foreach x of numlist 1/5 {

gen LTBeliefIncSuccess`x'=.
gen LTBeliefIncFailure`x'=.
gen LTBeliefNonSuccess`x'=.
gen LTBeliefNonFailure`x'=.

replace LTBeliefIncSuccess`x' = 1 if LTRoleMember==1 & LTBeliefSuccess`x' <  LTBeliefPrior`x'
replace LTBeliefIncSuccess`x' = 0 if LTRoleMember==1 & LTBeliefSuccess`x' >= LTBeliefPrior`x'
replace LTBeliefIncFailure`x' = 1 if LTRoleMember==1 & LTBeliefFailure`x' >  LTBeliefPrior`x'
replace LTBeliefIncFailure`x' = 0 if LTRoleMember==1 & LTBeliefFailure`x' <= LTBeliefPrior`x'

replace LTBeliefNonSuccess`x' = 1 if LTRoleMember==1 & LTBeliefSuccess`x' == LTBeliefPrior`x'
replace LTBeliefNonSuccess`x' = 0 if LTRoleMember==1 & LTBeliefSuccess`x' != LTBeliefPrior`x'
replace LTBeliefNonFailure`x' = 1 if LTRoleMember==1 & LTBeliefFailure`x' == LTBeliefPrior`x'
replace LTBeliefNonFailure`x' = 0 if LTRoleMember==1 & LTBeliefFailure`x' != LTBeliefPrior`x'

}

gen LTBeliefIncTotal = ///
	LTBeliefIncSuccess1+LTBeliefIncSuccess2+LTBeliefIncSuccess3+LTBeliefIncSuccess4+LTBeliefIncSuccess5 ///
	+ ///
	LTBeliefIncFailure1+LTBeliefIncFailure2+LTBeliefIncFailure3+LTBeliefIncFailure4+LTBeliefIncFailure5
gen LTBeliefNonTotal = ///
	LTBeliefNonSuccess1+LTBeliefNonSuccess2+LTBeliefNonSuccess3+LTBeliefNonSuccess4+LTBeliefNonSuccess5 ///
	+ ///
	LTBeliefNonFailure1+LTBeliefNonFailure2+LTBeliefNonFailure3+LTBeliefNonFailure4+LTBeliefNonFailure5

order LTBeliefIncSuccess* LTBeliefIncFailure* LTBeliefNonSuccess* LTBeliefNonFailure* LTBeliefIncTotal LTBeliefNonTotal, after(LTBeliefFailure5)

/*
Inconsistent updater: > 25% wrong direction (at least 3 of 10)
Non-updater: all are non-updates (10 of 10)
*/

gen LTInconsistent = 1 		if LTRoleMember==1 & LTBeliefIncTotal >= 3
replace LTInconsistent = 0 	if LTRoleMember==1 & LTBeliefIncTotal <  3

gen LTNonupdater = 1 		if LTRoleMember==1 & LTBeliefNonTotal == 10
replace LTNonupdater = 0 	if LTRoleMember==1 & LTBeliefNonTotal <  10

gen LTInconNonupdater = LTInconsistent | LTNonupdater
replace LTInconNonupdater =. if LTRoleLeader

label var LTInconsistent "Inconsistent updater"
label var LTNonupdater "Non-updater"
label var LTInconNonupdater "Inconsistent or non-updater"

order LTInconsistent LTNonupdater LTInconNonupdater, after(LTBeliefNonTotal)

* Comprehension question performance
foreach x of numlist 1/11 {
	gen ctrl1stattempt`x'= CtrlCounterQ`x'==0
	label var ctrl1stattempt`x' "Answer comprehension Q`x' correctly on first attempt"
}

egen ctrl1stattempttotal=rowmean(ctrl1stattempt*)
label var ctrl1stattempttotal "% comprehension questions answered correctly on first attempt"

* Average time spent on each decision screens across rounds
foreach x in LTTimeEffort LTTimeBeliefPrior LTTimeBeliefPosterior LTTimeReward {
	egen `x'_mean=rowmean(`x'1 `x'2 `x'3 `x'4 `x'5)
	label var `x'_mean "Average time spent on `x' screens"
}

save "Data/beliefs_gender-merged.dta", replace

*******************************************************************************

// Create long version of data
use "Data/beliefs_gender-merged.dta", clear
save "Data/beliefs_gender-merged-long.dta", replace
use "Data/beliefs_gender-merged-long.dta", clear

reshape long LTHighEff ///
	LTBeliefPrior LTBeliefSuccess LTBeliefFailure ///
	LTBeliefIncSuccess LTBeliefIncFailure LTBeliefNonSuccess LTBeliefNonFailure ///
	LTAdjSuccess LTAdjFailure LTAdjAmtSuccess LTAdjAmtFailure ///
	LTAdjBonusSuccess LTAdjPenaltySuccess LTAdjNoneSuccess ///
	LTAdjBonusFailure LTAdjPenaltyFailure LTAdjNoneFailure ///
	LTAdjCatSuccess LTAdjCatFailure ///
	LTAdjAbsSuccess LTAdjAbsFailure ///
	LTUncondBonusSuccess LTUncondBonusFailure ///
	LTUncondPenaltySuccess LTUncondPenaltyFailure ///
	LTCondBonusSuccess LTCondBonusFailure ///
	LTCondPenaltySuccess LTCondPenaltyFailure ///
	LTBeliefInvest LTHighEffHyp LTBeliefRewardSuccess LTBeliefRewardFailure ///
	LTTimeEffort LTTimeBeliefPrior LTTimeBeliefPosterior LTTimeReward ///
	LTTimeBeliefInvest LTTimeEffortHyp LTTimeBeliefReward  ///
	LTInvestSuccess LTLeaderHighEff LTBeliefPost ///
	LTBeliefScoreInt LTBeliefScorePost LTBeliefPayoffInt LTBeliefPayoffPost ///
	LTBeliefPaidQns LTBeliefPaidInt LTBeliefPaidPost ///
	LTBSRSuccessInt LTBSRSuccessPost ///
	LTMemPaidBelief LTPayoffInvest LTPayoffBelief PayoffLT ///
	RollInvest RollBeliefQns RollBeliefPayment RollMemPaidBelief RollMemReward ///
	LTLeaderReward LTMemReward LTMemPaidReward ///
	LTCostHigh LTCostLow LTReturnSuccess LTReturnFailure, ///
	i(ID) j(Round)

* Variable to identify each set of parameters
gen Parameter=.
replace Parameter=1	if	LTReturnSuccess == 150	& LTReturnFailure == 0
replace Parameter=2	if	LTReturnSuccess == 200	& LTReturnFailure == 0
replace Parameter=3	if	LTReturnSuccess == 250	& LTReturnFailure == 0
replace Parameter=4	if	LTReturnSuccess == 250	& LTReturnFailure == 50
replace Parameter=5	if	LTReturnSuccess == 300	& LTReturnFailure == 50

gen ParameterZero=.
replace ParameterZero=1 if LTReturnFailure == 0
replace ParameterZero=0 if LTReturnFailure != 0

gen ParameterReturnDiff=.
replace ParameterReturnDiff=LTReturnSuccess-LTReturnFailure
order Parameter ParameterZero ParameterReturnDiff, after(Round)
	
* Calculate Bayesian posteriors
gen LTBeliefTheorySuccess=.
gen LTBeliefTheoryFailure=.

local p=0.75
local q=1-`p'

replace LTBeliefTheorySuccess = ((`p'*LTBeliefPrior/100)/(`p'*LTBeliefPrior/100+`q'*(1-LTBeliefPrior/100)))*100 if LTRoleLeader==0
replace LTBeliefTheoryFailure = ((`q'*LTBeliefPrior/100)/(`q'*LTBeliefPrior/100+`p'*(1-LTBeliefPrior/100)))*100 if LTRoleLeader==0

gen LTBeliefDevSuccess = (LTBeliefSuccess-LTBeliefTheorySuccess)
gen LTBeliefDevFailure = (LTBeliefTheoryFailure-LTBeliefFailure)
gen LTBeliefPostiveAsymm = LTBeliefDevSuccess - LTBeliefDevFailure
	
* Create logit of beliefs
local p=0.75
local q=1-`p'

foreach Name in "Prior" "Success" "Failure" {
	gen Logit`Name'=log((LTBelief`Name'/100)/(1-(LTBelief`Name'/100)))
	replace Logit`Name'=log(0.0001/(1-0.0001)) if LTBelief`Name'==0
	replace Logit`Name'=log(0.9999/(1-0.9999)) if LTBelief`Name'==100
	}
	
label var LogitPrior "Logit of prior belief"
label var LogitSuccess "Logit of posterior belief (high)"
label var LogitFail "Logit of posterior belief (low)"

gen LogitStateGood=log(`p'/(1-`p'))
gen LogitStateBad=log(`q'/(1-`q'))
label var LogitStateGood "Logit of probability of good state"
label var LogitStateBad "Logit of probability of bad state"

order Logit*, after(LTBeliefFailure)

* Categorize posterior beliefs into intervals of 10
foreach x in Success Failure {

gen LTBelief`x'Cat=.
replace LTBelief`x'Cat=1  if LTRoleMember==1 & LTBelief`x'>=0  & LTBelief`x'<=10
replace LTBelief`x'Cat=2  if LTRoleMember==1 & LTBelief`x'> 10 & LTBelief`x'<=20
replace LTBelief`x'Cat=3  if LTRoleMember==1 & LTBelief`x'> 20 & LTBelief`x'<=30
replace LTBelief`x'Cat=4  if LTRoleMember==1 & LTBelief`x'> 30 & LTBelief`x'<=40
replace LTBelief`x'Cat=5  if LTRoleMember==1 & LTBelief`x'> 40 & LTBelief`x'<=50
replace LTBelief`x'Cat=6  if LTRoleMember==1 & LTBelief`x'> 50 & LTBelief`x'<=60
replace LTBelief`x'Cat=7  if LTRoleMember==1 & LTBelief`x'> 60 & LTBelief`x'<=70
replace LTBelief`x'Cat=8  if LTRoleMember==1 & LTBelief`x'> 70 & LTBelief`x'<=80
replace LTBelief`x'Cat=9  if LTRoleMember==1 & LTBelief`x'> 80 & LTBelief`x'<=90
replace LTBelief`x'Cat=10 if LTRoleMember==1 & LTBelief`x'> 90 & LTBelief`x'<=100
order LTBelief`x'Cat, after(LTBelief`x')

label define LTBeliefCatlbl 1 "0-10", replace
label define LTBeliefCatlbl 2 "11-20", add
label define LTBeliefCatlbl 3 "21-30", add
label define LTBeliefCatlbl 4 "31-40", add
label define LTBeliefCatlbl 5 "41-50", add
label define LTBeliefCatlbl 6 "51-60", add
label define LTBeliefCatlbl 7 "61-70", add
label define LTBeliefCatlbl 8 "71-80", add
label define LTBeliefCatlbl 9 "81-90", add
label define LTBeliefCatlbl 10 "91-100", add
label values LTBelief`x'Cat LTBeliefCatlbl

}

save "Data/beliefs_gender-merged-long.dta", replace

*******************************************************************************

// Create state-dependent version of data
use "Data/beliefs_gender-merged-long.dta", clear
save "Data/beliefs_gender-merged-state.dta", replace
use "Data/beliefs_gender-merged-state.dta", clear

foreach x in BeliefInc BeliefNon Return BeliefReward BeliefTheory BeliefDev ///
	Adj AdjAmt AdjBonus AdjPenalty AdjNone AdjCat AdjAbs ///
	UncondBonus UncondPenalty CondBonus CondPenalty {
rename LT`x'Success LT`x'1
rename LT`x'Failure LT`x'2
}

rename LTBeliefSuccess LTBeliefPosterior1
rename LTBeliefFailure LTBeliefPosterior2
rename LTBeliefSuccessCat LTBeliefPosteriorCat1
rename LTBeliefFailureCat LTBeliefPosteriorCat2
rename LogitSuccess LogitPosterior1
rename LogitFailure LogitPosterior2

reshape long LTBeliefPosterior LTBeliefPosteriorCat ///
	LogitPosterior ///
	LTBeliefInc LTBeliefNon ///
	LTReturn LTBeliefReward ///
	LTBeliefTheory LTBeliefDev ///
	LTAdj LTAdjAmt LTAdjBonus LTAdjPenalty LTAdjNone LTAdjCat LTAdjAbs ///
	LTUncondBonus LTUncondPenalty LTCondBonus LTCondPenalty ///
	, ///
	i(ID Session Round) j(State)
label define Statelbl 1 "Success", replace
label define Statelbl 2 "Failure", add
label values State Statelbl
label var State "Param: =1 if good state; =2 if bad state"
	
gen StateSuccess=1 if State==1
replace StateSuccess=0 if State==2
label var StateSuccess "Param: =1 if conditional on success"

gen StateFailure=1-StateSuccess
label var StateFailure "Param: =1 if conditional on failure"

order State*, after(Session)

replace LogitStateGood=StateSuccess*LogitStateGood
replace LogitStateBad=StateFail*LogitStateBad

save "Data/beliefs_gender-merged-state.dta", replace

capture log close _all