using HyperGraphs

he = HyperEdge([1, 2, 3, 1])
@test num_has_vertex(he, 1) == 2
@test num_has_vertex(he, 4) == 0
che = ChemicalHyperEdge([1], [1, 2, 3])
@test num_has_vertex(che, 1) == 2
@test num_has_vertex(che, 4) == 0
