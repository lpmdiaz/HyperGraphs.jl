using Test

const tests = [
    "traits",
    "core"
]

for test in tests
    @testset "$test" begin include("$test.jl") end
end
