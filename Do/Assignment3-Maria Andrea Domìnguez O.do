//3. create dummy for people with BAC > 0.08
gen D = 0
replace D = 1 if bac1>= 0.08

//4. Checking for manipulation 
net install rddensity, from(https://sites.google.com/site/rdpackages/rddensity/stata) replace
net install lpdensity, from(https://sites.google.com/site/nppackages/lpdensity/stata) replace
rddensity bac1, c(0.08) plot all
hist bac1, xline(0.08) width(0.0001)

//5. Cheching for covariate balance
gen bac_c = bac1-0.08
gen inter = D*bac_c

*Male
reg male D bac_c inter, r
outreg2 using balance.doc, replace ctitle(Male)
*White
reg white D bac_c inter,r 
outreg2 using balance.doc, append ctitle(White)
*Aged
reg  age D bac_c inter, r
outreg2 using balance.doc, append ctitle(Aged)
*Acc
reg acc D bac_c inter, r
outreg2 using balance.doc, append ctitle(Accident)


*Checking for balance at the cutoff 
reg male D bac_c inter if (bac_c>-0.05 & bac_c<0.05)
outreg2 using balance2.doc, replace ctitle(Male)
reg white D bac_c inter if (bac_c>-0.05 & bac_c<0.05)
outreg2 using balance2.doc, append ctitle(White)
reg age D bac_c inter if (bac_c>-0.05 & bac_c<0.05)
outreg2 using balance2.doc, append ctitle(Age)
reg acc D bac_c inter if (bac_c>-0.05 & bac_c<0.05)
outreg2 using balance2.doc, append ctitle(Accident)

//6. Recreating Figure 2 Panel A-D
set more off 
*Linear fit 
cmogram acc bac1, cut(0.08) scatter line(0.08)lfitci
cmogram male bac1, cut(0.08) scatter line(0.08)lfitci
cmogram age bac1, cut(0.08) scatter line(0.08)lfitci
cmogram white bac1, cut(0.08) scatter line(0.08)lfitci

*Quadratic fit 
cmogram acc bac1, cut(0.08) scatter line(0.08)qfitci
cmogram male bac1, cut(0.08) scatter line(0.08)qfitci
cmogram age bac1, cut(0.08) scatter line(0.08)qfitci
cmogram white bac1, cut(0.08) scatter line(0.08)qfitci

//7. Equation 1 recidivism 
gen interbac_c = bac_c*D 
gen intersq = (interbac_c)^2
*Panel A
reg recidivism D bac_c male white age acc if (bac1>0.03 & bac1<0.13), r
outreg2 using recidivism.doc, replace ctitle(Linear control)
reg recidivism D bac_c interbac_c  male white age acc if (bac1>0.03 & bac1<0.13), r
outreg2 using recidivism.doc, append ctitle(Linear interaction)
reg recidivism D bac_c interbac_c intersq male white age acc if (bac1>0.03 & bac1<0.13), r
outreg2 using recidivism.doc, append ctitle(Quadratic interaction)

*Panel B
reg recidivism D bac_c male white age acc if (bac1>0.055 & bac1<0.105), r
outreg2 using recidivism2.doc, replace ctitle(Linear control)
reg recidivism D bac_c interbac_c  male white age acc if (bac1>0.055 & bac1<0.105), r
outreg2 using recidivism2.doc, append ctitle(Linear interaction)
reg recidivism D bac_c interbac_c intersq male white age acc if (bac1>0.055 & bac1<0.105), r
outreg2 using recidivism2.doc, append ctitle(Quadratic interaction)

//8. RDD Graph 
*Linear fit
cmogram recidivism bac1 if bac1<0.15, cut(0.08) scatter lineat(0.08) lfitci 
cmogram recidivism bac1 if bac1<0.15, cut(0.08) scatter lineat(0.08) qfitci 

