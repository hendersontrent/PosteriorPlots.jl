# PosteriorPlots.jl

[![DOI](https://zenodo.org/badge/386667603.svg)](https://zenodo.org/badge/latestdoi/386667603)
[![Coverage](https://codecov.io/gh/hendersontrent/PosteriorPlots.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/hendersontrent/PosteriorPlots.jl)

Graphical tools for Bayesian inference and posterior predictive checks.

## Motivation

R has excellent packages for the plotting and analysis of Bayesian models fit in probabilistic programming languages such as [`Stan`](https://mc-stan.org). Examples of these packages include [`bayesplot`](http://mc-stan.org/bayesplot/) and [`tidybayes`](http://mjskay.github.io/tidybayes/). The functionality afforded by these packages greatly enables researchers to automaticall obtain informative and clean graphical summaries of various posterior properties of interest with ease. While packages such as [`MCMCChains.jl`](https://turinglang.github.io/MCMCChains.jl/dev/) and others exist in Julia for models built in the [PPL](https://en.wikipedia.org/wiki/Probabilistic_programming) [`Turing.jl`](https://turing.ml/stable/), the clean, inference-ready outputs produced by `bayesplot` are not easily available for these models. `PosteriorPlots.jl` seeks to bridge this gap.

## Functionality

`PosteriorPlots.jl` provides intuitive and simple functionality for both statistical inference of model parameter posterior distributions as well as visualisation and interpretation of model fits and posterior diagnostics. Prospective functionality can be summarised across these two domains:

### Statistical inference

* Pointwise and credible interval estimates of parameters
* Parameter probability density distributions
* Parameter histograms

### Model diagnostics

* Posterior predictive checks of distribution
* Posterior predictive checks of probability mass and probability density

## Future work

Currently, package functionality only works for models with continuous response variables (and therefore probability density functions). Work in the near future will add functionality to handle discrete response variables and their probability mass function requirements.

Future work will also expand `PosteriorPlots.jl` functionality to accept models from other probabilistic programming systems in Julia such as [`Soss.jl`](https://github.com/cscherrer/Soss.jl). Please check back soon for an update on this!
