using HyperGraphs

# project
x = project(HyperEdge, ChemicalHyperEdge([1], [1]))
y = project(HyperEdge, ChemicalHyperEdge([1], [1]), f=unique)
@test !isequal(x, y)
project.(HyperEdge, [ChemicalHyperEdge([1], [1]), ChemicalHyperEdge([2], [2])])
project(HyperGraph, ChemicalHyperGraph([ChemicalHyperEdge([1], [1]), ChemicalHyperEdge([2], [2])]))

# dual hypergraph
V₁ = collect(1:4)
i = [1; 2; 0; 1] # incidence vector
z = HyperGraph(V₁, BitMatrix(hcat(i, i) .!= 0))
@test isequal(dual(z, [1, 2]), dual(z)) # test automatic labelling of edges
V₂ = ["1", "2", "3", "4"]
I = BitArray([1 0; 1 1; 0 1; 1 1])
dual(HyperGraph(V₁, I))
dual(HyperGraph(V₂, I))