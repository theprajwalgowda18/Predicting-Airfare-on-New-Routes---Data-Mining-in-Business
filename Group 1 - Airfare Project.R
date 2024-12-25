#Import necessary libraries
install.packages("readxl")
library(readxl)

#STEP 1: DATA COLLECTION

#Read the dataset
whole_data = read_excel("Airfare dataset.xlsx")


#View the initial rows
head(whole_data)


# STEP 2: DATA PREPROCESSING

#a. Perform typecasting
whole_data$S_CODE=as.factor(whole_data$S_CODE)
whole_data$S_CITY=as.factor(whole_data$S_CITY)
whole_data$E_CODE=as.factor(whole_data$E_CODE)
whole_data$E_CITY=as.factor(whole_data$E_CITY)
whole_data$SLOT=as.factor(whole_data$SLOT)
whole_data$GATE=as.factor(whole_data$GATE)
whole_data$SW=as.factor(whole_data$SW)
whole_data$VACATION=as.factor(whole_data$VACATION)

#b. Sampling the dataset
set.seed(12345)
N=nrow(whole_data)
df = whole_data[sample(N, 600), ]

#c. Handle Missing Values

#Perform MEAN Imputation for numerical variables without outliers (COUPON, NEW, HI, S_INCOME, E_INCOME, DISTANCE, and PAX)
numeric_columns = c("COUPON", "NEW", "HI", "S_INCOME", "E_INCOME", "DISTANCE", "PAX")
df[numeric_columns] = lapply(df[numeric_columns], function(column) {
  ifelse(is.na(column), mean(column, na.rm = TRUE), column)
})
summary(df[, numeric_columns])

# Perform MODE Imputation for categorical (SW, VACATION, SLOT and GATE) variables.
calculate_mode = function(x) {
  unique_x = unique(na.omit(x))  
  unique_x[which.max(tabulate(match(x, unique_x)))] 
}
df$SW[is.na(df$SW)] = calculate_mode(df$SW)
df$VACATION[is.na(df$VACATION)] = calculate_mode(df$VACATION)
df$SLOT[is.na(df$SLOT)] = calculate_mode(df$SLOT)
df$GATE[is.na(df$GATE)] = calculate_mode(df$GATE)
summary(df[, c("SW", "VACATION","SLOT","GATE")])

#Perform MEDIAN Imputation for numerical variables with outliers (S_POP and E_POP
df$S_POP[is.na(df$S_POP)] = median(df$S_POP, na.rm = TRUE)
df$E_POP[is.na(df$E_POP)] = median(df$E_POP, na.rm = TRUE)
summary(df[, c("S_POP", "E_POP")])

#Perform partition (Training=50%, Validation=30% and Testing=20%)
train_size=round(N*0.5)
train_cases=sample(N,train_size)
train_data=df[train_cases,]

val_size=round(N*0.3)
val_cases=sample(N,val_size)
val_data=df[val_cases,]

test_size=round(N*0.2)
test_cases=sample(N,test_size)
test_data=df[test_cases,]


#Step 3: BUILD MODEL

# Linear Regression Model
model=lm(FARE~.,train_data)
summary(model)

#STEP 4: REFINE THE MODEL

#Exclude cities and codes
refine_model=lm(FARE~.-S_CITY-E_CITY-E_CODE-S_CODE,train_data)
summary(refine_model)

#Perform stepwise operation
refine_model=step(refine_model)
summary(refine_model)

# Calculate RMSE, MAE and R-squared for training data
train_pred <- predict(refine_model, train_data)
train_valid_indices <- !is.na(train_data$FARE) & !is.na(train_pred)
train_rmse <- sqrt(mean((train_data$FARE[train_valid_indices] - train_pred[train_valid_indices])^2))
train_mae <- mean(abs(train_data$FARE[train_valid_indices] - train_pred[train_valid_indices]))
train_r2 <- 1 - sum((train_data$FARE[train_valid_indices] - train_pred[train_valid_indices])^2) / 
  sum((train_data$FARE[train_valid_indices] - mean(train_data$FARE[train_valid_indices]))^2)

cat("Training RMSE:", train_rmse, "\n")
cat("Training MAE:", train_mae, "\n")
cat("Training R-squared:", train_r2, "\n")

# Calculate RMSE, MAE and R-squared for Validation data
val_pred <- predict(refine_model, val_data)
valid_indices <- !is.na(val_data$FARE) & !is.na(val_pred)
val_rmse <- sqrt(mean((val_data$FARE[valid_indices] - val_pred[valid_indices])^2))
val_mae <- mean(abs(val_data$FARE[valid_indices] - val_pred[valid_indices]))
val_r2 <- 1 - sum((val_data$FARE[valid_indices] - val_pred[valid_indices])^2) / 
  sum((val_data$FARE[valid_indices] - mean(val_data$FARE[valid_indices]))^2)

cat("Validation RMSE:", val_rmse, "\n")
cat("Validation MAE:", val_mae, "\n")
cat("Validation R-squared:", val_r2, "\n")


#STEP 5: Evaludate the Model
predictions=predict(refine_model,test_data)
observations=test_data$FARE
errors=observations-predictions

# Calculate RMSE, MAE and R-squared for Test data
valid_indices <- !is.na(observations) & !is.na(predictions)
observations_clean <- observations[valid_indices]
predictions_clean <- predictions[valid_indices]
rmse=sqrt(mean((observations_clean - predictions_clean)^2, na.rm = TRUE))
mae=mean(abs(observations_clean - predictions_clean), na.rm = TRUE)
r2=1 - sum((observations_clean - predictions_clean)^2) / 
  sum((observations_clean - mean(observations_clean))^2)
cat("Test RMSE:", rmse, "\n")
cat("Test MAE:", mae, "\n")
cat("Test R-squared:", r2, "\n")

mape = mean(abs((observations - predictions) / observations), na.rm = TRUE) * 100
cat("Test Mean absolute Percentage Error:", mape, "\n")
errors_bench=observations - mean(train_data$FARE, na.rm = TRUE)
mape_bench <- mean(abs(errors_bench) / observations, na.rm = TRUE) * 100
cat("Test MAPE for Benchmark:", mape_bench, "\n")
rmse_bench = sqrt(mean(errors_bench^2, na.rm = TRUE))
cat("Test RMSE for benchmark:", rmse_bench, "\n")

# Print the mertices table

metrics_table <- data.frame(
  Partition = c("Training", "Validation", "Test"),
  RMSE = c(train_rmse, val_rmse, rmse),
  MAE = c(train_mae, val_mae, mae),
  R_squared = c(train_r2, val_r2, r2)
)

print(metrics_table)
