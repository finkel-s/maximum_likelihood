*Use vote92a data.

mlogit presvote distrust, b(1)

* Show Data Structure before Conditional Logit Changes 
list presvote bdist cdist pdist distrust in 1/12

gen id = _n  // creates a new variable that is equal to the case number for given individual
expand 3     // creates 3 duplicate observations per case 
sort id      // sorts data so that all observations of same case are next to each other
//This routine will create a new variable "alt" which will be "1" for the first observation
// per individual, "2" for the second observation, "3" for the third
// It will then create a dummy variable for Clinton that will be "1" for the second observation
// per individual and "0" otherwise, and a dummy variable for Perot that will be "1" for the third 
// observation per individual and "0" otherwise -- Bush will be the omitted category still, and will
// correspond to the first observation per individual (I will still create a dummy called Bush 
// for the first observation per individual but will not enter it into the model)
// The final command creates a dummy variable that signifies whether the person's actual presidential 
// vote is equal to the candidate whose "row" it is, i.e., it will be a 1 in the first row if the person 
// voted for Bush, a 1 in the second row if the person voted for Clinton, and a 1 in the third row if 
// the person voted for Perot.  Otherwise "choice" will always equal 0 
gen alt =mod(_n,3)
replace alt=3 if alt ==0
gen bush = (alt==1)
gen clinton = (alt==2)
gen perot = (alt==3)
gen choice = (presvote==alt)

* Show structure of the data with list command 
list id presvote alt choice bush clinton perot bdist cdist pdist in 1/21

* now generate the appropriate ideological distances for each choice category 
gen ideodist=bdist 
replace ideodist=cdist if alt==2
replace ideodist=pdist if alt==3

list id presvote alt choice bush clinton perot bdist cdist pdist ideodist in 1/21

* Now do the clogit for the ideological distance model 
clogit choice  clinton perot ideodist, group(id)

// Predicted Probabilities

// For case #1:  ideo distance of -1 to Bush, -16 to Clinton, -4 to Perot
display exp(.143*-1)/(exp(.143*-1)+exp(.443+.143*-16)+exp(-.634+.143*-4)) //Bush Probability
display exp(.443+.143*-16)/(exp(.143*-1)+exp(.443+.143*-16)+exp(-.634+.143*-4)) // Clinton Probability 
display exp(-.634+.143*-4)/(exp(.143*-1)+exp(.443+.143*-16)+exp(-.634+.143*-4)) // Perot Probability

*or:
display exp(_b[ideodist]*-1)/(exp(_b[ideodist]*-1)+exp(_b[clinton]+_b[ideodist]*-16)+exp(_b[perot]+_b[ideodist]*-4)) //Bush Probability
display exp(_b[clinton]+_b[ideodist]*-16)/(exp(_b[ideodist]*-1)+exp(_b[clinton]+_b[ideodist]*-16)+exp(_b[perot]+_b[ideodist]*-4)) // Clinton Probability 
display exp(_b[perot]+_b[ideodist]*-4)/(exp(_b[ideodist]*-1)+exp(_b[clinton]+_b[ideodist]*-16)+exp(_b[perot]+_b[ideodist]*-4)) // Perot Probability 

predict prob
list prob presvote choice in 1/21


***INTERPRETATIONS

//OVERALL PREDICTED PROBABILITIES FOR BUSH, CLINTON, PEROT

summarize prob if alt==1
summarize prob if alt==2
summarize prob if alt==3

// For otherwise "average" people who vary on one other variable, like MCHANGE 

tabstat ideodist, stat (mean) by (alt) //THIS GIVES THE AVERAGE IDEO DISTANCE FROM EACH CANDIDATE

// For a person who is "average" distance from Bush and Perot, and 0 from Clinton 

display exp(_b[ideodist]*-6.77)/(exp(_b[ideodist]*-6.77)+exp(_b[clinton]+_b[ideodist]*0)+exp(_b[perot]+_b[ideodist]*-5.87)) //Bush Probability
display exp(_b[clinton]+_b[ideodist]*0)/(exp(_b[ideodist]*-6.77)+exp(_b[clinton]+_b[ideodist]*0)+exp(_b[perot]+_b[ideodist]*-5.87)) // Clinton Probability 
display exp(_b[perot]+_b[ideodist]*-5.87)/(exp(_b[ideodist]*-6.77)+exp(_b[clinton]+_b[ideodist]*0)+exp(_b[perot]+_b[ideodist]*-5.87)) // Perot Probability 

// For a person who is "average" distance from Bush and Perot, and -1 from Clinton 

display exp(_b[ideodist]*-6.77)/(exp(_b[ideodist]*-6.77)+exp(_b[clinton]+_b[ideodist]*-1)+exp(_b[perot]+_b[ideodist]*-5.87)) //Bush Probability
display exp(_b[clinton]+_b[ideodist]*-1)/(exp(_b[ideodist]*-6.77)+exp(_b[clinton]+_b[ideodist]*-1)+exp(_b[perot]+_b[ideodist]*-5.87)) // Clinton Probability 
display exp(_b[perot]+_b[ideodist]*-5.87)/(exp(_b[ideodist]*-6.77)+exp(_b[clinton]+_b[ideodist]*-1)+exp(_b[perot]+_b[ideodist]*-5.87)) // Perot Probability 

***INTERPRETATION: ODDS

// So Odds Clinton in first scenario was .719/.282 = 2.55 
// Odds Clinton in second scenario was .689/.311 = 2.22 

// So unit increase in ideological distance to Clinton increased the odds of voting for Clinton by 2.55/2.22, or 1.15 

