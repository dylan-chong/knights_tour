---
title: Assignment 4 for COMP 361
author:
    - Dylan Chong (Student ID - 300373593)
date: \today{}
---

# Installation

Firstly, install Elixir from here: https://elixir-lang.org/install.html .

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

Because this algorithm can only solve 3 boards (in a reasonable amount of
time), there is no point having a graph here.

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
    | Board Size | Part1KTSolver Duration (ms)  |  Part2KTSolver Duration (ms) |
    |------------|------------------------------|-----------------------------:|
    | 6 x 6      | Some very long, unknown time |                            3 |
    | 12 x 12    | Some very long, unknown time |                           25 |
    | 18 x 18    | Some very long, unknown time |                          133 |
    | 24 x 24    | Some very long, unknown time |                          322 |
    | 30 x 30    | Some very long, unknown time |                          913 |
    | 36 x 36    | Some very long, unknown time |                         1864 |
    | 42 x 42    | Some very long, unknown time | Some very long, unknown time |
    | 48 x 48    | Some very long, unknown time |                         6124 |
    | 54 x 54    | Some very long, unknown time |                        11201 |
    | 60 x 60    | Some very long, unknown time | Some very long, unknown time |
    | 66 x 66    | Some very long, unknown time |                        25648 |
    | 72 x 72    | Some very long, unknown time |                        37407 |
    | 78 x 78    | Some very long, unknown time |                        73297 |
    | 84 x 84    | Some very long, unknown time |                        73443 |
    | 90 x 90    | Some very long, unknown time |                       103175 |
    | 96 x 96    | Some very long, unknown time |                       204998 |
    |------------|------------------------------|------------------------------|

See page 1 of `./assignment-4-graphs.pdf` for a graphical chart of the above
table.

It's hard to find a metric to precisely compare Part1KTSolver with
Part2KTSolver. Part1KTSolver is not able to complete square boards. Both
algorithms performing differently for differently shaped boards (all of the
boards in the 1st table have 30 squares on them). And only the second solver
was able to solve square boards (and very quickly I might add). All I know is
that the second solver is much, much, much faster than the first.

Oddly, there were 2 square board that the algorithm could not solve in a few
hours - n=42 and n=60. I'm not sure why these boards in particular were hard to
solve.

# Part 3

NOTE: The report part of this assignment has been dispersed throught all 3
parts of this document.

Part 3 is implemented in file `lib/part_3_kt_solver.ex` - see function `solve`.

To run an example, open up the interactive console:

    iex -S mix test

Then run the algorithm on the size 6x6 (for example):

    Timer.bench_size(Part3KTSolver, 3, 10, true)

NOTE: Part3KTSolver does not work on boards smaller than 6x6, and only works on
square boards with an even widths and heights.

The Parberry algorithm, in essesence, divides the board into four quadrants
(each of a even width and height), recursively solving them, and using a
hard-coded set of structured boards as base cases. The sub-boards are then
joined by taking advantage of certain edges in structred boards. The algorithm
I implemented follows this exactly.

## Benchmarks

The Parberry algorithm is very fast, as expected, as it does not do any
extremely expensive operation like the graph algorithms do (in part 1 and part
2).

However, my implementation still ran in polynomial time, likely because of the
immutability in Elixir. Let's say I have the 4 sub-solutions. My implementation
needs to copy these to a new board (`n^2` points to copy), but because you can
only add one item to the board at a time, and each board is immutable, `n^2`
copies of the board are made (in the worst case, assuming that the compiler or
Elixir/Erlang runtime does not optimise this). This leads to a `n^4`
complexity.

    |--------------|--------------------------------|-------------------------------|
    | Board Size   |    Part2KTSolver Duration (ms) |   Part3KTSolver Duration (ms) |
    |--------------|-------------------------------:|------------------------------:|
    | 6 x 6        |                              3 |                             0 |
    | 12 x 12      |                             25 |                             1 |
    | 18 x 18      |                            133 |                             2 |
    | 24 x 24      |                            322 |                             7 |
    | 30 x 30      |                            913 |                            12 |
    | 36 x 36      |                           1864 |                            21 |
    | 42 x 42      |   Some very long, unknown time |                            39 |
    | 48 x 48      |                           6124 |                            48 |
    | 54 x 54      |                          11201 |                            61 |
    | 60 x 60      |   Some very long, unknown time |                            78 |
    | 66 x 66      |                          25648 |                            98 |
    | 72 x 72      |                          37407 |                           109 |
    | 78 x 78      |                          73297 |                           131 |
    | 84 x 84      |                          73443 |                           167 |
    | 90 x 90      |                         103175 |                           209 |
    | 96 x 96      |                         204998 |                           271 |
    | 102 x 102    |   Some very long, unknown time |                           282 |
    | 108 x 108    |   Some very long, unknown time |                           305 |
    | 114 x 114    |   Some very long, unknown time |                           339 |
    | 120 x 120    |   Some very long, unknown time |                           367 |
    | 126 x 126    |   Some very long, unknown time |                           410 |
    | 132 x 132    |   Some very long, unknown time |                           456 |
    | 138 x 138    |   Some very long, unknown time |                           499 |
    | 144 x 144    |   Some very long, unknown time |                           527 |
    | ------------ | ------------------------------ | ----------------------------- |

See page 2 and page 3 of `./assignment-4-graphs.pdf` for a graphical chart of the above
table. Page 2 contains just the data for Part3KTSolver, and page 3 contains a
comparison of Part2KTSolver and Part3KTSolver on a log scale. Part3KTSolver
has a massive improvement over Part2KTSolver.
