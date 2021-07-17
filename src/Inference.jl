"""

    plot_posterior_intervals(model, point_est, prob, args...; kwargs...)

Draw a plot with a point estimate measure of centrality and quantiled credible intervals for easy interpretation of regression models fit in Turing.jl.

Usage:
```julia-repl
plot_posterior_intervals(model, "mean", 0.025, 0.975)
```

Arguments:

- `model` : The Turing.jl model to draw inferences from.
- `point_est` : The measure of point estimate centrality. Options are "mean" or "median".
- `lowerprob` : The lower bound of the credible interval to extract. 0.025 is recommended.
- `upperprob` : The upper bound of the credible interval to extract. 0.975 is recommended.
"""

function plot_posterior_intervals(model, lowerprob::Float64, upperprob::Float64, args...; kwargs...)

    #------------ Argument checks ---------------

    # Numerical probabilities

    isa(lowerprob, Number) || error("`lowerprob` must be a floating point value.")
    isa(upperprob, Number) || error("`upperprob` must be a floating point value.")

    lowerprob + upperprob == 1.0 || error("`lowerprob` and `upperprob` must sum to 1. Consider using lowerprob = 0.025 and upperprob = 0.975 as a starting point for 95% credible intervals.")

    #------------ Reshaping and calcs -----------

    # Fix seed for reproducibility

    Random.seed!(123)

    posteriorDF = DataFrame(model)

    # Reshape into long form DataFrame

    posteriorDF = DataFrames.select(posteriorDF, Not([:iteration, :chain, :lp, :n_steps, :is_accept, :acceptance_rate, :log_density, :hamiltonian_energy, :hamiltonian_energy_error,  :max_hamiltonian_energy_error,  :tree_depth, :numerical_error, :step_size, :nom_step_size]))

    nrows, ncols = size(posteriorDF)

    posteriorDF = DataFrames.stack(posteriorDF, 1:ncols)

    # Extract mean and lower and upper quantiles for each parameter

    posteriorDFMean = combine(groupby(posteriorDF, :variable), :value => mean)
    posteriorDFLower = combine(groupby(posteriorDF, :variable), :value => lower -> quantile(lower, lowerprob))
    posteriorDFUpper = combine(groupby(posteriorDF, :variable), :value => upper -> quantile(upper, upperprob))

    # Rename columns for appropriate usage and interpretability
    
    posteriorDFMean = DataFrames.rename(posteriorDFMean, :value_mean => :mean)
    posteriorDFLower = DataFrames.rename(posteriorDFLower, :value_function => :lower)
    posteriorDFUpper = DataFrames.rename(posteriorDFUpper, :value_function => :upper)

    # Merge all back together

    tmpPost = leftjoin(posteriorDFMean, posteriorDFLower, on = :variable)
    finalPost = leftjoin(tmpPost, posteriorDFUpper, on = :variable)

    #------------ Draw the plot -----------------

    credibleinterval = (upperprob-lowerprob)*100

    gr() # gr backend for graphics

    myPlot = @df finalPost plot(
        :mean,
        :variable,
        xerror = (:lower, :upper),
        legend = false,
        seriestype = :scatter,
        marker = stroke(RGB(24/255,137/255,230/255), RGB(92/255,172/255,238/255)),
        title = string("Posterior ", "mean", "s w/ ", round(credibleinterval, digits = 0), "% credible intervals"),
        xlabel = "Posterior Value",
        ylabel = "Parameter",
    )

    return myPlot
end
