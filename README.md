# climate-airquality-causal-analysis
R code for data cleaning, Convergent Cross Mapping (CCM), surrogate significance testing, and correlation analysis to investigate the causal impact of climate variables on air quality metrics. Developed as part of Master's thesis research on "Climate Change Affecting Air Quality".

## Project Overview

This repository contains all R scripts developed during the final phase of the Master's thesis research titled **"Climate Change Affecting Air Quality"**. The aim is to investigate how climate indicators (such as temperature, humidity, wind) influence air pollutant concentrations (like PM2.5, O3, NO2) using causal inference techniques.

## Contents

- **1_data_cleaning.R** – Cleans and imputes missing values in raw environmental datasets.
- **2_ccm_analysis.R** – Performs Convergent Cross Mapping (CCM) to identify causal links between climate variables and pollutants.
- **3_surrogate_test.R** – Conducts surrogate significance testing to validate causal relationships.
- **4_partial_derivative_analysis.R** – (If applicable) Quantifies the magnitude of climate impact on pollutant levels.
- **5_correlation_analysis.R** – Complements CCM findings using classical statistical correlation.

## How to Use

1. Clone the repository.
2. Follow the step-by-step guide in each script. Each file includes detailed comments.
3. Ensure required libraries are installed (e.g., `rEDM`, `readxl`, `VIM`, `ggplot2`, etc.).
4. Input your dataset and adjust file paths accordingly.

## Notes

- Dataset-specific assumptions and variable names (e.g., `Carapungo_PM2.5`, `ElCamal_RH`) must be updated if applying this to other regions or periods.
- Developed for academic use; reproducibility may require minor adaptations depending on dataset quality and format.
