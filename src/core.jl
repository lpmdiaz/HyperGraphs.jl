## abstract types ##

"""
    AbstractHyperGraph

Abstract type that is the supertype of all hypergraph types.
"""
abstract type AbstractHyperGraph end

"""
    AbstractHyperEdge

Abstract type that is the supertype of all hyperedge types.
"""
abstract type AbstractHyperEdge end

abstract type AbstractIncidenceSet end

## concrete types ##

"""
    HyperEdge{T}

A type that represents unoriented, unweighted hyperedges. There are no restrictions to the structure; self-edges are allowed, and the hyperedge may be empty.

# Fields
- `V`: a set of vertices
"""
mutable struct HyperEdge{T} <: AbstractHyperEdge
    V::AbstractVector{T}
end
HyperEdge(v::T) where {T} = HyperEdge{T}([v])
HyperEdge{T}() where {T} = HyperEdge{T}([])
HyperEdge() = HyperEdge{Any}([])
Base.:(==)(e1::HyperEdge, e2::HyperEdge) = isequal(vertices(e1), vertices(e2))
Base.eltype(::HyperEdge{T}) where {T} = T

"""
    HyperGraph{T}

A type that represents unoriented, unweighted hypergraphs.

# Fields
- `V`: a set of vertices
- `E`: a set of hyperedges
"""
mutable struct HyperGraph{T} <: AbstractHyperGraph
    V::AbstractVector{T}
    E::AbstractVector{HyperEdge{T}}
end
HyperGraph(v::T, es::AbstractVector{HyperEdge{T}}) where {T} = HyperGraph{T}([v], es)
HyperGraph(vs::AbstractVector{T}, e::HyperEdge{T}) where {T} = HyperGraph{T}(vs, [e])
HyperGraph(v::T, e::HyperEdge{T}) where {T} = HyperGraph{T}([v], [e])
HyperGraph(es::AbstractVector{HyperEdge{T}}) where {T} = HyperGraph(union(vertices(es)...), es)
HyperGraph(e::HyperEdge{T}) where {T} = HyperGraph(union(vertices(e)), e)
HyperGraph{T}() where {T} = HyperGraph{T}([], [])
HyperGraph() = HyperGraph{Any}([], [])
(::Type{HyperGraph{T}})(e::HyperEdge{T}) where {T} = HyperGraph(e)
(::Type{HyperGraph{T}})(es::AbstractVector{HyperEdge{T}}) where {T} = HyperGraph(es)
Base.:(==)(x1::HyperGraph, x2::HyperGraph) = isequal(vertices(x1), vertices(x2)) && isequal(hyperedges(x1), hyperedges(x2))

Base.eltype(::HyperGraph{T}) where {T} = T

"""
    SpeciesSet{T}

A type that represents an incidence structure, that is a set of objects and their associated multiplicities, in the context of chemical reactions (where objects are chemical species and multiplicities are stoichiometries).

# Fields
- `objs`: a set of chemical species
- `mults`: a set of stoichiometries

# Notes
- multiplicities are restricted to integers
- if no stoichiometry is given, defaults to 1 for convenience
"""
mutable struct SpeciesSet{T} <: AbstractIncidenceSet
    objs::AbstractVector{T}
    mults::AbstractVector{Int}
    function SpeciesSet{T}(objs::AbstractVector{T}, mults::AbstractVector{Int}) where {T}
        (length(objs) == length(mults)) ? new{T}(objs, mults) : error("species and stoichiometry vectors must have the same length")
    end
end
SpeciesSet(species::AbstractVector{T}, stoich::AbstractVector{Int}) where {T} = SpeciesSet{T}(species, stoich)
SpeciesSet(species::T, stoich::Int) where {T} = SpeciesSet{T}([species], [stoich])
SpeciesSet(species::AbstractVector{T}) where {T} = SpeciesSet{T}(species, ones(Int, length(species)))
SpeciesSet(species::T) where {T} = SpeciesSet([species])
SpeciesSet{T}() where {T} = SpeciesSet{T}(T[], Int[])
SpeciesSet() = SpeciesSet{Any}()
species(S::SpeciesSet) = objects(S)
stoich(S::SpeciesSet) = multiplicities(S)
Base.:(==)(s1::SpeciesSet, s2::SpeciesSet) = isequal(species(s1), species(s2)) && isequal(stoich(s1), stoich(s2))
Base.eltype(::SpeciesSet{T}) where {T} = T
Base.length(S::SpeciesSet) = length(species(S))

"""
    ChemicalHyperEdge{T}

A type that represents a chemical hyperedge, that is an oriented, weighted hyperedge, in the context of chemical reactions (where the weight is the reaction rate).

# Fields
- `src`: a set of input species (negatively oriented)
- `tgt`: a set of output species (positively oriented)
- `weight`: reaction rate

# Notes
- if no rate is given, defaults to 1 for convenience
"""
mutable struct ChemicalHyperEdge{T} <: AbstractHyperEdge
    src::SpeciesSet{T}
    tgt::SpeciesSet{T}
    weight
