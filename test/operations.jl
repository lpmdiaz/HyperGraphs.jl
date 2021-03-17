using HyperGraphs

# adding and deleting vertices -- unoriented hypergraph
hg = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([2, 3, 4])])
@test add_vertex!(hg, 5, check=false) && has_vertex(hg, 5)
@test_throws ErrorException add_vertex!(hg, 5) # vertex already in hypergraph
@test_throws ErrorException add_vertex!(hg, 5.0) # type error
@test add_vertices!(hg, [6, 7]) && has_vertices(hg, [6, 7])
@test del_vertex!(hg , 1, weak=true) && has_hyperedge(hg, HyperEdge([2, 3])) # weak deletion of vertex retains hyperedges
@test del_vertex!(hg, 4) && !has_hyperedge(hg, HyperEdge([2, 3, 4])) # strong deletion of vertex removes hyperedges
@test del_vertices!(hg, [2, 3], weak=true) && !any(has_vertex(hg, [2, 3])) && has_empty_hyperedges(hg) # removing all vertices of a hyperedge weakly results in an empty hyperedge
@test del_vertices!(hg, vertices(hg)) && !any(has_vertex(hg, [5, 6, 7])) && has_hyperedge(hg, HyperEdge(Int[])) # only an empty hyperedge left
@test del_empty_hyperedges!(hg) && !has_empty_hyperedges(hg) && isempty(hg)
@test add_vertices!(hg, collect(1:4))
@test del_vertices!(hg, [1]) && add_vertices!(hg, [1]) # testing vectors with length 1
@test add_hyperedge!(hg, HyperEdge(vertices(hg)), check=false) && has_hyperedge(hg, HyperEdge(vertices(hg))) # check is true by default but not needed here
@test_throws ErrorException add_hyperedge!(hg, HyperEdge([10])) # can't add hyperedge if vertex not already in hypergraph
@test add_hyperedges!(hg, [HyperEdge([1 , 2, 3]), HyperEdge([1, 2, 3])]) && has_parallel_hyperedges(hg) # add parallel hyperedge
@test del_hyperedge!(hg, hyperedges(hg)[end]) && !has_parallel_hyperedges(hg) # removed parallel hyperedges
@test del_hyperedges!(hg, hyperedges(hg)) && isempty(hg)
@test del_vertices!(hg, vertices(hg)) && nv(hg) == 0

# removing parallel hyperedges in hypergraph with only parallel hyperedges -- unoriented hypergraph
hg = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([1, 2, 3])])
@test del_hyperedges!(hg, hyperedges(hg)) && isempty(hg)

# dealing with loops -- unoriented hypergraph
hg = HyperGraph{Int}([1, 2, 3], HyperEdge[]) # initialise an empty hypergraph with some vertices
@test add_hyperedge!(hg, HyperEdge([1, 1])) && has_loops(hg) && num_loops(hg) == 1
@test add_hyperedges!(hg, [HyperEdge([2, 2, 2]), HyperEdge([3, 3])]) && num_loops(hg) == 3
@test del_hyperedge!(hg, HyperEdge([1, 1])) && num_loops(hg) == 2
@test del_hyperedges!(hg, hyperedges(hg)) && !has_loops(hg) && isempty(hg)

