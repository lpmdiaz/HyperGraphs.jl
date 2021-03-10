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
mutable struct SpeciesSet{T}
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
