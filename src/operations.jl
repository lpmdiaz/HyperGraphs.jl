## bang functions ##

# add vertex, add vertices
function check_can_add_vertex(x::T, v::U) where {T<:AbstractHyperGraph, U}
    x_eltype = eltype(x)
    if x_eltype !== Any
        if !isa(x_eltype, Union)
            !isequal(x_eltype, U) && error("hypergraph of type $x_eltype but vertex of type $U")
        elseif isa(x_eltype, Union)
            !(U <: x_eltype) && error("vertex of type $U is not a subtype of hypergraph type")
        end
    end
    has_vertex(x, v) && error("vertex $v already in hypergraph")
    true
end
_add_vertex!(x, v) = push!(vertices(x), v)
function add_vertex!(x::T, v; check=true) where {T<:AbstractHyperGraph}
    if !check || (check && check_can_add_vertex(x, v))
        _add_vertex!(x, v)
        true
    else
        false
    end
end
function add_vertices!(x::T, vs::AbstractVector; check=true) where {T<:AbstractHyperGraph}
    [add_vertex!(x, v, check=check) for v in vs]
    true
end

# delete vertex, delete vertices
@traitfn function _del_vertex_from_hyperedges!(e::T::(!IsOriented), v) where {T<:AbstractHyperEdge}
    v_pos = findall(_v -> _v == v, vertices(e))
    deleteat!(vertices(e), v_pos)
end
@traitfn function _del_vertex_from_hyperedges!(e::T::IsOriented, v) where {T<:AbstractHyperEdge}
    v_pos_src = findall(_v -> _v == v, src(e))
    deleteat!(src(e), v_pos_src)
    deleteat!(src_multiplicities(e), v_pos_src)
    v_pos_tgt = findall(_v -> _v == v, tgt(e))
    deleteat!(tgt(e), v_pos_tgt)
    deleteat!(tgt_multiplicities(e), v_pos_tgt)
end
_del_vertex_from_vertices!(x::T, v) where {T<:AbstractHyperGraph} = filter!(_v -> _v != v, vertices(x))
function _del_vertex!(x, v, weak)
    incident_es = incident_hyperedges(x, v; check_presence=false) # presence checked in del_vertex!
    if !weak # completely remove any hyperedge incident on vertex
        filter!(e -> e ∉ incident_es, hyperedges(x))
    else # remove vertex from incidence -- retains the rest of the hyperedge
        [_del_vertex_from_hyperedges!(e, v) for e in Iterators.reverse(incident_es)]
    end
    _del_vertex_from_vertices!(x, v)
end
"""
    del_vertex!
Note: if choosing weak deletion, may result in empty hyperedges.
"""
function del_vertex!(x::T, v; weak=false) where {T<:AbstractHyperGraph}
    if has_vertex(x, v)
        _del_vertex!(x, v, weak)
        true
    else
        error("vertex $v not in hypergraph")
    end
end
# note: using comprehensions when deleting vertices conflicts with Iterators.reverse and makes tests error; need to use a loop instead, which is here outside of the main function for clarity
function _del_vertices!(x, vs, weak)
    for v in Iterators.reverse(vs)
        _del_vertex!(x, v, weak)
    end
end
"""
	del_vertices!
Note: if choosing weak deletion, may result in empty hyperedges.
"""
function del_vertices!(x::T, vs::AbstractVector; weak=false) where {T<:AbstractHyperGraph}
    if has_vertices(x, vs)
        _del_vertices!(x, vs, weak)
        true
    else
        error("at least one vertex not in hypergraph")
    end
end

# add hyperedge, add hyperedges
function check_can_add_hyperedge(x::T, e::U) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    eltype(x) !== Any && !isequal(eltype(x), eltype(e)) && error("hypergraph of type $(eltype(x)) but hyperedge of type $(eltype(e))")
    !has_vertices(x, vertices(e)) && error("edge incident on vertices not already in hypergraph ($(vertices(e)[[!has_vertex(x, v) for v in vertices(e)]]))")
    true
end
"""
    add_hyperedge!
If the hyperedge being added contains vertices not already in hypergraph x, run `add_vertices(x, [new_vertices])` first.
"""
function add_hyperedge!(x::T, e::U;check=true) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    check ? check_can_add_hyperedge(x, e) && push!(hyperedges(x), e) : push!(hyperedges(x), e)
    true
end
function add_hyperedges!(x::T, es::AbstractVector{U}; check=true) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    if check && all([check_can_add_hyperedge(x, e) for e in es])
        [add_hyperedge!(x, e, check=false) for e in es]
        true
    else
        [add_hyperedge!(x, e, check=false) for e in es]
        true
    end
