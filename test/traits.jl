using HyperGraphs, SimpleTraits

# making sure types are correctly traited
@test istrait(IsOriented{ChemicalHyperGraph})
@test istrait(IsOriented{ChemicalHyperEdge})
@test !istrait(IsOriented{HyperGraph})
@test !istrait(IsOriented{HyperEdge})
@test istrait(IsWeighted{ChemicalHyperGraph})
@test istrait(IsWeighted{ChemicalHyperEdge})
@test !istrait(IsWeighted{HyperGraph})
@test !istrait(IsWeighted{HyperEdge})

## trait functions ##

# chemical hypergraphs and hyperedges are oriented and weighted
@test isoriented(ChemicalHyperGraph()) && isoriented(ChemicalHyperGraph)
@test isoriented(ChemicalHyperEdge()) && isoriented(ChemicalHyperEdge)
@test isweighted(ChemicalHyperGraph()) && isoriented(ChemicalHyperGraph)
@test isweighted(ChemicalHyperEdge()) && isoriented(ChemicalHyperEdge)

# hypergraphs and hyperedges are unoriented and unweighted
@test !isoriented(HyperGraph()) && !isoriented(HyperGraph)
@test !isoriented(HyperEdge()) && !isoriented(HyperEdge)
@test !isweighted(HyperGraph()) && !isoriented(HyperGraph)
@test !isweighted(HyperEdge()) && !isoriented(HyperEdge)

## edge cases ##

# other types and object should not be traited
@test !isoriented(String) && !isoriented(3)
@test !isweighted(String) && !isweighted(3)
@test_throws TypeError istrait(IsOriented{Int})
