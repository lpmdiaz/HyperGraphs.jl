## Boolean queries ##

# check the presence of vertex/vertices and hyperedge/hyperedges; unique is used to only check parallel hyperedges or repeated vertices of loops once
has_vertex(x::T, v) where {T<:AbstractHyperGraph} = v in vertices(x)
has_vertex(x::T, vs::AbstractVector) where {T<:AbstractHyperGraph} = [has_vertex(x, v) for v in unique(vs)]
has_vertices(x::T, vs::AbstractVector) where {T<:AbstractHyperGraph} = all(has_vertex(x, vs))
has_vertex(e::T, v) where {T<:AbstractHyperEdge} = v in vertices(e)
has_vertex(e::T, vs::AbstractVector) where {T<:AbstractHyperEdge} = [has_vertex(e, v) for v in unique(vs)]
has_vertices(e::T, vs::AbstractVector) where {T<:AbstractHyperEdge} = all(has_vertex(e, vs))
has_hyperedge(x::T, e::U) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge} = e in hyperedges(x)
has_hyperedge(x::T, es::AbstractVector{U}) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge} = [has_hyperedge(x, e) for e in unique(es)]
Base.in(e::T, x::U) where {T<:AbstractHyperEdge, U<:AbstractHyperGraph} = has_hyperedge(x, e)
has_hyperedges(x::T, es::AbstractVector{U}) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge} = all(has_hyperedge(x, es))
in_src(v, e::T) where {T<:AbstractHyperEdge} = v in src(e)
in_src(vs::AbstractVector, e::T) where {T<:AbstractHyperEdge} = [in_src(v, e) for v in unique(vs)]
in_tgt(v, e::T) where {T<:AbstractHyperEdge} = v in tgt(e)
in_tgt(vs::AbstractVector, e::T) where {T<:AbstractHyperEdge} = [in_tgt(v, e) for v in unique(vs)]

# check incidence -- hyperedge e is incident on vertex v; either order is correct
isincident(e::AbstractHyperEdge, v) = has_vertex(e, v)
isincident(v, e::AbstractHyperEdge) = isincident(e, v)

# Base.isempty
Base.isempty(e::T) where {T<:AbstractHyperEdge} = length(vertices(e)) == 0
"""
    Base.isempty

A hyergraph is empty if it has no hyperedges.
"""
Base.isempty(x::T) where {T<:AbstractHyperGraph} = nhe(x) == 0

# a simple hypergraph has no loops or multiple hyperedges
issimple(x::T) where {T<:AbstractHyperGraph} = !has_loops(x) && !has_multi_hyperedges(x)

# check if a hypergraph may be represented as a graph, that is if the cardinality of all hyperedges is 2
isgraph(x::T) where {T<:AbstractHyperGraph} = cardinalities(x) == fill(2, nhe(x))

# check that a hyperedge is a subhyperedge of another hyperedge
@traitfn issubhyperedge(e_sub::T, e_super::T) where {T<:AbstractHyperEdge; !IsOriented{T}} = all([isincident(e_super, v) for v in vertices(e_sub)]) # unoriented
@traitfn issubhyperedge(e_sub::T, e_super::T) where {T<:AbstractHyperEdge; IsOriented{T}} = all(in_src(src(e_sub), e_super)) && all(in_tgt(tgt(e_sub), e_super)) # oriented

# check that a hyperedge is a subhyperedge of at most one hyperedge of a hypergraph (any hyperedge is a subhyperedge of itself)
isuniquesubhyperedge(e_sub::T, x::U) where {T<:AbstractHyperEdge, U<:AbstractHyperGraph} = sum([issubhyperedge(e_sub, e_super) for e_super in hyperedges(x)]) == 1

# loops
"""
    isloop

A hyperedge is a loop if it has repeated vertices.
"""
isloop(e::T) where {T<:AbstractHyperEdge} = length(vertices(e)) != length(unique(vertices(e)))
"""
    is_positive_loop

An oriented hyperedge is a positive loop wrt. a vertex if that vertex is both in the source set and in the target set.
"""
function is_positive_loop end
@traitfn is_positive_loop(e::AbstractHyperEdge::IsOriented, v) = has_vertex(e, v) ? v in intersect(src(e), tgt(e)) : error("vertex $v not in hyperedge")
@traitfn is_positive_loop(e::AbstractHyperEdge::IsOriented) = any([v in intersect(src(e), tgt(e)) for v in vertices(e)])
@traitfn is_positive_loop(e::AbstractHyperEdge::IsOriented, v, k) = cardinality(e) == k && is_positive_loop(e, v)
has_loops(x::AbstractHyperGraph) = any(isloop.(hyperedges(x)))

# uniformity, regularity
"""
    iskuniform

A hypergraph is k-uniform if all hyperedges have cardinality k. Equivalently, a hypergraph is k-uniform if its rank is equal to its co-rank [Berge1989, Bretto2013]; checking this is however slower than the method currently implemented.
"""
iskuniform(x::T, k::Int) where {T<:AbstractHyperGraph} = sum(cardinalities(hyperedges(x)) .== k) == nhe(x)
"""
    iskregular

A hypergraph is k-regular all its vertices have degree k.
"""
iskregular(x::T, k::Int) where {T<:AbstractHyperGraph} = sum(degrees(x) .== k) == nv(x)

