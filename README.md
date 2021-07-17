# PosteriorPlots.jl
Graphical tools for posterior distributions of Turing models.

## Motivation

R has excellent packages for the plotting and analysis of Bayesian models fit in proabilistic programming languages such as [`Stan`](https://mc-stan.org). Examples of these packages include [`bayesplot`](http://mc-stan.org/bayesplot/) and [`tidybayes`](http://mjskay.github.io/tidybayes/). The functionality afforded by these packages greatly enables researchers to obtain informative and clean graphical summaries of various posterior properties of interest with ease. Such functionality does not currently easily exist in Julia for its excellent and native [`Turing.jl`](https://turing.ml/stable/) package. `PosteriorPlots.jl` seeks to bridge this gap.

## Functionality

`PosteriorPlots.jl` seeks to provide intuitive and simple functionality for both statistical inference of model parameters as well as visualisation and interpretation of model fits and diagnostics.
