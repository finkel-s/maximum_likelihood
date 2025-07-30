*PS2730-2021
*LOGIT, PROBIT, GLM MODELS

*use south africa data"
*use "ps2730.safrica.dta"


* LINEAR PROBABILITY MODEL
scatter locdich educ1, jitter(20) || lfit locdich educ1
regress locdich educ1
predict lpmpred
summarize lpmpred if educ1==1
summarize lpmpred if educ1==3
summarize lpmpred if educ1==5
margins , at(educ1=(1(2)7))
tabstat lpmpred locdich, stats (mean) by (educ1)

predict lpmres,residuals

* SHOW NON-NORMALITY AND HETEROSKEDASTICITY
rvfplot,yline(0) jitter(20)
hist lpmres

* SHOW OUT-OF-BOUNDS PREDICTIONS
regress locdich educ1 groups know
predict lpmpred2
list lpmpred2 if lpmpred2<=0 | lpmpred2>=1

**GOLDBERGER LPM MODEL WITH WEIGHTED LEAST SQUARES***
generate lpmpred3=lpmpred2
replace lpmpred3=.995 if lpmpred2>1
generate wt=1/(lpmpred3*(1-lpmpred3))
tab wt
regress locdich educ1 groups know  [weight=wt]
generate lpmpred4=_cons+_b[educ1]*educ1+_b[groups]*groups+_b[know]*know //PREDICTED "LOCAL" IN THE ORIGINAL UNITS, NOT WEIGHTED
correlate lpmpred4 locdich
display .4429^2 //THIS IS THE R-SQUARED IN THE ORIGINAL UNITS OF LOCAL, NOT THE "WEIGHTED" UNITS AS IN THE WLS MODEL


**LOGIT
logit locdich groups
predict plogit // PREDICTED PROBABILITIES
predict logodds,xb // PREDICTED LOGITS (INDEX FUNCTION XB)
gen odds1=exp(logodds)

display exp(_b[_cons]+_b[groups]*0)/(1+exp(_b[_cons]+_b[groups]*0))  //SIMULATES PROBABILITY OF 1 FOR PERSON AT GROUPS=0
display exp(_b[_cons]+_b[groups]*4)/(1+exp(_b[_cons]+_b[groups]*4))  //SIMULATES PROBABILITY OF 1 FOR PERSON AT GROUPS=4


tabstat plogit odds1 logodds,by(groups) //GIVES PREDICTED PROBABILITY, ODDS AND PREDICTED LOGIT FOR ALL LEVELS OF X
logit locdich groups
margins, at(groups=(0(1)5))     //THIS IS THE STATA MARGINS VERSION OF THIS SAME CALCULATION
marginsplot                     //PLOTS THIS WITH STATA MARGINSPLOT

sort groups
twoway (connected plogit groups)  //GRAPH NON-LINEAR PROBABILITIES WITH ALTERNATIVE COMMANDS



*WHAT IF INTERCEPT CHANGED FROM -.96 TO -2?  
generate plogit1=exp(-2+_b[groups]*groups)/(1+exp(-2+_b[groups]*groups))
tabstat plogit plogit1,by(groups)

twoway (connected plogit groups)(connected plogit1 groups) //IT WILL TAKE *MANY* GROUP MEMBERSHIPS TO GENERATE HIGH Ps

*WHAT IF INTERCEPT CHANGED FROM -.96 TO 2??  
generate plogit2=exp(2.0+_b[groups]*groups)/(1+exp(2.0+_b[groups]*groups))
tabstat plogit plogit1 plogit2,by(groups)
twoway (connected plogit groups)(connected plogit1 groups) (connected plogit2 groups)

*WHAT IF SLOPE CHANGED FROM .54 to .10?
generate plogit3= exp(_b[_cons]+.1*groups)/(1+exp(_b[_cons]+.1*groups))
tabstat plogit plogit3 ,by(groups)  //MUCH SLOWER CHANGE IN THE PS

*WHAT IF SLOPE CHANGED FROM .54 to 1?
generate plogit4=exp(_b[_cons]+1*groups)/(1+exp(_b[_cons]+1*groups))
tabstat plogit plogit3 plogit4 ,by(groups)  //MUCH FASTER CHANGE IN THE PS

twoway (connected plogit groups)(connected plogit3 groups) (connected plogit4 groups)


**PROBIT

probit locdich groups 
predict pprobit  /*Predicted Probabilities */
predict zscore,xb /* Predicted Z-scores (Index Function XB) */

margins, at(groups=(0(1)5))   
marginsplot                    //GRAPH OF NON-LINEAR PROBABILITIES

display normal(_b[_cons]+_b[groups]*0)   //SIMULATES PROBABILITY OF 1 FOR PERSON AT GROUPS=0
display normal(_b[_cons]+_b[groups]*4)   //SIMULATES PROBABILITY OF 1 FOR PERSON AT GROUPS=4


display invnorm(.28)  //GIVES THE Z-SCORE FOR A PERSON WITH A PROBABILITY OF .28, I.E. GOES FROM P TO Z
//NOTE THAT THE RESULT HERE, -.58, IS THE SAME AS THE INTERCEPT TERM IN THE PROBIT REGRESSION, I., WHEN X=0, THE PREDICTED Z SCORE

display invnorm(.5)   //GIVES THE Z-SCORE FOR A PERSON WITH A PROBABILITY OF .5, I.E. GOES FROM P TO Z
tabstat pprobit zscore, by(groups) //GIVES PREDICTED PROBABILITY AND PREDICTED Z-SCORE FOR ALL LEVELS OF X
tabstat pprobit plogit, by(groups) //COMPARES PREDICTED PROBABILITIES FOR PROBIT AND LOGIT MODEL


**GENERALIZED LINEAR MODELS
glm locdich groups, f(gaussian) link (identity)
glm locdich groups, f(binomial) link(logit)
glm locdich groups ,f(binomial) link(probit)
