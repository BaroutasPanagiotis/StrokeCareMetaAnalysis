# README

## Meta-Analysis of Length of Hospital Stay for Stroke Patients

This repository contains the code and analysis for a meta-analysis investigating whether specialized stroke unit care results in a shorter length of hospitalization compared to routine management. It is used the `dat.normand1999` dataset from the `metafor` package.

### Hypothesis

The hypothesis is that specialist stroke unit care results in a shorter length of hospitalization compared to routine (non-specialist) care.

### Data Description

The dataset includes data from 9 studies, providing the mean length of hospital stay (in days) of stroke patients under specialized care and routine care. The data includes:
- Number of patients in each group
- Mean length of stay for each group
- Standard deviation for each group

### Analysis Methods

1. **Effect Size Calculation**: 
   - The standardized mean difference (SMD) is used to pool the effect sizes.
   - Hedges' method is applied for small sample size correction.
   
2. **Model Selection**:
   - A random effects model is used due to the expected heterogeneity.
   - Restricted Maximum Likelihood (REML) is used to estimate between-study variance.
   - Hartung-Knapp adjustment is used to obtain more precise confidence intervals.

3. **Heterogeneity Assessment**:
   - Tau^2 and I^2 statistics are calculated to measure heterogeneity.
   
4. **Influence Analysis**:
   - Outliers and influential studies are identified and analyzed.
   
5. **Visualization**:
   - Forest plots are used to visualize effect sizes and overall results.

### Key Findings

- The overall effect size is -0.53, indicating that patients in specialized stroke units had a 0.53 lower standardized mean length of stay compared to routine management. 
- The result is not statistically significant (p-value > 0.05, CI includes 0).
- High heterogeneity is present (Tau^2 = 0.7887, I^2 = 93.5%).
- Prediction intervals suggest that future studies could find both negative or positive outcomes.

### Steps to Run the Analysis

1. **Install Required Packages**:
   ```R
   install.packages(c("gridExtra", "meta", "dmetar", "metafor", "dplyr", "ggplot2"))
   ```

2. **Load the Required Libraries**:
   ```R
   library(gridExtra)
   library(meta)
   library(dmetar)
   library(metafor)
   library(dplyr)
   library(ggplot2)
   ```

3. **Load the Data**:
   ```R
   df <- dat.normand1999
   ```

4. **Run the Meta-Analysis**:
   ```R
   meta <- metacont(n.e = n1i,
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
   ```

5. **Update and Summarize the Model**:
   ```R
   meta_update <- update(meta, prediction = T)
   summary(meta_update)
   ```

6. **Influence Analysis**:
   ```R
   find.outliers(meta_update)
   meta_inf <- InfluenceAnalysis(meta, random = T)
   plot(meta_inf, 'baujat')
   plot(meta_inf, 'influence')
   plot(meta_inf, 'es')
   plot(meta_inf, 'i2')
   ```

7. **Forest Plot**:
   ```R
   meta::forest(meta,
                sortvar = TE,
                prediction = T,
                print_tau2 = F,
                leftcols = c("studlab", "TE", "seTE"),
                leftlabs = c("Study", "g", "SE"),
                label.left = "Favors specialized unit",
                label.right = 'Favors routine management')
   ```

### Conclusion

The meta-analysis indicates that specialized stroke unit care may result in a shorter length of hospitalization compared to routine care, but the result is not statistically significant. There is substantial heterogeneity among the studies, and future studies could show varied outcomes.

### Future Work

Given the high heterogeneity and the presence of influential studies, future research could explore potential sources of heterogeneity through subgroup analyses or additional studies with larger sample sizes.