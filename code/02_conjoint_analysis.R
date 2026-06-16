# =============================================================================
# Nutri-bento — Conjoint Analysis (Multinomial Logit, mlogit)
# STAT3613 Marketing Analytics, HKU
# -----------------------------------------------------------------------------
# Estimates part-worth utilities and preference shares for three menu factors:
#   Protein (ref = Beef), Grain (ref = White Rice), Vegetable (ref = Leafy Greens)
# Inputs: ../data/Proj3613.csv (protein + grain), ../data/vegetable.csv
# Run with the working directory set to the data/ folder, or edit the paths.
# =============================================================================

# Load the mlogit package
library(mlogit)

#Protein
# Read and prepare the data (your part is correct)
mydata <- read.table("data/Proj3613.csv", sep = ",", header = TRUE, stringsAsFactors = FALSE)

# Clean the data - remove any problematic rows and convert to factors
mydata <- mydata[mydata$Protein != "" & !is.na(mydata$Protein), ]

# Convert Protein to factor
mydata$Protein <- as.factor(mydata$Protein)

# Set the reference level for Protein
mydata$Protein <- relevel(mydata$Protein, ref = "Beef")

# For mlogit, we need to create a proper choice dataset
# Each row in your original data represents one choice occasion
# We need to reshape this to have all alternatives for each choice occasion

# Step 1: Create choice IDs and mark the chosen alternative
mydata$chid <- 1:nrow(mydata)  # Each row is a separate choice occasion
mydata$choice <- TRUE  # All current rows represent the chosen alternative

# Step 2: Get all possible protein alternatives
protein_alternatives <- levels(mydata$Protein)

# Step 3: Create a dataset with all alternatives for each choice occasion
choice_data <- data.frame()

for(i in 1:nrow(mydata)) {
  current_choice <- mydata[i, ]
  
  # Create a row for each possible protein alternative
  for(protein_alt in protein_alternatives) {
    new_row <- data.frame(
      chid = current_choice$chid,
      aid = protein_alt,
      chosen = ifelse(current_choice$Protein == protein_alt, 1, 0)
    )
    choice_data <- rbind(choice_data, new_row)
  }
}

# Step 4: Convert to mlogit format
mlogit_data <- mlogit.data(
  choice_data,
  choice = "chosen",
  shape = "long", 
  alt.var = "aid",
  chid.var = "chid"
)

# Step 5: Run the multinomial logit model
# This models the choice of protein
fit_part_a <- mlogit(formula = chosen ~ 1, data = mlogit_data, reflevel = "Beef")

# Summary of the model
summary(fit_part_a)

# Estimated coefficients
coefficients <- fit_part_a$coefficients

# Calculate all partworths (Beef is reference with partworth = 0)
all_partworths <- c(0, coefficients)
names(all_partworths) <- levels(mydata$Protein)

print("All Protein Partworths:")
print(all_partworths)

contrasts(mydata$Protein)

shares_X1 <- exp(all_partworths) / sum(exp(all_partworths))
shares_X1


#--------------------------------------------------------------------------------

#Grain
mydata <- read.table("data/Proj3613.csv", sep = ",", header = TRUE, stringsAsFactors = FALSE)

# Clean the data - remove any problematic rows and convert to factors
mydata <- mydata[mydata$Grain != "" & !is.na(mydata$Grain), ]

# Convert Grain to factor
mydata$Grain <- as.factor(mydata$Grain)

# Set the reference level for Grain (using "White Rice" as reference)
mydata$Grain <- relevel(mydata$Grain, ref = "White Rice")

# Check the contrasts for Grain
cat("Contrast matrix for Grain:\n")
print(contrasts(mydata$Grain))

# Check levels and frequencies
cat("\nGrain levels and frequencies:\n")
print(levels(mydata$Grain))
print(table(mydata$Grain))

# For mlogit, we need to create a proper choice dataset
# Each row in your original data represents one choice occasion
# We need to reshape this to have all alternatives for each choice occasion

# Step 1: Create choice IDs and mark the chosen alternative
mydata$chid <- 1:nrow(mydata)  # Each row is a separate choice occasion
mydata$choice <- TRUE  # All current rows represent the chosen alternative

# Step 2: Get all possible grain alternatives
grain_alternatives <- levels(mydata$Grain)

# Step 3: Create a dataset with all alternatives for each choice occasion
choice_data <- data.frame()

for(i in 1:nrow(mydata)) {
  current_choice <- mydata[i, ]
  
  # Create a row for each possible grain alternative
  for(grain_alt in grain_alternatives) {
    new_row <- data.frame(
      chid = current_choice$chid,
      aid = grain_alt,
      chosen = ifelse(current_choice$Grain == grain_alt, 1, 0)
    )
    choice_data <- rbind(choice_data, new_row)
  }
}

# Step 4: Convert to mlogit format
mlogit_data <- mlogit.data(
  choice_data,
  choice = "chosen",
  shape = "long", 
  alt.var = "aid",
  chid.var = "chid"
)

