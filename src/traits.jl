# build unions of abstract types for easier dispatch
const AbstractStructs = Union{AbstractHyperGraph, AbstractHyperEdge}

# fundamental traits
@traitdef IsOriented{hg <: AbstractStructs}
@traitdef IsWeighted{hg <: AbstractStructs}

# functions and default behaviour: orientation
@traitimpl IsOriented{T} <- isoriented(T)
isoriented(::Type{T}) where {T} = false
isoriented(X::T) where {T} = isoriented(T)

# functions and default behaviour: weight
@traitimpl IsWeighted{T} <- isweighted(T)
isweighted(::Type{T}) where {T} = false
isweighted(X::T) where {T} = isweighted(T)

# build unions of types for easier dispatch
const OrientedStructs = Union{ChemicalHyperGraph, ChemicalHyperEdge}
const WeightedStructs = Union{ChemicalHyperGraph, ChemicalHyperEdge}

# implementing traits on types
@traitimpl IsOriented{OrientedStructs}
isoriented(::Type{T}) where {T<:OrientedStructs} = true
@traitimpl IsWeighted{WeightedStructs}
isweighted(::Type{T}) where {T<:WeightedStructs} = true
