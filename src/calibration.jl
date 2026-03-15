module Calibration

using CSV, DataFrames, Statistics, LinearAlgebra

export calibrate_OU, calibrate_correlation

"""
Calibrate discretized OU parameters from time series of prices.
Given price vector P and time step dt, returns (kappa, theta, sigma)
using AR(1) regression: P_{t+1} = α + β P_t + ε
where β = 1 - kappa*dt, α = kappa*theta*dt, var(ε)=σ^2 dt.
"""
function calibrate_OU(P::Vector{Float64}, dt::Float64)
    n = length(P) - 1
    X = P[1:end-1]
    Y = P[2:end]
    # regress Y = α + β X + ε
    Xmat = hcat(ones(n), X)
    coeff = Xmat \ Y
    α = coeff[1]
    β = coeff[2]
    residuals = Y - Xmat * coeff
    s2 = var(residuals)
    kappa = max((1 - β) / dt, 0.0)
    theta = α / (kappa*dt + eps())
    sigma = sqrt(s2 / dt)
    return kappa, theta, sigma
end

"""
Calibrate correlation between two price series returns/dW increments.
Compute residuals from OU fits and use their sample correlation.
"""
function calibrate_correlation(P1::Vector{Float64}, P2::Vector{Float64}, dt::Float64)
    k1, θ1, σ1 = calibrate_OU(P1, dt)
    k2, θ2, σ2 = calibrate_OU(P2, dt)
    # compute dW estimates: (P_{t+1} - P_t - kappa*(theta-P_t)*dt)/sigma
    n = length(P1) - 1
    dW1 = zeros(n)
    dW2 = zeros(n)
    for t in 1:n
        dW1[t] = (P1[t+1] - P1[t] - k1*(θ1 - P1[t])*dt) / (σ1*sqrt(dt) + eps())
        dW2[t] = (P2[t+1] - P2[t] - k2*(θ2 - P2[t])*dt) / (σ2*sqrt(dt) + eps())
    end
    ρ = cor(dW1, dW2)
    return (k1, θ1, σ1), (k2, θ2, σ2), ρ
end

end # module
