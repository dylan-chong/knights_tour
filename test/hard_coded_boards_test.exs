defmodule HardCodedBoardsTest do
  use ExUnit.Case, async: true
  doctest HardCodedBoards

  test "for_size(6, 6) is valid" do
    assert_valid_size({6, 6})
  end

  test "for_size is valid for all sizes" do
    HardCodedBoards.all
    |> Map.keys
    |> Enum.each(&HardCodedBoards.for_size/1)
  end

  defp assert_valid_size(size) do
    board =
      HardCodedBoards.for_size(size)
      |> KTSolverUtil.points_to_linked_board
      |> KTSolverUtil.linked_board_with_nums

    board
    |> Board.all_points
    |> Enum.each(fn {x, y} ->
      assert Board.get(board, x, y)[:num] != nil
    end)
  end

end
