using Distributions: isprobvec

# hyperedges properties
vertices_e = [1, 2, 3]
e = HyperEdge(vertices_e)
@test length(e) == cardinality(e) == 3
vertices_es = [[1, 2, 3], [2, 3, 4]]
es = [HyperEdge(vertices_es[1]), HyperEdge(vertices_es[2])]
@test cardinalities(es) == [3, 3]
@test cardinalities(HyperGraph(es)) == [3, 3]
@test cardinality(HyperEdge([1, 1])) == 2 # cardinality of a self-loop is 2
srcs = [[1], [4]]; tgts = [[1, 2, 3], [2, 3, 4]]
ches = [ChemicalHyperEdge(src, tgt, 2) for (src, tgt) in zip(srcs, tgts)]
@test length.(ches) == cardinalities(ches) == cardinalities(ChemicalHyperGraph(ches)) == [4, 4]
@test cardinality(ChemicalHyperEdge(["X"], ["X"])) == 2 # cardinality of a self-loop is 2
@test nsrcs(ches[1]) == nsrcs(ches[2]) == 1
@test ntgts(ches[1]) == ntgts(ches[2]) == 3
@test nsrcs(ches[1]) + ntgts(ches[1]) == length(ches[1])
e = HyperEdge([1, 1, 2, 1])
che = ChemicalHyperEdge(SpeciesSet([1, 2], [2, 1]), SpeciesSet(1))
@test multiplicity(1, e) == multiplicity(1, che) == 3
@test cardinality(e) == cardinality(che) == 4
@test cardinality(ChemicalHyperEdge(SpeciesSet([1], [2]), SpeciesSet([2]))) == 3

# hypergraphs properties
x = HyperGraph(vertices_e, es)
@test nv(x) == length(vertices_e) == 3
@test nhe(x) == length(es) == 2
@test order(x) == 3
@test hypergraph_size(x) == 6
@test size(x) == (3, 2)
@test rank(x) == co_rank(x) == 3
vertices_chx = [1, 2, 3, 4]
chx = ChemicalHyperGraph(vertices_chx, ches)
@test nv(chx) == length(vertices_chx)
@test nhe(chx) == length(ches)
@test delta(x) == Δ(x) == 2
@test delta(chx) == Δ(chx) == 4
@test rank(chx) == co_rank(chx) == 4
@test sum(degree_counts(x)) == nv(x)
@test sum(cardinality_counts(x)) == nhe(x)
@test isprobvec(degree_distribution(x))
target_counts = [0, 2, 1]
@test degree_sequence(target_counts) == [2, 1, 1]
@test length(degree_sequence(target_counts)) == sum(target_counts)
@test degree_sequence([2, 1], degrees = [1, 2]) == [2, 1, 1] # truncate 0

# vertices properties
@test degree(x, 1) == 1
@test degrees(x, [1, 2]) == [1, 2]
@test degrees(x) == [1, 2, 2]
@test degrees(HyperGraph([HyperEdge([1, 1, 2, 3]), HyperEdge([2, 3, 4])])) == [2, 2, 2, 1]
@test degree(HyperGraph(HyperEdge([1, 1])), 1) == 2 # degree of a loop is 2
@test volume(x) == 5
@test degree(chx, 1) == 4
@test degrees(ChemicalHyperGraph([ChemicalHyperEdge([1], [1]), ChemicalHyperEdge([2], [1])])) == [3, 1]
@test outdegree(chx, 1) == 2
@test outdegrees(chx, [2]) == [0]
@test outdegrees(chx) == [2, 0, 0, 2]
@test indegree(chx, 1) == 2
@test indegrees(chx, [2]) == [4]
@test indegrees(chx) == [2, 4, 4, 2]
@test indegrees(chx) .+ outdegrees(chx) == degrees(chx)
@test degree(ChemicalHyperGraph(ChemicalHyperEdge([1], [1])), 1) == 2 # degree of a loop is 2
@test volume(chx) == 16
