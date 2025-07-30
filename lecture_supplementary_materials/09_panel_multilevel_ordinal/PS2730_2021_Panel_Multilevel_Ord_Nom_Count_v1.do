PS2730-2021
Longitudinal and Multilevel Models for Non-Continuous Dependent Variables
Week 11


*use PS2730-2021.Kenya-3wave.dta"

**ORDINAL OUTCOMES

**tab wave, gen(wvv)
**we'll take political interest and divide it into 3 ordinal categories to illustrate ordinal procedures
egen ordint=cut(interest_w), group(3)
tab ordint
xtset id wave
xtologit ordint totalce_w media_w educ wvv*, vce(cluster id)  // clustered standard errors

***USE PREDICT AND MARGINS COMMANDS AS YOU WOULD IN REGULAR OLOGIT - 
***NOTE: LONG-FRESE LISTCOEF/MCHANGE ETC DOESN"T WORK WITH XT MODELS!
margins, at(totalce_w =1)
margins, at(totalce_w =(0(1)6))
margins, at(media_w=(1(1)4))  // OR "atmeans"

***FACTOR CHANGE IN ODDS INTERPRETATION
*civic education
dis exp(.1278) // = 1.14

*So each workshop leads to a 1.14 factor change in the odds of being above a given category versus at or below

**Ordered Logit: Hybrid Model
egen media_mn=mean(media_w), by(id)
gen media_dif=media_w-media_mn
gen totalce_dif=totalce_w-totalce_mn
*Raw version
xtologit ordint totalce_w totalce_mn media_w media_mn educ wvv*, vce(cluster id)
*Mean-deviated version 
xtologit ordint totalce_dif totalce_mn media_dif media_mn educ wvv*, vce(cluster id)
test totalce_mn totalce_dif
test media_mn media_dif
meologit ordint totalce_dif totalce_mn media_dif media_mn educ wvv*||id:, vce(cluster id)

**MULTINOMIAL OUTCOMES
**Random Effect Model
xtmlogit system totalce_w i.sex age know_w
margins, at(totalce_w=(0(1)6)) // CAN SEE THAT MARGINAL EFFECT OF A UNIT CHANGE IN CIVIC ED IS ABOUT .02 
								// PROBABILITY CHANGE FOR AUTOCRACY AND MILITARY, AND ABOUT.05 FOR DEMOCRACY
**ALLOW THE RANDOM EFFECTS TO CORRELATE
xtmlogit system totalce_w i.sex age know_w, cov(unstructured)
//Mild change in regression coefficients, and strong covariance between random effects for military and autocracy

**Fixed Effects Model
xtmlogit system totalce_w i.sex age know_w, fe
//Non-negligible change in effects from RE model, especially for knowledge which is no longer 
//significant for autocracy model

**Note loss of cases for non-changers
**HYBRID MODEL
**egen totalce_mn=mean(total_ce), by(id)
gen totalce_dif=totalce_w-totalce_mn
egen knowmn=mean(know_w), by(id) 
gen know_dif=know_w-knowmn
xtmlogit system totalce_dif totalce_mn i.sex age know_dif knowmn, vce(cluster id)

*compare models with and without cluster means
xtmlogit system totalce_w  i.sex age know_w, vce(cluster id)

***difference in log-likelihood is 4.6 with 2 df, so no improvement of the hybrid version for total_ce

***COUNT OUTCOMES

**use political participation to illustrate count models
quietly tab id, gen(subj)

xtpoisson polpart_w know_w totalce_w wvv1 wvv2 subj* //Dummy variables as fixed effects
xtpoisson polpart_w know_w totalce_w wvv1 wvv2, fe // The fixed effects model -- same results!!

**note: 5 units (15 obs) dropped because of all zero outcomes -- not too bad!
dis exp(.0518)  // = 1.05, which means a factor change of 1.05, or a 5% change increase ///
**.                in the expected rate for every additional CE exposure
dis exp(.171) // = 1.18 or a factor change of 1.18 (18% change) in the rate for an additional unit change in 
**             //   political interest_w

***OVERDISPERSON -- NEGATIVE BINOMIAL MODELS
nbreg polpart_w totalce_w  know_w wvv1 wvv2 subj* // The manual fixed effects method with dummy variables
**Small value for alpha suggests FE poisson is sufficient without overdispersion correction


*Hybrid Model 
egen interest_mn=mean(interest), by(id)
egen know_mn=mean(know_w), by (id)

menbreg polpart_w know_w interest_w totalce_w wvv1 wvv2 know_mn totalce_mn interest_mn ||id: , vce(cluster id)

test totalce_w=totalce_mn  // *testing equality of within and between effects

