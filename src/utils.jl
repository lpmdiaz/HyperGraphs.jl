# count how many times a vertex appears in a hyperedge, according to function f on that hyperedge
num_has_vertex(e::T, v; f::Function=vertices) where {T<:AbstractHyperEdge} = count(_v -> _v == v, f(e))
num_has_vertex(x::T, v; f::Function=vertices) where {T<:AbstractHyperGraph} = sum(vcat([HyperGraphs.num_has_vertex(e, v, f=f) for e in hyperedges(x)]...))

# create dictionaries to keep track of vertices order, mainly for getting the incidence matrix
vertices_to_indices(vs::AbstractVector) = Dict([(v => i) for (i, v) in enumerate(vs)])
vertices_to_indices(x::T) where {T<:AbstractHyperGraph} = vertices_to_indices(vertices(x))

# return the stoichiometries of vertex v in chemical hyperedge e
stoichiometries(e::ChemicalHyperEdge, v) = has_vertex(e, v) && (src_stoich(e)[findall(_v -> _v == v, src(e))], tgt_stoich(e)[findall( _v -> _v == v, tgt(e))])
