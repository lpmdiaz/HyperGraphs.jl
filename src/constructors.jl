# create a hyperedge from an incidence vector and a reference vertex list
HyperEdge(V::AbstractVector{T}, i::BitArray) where {T} = HyperEdge{T}(V[i])

# create a hypergraph from an incidence vector and a reference vertex list
HyperGraph(V::AbstractVector{T}, I::BitMatrix) where {T} = HyperGraph{T}(V, [HyperEdge(V, BitArray(i)) for i in eachcol(I)])