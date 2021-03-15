using HyperGraphs

## hyperedges and hypergraphs ##

# hyperedges: constructors
HyperEdge()
HyperEdge{Int8}()
HyperEdge([:a, :b])

# hyperedges: functions
vertices_he = [1, 2, 3]
he = HyperEdge(vertices_he)
@test vertices(he) == vertices_he
@test vertices(HyperEdge([1, :∅])) == [1, :∅]
vertices_hes = [[1, 2, 3], [2, 3, 4]]
hes = [HyperEdge(vertices_hes[1]), HyperEdge(vertices_hes[2])]
@test vertices(hes) == vertices_hes
@test eltype(he) == Int64
@test HyperEdge([1, 2, 3]) == he

# hypergraphs: constructors
HyperGraph()
HyperGraph{Int8}()
HyperGraph(HyperEdge([1, :∅]))
HyperGraph([HyperEdge([1, 1]), HyperEdge([2, 2])])
HyperGraph(HyperEdge([1, 1]))
@test HyperGraph([1], HyperEdge{Int}[]) == HyperGraph{Int}([1], HyperEdge[])
@test HyperGraph(1, HyperEdge([1, 1])) == HyperGraph([1], HyperEdge([1, 1])) == HyperGraph(1, [HyperEdge([1, 1])]) == HyperGraph([1], [HyperEdge([1, 1])])
@test HyperGraph(hes) == HyperGraph(unique(vcat(vertices_hes...)), hes)

# hypergraphs: functions
@test vertices(HyperGraph(HyperEdge([1, :∅]))) == [1, :∅]
hg = HyperGraph(hes)
@test vertices(hg) == unique(vcat(vertices_hes...)) == [1, 2, 3, 4]
@test vertices(hyperedges(hg)) == vertices_hes
@test hyperedges(hg) == hes
@test eltype(hg) == eltype(hyperedges(hg)[1])

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
vertices_chg = [1, 2, 3, 4]
chg = ChemicalHyperGraph(vertices_chg, ches)
@test vertices(chg) == vertices_chg
hyperedges(chg)
@test ChemicalHyperGraph(ches) == chg
@test eltype(chg) == eltype(hyperedges(chg)[1])
