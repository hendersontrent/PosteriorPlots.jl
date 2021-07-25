module PosteriorPlots

using DataFrames, Plots, StatsPlots, Random, KernelDensity, Turing, StatsBase, MCMCChains, Soss

include("PlotHelpers.jl")
include("Inference.jl")
include("PosteriorPredictiveCheck.jl")

# Exports

export plot_posterior_intervals
export plot_posterior_hist
export plot_posterior_density
