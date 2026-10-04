# ==============================================================================
# File Name: feature_extraction.R
# Description: Functions for extracting EEG features across multiple domains
# Authors: Huu An - Hong Hien
# ==============================================================================

library(tidyverse)
library(moments)
library(seewave)
library(wavelets)
library(pracma)

#' 1. Extract Time Domain Features
#' @param signal Numeric vector of EEG signal (1 second epoch, 178 sampling points)
#' @return A tibble containing statistical features and waveform shape factors
extract_time_domain_features <- function(signal) {
  # Basic statistical properties
  mean_val <- mean(signal)
  std_val <- sd(signal)
  var_val <- var(signal)
  min_val <- min(signal)
  max_val <- max(signal)
  skew_val <- moments::skewness(signal)
  kurt_val <- moments::kurtosis(signal)
  rms_val <- sqrt(mean(signal^2))
  zero_crossings <- sum(diff(sign(signal)) != 0)
  
  # Peak absolute value
  abs_max <- max(abs(c(min_val, max_val)))
  
  # Waveform Factors
  # Crest factor: peak amplitude relative to RMS value
  crest_factor <- abs_max / rms_val
  # Margin factor: peak amplitude relative to variance
  margin_factor <- abs_max / var_val
  # Shape factor: RMS value relative to Mean Absolute Value (MAV)
  shape_factor <- rms_val / mean(abs(signal))
  # Impulse factor: peak amplitude relative to MAV
  impulse_factor <- abs_max / mean(abs(signal))
  
  tibble(
    mean = mean_val, std = std_val, var = var_val, min = min_val, max = max_val,
    skew = skew_val, kurtosis = kurt_val, rms = rms_val,
    zero_crossings = zero_crossings, abs_max = abs_max,
    crest_factor = crest_factor, margin_factor = margin_factor,
    shape_factor = shape_factor, impulse_factor = impulse_factor
  )
}

#' 2. Extract Frequency Domain Features
#' @param signal Numeric vector of EEG signal
#' @param fs Sampling frequency in Hz (default: 178)
#' @return A tibble containing band powers across standard EEG frequency bands
extract_frequency_domain_features <- function(signal, fs = 178) {
  # Compute Power Spectral Density (PSD)
  mean_spec_res <- seewave::meanspec(signal, f = fs, wl = length(signal), plot = FALSE)
  
  freqs <- mean_spec_res[, 1] * 1000 # Convert from kHz to Hz
  psd <- mean_spec_res[, 2]
  
  # Helper function to compute band power using trapezoidal integration
  bandpower <- function(psd, freqs, fmin, fmax) {
    idx <- freqs >= fmin & freqs <= fmax
    pracma::trapz(freqs[idx], psd[idx])
  }
  
  # Standard EEG spectral bands
  tibble(
    delta_power = bandpower(psd, freqs, 0.5, 4),
    theta_power = bandpower(psd, freqs, 4, 8),
    alpha_power = bandpower(psd, freqs, 8, 13),
    beta_power  = bandpower(psd, freqs, 13, 30),
    gamma_power = bandpower(psd, freqs, 30, fs / 2)
  )
}

#' 3. Extract Wavelet and Non-linear Features
#' @param signal Numeric vector of EEG signal
#' @return A tibble containing energy and statistical metrics across Wavelet decomposition levels
extract_wavelet_nonlinear_features <- function(signal) {
  # Ensure signal length is a power of 2 for DWT
  if (log2(length(signal)) %% 1 != 0) {
    new_len <- 2^floor(log2(length(signal)))
    signal_for_dwt <- signal[1:new_len]
  } else {
    signal_for_dwt <- signal
  }
  
  # Discrete Wavelet Transform using Daubechies-4 filter
  dwt_res <- wavelets::dwt(signal_for_dwt, filter = "d4", n.levels = 4)
  wavelet_coeffs <- c(dwt_res@W, list(dwt_res@V[[4]]))
  level_names <- paste0("level_", 1:length(wavelet_coeffs))
  
  all_features <- list()
  
  # Iterate across each coefficient level (detail and approximation)
  for (i in 1:length(wavelet_coeffs)) {
    coeffs <- wavelet_coeffs[[i]]
    level_name <- level_names[i]
    
    # Energy and statistical features
    all_features[[paste0(level_name, "_energy")]] <- sum(coeffs^2)
    all_features[[paste0(level_name, "_std")]]    <- sd(coeffs)
    all_features[[paste0(level_name, "_skew")]]   <- moments::skewness(coeffs)
    all_features[[paste0(level_name, "_kurt")]]   <- moments::kurtosis(coeffs)
  }
  
  return(as_tibble(all_features))
}
