********************************************************************************
* PIREES55
********************************************************************************
/*
Project: Survey I: PIREES55 Data analysis

Creator: Anna Emilie Wehrle & Cristina Penasco



*/


/* ------------------------recoding variables 1/0---------------------------*/ 


recode SchemesAwareness_1 (2=0) 
recode SchemesAwareness_2 (2=0) 
recode SchemesAwareness_3 (2=0) 
recode SchemesAwareness_4 (2=0) 
recode SchemesAwareness_5 (2=0) 
recode SchemesAwareness_6 (2=0) 
recode SchemesAwareness_7 (2=0) 
recode SchemesAwareness_8 (2=0) 
recode SchemesAwareness_9 (2=0) 
recode AdoptedMeasures_1 (2=0) 
recode AdoptedMeasures_2 (2=0) 
recode AdoptedMeasures_3 (2=0) 
recode AdoptedMeasures_4 (2=0) 
recode AdoptedMeasures_5 (2=0) 
recode AdoptedMeasures_6 (2=0) 
recode AdoptedMeasures_7 (2=0) 
recode AdoptedMeasures_8 (2=0) 
recode AdoptedMeasures_9 (2=0) 
recode AdoptedMeasures_10 (2=0) 
recode AdoptedMeasures_11 (2=0) 
recode AdoptedMeasures_12 (2=0) 
recode AdoptedMeasures_13 (2=0) 
recode AdoptedMeasures_14 (2=0) 
recode AdoptedMeasures_15 (2=0) 
recode AdoptedMeasures_16 (2=0) 


**Transformation of independent variables - cleaning process**

***generating income** NOTE: note that the value 16 and 17 are missing values in the original survey
generate income=profile_gross_household
replace income=. if income==16
replace income=. if income==17

**generating  tenure**
generate tenure=1 if profile_house_tenure==1|profile_house_tenure==2|profile_house_tenure==3
replace tenure=2 if profile_house_tenure==4|profile_house_tenure==5|profile_house_tenure==6
replace tenure=3 if profile_house_tenure==7|profile_house_tenure==8|profile_house_tenure==9    

**Transformation old and young people in households** NOTE: note that the value 1 in the original survey was representing 0 people with those characteristics in the household**
generate minor16=1 if under16sinhousehold==2| under16sinhousehold==3| under16sinhousehold==4| under16sinhousehold==5| under16sinhousehold==6
replace minor16=0 if under16sinhousehold==1
generate old75=1 if over75sinhousehold ==2| over75sinhousehold ==3| over75sinhousehold ==4| over75sinhousehold ==5| over75sinhousehold ==6
replace old75=0 if over75sinhousehold==1

**Generating hhsize** NOTE: not that the values 9 and 10 in the original survey were DK and prefer not to say options**
generate hhsize=profile_household_size
replace hhsize=. if hhsize==9
replace hhsize=. if hhsize==10

**Generating whenbuilt2** NOTE that the value 6 in the original survey for this variable was DK
generate whenbuilt2=whenbuilt
replace whenbuilt2=. if whenbuilt>5

**Generating awareness**
generate awarenessum= SchemesAwareness_1+SchemesAwareness_2+SchemesAwareness_3+SchemesAwareness_4+SchemesAwareness_5+SchemesAwareness_6+SchemesAwareness_7

**Generating house_type2**
generate house_type2=house_type
replace house_type2=. if house_type>6


**Creation of Dependent variables**

**Creation of a variable treated for all households in which at=1| adoptedmeasures_3==1| adoptedmeasures_4==1| adoptedmeasures_5==1| adoptedmeasures_6==1| adoptedmeasures_7==1| adoptedmeasures_8==1| adoptedmeasures_9==1| adoptedmeasures_10==1| adoptedmeasures_11==1| adoptedmeasures_12==1| adoptedmeasures_13==1| adoptedmeasures_14==1)

replace treated=0 if treated==.

** Treated sum**

generate treatedsum= (adoptedmeasures_1+ adoptedmeasures_2+adoptedmeasures_3 + adoptedmeasures_4 +adoptedmeasures_5+ adoptedmeasures_6 + adoptedmeasures_7 +  adoptedmeasures_8 + adoptedmeasures_9 + adoptedmeasures_10 + adoptedmeasures_11 + adoptedmeasures_12 + adoptedmeasures_13 + adoptedmeasures_14)


