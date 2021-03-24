# degree matrix
degree_matrix(hg::T) where {T<:AbstractHyperGraph} = Diagonal(degrees(hg))

# incidence matrix (oriented case)
@traitfn function incidence_matrix(hg::T::IsOriented) where {T<:AbstractHyperGraph}
	idx = vertices_to_indices(hg)
	I = zeros(Int, nv(hg), nhe(hg))
	@inbounds for (i, he) in enumerate(hyperedges(hg))
		[I[idx[v], i] -= s for (v, s) in zip(objects(he.src), src_multiplicities(he))]
		[I[idx[v], i] += s for (v, s) in zip(objects(he.tgt), tgt_multiplicities(he))]
	end
	I
end