# adding and deleting vertices -- oriented hypergraph
chg = ChemicalHyperGraph([ChemicalHyperEdge([1], [2, 3]), ChemicalHyperEdge([2], [3, 4])])
@test add_vertex!(chg, 5, check=false) && has_vertex(chg, 5)
@test_throws ErrorException add_vertex!(chg, 5) # vertex already in hypergraph
@test_throws ErrorException add_vertex!(chg, 5.0) # type error (might be bad for later developments)
@test add_vertices!(chg, [6, 7]) && has_vertices(chg, [6, 7])
@test del_vertex!(chg, 1, weak=true) && has_hyperedge(chg, ChemicalHyperEdge(Int[], [2, 3])) # weak deletion of vertex retains hyperedges
@test del_vertex!(chg, 4) && !has_hyperedge(chg, ChemicalHyperEdge([2], [3, 4])) # strong deletion of vertex removes hyperedges
@test del_vertices!(chg, [2, 3], weak=true) && !any(has_vertex(chg, [2, 3])) && has_empty_hyperedges(chg) # removing all vertices of a hyperedge weakly results in an empty hyperedge
@test del_vertices!(chg, vertices(chg)) && !any(has_vertex(chg, [5, 6, 7])) && has_hyperedge(chg, ChemicalHyperEdge{Int}()) # only an empty hyperedge left
@test del_empty_hyperedges!(chg) && !has_empty_hyperedges(chg) && isempty(chg)
@test add_vertices!(chg, collect(1:4))
@test del_vertices!(chg, [1]) && add_vertices!(chg, [1]) # testing vectors with length 1
@test add_hyperedge!(chg, ChemicalHyperEdge(vertices(chg), vertices(chg)), check=false) && has_hyperedge(chg, ChemicalHyperEdge(vertices(chg), vertices(chg))) # check is true by default but not needed here
@test_throws ErrorException add_hyperedge!(chg, ChemicalHyperEdge([10], [11])) # can't add hyperedge if vertex not already in hypergraph
@test add_hyperedges!(chg, [ChemicalHyperEdge([1], [2, 3]), ChemicalHyperEdge([1], [2, 3])]) && has_parallel_hyperedges(chg) # add parallel hyperedge
@test del_hyperedge!(chg, hyperedges(chg)[end]) && !has_parallel_hyperedges(chg) # removed parallel hyperedges
@test del_hyperedges!(chg, hyperedges(chg)) && isempty(chg)
@test del_vertices!(chg, vertices(chg)) && nv(chg) == 0

# removing parallel hyperedges in hypergraph with only parallel hyperedges -- oriented hypergraph
chg = ChemicalHyperGraph([ChemicalHyperEdge([1], [2, 3]), ChemicalHyperEdge([1], [2, 3])])
@test del_hyperedges!(chg, hyperedges(chg)) && isempty(chg)

# dealing with loops - oriented hypergraph
chg = ChemicalHyperGraph{Int}([1, 2, 3], ChemicalHyperEdge[]) # initialise an empty hypergraph with some vertices
@test add_hyperedge!(chg, ChemicalHyperEdge([1], [1])) && has_loops(chg) && num_loops(chg) == 1
@test add_hyperedges!(chg, [ChemicalHyperEdge([2], [2, 2]), ChemicalHyperEdge([3], [3])]) && num_loops(chg) == 3
@test del_hyperedge!(chg, ChemicalHyperEdge([1], [1])) && num_loops(chg) == 2
@test del_hyperedges!(chg, hyperedges(chg)) && !has_loops(chg) && isempty(chg)

# modifying hypergraphs of type Any
hg = HyperGraph{Any}(); v = 1; he = HyperEdge(Any[v, v])
@test add_vertex!(hg, v)
@test add_hyperedge!(hg, he)
@test vertices(hg) == [v] && nv(hg) == 1
@test hyperedges(hg) == [he] && nhe(hg) == 1
chg = ChemicalHyperGraph{Any}(); v = 1; che = ChemicalHyperEdge(Any[v], Any[v])
@test add_vertex!(chg, v)
@test add_hyperedge!(chg, che)
@test vertices(chg) == [v] && nv(chg) == 1
@test hyperedges(chg) == [che] && nhe(chg) == 1

# replace hyperedge, replace hyperedges -- unoriented hypergraph
hg = HyperGraph([HyperEdge([1]), HyperEdge([2])])
new_he = HyperEdge([1, 2])
@test replace_hyperedge!(hg, hyperedges(hg)[1], new_he) && has_hyperedge(hg, new_he)
new_hes = [HyperEdge([1, 1]), HyperEdge([2, 2])]
@test replace_hyperedges!(hg, hyperedges(hg), new_hes) && has_hyperedges(hg, new_hes)

