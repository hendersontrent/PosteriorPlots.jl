#--------------------------------------
# This script defines a bunch of
# helper functions to assist with the
# core functionality of PosteriorPlots.jl
#--------------------------------------

#--------------------------------------
# Author: Trent Henderson, 23 July 2021
#--------------------------------------

#----------- Histogram ------------

function histhelper(data::DataFrame, centrality::String, p::Symbol, add_legend::Bool)

    # Compute median

    if centrality == "median"
        m = median(data[!, p])
    else
        m = mean(data[!, p])
    end

    # Set up graphics helpers

    mycolor = cgrad(:blues)[1]
    mycolor2 = cgrad(:blues)[2]

    # Draw plot

    myPlot = plot(data[!, p], seriestype = :histogram, fillalpha = 0.5, 
                  xlabel = "Value", ylabel = "", label = "",
                  color = mycolor, title = string(p), size = (800, 800),
                  legend = add_legend)

    plot!([m], seriestype = "vline", color = mycolor2, label = centrality, linewidth = 2.5)

    return myPlot
end

#----------- Density --------------

function denshelper(data::DataFrame, centrality::String, p::Symbol, lower::Float64, upper::Float64, add_legend::Bool)

    Random.seed!(123)

    # Compute median

    thevec = convert(Vector, data[!, p])

    if centrality == "median"
        m = median(thevec)
    else
        m = mean(thevec)
    end

    y = kde(thevec)
    lowerquantile = quantile(thevec, lower)
    upperquantile = quantile(thevec, upper)

    # Set up graphics helpers

    mycolor = theme_palette(:auto).colors.colors[1]

    # Draw plot

    myPlot = plot(thevec, title = string(p), fillalpha = 0.8, 
         xlabel = "Value", ylabel = "Density", label = "",
         seriestype = :density, color = mycolor, size = (800, 800))

    plot!(range(lowerquantile, stop = upperquantile, length = 100), thevec -> pdf(y,thevec), 
           color =  mycolor, fill = (0, 0.4, mycolor), label = "Credible Interval", legend = add_legend)

    plot!([m], seriestype = "vline", color = mycolor, label = centrality, linewidth = 2.5)

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

#----------- Quantile maker -------

# Helper function to produce 2 numbers that bound a quantile for a user-specified probability

function generatequantile(x::Float64)

    upperbound = round(((x + 1) / 2), digits = 3) # Solve for upper bound
    lowerbound = round(upperbound - x, digits = 3) # Substitute in for lower bound
    return lowerbound, upperbound
end
