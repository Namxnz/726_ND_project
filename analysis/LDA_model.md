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
install.packages("LDAvis")

# Load libraries
library(pdftools)
library(tm)
library(topicmodels)
library(tidytext)
library(ggplot2)
library(wordcloud)
library(LDAvis)
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
## Step 3: Preprocess the Text**

• **Remove stopwords, punctuation, and numbers**

• **Tokenization**: Convert text into individual words

• **Convert to a Document-Term Matrix (DTM)** for LDA
``` r
# Convert text into a corpus
docs <- Corpus(VectorSource(full_text))

# Clean the text
docs <- tm_map(docs, content_transformer(tolower))   # Convert to lowercase
docs <- tm_map(docs, removePunctuation)              # Remove punctuation
docs <- tm_map(docs, removeNumbers)                  # Remove numbers
docs <- tm_map(docs, removeWords, stopwords("en"))   # Remove stopwords
docs <- tm_map(docs, stripWhitespace)                # Remove extra spaces

# Convert to a Document-Term Matrix (DTM)
dtm <- DocumentTermMatrix(docs)

# Remove sparse terms
dtm <- removeSparseTerms(dtm, 0.95)  # Keep only words in at least 5% of documents
```
## Step 4: Train the LDA model
```r
# Set the number of topics (choose based on coherence score later)
num_topics <- 5

# Train LDA model
lda_model <- LDA(dtm, k = num_topics, control = list(seed = 42))

# Extract topics
lda_topics <- terms(lda_model, 10)  # Show top 10 words per topic
lda_topics
```
## Step 5: Visualize the LDA Topics
``` r
# Test multiple values for K (number of topics)
topic_range <- seq(2, 10, by = 2)  # Try 2, 4, 6, 8, 10 topics
perplexity_scores <- sapply(topic_range, function(k) {
  model <- LDA(dtm, k = k, control = list(seed = 42))
  perplexity(model)
})

# Plot Perplexity Scores
topic <- 6  # Select the topic to visualize
words <- posterior(lda_model)$terms[topic, ]  # Get term probabilities for the topic
topwords <- head(sort(words, decreasing = TRUE), n = 50)  # Get top 50 words
head(topwords)  # Print top words with probabilities

wordcloud(names(topwords), topwords)

library(LDAvis)   

dtm = dtm[slam::row_sums(dtm) > 0, ]
phi = as.matrix(posterior(lda_model)$terms)
theta <- as.matrix(posterior(lda_model)$topics)
vocab <- colnames(phi)
doc.length = slam::row_sums(dtm)
term.freq = slam::col_sums(dtm)[match(vocab, colnames(dtm))]

json = createJSON(phi = phi, theta = theta, vocab = vocab,
     doc.length = doc.length, term.frequency = term.freq)
serVis(json)
```
# 2024 topics
Similar to above LDA
``` r
# Define the PDF URL
pdf_url <- "https://www.jstor.org/stable/pdf/2109686.pdf"

# Download PDF
temp_pdf <- tempfile(fileext = ".pdf")
download.file(pdf_url, temp_pdf, mode = "wb")

# Extract text from all pages
pdf_text_data <- pdf_text(temp_pdf)

# Combine text from all pages
full_text <- paste(pdf_text_data, collapse = " ")
# Convert text into a corpus
docs <- Corpus(VectorSource(full_text))

# Clean the text
docs <- tm_map(docs, content_transformer(tolower))   # Convert to lowercase
docs <- tm_map(docs, removePunctuation)              # Remove punctuation
docs <- tm_map(docs, removeNumbers)                  # Remove numbers
docs <- tm_map(docs, removeWords, stopwords("en"))   # Remove stopwords
docs <- tm_map(docs, stripWhitespace)                # Remove extra spaces

# Convert to a Document-Term Matrix (DTM)
dtm <- DocumentTermMatrix(docs)

# Remove sparse terms
dtm <- removeSparseTerms(dtm, 0.95)  # Keep only words in at least 5% of documents

# Set the number of topics (choose based on coherence score later)
num_topics <- 5

# Train LDA model
lda_model <- LDA(dtm, k = num_topics, control = list(seed = 42))

# Extract topics
lda_topics <- terms(lda_model, 10)  # Show top 10 words per topic
lda_topics

# Test multiple values for K (number of topics)
topic_range <- seq(2, 10, by = 2)  # Try 2, 4, 6, 8, 10 topics
perplexity_scores <- sapply(topic_range, function(k) {
  model <- LDA(dtm, k = k, control = list(seed = 42))
  perplexity(model)
})

# Plot Perplexity Scores
topic <- 6  # Select the topic to visualize
words <- posterior(lda_model)$terms[topic, ]  # Get term probabilities for the topic
topwords <- head(sort(words, decreasing = TRUE), n = 50)  # Get top 50 words
head(topwords)  # Print top words with probabilities

wordcloud(names(topwords), topwords)

library(LDAvis)   

dtm = dtm[slam::row_sums(dtm) > 0, ]
phi = as.matrix(posterior(lda_model)$terms)
theta <- as.matrix(posterior(lda_model)$topics)
vocab <- colnames(phi)
doc.length = slam::row_sums(dtm)
term.freq = slam::col_sums(dtm)[match(vocab, colnames(dtm))]

json = createJSON(phi = phi, theta = theta, vocab = vocab,
     doc.length = doc.length, term.frequency = term.freq)
serVis(json)
```
