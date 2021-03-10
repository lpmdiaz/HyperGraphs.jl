module HyperGraphs

using SimpleTraits.SimpleTraits

include("core.jl")

export

# core: types
AbstractHyperGraph, AbstractHyperEdge,
HyperEdge, HyperGraph,
SpeciesSet, ChemicalHyperEdge, ChemicalHyperGraph,

# core: traits
OrientedStructs, WeightedStructs, # constants holding type unions
IsOriented, IsWeighted, # traits
isoriented, isweighted, # trait functions

# core: functions
objects, multiplicities, # incidence functions
vertices, hyperedges, # hyperedges and hypergraphs functions
src, tgt, src_multiplicities, tgt_multiplicities, # oriented hyperedges functions
weight # weighted hyperedges functions

end # module
