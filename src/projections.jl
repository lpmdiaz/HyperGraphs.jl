function project(::Type{HyperEdge}, e::ChemicalHyperEdge{T}; f=identity) where {T}
    HyperEdge{T}(f(vertices(e)))
end

function project(::Type{HyperGraph}, x::ChemicalHyperGraph; f=identity)
    HyperGraph(project.(HyperEdge, hyperedges(x), f=f))
end

# dual of a hypergraph, given a labelling vector or setting one as a default
dual(x::HyperGraph, l::AbstractVector) = HyperGraph(l, BitMatrix(transpose(incidence_matrix(x))))
dual(x::HyperGraph) = dual(x, collect(1:nhe(x)))