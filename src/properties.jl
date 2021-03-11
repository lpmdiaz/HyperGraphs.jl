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
function _degree(hg::T, v, f::Function) where {T<:AbstractHyperGraph}
	has_vertex(hg, v) ? sum([num_has_vertex(he, v, f=f) for he in hyperedges(hg)]) : error("vertex $v not found in hypergraph vertices")
end

# the degree of a vertex in a hypergraph
degree(hg::T, v) where {T<:AbstractHyperGraph} = _degree(hg, v, vertices)

# the in- and outdegree of a vertex in an oriented hypergraph
@traitfn indegree(hg::T::IsOriented, v) where {T<:AbstractHyperGraph} = _degree(hg, v, tgt)
@traitfn outdegree(hg::T::IsOriented, v) where {T<:AbstractHyperGraph} = _degree(hg, v, src)

# degree functions for vectors of vertices
degrees(hg::T, vs::AbstractVector) where {T<:AbstractHyperGraph} = [degree(hg, v) for v in vs]
@traitfn indegrees(hg::T::IsOriented, vs::AbstractVector) where {T<:AbstractHyperGraph} = [indegree(hg, v) for v in vs]
@traitfn outdegrees(hg::T::IsOriented, vs::AbstractVector) where {T<:AbstractHyperGraph} = [outdegree(hg, v) for v in vs]

# degree functions for hypergraphs
degrees(hg::T) where {T<:AbstractHyperGraph} = degree(hg, vertices(hg))
@traitfn indegrees(hg::T::IsOriented) where {T<:AbstractHyperGraph} = indegree(hg, vertices(hg))
@traitfn outdegrees(hg::T::IsOriented) where {T<:AbstractHyperGraph} = outdegree(hg, vertices(hg))

## hyperedges properties ##

# length, cardinality
Base.length(he::T) where {T<:AbstractHyperEdge} = length(vertices(he))
cardinality(he::T) where {T<:AbstractHyperEdge} = length(he)
cardinalities(hes::AbstractVector{T}) where {T<:AbstractHyperEdge} = cardinality.(hes)

## hypergraphs properties ##

# number of vertices, of hyperedges
nv(hg::T) where {T<:AbstractHyperGraph} = length(vertices(hg))
nhe(hg::T) where {T<:AbstractHyperGraph} = length(hyperedges(hg))

# extending Base.size
Base.size(hg::T) where {T<:AbstractHyperGraph} = (nv(hg), nhe(hg))

# rank and order of hypergraph
rank(hg::T) where {T<:AbstractHyperGraph} = maximum(degrees(hg))
order(hg::T) where {T<:AbstractHyperGraph} = nv(hg)

# size and volume of hypergraph
hypergraph_size(hg::T) where {T<:AbstractHyperGraph} = sum(cardinalities(hyperedges(hg)))
volume(hg::T, vs::AbstractVector) where {T<:AbstractHyperGraph} = has_vertices(hg, vs) ? sum(degree(hg, vs)) : error("vertices not in hypergraph")
