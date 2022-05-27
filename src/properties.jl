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
    !has_vertex(x, v) && error("vertex $v not found in hypergraph vertices")
    sum([num_has_vertex(e, v, f=f) * weight(e) for e in hyperedges(x)])
end

# the degree of a vertex in a hypergraph
function degree(x::T, v) where {T<:AbstractHyperGraph}
    _degree(x, v, vertices)
end

# the in- and outdegree of a vertex in an oriented hypergraph
@traitfn function indegree(x::T::IsOriented, v) where {T<:AbstractHyperGraph}
    _degree(x, v, tgt)
end
@traitfn function outdegree(x::T::IsOriented, v) where {T<:AbstractHyperGraph}
    _degree(x, v, src)
end

# degree functions for vectors of vertices
function degrees(x::T, vs::AbstractVector) where {T<:AbstractHyperGraph}
    [degree(x, v) for v in vs]
end
@traitfn function indegrees(x::T::IsOriented, vs::AbstractVector) where {T<:AbstractHyperGraph}
    [indegree(x, v) for v in vs]
end
@traitfn function outdegrees(x::T::IsOriented, vs::AbstractVector) where {T<:AbstractHyperGraph}
    [outdegree(x, v) for v in vs]
end

# degree functions for hypergraphs
function degrees(x::T) where {T<:AbstractHyperGraph}
    degrees(x, vertices(x))
end
@traitfn function indegrees(x::T::IsOriented) where {T<:AbstractHyperGraph}
    indegrees(x, vertices(x))
end
@traitfn function outdegrees(x::T::IsOriented) where {T<:AbstractHyperGraph}
    outdegrees(x, vertices(x))
end

## hyperedges properties ##

# length, cardinality
Base.length(e::T) where {T<:AbstractHyperEdge} = length(vertices(e))
"""
    cardinality(e)

Cardinality of edge `e`, defined as its number of endpoints.
"""
cardinality(e::T) where {T<:AbstractHyperEdge} = length(e)
cardinalities(es::AbstractVector{T}) where {T<:AbstractHyperEdge} = cardinality.(es)
cardinalities(x::T) where {T<:AbstractHyperGraph} = cardinalities(hyperedges(x))

# number of source and of target objects
@traitfn nsrcs(e::T::IsOriented) where {T<:AbstractHyperEdge} = length(objects(e.src))
@traitfn ntgts(e::T::IsOriented) where {T<:AbstractHyperEdge} = length(objects(e.tgt))

## hypergraphs properties ##

# number of vertices, of hyperedges
nv(x::T) where {T<:AbstractHyperGraph} = length(vertices(x))
nhe(x::T) where {T<:AbstractHyperGraph} = length(hyperedges(x))

# extending Base.size
Base.size(x::T) where {T<:AbstractHyperGraph} = (nv(x), nhe(x))

# maximum degree of a hypergraph
"""
    delta(x)

The maximum degree delta or Δ of a hypergraph `x` is the maximum degree over its vertices [Berge1989, Hellmuth2012].
"""
delta(x::T) where {T<:AbstractHyperGraph} = maximum(degrees(x))
Δ(x::T) where {T<:AbstractHyperGraph} = delta(x)

# rank, co-rank, and order of hypergraph
"""
    rank(x)

Rank of hypergraph `x`, defined as the maximum cardinality over its hyperedges [Berge1989, Hellmuth2012, Bretto2013, Burgio2020].
"""
rank(x::T) where {T<:AbstractHyperGraph} = maximum(cardinalities(x))
"""
    co_rank(x)

Co-rank of hypergraph `x`, defined as the minimum cardinality over its hyperedges [Hellmuth2012, Bretto2013, Burgio2020]. Sometimes referred to as anti-rank, e.g. in [Berge1989].
"""
co_rank(x::T) where {T<:AbstractHyperGraph} = minimum(cardinalities(x))
order(x::T) where {T<:AbstractHyperGraph} = nv(x)

# size and volume of hypergraph
hypergraph_size(x::T) where {T<:AbstractHyperGraph} = sum(cardinalities(hyperedges(x)))
volume(x::T) where {T<:AbstractHyperGraph} = sum(degrees(x))

# degree & cardinality counts
function degree_counts(x::T) where {T<:AbstractHyperGraph}
    [sum(degrees(x) .== d) for d in HyperGraphs.degree_bins(x)]
end
function cardinality_counts(x::T) where {T<:AbstractHyperGraph}
    [sum(cardinalities(x) .== c) for c in HyperGraphs.cardinality_bins(x)]
end

# degree distribution
degree_distribution(x::T) where {T<:AbstractHyperGraph} = degree_counts(x) ./ nv(x)

# degree sequence
degree_sequence(x::T) where {T<:AbstractHyperGraph} = sort(degrees(x), rev=true)
function degree_sequence(degree_counts::AbstractVector{Int}; degrees=0:length(degree_counts))
    seq = vcat([repeat([degree], degree_count) for (degree, degree_count) in zip(degrees, degree_counts)]...)
    sort(seq, rev=true)
end
