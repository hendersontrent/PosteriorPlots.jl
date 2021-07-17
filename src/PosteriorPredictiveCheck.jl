"""

    plot_posterior_density_check(model, y, args...; kwargs...)

Draw a density plot of a random sample of response variable posterior distributions against the density estimation of the actual data to visualise model fit.

Usage:
```julia-repl
plot_posterior_density_check(model, data)
```
Arguments:

- `model` : The Turing.jl model to draw inferences from.
- `y` : The y variable of the actual data to plot posterior draws against.
"""



"""

    plot_posterior_hist_check(model, y, point_est, args...; kwargs...)

Draw a plot with a binned histogram of sampled parameters against a measure of centrality of the actual data to visualise model fit.

Usage:
```julia-repl
plot_posterior_hist(model)
```

Arguments:

- `model` : The Turing.jl model to draw inferences from.
- `y` : The y variable of the actual data to plot posterior draws against.
- `point_est` : The measure of point estimate centrality. Options are "mean" or "median".
"""

