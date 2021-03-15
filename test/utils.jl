using HyperGraphs

# num_has_vertex
he = HyperEdge([1, 2, 3, 1])
@test HyperGraphs.num_has_vertex(he, 1) == 2
@test HyperGraphs.num_has_vertex(he, 4) == 0
che = ChemicalHyperEdge([1], [1, 2, 3])
@test HyperGraphs.num_has_vertex(che, 1) == 2
@test HyperGraphs.num_has_vertex(che, 4) == 0

hg = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([2, 3, 4])])
srcs = [[1], [4]]; tgts = [[1, 2, 3], [2, 3, 4]]
chg = ChemicalHyperGraph([ChemicalHyperEdge(src, tgt) for (src, tgt) in zip(srcs, tgts)])

# get_incident_hyperedges
@test HyperGraphs.get_incident_hyperedges(hg, 1) == [hyperedges(hg)[1]]
@test HyperGraphs.get_incident_hyperedges(chg, 1) == [hyperedges(chg)[1]]

# vertices_to_indices
@test all([HyperGraphs.vertices_to_indices(hg)[i] == i for i in 1:nv(hg)])
@test all([HyperGraphs.vertices_to_indices(chg)[i] == i for i in 1:nv(chg)])
