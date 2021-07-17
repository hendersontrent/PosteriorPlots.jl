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

function plot_posterior_intervals(model, point_est, lowerprob::Float64, upperprob::Float64, args...; kwargs...)

    #------------ Argument checks ---------------

    # Point estimate method

    (point_est != "mean" || point_est != "median") || error("`point_est` should be a string specification of either 'mean' or 'median'.")

    # Numerical probabilities

    isa(lowerprob, Number) || error("`lowerprob` must be a floating point value.")
    isa(upperprob, Number) || error("`upperprob` must be a floating point value.")

    lowerprob + upperprob == 1.0 || error("`lowerprob` and `upperprob` must sum to 1. Consider using lowerprob = 0.025 and upperprob = 0.975 as a starting point for 95% credible intervals.")

    #------------ Reshaping and calcs -----------

    # Fix seed for reproducibility

    Random.seed!(123)

    posteriorDF = DataFrame(model)

    # Remove sampler-specific columns as only model parameters are of interest here

    posteriorDF = DataFrames.select(posteriorDF, Not([:iteration, :chain, :lp, :n_steps, :is_accept, :acceptance_rate, :log_density, :hamiltonian_energy, :hamiltonian_energy_error,  :max_hamiltonian_energy_error,  :tree_depth, :numerical_error, :step_size, :nom_step_size]))

    # Reshape into long form DataFrame for summarisation

    nrows, ncols = size(posteriorDF)

    posteriorDF = DataFrames.stack(posteriorDF, 1:ncols)

    # Extract mean and lower and upper quantiles for each parameter

    if point_est == "mean"
        posteriorDFPoint = combine(groupby(posteriorDF, :variable), :value => mean)
    else
        posteriorDFPoint = combine(groupby(posteriorDF, :variable), :value => median)
    end

    posteriorDFLower = combine(groupby(posteriorDF, :variable), :value => lower -> quantile(lower, lowerprob))
    posteriorDFUpper = combine(groupby(posteriorDF, :variable), :value => upper -> quantile(upper, upperprob))

    # Rename columns for appropriate usage and interpretability

    if point_est == "mean"
        posteriorDFPoint = DataFrames.rename(posteriorDFPoint, :value_mean => :centre)
    else
        posteriorDFPoint = DataFrames.rename(posteriorDFPoint, :value_median => :centre)
    end
    
    posteriorDFLower = DataFrames.rename(posteriorDFLower, :value_function => :lower)
    posteriorDFUpper = DataFrames.rename(posteriorDFUpper, :value_function => :upper)

    # Merge all back together

    tmpPost = leftjoin(posteriorDFPoint, posteriorDFLower, on = :variable)
    finalPost = leftjoin(tmpPost, posteriorDFUpper, on = :variable)

    #------------ Draw the plot -----------------

    credibleinterval = (upperprob-lowerprob)*100

    gr() # gr backend for graphics

    myPlot = @df finalPost plot(
        :centre,
        :variable,
        xerror = (:lower, :upper),
        legend = false,
        seriestype = :scatter,
        marker = stroke(RGB(24/255,137/255,230/255), RGB(92/255,172/255,238/255)),
        title = string("Posterior ", point_est, "s w/ ", round(credibleinterval, digits = 0), "% intervals"),
        xlabel = "Posterior Value",
        ylabel = "Parameter",
    )

    return myPlot
end



"""

    plot_posterior_hist(model, args...; kwargs...)

Draw a plot with a binned histogram of sampled parameters for easy interpretation of regression models fit in Turing.jl.

Usage:
```julia-repl
plot_posterior_hist(model)
```

Arguments:

- `model` : The Turing.jl model to draw inferences from.
"""


function plot_posterior_hist(model)
    
    x

end



"""

    plot_posterior_area(model, parameter, prob, args...; kwargs...)

Draw a plot with a binned histogram of sampled parameters for easy interpretation of regression models fit in Turing.jl.

Usage:
```julia-repl
plot_posterior_area(model, parameter, prob, prob_outer)
```

Arguments:

- `model` : The Turing.jl model to draw inferences from.
- `parameter` : The parameter of interest to plot.
- `prob` : The probability for the shaded portion of the density curve.
"""

function plot_posterior_area(model, parameter, prob args...; kwargs...)
    
    x
    
end
