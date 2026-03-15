# Stochastic Modeling of the Nuclear Fuel Cycle Market Under SWU Price Volatility

This repository implements a Julia-based stochastic simulation and optimization framework to study how uranium prices, SWU prices, and enrichment decisions (tails assay) interact to determine optimal fuel procurement strategies.

Contents
- `src/price_models.jl`: OU price models and correlated simulation utilities.
- `src/enrichment_model.jl`: Enrichment balance equations, `V(x)` value function, SWU requirement, and fuel cost.
- `src/optimization.jl`: Optimal tails-assay solver using `Optim.jl`.
- `src/simulation.jl`: Monte Carlo driver producing cost distributions and optimal strategies.
- `plots/results.jl`: Plotting helpers for price paths, histograms, and sensitivity surfaces.
- `main.jl`: Example runner showing how to run a Monte Carlo experiment and save plots.
- `data/historical_prices.csv`: (placeholder) historical price data.

Mathematical summary

- Uranium price OU process:

  $$dP_U = \kappa_U(\theta_U - P_U)\,dt + \sigma_U\,dW_t$$

- SWU price OU process:

  $$dP_{SWU} = \kappa_{SWU}(\theta_{SWU} - P_{SWU})\,dt + \sigma_{SWU}\,dW_t$$

- Enrichment balance and isotopic equations:

  Fuel mass: $F = P + T$  
  Isotope balance: $F x_f = P x_p + T x_t$  

- SWU value function used in SWU requirement:

  $$V(x) = (1 - 2x) \ln\left(\frac{1-x}{x}\right)$$

- SWU requirement (per mass):

  $$SWU = P\,V(x_p) + T\,V(x_t) - F\,V(x_f)$$

- Fuel cost:

  $$C = P_U F + P_{SWU} SWU$$

Usage

1. Install Julia and add required packages listed in `Project.toml`.
2. Run `julia --project=.` and start `main.jl`:

```bash
julia --project=. main.jl
```

Outputs: example plots saved to `plots/` and a `results.csv` with cost and optimal tails per simulation.

References (suggested)
- Gardiner, C. W. (2009). Stochastic Methods: A Handbook for the Natural and Social Sciences.
- Hull, J. (2018). Options, Futures and Other Derivatives.
- IAEA reports on uranium enrichment economics.
- Industry reports: Urenco, Orano, Rosatom annual reports.

For thesis-level write-up, see `README_extended.md` (to be added) with detailed derivations and figures.

## Example Results (generated)

Below are example outputs from a sample Monte Carlo run (see `main.jl` for reproduction):

- Price paths (uranium vs SWU):

![Price paths](plots/price_paths.png)

- Fuel cost distribution (histogram):

![Fuel cost histogram](plots/cost_histogram.png)

- Optimal tails assay vs SWU/U price ratio:

![Optimal tails vs ratio](plots/tails_vs_ratio.png)

**Extended Methods, Derivations, and References**

**1. Price Dynamics: Ornstein–Uhlenbeck Processes**

We model both uranium price $P_U(t)$ and enrichment (SWU) price $P_{SWU}(t)$ as mean-reverting Ornstein–Uhlenbeck (OU) processes:

$$dP_U = \kappa_U(\theta_U - P_U)\,dt + \sigma_U\,dW^U_t$$
$$dP_{SWU} = \kappa_{SWU}(\theta_{SWU} - P_{SWU})\,dt + \sigma_{SWU}\,dW^{SWU}_t$$

We allow correlation between the Brownian increments: $dW^{SWU}_t = \rho\,dW^U_t + \sqrt{1-\rho^2}\,dZ_t$ for independent $Z_t$.

Discrete-time approximation (Euler–Maruyama) with step $\Delta t$:

$$P_{t+\Delta t} = P_t + \kappa(\theta - P_t)\Delta t + \sigma\sqrt{\Delta t}\,\varepsilon_t$$
where $\varepsilon_t\sim N(0,1)$. For calibration we exploit the AR(1) mapping:

