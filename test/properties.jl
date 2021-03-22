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
@test nsrcs(ches[1]) == nsrcs(ches[2]) == 1
@test ntgts(ches[1]) == ntgts(ches[2]) == 3
@test nsrcs(ches[1]) + ntgts(ches[1]) == length(ches[1])
@test nsrcs(ches[1]) + ntgts(ches[1]) == length(ches[1])

# hypergraphs properties
hg = HyperGraph(vertices_he, hes)
@test nv(hg) == length(vertices_he) == 3
@test nhe(hg) == length(hes) == 2
@test order(hg) == 3
@test hypergraph_size(hg) == 6
@test size(hg) == (3, 2)
@test rank(hg) == 2
vertices_chg = [1, 2, 3, 4]
chg = ChemicalHyperGraph(vertices_chg, ches)
@test nv(chg) == length(vertices_chg)
@test nhe(chg) == length(ches)
@test rank(chg) == 2

# vertices properties
@test degree(hg, 1) == 1
@test degrees(hg, [1, 2]) == [1, 2]
@test degrees(hg) == [1, 2, 2]
@test degrees(HyperGraph([HyperEdge([1, 1, 2, 3]), HyperEdge([2, 3, 4])])) == [2, 2, 2, 1]
@test degree(HyperGraph(HyperEdge([1, 1])), 1) == 2 # degree of a loop is 2
@test volume(hg, vertices(hg)) == 5
@test degree(chg, 1) == 2
@test degrees(ChemicalHyperGraph([ChemicalHyperEdge([1], [1]), ChemicalHyperEdge([2], [1])])) == [3, 1]
@test outdegree(chg, 1) == 1
@test outdegrees(chg, [2]) == [0]
@test outdegrees(chg) == [1, 0, 0, 1]
@test indegree(chg, 1) == 1
@test indegrees(chg, [2]) == [2]
@test indegrees(chg) == [1, 2, 2, 1]
@test indegrees(chg) .+ outdegrees(chg) == degrees(chg)
@test degree(ChemicalHyperGraph(ChemicalHyperEdge([1], [1])), 1) == 2 # degree of a loop is 2
@test volume(chg, vertices(chg)) == 8
