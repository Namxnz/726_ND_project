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
lda_topics <- terms(lda_model, 10)  # Show top 10 words per topic
lda_topics

# Clean up unnnecessary words
clean_lda_topics <- lapply(lda_topics_df, function(words) {
  
  # Remove unwanted symbols like "-" and "–"
    words <- gsub("[-–]", "", words)
  
  # Convert words to lowercase
  words <- tolower(words)
  
  # Apply stemming (e.g., "prices" -> "price")
  words <- lemmatize_words(words)
  
  # Remove near-duplicates using fuzzy matching
  unique_words <- c()
  for (word in words) {
    if (!any(stringdist::stringdist(word, unique_words) <= 1)) {  # Adjust similarity threshold if needed
      unique_words <- c(unique_words, word)
    }
  }
  
  # Define custom stopwords to remove
  stopwords_custom <- c("doi", "yes", "one", "will", "per", "year", "prices", "estate", "price","ables", "able", "-")  # Add more if needed
  unique_words <- unique_words[!unique_words %in% stopwords_custom]
  
  return(unique_words)  # Return cleaned words for this topic
})

# Step 4: Ensure All Topics Have Equal Word Counts
max_words <- max(sapply(clean_lda_topics, length))  # Find the longest topic

clean_lda_topics_equal <- lapply(clean_lda_topics, function(words) {
  length(words) <- max_words  # Fill shorter topics with NA
  return(words)
})

# Step 5: Convert to Data Frame After Cleaning
lda_topics_cleaned <- as.data.frame(clean_lda_topics_equal)

# Print the cleaned topic words
print(lda_topics_cleaned)
```

## Step 5: Visualize the LDA Topics
``` r

# Plot wordcloud
## Convert to named vector for word cloud
word_freq <- setNames(topwords_cleaned, names(topwords_cleaned))

## Plot word cloud
wordcloud(names(word_freq), freq = word_freq, min.freq = 1, colors = brewer.pal(8, "Dark2"))

# bar plot
## Convert to data frame
df <- data.frame(
  word = names(topwords_cleaned),
  probability = topwords_cleaned
)

## Plot
ggplot(df, aes(x = reorder(word, probability), y = probability)) +
  geom_bar(stat = "identity", fill = "blue", alpha = 0.7) +
  coord_flip() +  # Flip to make text readable
  labs(title = "Top Words in LDA Topic", x = "Word", y = "Probability") +
  theme_minimal()
# heatmap
install.packages("reshape2")
library(reshape2)

# Convert topic-word matrix to long format
lda_matrix <- posterior(lda_model)$terms[, 1:10]  # Top 10 words per topic
lda_df <- melt(lda_matrix)

# Plot heatmap
ggplot(lda_df, aes(Var2, Var1, fill = value)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "blue") +
  labs(title = "LDA Topic-Word Heatmap", x = "Words", y = "Topics") +
  theme_minimal()

#ovarall
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
#  Result
