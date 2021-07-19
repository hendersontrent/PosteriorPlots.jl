# PosteriorPlots.jl
Graphical tools for posterior distributions of Turing models.

## Motivation

R has excellent packages for the plotting and analysis of Bayesian models fit in proabilistic programming languages such as [`Stan`](https://mc-stan.org). Examples of these packages include [`bayesplot`](http://mc-stan.org/bayesplot/) and [`tidybayes`](http://mjskay.github.io/tidybayes/). The functionality afforded by these packages greatly enables researchers to obtain informative and clean graphical summaries of various posterior properties of interest with ease. While packages such as [`MCMCChains.jl`](https://turinglang.github.io/MCMCChains.jl/dev/) and others exist in Julia for models built in the [PPL](https://en.wikipedia.org/wiki/Probabilistic_programming) [`Turing.jl`](https://turing.ml/stable/), the clean, inference-ready outputs produced by `bayesplot` are not easily available for these models. `PosteriorPlots.jl` seeks to bridge this gap.

## Functionality

`PosteriorPlots.jl` seeks to provide intuitive and simple functionality for both statistical inference of model parameters as well as visualisation and interpretation of model fits and diagnostics. Prospective functionality can be summarised across these two domains:

### Statistical inference

* Point and credible interval estimates
* Parameter distributions
* Predictions

### Model diagnostics

* Posterior predictive checks of distribution
* Posterior predictive checks of probability mass and probability density
