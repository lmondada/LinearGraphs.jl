# this file defines the interface of AbstractLinearGraph

"""
A linear graph is a graph where each vertex has equal numbers of inedges and outedges.
Further, each inedge corresponds to one outedge.

We assume all graphs are acyclic, so we can walk from an input to an output by following
the edges through vertices. We call each such walk from input to output a line.

Below are the methods that are expected to be implemented for the LinearGraph interface.
"""
abstract type AbstractLinearGraph{T<:Integer} <: AbstractGraph{T} end

"""
    next(g, v; line=l)

The vertex after v on line `l`.
"""
next(g::AbstractLinearGraph, v; line) = error("Not implemented")
"""
    prev(g, v; line=l)

The vertex before v on line `l`.
"""
prev(g::AbstractLinearGraph, v; line) = error("Not implemented")
"""
    line(g; line=l)

An entire path on line `l` from input to output.
"""
line(g::AbstractLinearGraph; line) = error("Not implemented")

"""
    nlines(g)

The number of lines in `g`.
"""
nlines(g::AbstractLinearGraph) = error("Not implemented")

"""
    isinitial(g, v)

Whether `v` is an input vertex.
"""
isinitial(g::AbstractLinearGraph, v) = error("Not implemented")

"""
    isfinal(g, v)

Whether `v` is an output vertex.
"""
isfinal(g::AbstractLinearGraph, v) = error("Not implemented")

"""
    isterminal(g, v)

Whether `v` is either an input or output vertex.
"""
isterminal(g::AbstractLinearGraph, v) = isinitial(g, v) || isfinal(g, v)

"""
    add_vertex!(g, i, j, ...)

Append vertex at the end of lines i, j, ...

This is the most intuitive way of building an acyclic linear graph, adding edges in a
topological order.
"""
Graphs.add_vertex!(g::AbstractLinearGraph, lines...) = error("Not implemented")

"""
    rewire_vertex_between!(g, v, s, t)

Rewire an edge (s, t) into (s, v) + (v, t).

The only supported way to add an edge, whilst respecting linearity.
"""
rewire_vertex_between!(g::AbstractLinearGraph, v, s, t) = error("Not implemented")
