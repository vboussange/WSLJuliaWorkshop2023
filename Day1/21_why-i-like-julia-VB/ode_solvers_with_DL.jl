#=
This script is inspired from https://github.com/ChrisRackauckas/universal_differential_equations/blob/d622d92095775f1f2bb3eee8f6c0e443a7f1ae34/LotkaVolterra/scenario_1.jl

=#

cd(@__DIR__)
using Pkg; Pkg.activate("."); Pkg.instantiate()

using OrdinaryDiffEq
using ModelingToolkit
using DataDrivenDiffEq
using LinearAlgebra, ComponentArrays
using Optimization, OptimizationOptimisers, OptimizationOptimJL #OptimizationFlux for ADAM and OptimizationOptimJL for BFGS
using DiffEqSensitivity
using Lux
using Plots
gr()
using JLD2, FileIO
using Statistics
# Set a random seed for reproduceable behaviour
using Random
rng = Random.default_rng()
Random.seed!(1234)

#### NOTE
# Since the recent release of DataDrivenDiffEq v0.6.0 where a complete overhaul of the optimizers took
# place, SR3 has been used. Right now, STLSQ performs better and has been changed.

# Create a name for saving ( basically a prefix )
svname = "Scenario_1_"

## Data generation
function 
    !(du, u, p, t)
    α, β, γ, δ = p
    du[1] = α*u[1] - β*u[2]*u[1]
    du[2] = γ*u[1]*u[2]  - δ*u[2]
end

# Define the experimental parameter
tspan = (0.0,3.0)
u0 = [0.44249296,4.6280594]
p_ = [1.3, 0.9, 0.8, 1.8]
prob = ODEProblem(lotka!, u0,tspan, p_)
solution = solve(prob, Vern7(), abstol=1e-12, reltol=1e-12, saveat = 0.1)

# Ideal data
X = Array(solution)
t = solution.t
DX = Array(solution(solution.t, Val{1}))

full_problem = DataDrivenProblem(X, t = t, DX = DX)

# Add noise in terms of the mean
x̄ = mean(X, dims = 2)
noise_magnitude = 5e-3
Xₙ = X .+ (noise_magnitude*x̄) .* randn(eltype(X), size(X))

plot(solution, alpha = 0.75, color = :black, label = ["True Data" nothing])
scatter!(t, transpose(Xₙ), color = :red, label = ["Noisy Data" nothing])
## Define the network
# Gaussian RBF as activation
rbf(x) = exp.(-(x.^2))

# Multilayer FeedForward
U = Lux.Chain(
    Lux.Dense(2,5,rbf), Lux.Dense(5,5, rbf), Lux.Dense(5,5, rbf), Lux.Dense(5,2)
)
# Get the initial parameters and state variables of the model
p, st = Lux.setup(rng, U)

# Define the hybrid model
function ude_dynamics!(du,u, p, t, p_true)
    û = U(u, p, st)[1] # Network prediction
    du[1] = p_true[1]*u[1] + û[1]
    du[2] = -p_true[4]*u[2] + û[2]
end

# Closure with the known parameter
nn_dynamics!(du,u,p,t) = ude_dynamics!(du,u,p,t,p_)
# Define the problem
prob_nn = ODEProblem(nn_dynamics!,Xₙ[:, 1], tspan, p)

## Function to train the network
# Define a predictor
function predict(θ, X = Xₙ[:,1], T = t)
    _prob = remake(prob_nn, u0 = X, tspan = (T[1], T[end]), p = θ)
    Array(solve(_prob, Vern7(), saveat = T,
                abstol=1e-6, reltol=1e-6,
                sensealg = ForwardDiffSensitivity()
                ))
end

# Simple L2 loss
function loss(θ)
    X̂ = predict(θ)
    sum(abs2, Xₙ .- X̂)
end

# Container to track the losses
losses = Float64[]

callback = function (p, l)
  push!(losses, l)
  if length(losses)%50==0
      println("Current loss after $(length(losses)) iterations: $(losses[end])")
  end
  return false
end

## Training

# First train with ADAM for better convergence -> move the parameters into a
# favourable starting positing for BFGS
adtype = Optimization.AutoZygote()
optf = Optimization.OptimizationFunction((x,p)->loss(x), adtype)
optprob = Optimization.OptimizationProblem(optf, ComponentVector{Float64}(p))
res1 = Optimization.solve(optprob, ADAM(0.1), callback=callback, maxiters = 200)
println("Training loss after $(length(losses)) iterations: $(losses[end])")
# Train with BFGS
optprob2 = Optimization.OptimizationProblem(optf, res1.minimizer)
res2 = Optimization.solve(optprob2, Optim.BFGS(initial_stepnorm=0.01), callback=callback, maxiters = 10000)
println("Final training loss after $(length(losses)) iterations: $(losses[end])")

# Plot the losses
pl_losses = plot(1:200, losses[1:200], yaxis = :log10, xaxis = :log10, xlabel = "Iterations", ylabel = "Loss", label = "ADAM", color = :blue)
plot!(201:length(losses), losses[201:end], yaxis = :log10, xaxis = :log10, xlabel = "Iterations", ylabel = "Loss", label = "BFGS", color = :red)
savefig(pl_losses, joinpath(pwd(), "plots", "$(svname)_losses.pdf"))
# Rename the best candidate
p_trained = res2.minimizer

## Analysis of the trained network
# Plot the data and the approximation
ts = first(solution.t):mean(diff(solution.t))/2:last(solution.t)
X̂ = predict(p_trained, Xₙ[:,1], ts)
# Trained on noisy data vs real solution
pl_trajectory = plot(ts, transpose(X̂), xlabel = "t", ylabel ="x(t), y(t)", color = :red, label = ["UDE Approximation" nothing])
scatter!(solution.t, transpose(Xₙ), color = :black, label = ["Measurements" nothing])
savefig(pl_trajectory, joinpath(pwd(), "plots", "$(svname)_trajectory_reconstruction.pdf"))