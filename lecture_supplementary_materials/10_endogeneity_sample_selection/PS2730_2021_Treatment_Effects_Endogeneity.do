PS2730-2021
Week 13

******TREATMENT EFFECTS MODELS

use https://www.stata-press.com/data/r16/gsem_union3, replace
generate llunion = 0 if union == 1
generate ulunion = 0 if union == 0


regress wage tenure age black smsa union  // naive OLS
**GSEM VERSION
webgetsem gsem_treat

gsem (1.south -> llunion, family(gaussian, udepvar(ulunion)) link(identity)) (1.black -> llunion, family(gaussian, udepvar(ulunion)) link(identity)) (1.black -> wage, ) ///
(tenure -> llunion, family(gaussian, udepvar(ulunion)) link(identity)) (tenure -> wage, ) (age -> wage, ) (L@1 -> llunion, family(gaussian, udepvar(ulunion)) ///
link(identity)) (L -> wage, ) (grade -> wage, ) (1.smsa -> wage, ) (1.union -> wage, ), covstruct(_lexogenous, diagonal) latent(L ) cov( e.llunion@a e.wage@a L@1) nocapslatent


*estimation of rho=sigma/lambda = 1.16/-1.71=-.68
*that's why the estimate of union is *larger* than the naive OLS model

**EXTENDED REGRESSION VERSIONS
**two-step

etregress wage tenure age black smsa, treat(union=black south tenure) twostep
**implausible rho value!

*ML
etregress wage tenure age black smsa, treat (union=black south tenure)
*estimate of rho=-.68, much closer to GSEM version!

***BINARY OUTCOME
ivprobit union black south (tenure=age smsa), twostep

**EXTENDED REGRESSION VERSION
eprobit union black south, endog (tenure=age smsa)

**BINARY TREATMENT EFFECTS
biprobit (union =black south tenure collgrad) (collgrad=age sms)

**EXTENDED REGRESSION VERSION
eprobit union black south tenure , entreat (collgrad=c.age c.sms, nointer pocorr) vce(robust)
estat teffects
