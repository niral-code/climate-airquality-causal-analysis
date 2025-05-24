# =============================================================
# DATA CLEANING – CAMAL 2004
# Purpose: Clean and impute missing values in meteorological and pollutant data
# =============================================================

# Load necessary packages
install.packages(c("VIM", "readxl", "zoo", "ggplot2", "writexl"), dependencies = TRUE)
library(readxl)
library(dplyr)
library(writexl)
library(zoo)
library(ggplot2)
library(VIM)

# Read dataset (replace this with your actual file path)
file_path <- "path/to/your/Camal_2004.xlsx"  # <-- Paste your dataset path here
df <- read_excel(file_path)

# Ensure column names are clean
colnames(df) <- trimws(colnames(df))

# Convert 'Date' to proper date format
df$Date <- as.Date(df$Date, origin = "1899-12-30")

# Identify numeric columns to clean
numeric_columns <- c("ElCamal_T", "ElCamal_RH", "ElCamal_WS", "ElCamal_WD", 
                     "ElCamal_P", "ElCamal_Rain", "ElCamal_CO", "ElCamal_NO2", 
                     "ElCamal_SO2", "ElCamal_O3", "ElCamal_PM2.5")
numeric_columns <- intersect(numeric_columns, names(df))

# View missing value count before cleaning
cat("Missing values before imputation:\n")
print(colSums(is.na(df[numeric_columns])))

# Visualize missing data pattern
aggr(df[numeric_columns], col = c("navyblue", "red"), numbers = TRUE,
     sortVars = TRUE, labels = names(df[numeric_columns]), cex.axis = 0.7,
     gap = 3, ylab = c("Missing data", "Pattern"))

# Trend of missing values over time
df$missing_count <- rowSums(is.na(df[numeric_columns]))
ggplot(df, aes(x = Date, y = missing_count)) + 
  geom_line(color = "red") + 
  labs(title = "Missing Values Over Time", x = "Date", y = "Missing Count") + 
  theme_minimal()

# Apply interpolation and fallback methods for missing value imputation
for (col in numeric_columns) {
  df[[col]] <- na.approx(df[[col]], na.rm = FALSE)                   # Linear interpolation
  df[[col]] <- na.locf(df[[col]], na.rm = FALSE)                     # Forward fill
  df[[col]] <- na.locf(df[[col]], fromLast = TRUE, na.rm = FALSE)   # Backward fill
  df[[col]][is.na(df[[col]])] <- mean(df[[col]], na.rm = TRUE)      # Mean impute (if needed)
  df[[col]][is.na(df[[col]])] <- median(df[[col]], na.rm = TRUE)    # Median impute (if still NA)
}

# View missing value count after cleaning
cat("Missing values after imputation:\n")
print(colSums(is.na(df[numeric_columns])))

# Save cleaned data (replace with your desired output path)
output_path <- "path/to/save/Cleaned_Camal_2004.xlsx"  # <-- Set your output path here
write_xlsx(df, output_path)
cat("Cleaned file saved to:", output_path, "\n")
