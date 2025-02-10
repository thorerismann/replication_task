***Representativy of the sample**

*Note: the weight tabulations are the frequencies we are searching for i.e. representative targets*

**Representativity by social grade**

generate rep_socialgrade=1 if profile_socialgrade==1
replace rep_socialgrade=1 if profile_socialgrade==2
replace rep_social=2 if profile_socialgrade==3
replace rep_social=3 if profile_socialgrade==4
replace rep_social=4 if profile_socialgrade==5
replace rep_social=4 if profile_socialgrade==6

tabulate rep_social [aweight = Weight]
tabulate rep_social
 
**Representativity by age, gender and education 

*Use profile_gender as the original variable for gender without transformation*

generate rep_age=4 if age>64
replace rep_age=3 if age<65
replace rep_age=2 if age<50
replace rep_age=1 if age<25

generate rep_edu=1 if profile_education_level==1
replace rep_edu=1 if profile_education_level==2
replace rep_edu=1 if profile_education_level==8
replace rep_edu=1 if profile_education_level==9
replace rep_edu=1 if profile_education_level==10
replace rep_edu=2 if profile_education_level==3
replace rep_edu=2 if profile_education_level==4
replace rep_edu=2 if profile_education_level==5
replace rep_edu=2 if profile_education_level==6
replace rep_edu=2 if profile_education_level==7
replace rep_edu=2 if profile_education_level==11
replace rep_edu=2 if profile_education_level==12
replace rep_edu=2 if profile_education_level==13
replace rep_edu=2 if profile_education_level==14
replace rep_edu=2 if profile_education_level==15
replace rep_edu=2 if profile_education_level==18
replace rep_edu=3 if profile_education_level==16
replace rep_edu=3 if profile_education_level==17


table (profile_gen  rep_age rep_edu), statistic(frequency) statistic(percent) 
table (profile_gen  rep_age rep_edu) [pweight=Weight], statistic(frequency) statistic(percent) 


**Representativity by region and past vote**



*Region*

generate rep_GOR=1 if profile_GOR==1
replace rep_GOR=1 if profile_GOR==2
replace rep_GOR=1 if profile_GOR==3
replace rep_GOR=2 if profile_GOR==4
replace rep_GOR=2 if profile_GOR==5
replace rep_GOR=2 if profile_GOR==5
replace rep_GOR=2 if profile_GOR==6
replace rep_GOR=3 if profile_GOR==7
replace rep_GOR=4 if profile_GOR==8
replace rep_GOR=4 if profile_GOR==9
replace rep_GOR=5 if profile_GOR==10
replace rep_GOR=6 if profile_GOR==11

*Past vote England*
generate rep_past=1 if pastvote_ge_2019==1
replace rep_past=2 if pastvote_ge_2019==2
replace rep_past=3 if pastvote_ge_2019==3
replace rep_past=4 if pastvote_ge_2019==4
replace rep_past=5 if pastvote_ge_2019==5
replace rep_past=6 if pastvote_ge_2019==6
replace rep_past=7 if pastvote_ge_2019==7
replace rep_past=7 if pastvote_ge_2019==98
replace rep_past=8 if pastvote_ge_2019==99
replace rep_past=8 if pastvote_ge_2019==.


tabulate rep_past rep_GOR [aweight = Weight], cell
tabulate rep_past rep_GOR, cell

*Past vote Wales*
generate rep_pastw=1 if rep_past==1
replace rep_pastw=2 if rep_past==2
replace rep_pastw=3 if rep_past==3
replace rep_pastw=4 if rep_past==4
replace rep_pastw=5 if rep_past==5
replace rep_pastw=6 if rep_past==6
replace rep_pastw=7 if rep_past==7
replace rep_pastw=7 if rep_past==8

tabulate rep_pastw rep_GOR, cell
tabulate rep_pastw rep_GOR [aweight=Weight], cell

*Past vote Scotland*
generate rep_pastscot=rep_pastw
replace rep_pastscot=7 if rep_pastw==6


tabulate rep_pastscot rep_GOR, cell
tabulate rep_pastscot rep_GOR [aweight=Weight], cell




***Comparison with EHS data 2022- 2023** Percentages to be compared with https://assets.publishing.service.gov.uk/media/65785e250467eb000d55f5ea/2022-23_EHS_Headline_Report_Chapter_1_Profile_of_households_and_dwellings_Annex_Tables.ods

generate ageEHS=6 if age>64
replace ageEHS=5 if age<65
replace ageEHS=4 if age<55
replace ageEHS=3 if age<45
replace ageEHS=2 if age<35
replace ageEHS=1 if age<25

*See doc. PIREES55 for definition of the variables
Minor16
Tenure
Whenbuilt
house_type2

tabulate minor16 [aweight=Weight] if profile_GOR<10
tabulate ageEHS [aweight=Weight] if profile_GOR<10
tabulate house_type2 [aweight=Weight] if profile_GOR<10
tabulate tenure [aweight=Weight] if profile_GOR<10
tabulate whenbuilt2 [aweight=Weight] if profile_GOR<10

