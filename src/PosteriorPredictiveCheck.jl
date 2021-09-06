"""

    plot_density_check(y, yrep, plot_legend, args...; kwargs...)

Draw a density plot of a random sample of draws from the response variable posterior distribution against the density estimation of the actual data to visualise model fit.

Usage:
```julia-repl
plot_density_check(y, yrep, plot_legend)
```

Details:

The `yrep` matrix should have individual draws from the posterior distribution in rows and unique values (matching the length of the `y` vector in length) in columns.

Arguments:

- `y` : The vector of response variable values.
- `yrep` : The Draws x Values matrix of posterior predictions.
- `plot_legend` : Boolean of whether to add a legend to the plot or not.
"""
function plot_density_check(y::Array, yrep, plot_legend::Bool, args...; kwargs...)

    # Check object sizes

    size(y, 2) == 1 || error("`y` should have a dimension of N x 1.")
    length1 = size(y, 1)

    if isa(yrep, Array)
        length2 = size(yrep, 2)
        nrows = size(yrep, 1)
    elseif isa(yrep, DataFrame)
        length2 = size(yrep, 2)
        nrows = size(yrep, 1)
    else
        error("`yrep` should be an object of class `Array` or `DataFrame` containing Draws x Values matrix information.")
    end 

    length1 == length2 || error("Number of columns in `yrep` should match the length of vector `y`.")

    #-------- Draw plot --------

    gr() # gr backend for graphics
    drawscolour = cgrad(:blues)[1]
    actualcolour = cgrad(:blues)[2]
    Random.seed!(123) # Fix seed for reproducibility
    myPlot = plot()

    # Check if yrep matrix is all integers or numerics 
    # to infer discrete/continuous model for plot

    if all(isa.(yrep, Integer)) && all(isa.(y, Integer))
        plotType = "discrete"
    else
        plotType = "continuous"
    end

    # Wrangle from wide to long

    if isa(yrep, Array)
        tmp = DataFrame(yrep)
    else
        tmp = yrep
    end

    #-----------------------
    # Convert to proportions
    #-----------------------

    # y vector

    y1 = y/sum(y)

    # yrep array

    m = median(yrep)
    lowerquantile = quantile(yrep, 0.025)
    upperquantile = quantile(yrep, 0.975)

    #----------
    # Draw plot
    #----------

    if plotType == "discrete"

        # Draw plot

        myPlot = plot(x = y, y = y1, seriestype = :barbins, fillalpha = 0.5, 
                     xlabel = "Value", ylabel = "Proportion of Values", 
                     label = "y", color = actualcolour, 
                     title = "Posterior Predictive Check", 
                     size = (600, 600), legend = plot_legend)

        # Add draw mean

        plot!(x = y, y = m, seriestype = :scatter, color = drawscolour,
              yerror = (lower, upper), label = "yrep", legend = plot_legend)

    else 
        # Plot posterior draws

        for n in 1:nrows

            tmp2 = DataFrame(tmp[n, :])
            tmp2 = stack(tmp2, 1:length2)

            # Add iteration to the plot

            if n == nrows
                plot!(tmp2[!, :value], linealpha = 0.4, xlabel = "", ylabel = "", label = "yrep",
                seriestype = :density, color = drawscolour, size = (400, 400))
            else
                plot!(tmp2[!, :value], linealpha = 0.4, xlabel = "", ylabel = "", label = "",
                seriestype = :density, color = drawscolour, size = (400, 400))
            end
        end

        # Plot actual data

        plot!(y, linealpha = 1, xlabel = "Value", ylabel = "Density", label = "y",
            seriestype = :density, color = actualcolour, legend = plot_legend,
            title = "Posterior Predictive Check", linewidth = 2)
    end

    return myPlot
end



