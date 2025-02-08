# Read the CSV file from the URL
NHANES <- read.csv("https://raw.githubusercontent.com/rashida048/Datasets/refs/heads/master/nhanes_2015_2016.csv")
# Check the first few rows
head(NHANES)
# Data summary
summary(NHANES)
