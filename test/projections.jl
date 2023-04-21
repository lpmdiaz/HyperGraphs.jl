using HyperGraphs

x = project(HyperEdge, ChemicalHyperEdge([1], [1]))
y = project(HyperEdge, ChemicalHyperEdge([1], [1]), f=unique)
@test !isequal(x, y)
project.(HyperEdge, [ChemicalHyperEdge([1], [1]), ChemicalHyperEdge([2], [2])])
project(HyperGraph, ChemicalHyperGraph([ChemicalHyperEdge([1], [1]), ChemicalHyperEdge([2], [2])]))