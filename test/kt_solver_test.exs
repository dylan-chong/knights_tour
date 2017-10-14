defmodule Solvers do
  def solvers do
    [
      # {Part1KTSolver},
      # {Part2KTSolver},
      {Part3KTSolver},
    ]
  end
end

defmodule KTSolverTest do
  use ExUnit.Case, async: true
  use ExUnit.Parameterized
  doctest Part1KTSolver
  doctest Part2KTSolver
  doctest Part3KTSolver

  test_with_params "solve returns single item for tiny board",
  fn solver ->
    [board: board, points: points] =
      %Board{width: 1, height: 1}
      |> solver.solve()

    assert board |> Board.get(0, 0) == 0
    assert points == [{0, 0}]
    assert KTSolverUtil.is_valid_tour(board, points)
  end, do: Solvers.solvers()

  test_with_params "solve fails for an impossible 2x2 board",
  fn solver ->
    solution =
      %Board{width: 2, height: 2}
      |> solver.solve()
    assert solution == :no_closed_tour_found
  end, do: Solvers.solvers()

  test_with_params "solve fails for an impossible 3x3 board",
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

  # test_with_params "solve succeeds for a 3x10",
  # fn solver ->
    # [board: board, points: points] =
      # %Board{width: 3, height: 10} |> solver.solve()

    # assert KTSolverUtil.is_valid_tour(board, points)
  # end, do: Solvers.solvers()

  test_with_params "solve succeeds for a 6x6",
  fn solver ->
    [board: board, points: points] =
      %Board{width: 6, height: 6} |> solver.solve()

    assert KTSolverUtil.is_valid_tour(board, points)
  end, do: Solvers.solvers()

  test_with_params "solve succeeds for a 6x5",
  fn solver ->
    [board: board, points: points] =
      %Board{width: 6, height: 5} |> solver.solve()

    assert KTSolverUtil.is_valid_tour(board, points)
  end do
    Solvers.solvers()
    |> Enum.filter(fn s -> s != Part3KTSolver end)
  end

  test_with_params "solve succeeds for a 6x8",
  fn solver ->
    [board: board, points: points] =
      %Board{width: 6, height: 8} |> solver.solve()

    assert KTSolverUtil.is_valid_tour(board, points)
  end, do: Solvers.solvers()
  test "can_finish_tour returns false when there is no path back" do
    points = [
      # x--
      # --x
      # -x-
      # Pretend we have been here to block the possible
      # return path
      {1, 2},
      # Path out of the starting square (top left)
      {2, 1},
      {0, 0}
    ]

    board = Enum.reduce(
      points,
      %Board{width: 3, height: 3},
      fn {x, y}, board -> Board.put(board, x, y, 0) end
    )

    refute Part2KTSolver.can_finish_tour(board, points, 3, 9)
  end

  test "can_finish_tour returns true when there is a path back" do
    points = [
      # x--
      # --x
      # ---
      # Path out of the starting square (top left)
      {2, 1},
      {0, 0}
    ]

    board = Enum.reduce(
      points,
      %Board{width: 3, height: 3},
      fn {x, y}, board -> Board.put(board, x, y, 0) end
    )

    assert Part2KTSolver.can_finish_tour(board, points, 1, 9)
  end

  test "split_board returns valid split for 12x12" do
    expected_sub_boards = MapSet.new [
      {0, 0, 6, 6},
      {0, 6, 6, 6},
      {6, 0, 6, 6},
      {6, 6, 6, 6},
    ]
    sub_boards =
      Part3KTSolver.split_board(12, 12)
      |> MapSet.new
    assert expected_sub_boards == sub_boards
  end

  test "split_board returns valid split for 12x14" do
    expected_sub_boards = MapSet.new [
      {0, 0, 6, 6},
      {6, 0, 6, 6},
      {0, 6, 6, 8},
      {6, 6, 6, 8},
    ]
    sub_boards =
      Part3KTSolver.split_board(12, 14)
      |> MapSet.new
    assert expected_sub_boards == sub_boards
  end

  test "split_board returns valid split for 14x16" do
    expected_sub_boards = MapSet.new [
      {0, 0, 6, 8},
      {6, 0, 8, 8},
      {0, 8, 6, 8},
      {6, 8, 8, 8},
    ]
    sub_boards =
      Part3KTSolver.split_board(14, 16)
      |> MapSet.new
    assert expected_sub_boards == sub_boards
  end

  test "split_board returns valid split for 16x18" do
    expected_sub_boards =
      Part3KTSolver.four_sub_boards(8, 8, 8, 10)
      |> MapSet.new
    sub_boards =
      Part3KTSolver.split_board(16, 18)
      |> MapSet.new
    assert expected_sub_boards == sub_boards
  end

  test "split_board returns valid split for 18x20" do
    expected_sub_boards =
      Part3KTSolver.four_sub_boards(8, 10, 10, 10)
      |> MapSet.new
    sub_boards =
      Part3KTSolver.split_board(18, 20)
      |> MapSet.new
    assert expected_sub_boards == sub_boards
  end


end