// Show odds ratios
listcoef  // Shows effect of 1.15 for ideodist
fitstat

//PRESENTATIONAL STRATEGY:  COMPARE MINIMUM-MAXIMUM VALUES OF IDEO DISTANCE FOR EACH CANDIDATE, WITH OTHER TWO AT MEAN VALUE

*Clinton predicted probability with ideo distance to him at a minimum with others at mean
display exp(_b[ideodist]*-6.77)/(exp(_b[ideodist]*-6.77)+exp(_b[clinton]+_b[ideodist]*0)+exp(_b[perot]+_b[ideodist]*-5.87)) //Bush Probability
display exp(_b[clinton]+_b[ideodist]*0)/(exp(_b[ideodist]*-6.77)+exp(_b[clinton]+_b[ideodist]*0)+exp(_b[perot]+_b[ideodist]*-5.87)) // Clinton Probability 
display exp(_b[perot]+_b[ideodist]*-5.87)/(exp(_b[ideodist]*-6.77)+exp(_b[clinton]+_b[ideodist]*0)+exp(_b[perot]+_b[ideodist]*-5.87)) // Perot Probability 

*Clinton maximum distance with others at mean
display exp(_b[ideodist]*-6.77)/(exp(_b[ideodist]*-6.77)+exp(_b[clinton]+_b[ideodist]*-16)+exp(_b[perot]+_b[ideodist]*-5.87)) //Bush Probability
display exp(_b[clinton]+_b[ideodist]*-16)/(exp(_b[ideodist]*-6.77)+exp(_b[clinton]+_b[ideodist]*-16)+exp(_b[perot]+_b[ideodist]*-5.87)) // Clinton Probability 
display exp(_b[perot]+_b[ideodist]*-5.87)/(exp(_b[ideodist]*-6.77)+exp(_b[clinton]+_b[ideodist]*-16)+exp(_b[perot]+_b[ideodist]*-5.87)) // Perot Probability 

//CLASS EXERCISE:  DO BUSH AND PEROT

**INTERPRETATION:  MARGINAL EFFECTS

mchange ideodist
mchange ideodist, atmeans ///DOESN'T MAKE AS MUCH SENSE HERE BECAUSE IT SETS EVERYONE TO THE OVERALL MEAN ON IDEODIST


//Subsuming the MNL model within the Conditional Logit set-up
*show that can't add individual-specific variables to the model without modification

clogit choice ideodist clinton perot distrust , group(id)

// need to generate interaction terms of each choice category with the IVs
generate trustb=distrust*bush
generate trustc=distrust*clinton
generate trustp=distrust*perot

clogit choice trustc clinton trustp perot, group(id)

//THIS IS *EXACTLY* THE SAME MODEL AS AN INDIVIDUAL-LEVEL MULTINOMIAL LOGIT MODEL WITH DISTRUST AS THE INDEPENDENT VARIABLE

//Make data look like it used to by eliminating the two extra observations per individual

preserve
keep if choice==1
list presvote distrust trustb trustc trustp clinton perot in 1/21
mlogit presvote distrust, b(1)


//NOTE:  ONE DIFFERENCE IS IN THE MCFADDEN (PSEUDO) R-SQUARED IN THE TWO MODELS
clogit choice trustc clinton trustp perot, group(id)
fitstat
//CLOGIT:  IMPROVEMENT OF (1706.145-1596.517) DIVIDED BY BASELINE OF 1706.145 = .064

mlogit presvote distrust if choice==1,b(1)
fitstat
//MLOGIT:  IMPROVEMENT OF (1603.782-1596.517) DIVIDED BY BASELINE OF 1603.782 = .005

//WHICH BASELINE IS CORRECT?
//ANSWER:  THE MLOGIT BASELINE INCLUDES ONLY INTERCEPTS FOR CLINTON AND PEROT, WHILE THE CLOGIT BASELINE IS THE MODEL FOR "CHOICE" WITH NO INDEPENDENT
//VARIABLES WHATSOEVER, NOT EVEN THE CLINTON AND PEROT INTERCEPTS -- THEREFORE THE MLOGIT BASLINE IS CORRECT

clogit choice clinton perot if distrust!=.,group(id) //SHOWS THIS MODEL TO HAVE A LOG-LIKELIHOOD OF -1603.782, EXACTLY THE CORRECT BASELINE


// Expand the conditional logit to include other vars and choice-specific variables

generate demc=dem*clinton
generate demp=dem*perot
generate demb=dem*bush
generate indepc=indep*clinton
generate indepp=indep*perot
generate indepb=indep*bush
generate agec=age*clinton
generate agep=age*perot
generate ageb=age*bush
generate malec=male*clinton
generate malep=male*perot
generate maleb=male*bush

clogit choice trustc demc indepc agec malec clinton trustp demp indepp agep malep perot, group(id)
listcoef
preserve
keep if choice==1
mlogit presvote distrust dem indep age male, b(1)


// Now a mixed CL/MNL model with ideodist
clogit choice ideodist trustc demc indepc agec malec clinton trustp demp indepp agep malep perot, group(id)

///MAKE SURE YOU USE THE RIGHT BASELINE MODEL FOR CALCULATING MCFADDEN HERE TOO!

****MULTINOMIAL PROBIT:  USE "CM" MODULE IN STATA -- "CHOICE MODELS"

cmset id alt

*SET CLINTON AS BASELINE TO ILLUSTRATE


cmmprobit choice ideodist , base (2) casevars (age male dem indep distrust) corr(unstructured)
estat correlation
cmmprobit choice ideodist , base (2) casevars (age male dem indep distrust) structural
estat correlation
