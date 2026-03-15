module MarketModel

export cournot_equilibrium

"""
Simple Cournot oligopoly equilibrium for linear inverse demand
P(Q) = a - b*Q and constant marginal costs c_i for each firm.
Returns q_vec, total_Q, price
"""
function cournot_equilibrium(a::Float64, b::Float64, c::Vector{Float64})
    n = length(c)
    # symmetric closed-form when marginal costs identical: q = (a - c)/(b*(n+1))
    # For heterogeneous costs, solve first-order conditions: P + q_i*P' = c_i
    # i.e. a - bQ - b q_i = c_i  -> a - b*(sum q_j) - b q_i = c_i
    # Rearranged: b*(n+1)*q_i + b*sum_{j≠i} q_j = a - c_i  (we solve linear system)
    # Build linear system A q = d
    A = zeros(n,n)
    for i in 1:n
        for j in 1:n
            A[i,j] = b * (i==j ? (n) + 1 : 1)
        end
    end
    d = [a - c[i] for i in 1:n]
    q = A \ d
    Q = sum(q)
    P = a - b*Q
    return q, Q, P
end

end # module
