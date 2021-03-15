# count how many times a vertex appears in a hyperedge, according to function f on that hyperedge
num_has_vertex(he::T, v; f::Function=vertices) where {T<:AbstractHyperEdge} = count(_v -> _v == v, f(he))

# returns all hyperedges incident on a given vertex
function get_incident_hyperedges(hg::T, v; check_presence=true) where {T<:AbstractHyperGraph}
	check_presence && !has_vertex(hg, v) && error("vertex $v not found in hypergraph vertices")
	filter(he -> isincident(he, v), hyperedges(hg))
end
get_incident_hyperedges(hg::T, vs::AbstractVector) where {T<:AbstractHyperGraph} = union(vcat([get_incident_hyperedges(hg, v) for v in vs])...)

# create dictionaries to keep track of vertices order, mainly for getting the incidence matrix
vertices_to_indices(vs::AbstractVector) = Dict([(v => i) for (i, v) in enumerate(vs)])
vertices_to_indices(hg::T) where {T<:AbstractHyperGraph} = vertices_to_indices(vertices(hg))
