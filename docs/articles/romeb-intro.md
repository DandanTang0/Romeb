# Romeb Package: An Introduction

## Introduction

`Romeb` implements *robust median‑based Bayesian* growth curve modeling
that accommodate the three classical missing‑data mechanisms—MCAR, MAR
and MNAR-and complete data, particularly beneficial when data are
nonnormally distributed or include outliers. A detailed tutorial can be
found in Tang & Tong (2025).

## Function usage

The main interface is

``` r
Romeb(
  Missing_Type,      # "MNAR", "MAR", "MCAR", or "no missing"
  data,              # matrix / data frame
  time,              # Numeric vector of measurement times (e.g., c(0,1,2,3)).
  seed,              # reproducibility seed
  K      = 0,        # number of auxiliary variables
  chain  = 1,        # number of MCMC chains
  Niter  = 6000,     # iterations per chain
  burnIn = 3000      # burn‑in iterations
)
```

### Arguments

| Argument | Description |
|----|----|
| `Missing_Type` | Character string specifying the assumed missing‑data mechanism. One of `"MNAR"`, `"MAR"`, `"MCAR"`, `"no missing"`. |
| `data` | Matrix or data frame. If `K = 0`, **all** columns are treated as outcomes *y*; otherwise the first *K* columns are auxiliary variables and the next `Time` columns are outcomes. |
| `time` | Numeric vector of measurement times (e.g., c(0,1,2,3)). |
| `seed` | Integer seed ensuring reproducibility. |
| `K` | Non‑negative integer (default 0) giving the number of auxiliary variables. |
| `chain` | Number of parallel MCMC chains (default 1). |
| `Niter` | Total iterations **per chain** (default 6000). |
| `burnIn` | Iterations discarded as burn‑in (default 3000). |

## Output object

Running

``` r
Res <- Romeb(...)
print(Res)             # or simply type Res
```

returns a compact table with the posterior median, Geweke *z*‑scores,
the 95% equal‑tail credible interval, and the 95%
highest‑posterior‑density (HPD) interval for each monitored parameter.

Further elements can be accessed directly:

| Element | Content |
|----|----|
| `Res$quantiles` | Posterior mean, SD, naïve and time‑series SEs, plus selected quantiles for every parameter *after* burn‑in. |
| `Res$geweke` | Vector of Geweke diagnostic *z*‑scores; values within ±1.96 indicate no evidence against lack of convergence. |
| `Res$credible_intervals` | 95% equal‑tail credible intervals (2.5% & 97.5% quantiles). |
| `Res$hpd_intervals` | 95% HPD intervals (shortest 95% region). |
| `Res$samps_full` | Complete [`coda::mcmc.list`](https://rdrr.io/pkg/coda/man/mcmc.list.html) (including burn‑in). Inspect with `coda::traceplot(Res$samps_full[,'par[i]'])` for par\[i\] . |

## Quick examples

Below we illustrate a workflow.

``` r
set.seed(123)
Y <- matrix(rnorm(300*5), nrow = 300, ncol = 5)  # tiny complete data set
result_full <- Romeb("no missing", data = Y, time = c(0, 1, 2, 3, 4), seed = 123)
```

    ## Compiling model graph
    ##    Resolving undeclared variables
    ##    Allocating nodes
    ## Graph information:
    ##    Observed stochastic nodes: 1500
    ##    Unobserved stochastic nodes: 1804
    ##    Total graph size: 14432
    ## 
    ## Initializing model

``` r
print(result_full)
```

    ## Romeb GCM summary
    ## ==================
    ## 
    ## Posterior medians (50% quantiles):
    ##       par[1]       par[2]       par[3]       par[4]       par[5] 
    ##  0.010448884  0.008549176  0.171543659 -0.056132922  0.046658630 
    ## 
    ## Geweke test:
    ##     par[1]     par[2]     par[3]     par[4]     par[5] 
    ## -0.4295213  0.8113677  0.1677203 -0.2686674  0.5478983 
    ## 
    ## 95% credible intervals:
    ##               2.5%       97.5%
    ## par[1] -0.08372728  0.09968858
    ## par[2] -0.03105851  0.04984433
    ## par[3]  0.09413207  0.27461789
    ## par[4] -0.09527199 -0.02609691
    ## par[5]  0.03244535  0.06536003
    ## 
    ## 95% hpd intervals:
    ##            par[1]      par[2]     par[3]      par[4]     par[5]
    ## lower -0.08410641 -0.03164083 0.09030855 -0.09251707 0.03161084
    ## upper  0.09900967  0.04894551 0.26590422 -0.02422712 0.06381646
    ## 
    ## Use x$samps_full to access full MCMC samples, and coda::traceplot(x$samps_full[,'par[i]']) for the trace plot of par[i].

Note: par \[1\]: latent intercept, par \[2\]: latent slope: par \[3\]:
variance of the latent intercept, par \[4\]: covariance between
intercept and slope, par \[5\]: variance of the latent slope.

### MCAR example

``` r
set.seed(456)
Y <- matrix(rnorm(300 * 5), nrow = 300)
miss <- runif(length(Y)) < 0.1       # 10% missing completely at random
Y[miss] <- NA
result_mcar <- Romeb("MCAR", data = Y, time = c(0, 1, 2, 3, 4), seed = 456)
```

### MNAR with auxiliary variables

``` r
set.seed(789)
X  <- matrix(rnorm(300 * 2), 300, 2)     # two auxiliaries
Y  <- matrix(rnorm(300 * 5), 300, 5)
Data <- cbind(X, Y)
result_mnar <- Romeb("MNAR", data = Data, time = c(0, 1, 2, 3, 4), K = 2, seed = 789)
```

## Inspecting convergence visually

``` r
# Uses the tiny example result_full from above
coda::traceplot(result_full$samps_full[,'par[1]'])
```

![Trace plot for the first chain
(par\[1\])](romeb-intro_files/figure-html/traceplot-1.png)

Trace plot for the first chain (par\[1\])

## How to cite

Please cite the package as:

> Tang,D.and Tong,X.(2025). *Romeb: An R Package for Robust Median-Based
> Bayesian Growth Curve Modeling with Missing Data.*

Bibliographic metadata can also be obtained via `citation("Romeb")`.
