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
