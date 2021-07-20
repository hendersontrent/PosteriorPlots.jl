"""

    plot_posterior_intervals(model, args...; kwargs...)

Draw a plot with a point estimate measure of centrality and quantiled credible intervals for easy interpretation of regression models fit in Turing.jl.

Usage:
```julia-repl
plot_posterior_intervals(model)
```

Arguments:

- `model` : The Turing.jl model to draw inferences from.
"""
function plot_posterior_intervals(model::Chains, args...; kwargs...)

    #------------ Reshaping and calcs -----------

    # Fix seed for reproducibility

    Random.seed!(123)

    finalPost = DataFrame(MCMCChains.quantile(chain))

    finalPost = select(finalPost, "parameters" => "parameters", "2.5%" => "lower", "50.0%" => "centre", "97.5%" => "upper")
    
    variable = finalPost[!, :parameters]
    variable = string.(variable)
    lower = finalPost[!, :lower]
    centre = finalPost[!, :centre]
    upper = finalPost[!, :upper]

    #------------ Draw the plot -----------------

    gr() # gr backend for graphics
    mycolor = theme_palette(:auto).colors.colors[1]

    myPlot = plot(centre, variable, xerror = (centre .- lower, upper .- centre), st = :scatter,
                title = "Posterior medians w/ 95% credible intervals",
                xlabel = "Value",
                ylabel = "Parameter",
                legend = false,
                marker = stroke(mycolor, mycolor))

    return myPlot
end



"""

    plot_posterior_hist(model, parameter, args...; kwargs...)

Draw a plot with a binned histogram of sampled parameters for easy interpretation of regression models fit in Turing.jl.

Usage:
```julia-repl
plot_posterior_hist(model, parameter)
```

Details:

"`parameter` must be an object of class Symbol specifying an exact parameter name from your model. For example, if you wanted to plot an intercept term that was called β0, you would enter :β0 in the function argument."

Arguments:

- `model` : The Turing.jl model to draw inferences from.
- `parameter` : The parameter of interest to plot.
"""
function plot_posterior_hist(model::Chains, parameter::Symbol)

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

Details:

"`parameter` must be an object of class Symbol specifying an exact parameter name from your model. For example, if you wanted to plot an intercept term that was called β0, you would enter :β0 in the function argument."

Arguments:

- `model` : The Turing.jl model to draw inferences from.
- `parameter` : The parameter of interest to plot.
"""
function plot_posterior_density(model::Chains, parameter::Symbol, args...; kwargs...)

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
