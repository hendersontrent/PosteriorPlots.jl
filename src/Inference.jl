"""

    plot_posterior_intervals(model, lowerprob, upperprob, args...; kwargs...)

Draw a plot with a point estimate measure of centrality and quantiled credible intervals for easy interpretation of regression models fit in Turing.jl.

Usage:
```julia-repl
plot_posterior_intervals(model, 0.025, 0.975)
```

Arguments:

- `model` : The Turing.jl model to draw inferences from.
- `lowerprob` : The lower bound of the credible interval to extract. 0.025 is recommended to start with.
- `upperprob` : The upper bound of the credible interval to extract. 0.975 is recommended to start with.
"""

function plot_posterior_intervals(model::Chains, lowerprob::Float64, upperprob::Float64, args...; kwargs...)

    #------------ Argument checks ---------------

    # Model

    isa(model, Chains) || error("`model` must be an object of class Chains created by Turing.jl.")

    # Numerical probabilities

    isa(lowerprob, Number) || error("`lowerprob` must be a floating point value.")
    isa(upperprob, Number) || error("`upperprob` must be a floating point value.")

    lowerprob + upperprob == 1.0 || error("`lowerprob` and `upperprob` must sum to 1. Consider using lowerprob = 0.025 and upperprob = 0.975 as a starting point for 95% credible intervals.")

    #------------ Reshaping and calcs -----------

    # Fix seed for reproducibility

    Random.seed!(123)

    # Convert model to DataFrame

    posteriorDF = DataFrame(model)

    # Remove sampler-specific columns as only model parameters are of interest here

    posteriorDF = DataFrames.select(posteriorDF, Not([:iteration, :chain, :lp, :n_steps, :is_accept, :acceptance_rate, :log_density, :hamiltonian_energy, :hamiltonian_energy_error,  :max_hamiltonian_energy_error,  :tree_depth, :numerical_error, :step_size, :nom_step_size]))

    # Reshape into long form DataFrame for summarisation

    nrows, ncols = size(posteriorDF)

    posteriorDF = DataFrames.stack(posteriorDF, 1:ncols)

    # Extract median and lower and upper quantiles for each parameter

    posteriorDFPoint = combine(groupby(posteriorDF, :variable), :value => median)
    posteriorDFLower = combine(groupby(posteriorDF, :variable), :value => lower -> quantile(lower, lowerprob))
    posteriorDFUpper = combine(groupby(posteriorDF, :variable), :value => upper -> quantile(upper, upperprob))

    # Rename columns for appropriate usage and interpretability

    posteriorDFPoint = DataFrames.rename(posteriorDFPoint, :value_median => :centre)
    posteriorDFLower = DataFrames.rename(posteriorDFLower, :value_function => :lower)
    posteriorDFUpper = DataFrames.rename(posteriorDFUpper, :value_function => :upper)

    # Merge all back together

    tmpPost = leftjoin(posteriorDFPoint, posteriorDFLower, on = :variable)
    finalPost = leftjoin(tmpPost, posteriorDFUpper, on = :variable)

    #------------ Draw the plot -----------------

    gr() # gr backend for graphics
    credibleinterval = (upperprob-lowerprob)*100
    mycolor = theme_palette(:auto).colors.colors[1]

    myPlot = @df finalPost plot(
        :centre,
        :variable,
        xerror = (:lower, :upper),
        legend = false,
        seriestype = :scatter,
        marker = stroke(mycolor, mycolor),
        title = string("Posterior medians w/ ", round(credibleinterval, digits = 0), "% intervals"),
        xlabel = "Posterior Value",
        ylabel = "Parameter",
    )

    return myPlot
end



"""

    plot_posterior_hist(model, parameter, args...; kwargs...)

Draw a plot with a binned histogram of sampled parameters for easy interpretation of regression models fit in Turing.jl.

Usage:
```julia-repl
plot_posterior_hist(model, parameter)
```

Arguments:

- `model` : The Turing.jl model to draw inferences from.
- `parameter` : The parameter of interest to plot.
"""


function plot_posterior_hist(model::Chains, parameter::Symbol)
    
    #------------ Argument checks ---------------

    # Model

    isa(model, Chains) || error("`model` must be an object of class Chains created by Turing.jl.")

    isa(parameter, Symbol) || error("`parameter` must be an object of class Symbol specifying an exact parameter name from your model. For example, if you wanted to plot an intercept term that was called β0, you would enter :β0 in the function argument.")

    #------------ Reshaping ---------------------

    posteriorDF = DataFrame(model)
    thevec = convert(Vector, posteriorDF[!,parameter])
    m = median(thevec)

    #------------ Draw the plots ----------------

    gr() # gr backend for graphics
    mycolor = theme_palette(:auto).colors.colors[1]
    mycolor2 = theme_palette(:auto).colors.colors[2]

    # Draw plot

    plot(thevec, title = parameter, seriestype = :histogram,
         fillalpha = 0.6, xlabel = "Posterior Value", ylabel = "", label = "",
         color = mycolor)

    myPlot = plot!([m], seriestype = "vline", color = mycolor2, label = "Median")

    return myPlot
end



"""

    plot_posterior_density(model, parameter, args...; kwargs...)

Draw a density plot of sampled parameters for easy interpretation of regression models fit in Turing.jl.

Usage:
```julia-repl
plot_posterior_area(model, parameter)
```

Arguments:

- `model` : The Turing.jl model to draw inferences from.
- `parameter` : The parameter of interest to plot.
"""

function plot_posterior_density(model::Chains, parameter::Symbol, args...; kwargs...)
        
    #------------ Argument checks ---------------

    isa(model, Chains) || error("`model` must be an object of class Chains created by Turing.jl.")

    isa(parameter, Symbol) || error("`parameter` must be an object of class Symbol specifying an exact parameter name from your model. For example, if you wanted to plot an intercept term that was called β0, you would enter :β0 in the function argument.")

    #------------ Reshaping ---------------------

    posteriorDF = DataFrame(model)
    thevec = convert(Vector, posteriorDF[!,parameter])
    m = median(thevec)
    y = kde(thevec)
    lowerquantile = quantile(thevec, 0.025)
    upperquantile = quantile(thevec, 0.975)

    #------------ Draw the plots ----------------

    gr() # gr backend for graphics
    mycolor = theme_palette(:auto).colors.colors[1]

    # Draw plot

    plot(thevec, title = parameter, fillalpha = 0.8, 
         xlabel = "Posterior Value", ylabel = "Density", label = "",
         seriestype = :density, color = mycolor)

    plot!(range(lowerquantile, stop = upperquantile, length = 100), thevec -> pdf(y,thevec), color = mycolor, 
          fill = (0, 0.4, mycolor),
          label = "95% credible interval", legend = true)

    myPlot = plot!([m], seriestype = "vline", color = mycolor, label = "Median")

    return myPlot
end