# replace hyperedge, replace hyperedges -- oriented hypergraph
chg = ChemicalHyperGraph([ChemicalHyperEdge([1], [2]), ChemicalHyperEdge([2], [1])])
new_he = ChemicalHyperEdge([1], [1])
@test replace_hyperedge!(chg, hyperedges(chg)[1], new_he) && has_hyperedge(chg, new_he)
new_hes = [ChemicalHyperEdge([1], [1]), ChemicalHyperEdge([2], [2])]
@test replace_hyperedges!(chg, hyperedges(chg), new_hes) && has_hyperedges(chg, new_hes)

# weight updating
chg = ChemicalHyperGraph([ChemicalHyperEdge(src, tgt) for (src, tgt) in zip([[1], [4]], [[1, 2, 3], [2, 3, 4]])])
che = hyperedges(chg)[1]
@test update_weight!(hyperedges(chg)[1], 2) == 2 && weight(che) == 2
@test update_weight!(chg, che, 3) == 3 && weight(che) == 3
@test set_all_weights!(chg, 4) == repeat([4], nhe(chg))
@test all(weight.(hyperedges(chg)) .== 4)

# hypergraphs merging
he1 = HyperEdge([1, 1])
he2 = HyperEdge([1, 2])
@test merge(HyperGraph(he1), HyperGraph(he2)) == HyperGraph([he1, he2])
che1 = ChemicalHyperEdge([1], [1])
che2 = ChemicalHyperEdge([1], [2])
@test merge(ChemicalHyperGraph(che1), ChemicalHyperGraph(che2)) == ChemicalHyperGraph([che1, che2])

# vertex-induced subhypergraph
hg = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([2, 3, 4])])
@test nv(subhypergraph(hg, 1)) == 3
@test subhypergraph(hg, 2) == subhypergraph(hg, [2]) == hg
@test subhypergraph(hg, 4) == subhypergraph(hg, [4])
@test subhypergraph(hg, vertices(hg)) == hg
chg = ChemicalHyperGraph([ChemicalHyperEdge(src, tgt) for (src, tgt) in zip([[1], [4]], [[1, 2, 3], [2, 3, 4]])])
@test nv(subhypergraph(chg, 1)) == 3
@test subhypergraph(chg, 2) == subhypergraph(chg, [2]) == chg
@test subhypergraph(chg, 4) == subhypergraph(chg, [4])
@test subhypergraph(chg, vertices(chg)) == chg

# hyperedge-induced subhypergraph
@test nhe(subhypergraph(hg, hyperedges(hg)[1])) == 1
@test nv(subhypergraph(hg, HyperEdge([1, 2]), relaxed=true)) == 2
@test_throws ErrorException subhypergraph(hg, HyperEdge([2, 3]), relaxed=true) # subhyperedge is not unique
@test subhypergraph(hg, hyperedges(hg)) == hg
@test vertices(subhypergraph(hg, [HyperEdge([1, 2]), HyperEdge([3, 4])], relaxed=true)) == vertices(hg)
@test nhe(subhypergraph(chg, hyperedges(chg)[1])) == 1
@test nv(subhypergraph(chg, ChemicalHyperEdge([1], [2]), relaxed=true)) == 2
@test_throws ErrorException subhypergraph(chg, ChemicalHyperEdge(Int[], [2, 3]), relaxed=true) # subhyperedge is not unique
@test subhypergraph(chg, hyperedges(chg)) == chg
@test vertices(subhypergraph(chg, [ChemicalHyperEdge(Int[], [1, 2]), ChemicalHyperEdge(Int[], [3, 4])], relaxed=true)) == vertices(chg)

# hyperedge-induced subhypergraph with parallel hyperedges
he = HyperEdge([1, 2, 3])
parallel_hg = HyperGraph([he, he])
@test subhypergraph(parallel_hg, he) == parallel_hg
che = ChemicalHyperEdge([1, 2], [3])
parallel_chg = ChemicalHyperGraph([che, che])
@test subhypergraph(parallel_chg, che) == parallel_chg
