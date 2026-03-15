module Procurement

using Random, Statistics
import ..EnrichmentModel: fuel_cost

export dynamic_contract_optimization

"""
Simple Monte Carlo-based procurement optimizer.
Decides fraction α of future demand D to lock in as long-term contract at price p_contract.
Remaining (1-α) bought on spot at stochastic prices. Minimizes expected discounted fuel cost.

Inputs:
 - D: total future demand (mass)
 - p_contract: fixed contract price for uranium and SWU as tuple (PUc, PSWUc)
 - price_sampler: function that returns (PU, PSWU) sample when called
 - α_grid: grid of contract fractions to search
 - Nmc: Monte Carlo draws
 - r: discount rate per period (applied to future cost expectation)
"""
function dynamic_contract_optimization(D::Float64, p_contract::Tuple{Float64,Float64}, price_sampler::Function; α_grid=collect(0.0:0.05:1.0), Nmc=200, r=0.0)
    PUc, PSWUc = p_contract
    scores = Float64[]
    for α in α_grid
        costs = zeros(Nmc)
        for m in 1:Nmc
            PU_spot, PSWU_spot = price_sampler()
            # locked quantity costs
            cost_locked = D * α * (PUc + PSWUc)
            # spot quantity cost: approximate by using per-unit fuel_cost with tails fixed (simplify)
            cost_spot = D * (1 - α) * (PU_spot + PSWU_spot)
            costs[m] = cost_locked + cost_spot
        end
        exp_cost = mean(costs) / (1 + r)
        push!(scores, exp_cost)
    end
    idx = argmin(scores)
    return α_grid[idx], scores[idx]
end

end # module
