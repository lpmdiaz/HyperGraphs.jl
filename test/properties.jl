# hyperedges properties
vertices_he = [1, 2, 3]
he = HyperEdge(vertices_he)
@test length(he) == cardinality(he) == 3
vertices_hes = [[1, 2, 3], [2, 3, 4]]
hes = [HyperEdge(vertices_hes[1]), HyperEdge(vertices_hes[2])]
@test cardinalities(hes) == [3, 3]
@test cardinality(HyperEdge([1, 1])) == 2 # cardinality of a self-loop is 2
srcs = [[1], [4]]; tgts = [[1, 2, 3], [2, 3, 4]]
ches = [ChemicalHyperEdge(src, tgt) for (src, tgt) in zip(srcs, tgts)]
@test length.(ches) == cardinalities(ches) == [4, 4]
@test cardinality(ChemicalHyperEdge(["X"], ["X"])) == 2 # cardinality of a self-loop is 2

# hypergraphs properties
hg = HyperGraph(vertices_he, hes)
@test nv(hg) == length(vertices_he) == 3
@test nhe(hg) == length(hes) == 2
@test order(hg) == 3
@test hypergraph_size(hg) == 6
@test size(hg) == (3, 2)
vertices_chg = [1, 2, 3, 4]
chg = ChemicalHyperGraph(vertices_chg, ches)
@test nv(chg) == length(vertices_chg)
@test nhe(chg) == length(ches)
