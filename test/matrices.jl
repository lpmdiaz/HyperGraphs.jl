using HyperGraphs

x1 = HyperGraph([HyperEdge([1, 2, 3]), HyperEdge([2, 3, 4])])
x2 = HyperGraph([HyperEdge(["1", "2", "3"]), HyperEdge(["2", "3", "4"])])

# degree matrix
@test degree_matrix(x1) == degree_matrix(x2)
