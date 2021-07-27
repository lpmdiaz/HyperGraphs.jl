## vertices properties ##

"""
    degree

Degree of a given vertex in a given hypergraph. Also referred to as valency.

"""
function degree end

"""
    degrees

Degrees of several vertices in a given hypergraph.

"""
function degrees end

"""
    indegree

"""
function indegree end

"""
    indegrees

"""
function indegrees end

"""
    outdegree

"""
function outdegree end

"""
    outdegrees

"""
function outdegrees end

# internal function to deal with all cases
function _degree(x::T, v, f::Function) where {T<:AbstractHyperGraph}
    has_vertex(x, v) ? sum([num_has_vertex(e, v, f=f) for e in hyperedges(x)]) : error("vertex $v not found in hypergraph vertices")
end

# the degree of a vertex in a hypergraph
degree(x::T, v) where {T<:AbstractHyperGraph} = _degree(x, v, vertices)

# the in- and outdegree of a vertex in an oriented hypergraph
@traitfn indegree(x::T::IsOriented, v) where {T<:AbstractHyperGraph} = _degree(x, v, tgt)
@traitfn outdegree(x::T::IsOriented, v) where {T<:AbstractHyperGraph} = _degree(x, v, src)

# degree functions for vectors of vertices
degrees(x::T, vs::AbstractVector) where {T<:AbstractHyperGraph} = [degree(x, v) for v in vs]
@traitfn indegrees(x::T::IsOriented, vs::AbstractVector) where {T<:AbstractHyperGraph} = [indegree(x, v) for v in vs]
@traitfn outdegrees(x::T::IsOriented, vs::AbstractVector) where {T<:AbstractHyperGraph} = [outdegree(x, v) for v in vs]

# degree functions for hypergraphs
degrees(x::T) where {T<:AbstractHyperGraph} = degrees(x, vertices(x))
@traitfn indegrees(x::T::IsOriented) where {T<:AbstractHyperGraph} = indegrees(x, vertices(x))
@traitfn outdegrees(x::T::IsOriented) where {T<:AbstractHyperGraph} = outdegrees(x, vertices(x))

## hyperedges properties ##

# length, cardinality
Base.length(e::T) where {T<:AbstractHyperEdge} = length(vertices(e))
cardinality(e::T) where {T<:AbstractHyperEdge} = length(e)
cardinalities(es::AbstractVector{T}) where {T<:AbstractHyperEdge} = cardinality.(es)

# number of source and of target objects
@traitfn nsrcs(e::T::IsOriented) where {T<:AbstractHyperEdge} = length(objects(e.src))
@traitfn ntgts(e::T::IsOriented) where {T<:AbstractHyperEdge} = length(objects(e.tgt))

## hypergraphs properties ##

# number of vertices, of hyperedges
nv(x::T) where {T<:AbstractHyperGraph} = length(vertices(x))
nhe(x::T) where {T<:AbstractHyperGraph} = length(hyperedges(x))

# extending Base.size
Base.size(x::T) where {T<:AbstractHyperGraph} = (nv(x), nhe(x))

# rank and order of hypergraph
hypergraph_rank(x::T) where {T<:AbstractHyperGraph} = maximum(degrees(x))
order(x::T) where {T<:AbstractHyperGraph} = nv(x)

# size and volume of hypergraph
hypergraph_size(x::T) where {T<:AbstractHyperGraph} = sum(cardinalities(hyperedges(x)))
volume(x::T, vs::AbstractVector) where {T<:AbstractHyperGraph} = has_vertices(x, vs) ? sum(degrees(x, vs)) : error("vertices not in hypergraph")
