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
@test in_src("W", che) && in_src(["W"], che)[1]
@test all(in_src(src(che), che))
@test in_tgt("Y", che) && in_tgt(["Y"], che)[1]
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
@test !has_hyperedge(HyperGraph(), HyperEdge()) # an emty hypergraph does not have empty hyperedges
@test !has_hyperedge(ChemicalHyperGraph(), ChemicalHyperEdge()) # an emty hypergraph does not have empty hyperedges

# incidences
he1 = HyperEdge([1, 2, 3])
he2 = ChemicalHyperEdge([1], [2, 3])
@test isincident(he1, 1) && isincident(1, he1)
@test isincident(he2, 1) && isincident(1, he2)

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
he_sub = HyperEdge([1, 2])
he_super = HyperEdge([1, 2, 2, 3])
@test issubhyperedge(he_sub, he_super)
@test !issubhyperedge(he_super, he_sub)

# subhyperedge -- oriented
he_sub = ChemicalHyperEdge([1], [2])
he_super = ChemicalHyperEdge([1, 2], [2, 3, 4])
@test issubhyperedge(he_sub, he_super)
@test !issubhyperedge(he_super, he_sub)

# unique subhyperedge -- unoriented
he_sub = HyperEdge([1, 2])
hg1 = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([2, 3, 4])])
hg2 = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([1, 2, 3, 4])])
@test isuniquesubhyperedge(he_sub, hg1)
@test !isuniquesubhyperedge(he_sub, hg2)
@test isuniquesubhyperedge(he_sub, HyperGraph(he_sub)) # any hyperedge is a subedge of itself

# unique subhyperedge -- oriented
he_sub = ChemicalHyperEdge([1], [2])
hg1 = ChemicalHyperGraph([ChemicalHyperEdge([1], [2, 3]), ChemicalHyperEdge([2], [3, 4])])
hg2 = ChemicalHyperGraph([ChemicalHyperEdge([1], [2, 3]), ChemicalHyperEdge([1, 2], [2, 3, 4])])
@test isuniquesubhyperedge(he_sub, hg1)
@test !isuniquesubhyperedge(he_sub, hg2)
@test isuniquesubhyperedge(he_sub, ChemicalHyperGraph(he_sub)) # any hyperedge is a subedge of itself

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
@test iskuniform(hg, 3)
@test !iskuniform(hg, rand(Int))
@test iskuniform(chg, 4)
@test !iskuniform(chg, rand(Int))
@test iskregular(chg, 2)
@test !iskregular(chg, rand(Int))
@test !iskregular(hg, rand(Int))

# chemical hypergraph & hyperedge queries
@test is_netstoich_null(ChemicalHyperEdge([1], [1, 2, 3, 4]), 1)
catalyst_edge = ChemicalHyperEdge([:X], [:X])
@test is_netstoich_null(catalyst_edge, :X)
@test iscatalyst(chg, 1) && iscatalyst(hyperedges(chg)[1], 1)

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
@test neighbors(hg, 2) == [1, 3, 4]
@test inneighbors(chg, 1) == [1]
@test inneighbors(chg, 2) == [1, 4]
@test inneighbors(chg, 3) == [1, 4]
@test inneighbors(chg, 4) == [4]
@test outneighbors(chg, 1) == [1, 2, 3]
@test outneighbors(chg, 2) == []
@test outneighbors(chg, 3) == []
@test outneighbors(chg, 4) == [2, 3, 4]
@test all_neighbors(hg, 1) == neighbors(hg, 1) == [2, 3]
@test all_neighbors(hg, 2) == neighbors(hg, 2) == [1, 3, 4]
@test all_neighbors(chg, 1) == [1, 2, 3]
new_ches = [ChemicalHyperEdge(src, tgt) for (src, tgt) in zip([[1], [4]], [[1, 2, 3, 4], [2, 3, 4, 5]])]
new_chg = ChemicalHyperGraph(new_ches)
@test sort(all_neighbors(new_chg, 4)) == [1, 2, 3, 4, 5]
@test neighbors(HyperGraph(HyperEdge([1, 1])), 1) == [1] # loop
@test all_neighbors(ChemicalHyperGraph(ChemicalHyperEdge([1], [1])), 1) == [1] # loop

# loops
extra_unoriented_he = HyperEdge([1])
extra_oriented_che = ChemicalHyperEdge([1], [2])
@test loops([unoriented_loop1, unoriented_loop2, extra_unoriented_he]) == [unoriented_loop1, unoriented_loop2]
@test loops(HyperGraph([unoriented_loop1, unoriented_loop2, extra_unoriented_he])) == [unoriented_loop1, unoriented_loop2]
@test loops([positive_loop1, negative_loop1, extra_oriented_che]) == [positive_loop1, negative_loop1]
@test loops(ChemicalHyperGraph([positive_loop1, negative_loop1, extra_oriented_che])) == [positive_loop1, negative_loop1]
@test positive_loops([positive_loop1, positive_loop2, extra_oriented_che]) == [positive_loop1, positive_loop2]
@test positive_loops(ChemicalHyperGraph(positive_loop1))[1] == positive_loop1
@test positive_loops(ChemicalHyperGraph([positive_loop1, negative_loop1, negative_loop2]))[1] == positive_loop1
@test num_loops(HyperGraph([unoriented_loop1, unoriented_loop2, extra_unoriented_he])) == 2
@test num_loops(ChemicalHyperGraph([positive_loop1, negative_loop1, extra_oriented_che])) == 2

# catalysts (chemical hypergraphs)
@test catalysts(catalyst_edge) == [:X]
@test catalysts(ChemicalHyperEdge([:X, :Y, :Z], [:X])) == [:X]
@test catalysts(ches) == catalysts(chg) == [1, 4]
@test isempty(catalysts(ChemicalHyperEdge(SpeciesSet(:X), SpeciesSet(:X, 2)))) # non-null net stoichiometry
