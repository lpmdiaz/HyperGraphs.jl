## Boolean queries ##

# check the presence of vertex/vertices and hyperedge/hyperedges; unique is used to only check parallel hyperedges or repeated vertices of loops once
has_vertex(hg::T, v) where {T<:AbstractHyperGraph} = v in vertices(hg)
has_vertex(hg::T, vs::AbstractVector) where {T<:AbstractHyperGraph} = [has_vertex(hg, v) for v in unique(vs)]
has_vertices(hg::T, vs::AbstractVector) where {T<:AbstractHyperGraph} = all(has_vertex(hg, vs))
has_vertex(he::T, v) where {T<:AbstractHyperEdge} = v in vertices(he)
has_vertex(he::T, vs::AbstractVector) where {T<:AbstractHyperEdge} = [has_vertex(he, v) for v in unique(vs)]
has_vertices(he::T, vs::AbstractVector) where {T<:AbstractHyperEdge} = all(has_vertex(he, vs))
has_hyperedge(hg::T, he::U) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge} = he in hyperedges(hg)
has_hyperedge(hg::T, hes::AbstractVector{U}) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge} = [has_hyperedge(hg, he) for he in unique(hes)]
Base.in(he::T, hg::U) where {T<:AbstractHyperEdge, U<:AbstractHyperGraph} = has_hyperedge(hg, he)
has_hyperedges(hg::T, hes::AbstractVector{U}) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge} = all(has_hyperedge(hg, hes))
in_src(v, he::T) where {T<:AbstractHyperEdge} = v in src(he)
in_src(vs::AbstractVector, he::T) where {T<:AbstractHyperEdge} = [in_src(v, he) for v in unique(vs)]
in_tgt(v, he::T) where {T<:AbstractHyperEdge} = v in tgt(he)
in_tgt(vs::AbstractVector, he::T) where {T<:AbstractHyperEdge} = [in_tgt(v, he) for v in unique(vs)]

# check incidence -- hyperedge he is incident on vertex v; either order is correct
isincident(he::AbstractHyperEdge, v) = has_vertex(he, v)
isincident(v, he::AbstractHyperEdge) = isincident(he, v)

# Base.isempty
Base.isempty(he::T) where {T<:AbstractHyperEdge} = length(vertices(he)) == 0
"""
    Base.isempty

A hyergraph is empty if it has no hyperedges.
"""
Base.isempty(hg::T) where {T<:AbstractHyperGraph} = nhe(hg) == 0

# check that a hyperedge is a subhyperedge of another hyperedge
@traitfn issubhyperedge(he_sub::T, he_super::T) where {T<:AbstractHyperEdge; !IsOriented{T}} = all([isincident(he_super, v) for v in vertices(he_sub)]) # unoriented
@traitfn issubhyperedge(he_sub::T, he_super::T) where {T<:AbstractHyperEdge; IsOriented{T}} = all(in_src(src(he_sub), he_super)) && all(in_tgt(tgt(he_sub), he_super)) # oriented

# check that a hyperedge is a subhyperedge of at most one hyperedge of a hypergraph (any hyperedge is a subhyperedge of itself)
isuniquesubhyperedge(he_sub::T, hg::U) where {T<:AbstractHyperEdge, U<:AbstractHyperGraph} = sum([issubhyperedge(he_sub, he_super) for he_super in hyperedges(hg)]) == 1

# loops
"""
    isloop

A hyperedge is a loop if it has repeated vertices.
"""
isloop(he::T) where {T<:AbstractHyperEdge} = length(vertices(he)) != length(unique(vertices(he)))
"""
    is_positive_loop

An oriented hyperedge is a positive loop wrt. a vertex if that vertex is both in the source set and in the target set.
"""
function is_positive_loop end
@traitfn is_positive_loop(he::AbstractHyperEdge::IsOriented, v) = has_vertex(he, v) ? v in intersect(src(he), tgt(he)) : error("vertex $v not in hyperedge")
@traitfn is_positive_loop(he::AbstractHyperEdge::IsOriented) = any([v in intersect(src(he), tgt(he)) for v in vertices(he)])
@traitfn is_positive_loop(he::AbstractHyperEdge::IsOriented, v, k) = cardinality(he) == k && is_positive_loop(he, v)
has_loops(hg::AbstractHyperGraph) = any(isloop.(hyperedges(hg)))

