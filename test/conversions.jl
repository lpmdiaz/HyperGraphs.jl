using HyperGraphs

convert(HyperEdge, ChemicalHyperEdge([1], [1]))
convert(HyperEdge, ChemicalHyperEdge([1], [1]), skipcatalysts=true)
convert.(HyperEdge, [ChemicalHyperEdge([1], [1]), ChemicalHyperEdge([2], [2])])
convert(HyperGraph, ChemicalHyperGraph([ChemicalHyperEdge([1], [1]), ChemicalHyperEdge([2], [2])]))
