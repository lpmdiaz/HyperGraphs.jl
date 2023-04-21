function project(::Type{HyperEdge}, e::ChemicalHyperEdge{T}; f=identity) where {T}
    HyperEdge{T}(f(vertices(e)))
end

function project(::Type{HyperGraph}, x::ChemicalHyperGraph; f=identity)
    HyperGraph(project.(HyperEdge, hyperedges(x), f=f))
end