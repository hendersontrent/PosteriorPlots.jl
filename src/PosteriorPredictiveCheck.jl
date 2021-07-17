"""

    plot_posterior_density_check(model, y, args...; kwargs...)

Draw a density plot of a random sample of response variable posterior distributions against the density estimation of the actual data to visualise model fit similar to the `bayesplot` package in R.

Usage:
```julia-repl
plot_posterior_density_check(model, data)
```
Arguments:

- `model` : The Turing.jl model to draw inferences from.
- `y` : The y variable of the actual data to plot posterior draws against.
"""


