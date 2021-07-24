"""

    plot_posterior_intervals(model, args...; kwargs...)

Draw a plot with a point estimate measure of centrality and quantiled credible intervals for easy interpretation of regression models fit in `Turing.jl` and `Soss.jl`.

Usage:
```julia-repl
plot_posterior_intervals(model)
```

Arguments:

- `model` : The Turing.jl or Soss.jl model to draw inferences from.
"""
function plot_posterior_intervals(model, args...; kwargs...)

    # Fix seed for reproducibility

    Random.seed!(123)

    # Turn model objects into DataFrames

    if isa(model, Array)

        myarray = DataFrame(model)
        
        # Wrangle floats

        thefloats = select(myarray, findall(col -> eltype(col) <: Float64, eachcol(myarray)))
        ncols = size(thefloats, 2)
        stackedfloats = stack(thefloats, 1:ncols)
        centrefloats = combine(groupby(stackedfloats, :variable), :value => median)
        centrefloats = rename(centrefloats, :value_median => :centre)
        lowerfloats = combine(groupby(stackedfloats, :variable), :value => t -> quantile(t, .025))
        lowerfloats = rename(lowerfloats, :value_function => :lower)
        upperfloats = combine(groupby(stackedfloats, :variable), :value => t -> quantile(t, .975))
        upperfloats = rename(upperfloats, :value_function => :upper)
        finalfloats = leftjoin(centrefloats, lowerfloats, on = :variable)
        finalfloats = leftjoin(finalfloats, upperfloats, on = :variable)

        # Wrangle arrays

        x

        # Bind together

        x

        # Compute quantiles

        x

    elseif isa(model, Chains)
        
        finalPost = DataFrame(MCMCChains.quantile(model))

        finalPost = select(finalPost, "parameters" => "parameters", "2.5%" => "lower", 
                            "50.0%" => "centre", "97.5%" => "upper")

        variable = finalPost[!, :parameters]
        variable = string.(variable)
        lower = finalPost[!, :lower]
        centre = finalPost[!, :centre]
        upper = finalPost[!, :upper]
    else
        error("`model` must be an object of type Chains or Array.")
    end

    #------------ Draw the plot -----------------

    gr() # gr backend for graphics
    mycolor = theme_palette(:auto).colors.colors[1]

    myPlot = plot(centre, variable, xerror = (centre .- lower, upper .- centre), st = :scatter,
                title = "Posterior medians w/ 95% credible intervals",
                xlabel = "Value",
                ylabel = "Parameter",
                legend = false,
                marker = stroke(mycolor, mycolor),
                markersize = 6,
                size = (600, 600))

    return myPlot
end



"""

    plot_posterior_hist(model, args...; kwargs...)

Draw a plot with a binned histogram of sampled parameters for easy interpretation of regression models fit in Turing.jl.

Usage:
```julia-repl
plot_posterior_hist(model)
```

Details:

Note that to get the function to work, you need to call it using a splat, such as `plot(plot_posterior_hist(chain)...)`.

Arguments:

- `model` : The Turing.jl model to draw inferences from.
"""
function plot_posterior_hist(model::Chains, args...; kwargs...)

    #------------ Reshaping ---------------------

    # Raw posterior samples

    posteriorDF = DataFrame(model)

    # Retrieve just the model parameter names to avoid the sampler specific columns

    paramsData = DataFrame(MCMCChains.summarize(model))
    params = paramsData[!, :parameters]

    #------------ Draw the plots ----------------

    gr() # gr backend for graphics

    # Draw plot for each parameter

    myPlotArray = [histhelper(posteriorDF, p) for p in params]

    return myPlotArray
end



"""

    plot_posterior_density(model, args...; kwargs...)

Draw a density plot of sampled parameters for easy interpretation of regression models fit in Turing.jl.

Usage:
```julia-repl
plot_posterior_density(model)
```

Details:

Note that to get the function to work, you need to call it using a splat, such as `plot(plot_posterior_density(chain)...)`.

Arguments:

- `model` : The Turing.jl model to draw inferences from.
"""
function plot_posterior_density(model::Chains, args...; kwargs...)

    #------------ Reshaping ---------------------

    # Raw posterior samples

    posteriorDF = DataFrame(model)

    # Retrieve just the model parameter names to avoid the sampler specific columns

    paramsData = DataFrame(MCMCChains.summarize(model))
    params = paramsData[!, :parameters]

    #------------ Draw the plots ----------------

    gr() # gr backend for graphics

    # Draw plot for each parameter

    myPlotArray = [denshelper(posteriorDF, p) for p in params]

    return myPlotArray
end
