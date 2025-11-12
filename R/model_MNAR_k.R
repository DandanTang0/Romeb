#' Bayesian Growth-Curve Model for MNAR with Auxiliary Variable (k)
#'
#' JAGS model definition for MNAR mechanism with auxiliary variable k.
#'
#' @format A character string.
#' @export
model_MNAR_k <- "
model {
  for (i in 1:N) {
    for(t in 1:Time) {
      V[i,t] ~ dexp(pre_sigma)
      
      y[i,t] ~ dnorm(muy[i,t], pre_sig2[i,t])
      
      muy[i,t]      <- LS[i,1] + time[t]*LS[i,2] + zeta*V[i,t]
      pre_sig2[i,t] <- 1/sig2_y[i,t]
      sig2_y[i,t]   <- eta^2 * V[i,t] / pre_sigma
      
      loglik[i,t]   <- logdensity.norm(y[i,t], muy[i,t], pre_sig2[i,t])
    }
    
    LS[i,1:2]  ~ dmnorm(muLS[1:2], Inv_cov[1:2,1:2])
  }

  for(i in 1:N){
    for(t in 2:Time){
      m[i,t] ~ dbern(q[i,t])
      # logit(q[i,t]) = r0 + r1*y[i,(t-1)] + r2*y[i,t] + inprod( beta_aux[], X[i,] )
      logit(q[i,t]) <- r0 + r1*y[i,(t-1)] + r2*y[i,t] + inprod(beta_aux[], X[i,])
    }
  }

  zeta <- (1 - 2*tau) / (tau*(1 - tau))
  eta  <- sqrt(2 / (tau*(1 - tau)))

  r0 ~ dnorm(0, 0.001)
  r1 ~ dnorm(0, 0.001)
  r2 ~ dnorm(0, 0.001)
  
  for(k in 1:K){
    beta_aux[k] ~ dnorm(0, 0.001)
  }

  pre_sigma ~ dgamma(0.001, 0.001)
  sigma <- 1 / pre_sigma

  muLS[1] ~ dnorm(0, 0.001)
  muLS[2] ~ dnorm(0, 0.001)
  
  Inv_cov[1:2,1:2] ~ dwish(R[1:2,1:2], 3)
  Cov_b <- inverse(Inv_cov[1:2,1:2])
  
  R[1,1] <- 1
  R[2,2] <- 1
  R[1,2] <- 0
  R[2,1] <- R[1,2]

  par[1] <- muLS[1]
  par[2] <- muLS[2]
  par[3] <- Cov_b[1,1]
  par[4] <- Cov_b[1,2]
  par[5] <- Cov_b[2,2]
  par[6] <- r0
  par[7] <- r1
  par[8] <- r2

  for(k in 1:K){
    par[8 + k] <- beta_aux[k]
  }
}
"

