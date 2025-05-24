# Load Required Packages
install_if_missing <- function(pkg){
  if (!require(pkg, character.only = TRUE)) install.packages(pkg, dependencies = TRUE)
  library(pkg, character.only = TRUE)
}

packages <- c("readxl", "ggplot2", "GGally", "dplyr", "tidyr", "ggpubr", "corrplot")
lapply(packages, install_if_missing)

#  Load Datasets
b_2004 <- read_excel("C:/Users/niral/OneDrive/Desktop/Thesis/cleaned-dataset/Cleaned_Belisario_2004.xlsx")
b_2024 <- read_excel("C:/Users/niral/OneDrive/Desktop/Thesis/cleaned-dataset/Cleaned_Belisario_2024.xlsx")
c_2005 <- read_excel("C:/Users/niral/OneDrive/Desktop/Thesis/cleaned-dataset/Cleaned_Cotocollao_2005.xlsx")
c_2024 <- read_excel("C:/Users/niral/OneDrive/Desktop/Thesis/cleaned-dataset/Cleaned_Cotocollao_2024.xlsx")

# Helper Function: Correlation Plot between RH and PM2.5
cor_plot <- function(data, location, year) {
  data_clean <- data %>%
    select(RH = contains("RH"), PM2.5 = contains("PM2.5")) %>%
    drop_na()
  
  cor_val <- cor(data_clean$RH, data_clean$PM2.5, method = "pearson")  # or use method = "spearman"
  
  p <- ggplot(data_clean, aes(x = RH, y = PM2.5)) +
    geom_point(alpha = 0.5, color = "darkgreen") +
    geom_smooth(method = "lm", se = FALSE, color = "blue") +
    labs(
      title = paste0(location, " ", year, " (r = ", round(cor_val, 2), ")"),
      x = "Relative Humidity (RH)",
      y = "PM2.5"
    ) +
    theme_minimal()
  
  return(p)
}

# Generate Individual Plots
p1 <- cor_plot(b_2004, "Belisario", 2004)
p2 <- cor_plot(b_2024, "Belisario", 2024)
p3 <- cor_plot(c_2005, "Cotocollao", 2005)
p4 <- cor_plot(c_2024, "Cotocollao", 2024)

#  Arrange in Grid
ggarrange(p1, p2, p3, p4, ncol = 2, nrow = 2)
 
