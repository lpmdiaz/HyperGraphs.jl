using HyperGraphs

## Boolean queries ##

# hyperedges
e = HyperEdge([1, 2, 3])
@test has_vertex(e, 1)
@test has_vertex(e, [1, 2]) == Vector{Bool}([true, true])
@test has_vertices(e, [1, 2])
che = ChemicalHyperEdge([1], [1, 2, 3])
@test has_vertex(che, 1)
@test has_vertex(che, [1, 2]) == Vector{Bool}([true, true])
@test has_vertices(che, [1, 2])
che = ChemicalHyperEdge(["W", "X"], ["Y", "Z"])
@test in_src("W", che) && in_src(["W"], che)[1]
@test all(in_src(src(che), che))
@test in_tgt("Y", che) && in_tgt(["Y"], che)[1]
@test all(in_tgt(tgt(che), che))

# hypergraphs
vertices_es = [[1, 2, 3], [2, 3, 4]]
es = [HyperEdge(vertices_es[1]), HyperEdge(vertices_es[2])]
x = HyperGraph(es)
@test has_vertex(x, 1)
@test has_vertices(x, vertices(x))
@test has_hyperedge(x, HyperEdge([1, 2, 3]))
@test has_hyperedges(x, hyperedges(x))
@test has_vertex(x, 1)
@test all(has_vertex(x, vertices(x)))
@test has_vertices(x, vertices(x))
@test has_vertex(hyperedges(x)[1], 1)
@test has_vertices(hyperedges(x)[1], [1, 2])
@test has_hyperedge(x, hyperedges(x)[1])
@test has_hyperedges(x, hyperedges(x))
srcs = [[1], [4]]; tgts = [[1, 2, 3], [2, 3, 4]]
ches = [ChemicalHyperEdge(src, tgt) for (src, tgt) in zip(srcs, tgts)]
vertices_chx = [1, 2, 3, 4]
chx = ChemicalHyperGraph(vertices_chx, ches)
@test has_vertex(chx, 1)
@test has_vertices(chx, vertices(chx))
@test !has_hyperedge(HyperGraph(), HyperEdge()) # an emty hypergraph does not have empty hyperedges
@test !has_hyperedge(ChemicalHyperGraph(), ChemicalHyperEdge()) # an emty hypergraph does not have empty hyperedges

# incidences
e1 = HyperEdge([1, 2, 3])
e2 = ChemicalHyperEdge([1], [2, 3])
@test isincident(e1, 1) && isincident(1, e1)
@test isincident(e2, 1) && isincident(1, e2)

# empty hyperedges and hypergraphs
@test isempty(HyperEdge())
@test isempty(HyperGraph())
@test isempty(HyperGraph[])
@test isempty(HyperEdge[])
@test isempty(ChemicalHyperEdge())
@test isempty(ChemicalHyperGraph())
@test isempty(ChemicalHyperGraph[])
@test isempty(ChemicalHyperEdge[])
@test !isempty(HyperGraph(HyperEdge())) # has one empty hyperedge
@test !isempty(ChemicalHyperGraph(ChemicalHyperEdge())) # has one empty hyperedge

# subhyperedge -- unoriented
e_sub = HyperEdge([1, 2])
e_super = HyperEdge([1, 2, 2, 3])
@test issubhyperedge(e_sub, e_super)
@test !issubhyperedge(e_super, e_sub)

# subhyperedge -- oriented
che_sub = ChemicalHyperEdge([1], [2])
che_super = ChemicalHyperEdge([1, 2], [2, 3, 4])
@test issubhyperedge(che_sub, che_super)
@test !issubhyperedge(che_super, che_sub)

# unique subhyperedge -- unoriented
e_sub = HyperEdge([1, 2])
x1 = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([2, 3, 4])])
x2 = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([1, 2, 3, 4])])
@test isuniquesubhyperedge(e_sub, x1)
@test !isuniquesubhyperedge(e_sub, x2)
@test isuniquesubhyperedge(e_sub, HyperGraph(e_sub)) # any hyperedge is a subedge of itself

