---
title: Assignment 4 for COMP 361
author:
    - Dylan Chong (Student ID - 300373593)
date: \today{}
---

# Installation

Firstly install Elixir [from here](https://elixir-lang.org/install.html).

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

Then run the algorithm on the size 3x10:

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
    | 9 | 14 | 11 |
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

## Description

This is a basic

## Benchmarks

This algorithm was able to solve these boards:

    |------------|---------------|
    | Board Size | Duration (ms) |
    |------------|---------------|
    | 3x10       | 10,861        |
    | 5x6        | 158,489       |
    | 6x5        | 352,064       |
    |------------|---------------|

It takes at least many hours to complete any other board sizes (e.g. 6x6) - I
have never been able to solve any board other than the ones above.

# Part 2

Part 2 is implemented in file `lib/part_2_kt_solver.ex` - see function
`solve`.

To run an example, open up the interactive console:

    iex -S mix test

## Optimisations

### Pruning

#### Checking end of path

#### Checking corner paths

#### Warnsdoff rule

See https://en.wikipedia.org/wiki/Knight%27s_tour#Warnsdorf.27s_rule
