"""

    plot_posterior_intervals(model, args...; kwargs...)

Draw a plot with a point estimate measure of centrality and quantiled credible intervals for easy interpretation of regression models fit in `Turing.jl` and `Soss.jl`.

Usage:
```julia-repl
plot_posterior_intervals(model)
```

Arguments:

- `model` : The Turing.jl or Soss.jl model of class `Chains` or `Array` to draw inferences from.
"""
function plot_posterior_intervals(model, args...; kwargs...)

    # Fix seed for reproducibility

    Random.seed!(123)

    # Turn model objects into DataFrames

    if isa(model, Array)

        myarray = DataFrame(model)
        
        #-------- Wrangle floats --------

        # Reshape

        thefloats = select(myarray, findall(col -> eltype(col) <: Float64, eachcol(myarray)))
        ncols = size(thefloats, 2)
        stackedfloats = stack(thefloats, 1:ncols)

        # Median

        centrefloats = combine(groupby(stackedfloats, :variable), :value => median)
        centrefloats = rename(centrefloats, :value_median => :centre)

        # Lower quantile

        lowerfloats = combine(groupby(stackedfloats, :variable), :value => t -> quantile(t, .025))
        lowerfloats = rename(lowerfloats, :value_function => :lower)

        # Upper quantile

        upperfloats = combine(groupby(stackedfloats, :variable), :value => t -> quantile(t, .975))
        upperfloats = rename(upperfloats, :value_function => :upper)

        # Join together

        finalfloats = leftjoin(centrefloats, lowerfloats, on = :variable)
        finalfloats = leftjoin(finalfloats, upperfloats, on = :variable)

        #-------- Wrangle arrays --------

        # Reshape

        thearrays = select(myarray, findall(col -> eltype(col) <: Array, eachcol(myarray)))
        ncols_arrays = size(thearrays, 2)

        if ncols_arrays > 1
            error("`plot_posterior_intervals` currently only works for models where an array of parameters exists for one type of parameter (e.g. β coefficients store in the array). Other parameters can be stored as regular Float64 columns.")
        else

            # Parse columns and retain only the separated ones

            parsedarrays = expandcol(thearrays, Symbol(names(thearrays)[1]))

            parsedarraysCols = select(parsedarrays, findall(col -> eltype(col) <: Float64, eachcol(parsedarrays)))

            # Reshape

            ncols_res_arrays = size(parsedarraysCols, 2)
            stackedarraysfloats = stack(parsedarraysCols, 1:ncols_res_arrays)

            # Median

            centrefloatsarrays = combine(groupby(stackedarraysfloats, :variable), :value => median)
            centrefloatsarrays = rename(centrefloatsarrays, :value_median => :centre)

            # Lower quantile

            lowerfloatsarrays = combine(groupby(stackedarraysfloats, :variable), :value => t -> quantile(t, .025))
            lowerfloatsarrays = rename(lowerfloatsarrays, :value_function => :lower)

            # Upper quantile

            upperfloatsarrays = combine(groupby(stackedarraysfloats, :variable), :value => t -> quantile(t, .975))
            upperfloatsarrays = rename(upperfloatsarrays, :value_function => :upper)

            # Join together

            finalfloatsarrays = leftjoin(centrefloatsarrays, lowerfloatsarrays, on = :variable)
            finalfloatsarrays = leftjoin(finalfloatsarrays, upperfloatsarrays, on = :variable)
        end

        #-------- Final outputs ---------

        # Merge together

        finalPost = [finalfloats; finalfloatsarrays]
        finalPost = rename(finalPost, :variable => :parameters)

        # Standardise outputs

        variable = finalPost[!, :parameters]
        variable = string.(variable)
        lower = finalPost[!, :lower]
        centre = finalPost[!, :centre]
        upper = finalPost[!, :upper]

    elseif isa(model, Chains)

        # Extract values
        
        finalPost = DataFrame(MCMCChains.quantile(model))

        finalPost = select(finalPost, "parameters" => "parameters", "2.5%" => "lower", 
                            "50.0%" => "centre", "97.5%" => "upper")

        # Standardise outputs

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
                markersize = 5,
                size = (600, 600))

    return myPlot
end



"""

    plot_posterior_hist(model, plot_legend, args...; kwargs...)

Draw a plot with a binned histogram of sampled parameters for easy interpretation of regression models fit in `Turing.jl` and `Soss.jl`.

Usage:
```julia-repl
plot_posterior_hist(model, plot_legend)
```

Details:

Note that to get the function to work, you may need to call it using a splat, such as `plot(plot_posterior_hist(chain, true)...)`.

Arguments:

- `model` : The Turing.jl or Soss.jl model of class `Chains` or `Array` to draw inferences from.
- `plot_legend` : Boolean of whether to add a legend to the plot or not.
"""
function plot_posterior_hist(model::Chains, plot_legend::Bool, args...; kwargs...)

    #------------ Reshaping ---------------------

    # Raw posterior samples

    posteriorDF = DataFrame(model)

    # Retrieve just the model parameter names to avoid the sampler specific columns

    paramsData = DataFrame(MCMCChains.summarize(model))
    params = paramsData[!, :parameters]

    #------------ Draw the plots ----------------

    gr() # gr backend for graphics

    # Draw plot for each parameter

    myPlotArray = [histhelper(posteriorDF, p, plot_legend) for p in params]

    return myPlotArray
end



"""

    plot_posterior_density(model, plot_legend, args...; kwargs...)

Draw a density plot of sampled parameters for easy interpretation of regression models fit in `Turing.jl` and `Soss.jl`.

Usage:
```julia-repl
plot_posterior_density(model, plot_legend)
```

Details:

Note that to get the function to work, you may need to call it using a splat, such as `plot(plot_posterior_density(chain, true)...)`.

Arguments:

- `model` : The Turing.jl or Soss.jl model of class `Chains` or `Array` to draw inferences from.
- `plot_legend` : Boolean of whether to add a legend to the plot or not.
"""
function plot_posterior_density(model::Chains, plot_legend::Bool, args...; kwargs...)

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
