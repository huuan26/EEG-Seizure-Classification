# ==============================================================================
# File Name: model_utils.R
# Description: Helper functions for model training, comparison, and visualization
# Authors: Huu An - Hong Hien
# ==============================================================================

library(tidyverse)
library(caret)
library(patchwork)

#' 1. Plot Algorithm Performance Comparison (Resamples)
#' @param resamples_obj Object returned from caret::resamples()
#' @param metric Metric to compare (default: "ROC")
#' @return A list containing Density and Dot plots
plot_model_comparison <- function(resamples_obj, metric = "ROC") {
  
  # Density plot to assess metric distribution and stability
  p1 <- densityplot(resamples_obj, metric = metric, auto.key = TRUE,
                    main = paste(metric, "Distribution Across Algorithms"))
  
  # Dot plot showing mean metric with confidence intervals
  p2 <- dotplot(resamples_obj, metric = metric,
                main = paste("Average", metric, "Comparison"))
  
  return(list(density = p1, dotplot = p2))
}

#' 2. Extract Performance Summary Table from Confusion Matrix
#' @param cm_list List of confusionMatrix objects
#' @param model_names Vector of corresponding model names
#' @return A tibble summarizing Accuracy, Sensitivity, Specificity, and F1
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

#' 3. Plot Confusion Matrix
#' @param cm caret confusionMatrix object
#' @param title Plot title (default: "Confusion Matrix")
#' @return A ggplot2 heatmap representing the confusion matrix
plot_confusion_matrix <- function(cm, title = "Confusion Matrix") {
  
  plt <- as.data.frame(cm$table)
  plt$Prediction <- factor(plt$Prediction, levels = rev(levels(plt$Prediction)))
  
  ggplot(plt, aes(Reference, Prediction, fill = Prediction)) +
    geom_tile(aes(fill = Freq), color = "white") +
    geom_text(aes(label = sprintf("%d", Freq)), vjust = 1) +
    scale_fill_gradient(low = "white", high = "#004085") +
    labs(title = title, x = "Actual", y = "Predicted") +
    theme_minimal() +
    theme(legend.position = "none")
}

#' 4. Create Standard EEG Preprocessing Recipe Pipeline
#' @param train_data Training data frame
#' @param use_pca Logical flag indicating whether to apply PCA (TRUE/FALSE)
#' @param n_comp Number of principal components if PCA is enabled
#' @return A recipe object incorporating scaling, centering, SMOTE, and optional PCA
create_eeg_recipe <- function(train_data, use_pca = FALSE, n_comp = 12) {
  
  rec <- recipe(y ~ ., data = train_data) %>%
    step_center(all_predictors()) %>%
    step_scale(all_predictors()) %>%
    step_smote(y, over_ratio = 1, seed = 123) # Handle class imbalance
  
  if (use_pca) {
    rec <- rec %>% step_pca(all_predictors(), num_comp = n_comp) # PCA reduction
  }
  
  return(rec)
}