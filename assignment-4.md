---
title: Assignment 4 for COMP 361
author:
    - Dylan Chong (Student ID - 300373593)
date: \today{}
---

# Installation

Firstly, install Elixir [from here](https://elixir-lang.org/install.html).

Then unzip the `project.zip` and `cd` into it. From now on I will assume you
are in the unzipped project folder.

Then install dependencies:

    mix deps.get

# Part 0

My UI simply involves using the interactive console to call commands, and
printing the board out when calculating is finished. See the function
`to_string` inside file `lib/board.ex` for the board to string conversion
implementation.

# Part 1

Part one is implemented in file `lib/part_1_kt_solver.ex` - see function
`solve`.

To run an example, open up the interactive console:

    iex -S mix test

*Please note that the `test` argument is required to (probably) force mix to
compile and optimise the code, rather than compiling onthefly and not
optimising. Without the `test` argument, the algorithm runs an order of
magnitude slower. (This is my best guess as to what is happening.)*

Then run the algorithm on the size 3x10 (for example):

    Timer.bench_size(Part1KTSolver, 3, 10, true)

`Part1KTSolver` is the module that contains the solve method. The `true`
argument enables printing of the result.

Hopefully you see something like:

    * Duration: 11521.142 ms
      * Result:
    +-----+-----+-----+
    | 0   | 27  | 2   |
    +-----+-----+-----+
    | 3   | 18  | 29  |
    +-----+-----+-----+
    | 28  | 1   | 26  |
    +-----+-----+-----+
    | 19  | 4   | 17  |
    +-----+-----+-----+
    | 6   | 25  | 20  |
    +-----+-----+-----+
    | 21  | 16  | 5   |
    +-----+-----+-----+
    | 24  | 7   | 22  |
    +-----+-----+-----+
    | 15  | 10  | 13  |
    +-----+-----+-----+
    | 12  | 23  | 8   |
    +-----+-----+-----+
    | 9   | 14  | 11  |
    +-----+-----+-----+

    {11521.142,
     [board: %Board{height: 10,
       map: %{{0, 0} => 0, {0, 1} => 3, {0, 2} => 28, {0, 3} => 19, {0, 4} => 6,
         {0, 5} => 21, {0, 6} => 24, {0, 7} => 15, {0, 8} => 12, {0, 9} => 9,
         {1, 0} => 27, {1, 1} => 18, {1, 2} => 1, {1, 3} => 4, {1, 4} => 25,
         {1, 5} => 16, {1, 6} => 7, {1, 7} => 10, {1, 8} => 23, {1, 9} => 14,
         {2, 0} => 2, {2, 1} => 29, {2, 2} => 26, {2, 3} => 17, {2, 4} => 20,
         {2, 5} => 5, {2, 6} => 22, {2, 7} => 13, {2, 8} => 8, {2, 9} => 11},
       width: 3},
      points: [{2, 1}, {0, 2}, {1, 0}, {2, 2}, {1, 4}, {0, 6}, {1, 8}, {2, 6},
       {0, 5}, {2, 4}, {0, 3}, {1, 1}, {2, 3}, {1, 5}, {0, 7}, {1, 9}, {2, 7},
       {0, 8}, {2, 9}, {1, 7}, {0, 9}, {2, 8}, {1, 6}, {0, 4}, {2, 5}, {1, 3},
       {0, 1}, {2, 0}, {1, 2}, {0, 0}]]}

The table containing the numbers shows the sequence of moves made by the knight
to complete a closed knight's tour. The data below that shows the object
representation of the board, and the sequence of point taken (in reverse
order).

## Description

This is a basic graph search algorithm. It traverses all of the possible unique
nodes and finishes once it finds a sequence that is both long enough to be a
tour, and it is a valid move for a night to move from the last to the first
point in the sequence.

A node equals another node if the collection of empty squares is equal, and the
current positions of the knights are equal. When determining uniqueness, we
don't have to care about the sequence order of how we got to the current
position: firstly, we know the sequence of points is valid otherwise we would
not have reached the spot; and secondly, we only care about where we want to go
next.

There is a cache variable that stores 'hashes' of each node, and the solution
for it, so that we don't have too recalculate the solution if we have already
visited an equivalent node. There is no customisable hash map in Elixir/Erlang,
so there's a hash function that extracts the information we need to determine
uniqueness (described in the above paragraph) and uses that as a key in the
cache (which is a map). The 'hash' is unique for each unique node (if it were
not, then I would have had to use a bag).

## Benchmarks

This algorithm was able to solve these boards:

    |------------|---------------|
    | Board Size | Duration (ms) |
    |------------|--------------:|
    | 3x10       |         10861 |
    | 5x6        |        158489 |
    | 6x5        |        352064 |
    |------------|---------------|

It takes at least many hours to complete any other board sizes (e.g. 6x6) - I
have never been able to solve any board other than the ones above.

# Part 2

Part 2 is implemented in file `lib/part_2_kt_solver.ex` - see function
`solve`.

To run an example, open up the interactive console:

    iex -S mix test

Then run the algorithm on the size 3x10 (for example):

    Timer.bench_size(Part2KTSolver, 3, 10, true)

## Optimisations

### Pruning

These 2 pruning optimisations halved the duration of the cases in Part 1 alone.
It still was not able to complete square boards overnight (e.g. 6x6).

#### Checking end of path

If we start at the top left corner, then there are only two possible moves
({+2, +1}, and {+1, +2}). We use up one of them when we leave the corner, so we
must use the other one we come back at the very end of the closed tour.

We can easily accidentally block off that square any time during the graph
traversal, so checking this will be able to prune a large number of branches
early on.

The above solution essentially checks finds a path of size 1 away from the top
left corner To improve this further, we can check that there is a path of size
2 that we can take back to the start.

#### Checking corner paths

We can use our knowledge that there are only two possible moves from a corner,
and that we started only at one of the corners, to further optimise our
algorithm. There are three corners left that we can consider.

If we encounter a square that can move to an unvisited corner, then we must
move there. If we don't, then we will have blocked off the only possible exit
from that corner.

This technique provides a noticeable amount of pruning. A square that can move
to a corner has up to 6 moves, minus the one that we took to get to that square
- 5 left. So this technique prunes 4/5 branches for all three corners (this
excludes the starting corner because the starting corner is visited and we
start the tour).

#### Warnsdoff rule

See https://en.wikipedia.org/wiki/Knight%27s_tour#Warnsdorf.27s_rule .

This will is a heuristic for best first search. It says that we should search
the paths where there are fewer possible moves.

I implement this heuristic around line 138. This involves sorting the next
possible options by how many possible moves each involves.

There are some possible reasons why I think this works so well:

The first possible reason is that by investigating the paths with less options
first, if that path is not completable, then we are more likely to come to a
dead end because there are less possible moves available. In contrast, if we
chose the option with more possible moves, then we are less likely to come to a
dead end and so we will recurse further.

The second possible reason is that by choosing the option with a less possible
moves, we end up choosing the trickier path to solve early on. By tricky path,
an example would be trying to fill the squares along/near the edge of the board
- in such a case there will be a limited number of possible solutions. By
trying to solve this early on, we don't attempt to do it many times in the
future, saving a lot of work.

Please note that the above two paragraphs are only some ideas as to why this
works.

## Benchmarks

To compare this with the boards that were able to be completed by the
Part1KTSolver solver, these are the results for both part one and part two.

    |------------|-----------------------------|-----------------------------|
    | Board Size | Part1KTSolver Duration (ms) | Part2KTSolver Duration (ms) |
    |------------|----------------------------:|----------------------------:|
    | 3x10       |                       10861 |                        5090 |
    | 5x6        |                      158489 |                        7275 |
    | 6x5        |                      352064 |                         397 |
    |------------|-----------------------------|-----------------------------|

For the 3x10 board there is a doubling in speed; for the 5x6, it takes 1/26th
of the time; and for the 6x5, it takes 1/887th of the time.

This algorithm was able to complete square boards (it was many order of
magnitudes faster than my previous algorithm).

    |------------|------------------------------|------------------------------|
    | Board Size | Part1KTSolver Duration (ms)  | Part2KTSolver Duration (ms)  |
    |------------|------------------------------|------------------------------|
    | 6 x 6      | Some very long, unknown time | 3                            |
    | 12 x 12    | Some very long, unknown time | 25                           |
    | 18 x 18    | Some very long, unknown time | 133                          |
    | 24 x 24    | Some very long, unknown time | 322                          |
    | 30 x 30    | Some very long, unknown time | 913                          |
    | 36 x 36    | Some very long, unknown time | 1864                         |
    | 42 x 42    | Some very long, unknown time | Some very long, unknown time |
    | 48 x 48    | Some very long, unknown time | 6124                         |
    | 54 x 54    | Some very long, unknown time | 11201                        |
    | 60 x 60    | Some very long, unknown time | Some very long, unknown time |
    | 66 x 66    | Some very long, unknown time | 25648                        |
    | 72 x 72    | Some very long, unknown time | 37407                        |
    | 78 x 78    | Some very long, unknown time | 73297                        |
    | 84 x 84    | Some very long, unknown time | 73443                        |
    | 90 x 90    | Some very long, unknown time | 103175                       |
    | 96 x 96    | Some very long, unknown time | 204998                       |
    |------------|------------------------------|------------------------------|


It's hard to find a metric to precisely compare Part1KTSolver with
Part2KTSolver. Part1KTSolver is not able to complete square boards. Both
algorithms performing differently for differently shaped boards (all of the
boards in the 1st table have 30 squares on them). And only the second solver
was able to solve square boards (and very quickly I might add). All I know is
that the second solver is much, much, much faster than the first.

Oddly, there were 2 square board that the algorithm could not solve in a few
hours - n=42 and n=60. I'm not sure why these boards in particular were hard to
solve.

**TODO graphs for above (when doing part 3)**

# Part 3
