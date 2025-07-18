library(readr)
library(forecast)
library(tseries)
library(Metrics)

# --------------------------------------------------
# 4.1 Analisis Data Awal
# --------------------------------------------------

# 1. Baca data
data <- read.csv("C:/Users/Rafi/Downloads/Data Historis INDF (2).csv", colClasses = "character")
data$Tanggal <- as.Date(data$Tanggal, format = "%d/%m/%Y")
data <- data[order(data$Tanggal), ]

# 2. Konversi kolom harga ke numerik
data$Terakhir <- as.numeric(gsub(",", ".", gsub("\\.", "", data$Terakhir)))

# 3. Ringkasan statistik
cat("Ringkasan harga penutupan:\n")
summary(data$Terakhir)

# 4. Pengecekan data hilang / nol
na_count  <- sum(is.na(data$Terakhir))
zero_count <- sum(data$Terakhir == 0)

cat("Jumlah data NA :", na_count, "\n")
cat("Jumlah data 0  :", zero_count, "\n")

# 5. Plot harga penutupan
plot(data$Tanggal, data$Terakhir, type="l",
     main="Harga Penutupan Saham INDF",
     xlab="Tanggal", ylab="Harga Penutupan")

# --------------------------------------------------
# 4.2 Pengujian Stasioneritas
# --------------------------------------------------

# Membuat time series
closing_ts <- ts(data$Terakhir, frequency=1)

# 1. Uji ADF pada data asli
cat("\nHasil ADF Test pada data asli:\n")
adf_asli <- adf.test(closing_ts)
print(adf_asli)

# 2. Plot data asli
plot(closing_ts,
     main="Plot Harga Penutupan (Data Asli)",
     ylab="Harga", xlab="Waktu")

# 3. Plot ACF & PACF data asli
acf(closing_ts, main="ACF Data Asli")
pacf(closing_ts, main="PACF Data Asli")

# 4. Differencing 1x
diff_ts <- diff(closing_ts)

# 5. Uji ADF setelah differencing
cat("\nHasil ADF Test setelah differencing 1x:\n")
adf_diff <- adf.test(diff_ts)
print(adf_diff)

# 6. Plot data setelah differencing
plot(diff_ts,
     main="Plot Setelah Differencing (d=1)",
     ylab="Differenced Harga", xlab="Waktu")

# 7. Plot ACF & PACF data differencing
acf(diff_ts, main="ACF Setelah Differencing")
pacf(diff_ts, main="PACF Setelah Differencing")

# --------------------------------------------------
# 4.3 Identifikasi dan Penentuan Model ARIMA
# --------------------------------------------------
model_auto <- auto.arima(closing_ts)
cat("\nHasil auto.arima:\n")
print(summary(model_auto))

# --------------------------------------------------
# 4.3.1 Penentuan Model ARIMA Terbaik
# --------------------------------------------------

# menggunakan seluruh data
full_ts <- closing_ts

# a) ARIMA(0,1,1)
model_011 <- arima(full_ts, order=c(0,1,1))
aic_011 <- AIC(model_011)
bic_011 <- BIC(model_011)

# b) ARIMA(1,1,0)
model_110 <- arima(full_ts, order=c(1,1,0))
aic_110 <- AIC(model_110)
bic_110 <- BIC(model_110)

# c) ARIMA(1,1,1)
model_111 <- arima(full_ts, order=c(1,1,1))
aic_111 <- AIC(model_111)
bic_111 <- BIC(model_111)

# d) ARIMA(2,1,1)
model_211 <- arima(full_ts, order=c(2,1,1))
aic_211 <- AIC(model_211)
bic_211 <- BIC(model_211)

# Ringkasan tabel
cat("\nRingkasan AIC dan BIC kandidat model:\n")
kandidat_table <- data.frame(
  Model = c("ARIMA(0,1,1)", "ARIMA(1,1,0)", "ARIMA(1,1,1)", "ARIMA(2,1,1)"),
  AIC = c(aic_011, aic_110, aic_111, aic_211),
  BIC = c(bic_011, bic_110, bic_111, bic_211)
)
print(kandidat_table)

