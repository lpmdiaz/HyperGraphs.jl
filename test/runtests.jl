using Test

const tests = [
    "core",
    "properties",
    "queries",
    "traits",
    "utils"
]

for test in tests
    @testset "$test" begin include("$test.jl") end
end
