# count how many times a vertex appears in a hyperedge, according to function f on that hyperedge
num_has_vertex(he::T, v; f::Function=vertices) where {T<:AbstractHyperEdge} = count(_v -> _v == v, f(he))
