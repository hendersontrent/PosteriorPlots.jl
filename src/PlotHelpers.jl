#--------------------------------------
# This script defines a bunch of
# helper functions to assist with the
# core functionality of PosteriorPlots.jl
#--------------------------------------

#--------------------------------------
# Author: Trent Henderson, 23 July 2021
#--------------------------------------

#----------- Histogram ------------

function histhelper(data::DataFrame, p::Symbol, plot_legend::Bool)

    # Compute median

    m = median(data[!, p])

    # Set up graphics helpers

    mycolor = theme_palette(:auto).colors.colors[1]
    mycolor2 = theme_palette(:auto).colors.colors[2]

    # Draw plot

    myPlot = plot(data[!, p], seriestype = :histogram, fillalpha = 0.6, 
                  xlabel = "Value", ylabel = "", label = "",
                  color = mycolor, title = string(p), size = (800, 800),
                  legend = plot_legend)

    plot!([m], seriestype = "vline", color = mycolor2, label = "", linewidth = 2.5)

    return myPlot
end

#----------- Density --------------

function denshelper(data::DataFrame, p::Symbol, plot_legend::Bool)

    # Compute median

    thevec = convert(Vector, data[!, p])
    m = median(thevec)
    y = kde(thevec)
    lowerquantile = quantile(thevec, 0.025)
    upperquantile = quantile(thevec, 0.975)

    # Set up graphics helpers

    mycolor = theme_palette(:auto).colors.colors[1]

    # Draw plot

    myPlot = plot(thevec, title = string(p), fillalpha = 0.8, 
         xlabel = "Value", ylabel = "Density", label = "",
         seriestype = :density, color = mycolor, size = (800, 800))

    plot!(range(lowerquantile, stop = upperquantile, length = 100), thevec -> pdf(y,thevec), 
           color =  mycolor, fill = (0, 0.4, mycolor), label = "95% CI", legend = plot_legend)

    plot!([m], seriestype = "vline", color = mycolor, label = "", linewidth = 2.5)

    return myPlot
end

#----------- Soss.jl parser -------

# Helper function to split an arbitrarily sized array returned by `dynamicHMC` 
# into separate columns for each parameter. This likely applies to coefficients more often than 
# not and potentially intercepts if mixed effects models are used.

function expandcol(df::DataFrame, thecol)

    expandlength =  length(df[1, thecol])
    @assert all(length.(df[!, thecol]) .== expandlength)
    expandnames = [Symbol(thecol, "_", i) for i ∈ 1:expandlength]
    subdf = DataFrame([getindex.(df[:, thecol], i) for i ∈ 1:lastindex(df[1, thecol])], expandnames)
    return hcat(df, subdf)
end
