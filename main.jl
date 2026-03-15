using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using DataFrames, CSV, Plots, Random

# Include local modules
include("src/price_models.jl")
include("src/enrichment_model.jl")
include("src/optimization.jl")
include("src/simulation.jl")
include("src/calibration.jl")
include("src/market_model.jl")
include("src/procurement.jl")
include("plots/results.jl")

using .PriceModels: simulate_OU, simulate_correlated_OU
using .EnrichmentModel: fuel_cost, swu_required
using .Optimization: optimal_tails
using .Simulation: run_monte_carlo
using .Calibration: calibrate_OU, calibrate_correlation
using .MarketModel: cournot_equilibrium
using .Procurement: dynamic_contract_optimization
using .ResultPlots: plot_price_paths, plot_cost_histogram, plot_tails_vs_ratio

# Example run
N = 500
# calibrate OU from historical data if available
if isfile("data/historical_prices.csv")
	df = CSV.read("data/historical_prices.csv", DataFrame)
	PU_hist = convert(Vector{Float64}, df.PU)
	PSWU_hist = convert(Vector{Float64}, df.PSWU)
	dt = 1.0/12.0 # monthly in example data
	(kU, θU, σU), (kS, θS, σS), ρ = calibrate_correlation(PU_hist, PSWU_hist, dt)
	println("Calibrated OU uranium: k=",kU,", θ=",θU,", σ=",σU)
	println("Calibrated OU swu: k=",kS,", θ=",θS,", σ=",σS)
	println("Estimated correlation ρ=", ρ)
else
	println("No historical data found; using defaults.")
end

results = run_monte_carlo(N; T=1.0, dt=1/252)
CSV.write("results_summary.csv", results)

using Distributions

# Quick plots (take first simulation for path illustration)
PU_path = simulate_OU(30.0, 0.5, 30.0, 5.0, 1.0, 1/252)
PSWU_path = simulate_OU(70.0, 0.6, 70.0, 8.0, 1.0, 1/252)
plt1 = plot_price_paths(PU_path, PSWU_path)
savefig(plt1, "plots/price_paths.png")

plt2 = plot_cost_histogram(results)
savefig(plt2, "plots/cost_histogram.png")

plt3 = plot_tails_vs_ratio(results)
savefig(plt3, "plots/tails_vs_ratio.png")

println("Done: results written to results_summary.csv and plots/ folder.")

# Simple example: Cournot equilibrium for enrichment suppliers
q, Q, P = cournot_equilibrium(100.0, 0.5, [20.0, 22.0, 18.0, 19.0])
println("Cournot total SWU Q=",Q,", price=",P)

# Procurement example: Monte Carlo sampler using simulated OU final draws
using Random
function price_sampler_example()
	PU = rand(Normal(30,5))
	PSWU = rand(Normal(70,8))
	return PU, PSWU
end
α_opt, cost_opt = dynamic_contract_optimization(1000.0, (28.0,65.0), price_sampler_example; α_grid=0.0:0.1:1.0, Nmc=200)
println("Optimal contract fraction α=", α_opt, " expected cost=", cost_opt)
