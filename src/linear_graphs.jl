const LinearGraphEdge = SimpleDiGraphEdge

"""
    LinearGraph{T}
A type representing a directed graph.

Difference to SimpleDiGraph: adjacency lists are ordered (and not sorted).
"""
mutable struct LinearGraph{T<:Integer} <: AbstractLinearGraph{T}
    ne::Int
    fadjlist::Vector{Vector{T}} # [src]: (qb=>dst, qb=>dst, qb=>dst)
    badjlist::Vector{Vector{T}} # [dst]: (qb=>src, qb=>src, qb=>src)
    linenb::Vector{Vector{T}}
    ins::Vector{T}
    outs::Vector{T}

    function LinearGraph(
        fadjlist::Vector{Vector{T}}, badjlist::Vector{Vector{T}}, linenb=nothing
    ) where {T}
        ins = T[]
        nv = length(fadjlist)
        ne = 0
        if isnothing(linenb)
            linenb = Vector{Vector{T}}(undef, nv)
        end
        if length(badjlist) != nv
            error("fadjlist and badjlist must be same length")
        end

        for v in 1:nv
            nout = length(fadjlist[v])
            nin = length(badjlist[v])
            ne += nout
            if nin == 0 && nout == 1
                # this is an input
                push!(ins, v)
            elseif nin == 1 && nout == 0
                # this is an output
            elseif nin != nout
                error("Linearity is not respected")
            end
            linenb[v] = fill(0, max(nin, nout))
        end
        outs = similar(ins)

        g = new{T}(ne, fadjlist, badjlist, linenb, ins, outs)

        for line in eachindex(ins)
            prev = ins[line]
            v = prev
            linenb[v][1] = line
            while !isempty(outneighbors(g, v))
                prev = v
                v = next(g, v; line=line)

                port = 1
                nin = length(badjlist[v])
                while (port ≤ nin) && (badjlist[v][port] != prev || linenb[v][port] != 0)
                    port += 1
                end
                if port > nin
                    error("Could not find port for vertex $v on line $line.")
                end
                linenb[v][port] = line
            end
            outs[line] = v
        end
        return g
    end
end

function LinearGraph(g::AbstractGraph)
    return LinearGraph(fadj(g), badj(g))
end
function LinearGraph(::Type{T}, n::Integer) where {T}
    g = SimpleDiGraph{T}(2n)
    for i in 1:n
        add_edge!(g, i, i + n)
    end
    return LinearGraph(g)
end
LinearGraph(n::Integer) = LinearGraph(Int, n)

function underlying(::Type{G}, g::LinearGraph) where {G<:AbstractGraph}
    return G(g.ne, g.fadjlist, g.badjlist)
end
underlying(g::LinearGraph{T}) where {T} = underlying(SimpleDiGraph{T}, g)

function Base.:(==)(a::LinearGraph, b::LinearGraph)
    for name in fieldnames(LinearGraph)
        if getfield(a, name) != getfield(b, name)
            return false
        end
    end
    return true
end

function isinitial(g::LinearGraph, v)
    return length(inneighbors(g, v)) == 0 && length(outneighbors(g, v)) == 1
end
function isfinal(g::LinearGraph, v)
    return length(inneighbors(g, v)) == 1 && length(outneighbors(g, v)) == 0
end
function next(g::LinearGraph, v; line=nothing)
    if isnothing(line)
        length(g.linenb[v]) == 1 || error("Could not infer line number")
        port = 1
    else
        port = portnb(g, v; line=line)
    end
    return outneighbors(g, v)[port]
end
function prev(g::LinearGraph, v; line=nothing)
    if isnothing(line)
        length(g.linenb[v]) == 1 || error("Could not infer line number")
        port = 1
    else
        port = portnb(g, v; line=line)
    end
    return inneighbors(g, v)[port]
end

function portnb(g::LinearGraph, v; line)
    portnb = 1
    nports = length(g.linenb[v])
    while portnb ≤ nports && g.linenb[v][portnb] != line
        portnb += 1
    end
    if portnb > nports
        error("Could not find line $line.")
    end
    return portnb
end

function line(g::LinearGraph; line)
    v = g.ins[line]
    path = [v]
    while v != g.outs[line]
        v = next(g, v; line=line)
        push!(path, v)
    end
    return path
end

function Graphs.add_vertex!(g::LinearGraph, lines...)
    add_vertex!(underlying(g)) || return false
    push!(g.linenb, [])
    v = nv(g)
    for l in lines
        out = g.outs[l]
        rewire_vertex_between!(g, v, prev(g, out), out; line=l)
    end
    return true
end

Graphs.nv(g::LinearGraph) = nv(underlying(g))
Graphs.ne(g::LinearGraph) = g.ne
Graphs.SimpleGraphs.fadj(g::LinearGraph, v) = fadj(underlying(g), v)
Graphs.SimpleGraphs.badj(g::LinearGraph, v) = badj(underlying(g), v)
Graphs.outneighbors(g::LinearGraph, v) = fadj(g, v)
Graphs.inneighbors(g::LinearGraph, v) = badj(g, v)
Base.eltype(::Type{LinearGraph{T}}) where {T} = T
Graphs.vertices(g::LinearGraph) = eachindex(fadj(g))

"""
    rewire_vertex_between!(g, v, s, t; line)

Insert v between s and t on line, maintaining linearity. This is the only way to add edges
in a linear graph.
"""
function rewire_vertex_between!(g::LinearGraph, v, s, t; line)
    s_port = portnb(g, s; line=line)
    t_port = portnb(g, t; line=line)

    g.fadjlist[s][s_port] == t || error("($s, $t) were not connected previously.")
    g.badjlist[t][t_port] == s || error("($s, $t) were not connected previously.")

    g.fadjlist[s][s_port] = v
    g.badjlist[t][t_port] = v

    push!(g.fadjlist[v], t)
    push!(g.badjlist[v], s)
    push!(g.linenb[v], line)
    g.ne += 1

    return nothing
end
