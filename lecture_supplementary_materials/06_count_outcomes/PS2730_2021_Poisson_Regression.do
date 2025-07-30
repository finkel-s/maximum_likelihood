
PS2730 - Fall 2021
Poisson Regression

**FIRST INSTALL THE PRCOUNTS ROUTINE

net search prcounts
*click on st002.pkg to install


********TO GENERATE THE PLOTS IN THE POWERPOINT OF THE POISSON PROBABILITY DISTRIBUTION FROM DIFFERENT RATES ********************

clear
set obs 25
gen ya = .8
poisson ya, nolog
prcounts pya, plot max(20)
gen yb = 1.5
poisson yb, nolog
prcounts pyb, plot max(20)
gen yc = 2.9
poisson yc, nolog
prcounts pyc, plot max(20)
gen yd = 10.5
poisson yd, nolog
prcounts pyd, plot max(20)
label var pyapreq "mu=0.8"
label var pybpreq "mu=1.5"
label var pycpreq "mu=2.9"
label var pydpreq "mu=10.5"
label var pyaval "y=# of Events"
graph twoway connected pyapreq pybpreq pycpreq pydpreq pyaval, ///
ytitle("Probability") ylabel(0(.1).5) xlabel(0(2)20)

************************************************************************************************************************************
* USE SOUTH AFRICA DATA 
tab polpart
// TRY OLS REGRESSION ON COUNT DATA
regress polpart groups
predict grpprd
sort groups
twoway (scatter polpart groups, jitter (5)) (connected grpprd groups)

// SEE NUMEROUS POTENTIAL PROBLEMS

regress polpart educ1 civiced groups interest
predict olsprd  // THIS GENERATES PREDICTED LEVEL OF POLPART
predict olsres,resid // THIS GENERATES THE OLS RESIDUAL

// PROBLEM #1:  NEGATIVE PREDICTIONS
list olsprd if olsprd < 0
summarize olsprd if olsprd<0

// PROBLEM #2:  SKEWED (NON-NORMAL) RESIDUALS

histogram olsres if groups==0
histogram olsres if groups==1
histogram olsres if groups==5

// PROBLEM #3:  HETEROSKEDASTIC VARIANCES -- INCREASES AS X INCREASES
rvfplot,yline(0) jitter(20)
summarize olsres if groups==1
summarize olsres if groups==3
summarize olsres if groups==5


// UNIVARIATE POISSON FOR POLITICAL PARTICIPATION VARIABLE

poisson polpart

// IMPLIES A CONSTANT MU, OR RATE OF PARTICIPATION OF e^(.8301)
display exp(.8301) // = 2.29, OR THE AVERAGE OF POLPART!!
//OR:
display exp(_b[_cons])
// IMPLIES A PREDICTED PROBABILITY FOR A COUNT OF "0" OF (e^(-2.29)*2.29^0)/0!
display exp(-exp(_b[_cons]))

// IMPLIES A PREDICTED PROBABILITY FOR A COUNT OF "1" OF (e^(-2.29)*2.29^1)/1!
display exp(-exp(_b[_cons]))*exp(_b[_cons])^1

// IMPLIES A PREDICTED PROBABILITY FOR A COUNT OF "3" OF (e^(-2.29)*2.29^3)/3!
display (exp(-exp(_b[_cons]))*exp(_b[_cons])^3)/(3*2*1)


// ALL OF THESE PREDICTED COUNTS ARE GENERATED IN FORM READY TO GRAPH WITH LONG-FREESE "PRCOUNTS" ROUTINE
prcounts nox, plot 

// PRCOUNTS GENERATES A SERIES OF VARIABLES WITH "NOX" AS THE PREFIX:  OBSERVED, PREDICTED PROBS, ETC

summarize noxrate noxpr0 noxpr1 noxpr2 noxpr3

list noxrate noxpr0 noxpr1 noxpr2 noxpr3 groups in 1/20

label var noxobeq "Observed Proportion"
label var noxpreq "Univariate Poisson Prediction"
label var noxval "# of Behaviors"

twoway (connected noxobeq noxval) (connected noxpreq noxval), ///
ytitle(Probabilities) xtitle(Number of Behaviors) title(Comparison of Observed Counts and Predicted Poisson Counts)

summarize polpart

// POISSON REGRESSION WITH SINGLE INDEPNDENT VARIABLE
poisson polpart groups

// OR GLM TO PUT POISSON WITHIN GENERALIZED LINEAR MODELS FRAMEWORK
glm polpart groups, family (poisson) link (log)

poisson polpart groups

listcoef // GIVES YOU THE CHANGES IN EXPECTED RATE FOR UNIT AND S.D. CHANGE IN X

listcoef, percent // OR IN TERMS OF PERCENTAGE CHANGE 
  

  //SHOW FACTOR CHANGE IN THE RATE FOR CHANGES IN GROUPS OF 1, 2, 3, ETC 

//EXPECTED RATE FOR GROUPS==0, 1, 2, 3

display exp(_b[_cons]+_b[groups]*0)
display exp(_b[_cons]+_b[groups]*1)
display exp(_b[_cons]+_b[groups]*2)
display exp(_b[_cons]+_b[groups]*3)
display exp(_b[_cons]+_b[groups]*4)

//SO CHANGING ONE UNIT ON GROUPS CHANGES THE EXPECTED RATE BY A FACTOR OF e^.358, or 1.43:
display exp(_b[_cons]+_b[groups]*1)/ exp(_b[_cons]+_b[groups]*0) // COMPARES GROUPS==1 TO GROUPS==0
display exp(_b[_cons]+_b[groups]*4)/ exp(_b[_cons]+_b[groups]*3) // COMPARES GROUPS==4 TO GROUPS==3

