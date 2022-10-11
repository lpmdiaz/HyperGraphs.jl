using HyperGraphs

# adding and deleting vertices -- unoriented hypergraph
x = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([2, 3, 4])])
@test add_vertex!(x, 5, check=false) && has_vertex(x, 5)
@test_throws ErrorException add_vertex!(x, 5) # vertex already in hypergraph
@test_throws ErrorException add_vertex!(x, 5.0) # type error
@test add_vertices!(x, [6, 7]) && has_vertices(x, [6, 7])
@test del_vertex!(x , 1, weak=true) && has_hyperedge(x, HyperEdge([2, 3])) # weak deletion of vertex retains hyperedges
@test del_vertex!(x, 4) && !has_hyperedge(x, HyperEdge([2, 3, 4])) # strong deletion of vertex removes hyperedges
@test del_vertices!(x, [2, 3], weak=true) && !any(has_vertex(x, [2, 3])) && has_empty_hyperedges(x) # removing all vertices of a hyperedge weakly results in an empty hyperedge
@test del_vertices!(x, vertices(x)) && !any(has_vertex(x, [5, 6, 7])) && has_hyperedge(x, HyperEdge(Int[])) # only an empty hyperedge left
@test del_empty_hyperedges!(x) && !has_empty_hyperedges(x) && isempty(x)
@test add_vertices!(x, collect(1:4))
@test del_vertices!(x, [1]) && add_vertices!(x, [1]) # testing vectors with length 1
@test add_hyperedge!(x, HyperEdge(vertices(x)), check=false) && has_hyperedge(x, HyperEdge(vertices(x))) # check is true by default but not needed here
@test_throws ErrorException add_hyperedge!(x, HyperEdge([10])) # can't add hyperedge if vertex not already in hypergraph
@test add_hyperedges!(x, [HyperEdge([1 , 2, 3]), HyperEdge([1, 2, 3])]) && has_parallel_hyperedges(x) # add parallel hyperedge
@test del_hyperedge!(x, hyperedges(x)[end]) && !has_parallel_hyperedges(x) # removed parallel hyperedges
@test del_hyperedges!(x, hyperedges(x)) && isempty(x)
@test del_vertices!(x, vertices(x)) && nv(x) == 0

# removing parallel hyperedges in hypergraph with only parallel hyperedges -- unoriented hypergraph
x = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([1, 2, 3])])
@test del_hyperedges!(x, hyperedges(x)) && isempty(x)

# dealing with loops -- unoriented hypergraph
x = HyperGraph{Int}([1, 2, 3], HyperEdge[]) # initialise an empty hypergraph with some vertices
@test add_hyperedge!(x, HyperEdge([1, 1])) && has_loops(x) && num_loops(x) == 1
@test add_hyperedges!(x, [HyperEdge([2, 2, 2]), HyperEdge([3, 3])]) && num_loops(x) == 3
@test del_hyperedge!(x, HyperEdge([1, 1])) && num_loops(x) == 2
@test del_hyperedges!(x, hyperedges(x)) && !has_loops(x) && isempty(x)

# adding and deleting vertices -- oriented hypergraph
chx = ChemicalHyperGraph([ChemicalHyperEdge([1], [2, 3]), ChemicalHyperEdge([2], [3, 4])])
@test add_vertex!(chx, 5, check=false) && has_vertex(chx, 5)
@test_throws ErrorException add_vertex!(chx, 5) # vertex already in hypergraph
@test_throws ErrorException add_vertex!(chx, 5.0) # type error (might be bad for later developments)
@test add_vertices!(chx, [6, 7]) && has_vertices(chx, [6, 7])
@test del_vertex!(chx, 1, weak=true) && has_hyperedge(chx, ChemicalHyperEdge(Int[], [2, 3])) # weak deletion of vertex retains hyperedges
@test del_vertex!(chx, 4) && !has_hyperedge(chx, ChemicalHyperEdge([2], [3, 4])) # strong deletion of vertex removes hyperedges
@test del_vertices!(chx, [2, 3], weak=true) && !any(has_vertex(chx, [2, 3])) && has_empty_hyperedges(chx) # removing all vertices of a hyperedge weakly results in an empty hyperedge
@test del_vertices!(chx, vertices(chx)) && !any(has_vertex(chx, [5, 6, 7])) && has_hyperedge(chx, ChemicalHyperEdge{Int}()) # only an empty hyperedge left
@test del_empty_hyperedges!(chx) && !has_empty_hyperedges(chx) && isempty(chx)
@test add_vertices!(chx, collect(1:4))
@test del_vertices!(chx, [1]) && add_vertices!(chx, [1]) # testing vectors with length 1
@test add_hyperedge!(chx, ChemicalHyperEdge(vertices(chx), vertices(chx)), check=false) && has_hyperedge(chx, ChemicalHyperEdge(vertices(chx), vertices(chx))) # check is true by default but not needed here
@test_throws ErrorException add_hyperedge!(chx, ChemicalHyperEdge([10], [11])) # can't add hyperedge if vertex not already in hypergraph
@test add_hyperedges!(chx, [ChemicalHyperEdge([1], [2, 3]), ChemicalHyperEdge([1], [2, 3])]) && has_parallel_hyperedges(chx) # add parallel hyperedge
@test del_hyperedge!(chx, hyperedges(chx)[end]) && !has_parallel_hyperedges(chx) # removed parallel hyperedges
@test del_hyperedges!(chx, hyperedges(chx)) && isempty(chx)
@test del_vertices!(chx, vertices(chx)) && nv(chx) == 0

