# PosteriorPlots.jl

[![DOI](https://zenodo.org/badge/386667603.svg)](https://zenodo.org/badge/latestdoi/386667603)
[![Coverage](https://codecov.io/gh/hendersontrent/PosteriorPlots.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/hendersontrent/PosteriorPlots.jl)

Graphical tools for Bayesian inference and posterior predictive checks.

## Motivation

R has excellent packages for the plotting and analysis of Bayesian models fit in probabilistic programming languages such as [`Stan`](https://mc-stan.org). Examples of these packages include [`bayesplot`](http://mc-stan.org/bayesplot/) and [`tidybayes`](http://mjskay.github.io/tidybayes/). The functionality afforded by these packages greatly enables researchers to automatically obtain informative and clean graphical summaries of various posterior properties of interest. While packages such as [`MCMCChains.jl`](https://turinglang.github.io/MCMCChains.jl/dev/), [`ArviZ.jl`](https://arviz-devs.github.io/ArviZ.jl/stable/), and others exist in Julia for models built in the [PPLs](https://en.wikipedia.org/wiki/Probabilistic_programming) [`Turing.jl`](https://turing.ml/stable/) and [`Soss.jl`](https://github.com/cscherrer/Soss.jl), the clean, inference-ready output aesthetics produced by `bayesplot` are not easily available by default. `PosteriorPlots.jl` seeks to bridge this gap. Since `PosteriorPlots.jl` functions can take standard object types such as Arrays as inputs (as well as special object types such as Chains), it can flexibly accommodate models from `Stan` and other PPLs.

## Functionality

`PosteriorPlots.jl` provides intuitive and simple functionality for both statistical inference of model parameter posterior distributions as well as visualisation and interpretation of model fits and posterior diagnostics. Package functionality can be summarised across these two domains:

### Statistical inference

* Parameter pointwise estimates and credible intervals
* Parameter posterior density/mass distributions
* Parameter posterior histograms

### Model diagnostics

* Posterior predictive checks of distribution
* Posterior predictive checks of probability mass/density
* Posterior predictive checks of empirical cumulative density functions

## Citation instructions

If you use `PosteriorPlots.jl` in your work, please cite it using the following (included as BibTeX file in the package folder):

```
@Manual{PosteriorPlots.jl,
  title={{PosteriorPlots.jl}},
  author={Henderson, Trent},
  year={2021},
  month={6},
  url={https://doi.org/10.5281/zenodo.5173723},
  doi={10.5281/zenodo.5173723}
}
```

## Acknowledgements

Many thanks to [Brendan Harris](https://github.com/brendanjohnharris) for error troubleshooting and other technical Julia advice.
