
PS2730 - 2021
Interpretation of Logit/Probit Models
Calculation of Confounding Versus Rescaling Effects of Adding Additional Explanatory Variables as "Controls"
Karlson-Breen-Holm Method

**get the package from Stata prompt**
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

