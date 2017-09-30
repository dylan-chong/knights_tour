defmodule Part1KTSolverTest do
  use ExUnit.Case
  doctest Part1KTSolver

  test "solve returns single item for tiny board" do
    [board: board, points: points] =
      %Board{width: 1, height: 1}
      |> Part1KTSolver.solve()

    assert board |> Board.get(0, 0) == 0
    assert points == [{0, 0}]
    assert KTSolverUtil.is_valid_tour(board, points)
  end

  test "solve returns nil for an impossible-to-solve 2x2 board" do
    assert Part1KTSolver.solve(%Board{width: 2, height: 2}) == nil
  end

  test "solve returns nil for an impossible-to-solve 3x3 board" do
    assert Part1KTSolver.solve(%Board{width: 3, height: 3}) == nil
  end

  test "solve succeeds for a hack 3x3" do
    [board: board, points: points] =
      %Board{width: 3, height: 3}
      |> Board.put(1, 1, -1)
      |> Part1KTSolver.solve()

    assert KTSolverUtil.is_valid_tour(board, points)
  end

  test "solve succeeds for a 5x6" do
    [board: board, points: points] =
      %Board{width: 5, height: 6} |> Part1KTSolver.solve()

    assert KTSolverUtil.is_valid_tour(board, points)
  end

end
