# 📈 Stock Forecasting for INDF using ARIMA in R

This repository contains a complete time series analysis and forecasting project for the stock price of **PT Indofood Sukses Makmur Tbk (INDF)** using the ARIMA model in R.

⚠️ **Note:** The ARIMA model is best suited for short-term forecasts and this project serves as an academic experiment to test its forecasting accuracy, not as financial advice.

---

## 🎯 Objective

To forecast INDF’s closing stock prices using historical data with the ARIMA model and evaluate the model's forecasting performance. The final goal is to project the next 30 trading days and validate the accuracy of the chosen model.

---

## 🧪 Methodology

1. **Data Cleaning & Preprocessing**
   - Format and clean daily closing price data
   - Handle missing/zero values

2. **Stationarity Check**
   - Apply Augmented Dickey-Fuller (ADF) test
   - Perform first-order differencing to achieve stationarity

3. **ACF/PACF Analysis**
   - Visualize autocorrelation and partial autocorrelation for model identification

4. **Model Estimation**
   - Test multiple ARIMA models: (0,1,1), (1,1,0), (1,1,1), and (2,1,1)
   - Use AIC/BIC criteria to select best-fit model

5. **Model Training & Forecasting**
   - Train best model (ARIMA(0,1,1)) on 80% training data
   - Forecast on 20% test data
   - Forecast future values for 30 trading days

6. **Model Evaluation**
   - Evaluate forecast accuracy using:
     - **MAPE:** Mean Absolute Percentage Error
     - **MAE:** Mean Absolute Error
     - **MSE:** Mean Squared Error

7. **Residual Diagnostics**
   - Use `checkresiduals()` to test model assumptions

---

## 📉 Evaluation Results

| Metric | Value |
|--------|-------|
| **MAPE** | 13.73% |
| **MAE**  | 1010.53 |
| **MSE**  | 1520956 |

---

## 📁 Files Included

- `INDF_ARIMA.R`  
  Main script containing all analysis steps from data loading to forecasting.

- `Artikel-INDF-Arima.pdf`  
  Full written report in Indonesian, explaining methodology and findings.

- `data/INDR_Historical.csv`  
  Source data (daily closing prices).

- `plots/` folder includes:
  - `harga-penutupan.png`
  - `acf-asli.png`, `pacf-asli.png`
  - `acf-diff.png`, `pacf-diff.png`
  - `forecast-30hari.png`

---

## ▶️ How to Run

1. **Clone this repo**

   ```bash
   git clone https://github.com/rafikingakbar/Stock-Forecast-INDF-Arima.git
   cd Stock-Forecast-INDF-Arima

2. **Install R Packages**
   install.packages(c("readr", "forecast", "tseries", "Metrics"))
   
3. **Run the Analysis**
   source("INDF_ARIMA.R")
   
4. **Output**
