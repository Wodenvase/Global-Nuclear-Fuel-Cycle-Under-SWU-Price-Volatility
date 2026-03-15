module EnrichmentModel

export V, swu_required, fuel_cost

function V(x::Float64)
    return (1 - 2x) * log((1 - x) / x)
end

function swu_required(P::Float64, xp::Float64, xt::Float64, xf::Float64)
    # P is product mass (set to 1 unit if working per-unit basis)
    F = P * (xp - xt) / (xf - xt)
    T = F - P
    SWU = P*V(xp) + T*V(xt) - F*V(xf)
    return SWU, F
end

function fuel_cost(PU::Float64, PSWU::Float64, P::Float64, xp::Float64, xt::Float64, xf::Float64)
    swu, F = swu_required(P, xp, xt, xf)
    cost = PU * F + PSWU * swu
    return cost
end

end # module
