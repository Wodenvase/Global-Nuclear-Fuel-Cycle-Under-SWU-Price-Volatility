module Optimization

using Optim
import ..EnrichmentModel: fuel_cost

export optimal_tails

function optimal_tails(PU::Float64, PSWU::Float64; xp::Float64=0.045, xf::Float64=0.00711, lower::Float64=0.0005, upper::Float64=0.05)
    obj(x) = fuel_cost(PU, PSWU, 1.0, xp, x, xf)
    result = optimize(obj, lower, upper) # scalar Brent method
    xt_opt = Optim.minimizer(result)
    return xt_opt, Optim.minimum(result)
end

end # module
