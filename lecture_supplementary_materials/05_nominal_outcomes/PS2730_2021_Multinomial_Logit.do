
PS2730
Weeks 5-6 Multinomial Logit

*use vote92a data
tab presvote, gen (choice)
tab1 choice*
// BASIC MULTINOMIAL LOGIT COMMANDS
mlogit presvote distrust

// COMPARISON TO SERIES OF BINOMIAL LOGITS
*BUSH VERSUS CLINTON
logit choice1 distrust if presvote!=3
*PEROT VERSUS CLINTON   
logit choice3 distrust if presvote!=1
*PEROT VERSUS BUSH
logit choice3 distrust if presvote!=2
//NOTE THAT THE COEFFICIENTS ARE SIMILAR TO THE MNL RESULTS BUT NOT IDENTICAL BECAUSE IN THE BINOMIAL LOGITS 
//THERE IS NO INHERENT CONSTRAINT THAT THE THIRD SET OF COEFFICIENTS MUST BE OBTAINABLE THROUGH ALGEBRAIC MANIPULATION FROM THE FIRST TWO
//AS THE THREE ESTIMATIONS ARE MADE ON DIFFERENT NUMBERS OF CASES -- THEREFORE MNL USES DATA MORE EFFICIENTLY

//SET BASELINE CATEGORY MANUALLY
mlogit presvote distrust, b(1)
listcoef

//CALCULATIONS OF LOGITS, ODDS, AND PREDICTED PROBABILITIES
// Predicted Logit, Clinton Over Bush, Distrust == 1
display .143+.0542*1
// THIS USES THE STORED COEFFICIENTS IN STATA:  [2] REFERS TO THE MODEL WHERE OUTCOME ==2 COMPARED TO THE BASE
display [2]_b[_cons] + [2]_b[distrust]*1  
// Predicted Logit, Perot Over Bush, Distrust == 1
display -1.981+.334*1
//OR, USING STORED COEFFICIENTS:
display [3]_b[_cons] + [3]_b[distrust]*1
//Predicted Logit, Bush Over Bush, Distrust == 1
display [1]_b[_cons] + [1]_b[distrust]*1  //NOTE THAT ALL COEFFICIENTS FOR BASELINE CATEGORY ARE 0 BY ASSUMPTION


***ODDS 
*Clinton over Bush
display exp([2]_b[distrust] )
*Perot over Bush
display exp([3]_b[distrust] )
*Perot over Clinton
display exp([3]_b[distrust])/exp([2]_b[distrust])

**PLOT THE ODDS
mlogitplot

// Predicted Probability, Clinton, Distrust ==1
display exp([2]_b[_cons] + [2]_b[distrust]*1)/(1+exp([2]_b[_cons] + [2]_b[distrust]*1)+exp([3]_b[_cons] + [3]_b[distrust]*1))

// Predicted Probabilities, Perot, Distrust ==1
display exp([3]_b[_cons] + [3]_b[distrust]*1)/(1+exp([2]_b[_cons] + [2]_b[distrust]*1)+exp([3]_b[_cons] + [3]_b[distrust]*1))

// Predicted Probability, Bush, Distruct == 1
display exp([1]_b[_cons] + [1]_b[distrust]*1)/(1+exp([2]_b[_cons] + [2]_b[distrust]*1)+exp([3]_b[_cons] + [3]_b[distrust]*1))

//USING PREDICT COMMAND
predict bushpred clinpred rosspred
summarize clinpred rosspred bushpred if distrust == 1

// NOW THE SAME FOR DISTRUST == 5
// Predicted Probability, Clinton, Distrust ==5
display exp([2]_b[_cons] + [2]_b[distrust]*5)/(1+exp([2]_b[_cons] + [2]_b[distrust]*5)+exp([3]_b[_cons] + [3]_b[distrust]*5))
// Predicted Probabilities, Perot, Distrust ==1
display exp([3]_b[_cons] + [3]_b[distrust]*5)/(1+exp([2]_b[_cons] + [2]_b[distrust]*5)+exp([3]_b[_cons] + [3]_b[distrust]*5))
// Predicted Probability, Bush, Distruct == 1
display exp([1]_b[_cons] + [1]_b[distrust]*5)/(1+exp([2]_b[_cons] + [2]_b[distrust]*5)+exp([3]_b[_cons] + [3]_b[distrust]*5))


// OR:
summarize clinpred rosspred bushpred if distrust == 5


// SO WHAT WE JUST DID WAS CALCULATE THE CHANGE IN PROBABILITY FOR A MAXIMUM CHANGE IN DISTRUST
// OF COURSE, WE COULD JUST DO "MCHANGE" AND FIND OUT ALL KINDS OF DISCRETE CHANGES IN PROBABILITIES
mchange, amount(all)
// NOW PLOT THE CHANGES IN PREDICTED PROBABILITIES
mchangeplot, amount(rng)
mchangeplot


fitstat, saving (mod1)  //SAVES THE FIT FROM THE SINGLE VARIABLE MNL IN "MOD1"


// NOW EXTEND MLOGIT TO MULTIPLE INDEPENDENT VARIABLES
mlogit presvote distrust indep dem age male, b(1)

// FITSTAT FOR SUMMARY STATISTICS
fitstat, using (mod1)


//TESTING OVERALL SIGNIFICANCE OF VARIABLES ACROSS ALL CATEGORIES
// EXAMPLE:  INDEP:  ARE ALL OF THE COEFFICIENTS ASSOCIATED WITH "INDEP" = 0
mlogit presvote distrust indep dem age male, b(1)
estimates store A
mlogit presvote distrust dem age male, b(1)
lrtest A
// OR, AN EASIER WAY WITH LONG-FREESE ADO MODULE
mlogit presvote distrust indep dem age male, b(1)
mlogtest, lr

// TESTING OVERALL SIGNIFICANCE OF CHOICE CATEGORIES ACROSS ALL VARIABLES
// ARE ALL OF THE COEFFICIENTS ASSOCIATED WITH, FOR EXAMPLE OUTCOME 1 (BUSH) EQUAL TO THOSE ASSOCIATED WITH OUTCOME 3 (PEROT)?  
//IF SO, THE OUTCOMES ARE "INDISTUIGUISHABLE"
mlogtest, lrcomb 

//USE "Constraint" COMMAND IN STATA TO DO THE SAME THING
constraint define 2 [3]distrust=0
constraint define 3 [3]indep=0
constraint define 4 [3]dem=0
constraint define 5 [3]age=0
constraint define 6 [3]male=0
mlogit presvote distrust indep dem age male, b(1)
estimates store B
mlogit presvote distrust indep dem age male, b(1) constraint (2 3 4 5 6)
lrtest B

//CONSTRAINT IS A USEFUL COMMAND B/C YOU CAN SET COEFFICIENTS IN VARIOUS MODELS TO BE EQUAL TO ZERO OR ANY OTHER VALUE NECESSARY TO DO CERTAIN
//THINGS AND RE-ESTIMATE MODELS AND COMPARE THEM -- BUT IN THIS CASE IT IS MORE CUMBERSOME THAN JUST USING "MLOGTEST"

//NOTE THAT (FOR EXAMPLE) B(CLINTON OVER BUSH) - B (PEROT OVER BUSH) = B (CLINTON OVER PEROT), ETC.

/* TESTING INDEPENDECE OF IRRELEVANT ALTERNATIVES ASSUMPTION */
mlogtest, iia

