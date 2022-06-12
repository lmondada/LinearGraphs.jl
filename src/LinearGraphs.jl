module LinearGraphs

export AbstractLinearGraph, LinearGraph
export isinitial, isfinal, isterminal
export line, next, prev

using Graphs: AbstractGraph, SimpleDiGraph, SimpleDiGraphEdge
using Graphs: nv, inneighbors, outneighbors
using Graphs.SimpleGraphs: fadj, badj
using Graphs: add_edge!, rem_edge!, add_vertex!
using Graphs

include("interface.jl")
include("linear_graphs.jl")
# Write your package code here.

end
