PS2730-2021

// ENDOGENEITY - SAMPLE SELECTION 

use "PS2730-2021.women-labforce.selection.dta", clear
tab lfp
tabstat wage,sta(mean) by (lfp) // WAGES OF WORK-FORCE WOMEN
tabstat wc, sta(mean) by (lfp) //DIFFERENCE IN EDUCATION BETWEEN CURRENTLY WORKING AND NON-WORKING

regress wage wc if lfp==1  // EFFECT OF COLLEGE EDUCATION ON WORK FORCE WOMEN'S WAGES
predict wagepred if e(sample)

heckman wage wc ,select(lfp=k5 wc age hc) two //HECKMAN PROCEDURE WITH K5 (CHILDREN), AGE AND HUSBAND EDUCATION

predict imr,mills //SAVES THE INVERSE MILLS RATIO

//COULD ALSO DO A PROBIT ON WORK-FORCE PARTICIPATION AND GENERATE PREDICTED PROBS TO TURN INTO IMR
probit lfp k5 wc age hc 
predict lfppred // PREDICTED PROBABILITY OF BEING IN THE WORK FORCE
predict lfpxb,xb // LINEAR PREDICTOR (Z-SCORE)
generate imr2=normalden(lfpxb)/normal(lfpxb)  // HEIGHT OF NORMAL CURVE AT PREDICTED Z-SCORE FOR INCLUSION, DIVIDED BY CUM PROBABILITY OF INCLUSION
  // THIS IS THE "INSTANTANEOUS PROBABILITY OF EXCLUSION!!!!
// SHOW THAT THE PREDICTED PROBABILITY OF INCLUSION AND THE IMR ARE INVERSELY RELATED
regress imr lfppred
corr imr imr2 lfppred
corr imr wc // THE IMR AND X (Women's College Eduction) ARE ALSO INVERSELY RELATED

regress wage wc imr if wage ~=.  // THIS IS THE MANUAL VERSION OF HECKMAN SECOND EQUATION WITH THE IMR (COMPARE TO EARLIER HECKMAN)

predict heckwage // HECKMAN PREDICTION FOR ALL WOMEN, REGARDLESS OF WHETHER THEY ARE CURRENTLY IN WORK-FORCE

//HECKMAN PREDICTS THAT CURRENTLY NON-WORKING WOMEN, IF THEY DID WORK, WOULD EARN SLIGHTLY LESS THAN CURRENT WORKERS
tabstat heckwage,sta(mean) by (lfp) // WHY?  BECAUSE THEY HAVE LESS EDUCATION



**ML Version with Extended Regression Module
eregress wage wc ,select(lfp=k5 wc age hc) 

**GSEM Version on ANOTHER WOMEN AND WAGES DATA SET
use https://www.stata-press.com/data/r16/gsem_womenwk, replace
regress wage educ age // THIS IS THE PREDICTION OF WAGES WITHOUT TAKING SELECTION INTO ACCOUNT
generate selected = 0 if wage < .
generate notselected = 0 if wage >= .
webgetsem gsem_select


gsem (married -> selected, family(gaussian, udepvar(notselected)) link(identity)) (children -> selected, family(gaussian, udepvar(notselected)) link(identity)) ///
(educ -> selected, family(gaussian, udepvar(notselected)) link(identity)) (educ -> wage, ) (age -> selected, family(gaussian, udepvar(notselected)) link(identity)) ///
(age -> wage, ) (L@1 -> selected, family(gaussian, udepvar(notselected)) link(identity)) (L -> wage, ), covstruct(_lexogenous, diagonal) latent(L ) ///
cov( e.selected@a e.wage@a L@1) nocapslatent



**HECKMAN AND ML VERSION OF THE GSEM SPECIFICATION
heckman wage educ age ,select(children educ age married) 
recode selected 0=1 .=0, gen(inforce)
eregress wage educ age, select(inforce=children educ age married)
