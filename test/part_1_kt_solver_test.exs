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

  # TODO NEXT checks solve method for a slightly larger board

end
