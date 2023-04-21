# create a hyperedge from an incidence vector and a reference vertex list
function HyperEdge(V::AbstractVector{T}, i::BitArray) where {T}
    @assert isequal(length(V), length(i))
    HyperEdge{T}(V[i])
end

# create a hypergraph from an incidence vector and a reference vertex list
function HyperGraph(V::AbstractVector{T}, I::BitMatrix) where {T}
    isequal(length(V), size(I)[1])
    HyperGraph{T}(V, [HyperEdge(V, BitArray(i)) for i in eachcol(I)])
end