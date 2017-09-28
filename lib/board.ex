defmodule Board do
  @moduledoc """
  A Chess Board
  """

  @enforce_keys [:width, :height]
  defstruct [:width, :height, map: %{}]

  def put(board = %Board{}, x, y, item) do
    require_valid_range(board, x, y)

    %Board{board |
      map: board.map |> Map.put(
        {x, y}, item
      )
    }
  end

  def get(board = %Board{}, x, y) do
    require_valid_range(board, x, y)
    board.map[{x, y}]
  end

  def to_string(board = %Board{}) do
    (
      for y <- 0..board.width - 1,
      do: Enum.join([
        row_to_string(board, y),
        edge_row(board),
      ], "\n")
    )
    |> List.insert_at(0, edge_row(board))
    |> Enum.join("\n")
  end

  defp edge_row(%Board{width: width}) do
    (for _ <- 0..width - 1, do: "-----+")
    |> List.insert_at(0, "+")
    |> Enum.join("")
  end

  defp row_to_string(board = %Board{}, y) do
    (
      for x <- 0..board.width - 1,
      do: String.pad_trailing(
        " #{board |> Board.get(x, y)}",
        5
      )
      |> Kernel.<>("|")
    )
    |> List.insert_at(0, "|")
    |> Enum.join("")
  end

  defp require_valid_range(%Board{width: width, height: height}, x, y)
      when x not in 0..width - 1
      or y not in 0..height - 1
  do
    raise ArgumentError, message: "Position out of bounds: {#{x}, #{y}}"
  end

  defp require_valid_range(_, _, _) do
    # Range is valid
  end

end
