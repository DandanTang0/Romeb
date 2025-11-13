# Romeb: Robust Median-Based Bayesian Growth Curve Modeling

Implements robust median-based Bayesian growth-curve models that handle
MCAR/MAR/MNAR missing-data mechanisms and complete data. Models are
fitted via rjags/JAGS and summarized with coda.

Fits a median-based Bayesian growth curve model under MCAR, MAR, MNAR or
complete-data assumptions. If `K > 0` the first `K` columns in `data`
are treated as auxiliary variables.

## Usage

``` r
Romeb(
  Missing_Type,
  data,
  time,
  seed,
  K = 0,
  chain = 1,
  Niter = 6000,
  burnIn = 3000
)
```

## Arguments

- Missing_Type:

  Character; one of `MNAR`, `MAR`, `MCAR`, `no missing`.

- data:

  Matrix or data frame containing outcome columns (and optionally
  auxiliary variables).

- time:

  Numeric vector of measurement times (e.g., c(0,1,2,3)).

- seed:

  Integer seed for reproducibility.

- K:

  Integer; number of auxiliary variables (default 0).

- chain:

  Integer; number of MCMC chains (default 1).

- Niter:

  Integer; iterations per chain (default 6000).

- burnIn:

  Integer; burn-in iterations (default 3000).

## Value

An object of class `RomebResult` containing

- quantiles:

  posterior means, SDs and quantiles

- geweke:

  Geweke *z*-scores

- credible_intervals:

  95% equal-tail credible intervals

- hpd_intervals:

  95% highest posterior density intervals

- samps_full:

  full [`coda::mcmc.list`](https://rdrr.io/pkg/coda/man/mcmc.list.html)
  (including burn-in)

## See also

Useful links:

- <https://github.com/DandanTang0/Romeb>

- Report bugs at <https://github.com/DandanTang0/Romeb/issues>

## Author

**Maintainer**: Dandan Tang <tangdd20@gmail.com>
([ORCID](https://orcid.org/0009-0007-3453-9660))

Authors:

- Xin Tong

## Examples

``` r
  set.seed(123)
  Y <- matrix(rnorm(300), 100, 3)
  fit <- Romeb("no missing", data = Y, time = c(0,1,2), seed = 123, K = 0,
               Niter = 6000, burnIn = 3000)
#> 
#> Running no missing model  (K = 0)
#> Compiling model graph
#>    Resolving undeclared variables
#>    Allocating nodes
#> Graph information:
#>    Observed stochastic nodes: 300
#>    Unobserved stochastic nodes: 404
#>    Total graph size: 3030
#> 
#> Initializing model
#> 
  print(fit)
#> Romeb GCM summary
#> ==================
#> 
#> Posterior medians (50% quantiles):
#>       par[1]       par[2]       par[3]       par[4]       par[5] 
#> -0.028959076  0.006534935  0.246008195 -0.139386679  0.191886602 
#> 
#> Geweke test:
#>     par[1]     par[2]     par[3]     par[4]     par[5] 
#>  0.6312252 -1.3194087  0.2727626  0.3205222 -0.7499546 
#> 
#> 95% credible intervals:
#>               2.5%       97.5%
#> par[1] -0.20424846  0.14309348
#> par[2] -0.13638706  0.15364752
#> par[3]  0.11134245  0.47052262
#> par[4] -0.31684374 -0.03367711
#> par[5]  0.08970286  0.35341840
#> 
#> 95% hpd intervals:
#>           par[1]     par[2]     par[3]     par[4]     par[5]
#> lower -0.1968473 -0.1370647 0.09913653 -0.2846050 0.07818917
#> upper  0.1489117  0.1522016 0.43895060 -0.0121798 0.33646925
#> 
#> Use x$samps_full to access full MCMC samples, and coda::traceplot(x$samps_full[,'par[i]']) for the trace plot of par[i].
```
