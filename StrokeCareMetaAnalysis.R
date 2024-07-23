## First we load the apropriate packages
library(gridExtra)
library(meta)
library(dmetar)
library(metafor)
library(dplyr)
library(ggplot2)

## In this project we will work with the dat.normald1999 data set that comes as built in data with the metafor package
## It includes 9 studies that provide data in terms of the mean length of the hospital stay (in days) of stroke patients 
## under specialized care and under conventional/routine (non-specialist) care.
## Hypothesis : Will the specialist stroke unit care result in a shorter length of hospitalization compared to routine management?

df = dat.normand1999
head(df)
glimpse(df)

## We can see that data set includes row data and provides us with mean, standard deviation and number of patients participated in 
## each group.
## Thus we will use the mean difference to pool the effect sizes and more precisely the standardized mean difference in order to avoid 
## differences in scales across studies
## The Hedges method will be used for small sample sizes correction
## In the first glimpse of the data set we can see that 'Source' variable has many different observations that could infer
## heterogeneity in our analysis. Thus we will use the random effects model for pooling the effects
## The restricted maximum likelihood will be used in order to gain unbiased estimates of between studies variance and  
## Hartung-Knapp adjustment to gain more precise confidence intervals.

meta = metacont(n.e = n1i,
                                 mean.e = m1i,
                                 sd.e = sd1i,
                                 n.c = n2i,
                                 mean.c = m2i,
                                 sd.c = sd2i,
                                 studlab = source,
                                 data = df,
                                 sm = 'SMD',
                                 method.smd = 'Hedges',
                                 fixed = F,
                                 random = T,
                                 method.tau = 'REML',
                                 method.random.ci = 'HK',
                                 title = 'Length of Hospital Stay of Stroke Patients')
summary(meta)

## The estimated overall effect size is -0.53 indicating that the for patients who administered care in specialized
## stroke unit had 0.53 lower standardized mean length of stay compared to routine management. The result is not 
## statistical significant as well as the p-value > 0.05 and the CI include the number 0.
## Looking at heterogeneity measures we can see a tau^2 of 0.7887 with C.I. far away from 0. This indicates that 
## the variance of the true effect sizes underlying our data is substantially away from 0.
## The I^2 is 93.5%. This tell us that 93.5%  of the variation in our data is estimated to stem from true effect size differences.


## Based on these data we can predict the range of effect sizes that future studies could fall
meta_update = update(meta, prediction = T)
summary(meta_update)
## The prediction interval gives us a range that includes 0. This means that despite the negative overall effect estimate
## studies with positive effect for routine management cannot be ruled out for future studies.


## Our indicators tell us that there are substantial heterogeneity between true effect sizes of our studies
## Thus we will explore what causes this heterogeneity
## First of all we are searching for outliers
find.outliers(meta_update) 
## The function found that "Orpington-Moderate" study is a potential outlier
## Thus the overall effect size recalculated by deleting this study
## The overall effect size is considerably higher but remain negative. The same pattern follows the C.I and p-value
## The tau^2 and I^2 is lower but heterogeneity between studies is still high


## Next step is to search for influential studies 
## Will be used the leave-one-out method

meta_inf = InfluenceAnalysis(meta, random = T)
plot(meta_inf, 'baujat')
## As we can see the "Orpington-Moderate" study is the only one that can be identified as influential

## Lets desplay all the diagnostics
plot(meta_inf, 'influence')
## The influential diagnostics shows that the "Orpington-Moderate is the main concern as well as its removal
## affects substantially the residuals, changes the pooled effect, infers lower covariance ratio, tau^2 and Q.

## Also we can plot the overall effect and I^2 heterogeneity of all meta-analyses that were conducted using the leave-one-out method.
plot(meta_inf, 'es')
plot(meta_inf, 'i2')
## Both plots shows that omitting the "Orpington-Moderate changes the effect size and reduces the heterogeneity
## Finally both influential analysis and outliers checking shows that one study is a source of concern, however 
## the removal of this study was not indused in significantly lower heterogeneity, and the change in overall effect size is not clinically significant
## Thus we will carry on without removing it 

## Now its time to visualize the effect sizes via forest plot
meta::forest(meta,
             sortvar =TE,
             prediction = T,
             print_tau2 = F,
             leftcols = c("studlab", "TE", "seTE"),
             leftlabs = c("Study", "g", "SE"),
             label.left = "Favors specialized unit",
             label.right = 'Favors routine managment' )

## In the forest plot we can see the pooled effect sizes for each study and the overall effect size of the meta analysis
## Also we can see the effect sizes for each study through Hedges' g correction for small sample sizes along with standard error
## It is also displayed the standardized mean difference along with the 95% C.I as well as the weight of each study
## Inn the bottom of the plot is displayed the method used for pooling the effects, the prediction interval and the amount of heterogeneity in the study

## Overall we can say that this meta analysis shows us that patients who administered care in specialized stroke unit had 0.54 lower standardized
## mean length of stay compared to routine management. These result is not statistically significant as well as the C.I includes 0.
## Despite the negative outcome that favors the specialized stroke unit, the prediction interval indicates that future studies could find both negative or 
## positive outcomes 
## The between study heterogeneity is quite high with an I^2 = 93% and t^2 = 0.78


## At this point it would be a reasonably idea to contact subgroup analysis in order to search for potential reasons that causes the between study heterogeneity
## However subgroup analyses are purely observational, so potential effect differences may be caused by confounding variables.
## Additionally the number of studies in our data set is quite low (k<10) and the statistical power would be small.
## Therefore we decide not to conduct a subgroup analysis because it would makes no sense

meta :: funnel(meta,
               xlim = c(-3, 2),
               studlab = T)
title('Funnel plot stroke care studies')
## As we can see the studies in funnel plot does not appear to be symmetrical. Effect sizes differ substantially. 
## This plot shows that there have been published studies with various effect sizes and standard errors but small studies with extreme high or low effect
## sizes doesn't exist. Only one small study shows very large effect size (Orpington - Severe) does not follow the funnel pattern well. Its effect size is considerably smaller than expected.
## Overall, the data set shows an asymmetrical pattern in the funnel plot that might be indicative of publication bias.

## We can inspect how asymmetry patterns relate to statistical significance via contour-enhanced funnel plots

meta::funnel(meta, xlim = c(-3, 2),
             contour = c(0.9, 0.95, 0.99),
             col.contour = c("gray75", "gray85", "gray95"))
legend(x = 1.6, y = 0.01, 
       legend = c("p < 0.1", "p < 0.05", "p < 0.01"),
       fill = c("gray75", "gray85", "gray95"))
title("Contour-Enhanced Funnel Plot (Funnel plot stroke care studies)")

## For the small studies, shaded funnel plot show us that only one with negative effect size is significant and one is not significant
## For larger studies the results are both significant and not significant with the negative effect studies to appear significant.
## In sum, Contour-Enhanced Funnel Plot corroborates the initial findings of asymmetry that may caused from publication bias
## It is also possible this asymmetry to come from between study heterogeneity or simply by chance


## Eggers regression test
