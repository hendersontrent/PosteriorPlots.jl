using Base: Symbol
"""

    plot_posterior_intervals(model, point_est, prob, args...; kwargs...)

Draw a plot with a point estimate measure of centrality and quantiled credible intervals for easy interpretation of models fit in PPLs such as `Turing.jl` or `Soss.jl`.

Usage:
```julia-repl
plot_posterior_intervals(model, point_est, prob)
```

Arguments:

- `model` : The model to draw inferences from.
- `point_est` : The type of point estimate to use.
- `prob` : The probability of the credible interval to calculate.
"""
function plot_posterior_intervals(model, point_est::Symbol = median, prob::Float64 = 0.95, args...; kwargs...)

    # Fix seed for reproducibility

    Random.seed!(123)

    # Check point estimate argument

    (point_est == mean || point_est == median) || error("`point_est` should be a Symbol of either `mean` or `median`.")

    # Check prob argument

    prob > 0 || error("`prob` should be a single Float64 value of 0 < prob < 1.")
    prob < 1 || error("`prob` should be a single Float64 value of 0 < prob < 1.")
    quantileRange = generatequantile(prob)

    # Turn model objects into DataFrames

    if isa(model, Array)

        myarray = DataFrame(model)
        
        #-------- Wrangle floats --------

        # Reshape

        thefloats = select(myarray, findall(col -> eltype(col) <: Float64, eachcol(myarray)))
        ncols = size(thefloats, 2)
        stackedfloats = stack(thefloats, 1:ncols)

        # Median and credible intervals

        finalfloats = combine(groupby(stackedfloats, :variable), :value => point_est => :centre, :value => (t -> quantile(t, quantileRange[1])) => :lower, :value => (t -> quantile(t, quantileRange[2])) => :upper)

        #-------- Wrangle arrays --------

        # Reshape

        thearrays = select(myarray, findall(col -> eltype(col) <: Array, eachcol(myarray)))
        ncols_arrays = size(thearrays, 2)

        if ncols_arrays > 1
            error("`plot_posterior_intervals` currently only works for models where an array of parameters exists for one type of parameter (e.g. β coefficients stored in the array). Other parameters can be stored as regular Float64 columns.")
        else

            # Parse columns and retain only the separated ones

            parsedarrays = expandcol(thearrays, Symbol(names(thearrays)[1]))

            parsedarraysCols = select(parsedarrays, findall(col -> eltype(col) <: Float64, eachcol(parsedarrays)))

            # Reshape

            ncols_res_arrays = size(parsedarraysCols, 2)
            stackedarraysfloats = stack(parsedarraysCols, 1:ncols_res_arrays)

            # Median and credible intervals

            finalfloatsarrays = combine(groupby(stackedarraysfloats, :variable), :value => point_est => :centre, :value => (t -> quantile(t, quantileRange[1])) => :lower, :value => (t -> quantile(t, quantileRange[2])) => :upper)
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
        
        finalPost = DataFrame(MCMCChains.quantile(model; q = [quantileRange[1], 0.50, quantileRange[2]]))
        my_names = ["parameters", "lower", "centre", "upper"]
        finalPost = rename!(finalPost, my_names)

        # Standardise outputs

        variable = finalPost[!, :parameters]
        variable = string.(variable)
        lower = finalPost[!, :lower]
        centre = finalPost[!, :centre]
        upper = finalPost[!, :upper]
    
    elseif isa(model, MultiChain)

        # Wrangle into tidy format

        finalPost = DataFrame(model)
        ncols = size(finalPost, 2)
        finalPost = stack(finalPost, 1:ncols)

        finalPost = combine(groupby(finalPost, :variable), :value => point_est => :centre, :value => (t -> quantile(t, quantileRange[1])) => :lower, :value => (t -> quantile(t, quantileRange[2])) => :upper)

        # Standardise outputs

        finalPost = rename(finalPost, :variable => :parameters)
        variable = finalPost[!, :parameters]
        variable = string.(variable)
        lower = finalPost[!, :lower]
        centre = finalPost[!, :centre]
        upper = finalPost[!, :upper]
    else
        error("`model` must be an object of type `Chains`, `Array`, or `MultiChain`.")
    end

    #------------ Draw the plot -----------------

    gr() # gr backend for graphics

    myPlot = plot(centre, variable, xerror = (centre .- lower, upper .- centre), st = :scatter,
                title = string("Posterior", point_est, "s with credible intervals"),
                xlabel = "Value",
                ylabel = "Parameter",
                legend = false,
                markersize = 5,
                size = (600, 600))

    return myPlot
end



