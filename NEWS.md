# Romeb 0.2.0

## New features

* Added `outcome_vars`, allowing users to identify longitudinal outcome variables by column names or 1-based column indices.
* Added `auxiliary_vars`, allowing users to identify auxiliary variables by column names or 1-based column indices. Auxiliary variables are used only in the MNAR missingness model.
* Added `priors`, a named-list interface for user-specified prior hyperparameters.
* Added `inits`, allowing users to provide initial values to `rjags::jags.model()` as a function, a named list for a single chain, or a list of named lists for multiple chains.
* Added a structured `RomebResult` print method that reports model type, selected variables, MCMC settings, parameter mapping, posterior medians, Geweke diagnostics, credible intervals, and HPD intervals.

## Bug fixes

* Replaced the non-exported `coda::window()` call with `stats::window()` for post-processing saved MCMC samples.
* Added validation that `burnIn` is smaller than both `Niter` and the number of saved MCMC iterations.
* Added validation for `n_adapt`, allowing `n_adapt = 0` but requiring a non-negative integer.
* Added input checks for duplicated variables, overlapping outcome and auxiliary variables, missing outcome values in the complete-data model, unknown prior names, and invalid prior dimensions.

## Backward compatibility

* Retained the legacy `K` argument. For new analyses, `outcome_vars` and `auxiliary_vars` are preferred because they do not require a fixed column order in `data`.
* The default prior settings match the original weakly informative implementation.

## Documentation

* Updated the reference manual, README, vignette, and tests to document the new variable-selection, prior-specification, initialization, and adaptation interfaces.
