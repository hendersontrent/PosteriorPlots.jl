using PosteriorPlots
using Test
using Soss, Random, Distributions, SampleChainsDynamicHMC, Plots

#------------- Run package tests --------------------

@testset "PosteriorPlots.jl" begin

    # Define an example model from Soss documentation

    model = @model X begin
        p = size(X, 2) # number of features
        α ~ Normal(0, 1) # intercept
        β ~ Normal(0, 1) |> iid(p) # coefficients
        σ ~ truncated(Normal(0, 100), 0, Inf) # dispersion
        η = α .+ X * β # linear predictor
        μ = η # `μ = g⁻¹(η) = η`
        y ~ For(eachindex(μ)) do j
            Normal(μ[j], σ) # `Yᵢ ~ Normal(mean=μᵢ, variance=σ²)`
        end
    end;
    
    X = randn(6,2)
    
    forward_sample = rand(model(X=X))
    
    num_rows = 1_000
    num_features = 2
    X = randn(num_rows, num_features)
    
    β_true = [2.0, -1.0]
    α_true = 1.0
    σ_true = 0.5
    
    η_true = α_true .+ X * β_true
    μ_true = η_true
    noise = randn(num_rows) .* σ_true
    y_true = μ_true .+ noise
    
    posterior = dynamicHMC(model(X=X), (y=y_true,))

    #------------------------------
    # Run core PosteriorPlots tests
    #------------------------------

    # Inference
    
    p =  plot_posterior_intervals(posterior, 0.95)
    @test p isa Plots.Plot

    p1 = plot(plot_posterior_hist(posterior, true)...)
    @test p1 isa Plots.Plot

    p2 = plot(plot_posterior_density(posterior, 0.95, true)...)
    @test p2 isa Plots.Plot

    # PPC

    y = [0,1,1,0,1,1,1,0,1,0]
    
    yrep = [[1,0,0,0,0] [1,1,1,1,0] [1,1,0,1,0] [0,0,0,1,0] [1,1,1,1,1] [1,1,1,1,1] [1,1,1,1,1] [0,0,0,0,0] [1,1,0,1,1] [0,0,0,0,0]]

    p3 =  plot_posterior_check(y, yrep)
    @test isa(p3, Plot)

    #p4 =  plot_hist_check(y, yrep)
    #@test isa(p4, Plot)

    #p5 =  plot_ecdf_check(y, yrep)
    #@test isa(p5, Plot)
end