"""

    plot_hist_check(y, yrep, plot_legend, args...; kwargs...)

Draw a plot with a binned histogram of posterior-predicted response variable values against a measure of centrality of the actual data to visualise model fit.

Usage:
```julia-repl
plot_hist_check(y, yrep, plot_legend)
```

Arguments:

- `y` : The vector of response variable values.
- `yrep` : The Draws x Values matrix of posterior predictions.
- `plot_legend` : Boolean of whether to add a legend to the plot or not.
"""
function plot_hist_check(y::Array, yrep, plot_legend::Bool, args...; kwargs...)

    # Check object sizes

    size(y, 2) == 1 || error("`y` should have a dimension of N x 1.")
    length1 = size(y, 1)
    
    if isa(yrep, Array)
        length2 = size(yrep, 2)
        nrows = size(yrep, 1)
    elseif isa(yrep, DataFrame)
        length2 = size(yrep, 2)
        nrows = size(yrep, 1)
    else
        error("`yrep` should be an object of class `Array` or `DataFrame` containing Draws x Values matrix information.")
    end 
    
    length1 == length2 || error("Number of columns in `yrep` should match the length of vector `y`.")

    # Compute median for real data vector

    m = median(y)

    # Wrangle posterior draws from wide to long and compute median for each value

    tmp = DataFrame(yrep)
    tmp = stack(tmp, 1:length2)
    tmp = combine(groupby(tmp, :variable), :value => median)

    # Set up graphics helpers

    drawscolour = cgrad(:blues)[1]
    actualcolour = cgrad(:blues)[2]

    # Draw plot

    myPlot = plot(tmp[!, :value_median], seriestype = :histogram, fillalpha = 0.5, 
                  xlabel = "Value", ylabel = "", label = "yrep",
                  color = drawscolour, title = "Posterior Predictive Check", size = (400, 400),
                  legend = plot_legend)

    plot!([m], seriestype = "vline", color = actualcolour, label = "y", linewidth = 2.5)

    return myPlot
end



"""

    plot_ecdf_check(y, yrep, plot_legend, args...; kwargs...)

Draw an empirical cumulative density function plot of a random sample of draws from the response variable posterior distribution against the density estimation of the actual data to visualise model fit.

Usage:
```julia-repl
plot_ecdf_check(y, yrep, plot_legend)
```

Details:

The `yrep` matrix should have individual draws from the posterior distribution in rows and unique values (matching the length of the `y` vector in length) in columns.

Arguments:

- `y` : The vector of response variable values.
- `yrep` : The Draws x Values matrix of posterior predictions.
- `plot_legend` : Boolean of whether to add a legend to the plot or not.
"""
function plot_ecdf_check(y::Array, yrep, plot_legend::Bool, args...; kwargs...)

    # Check object sizes

    size(y, 2) == 1 || error("`y` should have a dimension of N x 1.")
    length1 = size(y, 1)

    if isa(yrep, Array)
        length2 = size(yrep, 2)
        nrows = size(yrep, 1)
    elseif isa(yrep, DataFrame)
        length2 = size(yrep, 2)
        nrows = size(yrep, 1)
    else
        error("`yrep` should be an object of class `Array` or `DataFrame` containing Draws x Values matrix information.")
    end 

    length1 == length2 || error("Number of columns in `yrep` should match the length of vector `y`.")

    #-------- Draw plot --------

    gr() # gr backend for graphics
    drawscolour = cgrad(:blues)[1]
    actualcolour = cgrad(:blues)[2]
    Random.seed!(123) # Fix seed for reproducibility
    myPlot = plot()

    # Wrangle from wide to long

    if isa(yrep, Array)
        tmp = DataFrame(yrep)
    else
        tmp = yrep
    end

    # Compute ECDF and plot posterior draws

    for n in 1:nrows

        tmp2 = DataFrame(tmp[n, :])
        tmp2 = stack(tmp2, 1:length2)

        # ECDF calculation

        myECDF = StatsBase.ecdf(tmp2[!, :value])

        # Add iteration to the plot

        if n == nrows
            plot!(myECDF, linealpha = 0.4, xlabel = "", ylabel = "", label = "yrep",
            color = drawscolour, size = (400, 400))
        else
            plot!(myECDF, linealpha = 0.4, xlabel = "", ylabel = "", label = "",
            color = drawscolour, size = (400, 400))
        end
    end

    # Compute ECDF of actual data and add to plot

    yECDF = StatsBase.ecdf(y)

    if plot_legend == true
        plot!(yECDF, linealpha = 1, xlabel = "Value", ylabel = "Density", label = "y",
        color = actualcolour, legend = :bottomright, title = "Posterior Predictive Check",
        linewidth = 1.5)
    else
        plot!(yECDF, linealpha = 1, xlabel = "Value", ylabel = "Density", label = "y",
        color = actualcolour, legend = false, title = "Posterior Predictive Check", linewidth = 1.5)
    end

    return myPlot
end
