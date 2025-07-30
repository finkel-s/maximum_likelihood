PS2730
Censored Regression(Tobit) Model

*Use South African Data
/* CREATE NEW TOLERANCE VARIABLE THAT RUNS FROM -2 TO 2 */
generate newtol=tol2-2.2
/* CREATE A CENSORED TOLERANCE VARIABLE WITH ALL NEGATIVE VALUES CENSORED TO 0 */
generate centol=newtol
replace centol=0 if centol <=0
/* SHOW DIFFERENCES IN DISTRIBUTIONS OF UNCENSORED AND CENSORED VARIABLE */
tab1 newtol centol
summarize newtol centol

/* SHOW REAL REGRESSION, BEFORE CENSORING INTRODUCES BIASES */
regress newtol know 
listcoef,std
predict olspred, xb

/* GRAPH REAL RELATIONSHIP */
graph twoway (scatter newtol know)(scatter olspred know), ylabel(-2 (1) 2) xlabel(0 (1) 8)

//*OLS ON CENSORED VARIABLE
regress centol know
listcoef,std

/*GRAPH REAL RELATIONSHIP AND BIASED RELATIONSHIP WITH CENSORED VARIABLE */
graph twoway (scatter newtol know)(scatter centol know) (lfit newtol know)(lfit centol know), ylabel(-2 (1) 2) xlabel(0 (1) 8)

/*TOBIT MODEL*/
tobit centol know,ll
listcoef
predict tobpred
graph twoway (scatter newtol know)(scatter centol know) (lfit newtol know)(lfit centol know)(connected tobpred know), ylabel(-2 (1) 2) xlabel(0 (1) 8)

***INTERPRETATION OF COEFFICIENTS
tobit centol know polpart, ll
listcoef

*1. margins on being over the threshold (uncensored)
margins, at(polpart=(0(1)7)) predict(pr(0,.))
margins, at(know=(0(1)8)) predict(pr(0,.)) 

margins, at(polpart=(0(1)7)) predict(pr(0,.)) atmeans
margins, at(know=(0(1)8)) predict(pr(0,.)) atmeans

margins, dydx(know polpart) predict(pr(0,.)) atmeans

*2. margins on tolerance, given being over the threshold
margins, at(polpart=(0(1)7)) predict(e(0,.)) 
margins, at(know=(0(1)8)) predict(e(0,.)) 

margins, at(polpart=(0(1)7)) predict(e(0,.)) atmeans
margins, at(know=(0(1)8)) predict(e(0,.)) atmeans

margins, dydx(know polpart) predict(e(0,.)) atmeans 

*3. margins on actual Y, including censored and non-censored values of Y*

margins, dydx(know polpart) predict(ystar(0,.)) atmeans

**This quantity equals the tobit regression coefficient multiplied by the probability of being uncensored!! (see Powerpoint)
**Overall probability of being uncensored is (1-361/940)=.62 so that gives a rough approximation of the quantity to multiply by

**KNOW = .030*.62=.019
**POLPART=.024*.62=.015




/*McDonald Moffit Decomposition OF TOTAL MARGINAL EFFECT */

tobmargins, dydx(know polpart) predict(ystar(0,.)) atmeans
//  THIS IS THE MARGINAL EFFECT OF THE INDEPENDENT VARIABLES ON ACTUAL Y, INCLUDING CENSORED AND NON-CENSORED VALUES OF Y*
it centol know polpart, ll

//  CALL THIS QUANTITY (MM)
margins, dydx(know polpart) predict(pr(0,.)) atmeans
//  THIS IS THE MARGINAL EFFECT OF THE INDEPENDENT VARIABLES ON THE PROBABILITY OF BEING OVER THE CENSORING THRESHOLD
//  CALL THIS QUANTITY (1)
margins, atmeans predict(pr(0,.))
//	THIS IS THE PREDICTING PROBABILITY OF BEING OVER THE THRESHOLD AT THE MEAN OF THE INDEPENDENT VARIABLES
 //  CALL THIS QUANTITY (2)
margins, dydx(know polpart) predict(e(0,.)) atmeans 
//  THIS IS THE MARGINAL EFFECT OF THE INDEPENDENT VARIABLES ON THE EXPECTED VALUE OF Y FOR UNITS OVER THE THRESHOLD
//  CALL THIS QUANTITY (3)
margins, atmeans predict(e(0,.))
//  THIS IS THE EXPECTED VALUE OF Y FOR UNITS OVER THE THRESHOLD
//  CALL THIS QUANTITY (4)

*McDonald- Moffit is:

*MM=1*4 + 3*2
*MARGINAL EFFECT OF X ON P(Y>0), MULTIPLIED BY EXPECTED VALUE OF Y IF GREATER THAN 0  (WHEN XS ARE AT THEIR MEANS),
*PLUS MARGINAL EFFECT OF X ON CHANGE IN EXPECTED Y IF OVER THE THRESHOLD, MULTIPLIED BY PROBABILITY OF BEING OVER THE THRESHOLD (WHEN XS ARE AT THEIR MEANS)

*KNOW=.         .0189 TOTAL MARGINAL EFFECT ON Y
*PARTICIPATION  .0149 TOTAL MARGINAL EFFECT ON Y

*DECOMPOSITION
*KNOW:          .0168*.635+
*               .0132*.623=.0107+ .0082= .0189
*PARTICIPATION: .0132*.635+
*               .0105*.623=.0084+ .0065=.0149

**IN BOTH CASES THE FIRST PROCESS, CHANGING THE PROBABITY OF NOT BEING CENSORED TIMES THE EXPECTED VALUE OF Y IF Y>0
**MAKES UP MORE OF THE OVERALL MARGINAL EFFECT THAN CHANGING THE EXPECTED VALUE OF Y IF Y> 0 TIMES THE PROBABILTY OF NOT BEING CENSORED

