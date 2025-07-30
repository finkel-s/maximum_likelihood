*PS2730
*Week 3 Interpretation of Coefficients
*use South African data


***ODDS AND FACTOR CHANGE IN ODDS INTERPRETATION IN LOGIT

logit locdich know
margins, at(know=0)        // SHOWS THE PROBABILITY FOR SOMEONE WITH NO KNOWLEDGE(=0)
display .245/(1-.245)     //GIVES THE "ODDS" FOR A PROBABILITY OF .325,  I.E. GOES FROM P TO P/(1-P)
display ln(.245/(1-.245))  //GIVES THE "LOGIT" FOR A PROBABILITY OF .245, I.E. GOES FROM ODDS TO LOG-ODDS
//NOTE THAT THE RESULT HERE, -1.13, IS THE SAME AS THE INTERCEPT TERM IN THE LOGIT REGRESSION, I.E. WHEN X=0, THE PREDICTED LOG-ODDS

listcoef                   //SHOWS EFFECT OF X ON THE "ODDS" BY EXPONENTIATING THE B FROM THE LOGIT MODEL  -- HERE IT IS 1.615
display exp(.4795)        //VERIFIES THIS


predict logodds2, xb   //GENERATION OF THE PREDICTED LOG-ODDS FOR ALL LEVELS OF KNOWLEDGE
generate odds2=exp(logodds2) //MANUAL GENERATION OF THE PREDICTED ODDS FOR ALL LEVELS OF KNOWLEDGE
tabstat logodds2 odds2,by(know)

// EXERCISE:  VERIFY THE CONSTANT FACTOR CHANGE IN THE ODDS

logit locdich know, or  //OPTION IN STATA TO GO STRAIGHT TO ODDS INTERPRETATION

logit locdich know groups educ1 i.male 
listcoef  //COMPARE SD CHANGE IN ALL VARIABLES IN MULTIPLE REGRESSION IN TERMS OF PREDICTED ODDS


***PROBABILITY AND MARGINAL CHANGE INTERPRETATIONS
probit locdich groups know i.student i.male

**USE MARGINS FOR CHANGES IN PREDICTED PROBABILITIES

//MER:  All VARIABLES AT THEIR MINIMUM
margins, at(groups=0 know=0 student=0 male=0)
//MER:  ALL VARIABLES AT THEIR MAXIMUM
margins, at(groups=5 know=8 student=1 male=1)

//CHANGES IN PREDICTED PROBABILITIES:  MARGINAL CHANGE 
margins, dydx (*) //ALL OTHER VARIABLES AT THIER OBSERVED VALUES -- AND CAUTION IN INTERPRETING THE DUMMY VARIABLES!
margins, dydx (*) atmeans //ALL OTHER VARIABLES SET AT THEIR MEANS -- AND CAUTION IN INTERPRETING THE DUMMY VARIABLES!

//CHANGES IN PREDICTED PROBABILITIES:  DISCRETE CHANGE 
//MER: RANGE OF GROUP MEMBERSHIPS

margins, at(groups=(0 5)) atmeans  // DISCRETE CHANGE FROM 0 to 5 GROUPS USING MARGINAL EFFECTS AT MEAN APPROACH IS: .476

//CHANGES IN PREDICTED PROBABILITIES:  DISCRETE CHANGE USING (DEFAULT) AVERAGE MARGINAL EFFECTS APPROACH

margins, at(groups=(0 5))  // DISCRETE CHANGE FROM 0 to 5 GROUPS, HOLDING OTHER VARS AT OBSERVED SAMPLE VALUES, IS: .44


//SET OTHER VARIABLES TO THEIR MINIMUM AND MAXIMUM
						   						 

margins, at(groups=(0 5) know=0 student=0 male=0) //SO DIFFERENCE BETWEEN MIN AND MAX ON GROUPS, HOLDING OTHER VARS AT MINIMUM, IS:.45

margins, at(groups=(0 5) know=8 student=1 male=1) //SO DIFFERENCE BETWEEN MIN AND MAX ON GROUPS, HOLDING OTHER VARS AT MAX, IS: .21

*WHY IS THIS THE SMALLEST CHANGE FROM MIN TO MAX ON GROUPS?


***GENERATE FULL DISCRETE AND MARGINAL CHANGE INFORMATION WITH MCHANGE

mchange, stats(all)           // OTHER VARIABLES HELD AT OBSERVED SAMPLE VALUES
mchange, stats(all) centered  // FOR DISCRETE CHANGES CENTERED AROUND MEAN
mchange, stats(all) centered atmeans // FOR DISCRETE CHANGES CENTERED AROUND MEAN, OTHER VARIABLES HELD AT MEAN (MEM)

