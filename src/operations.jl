## bang functions ##

# add vertex, add vertices
function check_can_add_vertex(hg::T, v::U) where {T<:AbstractHyperGraph, U}
    hg_eltype = eltype(hg)
    if hg_eltype !== Any
        if !isa(hg_eltype, Union)
            !isequal(hg_eltype, U) && error("hypergraph of type $hg_eltype but vertex of type $U")
        elseif isa(hg_eltype, Union)
            !(U <: hg_eltype) && error("vertex of type $U is not a subtype of hypergraph type")
        end
    end
    has_vertex(hg, v) && error("vertex $v already in hypergraph")
    true
end
_add_vertex!(hg, v) = push!(vertices(hg), v)
function add_vertex!(hg::T, v; check=true) where {T<:AbstractHyperGraph}
    if !check || (check && check_can_add_vertex(hg, v))
        _add_vertex!(hg, v)
        true
    else
        false
    end
end
function add_vertices!(hg::T, vs::AbstractVector; check=true) where {T<:AbstractHyperGraph}
    [add_vertex!(hg, v, check=check) for v in vs]
    true
end

# delete vertex, delete vertices
@traitfn function _del_vertex_from_hyperedges!(he::T::(!IsOriented), v) where {T<:AbstractHyperEdge}
    v_pos = findall(_v -> _v == v, vertices(he))
    deleteat!(vertices(he), v_pos)
end
@traitfn function _del_vertex_from_hyperedges!(he::T::IsOriented, v) where {T<:AbstractHyperEdge}
    v_pos_src = findall(_v -> _v == v, src(he))
    deleteat!(src(he), v_pos_src)
    deleteat!(src_multiplicities(he), v_pos_src)
    v_pos_tgt = findall(_v -> _v == v, tgt(he))
    deleteat!(tgt(he), v_pos_tgt)
    deleteat!(tgt_multiplicities(he), v_pos_tgt)
end
_del_vertex_from_vertices!(hg::T, v) where {T<:AbstractHyperGraph} = filter!(_v -> _v != v, vertices(hg))
function _del_vertex!(hg, v, weak)
    incident_hes = get_incident_hyperedges(hg, v; check_presence=false) # presence checked in del_vertex!
    if !weak # completely remove any hyperedge incident on vertex
        filter!(he -> he ∉ incident_hes, hyperedges(hg))
    else # remove vertex from incidence -- retains the rest of the hyperedge
        [_del_vertex_from_hyperedges!(he, v) for he in Iterators.reverse(incident_hes)]
    end
    _del_vertex_from_vertices!(hg, v)
end
"""
    del_vertex!
Note: if choosing weak deletion, may result in empty hyperedges.
"""
function del_vertex!(hg::T, v; weak=false) where {T<:AbstractHyperGraph}
    if has_vertex(hg, v)
        _del_vertex!(hg, v, weak)
        true
    else
        error("vertex $v not in hypergraph")
    end
end
# note: using comprehensions when deleting vertices conflicts with Iterators.reverse and makes tests error; need to use a loop instead, which is here outside of the main function for clarity
function _del_vertices!(hg, vs, weak)
    for v in Iterators.reverse(vs)
        _del_vertex!(hg, v, weak)
    end
end
"""
	del_vertices!
Note: if choosing weak deletion, may result in empty hyperedges.
"""
function del_vertices!(hg::T, vs::AbstractVector; weak=false) where {T<:AbstractHyperGraph}
    if has_vertices(hg, vs)
        _del_vertices!(hg, vs, weak)
        true
    else
        error("at least one vertex not in hypergraph")
    end
end

# add hyperedge, add hyperedges
function check_can_add_hyperedge(hg::T, he::U) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    eltype(hg) !== Any && !isequal(eltype(hg), eltype(he)) && error("hypergraph of type $(eltype(hg)) but hyperedge of type $(eltype(he))")
    !has_vertices(hg, vertices(he)) && error("edge incident on vertices not already in hypergraph ($(vertices(he)[[!has_vertex(hg, v) for v in vertices(he)]]))")
    true
end
"""
    add_hyperedge!
If the hyperedge being added contains vertices not already in hypergraph hg, run `add_vertices(hg, [new_vertices])` first.
"""
function add_hyperedge!(hg::T, he::U;check=true) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    check ? check_can_add_hyperedge(hg, he) && push!(hyperedges(hg), he) : push!(hyperedges(hg), he)
    true
