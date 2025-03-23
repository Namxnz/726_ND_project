RESIDENT REAL ESTATE
================
Nam Dang
Mar 2025
  - [Introduction](#introduction)
  - [Codes] (#Codes)
  - [Result] (#Result)
  - [Analysis] (#Analysis)
  - [Conclusion] (#Conclusion)

# Introduction
Using LDA model, I want to answer these questions:
1. What are the factors that effect prices in residential real-estate?
2. Is the these topics make sense?
3. Are the topics ?

# Codes
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
install.packages("textstem")   # For stemming
install.packages("stringdist") # For fuzzy matching

# Load libraries
library(pdftools)
library(tm)
library(topicmodels)
library(tidytext)
library(ggplot2)
library(wordcloud)
library(LDAvis)
library(textstem)  # For stemming
library(stringdist)  # For fuzzy matching
```
## Step 2: Extract Text from the PDF
``` r
# Define the PDF file
resident_real_data<-"~/Downloads/JHS/726/final_project_pdf/resident_real_estate"
resident_data_file<-list.files(resident_real_data, pattern = "\\.pdf$", full.names = TRUE)
resident_pdf_texts <- lapply(resident_data_file, pdf_text)
resident_all_text <- unlist(resident_pdf_texts)
resident_all_text <- paste(resident_all_text, collapse = " ") # Merge text into a single string
```
## Step 3: Preprocess the Text**

• **Remove stopwords, punctuation, and numbers**

• **Tokenization**: Convert text into individual words

• **Convert to a Document-Term Matrix (DTM)** for LDA
``` r
# Convert text into a corpus
resident_docs <- Corpus(VectorSource(resident_all_text))

## Clean the text
resident_docs <- tm_map(resident_docs, content_transformer(tolower))
## Convert to lowercase
resident_docs <- tm_map(resident_docs, removePunctuation)
## Remove punctuation
resident_docs <- tm_map(resident_docs, removeNumbers)
## Remove numbers
resident_docs <- tm_map(resident_docs, removeWords, stopwords("en"))
## Remove stopwords
resident_docs <- tm_map(resident_docs, stripWhitespace)
## Remove extra spaces

# Convert to a Document-Term Matrix (DTM)
dtm <- DocumentTermMatrix(resident_docs)

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
lda_topics <- terms(lda_model, 20)  # Show top 10 words per topic
lda_topics
```
## Step 5: clean up unnecessary words
```r
library(textstem)  # For stemming
library(stringdist)  # For fuzzy matching

# Extract topic words
topic <- 6  
words <- posterior(lda_model)$terms[topic, ]  

# Sort and get top words
topwords <- head(sort(words, decreasing = TRUE), n = 50)

# Remove unwanted characters (e.g., "-", "–")
word_names <- gsub("[-–]", " ", names(topwords))  # Replace "-" with space

# Stem words to their base form (e.g., "prices" -> "price")
word_names_stemmed <- lemmatize_words(word_names)

# Convert to lowercase to avoid case-sensitive duplicates
word_names_stemmed <- tolower(word_names_stemmed)

# Identify near-duplicates using string distance
unique_words <- c()
word_probs <- c()

for (i in seq_along(word_names_stemmed)) {
  word <- word_names_stemmed[i]
  prob <- topwords[i]

  # Check if the word (or similar words) already exists
  if (!any(stringdist::stringdist(word, unique_words) <= 1)) {  # Allow small variations
    unique_words <- c(unique_words, word)
    word_probs <- c(word_probs, prob)
  }
}

# Create cleaned word-probability list
topwords_cleaned <- setNames(word_probs, unique_words)

# Print cleaned words
print(topwords_cleaned)

# Define a list of irrelevant words to remove
stopwords_custom <- c("doi", "yes", "one", "will", "per", "year","prices","estate","price")  # Add more if needed

# Remove unwanted characters
word_names <- gsub("[-–]", "", names(topwords_cleaned))  # Remove special characters
word_names <- gsub("[^a-zA-Z]", "", word_names)  # Remove any non-alphabetic characters

# Remove stopwords
word_names <- word_names[!word_names %in% stopwords_custom]

# Apply cleaned word names back to the probabilities
topwords_cleaned <- topwords_cleaned[names(topwords_cleaned) %in% word_names]
names(topwords_cleaned) <- word_names  # Update names

# Print cleaned results
print(topwords_cleaned)
```
## Step 6: Visualize the LDA Topics
``` r

# Plot Perplexity Scores
topic <- 6  # Select the topic to visualize
words <- posterior(lda_model)$terms[topic, ]  # Get term probabilities for the topic
topwords <- head(sort(words, decreasing = TRUE), n = 50)  # Get top 50 words
head(topwords)  # Print top words with probabilities

wordcloud(names(topwords), topwords)
wordcloud(names(topwords_cleaned), topwords_cleaned)
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
     doc.length = doc.length, term.frequency = term.freq)
serVis(json)
```
