RESIDENT REAL ESTATE
================
Nam Dang
Mar 2025
  - [Introduction](#introduction)
  - [Codes](#codes)
  - [Result](#result)
  - [Analysis](#analysis)
  - [Conclusion](#conclusion)

# Introduction
Using the result LDA model as prior knowledge, I want to:
1. Create Bayesian model 
2. Show the impact of independence variables to dependent variable
3. Be able the understand the effect of the variables

# Codes
## Step 1: Load Required Libraries and Data
```r
# Install required packages if not already installed
install.packages("zoo")
install.packages("dplyr")
install.packages("brms")
install.packages("tidyverse")
install.packages("ggplot2")

# Load libraries
library(zoo)
library(dplyr)
library(brms)
library("tidyverse")
library("ggplot2")
library(readr)
library(lubridate)

#Install data
library(readr)
zillow_rent <- read_csv("726_project_data/rent.csv")
View(annual_aqi_by_cbsa_2024),
## Same code for other data(mortgage rate, CPI, income, AQI, unemployment rate)
```
## Step 2: Clean data
``` r
# Convert Zillow rent data to long format
zillow_long <- zillow_data %>%
  pivot_longer(
    cols = starts_with("20"),
    names_to = "date",
    values_to = "rent"
  ) %>%
  mutate(date = as.Date(date))  # convert to proper Date
monthly_avg_rent <- zillow_long %>%
  group_by(date) %>%
  summarise(rent = mean(rent, na.rm = TRUE)) %>%
  ungroup()
  
monthly_avg_rent <- zillow_long %>%
  group_by(date) %>%
  summarise(rent = mean(rent, na.rm = TRUE))
# Left join other data
independent_vars<-CPIAUCSL %>%
	left_join(MORTGAGE30US, by="observation_date")%>%
	left_join(MEHOINUSA646N, by="observation_date")%>%
	left_join(UNRATE, by="observation_date")
# full data
full_data <- rent_clean %>%
  left_join(indep_vars_clean, by = c("year", "month"))
# clean NA
full_data <- full_data %>%
  mutate(
    MORTGAGE30US = ifelse(is.na(MORTGAGE30US), mean(MORTGAGE30US, na.rm = TRUE), MORTGAGE30US),
    MEHOINUSA646N = ifelse(is.na(MEHOINUSA646N), mean(MEHOINUSA646N, na.rm = TRUE), MEHOINUSA646N)
  )
model_data <- full_data %>%

  arrange(date)
```
## Step 3: Define Prior Belief

• **Remove stopwords, punctuation, and numbers**

• **Tokenization**: Convert text into individual words

• **Convert to a Document-Term Matrix (DTM)** for LDA
``` r
library(brms)

priors <- c(
  set_prior("normal(-0.05, 0.03)", class = "b", coef = "AQI"),            # Add later if AQI is used
  set_prior("normal(-0.10, 0.05)", class = "b", coef = "MORTGAGE30US"),
  set_prior("normal(-0.15, 0.05)", class = "b", coef = "UNRATE"),
  set_prior("normal(0.12, 0.04)", class = "b", coef = "MEHOINUSA646N"),
  set_prior("normal(0.08, 0.03)", class = "b", coef = "CPIAUCSL"),
  set_prior("normal(0, 1)", class = "Intercept")  # weak prior for intercept
)
```
## Step 4: Fit the Bayesian Model
```r
model <- brm(
  formula = rent ~ CPIAUCSL + MORTGAGE30US + UNRATE + MEHOINUSA646N,
  data = model_data,
  prior = priors,
  family = gaussian(),
  chains = 4,
  iter = 2000,
  warmup = 500,
  seed = 1234,
  control = list(adapt_delta = 0.95)
)
```

## Step 5: Output and Visualize 
``` r
summary(model)
plot(model)
pp_check(model)  # posterior predictive checks

fitted_vals <- fitted(model)
predicted_vals <- predict(model)

model_data <- model_data %>%
  mutate(predicted_rent = predicted_vals[, "Estimate"])

# Plot observed vs predicted
library(ggplot2)
ggplot(model_data, aes(x = date)) +
  geom_line(aes(y = rent), color = "black", size = 1) +
  geom_line(aes(y = predicted_rent), color = "blue", linetype = "dashed") +
  labs(title = "Actual vs Predicted Rent (Bayesian Regression)", y = "Rent Price")
```
#  Result

