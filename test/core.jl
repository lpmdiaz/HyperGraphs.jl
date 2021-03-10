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

# hypergraphs: constructors
HyperGraph()
HyperGraph{Int8}()
HyperGraph(HyperEdge([1, :∅]))
HyperGraph([HyperEdge([1, 1]), HyperEdge([2, 2])])
HyperGraph(HyperEdge([1, 1]))

# hypergraphs: functions
@test vertices(HyperGraph(HyperEdge([1, :∅]))) == [1, :∅]
hg = HyperGraph(vertices_he, hes)
@test vertices(hg) == vertices_he
@test hyperedges(hg) == hes

## chemical hyperedges and chemical hypergraphs ##

# incidence: constructors
SpeciesSet{Symbol}()
SpeciesSet()

# incidence: functions
s = SpeciesSet(:∅)
@test objects(s) == [:∅]
@test multiplicities(s) == [1]
@test multiplicities(SpeciesSet([1, 2, 3], [1, 1, 2])) == [1, 1, 2]
@test_throws MethodError SpeciesSet(["X"], [1.2]) # stoichiometries are defined on integers

# chemical hyperedges: constructors
ChemicalHyperEdge{String}()
ChemicalHyperEdge()
ChemicalHyperEdge(["X", "Y"], ["Z"], 2)
ChemicalHyperEdge(["X", "Y"], ["Z"], [[[2]]]) # is this undesirable?
ChemicalHyperEdge(["X"], ["Y"])

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

# chemical hypergraphs: constructors
ChemicalHyperGraph{String}()
ChemicalHyperGraph()

# chemical hypergraphs: functions
vertices_chg = [1, 2, 3, 4]
chg = ChemicalHyperGraph(vertices_chg, ches)
@test vertices(chg) == vertices_chg
hyperedges(chg)
