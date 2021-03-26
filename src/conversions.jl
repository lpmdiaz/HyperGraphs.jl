function Base.convert(::Type{HyperEdge}, he::ChemicalHyperEdge{T}; skipcatalysts=false) where {T}
    v = skipcatalysts ? unique(vertices(he)) : vertices(he)
    HyperEdge{T}(v)
end

function Base.convert(::Type{HyperGraph}, hg::ChemicalHyperGraph; skipcatalysts=false)
    HyperGraph(convert.(HyperEdge, hyperedges(hg), skipcatalysts=skipcatalysts))
end
