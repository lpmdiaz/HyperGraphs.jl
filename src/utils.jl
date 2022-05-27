# count how many times a vertex appears in a hyperedge, according to function f on that hyperedge
num_has_vertex(e::T, v; f::Function=vertices) where {T<:AbstractHyperEdge} = count(_v -> _v == v, f(e))
num_has_vertex(x::T, v; f::Function=vertices) where {T<:AbstractHyperGraph} = sum(vcat([HyperGraphs.num_has_vertex(e, v, f=f) for e in hyperedges(x)]...))

# create dictionaries to keep track of vertices order, mainly for getting the incidence matrix
vertices_to_indices(vs::AbstractVector) = Dict([(v => i) for (i, v) in enumerate(vs)])
vertices_to_indices(x::T) where {T<:AbstractHyperGraph} = vertices_to_indices(vertices(x))

# return the stoichiometries of vertex v in chemical hyperedge e
stoichiometries(e::ChemicalHyperEdge, v) = has_vertex(e, v) && (src_stoich(e)[findall(_v -> _v == v, src(e))], tgt_stoich(e)[findall( _v -> _v == v, tgt(e))])

# retrieve the hyperedge type of a concrete type of AbstractHyperGraph
# might want to check that the returned value isa AbstractHyperEdge
function get_hyperedge_type(t::Type{T}) where {T<:AbstractHyperGraph}
    idx = findall(field -> field == :E, fieldnames(T))
    !(isempty(idx)) ? e_field = fieldtypes(T)[idx[1]] : error("could not find edge field")
    if isa(t, DataType)         # T is typed
        e_field.parameters[1].name.wrapper
    elseif isa(t, UnionAll)     # T isn’t typed
        e_field.body.parameters[1].name.wrapper
    end
end

# get degree bins (0 to maximum degree) for a given hypergraph
@traitfn degree_bins(x::T::(!IsWeighted)) where {T<:AbstractHyperGraph} = 0:1:Δ(x)

# get cardinality bins (0 to maximum cardinality) for a given hypergraph
cardinality_bins(x::T) where {T<:AbstractHyperGraph} = 0:1:rank(x)
