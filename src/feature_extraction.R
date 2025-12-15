# ==============================================================================
# Tên file: feature_extraction.R
# Chức năng: Chứa các hàm trích xuất đặc trưng EEG từ các miền phân tích khác nhau
# Nhóm thực hiện: Hữu Ân - Hồng Hiên
# ==============================================================================

library(tidyverse)
library(moments)
library(seewave)
library(wavelets)
library(pracma)

#' 1. Trích xuất đặc trưng Miền Thời gian (Time Domain)
#' @param signal Vector tín hiệu EEG (1 giây, 178 điểm)
#' @return Một tibble chứa các đặc trưng thống kê và các hệ số hình dạng
extract_time_domain_features <- function(signal) {
  # Các thống kê cơ bản
  mean_val <- mean(signal)
  std_val <- sd(signal)
  var_val <- var(signal)
  min_val <- min(signal)
  max_val <- max(signal)
  skew_val <- moments::skewness(signal)
  kurt_val <- moments::kurtosis(signal)
  rms_val <- sqrt(mean(signal^2))
  zero_crossings <- sum(diff(sign(signal)) != 0)
  
  # Giá trị tuyệt đối lớn nhất
  abs_max <- max(abs(c(min_val, max_val)))
  
  # Các hệ số (Factors)
  # Crest factor: tỷ lệ đỉnh trên giá trị RMS
  crest_factor <- abs_max / rms_val
  # Margin factor: tỷ lệ đỉnh trên phương sai
  margin_factor <- abs_max / var_val
  # Shape factor: tỷ lệ RMS trên Giá trị Tuyệt đối Trung bình (MAV)
  shape_factor <- rms_val / mean(abs(signal))
  # Impulse factor: tỷ lệ đỉnh trên MAV
  impulse_factor <- abs_max / mean(abs(signal))
  
  tibble(
    mean = mean_val, std = std_val, var = var_val, min = min_val, max = max_val,
    skew = skew_val, kurtosis = kurt_val, rms = rms_val,
    zero_crossings = zero_crossings, abs_max = abs_max,
    crest_factor = crest_factor, margin_factor = margin_factor,
    shape_factor = shape_factor, impulse_factor = impulse_factor
  )
}

#' 2. Trích xuất đặc trưng Miền Tần số (Frequency Domain)
#' @param signal Vector tín hiệu EEG
#' @param fs Tần số lấy mẫu (mặc định 178Hz)
#' @return Một tibble chứa năng lượng các dải tần số EEG điển hình
extract_frequency_domain_features <- function(signal, fs = 178) {
  # Tính toán mật độ phổ công suất (PSD)
  mean_spec_res <- seewave::meanspec(signal, f = fs, wl = length(signal), plot = FALSE)
  
  freqs <- mean_spec_res[, 1] * 1000 # Chuyển từ kHz sang Hz
  psd <- mean_spec_res[, 2]
  
  # Hàm phụ tính công suất dải tần bằng quy tắc hình thang
  bandpower <- function(psd, freqs, fmin, fmax) {
    idx <- freqs >= fmin & freqs <= fmax
    pracma::trapz(freqs[idx], psd[idx])
  }
  
  # Các dải công suất EEG điển hình
  tibble(
    delta_power = bandpower(psd, freqs, 0.5, 4),
    theta_power = bandpower(psd, freqs, 4, 8),
    alpha_power = bandpower(psd, freqs, 8, 13),
    beta_power  = bandpower(psd, freqs, 13, 30),
    gamma_power = bandpower(psd, freqs, 30, fs / 2)
  )
}

#' 3. Trích xuất đặc trưng Wavelet và Phi tuyến
#' @param signal Vector tín hiệu EEG
#' @return Một tibble chứa năng lượng và thống kê các mức phân rã Wavelet
extract_wavelet_nonlinear_features <- function(signal) {
  # Đảm bảo độ dài tín hiệu là lũy thừa của 2 để dùng DWT
  if (log2(length(signal)) %% 1 != 0) {
    new_len <- 2^floor(log2(length(signal)))
    signal_for_dwt <- signal[1:new_len]
  } else {
    signal_for_dwt <- signal
  }
  
  # Biến đổi Wavelet Rời rạc với bộ lọc Daubechies-4
  dwt_res <- wavelets::dwt(signal_for_dwt, filter = "d4", n.levels = 4)
  wavelet_coeffs <- c(dwt_res@W, list(dwt_res@V[[4]]))
  level_names <- paste0("level_", 1:length(wavelet_coeffs))
  
  all_features <- list()
  
  # Lặp qua từng mức hệ số (chi tiết và xấp xỉ)
  for (i in 1:length(wavelet_coeffs)) {
    coeffs <- wavelet_coeffs[[i]]
    level_name <- level_names[i]
    
    # Đặc trưng năng lượng và thống kê
    all_features[[paste0(level_name, "_energy")]] <- sum(coeffs^2)
    all_features[[paste0(level_name, "_std")]]    <- sd(coeffs)
    all_features[[paste0(level_name, "_skew")]]   <- moments::skewness(coeffs)
    all_features[[paste0(level_name, "_kurt")]]   <- moments::kurtosis(coeffs)
  }
  
  return(as_tibble(all_features))
}
