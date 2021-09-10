module PosteriorPlots

using DataFrames, Statistics, Plots, StatsPlots, StatsBase, Random, KernelDensity, StatsBase, MCMCChains

include("PlotHelpers.jl")
include("Inference.jl")
include("PosteriorPredictiveCheck.jl")

# Exports

export plot_posterior_intervals
export plot_posterior_hist
export plot_posterior_density
export plot_posterior_check
export plot_hist_check
export plot_ecdf_check

end