**** Treated for high and low cost measures***
generate sumlowcost= adoptedmeasures_1+ adoptedmeasures_2+ adoptedmeasures_3+ adoptedmeasures_12
generate lowcostdummy=1 if sumlowcost>0
replace lowcostdummy=0 if sumlowcost==0
generate sumhighcost= adoptedmeasures_4+ adoptedmeasures_5 + adoptedmeasures_6+ adoptedmeasures_7+ adoptedmeasures_8+ adoptedmeasures_9+ adoptedmeasures_10+ adoptedmeasures_11+ adoptedmeasures_13+ adoptedmeasures_14
generate highcostdummy=1 if sumhighcost>0
replace highcostdummy=0 if sumhighcost==0


****Treated for multinomial logit - Dependent variable with 4 categories****
generate treatedmulti=0 if lowcostdummy==0 & highcostdummy==0
replace treatedmulti=1 if lowcostdummy==1 & highcostdummy==0
replace treatedmulti=2 if lowcostdummy==0 & highcostdummy==1
replace treatedmulti=3 if lowcostdummy==1 & highcostdummy==1 least they have adopted an energy efficiency measure**

*Treated vs non treated*

generate treated=1 if (adoptedmeasures_1==1| adoptedmeasures_2==1| adoptedmeasures_3==1| adoptedmeasures_4==1| adoptedmeasures_5==1| adoptedmeasures_6==1| adoptedmeasures_7==1| adoptedmeasures_8==1| adoptedmeasures_9==1| adoptedmeasures_10==1| adoptedmeasures_11==1| adoptedmeasures_12==1| adoptedmeasures_13==1| adoptedmeasures_14==1)

replace treated=0 if treated==.

** Treated sum** 

generate treatedsum= (adoptedmeasures_1+ adoptedmeasures_2+adoptedmeasures_3 + adoptedmeasures_4 +adoptedmeasures_5+ adoptedmeasures_6 + adoptedmeasures_7 +  adoptedmeasures_8 + adoptedmeasures_9 + adoptedmeasures_10 + adoptedmeasures_11 + adoptedmeasures_12 + adoptedmeasures_13 + adoptedmeasures_14)


**** Treated for high and low cost measures***
generate sumlowcost= adoptedmeasures_1+ adoptedmeasures_2+ adoptedmeasures_3+ adoptedmeasures_12
generate lowcostdummy=1 if sumlowcost>0
replace lowcostdummy=0 if sumlowcost==0
generate sumhighcost= adoptedmeasures_4+ adoptedmeasures_5 + adoptedmeasures_6+ adoptedmeasures_7+ adoptedmeasures_8+ adoptedmeasures_9+ adoptedmeasures_10+ adoptedmeasures_11+ adoptedmeasures_13+ adoptedmeasures_14
generate highcostdummy=1 if sumhighcost>0
replace highcostdummy=0 if sumhighcost==0


****Treated for multinomial logit - Dependent variable with 4 categories****
generate treatedmulti=0 if lowcostdummy==0 & highcostdummy==0
replace treatedmulti=1 if lowcostdummy==1 & highcostdummy==0
replace treatedmulti=2 if lowcostdummy==0 & highcostdummy==1
replace treatedmulti=3 if lowcostdummy==1 & highcostdummy==1


**correlation matrix**

correlate treated lowcostdummy highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1 CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum house_type2 tenure whenbuilt2 squarefoot bedroom hhsize income old75 minor16 address_change_time EPCrating profile_GOR 
matrix corrmatrix=r(C)
heatplot corrmatrix
heatplot corrmatrix, values (format(%4.2f) size (small)) legend (off) 


**Table 3 and Table A3**
eststo: logit treated AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1 CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post

eststo: cloglog treated AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1 CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post

eststo: poisson treatedsum AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1 CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post


**coefplot code*
coefplot, keep( AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1 CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum) xline(0) 
coefplot, keep( AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1 CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum) xline(1) eform



*** Table 4 and Table A4: logit and clogit for classification by high low cost***

eststo: cloglog lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1 CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
estimates store Lowcostclog
eststo: margins, dydx(_all) post

eststo: cloglog highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1 CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
estimates store Highcostclog
eststo: margins, dydx(_all) post

eststo: logit lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1 CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
estimates store Lowcostlogit
eststo: margins, dydx(_all) post

eststo: logit highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1 CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
estimates store Highcostlogit
eststo: margins, dydx(_all) post


**coefplot**

qui coefplot Lowcostlogit Lowcostclog, keep( AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1 CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum) xline(1) eform name(modellow_awareness, replace)

qui coefplot Highcostlogit Highcostclog, keep( AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1 CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum) xline(1) eform name(modelhigh, replace)

