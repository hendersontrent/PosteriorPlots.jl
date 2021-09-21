"""

    plot_posterior_check(y, yrep, point_est, prob, plot_legend, args...; kwargs...)

Draw a density plot of a random sample of draws from the response variable posterior distribution against the density estimation of the actual data to visualise model fit.

Usage:
```julia-repl
plot_posterior_check(y, yrep, point_est, prob, plot_legend)
```

Details:

The `yrep` matrix should have individual draws from the posterior distribution in rows and unique values (matching the length of the `y` vector in length) in columns.

Arguments:

- `y` : The vector of response variable values.
- `yrep` : The Draws x Values matrix of posterior predictions.
- `point_est` : The type of point estimate to use.
- `prob` : The probability of the credible interval to calculate.
- `plot_legend` : Boolean of whether to add a legend to the plot or not.
"""
function plot_posterior_check(y::Array, yrep, point_est::String = "median", prob::Float64 = 0.95, plot_legend::Bool = true, args...; kwargs...)

    # Check point estimate argument

    (point_est == "mean" || point_est == "median") || error("`point_est` should be a String of either 'mean' or 'median'.")
    
    # Check prob argument

    prob > 0 || error("`prob` should be a single Float64 value of 0 < prob < 1.")
    prob < 1 || error("`prob` should be a single Float64 value of 0 < prob < 1.")
    quantileRange = generatequantile(prob)

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
    actualcolour = cgrad(:blues)[1]
    drawscolour = cgrad(:blues)[2]
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

    #----------
    # Draw plot
    #----------

    if plotType == "discrete"

        #-----------------------
        # Convert to proportions
        #-----------------------

        # y vector

        a = countmap(y)
        b = DataFrame(hcat([[key, val] for (key, val) in a]...)')
        b = rename(b, :x1 => :value)
        b = rename(b, :x2 => :tally)
        b.props = b.tally / sum(b.tally)

        # yrep array - compute proportions for each simulated draw, median and intervals

        tmp.iteration = rownumber.(eachrow(tmp)) # Add iteration IDs
        tmp = stack(tmp, 1:size(tmp,2)-1)
        tmp = combine(groupby(tmp, [:iteration, :value]), nrow => :count)

        tmp = combine(groupby(tmp, :iteration), :count => (x -> x ./ sum(x)) => :props, :value => :value)

        if point_est == "median"
            tmp = combine(groupby(tmp, [:value]), :props => median => :centre, :props => (x -> quantile(x, quantileRange[1])) => :lower, :props => (x -> quantile(x, quantileRange[2])) => :upper)
        else
            tmp = combine(groupby(tmp, [:value]), :props => mean => :centre, :props => (x -> quantile(x, quantileRange[1])) => :lower, :props => (x -> quantile(x, quantileRange[2])) => :upper)
        end

        # Get margins to extend vertically from point estimate for yerror bars on plot

        tmp.lower_margin = tmp.centre - tmp.lower
        tmp.upper_margin = tmp.upper - tmp.centre

        # Draw plot

        myPlot = plot(b[:,1], b[:,3], seriestype = :bar, fillalpha = 0.8, 
                     xlabel = "Value", ylabel = "Proportion", 
                     label = "y", fill = actualcolour, 
                     title = "Posterior Predictive Check", 
                     size = (600, 600), legend = plot_legend)

        # Add draw median and 95% credible intervals

        plot!(tmp[:,1], tmp[:,2], seriestype = :scatter, color = drawscolour,
              yerror = (tmp[:,5], tmp[:,6]), 
              label = "yrep", legend = plot_legend,
              markerstrokecolor = drawscolour, markersize = 5)

    else 
        # Plot posterior draws

        Random.seed!(123)

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

    plot_hist_check(y, yrep, point_est, plot_legend, args...; kwargs...)

Draw a plot with a binned histogram of posterior-predicted response variable values against a measure of centrality of the actual data to visualise model fit.

Usage:
```julia-repl
plot_hist_check(y, yrep, point_est, plot_legend)
```

Arguments:

- `y` : The vector of response variable values.
- `yrep` : The Draws x Values matrix of posterior predictions.
- `point_est` : The type of point estimate to use.
- `plot_legend` : Boolean of whether to add a legend to the plot or not.
"""
function plot_hist_check(y::Array, yrep, point_est::String = "median", plot_legend::Bool = true, args...; kwargs...)

    # Check point estimate argument

    (point_est == "mean" || point_est == "median") || error("`point_est` should be a String of either 'mean' or 'median'.")
    
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

    if point_est == "median"
        m = median(y)
    else
        m = mean(y)
    end

    # Wrangle posterior draws from wide to long and compute point estimate for each value

    tmp = DataFrame(yrep)
    tmp = stack(tmp, 1:length2)

    if point_est == "median"
        tmp = combine(groupby(tmp, :variable), :value => median)
    else
        tmp = combine(groupby(tmp, :variable), :value => mean)
    end

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
function plot_ecdf_check(y::Array, yrep, plot_legend::Bool = true, args...; kwargs...)
    
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
