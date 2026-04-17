# ── Predictive Analytics – Eksamen 2026 ────────────────────────────────────────
# Main analysis script
# ───────────────────────────────────────────────────────────────────────────────

# ── 0. Packages ────────────────────────────────────────────────────────────────
# Install missing packages automatically
required_packages <- c("tidyverse", "caret", "corrplot", "MASS")
new_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(new_packages)) install.packages(new_packages)

library(tidyverse)
library(caret)
library(ggplot2)
library(corrplot)

# ── 1. Load data ───────────────────────────────────────────────────────────────
# Replace the path / dataset below with the actual exam dataset
# data <- read.csv("data/dataset.csv")

# Example: use the built-in Boston housing dataset
data("Boston", package = "MASS")
df <- Boston

cat("Dataset dimensions:", nrow(df), "rows x", ncol(df), "columns\n")
cat("Summary:\n")
print(summary(df))

# ── 2. Exploratory Data Analysis ───────────────────────────────────────────────
# Correlation matrix
cor_matrix <- cor(df)

png("R/output/correlation_matrix.png", width = 800, height = 700)
corrplot(cor_matrix, method = "color", type = "upper",
         tl.cex = 0.8, addCoef.col = "black", number.cex = 0.6)
dev.off()

# Distribution of the target variable (medv = median home value)
p_hist <- ggplot(df, aes(x = medv)) +
  geom_histogram(bins = 30, fill = "steelblue", colour = "white") +
  labs(title = "Distribution of median home value (medv)",
       x = "medv ($1000s)", y = "Count") +
  theme_minimal()

ggsave("R/output/target_distribution.pdf", plot = p_hist, width = 7, height = 5)

# ── 3. Train / Test split ──────────────────────────────────────────────────────
set.seed(42)
train_index <- createDataPartition(df$medv, p = 0.8, list = FALSE)
train_data  <- df[ train_index, ]
test_data   <- df[-train_index, ]

cat("\nTrain rows:", nrow(train_data), "| Test rows:", nrow(test_data), "\n")

# ── 4. Model training ─────────────────────────────────────────────────────────
# 4a. Linear regression (baseline)
lm_model <- train(
  medv ~ .,
  data      = train_data,
  method    = "lm",
  trControl = trainControl(method = "cv", number = 5)
)

cat("\n── Linear Regression ──────────────────────────────\n")
print(lm_model)

# 4b. Random Forest
rf_model <- train(
  medv ~ .,
  data      = train_data,
  method    = "rf",
  trControl = trainControl(method = "cv", number = 5),
  tuneLength = 3
)

cat("\n── Random Forest ──────────────────────────────────\n")
print(rf_model)

# ── 5. Evaluation ─────────────────────────────────────────────────────────────
eval_model <- function(model, test_data, target = "medv") {
  preds  <- predict(model, newdata = test_data)
  actual <- test_data[[target]]
  rmse   <- sqrt(mean((preds - actual)^2))
  mae    <- mean(abs(preds - actual))
  r2     <- cor(preds, actual)^2
  data.frame(RMSE = round(rmse, 3), MAE = round(mae, 3), R2 = round(r2, 3))
}

results <- rbind(
  cbind(Model = "Linear Regression", eval_model(lm_model, test_data)),
  cbind(Model = "Random Forest",     eval_model(rf_model, test_data))
)

cat("\n── Model comparison ───────────────────────────────\n")
print(results)

# ── 6. Variable importance (Random Forest) ────────────────────────────────────
importance_df <- varImp(rf_model)$importance %>%
  rownames_to_column("Feature") %>%
  arrange(desc(Overall))

p_imp <- ggplot(importance_df, aes(x = reorder(Feature, Overall), y = Overall)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Variable Importance – Random Forest",
       x = NULL, y = "Importance") +
  theme_minimal()

ggsave("R/output/variable_importance.pdf", plot = p_imp, width = 7, height = 5)

cat("\nDone. Plots saved to R/output/\n")