graph combine "modellow_awareness.gph" "modelhigh.gph", ycommon xcommon title("Odd-ratios per type of measure")



***Multinomial logit***

**Table A5**

eststo: mlogit treatedmulti AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1 CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time i.profile_GOR [pweight = Weight], b(0) vce(robust)




***Policy interactions**

**Table A6**

eststo: logit treated c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit treated AdoptionLikelihood_1 c.AdoptionLikelihood_2#c.CircumstancesLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit treated AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit treated AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit treated c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_2 AdoptionLikelihood_3  c.AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit treated AdoptionLikelihood_1 c.AdoptionLikelihood_2#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_3  AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit treated AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit treated AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3   c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post

**Table A7**

eststo: cloglog treated c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog treated AdoptionLikelihood_1 c.AdoptionLikelihood_2#c.CircumstancesLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog treated AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog treated AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog treated c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_2 AdoptionLikelihood_3  c.AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog treated AdoptionLikelihood_1 c.AdoptionLikelihood_2#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_3  AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog treated AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog treated AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3   c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post


**Codes graphs policy mixes**

eststo: logit treated c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_1) at (CircumstancesLikelihood_2=(1(1)11)) 
marginsplot, recastci(rarea)
eststo: cloglog treated c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_1) at (c.CircumstancesLikelihood_2=(1(1)11)) 
marginsplot, recastci(rarea)
eststo: logit treated AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_3) at (c.CircumstancesLikelihood_2=(1(1)11)) 
marginsplot, recastci(rarea)
eststo: cloglog treated AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_3) at (c.CircumstancesLikelihood_2=(1(1)11)) 
marginsplot, recastci(rarea)
eststo: logit treated c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_2 AdoptionLikelihood_3  c.AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_1) at (c.CircumstancesLikelihood_2=(1(1)11) c.AdoptionLikelihood_4=(1(1)11))
marginsplot, recastci(rarea)
eststo: logit treated c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_2 AdoptionLikelihood_3  c.AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_1) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: cloglog treated c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_2 AdoptionLikelihood_3  c.AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_1) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: logit treated AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_3) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: cloglog treated AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_3) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: logit treated AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3   c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_5) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: cloglog treated AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3   c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_5) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)

**Codes graphs policy mixes low cost**

eststo: logit lowcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_1) at (CircumstancesLikelihood_2=(1(1)11)) 
marginsplot, recastci(rarea)
eststo: cloglog lowcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_1) at (c.CircumstancesLikelihood_2=(1(1)11)) 
marginsplot, recastci(rarea)
eststo: logit lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_3) at (c.CircumstancesLikelihood_2=(1(1)11)) 
marginsplot, recastci(rarea)
eststo: cloglog lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_3) at (c.CircumstancesLikelihood_2=(1(1)11)) 
marginsplot, recastci(rarea)
eststo: logit lowcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_2 AdoptionLikelihood_3  c.AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_1) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: cloglog lowcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_2 AdoptionLikelihood_3  c.AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_1) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: logit lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_3) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: cloglog lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_3) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: logit lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3   c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_5) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: cloglog lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3   c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_5) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)


***Codes graphs high cost policy mixes***

eststo: logit highcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_1) at (CircumstancesLikelihood_2=(1(1)11)) 
marginsplot, recastci(rarea)
eststo: cloglog highcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_1) at (c.CircumstancesLikelihood_2=(1(1)11)) 
marginsplot, recastci(rarea)
eststo: logit highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_3) at (c.CircumstancesLikelihood_2=(1(1)11)) 
marginsplot, recastci(rarea)
eststo: cloglog highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_3) at (c.CircumstancesLikelihood_2=(1(1)11)) 
marginsplot, recastci(rarea)
eststo: logit highcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_2 AdoptionLikelihood_3  c.AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_1) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: cloglog highcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_2 AdoptionLikelihood_3  c.AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_1) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: logit highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_3) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: cloglog highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_3) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: logit highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3   c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_5) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)
eststo: cloglog highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3   c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
margins, dydx(c.AdoptionLikelihood_5) at (c.AdoptionLikelihood_4=(1(1)11) c.CircumstancesLikelihood_2=(1(1)11) )
marginsplot, recastci(rarea)

**Table A8**

eststo: cloglog lowcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog lowcostdummy AdoptionLikelihood_1 c.AdoptionLikelihood_2#c.CircumstancesLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog lowcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_2 AdoptionLikelihood_3  c.AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog lowcostdummy AdoptionLikelihood_1 c.AdoptionLikelihood_2#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_3  AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3   c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post



