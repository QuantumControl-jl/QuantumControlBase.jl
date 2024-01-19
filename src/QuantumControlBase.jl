module QuantumControlBase

# The export here is simply to indicate which symbols should be re-exported in
# QuantumControl
export ControlProblem, Objective, optimize, propagate_objective
export propagate_objectives

include("atexit.jl")
include("conditionalthreads.jl")
include("objectives.jl")
include("propagate.jl")
include("derivs.jl")
include("functionals.jl")
include("infohook.jl")
include("check_amplitude.jl")
include("check_generator.jl")
include("optimize.jl")

end
