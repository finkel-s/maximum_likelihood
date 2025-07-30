PS2730-2021
Longitudinal and Multilevel Models for Non-Continuous Dependent Variables
Weeks 10-11

*I. LONGITUDINAL MODELS FOR DICHOTOMOUS OUTCOMES

**use "PS2730-2021.logit panel data.dta"

xtset subject year
tab year, gen(yrr)
gen civyear=civiced*year
***POOLED LOGIT
logit voted contact civiced thermdif year civyear , vce(cluster subject)

**RANDOM EFFECTS LOGIT
*USING TIME DUMMIES NOT TIME_TREND FOR ILLUSTRATIVE PURPOSES - MIGHT DIFFER DEPENDING ON SUBSTANTIVE CONCERNS IN A GIVEN ANALYSIS

xtlogit voted contact civiced thermdif yrr*, vce(cluster subject)


***POPULATION AVERAGE VERSUS SUBJECT-SPECIFIC INTERPRETATIONS
summarize voted if contact==1  // This is the rough probability of voting for the entire sample if contacted by parties
summarize voted if contact==0  // This is the rough probability of voting for the entire sample if not contacted by parties

dis ln(.87/.13)-ln(.55/.45)    // gives a difference in log-odds for unit change in contact for entire sample of 1.7

logit voted contact  // That is what pooled logit gives you -- the "population averaged" effect of a unit change in the IV

logit voted contact civiced thermdif yrr*, vce(cluster subject) // the multivariate "population average" effects

xtlogit voted contact civiced thermdif yrr*, vce(cluster subject) // the subject-specific effect of 2.95

***SD of the random effects is (2.23), so large amount of variation in the random intercepts.  This produces big differences in the 
***population averaged versus subject-specific effects
   

**RANDOM EFFECTS LOGIT WITH MELOGIT COMMAND
melogit voted contact civiced thermdif yrr*|| subject: , vce(cluster subject) // RESULTS DIFFER SLIGHTLY BECAUSE OF NUMBER OF 'INTPOINTS' IN THE TWO METHODS -- CAN TRY DIFFERENT INTPOINTS WITH , intpoint (X) option

****GSEM VERSION --

***SEE DIAGRAM 1 -- Random Effects Logit with IVs.stsem

gsem (M1[subject] -> voted, family(binomial) link(logit)) (contact -> voted, /// 
family(binomial) link(logit)) (thermdif -> voted, family(binomial) link(logit)) /// 
(yrr2 -> voted, family(binomial) link(logit)) (yrr3 -> voted, family(binomial) link(logit)) ///
(civiced -> M1[subject], )  (yrr4 -> voted, family(binomial) /// 
link(logit)) (yrr5 -> voted, family(binomial) link(logit)), vce(cluster subject) latent(M1 ) nocapslatent


***FIXED EFFECTS LOGIT
egen votesum=sum(voted), by (subject)
tab votesum

*can see that 655 cases do not change on the outcome at any point in time:  these cases will be lost to FE logit
												 
xtlogit voted contact thermdif civiced yrr*, fe  // ALSO SEE THAT CIVICED DROPS OUT BECAUSE IT IS TIME-INVARIANT

// SEE N OF CASES 

**HYBRID MODEL WITH MEANS OF TIME-VARYING VARIABLES INCLUDED 

egen thermdifmn=mean(thermdif), by (subject)
gen thermmndev=thermdif-thermdifmn
egen contactmn=mean(contact), by (subject)
gen contactmndev=contact-contactmn


xtlogit voted contact thermdif civiced yrr* , vce(cluster subject) // "NORMAL" RE
// "HYBRID" RE WITH RAW TIME-SPECIFIC VALUES
xtlogit voted contact contactmn thermdif thermdifmn civiced yrr*  , vce(cluster subject) 
// "HYBRID" RE WITH MEAN-DEVIATED VALUES
xtlogit voted contactmndev contactmn thermmndev thermdifmn civiced yrr* ,vce(cluster subject) 
test thermmndev=thermdifmn  //SHOWS DIFFERENCE FROM WITHIN AND BETWEEN FOR THERMDIF
test contactmndev=contactmn  // SHOWS EQUIVALENCE OF WITHIN AND BETWEEN FOR CONTACT
-
*** MELOGIT VERSION
melogit voted contact thermdif contactmn thermdifmn civiced yrr* ||subject:, vce (cluster subject) // VERSION WITH RAW TIME-SPECIFIC VALUES  


****GSEM VERSIONS -
***HYBRID VERSION -- SEE DIAGRAM 2.Random Effects Hybrid Model
melogit voted contactmndev contactmn thermmndev thermdifmn civiced yrr* || subject:, vce(cluster subject) //VERSION WITH MEAN-DEVIATED VALUES 

gsem (M1[subject] -> voted, family(binomial) link(logit)) (contactmndev -> voted, /// 
family(binomial) link(logit)) (thermmndev -> voted, family(binomial) link(logit)) /// 
(yrr2 -> voted, family(binomial) link(logit)) (yrr3 -> voted, family(binomial) link(logit)) ///
(civiced -> M1[subject], ) (contactmn -> M1[subject], ) (thermdifmn -> M1[subject], ) (yrr4 -> voted, family(binomial) /// 
link(logit)) (yrr5 -> voted, family(binomial) link(logit)), vce(cluster subject) latent(M1 ) nocapslatent



***FOR FUTURE REFERENCE: THE RANDOM SLOPE AND RANDOM INTERCEPT MODELS
 
gsem (M1[subject] -> voted, family(binomial) link(logit)) (contactmndev -> voted, family(binomial) link(logit)) (thermmndev -> voted, family(binomial) link(logit)) (civiced -> M1[subject], ) (civiced -> M2[subject], ) (yrr2 -> voted, family(binomial) link(logit)) (contactmn -> M1[subject], ) (thermdifmn -> M1[subject], ) (yrr3 -> voted, family(binomial) link(logit)) (yrr4 -> voted, family(binomial) link(logit)) (yrr5 -> voted, family(binomial) link(logit)) (M2[subject]#c.contactmndev -> voted), vce(cluster subject) latent(M1 M2 ) nocapslatent


