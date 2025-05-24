# ============================
# Step 3: Surrogate Test
# Purpose: Test if the causality detected by CCM is statistically significant
# ============================

# Load necessary libraries
library(rEDM)
library(readxl)

# ----------------------------
# 1. Load cleaned dataset
# ----------------------------
# Replace this with the correct path to your cleaned dataset
data <- read_excel("your_path_here/Cleaned_Carapungo_2024.xlsx")  # <-- Paste your file path here
data$Date <- as.Date(data$Date)
data <- data[order(data$Date), ]

# ----------------------------
# 2. Set variables and parameters
# ----------------------------
driver_var <- "Carapungo_PM2.5"    # Potential causal variable
target_var <- "Carapungo_RH"       # Affected variable
E <- 6                             # Embedding dimension
num_surr <- 1000                   # Number of surrogate series to generate

# ----------------------------
# 3. Generate surrogate time series (Ebisuzaki method preserves power spectrum)
# ----------------------------
surrogates <- make_surrogate_data(data[[driver_var]], method = "ebisuzaki", num_surr = num_surr)

# ----------------------------
# 4. Run CCM for each surrogate
# ----------------------------
surrogate_rhos <- numeric(num_surr)

for (i in 1:num_surr) {
  temp_data <- data
  temp_data[[driver_var]] <- surrogates[, i]
  
  result <- CCM(temp_data, columns = driver_var, target = target_var,
                libSizes = "10 500 10", Tp = 0, E = E, sample = 100)
  
  rho_vals <- result[[paste(driver_var, target_var, sep = ":")]]
  surrogate_rhos[i] <- mean(rho_vals, na.rm = TRUE)
}

# ----------------------------
# 5. Run CCM on actual (non-surrogate) data
# ----------------------------
real_result <- CCM(data, columns = driver_var, target = target_var,
                   libSizes = "10 500 10", Tp = 0, E = E, sample = 100)

real_rho <- mean(real_result[[paste(driver_var, target_var, sep = ":")]], na.rm = TRUE)

# ----------------------------
# 6. Plot the null distribution and observed rho
# ----------------------------
hist(surrogate_rhos, breaks = 40, main = "Surrogate Test for Causality", 
     xlab = "Mean Prediction Skill (ρ)", col = "lightgray", border = "white")
abline(v = real_rho, col = "red", lwd = 2)
legend("topright", legend = c("Observed ρ"), col = "red", lwd = 2)
