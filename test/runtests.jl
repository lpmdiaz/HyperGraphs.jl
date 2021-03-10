using Test

const tests = [
    "traits"
]

for test in tests
    @testset "$test" begin include("$test.jl") end
end
