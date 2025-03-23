# RMB: Robust Median-Based Bayesian Approach

**RMB** is an R package for robust median-based Bayesian modeling for longitudinal data with missingness (MAR, MNAR, MCAR). It uses JAGS and MCMC methods to estimate latent growth curves.

## 📦 Installation

You can install the development version of `RMB` from GitHub:

```r
install.packages("devtools")
devtools::install_github("your_username/RMB")
```

## 🚀 Usage

```r
library(RMB)

# Example data
data <- matrix(rnorm(200), 20, 10)

# Run model
result <- RMB("MAR", data = data, seed = 123)

# Traceplot
# traceplot(result)
```

## 📖 Vignette

After installation, view the vignette:

```r
browseVignettes("RMB")
```

## 🔧 Supported Missing Data Mechanisms

- MAR (Missing At Random)
- MNAR (Missing Not At Random)
- MCAR (Missing Completely At Random)
- No missing

## 📚 License

MIT License