# uniformity, regularity
"""
    iskuniform

A hypergraph is k-uniform if all hyperedges have cardinality k.
"""
iskuniform(hg::T, k::Int) where {T<:AbstractHyperGraph} = sum(cardinalities(hyperedges(hg)) .== k) == nhe(hg)
"""
    iskregular

A hypergraph is k-regular all its vertices have degree k.
"""
iskregular(hg::T, k::Int) where {T<:AbstractHyperGraph} = sum(degrees(hg) .== k) == nv(hg)

# chemical hypergraph & hyperedge queries
function is_netstoich_null(che::ChemicalHyperEdge, v)
    s = stoichiometries(che, v)
    (length(first(s)) == length(last(s))) && all(first(s) .- last(s) .== 0)
end
iscatalyst(chg::ChemicalHyperGraph, v) = v in catalysts(chg)
iscatalyst(che::ChemicalHyperEdge, v) = v in catalysts(che)

# parallel and multi-hyperedges
has_parallel_hyperedges(hg::T) where {T<:AbstractHyperGraph} = num_parallel_hyperedges(hg) > 0
has_multi_hyperedges(hg::T) where {T<:AbstractHyperGraph} = num_multi_hyperedges(hg) > 0

## content queries ##

# empty hyperedges, hypergraphs
empty_hyperedges(hg::T) where {T<:AbstractHyperGraph} = filter(he -> isempty(he), hyperedges(hg))
num_empty_hyperedges(hg::T) where {T<:AbstractHyperGraph} = length(empty_hyperedges(hg))
has_empty_hyperedges(hg::T) where {T<:AbstractHyperGraph} = num_empty_hyperedges(hg) > 0

# neighbors
function neighbors(hg::T, v) where {T<:AbstractHyperGraph} # unoriented
    union(vcat(symdiff.(vertices(get_incident_hyperedges(hg, v)), v))...)
end
@traitfn function inneighbors(hg::T::IsOriented, v) where {T<:AbstractHyperGraph}

    # incident hyperedges where v is in the target set
    v_in_tgt = filter(he -> in_tgt(v, he), get_incident_hyperedges(hg, v))

    union(vcat(src(v_in_tgt)...))
end
@traitfn function outneighbors(hg::T::IsOriented, v) where {T<:AbstractHyperGraph}

    # incident hyperedges where v is in the source set
    v_in_src = filter(he -> in_src(v, he), get_incident_hyperedges(hg, v))

    union(vcat(tgt(v_in_src)...))
end
@traitfn all_neighbors(hg::T::(!IsOriented), v) where {T<:AbstractHyperGraph} = neighbors(hg, v) # unoriented
@traitfn all_neighbors(hg::T::IsOriented, v) where {T<:AbstractHyperGraph} = union(inneighbors(hg, v), outneighbors(hg, v)) # oriented

# loops
loops(hes::AbstractVector{T}) where {T<:AbstractHyperEdge} = filter(he -> isloop(he), hes)
loops(hg::AbstractHyperGraph) = loops(hyperedges(hg))
@traitfn positive_loops(hes::AbstractVector{T}) where {T<:AbstractHyperEdge; IsOriented{T}} = filter(he -> is_positive_loop(he), hes)
@traitfn positive_loops(hg::AbstractHyperGraph::IsOriented) = positive_loops(hyperedges(hg))
num_loops(hg::AbstractHyperGraph) = sum([length(loop) > 0 for loop in loops(hg)])

# catalysts (chemical hypergraphs)
catalysts(che::ChemicalHyperEdge) = filter(v -> is_positive_loop(che, v) && is_netstoich_null(che, v), unique(vertices(che)))
catalysts(ches::AbstractVector{ChemicalHyperEdge{T}}) where {T} = vcat(catalysts.(ches)...)
catalysts(chg::ChemicalHyperGraph) = vcat(catalysts(hyperedges(chg))...)

# parallel and multi-hyperedges
"""
    parallel_hyperedges

There are parallel hyperedges in a hypergraph if any of its hyperedges is present more than once in the set of hyperedges."""
parallel_hyperedges(hg::T) where {T<:AbstractHyperGraph} = filter(he -> sum(he == _he for _he in hyperedges(hg)) > 1, hyperedges(hg))
num_parallel_hyperedges(hg::T) where {T<:AbstractHyperGraph} = length(parallel_hyperedges(hg))
"""
    multi_hyperedges

There are multi-hyperedges in a hypergraph if any of its hyperedges is not a unique subedge i.e. there is at least another hyperedge of the same or greater length."""
multi_hyperedges(hg::T) where {T<:AbstractHyperGraph} = filter(he -> !isuniquesubhyperedge(he, hg), hyperedges(hg))
num_multi_hyperedges(hg::T) where {T<:AbstractHyperGraph} = length(multi_hyperedges(hg))