"""

    plot_posterior_hist(model, point_est, plot_legend, args...; kwargs...)

Draw a plot with a binned histogram of sampled parameters for easy interpretation of models fit in PPLs such as `Turing.jl` or `Soss.jl`.

Usage:
```julia-repl
plot_posterior_hist(model, point_est, plot_legend)
```

Details:

Note that to get the function to work, you may need to call it using a splat, such as `plot(plot_posterior_hist(model, plot_legend)...)`.

Arguments:

- `model` : The model to draw inferences from.
- `point_est` : The type of point estimate to use.
- `plot_legend` : Boolean of whether to add a legend to the plot or not.
"""
function plot_posterior_hist(model, point_est::Symbol = median, plot_legend::Bool = true, args...; kwargs...)

    # Check point estimate argument

    (point_est == mean || point_est == median) || error("`point_est` should be a Symbol of either `mean` or `median`.")

    if isa(model, Array)

        myarray = DataFrame(model)

        #-------- Wrangle floats --------

        thefloats = select(myarray, findall(col -> eltype(col) <: Float64, eachcol(myarray)))

        #-------- Wrangle arrays --------

        thearrays = select(myarray, findall(col -> eltype(col) <: Array, eachcol(myarray)))
        ncols_arrays = size(thearrays, 2)
        
        if ncols_arrays > 1
            error("`plot_posterior_intervals` currently only works for models where an array of parameters exists for one type of parameter (e.g. β coefficients stored in the array). Other parameters can be stored as regular Float64 columns.")
        else
        
            # Parse columns and retain only the separated ones
        
            parsedarrays = expandcol(thearrays, Symbol(names(thearrays)[1]))
        
            parsedarraysCols = select(parsedarrays, findall(col -> eltype(col) <: Float64, eachcol(parsedarrays)))
        end

        #-------- Merge together --------

        posteriorDF = [thefloats parsedarraysCols]
        params = propertynames(posteriorDF)

    elseif isa(model, Chains)

        posteriorDF = DataFrame(model)

        # Retrieve just the model parameter names to avoid the sampler specific columns

        paramsData = DataFrame(MCMCChains.summarize(model))
        params = paramsData[!, :parameters]

    elseif isa(model, MultiChain)

        posteriorDF = DataFrame(model)
    
    else
        error("`model` must be an object of type `Chains`, `Array`, or `MultiChain`.")
    end

    #------------ Draw the plots ----------------

    gr() # gr backend for graphics

    # Draw plot for each parameter

    myPlotArray = [histhelper(posteriorDF, point_est, p, plot_legend) for p in params]

    return myPlotArray
end



"""

    plot_posterior_density(model, point_est, prob, plot_legend, args...; kwargs...)

Draw a density plot of sampled parameters for easy interpretation of models fit in PPLs such as `Turing.jl` or `Soss.jl`.

Usage:
```julia-repl
plot_posterior_density(model, point_est, prob, plot_legend)
```

Details:

Note that to get the function to work, you may need to call it using a splat, such as `plot(plot_posterior_density(model, point_est, plot_legend)...)`.

Arguments:

- `model` : The model to draw inferences from.
- `point_est` : The type of point estimate to use.
- `prob` : The probability of the credible interval to calculate.
- `plot_legend` : Boolean of whether to add a legend to the plot or not.
"""
function plot_posterior_density(model, point_est::Symbol = median, prob::Float64 = 0.95, plot_legend::Bool = true, args...; kwargs...)

    # Check point estimate argument

    (point_est == mean || point_est == median) || error("`point_est` should be a Symbol of either `mean` or `median`.")
    
    # Check prob argument

    prob > 0 || error("`prob` should be a single Float64 value of 0 < prob < 1.")
    prob < 1 || error("`prob` should be a single Float64 value of 0 < prob < 1.")
    quantileRange = generatequantile(prob)

    if isa(model, Array)

        myarray = DataFrame(model)

        #-------- Wrangle floats --------

        thefloats = select(myarray, findall(col -> eltype(col) <: Float64, eachcol(myarray)))

        #-------- Wrangle arrays --------

        thearrays = select(myarray, findall(col -> eltype(col) <: Array, eachcol(myarray)))
        ncols_arrays = size(thearrays, 2)
        
        if ncols_arrays > 1
            error("`plot_posterior_intervals` currently only works for models where an array of parameters exists for one type of parameter (e.g. β coefficients stored in the array). Other parameters can be stored as regular Float64 columns.")
        else
        
            # Parse columns and retain only the separated ones
        
            parsedarrays = expandcol(thearrays, Symbol(names(thearrays)[1]))
        
            parsedarraysCols = select(parsedarrays, findall(col -> eltype(col) <: Float64, eachcol(parsedarrays)))
        end

        #-------- Merge together --------

        posteriorDF = [thefloats parsedarraysCols]
        params = propertynames(posteriorDF)

    elseif isa(model, Chains)

        posteriorDF = DataFrame(model)

        # Retrieve just the model parameter names to avoid the sampler specific columns

        paramsData = DataFrame(MCMCChains.summarize(model))
        params = paramsData[!, :parameters]

    elseif isa(model, MultiChain)

        posteriorDF = DataFrame(model)
    
    else
        error("`model` must be an object of type `Chains`, `Array`, or `MultiChain`.")
    end

    #------------ Draw the plots ----------------

    gr() # gr backend for graphics

    # Draw plot for each parameter

    myPlotArray = [denshelper(posteriorDF, point_est, p, quantileRange[1], quantileRange[2], plot_legend) for p in params]

    return myPlotArray
end
