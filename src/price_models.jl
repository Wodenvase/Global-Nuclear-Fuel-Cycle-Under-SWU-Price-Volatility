module PriceModels

using Random, LinearAlgebra

export simulate_OU, simulate_correlated_OU

function simulate_OU(P0, kappa, theta, sigma, T, dt)
    steps = Int(floor(T/dt)) + 1
    prices = similar(zeros(Float64, steps))
    prices[1] = P0
    for t in 2:steps
        dW = sqrt(dt) * randn()
        prices[t] = prices[t-1] + kappa*(theta - prices[t-1])*dt + sigma*dW
    end
    return prices
end

function simulate_correlated_OU(P0::Vector, kappas::Vector, thetas::Vector, sigmas::Vector, ρ::Float64, T, dt)
    # Two-dimensional correlated OU simulation (returns matrix: nvars x steps)
    n = length(P0)
    steps = Int(floor(T/dt)) + 1
    prices = zeros(Float64, n, steps)
    prices[:,1] = P0
    Σ = [1.0 ρ; ρ 1.0]
    L = cholesky(Σ).L
    for t in 2:steps
        z = randn(n)
        dW = sqrt(dt) * (L * z)
        for i in 1:n
            prices[i,t] = prices[i,t-1] + kappas[i]*(thetas[i] - prices[i,t-1])*dt + sigmas[i]*dW[i]
        end
    end
    return prices
end

end # module
