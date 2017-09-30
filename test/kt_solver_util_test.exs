defmodule KTSolverUtilTest do
  use ExUnit.Case
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

  test "is_valid_tour returns true for full tour" do
    points = for x <- 0..2, y <- 0..2, do: {x, y}

    board = Enum.reduce(
      points,
      %Board{width: 3, height: 3},
      fn {x, y}, b -> Board.put(b, x, y, 0) end
    )

    assert KTSolverUtil.is_valid_tour(board, points)
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
end