end

# delete hyperedge, delete hyperedges
_del_hyperedge!(x, e) = deleteat!(hyperedges(x), findall(_e -> _e == e, hyperedges(x)))
function del_hyperedge!(x::T, e::U) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    if has_hyperedge(x, e)
        _del_hyperedge!(x, e)
        true
    else
        error("hyperedge $(e) not in hypergraph")
    end
end
function del_hyperedges!(x::T, es::AbstractVector{U}) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    if has_hyperedges(x, es)
        [_del_hyperedge!(x, e) for e in Iterators.reverse(unique(es))]
        true
    else
        error("at least one hyperedge not in hypergraph")
    end
end
del_empty_hyperedges!(x::T) where {T<:AbstractHyperGraph} = !isempty(x) && del_hyperedge!(x, eltype(hyperedges(x))())

# replace a vertex in a hyperedge
@traitfn function replace_vertex!(e::T::(!IsOriented), p::Pair) where {T<:AbstractHyperEdge}
    replace!(vertices(e), p)
end
@traitfn function replace_vertex!(e::T::IsOriented, p::Pair) where {T<:AbstractHyperEdge}
    replace!(src(e), p)
    replace!(tgt(e), p)
end
function replace_vertex!(x::T, p::Pair) where {T<:AbstractHyperGraph}
    replace!(vertices(x), p)
    for e in hyperedges(x)
        replace_vertex!(e, p)
    end
end

# replace hyperedge, replace hyperedges
function replace_hyperedge!(x::T, e::U, new_e::U) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    has_hyperedge(x, e) && has_vertices(x, vertices(new_e))
    hyperedges(x)[findall(_e -> _e == e, hyperedges(x))] .= [new_e]
    true
end
function replace_hyperedges!(x::T, es::AbstractVector{U}, new_es::AbstractVector{U}) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    length(es) != length(new_es) && error("length does not match")
    [replace_hyperedge!(x, e, new_e) for (e, new_e) in zip(es, new_es)]
    true
end

# weight updating
"""
    update_weight!
Notes: only works for weighted hyperedges (this will eventually be a traited function) and relies on the weight field being named `:weight`.
"""
update_weight!(e::T, w) where {T<:AbstractHyperEdge} = setfield!(e, :weight, w)
update_weight!(x::T, e::U, w) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge} = has_hyperedge(x, e) ? update_weight!(e, w) : error("hyperedge not in hypergraph")
set_all_weights!(x::T, w) where {T<:AbstractHyperGraph} = [update_weight!(e, w) for e in hyperedges(x)]

## other operations ##

# hypergraphs merging
Base.merge(x1::T, x2::T) where {T<:AbstractHyperGraph} = T(vcat(hyperedges(x1), hyperedges(x2)))
Base.merge(x::T, y::T, z::T...) where {T<:AbstractHyperGraph} = merge(merge(x, y), z...)
Base.merge(xs::AbstractVector{T}) where {T<:AbstractHyperGraph} = reduce(merge, xs)

"""
    subhypergraph
Subhypergraph induced by a set of vertices or hyperedges (also referred to as a hyperedge restriciton and a vertex restriction, respectively).
"""
function subhypergraph end

# vertex-induced subhypergraph
subhypergraph(x::T, v) where {T<:AbstractHyperGraph} = T(incident_hyperedges(x, v))
subhypergraph(x::T, vs::AbstractVector) where {T<:AbstractHyperGraph} = T(incident_hyperedges(x, vs))

# hyperedge-induced subhypergraph
function subhypergraph(x::T, e::U; relaxed=false) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    if !relaxed
        has_hyperedge(x, e) ? (!has_parallel_hyperedges(x) ? T(e) : T(hyperedges(x)[[e == _e for _e in hyperedges(x)]])) : error("hyperedge not in hypergraph")
    elseif relaxed
        isuniquesubhyperedge(e, x) ? T(e) : error("hyperedge is not unique subhyperedge")
    end
end
function subhypergraph(x::T, es::AbstractVector{U}; relaxed=false) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    if !relaxed
        has_hyperedges(x, es) ? T(es) : error("at least one hyperedge not in hypergraph")
    elseif relaxed
        all([isuniquesubhyperedge(e, x) for e in es]) ? T(es) : error("at least one hyperedge is not unique subhyperedge")
    end
end

# switch an oriented hyperedge, i.e. swap its source and target sets
@traitfn function switch(e::T::IsOriented) where {T<:AbstractHyperEdge}
    T([e.tgt, e.src, [getproperty(e, sym) for sym in fieldnames(T)[3:end]]...]...)
end
