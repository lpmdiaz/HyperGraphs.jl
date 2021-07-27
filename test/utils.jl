using HyperGraphs

x = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([2, 3, 4])])
srcs = [[1], [4]]; tgts = [[1, 2, 3], [2, 3, 4]]
chx = ChemicalHyperGraph([ChemicalHyperEdge(src, tgt) for (src, tgt) in zip(srcs, tgts)])

# num_has_vertex
e = HyperEdge([1, 2, 3, 1])
@test HyperGraphs.num_has_vertex(e, 1) == 2
@test HyperGraphs.num_has_vertex(e, 4) == 0
che = ChemicalHyperEdge([1], [1, 2, 3])
@test HyperGraphs.num_has_vertex(che, 1) == 2
@test HyperGraphs.num_has_vertex(che, 4) == 0
@test HyperGraphs.num_has_vertex(x, 2) == 2
@test HyperGraphs.num_has_vertex(chx, 2) == 2

# get_incident_hyperedges
@test HyperGraphs.get_incident_hyperedges(x, 1) == [hyperedges(x)[1]]
@test HyperGraphs.get_incident_hyperedges(chx, 1) == [hyperedges(chx)[1]]

# vertices_to_indices
@test all([HyperGraphs.vertices_to_indices(x)[i] == i for i in 1:nv(x)])
@test all([HyperGraphs.vertices_to_indices(chx)[i] == i for i in 1:nv(chx)])

# stoichiometries
@test HyperGraphs.stoichiometries(ChemicalHyperEdge([:X], [:X]), :X) == ([1], [1])
