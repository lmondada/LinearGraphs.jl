using Graphs: SimpleDiGraph, add_edge!, add_vertex!
using Graphs: inneighbors, outneighbors
using Graphs.SimpleGraphs: fadj, badj

@testset "linear_graphs.jl" begin
    @testset "a valid graph" begin
        g = SimpleDiGraph(12)
        # qb 1
        add_edge!(g, 1, 2)
        add_edge!(g, 2, 3)
        add_edge!(g, 3, 4)
        # qb 2
        add_edge!(g, 5, 6)
        add_edge!(g, 6, 2)
        add_edge!(g, 2, 7)
        add_edge!(g, 7, 8)
        # qb 3
        add_edge!(g, 9, 10)
        add_edge!(g, 10, 3)
        add_edge!(g, 3, 7)
        add_edge!(g, 7, 11)
        add_edge!(g, 11, 12)

        ling = LinearGraph(g)
        for v in 1:4:12
            @test isterminal(ling, v)
            @test isinitial(ling, v)
        end
        for v in 4:4:12
            @test isterminal(ling, v)
            @test isfinal(ling, v)
        end

        @testset "next/prev" begin
            # line 1
            @test next(ling, 1) == 2
            @test prev(ling, 2; line=1) == 1
            @test next(ling, 2; line=1) == 3
            @test prev(ling, 3; line=1) == 2
            @test next(ling, 3; line=1) == 4
            @test prev(ling, 4) == 3
            # line 2
            @test next(ling, 5; line=2) == 6
            @test prev(ling, 6; line=2) == 5
            @test next(ling, 6; line=2) == 2
            @test prev(ling, 2; line=2) == 6
            @test next(ling, 2; line=2) == 7
            @test prev(ling, 7; line=2) == 2
            @test next(ling, 7; line=2) == 8
            @test prev(ling, 8; line=2) == 7
            # line 3
            @test next(ling, 9; line=3) == 10
            @test prev(ling, 10; line=3) == 9
            @test next(ling, 10; line=3) == 3
            @test prev(ling, 3; line=3) == 10
            @test next(ling, 3; line=3) == 7
            @test prev(ling, 7; line=3) == 3
            @test next(ling, 7; line=3) == 11
            @test prev(ling, 11; line=3) == 7
            @test next(ling, 11; line=3) == 12
            @test prev(ling, 12; line=3) == 11
        end

        @testset "line" begin
            l1 = line(ling; line=1)
            @test l1 == [1, 2, 3, 4]

            l2 = line(ling; line=2)
            @test l2 == [5, 6, 2, 7, 8]

            l3 = line(ling; line=3)
            @test l3 == [9, 10, 3, 7, 11, 12]
        end
    end

    @testset "the real way to build a linear graph" begin
        g = LinearGraph(4)
        add_vertex!(g, 1, 2) # v9
        add_vertex!(g, 2) # v10
        add_vertex!(g, 3, 4) # v11
        add_vertex!(g, 2, 3) # v12
        add_vertex!(g, 4) # v13
        add_vertex!(g, 4) # v14
        add_vertex!(g, 1, 2, 3) # v15

        l1 = line(g; line=1)
        @test l1 == [1, 9, 15, 5]

        l2 = line(g; line=2)
        @test l2 == [2, 9, 10, 12, 15, 6]

        l3 = line(g; line=3)
        @test l3 == [3, 11, 12, 15, 7]

        l4 = line(g; line=4)
        @test l4 == [4, 11, 13, 14, 8]
    end
end