# chemical hypergraph & hyperedge queries
function is_netstoich_null(e::ChemicalHyperEdge, v)
    s = stoichiometries(e, v)
    (length(first(s)) == length(last(s))) && all(first(s) .- last(s) .== 0)
end
iscatalyst(x::ChemicalHyperGraph, v) = v in catalysts(x)
iscatalyst(e::ChemicalHyperEdge, v) = v in catalysts(e)

# parallel and multi-hyperedges
has_parallel_hyperedges(x::T) where {T<:AbstractHyperGraph} = num_parallel_hyperedges(x) > 0
has_multi_hyperedges(x::T) where {T<:AbstractHyperGraph} = num_multi_hyperedges(x) > 0

## content queries ##

# incident hyperedges
# returns all hyperedges incident on a given vertex
function incident_hyperedges(x::T, v; check_presence=true) where {T<:AbstractHyperGraph}
    check_presence && !has_vertex(x, v) && error("vertex $v not found in hypergraph vertices")
    filter(e -> isincident(e, v), hyperedges(x))
end
incident_hyperedges(x::T, vs::AbstractVector) where {T<:AbstractHyperGraph} = union(vcat([incident_hyperedges(x, v) for v in vs])...)

# empty hyperedges, hypergraphs
empty_hyperedges(x::T) where {T<:AbstractHyperGraph} = filter(e -> isempty(e), hyperedges(x))
num_empty_hyperedges(x::T) where {T<:AbstractHyperGraph} = length(empty_hyperedges(x))
has_empty_hyperedges(x::T) where {T<:AbstractHyperGraph} = num_empty_hyperedges(x) > 0

# neighbors
function neighbors(x::T, v) where {T<:AbstractHyperGraph} # unoriented

    # get vertices in incident hyperedges
    vs = vertices(incident_hyperedges(x, v))

    # take care of implicit multiset (to be specialised later)
    vloops = eltype(x)[]
    for _vs in vs
        sum(v .== _vs) > 1 && (push!(vloops, v))
    end

    union(vloops, vcat(symdiff.(vs, v))...)
end
@traitfn function inneighbors(x::T::IsOriented, v) where {T<:AbstractHyperGraph}

    # incident hyperedges where v is in the target set
    v_in_tgt = filter(e -> in_tgt(v, e), incident_hyperedges(x, v))

    union(vcat(src(v_in_tgt)...))
end
@traitfn function outneighbors(x::T::IsOriented, v) where {T<:AbstractHyperGraph}

    # incident hyperedges where v is in the source set
    v_in_src = filter(e -> in_src(v, e), incident_hyperedges(x, v))

    union(vcat(tgt(v_in_src)...))
end
@traitfn all_neighbors(x::T::(!IsOriented), v) where {T<:AbstractHyperGraph} = neighbors(x, v) # unoriented
@traitfn all_neighbors(x::T::IsOriented, v) where {T<:AbstractHyperGraph} = union(inneighbors(x, v), outneighbors(x, v)) # oriented

# loops
loops(es::AbstractVector{T}) where {T<:AbstractHyperEdge} = filter(e -> isloop(e), es)
loops(x::AbstractHyperGraph) = loops(hyperedges(x))
@traitfn positive_loops(es::AbstractVector{T}) where {T<:AbstractHyperEdge; IsOriented{T}} = filter(e -> is_positive_loop(e), es)
@traitfn positive_loops(x::AbstractHyperGraph::IsOriented) = positive_loops(hyperedges(x))
num_loops(x::AbstractHyperGraph) = length(loops(x))

# catalysts (chemical hypergraphs)
catalysts(e::ChemicalHyperEdge) = filter(v -> is_positive_loop(e, v) && is_netstoich_null(e, v), unique(vertices(e)))
catalysts(es::AbstractVector{ChemicalHyperEdge{T}}) where {T} = vcat(catalysts.(es)...)
catalysts(x::ChemicalHyperGraph) = vcat(catalysts(hyperedges(x))...)

# parallel and multi-hyperedges
"""
    parallel_hyperedges

There are parallel hyperedges in a hypergraph if any of its hyperedges is present more than once in the set of hyperedges."""
parallel_hyperedges(x::T) where {T<:AbstractHyperGraph} = filter(e -> sum(e == _e for _e in hyperedges(x)) > 1, hyperedges(x))
num_parallel_hyperedges(x::T) where {T<:AbstractHyperGraph} = length(parallel_hyperedges(x))
"""
    multi_hyperedges

There are multi-hyperedges in a hypergraph if any of its hyperedges is not a unique subedge i.e. there is at least another hyperedge of the same or greater length."""
multi_hyperedges(x::T) where {T<:AbstractHyperGraph} = filter(e -> !isuniquesubhyperedge(e, x), hyperedges(x))
num_multi_hyperedges(x::T) where {T<:AbstractHyperGraph} = length(multi_hyperedges(x))
