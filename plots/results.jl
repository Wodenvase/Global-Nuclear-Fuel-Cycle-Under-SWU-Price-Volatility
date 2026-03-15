module ResultPlots

using Plots, StatsPlots, DataFrames

export plot_price_paths, plot_cost_histogram, plot_tails_vs_ratio

function plot_price_paths(PU_path, PSWU_path; labels=("Uranium","SWU"))
    plt = plot(PU_path, label=labels[1])
    plot!(plt, PSWU_path, label=labels[2])
    return plt
end

function plot_cost_histogram(df::DataFrame)
    plt = histogram(df.cost, bins=30, xlabel="Fuel Cost", ylabel="Frequency", title="Fuel Cost Distribution")
    return plt
end

function plot_tails_vs_ratio(df::DataFrame)
    ratio = df.PSWU ./ df.PU
    plt = scatter(ratio, df.xt_opt, xlabel="PSWU / PU", ylabel="Optimal tails (x_t)", title="Optimal tails vs SWU/U price ratio")
    return plt
end

end # module