# Menentukan model terbaik
idx_best <- which.min(kandidat_table$AIC)
cat("\nModel terbaik berdasarkan AIC:\n")
print(kandidat_table[idx_best,])

best_model <- switch(
  idx_best,
  model_011,
  model_110,
  model_111,
  model_211
)

# Ringkasan koefisien best_model
cat("\nRingkasan koefisien model terbaik:\n")
print(summary(best_model))

# --------------------------------------------------
# 4.4 Pembangunan, Pelatihan, dan Evaluasi Model
# --------------------------------------------------

# 4.4.1 Pembangunan dan Pelatihan Model
# --------------------------------------------------

# Train-Test Split
n <- length(closing_ts)
n_train <- floor(0.8 * n)
train_ts <- ts(closing_ts[1:n_train], frequency=1)
test_ts  <- closing_ts[(n_train+1):n]

# Latih model ARIMA(0,1,1) di data train
final_model <- arima(train_ts, order=c(0,1,1))

cat("\nRingkasan model ARIMA(0,1,1) di data training:\n")
print(summary(final_model))

# Plot fitted vs aktual di data training
fitted_train <- fitted(final_model)

plot(train_ts, type="l", col="black", lwd=2,
     main="Data Aktual vs Fitted Model ARIMA(0,1,1) pada Data Training",
     ylab="Harga", xlab="Waktu")
lines(fitted_train, col="blue", lwd=2)
legend("topleft", legend=c("Aktual","Fitted"),
       col=c("black","blue"), lwd=2)

# --------------------------------------------------
# 4.4.2 Evaluasi Model
# --------------------------------------------------

# Forecast ke data test
h_test <- length(test_ts)
fc_test <- forecast(final_model, h=h_test)

# Plot prediksi vs aktual di data testing
plot(fc_test, main="Prediksi vs Aktual pada Data Testing (ARIMA 0,1,1)")
lines((n_train+1):n, test_ts, col="red", lwd=2)  # perbaikan di sini!

# Hitung akurasi evaluasi
mape_test <- mape(test_ts, fc_test$mean) * 100
mae_test  <- mae(test_ts, fc_test$mean)
mse_test  <- mse(test_ts, fc_test$mean)

cat("\nEvaluasi Model di Data Testing:\n")
cat("MAPE :", round(mape_test,2), "%\n")
cat("MAE  :", round(mae_test,2), "\n")
cat("MSE  :", round(mse_test,2), "\n")

# --------------------------------------------------
# 4.5 Analisis Diagnostik Residual
# --------------------------------------------------
checkresiduals(final_model)
checkresiduals(model_011)
               
# --------------------------------------------------
# 4.6 Implementasi Peramalan
# --------------------------------------------------
# fit ulang ke seluruh data
final_model_full <- arima(closing_ts, order=c(0,1,1))

# forecast 30 hari ke depan
forecast_30 <- forecast(final_model_full, h=30)

# plot hasil peramalan
plot(forecast_30,
     main="Peramalan 30 Hari ke Depan Harga Penutupan Saham INDF (ARIMA 0,1,1)",
     xlab="Hari", ylab="Harga Penutupan")

# melihat ringkasan prediksi
print(forecast_30)

# jika ingin data frame tabel prediksi
pred_table <- data.frame(
  Tanggal_Prediksi = seq(tail(data$Tanggal,1) + 1, by=1, length.out=30),
  Harga_Prediksi = round(forecast_30$mean,2),
  Lower_80 = round(forecast_30$lower[,1],2),
  Upper_80 = round(forecast_30$upper[,1],2),
  Lower_95 = round(forecast_30$lower[,2],2),
  Upper_95 = round(forecast_30$upper[,2],2)
)

# tampilkan tabel prediksi
print(pred_table)
