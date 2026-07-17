# HEOR Portfolio: SGLT2 vs DPP-4 Inhibitors in Type 2 Diabetes

## Project Overview
An independent health economics and outcomes research (HEOR) analysis comparing SGLT2 inhibitors (e.g., Jardiance, Farxiga) versus DPP-4 inhibitors (e.g., Januvia) in adult patients with Type 2 diabetes, conducted using nationally representative US survey data.

## Data Source
Medical Expenditure Panel Survey (MEPS) HC-243 (2022 Full Year Consolidated File) and HC-239A (2022 Prescribed Medicines File), available at meps.ahrq.gov

## Study Population
- 22,431 total MEPS respondents
- 2,528 adult diabetes patients identified
- 466 final study cohort: 328 SGLT2 inhibitor users, 138 DPP-4 inhibitor users

## Methods
- Data cleaning and cohort construction in R (dplyr)
- Baseline characteristics table (Table 1)
- Logistic regression: hospitalization outcome
- Linear regression: total healthcare cost outcome
- Kaplan-Meier survival analysis: time to hospitalization
- Budget impact model (BIM) in Excel: 12-month, 3-scenario projection for 100,000-member plan
- Cost-effectiveness analysis (CEA) in Excel: ICER calculation and cost-effectiveness plane

## Key Findings
- Drug group did not significantly predict hospitalization or total costs after controlling for confounders (p>0.05)
- Each hospitalization added approximately $15,040 in total annual costs
- SGLT2 patients cost $1,100 more per year than DPP-4 patients
- Budget impact: $91 PMPM difference between conservative and optimistic SGLT2 adoption scenarios
- ICER: -$14,865 per hospitalization avoided (DPP-4 dominant on this outcome in this dataset)

## Tools
- R (tidyverse, dplyr, ggplot2, survival, survminer, readxl)
- Microsoft Excel
- Data: MEPS public use files (freely available)

## Literature Review
10 peer-reviewed publications synthesized including RCTs, real-world evidence studies, and economic analyses comparing SGLT2 and DPP-4 inhibitors in Type 2 diabetes.
