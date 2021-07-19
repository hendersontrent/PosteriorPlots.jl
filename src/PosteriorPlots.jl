module PosteriorPlots

using DataFrames, Plots, StatsPlots, Random, KernelDensity, Turing, StatsBase

include("plot_posterior_intervals.jl")
include("plot_posterior_density_check.jl")