$$P_{t+1} = \alpha + \beta P_t + \varepsilon_t',\qquad \beta = 1 - \kappa\Delta t,\quad \alpha = \kappa\theta\Delta t,$$
so that estimated $\beta$ yields $\kappa=(1-\beta)/\Delta t$ and $\theta=\alpha/(\kappa\Delta t)$; residual variance gives $\sigma$ via $\mathrm{Var}(\varepsilon')=\sigma^2\Delta t$.

**2. Enrichment Physics and Mass Balance**

Let product mass $P$ (per-unit basis often set to 1 kg heavy metal), feed mass $F$, tails mass $T$; product assay $x_p$, feed assay $x_f$, tails assay $x_t$. Mass and isotope balances:

Fuel mass: $F = P + T$.
Isotope mass: $F x_f = P x_p + T x_t$.

Solving for $F$ and $T$ yields (per product mass $P$):

$$F = P\frac{x_p - x_t}{x_f - x_t},\quad T = F - P.$$ 

**3. SWU Requirement**

Using separative work formula and value function $V(x)$ (consistent with standard enrichment theory):

$$V(x)= (1-2x)\ln\left(\frac{1-x}{x}\right).$$

Total separative work for producing $P$ units of product at assays $(x_p,x_f,x_t)$:

$$SWU = P\,V(x_p) + T\,V(x_t) - F\,V(x_f).$$

**4. Fuel Cost and Optimization**

Total fuel cost per product mass:

$$C = P_U F + P_{SWU}\,SWU + P_C F + C_{fab}$$

In this repository the baseline cost excludes conversion and fabrication for clarity; they can be added as constants or stochastic processes.

Optimization problem: choose tails assay $x_t$ to minimize $C$. For fixed $P_U,P_{SWU},x_p,x_f$ this is a one-dimensional optimization problem. Analytical approximations exist in the low-tail limit; here we solve numerically using Brent/Golden-section.

**5. Market: Cournot Oligopoly for SWU Supply**

Model SWU inverse demand as linear: $P_{SWU}(Q)=a-bQ$ where $Q=\sum_i q_i$ is total SWU supplied. Each firm $i$ with marginal cost $c_i$ chooses $q_i$ to maximize profit $\Pi_i = P(Q) q_i - C_i(q_i)$ where $C_i(q_i)=c_i q_i$.

First-order conditions (FOC) for interior solution:

$$\frac{\partial\Pi_i}{\partial q_i} = P + q_i P' - c_i = 0 \Rightarrow a - bQ - b q_i - c_i = 0.$$ 

This yields a linear system in the $q_i$ which can be solved to obtain the Cournot equilibrium. In the symmetric-cost case $c_i=c$, closed-form:

We implement a general linear solver to handle heterogeneous costs.

**6. Enrichment Demand Link to Reactor Fleet**

Reactor fleet size $R(t)$ and per-reactor fuel requirement $B$ give fuel demand $D_{fuel}(t)=R(t)B$. SWU demand is derived via enrichment mass balances and required product assays.

**7. Procurement / Dynamic Contracting**

Utilities decide how much to lock in via long-term contracts vs buy on spot. A stylized decision variable $\alpha\in[0,1]$ denotes fraction of future demand locked at contract prices $(P_{U}^c,P_{SWU}^c)$; the remainder purchased on spot at stochastic prices. Expected discounted cost minimized via Monte Carlo sampling of spot realizations. Extensions include multi-period stochastic dynamic programming, inventory models, and risk-aversion using CVaR or utility functions.

**8. Calibration**

We provide simple, transparent estimators:

- OU parameters via AR(1) regression (MLE/OLS equivalent under Gaussian errors).
- Correlation estimated via residual (dW) correlation after OU detrending.

For robustness use overlapping returns, robust regression, or maximum likelihood estimation specialized for OU (found in econometrics literature).

**9. Simulation Design**

Monte Carlo procedure:

1. Calibrate OU parameters from historical series (if available).
2. Simulate correlated OU paths for $(P_U,P_{SWU})$ using Cholesky decomposition for correlated normals.
3. For each simulated terminal (or path) price, compute optimal tails $x_t^*$ and fuel cost $C$.
4. Aggregate distribution of costs, store optimal strategies, and compute sensitivity measures.

We provide `run_monte_carlo` in `src/simulation.jl`.

**10. Numerical Implementation Notes**

- Euler–Maruyama is used for path simulation; for higher accuracy consider Milstein or exact OU discretization.
- Correlated normals are generated via Cholesky factorization of the 2×2 covariance matrix.
- Optimizer: Brent/Golden-section for 1D tails optimization (package `Optim.jl` used as a convenience).

**11. References**

- Gardiner, C. W., "Stochastic Methods: A Handbook for the Natural and Social Sciences", Springer, 2009.
- Karatzas, I., & Shreve, S. E., "Brownian Motion and Stochastic Calculus", Springer, 1991.
- Hull, J., "Options, Futures and Other Derivatives", Pearson, latest edition.
- IAEA, "Uranium 2020: Resources, Production and Demand" reports.
- Industry annual reports: Urenco, Orano, Rosatom.


