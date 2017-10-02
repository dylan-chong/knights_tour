defmodule Solvers do
  def solvers, do: [{Part1KTSolver}, {Part2KTSolver}]
end

defmodule Part1KTSolverTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  doctest Part1KTSolver
  doctest Part2KTSolver

  test_with_params "solve returns single item for tiny board",
  fn solver ->
    [board: board, points: points] =
      %Board{width: 1, height: 1}
      |> solver.solve()

    assert board |> Board.get(0, 0) == 0
    assert points == [{0, 0}]
    assert KTSolverUtil.is_valid_tour(board, points)
  end, do: Solvers.solvers()

  test_with_params "solve fails for an impossible-to-solve 2x2 board",
  fn solver ->
    solution =
      %Board{width: 2, height: 2}
      |> solver.solve()
    assert solution == :no_closed_tour_found
  end, do: Solvers.solvers()

  test_with_params "solve fails for an impossible-to-solve 3x3 board",
  fn solver ->
    solution =
      %Board{width: 3, height: 3}
      |> solver.solve()
    assert solution == :no_closed_tour_found
  end, do: Solvers.solvers()

  test_with_params "solve succeeds for a hack 3x3",
  fn solver ->
    [board: board, points: points] =
      %Board{width: 3, height: 3}
      |> Board.put(1, 1, -1)
      |> solver.solve()

    assert KTSolverUtil.is_valid_tour(board, points)
  end, do: Solvers.solvers()

  test_with_params "solve succeeds for a 3x10",
  fn solver ->
    [board: board, points: points] =
      %Board{width: 3, height: 10} |> solver.solve()

    assert KTSolverUtil.is_valid_tour(board, points)
  end, do: Solvers.solvers()

  # test_with_params "solve succeeds for a 5x6",
  # fn solver ->
    # [board: board, points: points] =
      # %Board{width: 5, height: 6} |> solver.solve()

    # assert KTSolverUtil.is_valid_tour(board, points)
  # end, do: Solvers.solvers()

end
