# HyperGraphs.jl

The main aim of this package is to implement concepts of graph theory on hypergraphs. At the most basic level, it allows to represent high-order relationships between objects, with complete freedom to choose the type of these objects. A secondary aim follows from the realisation that most flavours of (hyper)graphs are a specific case of oriented, weighted hypergraphs; from this, it should be possible to define all methods at the hypergraph level and to programmatically specialise them for other (hyper)graph types.

Currently implemented are fundamental constructors for unoriented, unweighted hypergraphs (via the `HyperGraph` and `HyperEdge` types) and for a specific case of oriented, weighted hypergraphs: chemical hypergraphs (via the `ChemicalHyperGraph` and `ChemicalHyperEdge` types), as well as a set of functions that allow to modify hypergraphs (adding and deleting hyperedges and vertices). Flavours of hypergraphs and hyperedges are implemented with traits via [SimpleTraits.jl](https://github.com/mauro3/SimpleTraits.jl); traits implemented so far are `IsOriented` and `IsWeighted`.

For some example applications of HyperGraphs.jl, check out its sibling package [Simulacrum.jl](https://github.com/lpmdiaz/Simulacrum.jl).

## High-level aims

One aim would be to have the trait system be automatically generated: because traits membership information (i.e. which traits does a specific flavour of hypergraph have?) may be represented as relationships i.e. hyperedges between types of hypergraphs, it should be possible to derive the entire trait system from a hypergraph representing such information. Further, this would mean that any method could be programmatically derived from a set of trait-specific methods. This would mean that it is only necessary to implement each method once, and that any newly implemented flavour of hypergraph naturally inherits all existing methods. One caveat is that the resulting code may not be optimally efficient.

Another aim would be to represent heterogeneous relationships within the same hypergraph. This relies again on the fact that most flavours of (hyper)graphs are a specific case of oriented, weighted hypergraphs (e.g. an unweighted edge is a weighted edge with weight 1; a directed graph is a special case of an oriented graph, etc.), implying that the same hypergraph may be made up of different flavours of hypergraphs (e.g. organised in neighborhoods). A concrete example would be a hypergraph describing directed relationships, with the exception of a small number of oriented ones; it should be possible to represent this information in a hypergraph made up of both directed and oriented hyperedges, and rely on promotion / conversions between these flavours to make them interact. Taken one step further, this would allow to connect distinct modelling formalisms that can be encoded as hypergraphs; as such, hypergraphs would serve as a fundamental representation of e.g. chemical reaction networks, Petri nets, etc. and relationships between hypergraphs flavours would allow to switch between modelling formalisms.

## Naming rules

In the code, `hg` and `hgs` refer to one and several hypergraphs, respectively; the same applies for `he` and `hes` with hyperedges, and for `v` and `vs` with vertices.

The current idea to allow for natural extension of the core functions is to respect a set of standard field names when defining a new custom concrete type. If custom field names are needed, these should be explicitly connected to core methods (`vertices` and `hyperedges` mainly). Currently, field names should be:

- `V`, the set of vertices in a hypergraph and a hyperedge
- `HE`, the set of hyperedges in a hypergraph
- `src`, the set of source vertices in an oriented hyperedge
- `tgt`, the set of target vertices in an oriented hyperedge
- `objs`, the objects of an incidence
- `mults`, the multiplicities of the objects of an incidence
- `w`, the weight of a weighted hyperedge

Then, custom names are built on top e.g. `rate(che::ChemicalHyperEdge) = weight(che)` (which is already implemented).

Note a potential future breaking change about the behaviour of `src` and `tgt`: these currently return the objects of the set of incidences but may return the set of incidences themselves in the future, depending on what makes sense. This also means that currently, the extension of `Base.==` does not check for equal multiplicity (which may be slightly incorrect).

## Some notes on the code

A word of caution: this is a work in progress, and so functions have not been perfectly proofread for corectness (especially those in operations, neighbor functions, parallel and multi-hyperedges, loops...). E.g. currently, it is possible to add hyperedges to a hypergraph that does not have all the vertices in said hyperedges in its vertx set; this will be prevented from happening eventually.

Each graph flavour should be implemented with performance and ease of interfacing (i.e. of accessing information) in mind: there is no need to carry redundant information just because the mathematical syntax does. Hopefully this is true in the current code, but some improvements are definitely possible.

## Implementation notes

Most of these will hopefully end up in the documentation.

### Core

The source and the target of an oriented hyperedge are also referred to as head and tail, but the former is more explicit.

#### Chemical hypergraphs and chemical hyperedges

Chemical hypergraphs represent reaction networks but are rooted in graph theory. The main reference is probably [[Jost2019]](#Jost2019).

In this implementation, I took the liberty to name _chemical hyperedges_ the reactions, following the same logic as naming _chemical hypergraph_ the hypergraph that represents a system of reactions (this is because in each case it is a specific case of hypergraph and hyperedge, namely one where the hyperedge incidence multiplicity is restricted to the positive integers, thus representing stoichiometries).

Constructors set 1 as the default value for reactions rate and for stoichiometries; this is to simplify the syntax. For instance, all these calls are equivalent: `SpeciesSet(["X"])`, `SpeciesSet("X")`, `SpeciesSet("X", 1)`, `SpeciesSet(["X"], [1])`. Compared to other implementations of reaction networks, it is also easier to specify a different stoichiometry for only part of the reaction (e.g. if one needs only some of the reactants to have stoichiometries different from 1, only the reactant stoichiometries have to be specified and not those of all the species involved).

### Properties

The vertex _degree_ is also referred to as _valency_. Additionally, the _degree_ of a graph is its maximum vertex degree [[Zhu2019]](#Zhu2019), which is not implemented here to avoid confusion.

Hyperedge cardinality is also referred to as _order_ [[Zhu2019]](#Zhu2019), and as _size_. Neither of these are implemented; the former may be confused with the order of a hypergraph, and the latter may conflict with `Base.size`.

The _size_ of a hypergraph is defined in [[Gallo1993]](#Gallo1993); this is implemented as `hypergraph_size` to avoid confusion with `Base.size` again.

The _order_ of a hypergraph is its number of vertices [[Wang2018]](#Wang2018), [[Zaslavsky2010]](#Zaslavsky2010). (Also note that order is used to refer to the maximum cardinality of a hypergraph in [[Zhu2019]](#Zhu2019), but this use seems unusual.)

Note that the _rank_ of a reaction network is the maximum number of linearly independent reactions [[Shinar2010]](#Shinar2010), which may be confused with the rank of a hypergraph.

A reference for the _volume_ of a hypergraph is [[Kaminski2019]](#Kaminski2019).

### Operations

Functions only do what their name implies, and so if a loop is undesirable in a specific application, one must check that e.g. the hyperedge that is about to be added to a hypergraph is not a loop.

_Weak_ deletion only deletes incidences, whereas _strong_ deletion deletes any object incident on the object(s) being deleted; this means that e.g. weak vertex deletion removes any occurence of the given vertex in the hyperedges incident on that vertex but does not delete those hyperedges [[Chen2018]](#Chen2018), [[Rusnak2013]](#Rusnak2013). Note: vertex deletion is (incidence) dual to edge deletion [[Rusnak2013]](#Rusnak2013).

Note: currently, the internal function `_del_vertex!(he)` must have two methods: one for unoriented and one for oriented hyperedges; this is because the former method only needs to remove a vertex from `vertices(he)` when the latter needs to remove it from both the source and target sets (and both objects and multiplicities), which does not naturally work with `vertices` of an oriented hyperedge. This is somewhat messy; ideally, as mentioned above, methods would be built automatically from the hyperedge flavour (here oriented vs. unoriented), via traits.

## Future developments

This is mainly a personal repository to play around with hypergraphs, but I do plan to add more functionalities over time.

## References

<a id="Chen2018"></a>[Chen2018] --
Chen, G., Liu, V., Robinson, E., Rusnak, L. J., & Wang, K. (2018). A characterization of oriented hypergraphic Laplacian and adjacency matrix coefficients. _Linear Algebra and Its Applications_, 556, 323–341. [[doi]](https://doi.org/10.1016/j.laa.2018.07.012)

<a id="Gallo1993"></a>[Gallo1993] --
Gallo, G., Longo, G., Pallottino, S., & Nguyen, S. (1993). Directed hypergraphs and applications. _Discrete Applied Mathematics_, 42(2–3), 177–201. [[doi]](https://doi.org/10.1016/0166-218X(93)90045-P)

<a id="Jost2019"></a>[Jost2019] --
Jost, J., & Mulas, R. (2019). Hypergraph Laplace operators for chemical reaction networks. _Advances in Mathematics_, 351, 870–896. [[doi]](https://doi.org/10.1016/j.aim.2019.05.025)

<a id="Kaminski2019"></a>[Kaminski2019] --
Kamiński, B., Poulin, V., Prałat, P., Szufel, P., & Théberge, F. (2019). Clustering via hypergraph modularity. _PLoS ONE_, 14(11), 1–15. [[doi]](https://doi.org/10.1371/journal.pone.0224307)

<a id="Rusnak2013"></a>[Rusnak2013] --
Rusnak, L. J. (2013). Oriented hypergraphs: Introduction and balance. _Electronic Journal of Combinatorics_, 20(3), 1–29. [[doi]](https://doi.org/10.37236/2763)

<a id="Shinar2010"></a>[Shinar2010] --
Shinar, G., & Feinberg, M. (2010). Structural sources of robustness in biochemical reaction networks. _Science_, 327(5971), 1389–1391. [[doi]](https://doi.org/10.1126/science.1183372)

<a id="Wang2018"></a>[Wang2018] --
Wang, L., Egorova, E. K., & Mokryakov, A. V. (2018). Development of Hypergraph Theory. _Journal of Computer and Systems Sciences International_, 57(1), 109–114. [[doi]](https://doi.org/10.1134/S1064230718010136)

<a id="Zaslavsky2010"></a>[Zaslavsky2010] --
Zaslavsky, T. (2010). Matrices in the Theory of Signed Simple Graphs. _arXiv_, 1–20. Retrieved from [http://arxiv.org/abs/1303.3083](http://arxiv.org/abs/1303.3083)

<a id="Zhu2019"></a>[Zhu2019] --
Zhu, H., & Masahito H. (2019). Efficient verification of hypergraph states. _Physical Review Applied_, 12(5), 054047. [[doi]](https://doi.org/10.1103/PhysRevApplied.12.054047)