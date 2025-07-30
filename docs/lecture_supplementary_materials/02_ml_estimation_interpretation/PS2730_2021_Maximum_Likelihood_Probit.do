PS2730
Maximum Likelihood Example and Summary Measures of Model Fit

/* use PS2730.maxlike.probit.xy.dta */

/* DEFAULT Log Likelihood when all Bs are 0 except for the intercept */
probit y
display 5/9                               //THIS IS THE UNCONDITIONAL PROBABILITY OF BEING 1 FOR ALL CASES -- I.E. 5 AT "1", 4 AT '0" = .55 P(Y=1)
display invnorm(5/9)                      //THIS IS THE Z-SCORE ASSOCIATED WITH P(Y=1) OF .55
gen pred0=.1397
gen predprb0=normal(pred0)                // THIS RETURNS .55 AS THE PREDICTED PROB FOR ALL CASES ASSOCIATED WITH THE INTERCEPT ONLY MODEL
gen lnlikep0=ln(predprb0) if y==1         // TAKE THE LN OF .55 IF THE CASE IS A "1"
replace lnlikep0=ln(1-predprb0) if y==0   // TAKE THE LN OF (1-.55) IF THE CASE IS A "0"
tabstat lnlikep0, stat(sum)               // SUM THE LOG-LIKELIHOODS TO GET -6.18

/* Now try different values of B for X */

gen pred1=-.3+1*x
gen predprb1=normal(pred1)
gen lnlikep1=ln(predprb1) if y==1
replace lnlikep1=ln(1-predprb1) if y==0

tabstat lnlikep0 lnlikep1, stat(sum)

gen pred2=-.3+2*x
gen predprb2=normal(pred2)
gen lnlikep2=ln(predprb2) if y==1
replace lnlikep2=ln(1-predprb2) if y==0
tabstat lnlikep0 lnlikep1 lnlikep2, stat(sum)

gen pred3=-.3+3*x
gen predprb3=normal(pred3)
gen lnlikep3=ln(predprb3) if y==1
replace lnlikep3=ln(1-predprb3) if y==0

tabstat lnlikep3, stat(sum)

gen pred4=-.3+3.5*x
gen predprb4=normal(pred4)
gen lnlikep4=ln(predprb4) if y==1
replace lnlikep4=ln(1-predprb4) if y==0
tabstat lnlikep0 lnlikep1 lnlikep2 lnlikep3 lnlikep4, stat(sum)

gen pred5=-.3+4*x
gen predprb5=normal(pred5)
gen lnlikep5=ln(predprb5) if y==1
replace lnlikep5=ln(1-predprb5) if y==0
tabstat lnlikep0 lnlikep1 lnlikep2 lnlikep3 lnlikep4 lnlikep5 ,stat(sum)

gen pred6=-.3+5*x
gen predprb6=normal(pred6)
gen lnlikep6=ln(predprb6) if y==1
replace lnlikep6=ln(1-predprb6) if y==0
tabstat lnlikep0 lnlikep1 lnlikep2 lnlikep3 lnlikep4 lnlikep5 lnlikep6 ,stat(sum)

/* Now get real estimates */
probit y
est store M1

probit y x

est store M2

lrtest M2 M1  // The LR Test for comparing the null model to the "full" model

test x        // The Wald test of the constraint that B(x)=0

display 3.483^2/2.0295^2  // manual calculation of Wald test
display 2.95^.5           // shows z test as the square root of the Wald test

/* Long and Freese module for summary statistics */

fitstat

***Manual Calculation of McKelvey-Zavoina R-squared

summarize x // to get SD of X for variance calculations = .185

//So 3.48^2*.185=2.24
//McKelvey-Zavoina R-squared= 2.24/3.24
//McKelvey-Zavoina R-squared=.69
***


/*Regular Stata's module for correct classifications */

lstat

// Manual calculation of Tjur's D, the "coefficient of Discrimination" (Tjur's D)
predict predproby
ttest predproby, by(y)
// FOR THE 5 CASES ON '1', THE MEAN PREDICTED PROBABILITY IS .782
// FOR THE 4 CASES ON '0', THE MEAN PREDICTED PROBABILITY IS .286  
// TJUR'S D IS THEREFORE .50

