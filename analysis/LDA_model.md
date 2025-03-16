LDA Models in R
================
Nam Dang
Mar 2025
  - [Introduction](#introduction)
  - [2025] (#2025 topics)
  - [2024] (#2024 topics)
  - [2023] (#2023 topics)
  - [2022] (#2022 topics)
  - [2021] (#2021 topics)
  - [2020] (#2020 topics)
  - [2019] (#2019 topics)

# Introduction
Using LDA model, I want to answer these questions:
1. What are the topics that experts consider important for U.S real-estate each year?
2. How topics change throughout the years?
3. Are the topics ussually the same or different throughout the year?

# 2025 topics
## Step 1: Load Required Libraries
```r
# Install required packages if not already installed
install.packages("pdftools")
install.packages("tm")
install.packages("topicmodels")
install.packages("tidytext")
install.packages("ggplot2")
install.packages("wordcloud")

# Load libraries
library(pdftools)
library(tm)
library(topicmodels)
library(tidytext)
library(ggplot2)
library(wordcloud)
```
## Step 2: Extract Text from the PDF
``` r
# Define the PDF URL
pdf_url <- "https://www.pwc.com/us/en/industries/financial-services/images/pwc-etre-2025.pdf"

# Download PDF
temp_pdf <- tempfile(fileext = ".pdf")
download.file(pdf_url, temp_pdf, mode = "wb")

# Extract text from all pages
pdf_text_data <- pdf_text(temp_pdf)

# Combine text from all pages
full_text <- paste(pdf_text_data, collapse = " ")
```