***GIVE PREDICTED PROBABILITIES FOR DIFFERENT CATEGORIES OF DUMMY VARIABLES, REST AT MEAN OR OBSERVED VALUES
probit locdich groups know  i.student i.male
margins male student
margins male student, atmeans
mtable, at(male=(0 1) student=(0 1))  // THIS GIVES THE CROSS-TAB COMBINATION OF MALE STUDENTS/FEMALE STUDENTS, MALE NON-STUDENTS, ETC.


***LATENT VARIABLE Y* INTERPRETATION

probit locdich educ1 know groups i.male student
listcoef

display .26/1.233 //GIVES THE Y-STANDARDIZED COEFFICIENT FOR GROUPS -- ONE ADDITIONAL GROUP LEADS TO .21 STANDARD DEVIATION CHANGE IN Y*
display .186/1.233 //BEING MALE LEADS TO .15 STANDARD DEVIATION CHANGE IN Y*

display .26*1.579/1.233 //GIVES THE FULLY STANDARDIZED COEFFICIENT FOR GROUPS -- AN ADDITIONAL S.D. CHANGE IN GROUPS LEADS TO .33 S.D. CHANGE IN Y*
display .207*1.943/1.233  //SAME FOR KNOWLEDGE
display .185*.48/1.233  //SAME FOR MALE, BUT NOTE DIFFICULTIES IN INTERPRETATION FOR DUMMY VARIABLES, JUST LIKE BETAS IN REGULAR REGRESSION.
						//CAN LOOK IT AS A KIND OF WEIGHTED AVERAGE OF THE EFFECT, WEIGHTED BY PROPORTION MALES/FEMALES IN THE SAMPLE


*****COMPARING ALTERNATIVE MODELS USING FITSTAT

****FIRST WE NEED TO MAKE SURE THAT WE ONLY USE VALID CASES FOR *ALL* MODELS
mark nomiss
markout nomiss educ1 groups i.male i.black age1 ecocur ecofut ideo partyid dembest demsat
tab nomiss //THIS CREATES A VARIABLE NOMISS THAT EQUAL 1 IF THE CASE IS NOT MISSING ON ALL THE VARIABLES IN THE ABOVE LIST

probit locpart educ1 groups age1 i.male i.black if nomiss==1  // THIS IS THE FIRST MODEL WE WANT TO COMPARE -- THE "REDUCED" MODEL
fitstat, saving(mod1)  //THIS SAVES THE RESULTS OF THE FITSTAT INTO A SCALAR CALLED "MOD1"
probit locpart educ1 groups age1 i.male i.black ecocur ecofut ideo partyid dembest demsat if nomiss==1 // THIS IS THE SECOND MODEL WE WANT TO COMPARE -- THE "FULL" MODEL
fitstat, using(mod1)  //THIS COMPARES THE TWO AND GIVES THE DIFFERENCE IN THE LOG-LIKELIHOODS ASSUMING THEY ARE NESTED MODELS




***Interpretation of Logit/Probit Models:  The Karlson-Breen-Holm Method
***Calculation of Confounding Versus Rescaling Effects of Adding Additional Explanatory Variables as "Controls"


**get the khb add-on package from the Stata prompt**
net search khb
install

*Naive comparison of coefficient changes, group memberships by itself, then adding education as a control 
probit locdich groups
listcoef
probit locdich groups educ1
listcoef

**change in groups coefficient from .3277 to .289 = .0382
**but the variance of Y* also changed from 1.27 to 1.34 simply by adding educ1 to the model

*KHB decomposition
regress educ1 groups
predict edres, res // this gives the residualized Z:  same scale as Z but uncorrelated with X

probit locdich groups edres // this gives the "true" reduced effect, controlling for the change in scale
probit locdich groups educ1 // this gives the true full effect
                            // can verify this with "listcoef" after each probit and you'll see the same Latent SD!!!
							
*So change in groups coefficient is really .3414 to .289 = .052

khb probit locdich groups ||educ1

khb probit locdich groups ||educ1, summary

*Gives the true change in coefficient *and* the percentage of the original coefficient that changed due to confounding
*as Conf_Pct = 
dis .052/.341 // =15.2%

*Gives the "Resc+Fact" or scaling factor as 1.042 which is the "true" reduced effect divided by the "naive" reduced effect
dis .3414/.3277 // =1.04

*Also gives the ratio of the reduced to the full coefficients as "Conf_ratio" (but not that interesting)
dis .3414/.2895 //=1.179



