using HyperGraphs
using LinearAlgebra: Diagonal

## matrices ##

# incidence matrix of undirected graph from https://en.wikipedia.org/wiki/Incidence_matrix
hes = [HyperEdge([1, 2]), HyperEdge([1, 3]), HyperEdge([1, 4]), HyperEdge([3, 4])]
ref_incidence = [1 1 1 0; 1 0 0 0; 0 1 0 1; 0 0 1 1]
@test incidence_matrix(HyperGraph(hes)) == ref_incidence

# example from: Chen, G., Liu, V., Robinson, E., Rusnak, L. J., & Wang, K. (2018). A characterization of oriented hypergraphic Laplacian and adjacency matrix coefficients. Linear Algebra and Its Applications, 556, 323–341.
srcs = [[2], [1, 2], Int[]]; tgts = [[1], [2, 3], [3, 3]]
chen2018_es = [ChemicalHyperEdge(src, tgt) for (src, tgt) in zip(srcs, tgts)]
chen2018_x = ChemicalHyperGraph([1, 2, 3], chen2018_es)
ref_degree = [2; 3; 3]
ref_incidence = [1 -1 0; -1 0 0; 0 1 2]
ref_adjacency = [0 1 1; 1 2 0; 1 0 -2]
@test ref_incidence * transpose(ref_incidence) == Diagonal(ref_degree) - ref_adjacency # II^T = D - A
@test degrees(chen2018_x) == ref_degree
@test degree_matrix(chen2018_x) == Diagonal(ref_degree)
@test incidence_matrix(chen2018_x) == ref_incidence

# undirected graph from https://en.wikipedia.org/wiki/Laplacian_matrix
wikipedia_edges = HyperEdge.([[1, 2], [2, 3], [3, 4], [4, 5], [5, 1], [5, 2], [6, 4]])
wikipedia_graph = HyperGraph(wikipedia_edges)
@test degree_matrix(wikipedia_graph) == Diagonal([2; 3; 2; 3; 3; 1])

## loops ##

# NOTES
# loops should always have degree 2

# unoriented loop
unoriented_loop = HyperGraph(HyperEdge([1, 1]))
@test incidence_matrix(unoriented_loop) == 2*ones(Int, 1, 1)
@test degrees(unoriented_loop) == [2]

# oriented loops
positive_loop = ChemicalHyperGraph(ChemicalHyperEdge([1], [1]))
@test incidence_matrix(positive_loop) == zeros(Int, 1, 1)
@test degrees(positive_loop) == [2]
negative_loop = ChemicalHyperGraph(ChemicalHyperEdge(Int[], [1, 1]))
@test incidence_matrix(negative_loop) == 2*ones(Int, 1, 1)
@test degrees(negative_loop) == [2]
