# Automated Epileptic Seizure Detection from Short-Term EEG Signals

## Introduction
This project focuses on developing an automated machine learning system to recognize **epileptic seizures** from short-term **electroencephalogram (EEG)** signal segments. By employing classification algorithms and dimensionality reduction techniques, our objective is to construct an accurate and computationally efficient model to assist medical professionals in rapid, objective epilepsy diagnosis and patient monitoring.

---

## Problem Statement and Research Objectives
Manual visual inspection of multi-channel EEG recordings is time-consuming, labor-intensive, and inherently subjective. This research addresses these challenges through the following key questions:
* **Feature Discriminability:** Do features extracted across time, frequency, and wavelet domains possess sufficient discriminative power to reliably distinguish between **seizure** and **non-seizure** states from short EEG epochs?
* **Dimensionality Reduction Impact:** How do dimensionality reduction techniques such as **Principal Component Analysis (PCA)** affect the trade-off between classification accuracy and computational complexity?
* **Model Optimization:** Which classification model provides the optimal balance of sensitivity, specificity, and generalization stability for automated seizure detection?

---

## Dataset
- **Source:** [Epileptic Seizure Recognition Dataset on Kaggle](https://www.kaggle.com/datasets/yasserhessein/epileptic-seizure-recognition/data)
- **Origin:** Curated from the benchmark database by Andrzejak et al. (2001), comprising EEG recordings from healthy volunteers and epilepsy patients across various conditions.
- **Structure:** The `Epileptic Seizure Recognition.csv` file contains **11,500 samples** (rows):
  - Each sample represents a **1-second** EEG segment (178 discrete sampling points at ~178 Hz).
  - **178 numerical feature columns** (`X1` to `X178`) representing voltage values ($\mu\text{V}$).
  - **1 target column** (`y`), originally categorized into 5 classes (1 to 5), transformed into a binary classification task:
    - **Class 1 (Seizure):** EEG activity recorded during epileptic seizure activity (ictal state, original label `y = 1`).
    - **Class 0 (Non-Seizure):** EEG activity from all other states including tumor-free/tumor regions and normal open/closed-eye recordings (original labels `y = 2, 3, 4, 5`).

---

## Methodology
The research pipeline is organized into four main stages:

1. **Data Preprocessing & Balancing:**
   - Conversion of multi-class labels into a binary formulation (Seizure vs. Non-Seizure).
   - Addressing severe class imbalance (80% Non-Seizure vs. 20% Seizure) using **SMOTE** (Synthetic Minority Over-sampling Technique) on the training set.
2. **Feature Engineering:**
   - **Time Domain:** Mean, standard deviation, variance, min, max, skewness, kurtosis, root mean square (RMS), zero crossings, crest factor, margin factor, shape factor, and impulse factor.
   - **Frequency Domain:** Power Spectral Density (PSD) using Welch-type estimation, band powers for Delta (0.5–4 Hz), Theta (4–8 Hz), Alpha (8–13 Hz), Beta (13–30 Hz), and Gamma (30–89 Hz).
   - **Wavelet & Non-linear Domain:** Discrete Wavelet Transform (DWT) decomposition via Daubechies-4 (`db4`) filters across 4 levels, extracting energy, standard deviation, skewness, and kurtosis of wavelet coefficients.
3. **Exploratory Data Analysis & Dimensionality Reduction:**
   - **Multivariate Statistics:** KMO & Bartlett tests, Factor Analysis (FA), and Multivariate Analysis of Variance (MANOVA).
   - **Dimensionality Reduction:** Scree plot and cumulative variance analysis using Principal Component Analysis (PCA).
   - **Non-linear Manifold Learning:** t-SNE and UMAP visualizations demonstrating class separability in reduced spaces.
4. **Model Training & Evaluation:**
   - 10-fold cross-validation comparing Linear Discriminant Analysis (LDA), Support Vector Machines with Radial Basis Function kernel (SVM-RBF), and Random Forest (RF).
   - Rigorous evaluation on a held-out test set (20%) assessing Accuracy, Sensitivity (Recall), Specificity, and F1-score.

---

## Project Structure
```text
EEG-Seizure-Classification/
├── data/
│   ├── raw/                 # Raw dataset (Epileptic Seizure Recognition.csv)
│   └── processed/           # Extracted feature sets (EEG_Features_Extracted.csv)
├── notebooks/
│   ├── 01_feature_engineering.Rmd       # Feature extraction implementation & visualizations
│   ├── 02_eda_and_dim_reduction.Rmd     # Statistical tests, PCA, FA, t-SNE, and UMAP
│   └── 03_modeling_and_evaluation.Rmd   # SMOTE, model training, cross-validation & testing
├── reports/
│   └── final_report.html                # Compiled comprehensive report
├── src/
│   ├── feature_extraction.R             # Reusable signal processing & feature functions
│   └── model_utils.R                    # Recipe construction, metric reporting & plotting
├── requirements.txt                     # List of required R packages
└── README.md                            # Project documentation
```

---

## Installation & Setup

### Prerequisites
- **R (>= 4.0.0)** and **RStudio** (recommended)

### Installing Required Packages
Install the necessary R dependencies by running:
```r
packages <- c(
  "tidyverse", "moments", "seewave", "wavelets", "TSEntropies",
  "caret", "themis", "recipes", "randomForest", "e1071",
  "patchwork", "pracma", "pROC", "Rtsne", "MASS",
  "psych", "uwot", "biotools", "mvnormtest", "factoextra",
  "scales", "tidytext", "knitr", "rmarkdown"
)

install.packages(packages)
```

---

## Key Results Summary
- **SVM-Full (All Features):** Achieved **98.87% Accuracy**, **97.17% Sensitivity**, and **99.29% Specificity** on the independent test set.
- **SVM-12PCA (Dimensionality Reduced):** Retained **97.87% Accuracy** and **95.43% Sensitivity** while reducing dimensionality from 39 features down to 12 principal components, offering high computational efficiency suitable for embedded or real-time clinical monitoring.