end
function add_hyperedges!(hg::T, hes::AbstractVector{U}; check=true) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    if check && all([check_can_add_hyperedge(hg, he) for he in hes])
        [add_hyperedge!(hg, he, check=false) for he in hes]
        true
    else
        [add_hyperedge!(hg, he, check=false) for he in hes]
        true
    end
end

# delete hyperedge, delete hyperedges
_del_hyperedge!(hg, he) = deleteat!(hyperedges(hg), findall(_he -> _he == he, hyperedges(hg)))
function del_hyperedge!(hg::T, he::U) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    if has_hyperedge(hg, he)
        _del_hyperedge!(hg, he)
        true
    else
        error("hyperedge not in hypergraph")
    end
end
function del_hyperedges!(hg::T, hes::AbstractVector{U}) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    if has_hyperedges(hg, hes)
        [_del_hyperedge!(hg, he) for he in Iterators.reverse(unique(hes))]
        true
    else
        error("at least one hyperedge not in hypergraph")
    end
end
del_empty_hyperedges!(hg::T) where {T<:AbstractHyperGraph} = !isempty(hg) && del_hyperedge!(hg, eltype(hyperedges(hg))())

# replace a vertex in a hyperedge
@traitfn function replace_vertex!(he::T::(!IsOriented), p::Pair) where {T<:AbstractHyperEdge}
    replace!(vertices(he), p)
end
@traitfn function replace_vertex!(he::T::IsOriented, p::Pair) where {T<:AbstractHyperEdge}
    replace!(src(he), p)
    replace!(tgt(he), p)
end
function replace_vertex!(hg::T, p::Pair) where {T<:AbstractHyperGraph}
    replace!(vertices(hg), p)
    for he in hyperedges(hg)
        replace_vertex!(he, p)
    end
end

# replace hyperedge, replace hyperedges
function replace_hyperedge!(hg::T, he::U, new_he::U) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    has_hyperedge(hg, he) && has_vertices(hg, vertices(new_he))
    hyperedges(hg)[findall(_he -> _he == he, hyperedges(hg))] .= [new_he]
    true
end
function replace_hyperedges!(hg::T, hes::AbstractVector{U}, new_hes::AbstractVector{U}) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    length(hes) != length(new_hes) && error("length does not match")
    [replace_hyperedge!(hg, he, new_he) for (he, new_he) in zip(hes, new_hes)]
    true
end

# weight updating
"""
    update_weight!
Notes: only works for weighted hyperedges (this will eventually be a traited function) and relies on the weight field being named `:weight`.
"""
update_weight!(he::T, w) where {T<:AbstractHyperEdge} = setfield!(he, :weight, w)
update_weight!(hg::T, he::U, w) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge} = has_hyperedge(hg, he) ? update_weight!(he, w) : error("hyperedge not in hypergraph")
set_all_weights!(hg::T, w) where {T<:AbstractHyperGraph} = [update_weight!(he, w) for he in hyperedges(hg)]

## other operations ##

# hypergraphs merging
Base.merge(hg1::T, hg2::T) where {T<:AbstractHyperGraph} = T(vcat(hyperedges(hg1), hyperedges(hg2)))
Base.merge(hgs::AbstractVector{T}) where {T<:AbstractHyperGraph} = reduce(merge, hgs)

"""
    subhypergraph
Subhypergraph induced by a set of vertices or hyperedges (also referred to as a hyperedge restriciton and a vertex restriction, respectively).
"""
function subhypergraph end

# vertex-induced subhypergraph
subhypergraph(hg::T, v) where {T<:AbstractHyperGraph} = T(get_incident_hyperedges(hg, v))
subhypergraph(hg::T, vs::AbstractVector) where {T<:AbstractHyperGraph} = T(get_incident_hyperedges(hg, vs))

# hyperedge-induced subhypergraph
function subhypergraph(hg::T, he::U; relaxed=false) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    if !relaxed
        has_hyperedge(hg, he) ? (!has_parallel_hyperedges(hg) ? T(he) : T(hyperedges(hg)[[he == _he for _he in hyperedges(hg)]])) : error("hyperedge not in hypergraph")
    elseif relaxed
        isuniquesubhyperedge(he, hg) ? T(he) : error("hyperedge is not unique subhyperedge")
    end
end
function subhypergraph(hg::T, hes::AbstractVector{U}; relaxed=false) where {T<:AbstractHyperGraph, U<:AbstractHyperEdge}
    if !relaxed
        has_hyperedges(hg, hes) ? T(hes) : error("at least one hyperedge not in hypergraph")
    elseif relaxed
        all([isuniquesubhyperedge(he, hg) for he in hes]) ? T(hes) : error("at least one hyperedge is not unique subhyperedge")
    end
end
