"""

    plot_density_check(model, predmodel, y, ndraws, args...; kwargs...)

Draw a density plot of a random sample of draws from the response variable posterior distribution against the density estimation of the actual data to visualise model fit.

Usage:
```julia-repl
plot_density_check(model, y, ndraws)
```
Arguments:

- `model` : The `Turing.jl` or `Soss.jl` model of class `Chains` or `Array` to draw inferences from.
- `predmodel` : The `Turing.jl` or `Soss.jl` model that specifies predictions for Missing input data.
- `y` : The vector of response variable values.
- `ndraws` : The number of random draws to make from the posterior distribution.
"""
function plot_density_check(model::Chains, predmodel::Model, y::Vector, ndraws::Int, args...; kwargs...)

    #------------ Draws and plot ----------------

    gr() # gr backend for graphics
    mycolor = theme_palette(:auto).colors.colors[1]
    Random.seed!(123) # Fix seed for reproducibility

    # Perform draws and add to plot

    myPlot = plot()

    for i in 1:ndraws
        chain2 = sample(predmodel, NUTS(), 1000)
        gen = generated_quantities(model, chain2)
        plot!(p, predictions, label = string(ndraws, " Posterior Draws"), seriestype = :density, color = :grey, alpha = 0.5)
    end

    # Add original data to plot

    plot!(myPlot, y, label = "Real Data", seriestype = :density, color = mycolor)
    myPlot = plot!(myPlot, title = "Posterior Predictive Check", xlabel = "Value", ylabel = "Density")

    return myPlot
end



"""

    plot_hist_check(x, y, args...; kwargs...)

Draw a plot with a binned histogram of posterior-predicted response variable values against a measure of centrality of the actual data to visualise model fit.

Usage:
```julia-repl
plot_hist_check(x, y)
```

Arguments:

- `x` : The vector of the actual data values to plot.
- `y` : The vector of model response variable predictions to plot.
"""

function plot_hist_check(x::Vector, y::Vector, args...; kwargs...)

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