**Table A9**


eststo: logit lowcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit lowcostdummy AdoptionLikelihood_1 c.AdoptionLikelihood_2#c.CircumstancesLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit lowcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_2 AdoptionLikelihood_3  c.AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit lowcostdummy AdoptionLikelihood_1 c.AdoptionLikelihood_2#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_3  AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit lowcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3   c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post


**Table A10**

eststo: logit highcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit highcostdummy AdoptionLikelihood_1 c.AdoptionLikelihood_2#c.CircumstancesLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit highcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_2 AdoptionLikelihood_3  c.AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit highcostdummy AdoptionLikelihood_1 c.AdoptionLikelihood_2#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_3  AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: logit highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3   c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post


**Table A11**

eststo: cloglog highcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog highcostdummy AdoptionLikelihood_1 c.AdoptionLikelihood_2#c.CircumstancesLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2 AdoptionLikelihood_4 AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4 c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog highcostdummy c.AdoptionLikelihood_1#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_2 AdoptionLikelihood_3  c.AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog highcostdummy AdoptionLikelihood_1 c.AdoptionLikelihood_2#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 AdoptionLikelihood_3  AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 c.AdoptionLikelihood_3#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: cloglog highcostdummy AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3   c.AdoptionLikelihood_5#c.CircumstancesLikelihood_2#c.AdoptionLikelihood_4 CircumstancesLikelihood_1   CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum i.house_type2 i.tenure ib5.whenbuilt2 squarefoot bedroom hhsize old75 minor16 income i.address_change_time ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post


***Robustness check**

**imputation**

. mi set wide

. mi register imputed house_type2  whenbuilt2  bedroom hhsize old75 minor16 income address_change_time

. mi impute mvn house_type2  whenbuilt2  bedroom hhsize old75 minor16 income address_change_time, add(1)


**t-test table A12**

ttest house_type2 == _1_house_type2, unpaired
ttest whenbuilt2 == _1_whenbuilt2, unpaired
ttest hhsize == _1_hhsize, unpaired
ttest old75 == _1_old75, unpaired
ttest minor16 == _1_minor16, unpaired
ttest address_change_time == _1_address_change_time, unpaired
ttest bedrooms == _1_bedrooms, unpaired
ttest income == _1_income, unpaired


**regression Table 5 and A13**

eststo: jackknife: cloglog treated AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1  CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum _1_house_type2 i.tenure _1_whenbuilt2 squarefoot _1_bedrooms _1_hhsize _1_old75 _1_minor16 _1_income _1_address_change ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: jackknife: logit treated AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1  CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum _1_house_type2 i.tenure _1_whenbuilt2 squarefoot _1_bedrooms _1_hhsize _1_old75 _1_minor16 _1_income _1_address_change ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: jackknife: poisson treatedsum AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1  CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum _1_house_type2 i.tenure _1_whenbuilt2 squarefoot _1_bedrooms _1_hhsize _1_old75 _1_minor16 _1_income _1_address_change ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post


**Regression Table 6 and A14**
eststo: jackknife: logit lowcostd AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1  CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum _1_house_type2 i.tenure _1_whenbuilt2 squarefoot _1_bedrooms _1_hhsize _1_old75 _1_minor16 _1_income _1_address_change ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: jackknife: cloglog lowcostd AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1  CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum _1_house_type2 i.tenure _1_whenbuilt2 squarefoot _1_bedrooms _1_hhsize _1_old75 _1_minor16 _1_income _1_address_change ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: jackknife: logit highcostd AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1  CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum _1_house_type2 i.tenure _1_whenbuilt2 squarefoot _1_bedrooms _1_hhsize _1_old75 _1_minor16 _1_income _1_address_change ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
eststo: jackknife: cloglog highcostd AdoptionLikelihood_1 AdoptionLikelihood_2 AdoptionLikelihood_3 AdoptionLikelihood_4   AdoptionLikelihood_5 CircumstancesLikelihood_1  CircumstancesLikelihood_2 CircumstancesLikelihood_3 CircumstancesLikelihood_4 CircumstancesLikelihood_5 awarenessum _1_house_type2 i.tenure _1_whenbuilt2 squarefoot _1_bedrooms _1_hhsize _1_old75 _1_minor16 _1_income _1_address_change ib9.EPCrating i.profile_GOR [pweight = Weight], vce(robust)
eststo: margins, dydx(_all) post