//CHANGING 3 UNITS ON GROUPS CHANGES THE EXPECTED RATE BY A FACTOR OF e^(.358*3), or 2.93
display exp(_b[_cons]+_b[groups]*4)/ exp(_b[_cons]+_b[groups]*1) // COMPARES GROUPS==4 TO GROUPS==1

//CHANGING BY A STANDARD DEVIATION OF X GIVES A CONSTANT FACTOR CHANGE IN THE RATE OF e^(.358*1.579), or 1.761

display exp(_b[_cons]+_b[groups]*1.579)/ exp(_b[_cons]+_b[groups]*0) // COMPARES GROUPS==1.579 TO GROUPS==0

//GRAPH PREDICTED COUNTS AND RATE WITH PRCOUNTS

prcounts xgrp,plot // GIVES YOU ALL THE PREDICTED VALUES AS BEFORE

tabstat xgrprate, stat(mean) by (groups)

// GRAPH THE NON-LINEAR MODEL OF EXPECTED RATE
twoway (scatter polpart groups, jitter(5))(connected xgrprate groups)

predict poisprd // PREDICT IN STATA GIVES YOU THE PREDICTED MU, EXACTLY LIKE XGRPRATE IN PRCOUNTS
twoway (scatter polpart groups, jitter(5))(connected poisprd groups)

//COMPARE OLS AND POISSON MODELS GRAPHICALLY
twoway (scatter polpart groups, jitter(5))(connected poisprd groups)(connected grpprd groups) 

// INTERPRETATION OF COEFFICIENTS IN TERMS OF DISCRETE CHANGE IN EXPECTED COUNTS

// EXAMPLE:  PREDICTED EXPECTED COUNT FOR PERSON 1/2 UNIT BELOW THE MEAN, COMPARED TO PERSON 1/2 UNIT ABOVE THE MEAN

display exp(_b[_cons]+_b[groups]*(2.51-.5))
display exp(_b[_cons]+_b[groups]*(2.51+.5))  //	NOTE:  FACTOR CHANGE IS STILL 1.43!)

// EXAMPLE:  PREDICTED EXPECTED COUNT FOR PERSON 1/2 S.D. BELOW THE MEAN, COMPARED TO PERSON 1/2 S.D. ABOVE THE MEAN
display exp(_b[_cons]+_b[groups]*(2.51-(.5*1.58)))
display exp(_b[_cons]+_b[groups]*(2.51+(.5*1.58)))  //NOTE:  FACTOR CHANGE IS STILL 1.76!!


// GIVEN POISSON MODEL, GENERATE PREDICTED PROBABILITIES FOR SPECIFIC COUNTS AT SPECIFIC VALUES OF X
// EXAMPLE:  PREDICTED PROBABILITY OF A 2 COUNT IF GROUPS = 0,1,5

//START WITH EXPECTED RATES:
tabstat xgrprate, by(groups)

//SO EXPECTED PROBABILITY OF A 2 COUNT IF GROUPS=0, 1 ,5 :
display (exp(-.79)*.79^2)/2   /* ANSWER: .14 */
//OR:
display (exp(-exp(_b[_cons]+_b[groups]*0))*exp(_b[_cons]+_b[groups]*0)^2)/(2*1) //GROUPS==0

display (exp(-exp(_b[_cons]+_b[groups]*1))*exp(_b[_cons]+_b[groups]*1)^2)/(2*1) //GROUPS==1

display (exp(-exp(_b[_cons]+_b[groups]*5))*exp(_b[_cons]+_b[groups]*5)^2)/(2*1) //GROUPS==5

*****SUMMARIZE THE DISCRETE CHANGES IN MU FOR GIVEN CHANGE IN X
mchange 


// MULTIPLE INDEPENDENT VARIABLES
poisson polpart educ1 civiced groups interest
listcoef
mchange

fitstat

// GRAPH THIS MODEL
prcounts allx, plot
predict allpred,xb
sort allpred
twoway (scatter polpart allpred, jitter(3))(connected allxrate allpred)

//COMPARE AVERAGE PREDICTED PROBABILITIES FROM FULL POISSON TO UNIVARIATE POISSON TO OBSERVED DATA
label var allxpreq "Multivariate Poisson Prediction"
label var allxobeq "Observed Proportion"
sort allxval
twoway (connected allxobeq allxval) (connected allxpreq allxval) (connected noxpreq noxval) , ///
ytitle(Probabilities) xtitle(Number of Behaviors) title(Comparison of Observed Counts and Predicted Poisson Counts)



//COMPARING PREDICTED PROBABILITIES TO SEE DIFFERENCES BETWEEN CATEGORIES OF INDEPENDENT VARIABLES

//EXAMPLE:  EFFECT OF CIVICED USing PREDICTED COUNTS

tabstat allx*, by(civiced)

prcounts ceallx if civiced==0, plot
prcounts ceceallx if civiced==1,plot
label var ceallxval "Number of Behaviors"
label var ceallxpreq "Pred Counts, No Civic Education"
label var ceceallxpreq "Pred Counts, Civic Education"
twoway (connected ceallxpreq ceallxval)(connected ceceallxpreq ceallxval), ///
ytitle(Probabilities) xtitle(Number of Behaviors) title(Comparison of Predicted Counts CE and NO CE)


