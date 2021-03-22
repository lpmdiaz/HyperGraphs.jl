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
Base.:(==)(he1::HyperEdge, he2::HyperEdge) = isequal(vertices(he1), vertices(he2))
Base.eltype(::HyperEdge{T}) where {T} = T

"""
	HyperGraph{T}

A type that represents unoriented, unweighted hypergraphs.

# Fields
- `V`: a set of vertices
- `HE`: a set of hyperedges
"""
mutable struct HyperGraph{T} <: AbstractHyperGraph
	V::AbstractVector{T}
	HE::AbstractVector{HyperEdge{T}}
end
HyperGraph(v::T, hes::AbstractVector{HyperEdge{T}}) where {T} = HyperGraph{T}([v], hes)
HyperGraph(vs::AbstractVector{T}, he::HyperEdge{T}) where {T} = HyperGraph{T}(vs, [he])
HyperGraph(v::T, he::HyperEdge{T}) where {T} = HyperGraph{T}([v], [he])
HyperGraph(hes::AbstractVector{HyperEdge{T}}) where {T} = HyperGraph(union(vertices(hes)...), hes)
HyperGraph(he::HyperEdge{T}) where {T} = HyperGraph(union(vertices(he)), he)
HyperGraph{T}() where {T} = HyperGraph{T}([], [])
HyperGraph() = HyperGraph{Any}([], [])
(::Type{HyperGraph{T}})(he::HyperEdge{T}) where {T} = HyperGraph(he)
(::Type{HyperGraph{T}})(hes::AbstractVector{HyperEdge{T}}) where {T} = HyperGraph(hes)
Base.:(==)(hg1::HyperGraph, hg2::HyperGraph) = isequal(vertices(hg1), vertices(hg2)) && isequal(hyperedges(hg1), hyperedges(hg2))

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
inputs(che::ChemicalHyperEdge) = src(che)
outputs(che::ChemicalHyperEdge) = tgt(che)
rate(che::ChemicalHyperEdge) = weight(che)
src_stoich(che::ChemicalHyperEdge) = src_multiplicities(che)
tgt_stoich(che::ChemicalHyperEdge) = tgt_multiplicities(che)
inputs_stoich(che::ChemicalHyperEdge) = src_stoich(che)
outputs_stoich(che::ChemicalHyperEdge) = tgt_stoich(che)
Base.:(==)(che1::ChemicalHyperEdge, che2::ChemicalHyperEdge) = isequal(inputs(che1), inputs(che2)) && isequal(outputs(che1), outputs(che2)) && isequal(rate(che1), rate(che2))
Base.eltype(::ChemicalHyperEdge{T}) where {T} = T

"""
	ChemicalHyperGraph{T}

A type that represents oriented, weighted hypergraphs, in the context of chemical reactions.

# Fields
- `V`: a set of vertices
- `HE`: a set of chemical hyperedges
"""
mutable struct ChemicalHyperGraph{T} <: AbstractHyperGraph
	V::AbstractVector{T}
	HE::AbstractVector{ChemicalHyperEdge{T}}
end
ChemicalHyperGraph(vs::AbstractVector{T}, he::ChemicalHyperEdge{T}) where {T} = ChemicalHyperGraph{T}(vs, [he])
ChemicalHyperGraph(he::ChemicalHyperEdge{T}) where {T} = ChemicalHyperGraph{T}(union(vertices(he)), [he])
ChemicalHyperGraph(hes::AbstractVector{ChemicalHyperEdge{T}}) where {T} = ChemicalHyperGraph(union(vertices(hes)...), hes)
(::Type{ChemicalHyperGraph{T}})(he::ChemicalHyperEdge{T}) where {T} = ChemicalHyperGraph(he)
(::Type{ChemicalHyperGraph{T}})(hes::AbstractVector{ChemicalHyperEdge{T}}) where {T} = ChemicalHyperGraph(hes)
ChemicalHyperGraph{T}() where {T} = ChemicalHyperGraph{T}([], [])
ChemicalHyperGraph() = ChemicalHyperGraph{Any}([], [])
Base.:(==)(hg1::ChemicalHyperGraph, hg2::ChemicalHyperGraph) = isequal(vertices(hg1), vertices(hg2)) && isequal(hyperedges(hg1), hyperedges(hg2))
Base.eltype(::ChemicalHyperGraph{T}) where {T} = T

## traits ##

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

## core functions ##

# objects and multiplicities of incidence structures
objects(i::T) where {T<:AbstractIncidenceSet} = i.objs
multiplicities(i::T) where {T<:AbstractIncidenceSet} = i.mults

# vertices of hyperedges, of hypergraphs
@traitfn vertices(he::T::(!IsOriented)) where {T<:AbstractHyperEdge} = he.V
@traitfn vertices(he::T::IsOriented) where {T<:AbstractHyperEdge} = vcat(src(he), tgt(he))
vertices(hes::AbstractVector{T}) where {T<:AbstractHyperEdge} = vertices.(hes)
vertices(hg::T) where {T<:AbstractHyperGraph} = hg.V

# hyperedges of hypergraphs
hyperedges(hg::T) where {T<:AbstractHyperGraph} = hg.HE

# source and target of oriented hyperedges
@traitfn src(he::T::IsOriented) where {T<:AbstractHyperEdge} = objects(he.src)
@traitfn tgt(he::T::IsOriented) where {T<:AbstractHyperEdge} = objects(he.tgt)
src(hes::AbstractVector{T}) where {T<:AbstractHyperEdge} = [src(he) for he in hes]
tgt(hes::AbstractVector{T}) where {T<:AbstractHyperEdge} = [tgt(he) for he in hes]

# multiplicities of oriented hyperedges
@traitfn src_multiplicities(he::T::IsOriented) where {T<:AbstractHyperEdge} = multiplicities(he.src)
@traitfn tgt_multiplicities(he::T::IsOriented) where {T<:AbstractHyperEdge} = multiplicities(he.tgt)

# weight of weighted hyperedges
@traitfn weight(he::T::IsWeighted) where {T} = he.weight
