# =============================================================
# CCM CAUSALITY ANALYSIS – CARAPUNGO 2005
# Purpose: Apply Convergent Cross Mapping to detect causal influence
# =============================================================

# Install required packages (only if not already installed)
if (!require("devtools")) install.packages("devtools")
if (!require("rEDM")) devtools::install_github("SugiharaLab/rEDM", force = TRUE)
if (!require("readxl")) install.packages("readxl")
if (!require("parallel")) install.packages("parallel")

library(devtools)
library(rEDM)
library(readxl)
library(parallel)

# Load dataset (replace with your cleaned data path)
data <- read_excel("path/to/your/Cleaned_Carapungo_2005.xlsx")  # <-- Paste your dataset path here

# Ensure 'Date' is a date and data is time-ordered
data$Date <- as.Date(data$Date)
data <- data[order(data$Date), ]

# Define variables for CCM
met <- "Carapungo_RH"                 # Meteorological variable (e.g., Relative Humidity)
pollutants <- c("Carapungo_PM2.5")    # List of target pollutants
E <- 6                                # Embedding dimension
libSize <- "10 500 10"                # Library size range
sample_size <- 100                    # Number of samples
supports_threads <- "numThreads" %in% names(formals(CCM))

# Perform CCM for each pollutant
for (poll in pollutants) {
  cat("Running CCM:", met, "→", poll, "\n")
  
  ccm_out <- if (supports_threads) {
    CCM(dataFrame = data, columns = met, target = poll,
        libSizes = libSize, Tp = 0, E = E, sample = sample_size,
        numThreads = detectCores() - 1)
  } else {
    CCM(dataFrame = data, columns = met, target = poll,
        libSizes = libSize, Tp = 0, E = E, sample = sample_size)
  }
  
  forward <- ccm_out[[paste(met, poll, sep = ":")]]
  reverse <- ccm_out[[paste(poll, met, sep = ":")]]
  lib_sizes <- ccm_out$LibSize
  
  valid_fwd <- !is.na(forward)
  valid_rev <- !is.na(reverse)
  
  # Plot only if valid data is available
  if (sum(valid_fwd) > 1 & sum(valid_rev) > 1) {
    y_min <- min(c(forward, reverse), na.rm = TRUE)
    y_max <- max(c(forward, reverse), na.rm = TRUE)
    
    # Save plot (set desired output file name)
    filename <- paste0("path/to/save/CCM_", met, "_", poll, ".png")  # <-- Output image path
    png(filename, width = 1000, height = 500, res = 120)
    plot(lib_sizes[valid_fwd], forward[valid_fwd], type = "l", col = "blue", lwd = 3,
         xlab = "Library Size", ylab = "Prediction Skill (ρ)",
         main = paste(met, "→", poll), ylim = c(y_min, y_max))
    lines(lib_sizes[valid_rev], reverse[valid_rev], col = "red", lwd = 3)
    legend("bottomright", legend = c(paste(met, "→", poll), paste(poll, "→", met)),
           col = c("blue", "red"), lty = 1, lwd = 3)
    dev.off()
    
    cat("Plot saved:", filename, "\n")
  } else {
    cat("Not enough valid data to generate plot for:", met, "↔", poll, "\n")
  }
}
