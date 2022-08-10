module HyperGraphs

using SimpleTraits.SimpleTraits
using LinearAlgebra: Diagonal

include("core.jl")
include("conversions.jl")
include("matrices.jl")
include("operations.jl")
include("properties.jl")
include("queries.jl")
include("utils.jl")

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
weight, weights, # weighted hyperedges functions

# core: type functions
multiplicity,
species, stoich, src_stoich, tgt_stoich, inputs_stoich, outputs_stoich,
inputs, outputs, rate,

# matrices
degree_matrix, incidence_matrix, cardinality_matrix, weight_matrix,

# operations
add_vertex!, add_vertices!, del_vertex!, del_vertices!,
add_hyperedge!, add_hyperedges!, del_hyperedge!, del_hyperedges!, del_empty_hyperedges!,
replace_vertex!, replace_hyperedge!, replace_hyperedges!,
update_weight!, set_all_weights!,
merge,
subhypergraph,
switch,

# properties: vertices
degree, indegree, outdegree, degrees, indegrees, outdegrees,

# properties: hyperedges
length, cardinality, cardinalities, nsrcs, ntgts,

# properties: hypergraphs
nv, nhe, delta, Δ, rank, co_rank, order, hypergraph_size, volume,
degree_counts, cardinality_counts, degree_distribution, degree_sequence,

# queries: Boolean
has_vertex, has_vertices, has_hyperedge, has_hyperedges,
in_src, in_tgt,
isincident,
issimple, isgraph,
issubhyperedge, isuniquesubhyperedge,
isloop, is_positive_loop, has_loops,
iskuniform, iskregular,
is_netstoich_null, iscatalyst,
has_parallel_hyperedges, has_multi_hyperedges,

# queries: content
incident_hyperedges,
empty_hyperedges, num_empty_hyperedges, has_empty_hyperedges,
neighbors, inneighbors, outneighbors, all_neighbors,
loops, positive_loops, num_loops,
catalysts,
parallel_hyperedges, num_parallel_hyperedges,
multi_hyperedges, num_multi_hyperedges

end # module
