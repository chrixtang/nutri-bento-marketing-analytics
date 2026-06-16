# =============================================================================
# Nutri-bento — Factor Analysis (PCA), Customer Segmentation & Regression
# STAT3613 Marketing Analytics, HKU
# -----------------------------------------------------------------------------
# This script reproduces the health-attitude PCA, the K-means segmentation,
# and the willingness-to-pay / purchase-frequency regressions described in
# the report (sections 3.1, 3.2, 3.4).
#
# NOTE: The raw survey file ("Eating habits 2.csv") is NOT included in this
# repo because it contains personal respondent data (income, occupation, etc.).
# Point SURVEY_PATH below at your own copy to run end to end.
# =============================================================================

library(tidyverse)
library(cluster)
library(factoextra)
library(corrplot)
library(car)        # VIF for the regression diagnostics

theme_set(theme_minimal(base_size = 12))

SURVEY_PATH <- "data/Eating habits 2.csv"   # <-- not committed; supply your own
set.seed(42)

# -----------------------------------------------------------------------------
# 1. Load + identify the 7 health-attitude Likert items (1-5 scale)
# -----------------------------------------------------------------------------
df <- read_csv(SURVEY_PATH)

health_patterns <- c("nutritional", "organic", "calorie", "protein",
                     "sodium", "investment", "whole grain", "label")

health_cols <- colnames(df)[
  map_lgl(colnames(df), ~ any(str_detect(tolower(.x), health_patterns)))
]
# keep only the numeric Likert columns
health_numeric <- health_cols[map_lgl(health_cols, ~ is.numeric(df[[.x]]))]

cat("Found", length(health_numeric), "health-attitude items\n")

# -----------------------------------------------------------------------------
# 2. Light cleaning of free-text spending fields (e.g. "$60", "HKD 60", "60.")
# -----------------------------------------------------------------------------
clean_money <- function(value) {
  if (is.na(value) || value == "") return(NA_real_)
  cleaned <- as.character(value) %>%
    str_replace_all("\\$|HKD|,|\\?|\\s+", "") %>%
    str_extract("[0-9]+\\.?[0-9]*")
  if (is.na(cleaned) || cleaned == "") return(NA_real_)
  as.numeric(cleaned)
}

df_clean <- df
meal_col <- "What is your average spending on each meal? (HKD)"
df_clean$Meal_Spending <- map_dbl(df_clean[[meal_col]], clean_money)

# -----------------------------------------------------------------------------
# 3. Factor Analysis via PCA on the standardized health-attitude items
# -----------------------------------------------------------------------------
pca_data   <- df_clean %>% select(all_of(health_numeric)) %>% na.omit()
pca_scaled <- scale(pca_data)
pca        <- prcomp(pca_scaled)

var_ratio  <- pca$sdev^2 / sum(pca$sdev^2)
cum_var    <- cumsum(var_ratio)

cat("\nExplained variance (first 3 PCs):\n")
print(round(var_ratio[1:3], 3))          # ~0.608, 0.104, 0.086 -> 79.7% cumulative

# Scree plot
scree <- tibble(PC = seq_along(var_ratio),
                Individual = var_ratio,
                Cumulative = cum_var)
ggplot(scree, aes(PC)) +
  geom_line(aes(y = Individual, colour = "Individual")) +
  geom_point(aes(y = Individual, colour = "Individual")) +
  geom_line(aes(y = Cumulative, colour = "Cumulative")) +
  geom_point(aes(y = Cumulative, colour = "Cumulative")) +
  geom_hline(yintercept = 0.70, linetype = "dashed") +
  labs(title = "PCA Scree Plot", x = "Principal Component",
       y = "Explained Variance Ratio", colour = NULL)

# Component loadings (interpretation of the 3 factors)
loadings <- as.data.frame(pca$rotation[, 1:3])
print(round(loadings, 3))

# -----------------------------------------------------------------------------
# 4. K-means segmentation on the first 3 PC scores
# -----------------------------------------------------------------------------
scores <- as_tibble(pca$x[, 1:3]) %>% rename(PC1 = PC1, PC2 = PC2, PC3 = PC3)

# Elbow method
wcss <- map_dbl(1:10, ~ kmeans(scores, centers = .x, nstart = 25)$tot.withinss)
ggplot(tibble(k = 1:10, wcss = wcss), aes(k, wcss)) +
  geom_line() + geom_point() +
  scale_x_continuous(breaks = 1:10) +
  labs(title = "Elbow Method", x = "Number of Clusters", y = "WCSS")

km <- kmeans(scores, centers = 4, nstart = 25)

# Attach PC scores AND cluster back onto the cleaned rows used for PCA
df_seg <- df_clean[rownames(pca_data), ] %>%
  mutate(PC1 = scores$PC1, PC2 = scores$PC2, PC3 = scores$PC3,
         Cluster = factor(km$cluster))

# Cluster profiles  (fixes the original "object 'PC1' not found" bug:
# PC scores are now joined onto df_seg before summarising)
cluster_profiles <- df_seg %>%
  group_by(Cluster) %>%
  summarise(
    n            = n(),
    Percent      = round(n() / nrow(df_seg) * 100, 1),
    PC1_Mean     = round(mean(PC1, na.rm = TRUE), 2),
    PC2_Mean     = round(mean(PC2, na.rm = TRUE), 2),
    PC3_Mean     = round(mean(PC3, na.rm = TRUE), 2),
    Meal_Spend   = round(mean(Meal_Spending, na.rm = TRUE), 1),
    .groups = "drop"
  )
print(cluster_profiles)

# -----------------------------------------------------------------------------
# 5. Regression: Willingness to Pay (WTP) and Monthly Purchase Frequency (MPF)
# -----------------------------------------------------------------------------
# Assumes df_seg also carries numeric WTP, Income_Num, Age and the PC1 factor
# score (Health_Consciousness_Factor). Column names below match the report's
# model specification (section 3.4); adjust to your survey's headers as needed.
#
# model_wtp <- lm(WTP ~ Health_Consciousness_Factor + Age + Income_Num +
#                       Cluster, data = df_seg)
# summary(model_wtp)          # R^2 ~ 0.31, F = 5.60, p = 0.00025
# vif(model_wtp)              # all < 3.0 -> no multicollinearity
#
# model_mpf <- lm(MPF ~ Health_Consciousness_Factor + Age + Income_Num +
#                       Cluster, data = df_seg)
# summary(model_mpf)          # R^2 ~ 0.15, F = 2.25, p = 0.06
# -----------------------------------------------------------------------------
