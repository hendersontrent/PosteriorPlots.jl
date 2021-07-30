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
    mycolor = theme_palette(:auto).colors.colors[2]
    Random.seed!(123) # Fix seed for reproducibility
    myPlot = plot()

    # Wrangle from wide to long

    if isa(yrep, Array)
        tmp = DataFrame(yrep)
    else
        tmp = yrep
    end

    # Plot posterior draws

    for n in 1:nrows

        tmp2 = DataFrame(tmp[n, :])
        tmp2 = stack(tmp2, 1:length2)

        # Add iteration to the plot

        if n == nrows
            plot!(tmp2[!, :value], linealpha = 0.2, xlabel = "", ylabel = "", label = "yrep",
            seriestype = :density, color = :grey, size = (400, 400))
        else
            plot!(tmp2[!, :value], linealpha = 0.2, xlabel = "", ylabel = "", label = "",
            seriestype = :density, color = :grey, size = (400, 400))
        end
    end

    # Plot actual data

    plot!(y, linealpha = 0.9, xlabel = "Value", ylabel = "Density", label = "y",
        seriestype = :density, color = mycolor, legend = plot_legend,
        title = "Posterior Predictive Check", linewidth = 1.5)

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

    mycolor = theme_palette(:auto).colors.colors[1]
    mycolor2 = theme_palette(:auto).colors.colors[2]

    # Draw plot

    myPlot = plot(tmp[!, :value_median], seriestype = :histogram, fillalpha = 0.6, 
                  xlabel = "Value", ylabel = "", label = "yrep",
                  color = mycolor, title = "Posterior Predictive Check", size = (400, 400),
                  legend = plot_legend)

    plot!([m], seriestype = "vline", color = mycolor2, label = "y", linewidth = 2.5)

    return myPlot
end
