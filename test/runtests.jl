using Test

const tests = [
    "core",
    "conversions",
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