# removing parallel hyperedges in hypergraph with only parallel hyperedges -- oriented hypergraph
chx = ChemicalHyperGraph([ChemicalHyperEdge([1], [2, 3]), ChemicalHyperEdge([1], [2, 3])])
@test del_hyperedges!(chx, hyperedges(chx)) && isempty(chx)

# dealing with loops - oriented hypergraph
chx = ChemicalHyperGraph{Int}([1, 2, 3], ChemicalHyperEdge[]) # initialise an empty hypergraph with some vertices
@test add_hyperedge!(chx, ChemicalHyperEdge([1], [1])) && has_loops(chx) && num_loops(chx) == 1
@test add_hyperedges!(chx, [ChemicalHyperEdge([2], [2, 2]), ChemicalHyperEdge([3], [3])]) && num_loops(chx) == 3
@test del_hyperedge!(chx, ChemicalHyperEdge([1], [1])) && num_loops(chx) == 2
@test del_hyperedges!(chx, hyperedges(chx)) && !has_loops(chx) && isempty(chx)

# modifying hypergraphs of type Any
x = HyperGraph{Any}(); v = 1; e = HyperEdge(Any[v, v])
@test add_vertex!(x, v)
@test add_hyperedge!(x, e)
@test vertices(x) == [v] && nv(x) == 1
@test hyperedges(x) == [e] && nhe(x) == 1
chx = ChemicalHyperGraph{Any}(); v = 1; che = ChemicalHyperEdge(Any[v], Any[v])
@test add_vertex!(chx, v)
@test add_hyperedge!(chx, che)
@test vertices(chx) == [v] && nv(chx) == 1
@test hyperedges(chx) == [che] && nhe(chx) == 1

e = HyperEdge([1, 2, 3])
replace_vertex!(e, (2 => 1))
@test vertices(e) == [1, 1, 3]
che = ChemicalHyperEdge([1, 2, 3], [2, 3, 4])
replace_vertex!(che, (2 => 1))
@test vertices(che) == [1, 1, 3, 1, 3, 4]
x = HyperGraph(e)
replace_vertex!(x, (2 => 1))
@test vertices(x) == [1, 3]
@test vertices(hyperedges(x)) == [[1, 1, 3]]
chx = ChemicalHyperGraph(che)
replace_vertex!(chx, (2 => 1))
@test vertices(x) == [1, 3]
@test vertices(hyperedges(chx)) == [[1, 1, 3, 1, 3, 4]]

# replace hyperedge, replace hyperedges -- unoriented hypergraph
x = HyperGraph([HyperEdge([1]), HyperEdge([2])])
new_e = HyperEdge([1, 2])
@test replace_hyperedge!(x, hyperedges(x)[1], new_e) && has_hyperedge(x, new_e)
new_es = [HyperEdge([1, 1]), HyperEdge([2, 2])]
@test replace_hyperedges!(x, hyperedges(x), new_es) && has_hyperedges(x, new_es)

