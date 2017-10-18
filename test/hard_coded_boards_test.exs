defmodule HardCodedBoardsTest do
  use ExUnit.Case, async: true
  doctest HardCodedBoards

  test "for_size(6, 6) is valid" do
    assert_valid_size({6, 6})
  end

  test "for_size is valid for all non-rotated sizes" do
    HardCodedBoards.all
    |> Map.keys
    |> Enum.each(&assert_valid_size/1)
  end

  test "for_size is valid for all rotated sizes" do
    HardCodedBoards.all
    |> Map.keys
    |> Enum.map(fn wxh -> String.split(wxh, "x") end)
    |> Enum.map(fn [w, h] -> "#{h}x#{w}" end)
    |> Enum.each(&assert_valid_size/1)
  end

  defp assert_valid_size(size) do
    board =
      HardCodedBoards.for_size(size)
      |> KTSolverUtil.points_to_linked_board
      |> KTSolverUtil.linked_board_with_nums
      |> Keyword.fetch!(:board)

    # IO.puts ""
    # board
    # |> Board.to_string(fn cell -> cell[:num] end)
    # |> IO.puts

    board
    |> Board.all_points
    |> Enum.each(fn {x, y} ->
      assert Board.get(board, x, y)[:num] != nil
    end)
  end

end
