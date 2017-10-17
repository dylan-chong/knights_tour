defmodule KTSolverUtilTest do
  use ExUnit.Case, async: true
  doctest Board

  test "valid_moves when all moves are valid" do
    valid_moves =
      %Board{width: 5, height: 5}
      |> KTSolverUtil.valid_moves(2, 2)

    assert valid_moves == KTSolverUtil.possible_moves()
  end

  test "valid_moves when no moves are valid" do
    valid_moves =
      %Board{width: 3, height: 3}
      |> KTSolverUtil.valid_moves(1, 1)

    assert valid_moves == []
  end

  test "is_valid_tour returns false for a tour with a missing point" do
    [_ | points] = for x <- 0..2, y <- 0..2, do: {x, y}

    board = Enum.reduce(
      points,
      %Board{width: 3, height: 3},
      fn {x, y}, b -> Board.put(b, x, y, 0) end
    )

    refute KTSolverUtil.is_valid_tour(board, points)
  end

  test "points_in_range returns true" do
    assert KTSolverUtil.points_in_range({4, 1}, {6, 0})
  end

  test "points_in_range returns false" do
    refute KTSolverUtil.points_in_range({4, 0}, {6, 0})
  end

  test "points_to_linked_board for simple board" do
    linked_board = KTSolverUtil.points_to_linked_board([
      {1, 0},
      {2, 1},
      {3, 2},
    ])
    expected_board =
      %Board{width: 4, height: 3}
      |> Board.put(1, 0, [prev: {3, 2}, next: {2, 1}])
      |> Board.put(2, 1, [prev: {1, 0}, next: {3, 2}])
      |> Board.put(3, 2, [prev: {2, 1}, next: {1, 0}])
    assert expected_board == linked_board
  end

  test "linked_board_with_nums assigns a number to all cells" do
    board =
      Part2KTSolver.solve(%Board{width: 6, height: 6})
      |> Keyword.fetch!(:points)
      |> KTSolverUtil.points_to_linked_board
      |> KTSolverUtil.linked_board_with_nums
      |> Keyword.fetch!(:board)

    board
    |> Board.all_points
    |> Enum.each(fn {x, y} ->
      assert Board.get(board, x, y)[:num] != nil
    end)
  end

end
