*PS2730-2021

*use south africa data

* FREQUENCY ON LOCAL PARTICIPATION
tab locpart
* CREATE TRICHOTOMIZED VARIABLE
generate loctri=locpart
recode loctri 0=1 1/2=2 *=3
* BIVARIATE ORDERED PROBIT
oprobit loctri groups
* PREDICTED Y*
predict opred1,xb
* PREDICTED PROBABILITIES OF BEING IN LOW, MEDIUM, HIGH CATEGORIES 
predict lowpar medpar highpar
tabstat opred1 lowpar medpar highpar, stat (mean) by(groups)
* CALCULATING THESE PROBABILITIES "MANUALLY" WITH DISPLAY
oprobit loctri groups
display normal(.607-.339) // GETS PROBABILITY OF LOW PARTICIPATION FOR GROUPS=1
//or:
display normal(_b[/cut1]-_b[groups]*1)
//or:
margins, at (groups=1) predict(outcome(1))

display normal(1.84-.339)-normal(.607-.339) // GETS PROBABILITY OF MEDIUM PARTICIPATION FOR GROUPS=1
//or:
display normal(_b[/cut2]-_b[groups]*1)-normal(_b[/cut1]-_b[groups]*1)
//or:
margins, at (groups=1) predict(outcome(2))

display 1-normal(1.84-.339) // GETS PROBABILITY OF HIGH PARTICIPATION FOR GROUPS=1
//or:
display 1-normal(_b[/cut2]-_b[groups]*1)
//or:
margins, at (groups=1) predict(outcome(3))

* GRAPHING THE PROBABILITIES OF BEING IN LOW AND HIGH CATEGORIES TO SHOW NON-LINEARITIES
sort groups
twoway connect lowpar groups
* What if someone belonged to 10 groups?
display normal(_b[/cut1]-_b[groups]*10)  // =.02 SHOWS CURVE GETTING FLATTER AND FLATTER AT LOW Ps

twoway connect highpar groups
* What if someone belonged to 10 groups?
display 1-normal(_b[/cut2]-_b[groups]*10) // = .79, showing that curve becomes flatter up there too

*GRAPH ALL THREE PROBABILITIES IN ONE GRAPH
twoway (connected lowpar groups)(connected medpar groups)(connected highpar groups)


// EXTEND TO MULTIPLE INDEPENDENT VARIABLES
oprobit loctri groups
fitstat, saving (md1)
oprobit loctri groups educ1 interest know i.male
//COMPARE FIT OF TWO MODELS:  CONSTRAINED OR REDUCED MODEL WITH B2-B6=0 COMPARED WITH CURRENT MODEL
fitstat ,using (md1)



***GENERATE CHANGES IN PREDICTED PROBABILITIES FOR CHANGES IN ALL INDEPENDENT VARIABLES
***WITH LONG-FRESE COMMAND "MCHANGE"
mchange, atmeans
mchange  // uses observed value method
mchange, centered
mchangeplot, sig(.05)  // plots changes in probability from (default) standard deviation change in all IVs
***can change the default to unit changes, marginal changes, or changes over the range of IVs***


* EFFECTS OF X ON Y* (USING PROBIT ONLY), WITH STANDARDIZED Y* AND FULLY STANDARDIZED RESULTS

listcoef


***Side Note: Calculating Count R-squared and Adjusted Count R-squared Manually

***This gives the count R-squared from fitstat!
oprobit loctri groups educ1 interest know i.male
fitstat
predict p1 p2 p3 
egen maxpred = rowmax(p1-p3)
gen vpred = .
forval i = 1/3 {
replace vpred = `i' if p`i' == maxpred
}
tab2 loctri vpred

**Count R-squared=cases on the diagonal divided by total N
dis (269+211+79)/940 //=.595

***Adjusted Count: take the number of mistakes you would make simply from the marginals,
***then the percentage reduction with number of mistakes you would make, knowing the predictions from model


dis (547-(123+21+117+79+7+34))/547 //=.303



* ORDERED LOGIT ANALYSIS
ologit loctri groups

* LET STATA CREATE ALL PREDICTED PROBABILITIES AND COMPARE TO PROBIT PROBABILITIES
predict lowparl medparl highparl

