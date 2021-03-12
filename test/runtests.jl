using Test

const tests = [
    "core"
    "queries"
    "traits",
]

for test in tests
    @testset "$test" begin include("$test.jl") end
end
