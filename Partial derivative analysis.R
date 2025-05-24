# Load necessary libraries
library(rEDM)
library(ggplot2)
library(readxl)

# Load the cleaned dataset (please update the file path accordingly)
my_data <- read_excel("C:/Users/niral/OneDrive/Desktop/Thesis/cleaned-dataset/Cleaned_Belisario_2024.xlsx")

# Rename columns for ease of use
colnames(my_data) <- c("Date", "Temp", "RH", "WS", "WD", "Pressure", 
                       "Solar", "Rain", "CO", "NO2", "SO2", "O3", "PM25")

# Step 1: Find the optimal embedding dimension (E) for RH
rho_E <- EmbedDimension(
  dataFrame = my_data,
  columns = "RH", 
  target = "RH",
  lib = "1 400", 
  pred = "1 400",
  maxE = 10
)

# Select best embedding dimension (E) based on highest rho
best_E <- rho_E$E[which.max(rho_E$rho)]

# Step 2: Run S-Map to estimate dynamic interaction strength from PM2.5 to RH
smap_pm_rh <- SMap(
  dataFrame = my_data,
  lib = "1 400", 
  pred = "1 400",
  E = best_E,
  theta = 1,
  columns = "PM25",
  target = "RH",
  embedded = TRUE
)

# Step 3: Run S-Map to estimate dynamic interaction strength from RH to PM2.5
smap_rh_pm <- SMap(
  dataFrame = my_data,
  lib = "1 400", 
  pred = "1 400",
  E = best_E,
  theta = 1,
  columns = "RH",
  target = "PM25",
  embedded = TRUE
)

# Step 4: Extract S-map coefficients representing partial derivatives (interaction strengths)
col_pm_rh <- grep("PM25", colnames(smap_pm_rh$coefficients), value = TRUE)[1]
col_rh_pm <- grep("RH", colnames(smap_rh_pm$coefficients), value = TRUE)[1]
coeff_pm_rh <- smap_pm_rh$coefficients[[col_pm_rh]]
coeff_rh_pm <- smap_rh_pm$coefficients[[col_rh_pm]]

# Step 5: Equalize lengths of coefficient vectors and prepare data for plotting
len <- min(length(coeff_pm_rh), length(coeff_rh_pm))
plot_data <- data.frame(
  Time = 1:len,
  PM25_to_RH = coeff_pm_rh[1:len],
  RH_to_PM25 = coeff_rh_pm[1:len]
)

# Step 6: Plot dynamic interaction strength over time
p <- ggplot(plot_data, aes(x = Time)) +
  geom_line(aes(y = PM25_to_RH, color = "PM2.5 → RH"), size = 1.2, alpha = 0.95) +
  geom_line(aes(y = RH_to_PM25, color = "RH → PM2.5"), size = 1.2, alpha = 0.95) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray40") +
  scale_color_manual(
    name = " ",
    values = c("PM2.5 → RH" = "#1f78b4", "RH → PM2.5" = "#e31a1c")
  ) +
  labs(
    title = "Dynamic Interaction Strength Between PM2.5 and RH (Belisario_2024)",
    x = "Time (Observations)",
    y = "Interaction Strength (S-map Coefficient)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.title = element_text(face = "bold"),
    legend.position = "top",
    panel.background = element_rect(fill = "white"),
    plot.background = element_rect(fill = "white")
  )

# Step 7: Save the plot as a high-quality PNG file (update path as needed)
ggsave("C:/Users/niral/OneDrive/Desktop/Thesis Results/PD/Belisario_2024_interaction_plot.png", 
       plot = p, width = 10, height = 6, dpi = 300)