tabstat lowparl lowpar medparl medpar highparl highpar, stat (mean) by (groups)

* GENERATE CUMULATIVE PREDICTED LOGITS FOR GROUPS=3  
display 1.034+(-.579*3) // Cumulative logit for groups=3, category 1  
display [/cut1]-_b[groups]*3   // CAN DO THE SAME WITH THE NAMED _B COEFFICIENTS
display 3.13+(-.579*3) // Cumulative logit for groups=3, category 2  //
display [/cut2]-_b[groups]*3   // CAN DO THE SAME WITH THE NAMED _B COEFFICIENTS

* CUMULATIVE PROBABILITIES FOR GROUPS=3
display exp(-.70)/(1+exp(-.70))      //category 1
display exp(1.393)/(1+exp(1.393))    //caterogy 2

* GENERATE CUMULATIVE PREDICTED LOGITS FOR GROUPS=4

display 1.034+(-.579*4) // Cumulative logit for groups=4, category 1 
display 3.13+(-.579*4) // Cumulative logit for groups=4, category 2 

* CUMULATIVE PROBABILITIES FOR GROUPS=4
display exp(-1.282)/(1+exp(-1.282))
display exp(.814)/(1+exp(.814))

*so predicted probability for category 2 is cumulative prob for category 2 minus cumulative prob for category 1
* .693-.217 for Groups=4 = .476
* .801-.332 for Groups=3 = .469


*ODDS INTERPRETATION

ologit loctri groups
listcoef  //E^XB SAYS THAT ONE UNIT CHANGE IN X PRODUCES A 1.78 FACTOR CHANGE IN THE CUMULATIVE ODDS

*CUMULATIVE ODDS OF BEING AT OR BELOW A GIVEN CATEGORY FOR GROUPS=1
display .612/(1-.612)  //=1.58   FOR CATEGORY 1
display .93/(1-.93) //=13.29     FOR CATEGORY 2

*CUMULATIVE ODDS OF BEING AT OR BELOW A GIVEN CATEGORY FOR GROUPS=2
display .469/(1-.469)  //=.88    FOR CATEGORY 1
display .88/(1-.88) //=  7.33    FOR CATEGORY 2

*CUMULATIVE ODDS OF BEING AT OR BELOW A GIVEN CATEGORY FOR GROUPS=3
display .331/(1-.331)  //= .495  FOR CATEGORY 1
display .80/(1-.80)  //= 4.00    FOR CATEGORY 2

*CUMULATIVE ODDS FOR GROUPS=4
display .217/(1-.217)  //=.277  FOR CATEGORY 1
display .69/(1-.69) //=  2.26  FOR CATEGORY 2

*SO:  CHANGING FROM GROUPS=1 TO GROUPS=2 DECREASED THE CUMULATIVE ODDS OF BEING IN CATEGORY 1 (LOW) OR BELOW 
*      BY A FACTOR OF (approx) 1.78 (1.58/.88)
*        CHANGING FROM GROUPS=1 TO GROUPS=2 DECREASED THE CUMULATIVE ODDS OF BEING IN CATEGORY 2 (MEDIUM) OR BELOW
*      BY A FACTOR OF (approx) 1.78 (13.29/7.33)

***YOU COULD ALSO SAY (FOLLOWING THE LECTURE POWERPOINT) THAT CHANGING FROM GROUPS=1 TO GROUPS=2 *INCREASED* THE CUMULATIVE ODDS OF
***BEING IN CATEGORY 1 OR BELOW BY A FACTOR OF .56 (.88/1.58)
***AND CHANGING FROM GROUPS=1 TO GROUPS=2 *INCREASED* THE CUMULATIVE ODDS OF BEING IN CATEGORY 2 (MEDIUM) OR BELOW
***BY A FACTOR OF (approx) .56 (7.33/13.29)


* CHANGING FROM GROUPS=2 TO GROUPS=3 DECREASED THE CUMULATIVE ODDS OF BEING IN CATEGORY 1 OR BELOW BY FACTOR OF 1.78 (.88/.495)
* CHANGING FROM GROUPS=2 TO GROUPS=3 DECREASED THE CUMULATIVE ODDS OF BEING IN CATEGORY 2 OR BELOW BY FACTOR OF 1.78 (7.33/4.00)



