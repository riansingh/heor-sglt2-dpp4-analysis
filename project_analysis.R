# Load required packages
library(tidyverse)
library(readxl)
library(survival)
library(survminer)

# Load MEPS HC-243 data
# Note: The source() URL below may return a 404 error.
# If so, ensure h243.dat is downloaded from meps.ahrq.gov and saved to data/raw/
# then run the R programming statements manually from the MEPS website
meps_path <- "/Users/rian/Desktop/HEOR Portfolio/data/raw/h243.dat"
source("https://meps.ahrq.gov/mepsweb/data_stats/download_data/pufs/h243/h243ru.txt")

# Filter to diabetes patients only
diabetes_patients <- h243 %>% filter(DIABDX_M18 == 1)

# Filter to adults only (age 18+)
diabetes_clean <- diabetes_patients %>% filter(AGELAST >= 18)

# Select key variables
diabetes_clean <- diabetes_clean %>% select(
  DUPERSID,
  AGELAST,
  SEX,
  INSCOV22,
  DIABDX_M18,
  TOTEXP22,
  IPDIS22,
  RXTOT22,
  RXEXP22
)

# Save clean diabetes dataset
write.csv(diabetes_clean,
          "/Users/rian/Desktop/HEOR Portfolio/data/clean/diabetes_clean.csv",
          row.names = FALSE)

# Build Table 1 - Baseline Characteristics of diabetes cohort
table1 <- diabetes_clean %>%
  summarize(
    n = n(),
    mean_age = mean(AGELAST),
    pct_female = mean(SEX == 2) * 100,
    pct_private_insurance = mean(INSCOV22 == 1) * 100,
    pct_public_insurance = mean(INSCOV22 == 2) * 100,
    pct_uninsured = mean(INSCOV22 == 3) * 100,
    mean_total_cost = mean(TOTEXP22),
    mean_rx_cost = mean(RXEXP22),
    mean_hospitalizations = mean(IPDIS22)
  )

table1
write.csv(table1, 
          "/Users/rian/Desktop/HEOR Portfolio/outputs/tables/table1_baseline_characteristics.csv",
          row.names = FALSE)
# Create binary hospitalization variable
diabetes_clean <- diabetes_clean %>%
  mutate(hospitalized = ifelse(IPDIS22 > 0, 1, 0))
# Logistic regression - hospitalization outcome
model1 <- glm(hospitalized ~ AGELAST + SEX + INSCOV22 + TOTEXP22,
              data = diabetes_clean,
              family = "binomial")

summary(model1)
# Save logistic regression results
sink("/Users/rian/Desktop/HEOR Portfolio/outputs/tables/logistic_regression_results.txt")
summary(model1)
sink()
# Linear regression - total cost outcome
model2 <- lm(TOTEXP22 ~ AGELAST + SEX + INSCOV22 + IPDIS22 + RXEXP22,
             data = diabetes_clean)

summary(model2)
# Save linear regression results
sink("/Users/rian/Desktop/HEOR Portfolio/outputs/tables/linear_regression_results.txt")
summary(model2)
sink()
# Load MEPS Prescribed Medicines file (XLSX format)
rx_data <- read_excel("/Users/rian/Desktop/HEOR Portfolio/data/raw/h239a.xlsx")

# Identify SGLT2 patients
sglt2_patients <- rx_data %>%
  filter(grepl("EMPAGLIFLOZIN|DAPAGLIFLOZIN|CANAGLIFLOZIN|JARDIANCE|FARXIGA|INVOKANA",
               RXNAME, ignore.case = TRUE)) %>%
  distinct(DUPERSID) %>%
  mutate(drug_group = "SGLT2")

# Identify DPP4 patients
dpp4_patients <- rx_data %>%
  filter(grepl("SITAGLIPTIN|SAXAGLIPTIN|LINAGLIPTIN|ALOGLIPTIN|JANUVIA|ONGLYZA|TRADJENTA|NESINA",
               RXNAME, ignore.case = TRUE)) %>%
  distinct(DUPERSID) %>%
  mutate(drug_group = "DPP4")

# Combine drug groups
drug_groups <- bind_rows(sglt2_patients, dpp4_patients)

# Convert DUPERSID to same type
diabetes_clean$DUPERSID <- as.character(diabetes_clean$DUPERSID)
drug_groups$DUPERSID <- as.character(drug_groups$DUPERSID)

# Create study cohort
study_cohort <- diabetes_clean %>%
  inner_join(drug_groups, by = "DUPERSID")

# Create binary hospitalization variable for study cohort
study_cohort <- study_cohort %>%
  mutate(hospitalized = ifelse(IPDIS22 > 0, 1, 0))

write.csv(study_cohort, 
          "/Users/rian/Desktop/HEOR Portfolio/data/clean/study_cohort.csv", 
          row.names = FALSE)
comparison_table <- study_cohort %>%
  group_by(drug_group) %>%
  summarize(
    n = n(),
    mean_age = mean(AGELAST),
    mean_total_cost = mean(TOTEXP22),
    mean_rx_cost = mean(RXEXP22),
    mean_hospitalizations = mean(IPDIS22)
  )

write.csv(comparison_table,
          "/Users/rian/Desktop/HEOR Portfolio/outputs/tables/comparison_table.csv",
          row.names = FALSE)
# Logistic regression on study cohort - hospitalization outcome
model3 <- glm(hospitalized ~ drug_group + AGELAST + SEX + INSCOV22 + TOTEXP22,
              data = study_cohort,
              family = "binomial")

summary(model3)
# Linear regression on study cohort - total cost outcome
model4 <- lm(TOTEXP22 ~ drug_group + AGELAST + SEX + INSCOV22 + IPDIS22 + RXEXP22,
             data = study_cohort)

summary(model4)
sink("/Users/rian/Desktop/HEOR Portfolio/outputs/tables/study_cohort_regression_results.txt")
summary(model3)
summary(model4)
sink()
# Create survival object
# Event = hospitalized (1=yes, 0=no)
# Time = we'll use RXTOT22 (number of prescriptions) as a proxy for time in care
km_fit <- survfit(Surv(RXTOT22, hospitalized) ~ drug_group, 
                  data = study_cohort)

# Plot the Kaplan-Meier curve
ggsurvplot(km_fit,
           data = study_cohort,
           pval = TRUE,
           legend.labs = c("DPP-4", "SGLT2"),
           title = "Time to Hospitalization by Drug Group",
           xlab = "Number of Prescriptions",
           ylab = "Probability of Remaining Hospitalization-Free")
# Save KM plot
km_plot <- ggsurvplot(km_fit,
                      data = study_cohort,
                      pval = TRUE,
                      legend.labs = c("DPP-4", "SGLT2"),
                      title = "Time to Hospitalization by Drug Group",
                      xlab = "Number of Prescriptions",
                      ylab = "Probability of Remaining Hospitalization-Free")

ggsave("/Users/rian/Desktop/HEOR Portfolio/outputs/plots/km_curve.png",
       plot = km_plot$plot,
       width = 8, height = 6)