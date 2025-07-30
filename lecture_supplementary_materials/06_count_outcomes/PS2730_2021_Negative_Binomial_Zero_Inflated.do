PS2730-2021

* NEGATIVE BINOMIAL MODEL
//South Africa Data

poisson polpart
prcounts nox,plot
// COMPARE WITH POISSON MULTIVARIATE
poisson polpart educ1 civiced groups interest
prcounts allx,plot
listcoef
mchange

nbreg polpart educ1 civiced groups interest

// FACTOR CHANGE IN EXPECTED RATE WITH LISTCOEF
listcoef	

//PREDICTED COUNTS DIFFERENT CHANGES IN X WHEN ALL VARIABLES ARE AT THEIR MEANS
mchange
mchange, atmeans

// PREDICTED COUNTS AND OTHER VARIABLES WITH PRCOUNTS, PLOT
prcounts nbrg,plot

// IS THIS BETTER AT GENERATING AVERAGE PREDICTED PROBABILITIES THAN POISSON?
label var nbrgpreq "Negative Binominal"

// LOOK AT AVERAGE PREDICTED PROBABILITIES
summarize nbrgpr0-nbrgpr9
summarize allxpr0-allxpr9 // THESE ARE THE POISSON COUNTERPARTS

twoway (connected allxobeq allxval) (connected allxpreq allxval) (connected noxpreq noxval) (connected nbrgpreq nbrgval), ///
ytitle(Probabilities) xtitle(Number of Behaviors) title(Comparison of Observed Counts and Predicted Counts)


*ZERO-INFLATED POISSON
//ASSUME:  POOR, BLACK, WOMEN FACE STRUCTURAL BARRIERS TO PARTICIPATION SO THEY MAY CONSTITUTE AN "ALWAYS-ZERO" GROUP
zip polpart educ1 civiced groups interest income1 black male, inflate (income1 black male)
listcoef // for interpretation of the effects in odds, both for structural zero probability and counts for non-structural zeros
fitstat
mchange
// Note difference in expected count from Poisson to ZIP

prcounts zipx,plot
label var zipxpreq "Zero-Inflated Poisson"

*see how rates differ for different IVs.  
mgen , at(income1=(1/4)) pr(0) stub(zipp) replace          // This is the prediction of any zeros
mgen , at (income1=(1/4)) predict (pr) stub(zipp) replace  // This is the prediction of "always" zeros

tabstat zipxrate, by(income1)


gen zippcount0=zippprany0-zippprall0  // probability of poisson 0 by IVS
 

graph twoway connected zippprall0  zippprany0  zippcount0 zippincome1


***ZERO-INFLATED NEGATIVE BINOMIAL
zinb polpart educ1 civiced groups interest income1 black male, inflate (income1 black male)
listcoef
fitstat

prcounts zinbx,plot
label var zinbxpreq "Zero-Inflated Negative Binominal"

*GRAPH ALL COUNT MODEL PREDICTIONS 

twoway (connected allxobeq allxval) (connected allxpreq allxval) (connected nbrgpreq nbrgval) (connected zinbxpreq zinbxval) ///
(connected zipxpreq zipxval),ytitle(Probabilities) xtitle(Number of Behaviors) title(Comparison of Observed Counts and Predicted Counts)


*OR WITH DEVIATION GRAPHS

//TAKE ALLXOBEQ AS "OBSERVED," AND CREATE A DEVIATION OF OBSERVED MINUS PREDICTED FOR ALL MODELS

gen devpois=allxobeq-allxpreq
gen devnbr =allxobeq-nbrgpreq
gen devzip=allxobeq-zipxpreq
gen devzinb=allxobeq-zinbxpreq
label var devpois "Poisson"
label var devnbr "Negative Binomial"
label var devzip "Zero Inflated Poisson"
label var devzinb "Zero Inflated Negative Binomial"
twoway (connected devpois allxval) (connected devnbr allxval) (connected devzip nbrgval) (connected devzinb zinbxval) ///
,ytitle(Probabilities) xtitle(Number of Behaviors) title(Deviations of Predicted Counts from Observed Counts)


***LONG-FRESE COMMAND 'COUNTFIT' COMPARES POISSON, NEGATIVE BINOMIAL, ZIP, AND ZINB AND GRAPHS THE DEVIATIONS ALSO!

countfit polpart educ1 civiced groups interest income1 black male, inflate (income1 black male) forcevuong
