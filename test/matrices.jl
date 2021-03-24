using HyperGraphs
using LinearAlgebra

hg1 = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([2, 3, 4])])
hg2 = HyperGraph([HyperEdge(["1", "2", "3"]), HyperEdge(["2", "3", "4"])])

# degree matrix
@test degree_matrix(hg1) == degree_matrix(hg2)