# replace hyperedge, replace hyperedges -- oriented hypergraph
chx = ChemicalHyperGraph([ChemicalHyperEdge([1], [2]), ChemicalHyperEdge([2], [1])])
new_che = ChemicalHyperEdge([1], [1])
@test replace_hyperedge!(chx, hyperedges(chx)[1], new_che) && has_hyperedge(chx, new_che)
new_ches = [ChemicalHyperEdge([1], [1]), ChemicalHyperEdge([2], [2])]
@test replace_hyperedges!(chx, hyperedges(chx), new_ches) && has_hyperedges(chx, new_ches)

# weight updating
chx = ChemicalHyperGraph([ChemicalHyperEdge(src, tgt) for (src, tgt) in zip([[1], [4]], [[1, 2, 3], [2, 3, 4]])])
che = hyperedges(chx)[1]
@test update_weight!(hyperedges(chx)[1], 2) == 2 && weight(che) == 2
@test update_weight!(chx, che, 3) == 3 && weight(che) == 3
@test set_all_weights!(chx, 4) == repeat([4], nhe(chx))
@test all(weight.(hyperedges(chx)) .== 4)

# hypergraphs merging
e1 = HyperEdge([1, 1])
e2 = HyperEdge([1, 2])
@test merge(HyperGraph(e1), HyperGraph(e2)) == HyperGraph([e1, e2])
@test merge(HyperGraph(e1), HyperGraph(e2), HyperGraph(e2)) == HyperGraph([e1, e2, e2])
che1 = ChemicalHyperEdge([1], [1])
che2 = ChemicalHyperEdge([1], [2])
@test merge(ChemicalHyperGraph(che1), ChemicalHyperGraph(che2)) == ChemicalHyperGraph([che1, che2])
@test merge(ChemicalHyperGraph(che1), ChemicalHyperGraph(che2), ChemicalHyperGraph(che2)) == ChemicalHyperGraph([che1, che2, che2])

# vertex-induced subhypergraph
x = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([2, 3, 4])])
@test nv(subhypergraph(x, 1)) == 3
@test subhypergraph(x, 2) == subhypergraph(x, [2]) == x
@test subhypergraph(x, 4) == subhypergraph(x, [4])
@test subhypergraph(x, vertices(x)) == x
chx = ChemicalHyperGraph([ChemicalHyperEdge(src, tgt) for (src, tgt) in zip([[1], [4]], [[1, 2, 3], [2, 3, 4]])])
@test nv(subhypergraph(chx, 1)) == 3
@test subhypergraph(chx, 2) == subhypergraph(chx, [2]) == chx
@test subhypergraph(chx, 4) == subhypergraph(chx, [4])
@test subhypergraph(chx, vertices(chx)) == chx

# hyperedge-induced subhypergraph
@test nhe(subhypergraph(x, hyperedges(x)[1])) == 1
@test nv(subhypergraph(x, HyperEdge([1, 2]), relaxed=true)) == 2
@test_throws ErrorException subhypergraph(x, HyperEdge([2, 3]), relaxed=true) # subhyperedge is not unique
@test subhypergraph(x, hyperedges(x)) == x
@test vertices(subhypergraph(x, [HyperEdge([1, 2]), HyperEdge([3, 4])], relaxed=true)) == vertices(x)
@test nhe(subhypergraph(chx, hyperedges(chx)[1])) == 1
@test nv(subhypergraph(chx, ChemicalHyperEdge([1], [2]), relaxed=true)) == 2
@test_throws ErrorException subhypergraph(chx, ChemicalHyperEdge(Int[], [2, 3]), relaxed=true) # subhyperedge is not unique
@test subhypergraph(chx, hyperedges(chx)) == chx
@test vertices(subhypergraph(chx, [ChemicalHyperEdge(Int[], [1, 2]), ChemicalHyperEdge(Int[], [3, 4])], relaxed=true)) == vertices(chx)

# hyperedge-induced subhypergraph with parallel hyperedges
e = HyperEdge([1, 2, 3])
parallel_x = HyperGraph([e, e])
@test subhypergraph(parallel_x, e) == parallel_x
che = ChemicalHyperEdge([1, 2], [3])
parallel_chx = ChemicalHyperGraph([che, che])
@test subhypergraph(parallel_chx, che) == parallel_chx

# edge switching
che = ChemicalHyperEdge([1, 2], [3], 5)
switched_che = switch(che)
@test src(che) == tgt(switched_che) && tgt(che) == src(switched_che)
@test weight(che) == weight(switched_che)
