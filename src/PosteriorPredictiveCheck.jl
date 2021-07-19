"""

    plot_posterior_density_check(model, y, ndraws, args...; kwargs...)

Draw a density plot of a random sample of draws from the response variable posterior distribution against the density estimation of the actual data to visualise model fit.

Usage:
```julia-repl
plot_posterior_density_check(model, y, ndraws)
```
Arguments:

- `model` : The Turing.jl model to draw inferences from.
- `y` : The vector of response variable values.
- `ndraws` : The number of random draws to take from the posterior distribution.
"""

function plot_density_check(model::Chains, y::Vector, ndraws::Int, args...; kwargs...)

        #------------ Argument checks ---------------

        isa(model, Chains) || error("`model` must be an object of class Chains created by Turing.jl.")

        isa(y, Vector) || error("`y` must be an object of class Vector specifying the name of a created vector of response variable values to compare model posteriors against.")

        isa(ndraws, Int) || error("`ndraws` must be an object of class Int64 denoting the number of random draws to make from the model posterior distribution.")

        #------------ Posterior draws ---------------

        # Fix seed for reproducibility

        Random.seed!(123)

        # Perform draws

        drawSamples = StatsBase.sample(chn[:a].value, ndraws)

        #------------ Draw the plot -----------------

        gr() # gr backend for graphics
        mycolor = theme_palette(:auto).colors.colors[1]

        plot(drawSamples, label = string(ndraws, " Posterior Draws"), seriestype = :density, color = :grey, alpha = 0.5)
        plot!(y, label = "Real Data", seriestype = :density, color = mycolor)
        myPlot = plot!(title = "Posterior Predictive Check", xlabel = "Value", ylabel = "Density")

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
        myPlot = plot!(title = "Posterior Predictive Check", xlabel = "Value", ylabel = "")

        return myPlot

end