# Step 5: Run the multinomial logit model
# This models the choice of grain
fit_part_a <- mlogit(formula = chosen ~ 1, data = mlogit_data, reflevel = "White Rice")

# Summary of the model
summary(fit_part_a)

# Estimated coefficients
coefficients <- fit_part_a$coefficients

# Calculate all partworths (White Rice is reference with partworth = 0)
all_partworths <- c(0, coefficients)
names(all_partworths) <- levels(mydata$Grain)

cat("\nAll Grain Partworths:\n")
print(all_partworths)

# For mlogit, we need to create a proper choice dataset
# Each row in your original data represents one choice occasion
# We need to reshape this to have all alternatives for each choice occasion

# Step 1: Create choice IDs and mark the chosen alternative
mydata$chid <- 1:nrow(mydata)  # Each row is a separate choice occasion
mydata$choice <- TRUE  # All current rows represent the chosen alternative

# Step 2: Get all possible protein alternatives
Grain_alternatives <- levels(mydata$Grain)

# Step 3: Create a dataset with all alternatives for each choice occasion
choice_data <- data.frame()

for(i in 1:nrow(mydata)) {
  current_choice <- mydata[i, ]
  
  # Create a row for each possible protein alternative
  for(Grain_alt in Grain_alternatives) {
    new_row <- data.frame(
      chid = current_choice$chid,
      aid = Grain_alt,
      chosen = ifelse(current_choice$Grain == Grain_alt, 1, 0)
    )
    choice_data <- rbind(choice_data, new_row)
  }
}

# Step 4: Convert to mlogit format
mlogit_data <- mlogit.data(
  choice_data,
  choice = "chosen",
  shape = "long", 
  alt.var = "aid",
  chid.var = "chid"
)

# Step 5: Run the multinomial logit model
# This models the choice of protein
fit_part_b <- mlogit(formula = chosen ~ 1, data = mlogit_data, reflevel = "White Rice")

# Summary of the model
summary(fit_part_b)

# Estimated coefficients
coefficients_1 <- fit_part_b$coefficients

# Calculate all partworths (Beef is reference with partworth = 0)
all_partworths <- c(0, coefficients)
names(all_partworths) <- levels(mydata$Grain)

print("All Grain Partworths:")
print(all_partworths)

contrasts(mydata$Grain)

shares_X1 <- exp(all_partworths) / sum(exp(all_partworths))
shares_X1


#------------------------------------------------------------------------------
#vegetable
# Load the mlogit package
library(mlogit)

# Vegetable Analysis
# Read and prepare the data
mydata <- read.table("data/vegetable.csv", sep = ",", header = TRUE, stringsAsFactors = FALSE)


# Convert Vegetable to factor
mydata$Vegetable <- as.factor(mydata$Vegetable)

# Set the reference level for Vegetable (using "Leafy Greens" as reference)
mydata$Vegetable <- relevel(mydata$Vegetable, ref = "Leafy Greens")

# Check the contrasts for Vegetable
cat("Contrast matrix for Vegetable:\n")
print(contrasts(mydata$Vegetable))

# Check levels and frequencies
cat("\nVegetable levels and frequencies:\n")
print(levels(mydata$Vegetable))
print(table(mydata$Vegetable))

# For mlogit, we need to create a proper choice dataset
# Each row in your original data represents one choice occasion
# We need to reshape this to have all alternatives for each choice occasion

# Step 1: Create choice IDs and mark the chosen alternative
mydata$chid <- 1:nrow(mydata)  # Each row is a separate choice occasion
mydata$choice <- TRUE  # All current rows represent the chosen alternative

# Step 2: Get all possible vegetable alternatives
vegetable_alternatives <- levels(mydata$Vegetable)

# Step 3: Create a dataset with all alternatives for each choice occasion
choice_data <- data.frame()

for(i in 1:nrow(mydata)) {
  current_choice <- mydata[i, ]
  
  # Create a row for each possible vegetable alternative
  for(vegetable_alt in vegetable_alternatives) {
    new_row <- data.frame(
      chid = current_choice$chid,
      aid = vegetable_alt,
      chosen = ifelse(current_choice$Vegetable == vegetable_alt, 1, 0)
    )
    choice_data <- rbind(choice_data, new_row)
  }
}

# Step 4: Convert to mlogit format
mlogit_data <- mlogit.data(
  choice_data,
  choice = "chosen",
  shape = "long", 
  alt.var = "aid",
  chid.var = "chid"
)

# Step 5: Run the multinomial logit model
# This models the choice of vegetable categories
fit_part_a <- mlogit(formula = chosen ~ 1, data = mlogit_data, reflevel = "Leafy Greens")

# Summary of the model
summary(fit_part_a)

# Estimated coefficients
coefficients <- fit_part_a$coefficients

# Calculate all partworths (Leafy Greens is reference with partworth = 0)
all_partworths <- c(0, coefficients)
names(all_partworths) <- levels(mydata$Vegetable)

cat("\nAll Vegetable Partworths:\n")
print(all_partworths)

contrasts(mydata$Vegetable)

shares_X1 <- exp(all_partworths) / sum(exp(all_partworths))
shares_X1