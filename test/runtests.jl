using Test

const tests = [
    "core",
    "properties",
    "traits"
]

for test in tests
    @testset "$test" begin include("$test.jl") end
end
