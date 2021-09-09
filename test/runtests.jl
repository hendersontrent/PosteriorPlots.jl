using PosteriorPlots
using Test
using Turing, Distributions, RDatasets, MCMCChains, Plots, StatsPlots, Random
using MLDataUtils: shuffleobs, splitobs, rescale!

Random.seed!(0)
Turing.setprogress!(false)

#------------- Run package tests --------------------

@testset "PosteriorPlots.jl" begin

    # Define an example model from the Turing.jl documentation

    data = RDatasets.dataset("datasets", "mtcars")

    # Remove the model column

    select!(data, Not(:Model))

    # Split our dataset 70%/30% into training/test sets

    trainset, testset = splitobs(shuffleobs(data), 0.7)

    # Turing requires data in matrix form

    target = :MPG
    train = Matrix(select(trainset, Not(target)))
    test = Matrix(select(testset, Not(target)))
    train_target = trainset[:, target]
    test_target = testset[:, target]

    # Standardize the features

    μ, σ = rescale!(train; obsdim = 1)
    rescale!(test, μ, σ; obsdim = 1)
    μtarget, σtarget = rescale!(train_target; obsdim = 1)
    rescale!(test_target, μtarget, σtarget; obsdim = 1)

    # Linear regression model

    @model function linear_regression(x, y)
        σ₂ ~ truncated(Normal(0, 100), 0, Inf)
        intercept ~ Normal(0, sqrt(3))
        nfeatures = size(x, 2)
        coefficients ~ MvNormal(nfeatures, sqrt(10))
        
        mu = intercept .+ x * coefficients
        y ~ MvNormal(mu, sqrt(σ₂))
    end

    model = linear_regression(train, train_target)
    chain = sample(model, NUTS(0.65), 3_000)

    #------------------------------
    # Run core PosteriorPlots tests
    #------------------------------

    # Inference
    
    p =  plot_posterior_intervals(chain, 0.95)
    @test p isa Plots.Plot

    p1 = plot(plot_posterior_hist(chain, true)...)
    @test p1 isa Plots.Plot

    p2 = plot(plot_posterior_density(chain, 0.95, true)...)
    @test p2 isa Plots.Plot

    # PPC

    y = [0,1,1,0,1,1,1,0,1,0]
    
    yrep = [[1,0,0,0,0] [1,1,1,1,0] [1,1,0,1,0] [0,0,0,1,0] [1,1,1,1,1] [1,1,1,1,1] [1,1,1,1,1] [0,0,0,0,0] [1,1,0,1,1] [0,0,0,0,0]]

    p3 =  plot_posterior_check(y, yrep)
    @test isa(p3, Plot)

    #p4 =  plot_hist_check()
    #@test isa(p4, Plot)

    #p5 =  plot_ecdf_check()
    #@test isa(p5, Plot)
end
