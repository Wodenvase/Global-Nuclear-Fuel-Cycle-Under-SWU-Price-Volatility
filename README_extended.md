**Extended Methods, Derivations, and References**

This extended README provides the mathematical derivations, modeling choices, calibration procedures, simulation design, and suggested figures for a thesis-quality treatment of stochastic modeling of the nuclear fuel-cycle market under SWU price volatility.

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

$$q_i^* = \frac{a-c}{b(n+1)},\quad Q^*=\frac{n(a-c)}{b(n+1)},\quad P^*=a-bQ^*.$$ 

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

**11. Figures and Thesis Deliverables**

Key figures to produce and include in the thesis:

- Commodity price sample paths and ensemble (uranium vs SWU).
- Phase diagram: SWU price vs uranium price.
- Optimal tails assay surface vs price ratio and vs (PU,PSWU).
- Fuel cost distribution histogram and CVaR statistics.
- Sensitivity heatmap: cost vs (PU,PSWU).
- Scenario analysis: shocks to supply (e.g., exogenous capacity reduction), and impact on SWU prices/optimal procurement.

**12. References (select)**

- Gardiner, C. W., "Stochastic Methods: A Handbook for the Natural and Social Sciences", Springer, 2009.
- Karatzas, I., & Shreve, S. E., "Brownian Motion and Stochastic Calculus", Springer, 1991.
- Hull, J., "Options, Futures and Other Derivatives", Pearson, latest edition.
- IAEA, "Uranium 2020: Resources, Production and Demand" reports.
- Industry annual reports: Urenco, Orano, Rosatom.

**13. Suggested Extensions**

- Multi-period dynamic programming for procurement (state = inventory + forward contract positions).
- Endogenize SWU supply via capacity investment and Cournot competition with entry/exit.
- Model risk-aversion via utility functions or coherent risk measures (CVaR).
- Implement an econometric calibration using maximum likelihood for OU processes and bootstrapped confidence intervals.

---

This file is intended as a thorough mathematical appendix; for the thesis write-up, expand sections 5–7 with formal proofs, tables of parameter estimates (with confidence intervals), and extended scenario descriptions.

