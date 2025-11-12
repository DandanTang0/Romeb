#' Robust Median-Based Bayesian Growth Curve Modeling
#'
#' Fits a median-based Bayesian growth curve model under MCAR, MAR,
#' MNAR or complete-data assumptions.  If \code{K > 0} the first
#' \code{K} columns in \code{data} are treated as auxiliary variables.
#'
#' @param Missing_Type Character; one of \code{MNAR}, \code{MAR},
#'   \code{MCAR}, \code{no missing}.
#' @param data Matrix or data frame containing outcome columns (and
#'   optionally auxiliary variables).
#' @param time Numeric vector of measurement times (e.g., c(0,1,2,3)).
#' @param seed Integer seed for reproducibility.
#' @param K Integer; number of auxiliary variables (default 0).
#' @param chain Integer; number of MCMC chains (default 1).
#' @param Niter Integer; iterations per chain (default 6000).
#' @param burnIn Integer; burn-in iterations (default 3000).
#'
#' @return An object of class \code{RomebResult} containing
#'   \describe{
#'     \item{quantiles}{posterior means, SDs and quantiles}
#'     \item{geweke}{Geweke \emph{z}-scores}
#'     \item{credible_intervals}{95% equal-tail credible intervals}
#'     \item{hpd_intervals}{95% highest posterior density intervals}
#'     \item{samps_full}{full \code{coda::mcmc.list} (including burn-in)}
#'   }
#' @export
#'
#' @examples
#'   set.seed(123)
#'   Y <- matrix(rnorm(300), 100, 3)
#'   fit <- Romeb("no missing", data = Y, time = c(0,1,2), seed = 123, K = 0,
#'                Niter = 6000, burnIn = 3000)
#'   print(fit)



Romeb <- function(Missing_Type,
                  data,
                  time,
                  seed,
                  K      = 0,
                  chain  = 1,
                  Niter  = 6000,
                  burnIn = 3000) {
  
  
  if (!Missing_Type %in% c("MNAR","MAR","MCAR","no missing"))
    stop("Missing_Type must be 'MNAR','MAR','MCAR', or 'no missing'.")
  
  if (!is.matrix(data) && !is.data.frame(data))
    stop("data must be a matrix or data.frame.")
  
  
  # time: must be a non-empty numeric vector
  if (!is.numeric(time) || length(time) < 1L)
    stop("'time' must be a non-empty numeric vector, e.g., c(0,1,2,3).")
  if (!all(is.finite(time)))
    stop("'time' contains non-finite values (NA/NaN/Inf).")
  
  n_time  <- length(time)
  tvec_in <- as.numeric(time)
  
  if (K < 0 || K != floor(K))
    stop("K must be a non-negative integer.")
  
  if (K + n_time > ncol(data))
    stop("data does not have enough columns for K + length(time) variables.")
  
  if (K == 0 && ncol(data) != n_time)
    stop("With K = 0, 'data' must have exactly length(time) outcome columns.")
  
  
  set.seed(seed)
  tau <- 0.5
  N   <- nrow(data)
  initial <- list(".RNG.name" = "base::Wichmann-Hill",
                  ".RNG.seed" = seed)
  Time <- length(time)
  if (K == 0) {
    dat <- list(N = N, y = data, tau = tau, Time = n_time, time=tvec_in)
    
    model_string <- switch(Missing_Type,
                           "MNAR"       = model_MNAR,
                           "MAR"        = model,
                           "MCAR"       = model,
                           "no missing" = model)
    message("\nRunning ", Missing_Type, " model  (K = 0)")
  } else {
    X_part <- data[, 1:K, drop = FALSE]
    Y_part <- data[, (K+1):(K+n_time), drop = FALSE]
    dat <- list(N = N, y = Y_part, tau = tau,
                K = K, X = X_part, Time = n_time, time=tvec_in)
    
    
    model_string <- model_MNAR_k
    message("\nRunning ", Missing_Type,
            " model  (K = ", K, " auxiliary vars)")
  }
  
  
  jm <- rjags::jags.model(textConnection(model_string),
                          data   = dat,
                          inits  = initial,
                          n.chains = chain,
                          n.adapt  = 1000)
  
  samps_full <- rjags::coda.samples(jm, c("par"), n.iter = Niter)
  total_iter <- nrow(as.matrix(samps_full[[1]]))
  burnIn     <- min(burnIn, total_iter - 1)
  smp_post   <- window(samps_full[[1]], start = burnIn)
  
  
  quantile_summary <- summary(smp_post)
  geweke_z         <- apply(smp_post, 2,
                            function(x) coda::geweke.diag(x)$z)
  credible_int     <- apply(as.matrix(samps_full),
                            2, quantile, probs = c(.025,.975))
  hpd_int          <- coda::HPDinterval(coda::mcmc(as.matrix(samps_full)),
                                        prob = .95)
  
  
  output <- list(
    quantiles          = quantile_summary,
    geweke             = geweke_z,
    credible_intervals = credible_int,
    hpd_intervals      = hpd_int,
    samps_full         = samps_full      
  )
  class(output) <- "RomebResult"         
  return(output)                         
}

#' @export
print.RomebResult <- function(x, ...) {
  cat("Romeb GCM summary\n",
      "==================\n", sep = "")
  cat("\nPosterior medians (50% quantiles):\n")
  print(x$quantiles$quantiles[,"50%"])
  cat("\nGeweke test:\n")
  print(x$geweke)
  cat("\n95% credible intervals:\n")
  print(t(x$credible_intervals))
  cat("\n95% hpd intervals:\n")
  print(t(x$hpd_intervals[,1:2]))
  cat("\nUse x$samps_full to access full MCMC samples,",
      "and coda::traceplot(x$samps_full[,'par[i]']) for the trace plot of par[i].\n")
  invisible(x)
}