end
ChemicalHyperEdge(inputs::SpeciesSet{T}, outputs::SpeciesSet{T}) where {T} = ChemicalHyperEdge{T}(inputs, outputs, one(Int))
ChemicalHyperEdge(inputs::AbstractVector{T}, outputs::AbstractVector{T}, rate) where {T} = ChemicalHyperEdge(SpeciesSet(inputs), SpeciesSet(outputs), rate)
ChemicalHyperEdge(inputs::AbstractVector{T}, outputs::AbstractVector{T}) where {T} = ChemicalHyperEdge(SpeciesSet(inputs), SpeciesSet(outputs))
ChemicalHyperEdge(inputs::AbstractVector{T}, outputs::SpeciesSet{T}) where {T} = ChemicalHyperEdge(SpeciesSet(inputs), outputs)
ChemicalHyperEdge(inputs::SpeciesSet{T}, outputs::AbstractVector{T}) where {T} = ChemicalHyperEdge(inputs, SpeciesSet(outputs))
ChemicalHyperEdge{T}() where {T} = ChemicalHyperEdge{T}(SpeciesSet{T}(), SpeciesSet{T}(), one(Int))
ChemicalHyperEdge() = ChemicalHyperEdge{Any}()
(::Type{ChemicalHyperEdge{T}})(inputs, outputs) where {T} = ChemicalHyperEdge(inputs, outputs)
inputs(e::ChemicalHyperEdge) = src(e)
outputs(e::ChemicalHyperEdge) = tgt(e)
rate(e::ChemicalHyperEdge) = weight(e)
src_stoich(e::ChemicalHyperEdge) = src_multiplicities(e)
tgt_stoich(e::ChemicalHyperEdge) = tgt_multiplicities(e)
inputs_stoich(e::ChemicalHyperEdge) = src_stoich(e)
outputs_stoich(e::ChemicalHyperEdge) = tgt_stoich(e)
Base.:(==)(e1::ChemicalHyperEdge, e2::ChemicalHyperEdge) = isequal(inputs(e1), inputs(e2)) && isequal(outputs(e1), outputs(e2)) && isequal(rate(e1), rate(e2))
Base.eltype(::ChemicalHyperEdge{T}) where {T} = T

"""
    ChemicalHyperGraph{T}

A type that represents oriented, weighted hypergraphs, in the context of chemical reactions.

# Fields
- `V`: a set of vertices
- `E`: a set of chemical hyperedges
"""
mutable struct ChemicalHyperGraph{T} <: AbstractHyperGraph
    V::AbstractVector{T}
    E::AbstractVector{ChemicalHyperEdge{T}}
end
ChemicalHyperGraph(vs::AbstractVector{T}, e::ChemicalHyperEdge{T}) where {T} = ChemicalHyperGraph{T}(vs, [e])
ChemicalHyperGraph(e::ChemicalHyperEdge{T}) where {T} = ChemicalHyperGraph{T}(union(vertices(e)), [e])
ChemicalHyperGraph(es::AbstractVector{ChemicalHyperEdge{T}}) where {T} = ChemicalHyperGraph(union(vertices(es)...), es)
(::Type{ChemicalHyperGraph{T}})(e::ChemicalHyperEdge{T}) where {T} = ChemicalHyperGraph(e)
(::Type{ChemicalHyperGraph{T}})(es::AbstractVector{ChemicalHyperEdge{T}}) where {T} = ChemicalHyperGraph(es)
ChemicalHyperGraph{T}() where {T} = ChemicalHyperGraph{T}([], [])
ChemicalHyperGraph() = ChemicalHyperGraph{Any}([], [])
Base.:(==)(x1::ChemicalHyperGraph, x2::ChemicalHyperGraph) = isequal(vertices(x1), vertices(x2)) && isequal(hyperedges(x1), hyperedges(x2))
Base.eltype(::ChemicalHyperGraph{T}) where {T} = T

## traits ##

# build unions of abstract types for easier dispatch
const AbstractStructs = Union{AbstractHyperGraph, AbstractHyperEdge}

# fundamental traits
@traitdef IsOriented{X <: AbstractStructs}
@traitdef IsWeighted{X <: AbstractStructs}

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

## core functions ##

# objects and multiplicities of incidence structures
objects(i::T) where {T<:AbstractIncidenceSet} = i.objs
multiplicities(i::T) where {T<:AbstractIncidenceSet} = i.mults

# vertices of hyperedges, of hypergraphs
@traitfn vertices(e::T::(!IsOriented)) where {T<:AbstractHyperEdge} = e.V
@traitfn vertices(e::T::IsOriented) where {T<:AbstractHyperEdge} = vcat(src(e), tgt(e))
vertices(es::AbstractVector{T}) where {T<:AbstractHyperEdge} = vertices.(es)
vertices(x::T) where {T<:AbstractHyperGraph} = x.V

# hyperedges of hypergraphs
hyperedges(x::T) where {T<:AbstractHyperGraph} = x.E

# source and target of oriented hyperedges
@traitfn src(e::T::IsOriented) where {T<:AbstractHyperEdge} = objects(e.src)
@traitfn tgt(e::T::IsOriented) where {T<:AbstractHyperEdge} = objects(e.tgt)
src(es::AbstractVector{T}) where {T<:AbstractHyperEdge} = [src(e) for e in es]
tgt(es::AbstractVector{T}) where {T<:AbstractHyperEdge} = [tgt(e) for e in es]

# multiplicities of oriented hyperedges
@traitfn src_multiplicities(e::T::IsOriented) where {T<:AbstractHyperEdge} = multiplicities(e.src)
@traitfn tgt_multiplicities(e::T::IsOriented) where {T<:AbstractHyperEdge} = multiplicities(e.tgt)

# weight of weighted hyperedges
@traitfn weight(e::T::IsWeighted) where {T<:AbstractHyperEdge } = e.weight
weights(es::AbstractVector{T}) where {T<:AbstractHyperEdge} = [weight(es...)]
weights(x::T) where {T<:AbstractHyperGraph} = weights(hyperedges(x))
