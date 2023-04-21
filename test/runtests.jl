using Test

const tests = [
    "core",
    "projections",
    "graph-theory",
    "matrices",
    "operations",
    "properties",
    "queries",
    "traits",
    "utils"
]

for test in tests
    @testset "$test" begin include("$test.jl") end
end
