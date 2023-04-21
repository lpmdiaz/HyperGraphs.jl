using HyperGraphs

## hyperedges and hypergraphs ##

# hyperedges: constructors
HyperEdge()
HyperEdge{Int8}()
HyperEdge([:a, :b])
V = collect(1:4) # vertex set
i = [1; 2; 0; 1] .!= 0
HyperEdge(V, i)
HyperEdge(["1", "2", "3", "4"], BitArray([1, 1, 0, 1]))
@test isequal(HyperEdge(["1", "2", "3", "4"], BitArray([1; 1; 0; 1])), HyperEdge(["1", "2", "4"]))

# hyperedges: functions
vertices_e = [1, 2, 3]
e = HyperEdge(vertices_e)
@test vertices(e) == vertices_e
@test vertices(HyperEdge([1, :∅])) == [1, :∅]
vertices_es = [[1, 2, 3], [2, 3, 4]]
es = [HyperEdge(vertices_es[1]), HyperEdge(vertices_es[2])]
@test vertices(es) == vertices_es
@test eltype(e) == Int64
@test HyperEdge([1, 2, 3]) == e

# hypergraphs: constructors
HyperGraph()
HyperGraph{Int8}()
HyperGraph(HyperEdge([1, :∅]))
HyperGraph([HyperEdge([1, 1]), HyperEdge([2, 2])])
HyperGraph(HyperEdge([1, 1]))
@test HyperGraph([1], HyperEdge{Int}[]) == HyperGraph{Int}([1], HyperEdge[])
@test HyperGraph(1, HyperEdge([1, 1])) == HyperGraph([1], HyperEdge([1, 1])) == HyperGraph(1, [HyperEdge([1, 1])]) == HyperGraph([1], [HyperEdge([1, 1])])
@test HyperGraph(es) == HyperGraph(unique(vcat(vertices_es...)), es)
I = BitMatrix(hcat(i, i) .!= 0)
HyperGraph(V, I)
HyperGraph(["1", "2", "3", "4"], BitArray([1 0; 1 1; 0 1; 1 1]))
@test isequal(hyperedges(HyperGraph(["1", "2", "3", "4"], BitArray([1 0; 1 0; 0 1; 1 1]))), [HyperEdge(["1", "2", "4"]), HyperEdge(["3", "4"])])

# hypergraphs: functions
@test vertices(HyperGraph(HyperEdge([1, :∅]))) == [1, :∅]
x = HyperGraph(es)
@test vertices(x) == unique(vcat(vertices_es...)) == [1, 2, 3, 4]
@test vertices(hyperedges(x)) == vertices_es
@test hyperedges(x) == es
@test eltype(x) == eltype(hyperedges(x)[1])

## chemical hyperedges and chemical hypergraphs ##

# incidence: constructors
SpeciesSet{Symbol}()
SpeciesSet()
@test SpeciesSet([1]) == SpeciesSet(1)
@test SpeciesSet(["X"]) == SpeciesSet("X") == SpeciesSet("X", 1) == SpeciesSet(["X"], [1])

# incidence: functions
s = SpeciesSet(:∅)
@test objects(s) == [:∅]
@test multiplicities(s) == [1]
@test multiplicities(SpeciesSet([1, 2, 3], [1, 1, 2])) == [1, 1, 2]
@test_throws MethodError SpeciesSet(["X"], [1.2]) # stoichiometries are defined on integers
@test species(s) == [:∅]
@test stoich(s) == [1]
@test length(s) == 1

# chemical hyperedges: constructors
ChemicalHyperEdge{String}()
ChemicalHyperEdge()
ChemicalHyperEdge(["X", "Y"], ["Z"], 2)
ChemicalHyperEdge(["X", "Y"], ["Z"], [[[2]]]) # is this undesirable?
ChemicalHyperEdge(["X"], ["Y"])
@test ChemicalHyperEdge(["X"], ["Y"], 1) == ChemicalHyperEdge(["X"], ["Y"]) # rate defaults to 1

# chemical hyperedges: functions
reactant = SpeciesSet(["X"])
product = SpeciesSet(["Y"], [2])
che = ChemicalHyperEdge(reactant, product)
@test src(che) == objects(reactant)
@test tgt(che) == objects(product)
@test vertices(che) == ["X", "Y"]
@test src(ChemicalHyperEdge(["X", "Y"], ["Z"])) == ["X", "Y"]
@test src_multiplicities(che) == [1]
@test tgt_multiplicities(che) == [2]
@test weight(ChemicalHyperEdge()) == 1
e = ChemicalHyperEdge([], [], 6)
@test weight(e) == 6
x = ChemicalHyperGraph([e, e])
@test weights(hyperedges(x)) == weights(x) == [6, 6]
srcs = [[1], [4]]; tgts = [[1, 2, 3], [2, 3, 4]]
ches = [ChemicalHyperEdge(src, tgt) for (src, tgt) in zip(srcs, tgts)]
@test src(ches) == srcs
@test tgt(ches) == tgts
@test vertices(ches) == [[1, 1, 2, 3], [4, 2, 3, 4]]
@test eltype(reactant) == eltype(che) == String
@test src_stoich(che) == inputs_stoich(che) == [1]
@test tgt_stoich(che) == outputs_stoich(che) == [2]

# chemical hypergraphs: constructors
ChemicalHyperGraph{String}()
ChemicalHyperGraph()

# chemical hypergraphs: functions
vertices_chx = [1, 2, 3, 4]
chx = ChemicalHyperGraph(vertices_chx, ches)
@test vertices(chx) == vertices_chx
hyperedges(chx)
@test ChemicalHyperGraph(ches) == chx
@test eltype(chx) == eltype(hyperedges(chx)[1])

## defaults ##

e = HyperEdge(collect(1:10))
@test !isweighted(e) && e.weight == 1
@test_throws ErrorException e.weight = 2
@test getproperty(e, :weight) === e.weight === weight(e)
