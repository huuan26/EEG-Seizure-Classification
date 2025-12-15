# ==============================================================================
# Tên file: model_utils.R
# Chức năng: Các hàm hỗ trợ huấn luyện, so sánh và trực quan hóa mô hình
# Nhóm thực hiện: Hữu Ân - Hồng Hiên
# ==============================================================================

library(tidyverse)
library(caret)
library(patchwork)

#' 1. Vẽ biểu đồ so sánh hiệu năng các thuật toán (Resamples)
#' @param resamples_obj Đối tượng trả về từ hàm caret::resamples()
#' @param metric Chỉ số muốn so sánh (mặc định là "ROC")
#' @return Một danh sách chứa biểu đồ Density và Dotplot
plot_model_comparison <- function(resamples_obj, metric = "ROC") {
  
  # Biểu đồ phân bố (Density plot) để xem độ ổn định
  p1 <- densityplot(resamples_obj, metric = metric, auto.key = TRUE,
                    main = paste("Phân bố", metric, "của các thuật toán"))
  
  # Biểu đồ điểm kèm khoảng tin cậy (Dotplot)
  p2 <- dotplot(resamples_obj, metric = metric,
                main = paste("So sánh", metric, "trung bình"))
  
  return(list(density = p1, dotplot = p2))
}

#' 2. Trích xuất bảng tóm tắt hiệu năng từ Confusion Matrix
#' @param cm_list Danh sách các đối tượng confusionMatrix
#' @param model_names Vector tên các mô hình tương ứng
#' @return Một tibble tổng hợp các chỉ số Accuracy, Sensitivity, Specificity, F1
summarize_test_performance <- function(cm_list, model_names) {
  
  results <- map2_dfr(cm_list, model_names, function(cm, name) {
    tibble(
      Model = name,
      Accuracy = cm$overall['Accuracy'],
      Sensitivity = cm$byClass['Sensitivity'],
      Specificity = cm$byClass['Specificity'],
      F1 = cm$byClass['F1']
    )
  })
  
  return(results)
}

#' 3. Vẽ biểu đồ Confusion Matrix trực quan
#' @param cm Đối tượng confusionMatrix từ caret
#' @param title Tiêu đề biểu đồ
#' @return Một biểu đồ ggplot2 hiển thị ma trận nhầm lẫn
plot_confusion_matrix <- function(cm, title = "Confusion Matrix") {
  
  plt <- as.data.frame(cm$table)
  plt$Prediction <- factor(plt$Prediction, levels=rev(levels(plt$Prediction)))
  
  ggplot(plt, aes(Reference, Prediction, fill= Prediction)) +
    geom_tile(aes(fill = Freq), color = "white") +
    geom_text(aes(label = sprintf("%d", Freq)), vjust = 1) +
    scale_fill_gradient(low = "white", high = "#004085") +
    labs(title = title, x = "Thực tế", y = "Dự đoán") +
    theme_minimal() +
    theme(legend.position = "none")
}

#' 4. Hàm hỗ trợ tạo Pipeline (Recipe) chuẩn cho dự án
#' @param train_data Data frame huấn luyện
#' @param use_pca Logic có sử dụng PCA hay không (TRUE/FALSE)
#' @param n_comp Số lượng thành phần chính nếu dùng PCA
#' @return Một đối tượng recipe đã đóng gói SMOTE và Scaling
create_eeg_recipe <- function(train_data, use_pca = FALSE, n_comp = 12) {
  
  rec <- recipe(y ~ ., data = train_data) %>%
    step_center(all_predictors()) %>%
    step_scale(all_predictors()) %>%
    step_smote(y, over_ratio = 1, seed = 123) # Xử lý mất cân bằng
  
  if (use_pca) {
    rec <- rec %>% step_pca(all_predictors(), num_comp = n_comp) # Giảm chiều PCA
  }
  
  return(rec)
}