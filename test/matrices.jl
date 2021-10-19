using HyperGraphs
using LinearAlgebra: Diagonal

x1 = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([2, 3, 4])])
x2 = HyperGraph([HyperEdge(["1", "2", "3"]), HyperEdge(["2", "3", "4"])])
x3 = ChemicalHyperGraph([ChemicalHyperEdge(), ChemicalHyperEdge()])

# degree matrix
@test degree_matrix(x1) == degree_matrix(x2)

# incidence matrix
@test incidence_matrix(x1) == incidence_matrix(x2)

# cardinality matrix
@test cardinality_matrix(x1) == cardinality_matrix(x2) == Diagonal([3, 3])

# weight matrix
@test weight_matrix(x3) == Diagonal([1, 1])
