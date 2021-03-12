using HyperGraphs

## Boolean queries ##

# hyperedges
he = HyperEdge([1, 2, 3])
@test has_vertex(he, 1)
@test has_vertex(he, [1, 2]) == Vector{Bool}([true, true])
@test has_vertices(he, [1, 2])
che = ChemicalHyperEdge([1], [1, 2, 3])
@test has_vertex(che, 1)
@test has_vertex(che, [1, 2]) == Vector{Bool}([true, true])
@test has_vertices(che, [1, 2])
che = ChemicalHyperEdge(["W", "X"], ["Y", "Z"])
@test in_src("W", che) == in_src(["W"], che)[1]
@test all(in_src(src(che), che))
@test in_tgt("Y", che) == in_tgt(["Y"], che)[1]
@test all(in_tgt(tgt(che), che))

# hypergraphs
vertices_hes = [[1, 2, 3], [2, 3, 4]]
hes = [HyperEdge(vertices_hes[1]), HyperEdge(vertices_hes[2])]
hg = HyperGraph(hes)
@test has_vertex(hg, 1)
@test has_vertices(hg, vertices(hg))
@test has_hyperedge(hg, HyperEdge([1, 2, 3]))
@test has_hyperedges(hg, hyperedges(hg))
@test has_vertex(hg, 1)
@test all(has_vertex(hg, vertices(hg)))
@test has_vertices(hg, vertices(hg))
@test has_vertex(hyperedges(hg)[1], 1)
@test has_vertices(hyperedges(hg)[1], [1, 2])
@test has_hyperedge(hg, hyperedges(hg)[1])
@test has_hyperedges(hg, hyperedges(hg))
srcs = [[1], [4]]; tgts = [[1, 2, 3], [2, 3, 4]]
ches = [ChemicalHyperEdge(src, tgt) for (src, tgt) in zip(srcs, tgts)]
vertices_chg = [1, 2, 3, 4]
chg = ChemicalHyperGraph(vertices_chg, ches)
@test has_vertex(chg, 1)
@test has_vertices(chg, vertices(chg))

## content queries ##
