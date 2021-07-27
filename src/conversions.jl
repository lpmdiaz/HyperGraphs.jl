function Base.convert(::Type{HyperEdge}, e::ChemicalHyperEdge{T}; skipcatalysts=false) where {T}
    v = skipcatalysts ? unique(vertices(e)) : vertices(e)
    HyperEdge{T}(v)
end

function Base.convert(::Type{HyperGraph}, x::ChemicalHyperGraph; skipcatalysts=false)
    HyperGraph(convert.(HyperEdge, hyperedges(x), skipcatalysts=skipcatalysts))
end
