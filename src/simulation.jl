module Simulation

using Random, DataFrames, CSV
import ..PriceModels: simulate_correlated_OU
import ..Optimization: optimal_tails

export run_monte_carlo

function run_monte_carlo(N::Int; T=1.0, dt=1/252, P0=[30.0, 70.0], kappas=[0.5,0.6], thetas=[30.0,70.0], sigmas=[5.0,8.0], ρ=0.3)
    results = DataFrame(sim=Int[], PU=Float64[], PSWU=Float64[], xt_opt=Float64[], cost=Float64[])
    for sim in 1:N
        prices = simulate_correlated_OU(P0, kappas, thetas, sigmas, ρ, T, dt)
        PU_path = prices[1,:]
        PSWU_path = prices[2,:]
        PU_final = PU_path[end]
        PSWU_final = PSWU_path[end]
        xt_opt, mincost = optimal_tails(PU_final, PSWU_final)
        push!(results, (sim, PU_final, PSWU_final, xt_opt, mincost))
    end
    return results
end

end # module