# unique subhyperedge -- oriented
che_sub = ChemicalHyperEdge([1], [2])
x1 = ChemicalHyperGraph([ChemicalHyperEdge([1], [2, 3]), ChemicalHyperEdge([2], [3, 4])])
x2 = ChemicalHyperGraph([ChemicalHyperEdge([1], [2, 3]), ChemicalHyperEdge([1, 2], [2, 3, 4])])
@test isuniquesubhyperedge(che_sub, x1)
@test !isuniquesubhyperedge(che_sub, x2)
@test isuniquesubhyperedge(che_sub, ChemicalHyperGraph(che_sub)) # any hyperedge is a subedge of itself

# loops
unoriented_loop1 = HyperEdge([1, 1])
unoriented_loop2 = HyperEdge([1, 2, 1, 4])
positive_loop1 = ChemicalHyperEdge([1], [1])
positive_loop2 = ChemicalHyperEdge([1, 2], [2, 5])
negative_loop1 = ChemicalHyperEdge(Int[], [1, 1])
negative_loop2 = ChemicalHyperEdge([1, 2, 3], [4, 5, 4])
@test isloop(unoriented_loop1)
@test isloop(unoriented_loop2)
@test isloop(positive_loop1)
@test isloop(positive_loop2)
@test isloop(negative_loop1)
@test isloop(negative_loop2)
@test is_positive_loop(positive_loop1)
@test is_positive_loop(positive_loop1, 1)
@test is_positive_loop(positive_loop2)
@test is_positive_loop(positive_loop2, 2)
@test !is_positive_loop(positive_loop2, 5)
@test !has_loops(ChemicalHyperGraph())
@test !has_loops(HyperGraph())

# uniformity, regularity
@test iskuniform(x, 3)
@test !iskuniform(x, rand(Int))
@test iskuniform(chx, 4)
@test !iskuniform(chx, rand(Int))
@test iskregular(chx, 2)
@test !iskregular(chx, rand(Int))
@test !iskregular(x, rand(Int))

# chemical hypergraph & hyperedge queries
@test is_netstoich_null(ChemicalHyperEdge([1], [1, 2, 3, 4]), 1)
catalyst_edge = ChemicalHyperEdge([:X], [:X])
@test is_netstoich_null(catalyst_edge, :X)
@test iscatalyst(chx, 1) && iscatalyst(hyperedges(chx)[1], 1)

# parallel and multi-hyperedges

## content queries ##

# empty hyperedges and hypergraphs
@test empty_hyperedges(HyperGraph(HyperEdge())) == [HyperEdge()]
@test empty_hyperedges(ChemicalHyperGraph(ChemicalHyperEdge())) == [ChemicalHyperEdge()]
@test num_empty_hyperedges(HyperGraph()) == 0
@test num_empty_hyperedges(HyperGraph(HyperEdge())) == 1
@test num_empty_hyperedges(ChemicalHyperGraph()) == 0
@test num_empty_hyperedges(HyperGraph(HyperEdge())) == 1
@test has_empty_hyperedges(ChemicalHyperGraph(ChemicalHyperEdge()))

# neighbors
@test neighbors(x, 2) == [1, 3, 4]
@test inneighbors(chx, 1) == [1]
@test inneighbors(chx, 2) == [1, 4]
@test inneighbors(chx, 3) == [1, 4]
@test inneighbors(chx, 4) == [4]
@test outneighbors(chx, 1) == [1, 2, 3]
@test outneighbors(chx, 2) == []
@test outneighbors(chx, 3) == []
@test outneighbors(chx, 4) == [2, 3, 4]
@test all_neighbors(x, 1) == neighbors(x, 1) == [2, 3]
@test all_neighbors(x, 2) == neighbors(x, 2) == [1, 3, 4]
@test all_neighbors(chx, 1) == [1, 2, 3]
new_ches = [ChemicalHyperEdge(src, tgt) for (src, tgt) in zip([[1], [4]], [[1, 2, 3, 4], [2, 3, 4, 5]])]
new_chx = ChemicalHyperGraph(new_ches)
@test sort(all_neighbors(new_chx, 4)) == [1, 2, 3, 4, 5]
@test neighbors(HyperGraph(HyperEdge([1, 1])), 1) == [1] # loop
@test all_neighbors(ChemicalHyperGraph(ChemicalHyperEdge([1], [1])), 1) == [1] # loop