*CUMULATIVE ODDS OF BEING ABOVE A GIVEN CATEGORY FOR GROUPS=1
display .39/.61  //=.639   FOR CATEGORY 1
display .075/.925 //= .081   FOR CATEGORY 2

*CUMULATIVE ODDS OF BEING ABOVE A GIVEN CATEGORY FOR GROUPS=2
display .53/.47    //  = 1.13 FOR CATEGORY 1
display .124/.876  //  = .142 FOR CATEGORY 2

**SO:  CHANGING FROM GROUPS=1 TO GROUPS=2 INCREASED THE CUMULATIVE ODDS OF BEING ABOVE CATEGORY 1 BY 1.13/.639 = 1.78
*******CHANGING FROM GROUPS=1 TO GROUPS=2 INCREASED THE CUMULATIVE ODDS OF BEING ABOVE CATEGORY 2 BY .142/.081 = 1.78

*************************************************************************************************************

***SO WITH POSITIVE RELATIONSHIPS THE FOLLOWING INTERPRETATIONS ARE POSSIBLE:
1) DECREASING THE CUMULATIVE ODDS OF BEING IN A GIVEN CATEGORY OR BELOW BY A CONSTANT FACTOR GREATER THAN 1
2) INCREASING THE CUMULATIVE ODDS OF BEING IN A GIVEN CATEGORY OR BELOW BY THE RECIPROCAL CONSTANT FACTOR (LESS THAN 1)
3) INCREASING THE CUMULATIVE ODDS OF BEING ABOVE A GIVEN CATEGORY BY A CONSTANT FACTOR GREATER THAN 1
4) DECREASING THE CUMULATIVE ODDS OF BEING ABOVE A GIVEN CATEGORY BY THE RECIPROCAL CONSTANT FACTOR (LESS THAN 1)

1 AND 3 ARE USUALLY MORE INTUITIVE THAN 2 AND 4
*************************************************************************************************************

*SO ORDERED LOGIT IS A "PROPORTIONAL ODDS" MODEL -- CONSTANT FACTOR CHANGE IN THE CUMULATIVE ODDS BUT NONCONSTANT FACTOR
*CHANGE IN THE CUMULATIVE PROBABILITIES


* TESTING PROPORTIONAL ODDS OR PARALLEL REGRESSION ASSUMPTIONS
generate onecat=0
replace onecat=1 if loctri<=1  // DUMMY VARIABLE FOR BEING IN CATEGORY 1 OR BELOW
generate twocat=0
replace twocat=1 if loctri <=2  //DUMMY VARIABLE FOR BEING IN CATEGORY 2 OR BELOW
logit onecat groups
logit twocat groups

ologit loctri groups
brant, detail          // NOTE: Can only run brant after ologit, not oprobit
	
***IF PROPORTIONAL ODDS VIOLATED, CAN USE "GOLOGIT2" TO ESTIMATE GENERALIZED ORDERED LOGIT MODEL WITH MANY OPTIONS 
***TO SUBSUME MODELS WE'VE CONSIDERED INTO GENERAL FLEXIBLE FRAMEWORK.  CAN RELAX PROP ODDS ASSUMPTION FOR ANY VARIABLE
***THAT FAILS BRANT TEST, OR IF YOU HAVE THEORETICAL REASONS TO RELAX, OR YOU CAN ALLOW THE PROGRAM TO INDUCTIVELY RELAX THE ASSUMPTION
***FOR YOU

net search "gologit2" and install

recode know 0=0 1 2=1 3 4=2 5/8=3, gen(knowrec)
ologit knowrec educ i.male age i.vote95

mchange // you can see that the effect of vote95, male have (slightly) stronger effects on highest outcomes

mchangeplot,sig(.05)

brant, detail // See that male and vote95 violate assumption of proportional odds 


gologit2 knowrec educ i.male age i.vote95, autofit
gologit2 knowrec educ i.male age i.vote95, pl(educ age)  // same model but manually constrains educ and age to have proportional odds

