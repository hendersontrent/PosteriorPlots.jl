"""

    plot_posterior_density_check(x, y, args...; kwargs...)

Draw a density plot of response variable posterior distributions against the density estimation of the actual data to visualise model fit.

Usage:
```julia-repl
plot_posterior_density_check(x, y)
```
Arguments:

- `x` : The vector of the actual data values to plot.
- `y` : The vector of model response variable predictions to plot.
"""

function plot_density_check(x::Vector, y::Vector, args...; kwargs...)

        #------------ Argument checks ---------------

        isa(x, Vector) || error("`x` must be an object of class Vector specifying the name of a created vector of values for the parameter of interest that were entered into the Turing model.")

        isa(y, Vector) || error("`parameter` must be an object of class Vector specifying the name of a created vector of predicted response variable values for the Turing model.")

        #------------ Draw the plot -----------------

        gr() # gr backend for graphics
        mycolor = theme_palette(:auto).colors.colors[1]
        mycolor2 = theme_palette(:auto).colors.colors[2]

        plot(x, label = "Real Data", seriestype = :density, color = mycolor)
        plot!(y, label = "Posterior Predictions", seriestype = :density, color = mycolor2)
        myPlot = plot!(title = "Posterior Predictive Check", xlabel = "Posterior Value", ylabel = "Density")

        return myPlot
end



"""

    plot_posterior_hist_check(x, y, args...; kwargs...)

Draw a plot with a binned histogram of sampled parameters against a measure of centrality of the actual data to visualise model fit.

Usage:
```julia-repl
plot_posterior_hist(x, y)
```

Arguments:

- `x` : The vector of the actual data values to plot.
- `y` : The vector of model response variable predictions to plot.
"""

function plot_posterior_hist(x::Vector, y::Vector, args...; kwargs...)

        #------------ Argument checks ---------------

        isa(x, Vector) || error("`x` must be an object of class Vector specifying the name of a created vector of values for the parameter of interest that were entered into the Turing model.")

        isa(y, Vector) || error("`parameter` must be an object of class Vector specifying the name of a created vector of predicted response variable values for the Turing model.")

        #------------ Computations ------------------

        m = median(x)

        #------------ Draw the plot -----------------

        gr() # gr backend for graphics
        mycolor = theme_palette(:auto).colors.colors[1]
        mycolor2 = theme_palette(:auto).colors.colors[2]

        plot(x, label = "Real Data", seriestype = :histogram, color = mycolor)
        plot!([m], seriestype = "vline", color = mycolor, label = "Real Data Median")
        myPlot = plot!(title = "Posterior Predictive Check", xlabel = "Posterior Value", ylabel = "")

        return myPlot

end
