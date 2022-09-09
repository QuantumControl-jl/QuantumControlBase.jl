using Test
using LinearAlgebra
using QuantumControlBase.TestUtils
using QuantumControlBase: Objective

@testset "Sparse objective adjoint" begin

    obj = dummy_control_problem().objectives[1]
    adj = adjoint(obj)

    @test norm(adj.initial_state - obj.initial_state) ≈ 0
    @test norm(adj.target_state - obj.target_state) ≈ 0
    @test norm(adj.generator[1] - obj.generator[1]') ≈ 0
    @test norm(adj.generator[2][1] - obj.generator[2][1]') ≈ 0
    @test adj.generator[2][2] == obj.generator[2][2]

end

@testset "Dense objective adjoint" begin

    obj = dummy_control_problem(sparsity=1.0).objectives[1]
    adj = adjoint(obj)

    @test norm(adj.initial_state - obj.initial_state) ≈ 0
    @test norm(adj.target_state - obj.target_state) ≈ 0
    @test norm(adj.generator[1] - obj.generator[1]') ≈ 0
    @test norm(adj.generator[1] - obj.generator[1]) ≈ 0
    @test norm(adj.generator[2][1] - obj.generator[2][1]') ≈ 0
    @test adj.generator[2][2] == obj.generator[2][2]

end

@testset "Non-Hermitian objective adjoint" begin

    obj = dummy_control_problem(sparsity=1.0, hermitian=false).objectives[1]
    adj = adjoint(obj)

    @test norm(adj.initial_state - obj.initial_state) ≈ 0
    @test norm(adj.target_state - obj.target_state) ≈ 0
    @test norm(adj.generator[1] - obj.generator[1]') ≈ 0
    @test norm(adj.generator[1] - obj.generator[1]) > 0
    @test norm(adj.generator[2][1] - obj.generator[2][1]') ≈ 0
    @test norm(adj.generator[2][1] - obj.generator[2][1]) > 0
    @test adj.generator[2][2] == obj.generator[2][2]

end


@testset "weighted objective adjoint" begin

    obj0 = dummy_control_problem().objectives[1]
    obj = Objective(
        initial_state=obj0.initial_state,
        generator=obj0.generator,
        target_state=obj0.target_state,
        weight=0.2
    )
    adj = adjoint(obj)

    @test adj.weight == obj.weight

end

@testset "custom objective adjoint" begin

    obj0 = dummy_control_problem(hermitian=false).objectives[1]

    obj = Objective(
        initial_state=obj0.initial_state,
        generator=obj0.generator,
        gate="CNOT",
        weight=0.5,
        coeff=1im
    )

    @test propertynames(obj) ==
          (:initial_state, :generator, :target_state, :weight, :coeff, :gate)
    kwargs = getfield(obj, :kwargs)
    @test :coeff ∈ keys(kwargs)
    @test isnothing(obj.target_state)
    @test obj.gate == "CNOT"
    @test obj.coeff == 1im

    adj = adjoint(obj)

    @test norm(adj.initial_state - obj.initial_state) ≈ 0
    @test norm(adj.generator[1] - obj.generator[1]') ≈ 0
    @test norm(adj.generator[1] - obj.generator[1]) > 0
    @test adj.gate == "CNOT"
    @test adj.weight == 0.5
    @test adj.coeff == 1im

end