# loops
extra_unoriented_e = HyperEdge([1])
extra_oriented_che = ChemicalHyperEdge([1], [2])
@test loops([unoriented_loop1, unoriented_loop2, extra_unoriented_e]) == [unoriented_loop1, unoriented_loop2]
@test loops(HyperGraph([unoriented_loop1, unoriented_loop2, extra_unoriented_e])) == [unoriented_loop1, unoriented_loop2]
@test loops([positive_loop1, negative_loop1, extra_oriented_che]) == [positive_loop1, negative_loop1]
@test loops(ChemicalHyperGraph([positive_loop1, negative_loop1, extra_oriented_che])) == [positive_loop1, negative_loop1]
@test positive_loops([positive_loop1, positive_loop2, extra_oriented_che]) == [positive_loop1, positive_loop2]
@test positive_loops(ChemicalHyperGraph(positive_loop1))[1] == positive_loop1
@test positive_loops(ChemicalHyperGraph([positive_loop1, negative_loop1, negative_loop2]))[1] == positive_loop1
@test num_loops(HyperGraph([unoriented_loop1, unoriented_loop2, extra_unoriented_e])) == 2
@test num_loops(ChemicalHyperGraph([positive_loop1, negative_loop1, extra_oriented_che])) == 2

# catalysts (chemical hypergraphs)
@test catalysts(catalyst_edge) == [:X]
@test catalysts(ChemicalHyperEdge([:X, :Y, :Z], [:X])) == [:X]
@test catalysts(ches) == catalysts(chx) == [1, 4]
@test isempty(catalysts(ChemicalHyperEdge(SpeciesSet(:X), SpeciesSet(:X, 2)))) # non-null net stoichiometry

# parallel and multi-hyperedges
parallel_x = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([1, 2, 3])])
multi_x = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([1, 2, 3, 4])])
@test parallel_hyperedges(parallel_x) == multi_hyperedges(parallel_x) == hyperedges(parallel_x)
@test isempty(parallel_hyperedges(multi_x))
@test num_parallel_hyperedges(multi_x) == 0
@test multi_hyperedges(multi_x) == [hyperedges(multi_x)[1]]
@test num_parallel_hyperedges(parallel_x) == 2
@test num_multi_hyperedges(multi_x) == 1
@test has_parallel_hyperedges(parallel_x)
@test !has_parallel_hyperedges(multi_x)
@test has_multi_hyperedges(parallel_x)
@test has_multi_hyperedges(multi_x)
parallel_chx = ChemicalHyperGraph([ChemicalHyperEdge(src, tgt) for (src, tgt) in zip([[1], [1]], [[1, 2, 3], [1, 2, 3]])])
multi_chx = ChemicalHyperGraph([ChemicalHyperEdge(src, tgt) for (src, tgt) in zip([[1], [1]], [[1, 2, 3], [1, 2, 3, 4]])])
@test parallel_hyperedges(parallel_chx) == multi_hyperedges(parallel_chx) == hyperedges(parallel_chx)
@test isempty(parallel_hyperedges(multi_chx))
@test num_parallel_hyperedges(multi_chx) == 0
@test multi_hyperedges(multi_chx) == [hyperedges(multi_chx)[1]]
@test num_parallel_hyperedges(parallel_chx) == 2
@test num_multi_hyperedges(multi_chx) == 1
@test has_parallel_hyperedges(parallel_chx)
@test !has_parallel_hyperedges(multi_chx)
@test has_multi_hyperedges(parallel_chx)
@test has_multi_hyperedges(multi_chx)
