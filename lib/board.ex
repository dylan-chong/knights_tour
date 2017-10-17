defmodule Board do
  @moduledoc """
  A Chess Board
  """

  @enforce_keys [:width, :height]
  defstruct [:width, :height, map: %{}]

  def put(board = %Board{}, x, y, item) do
    require_valid_point(board, x, y)

    %Board{board |
      map: board.map |> Map.put(
        {x, y}, item
      )
    }
  end

  def get(board = %Board{}, x, y) do
    require_valid_point(board, x, y)
    board.map[{x, y}]
  end

  def all_points(board) do
    Map.keys(board.map)
  end

  def all_points_to_cells(board) do
    Map.to_list(board.map)
  end

  def to_string(
    board = %Board{},
    stringifier \\ (fn cell -> "#{cell}" end),
    cell_width \\ 5
  ) do
    (
      for y <- 0..board.height - 1,
      do: Enum.join([
        row_to_string(board, y, stringifier, cell_width),
        edge_row(board, cell_width),
      ], "\n")
    )
    |> List.insert_at(0, edge_row(board, cell_width))
    |> Enum.join("\n")
  end

  def empty_points(board = %Board{}) do
    for x <- 0..board.width - 1,
        y <- 0..board.height - 1,
        Board.get(board, x, y) == nil,
        do: {x, y}
  end

  def empty_bounds(board = %Board{}) do
    board
    |> empty_points
    |> Enum.reduce(
      {board.width, board.height, 0, 0},
      fn {x, y}, {left, top, right, bottom} ->
        {
          min(left, x),
          min(top, y),
          max(right, x + 1),
          max(bottom, y + 1),
        }
      end
    )
  end

  def corner_points(board = %Board{}) do
    [
      {0, 0},
      {board.width - 1, 0},
      {board.width - 1, board.height - 1},
      {0, board.height - 1},
    ]
  end

  def is_valid_point(%Board{width: width, height: height}, x, y) do
    x in 0..width - 1 and y in 0..height - 1
  end

  def require_valid_point(board = %Board{}, x, y) do
    if not is_valid_point(board, x, y) do
      raise ArgumentError, message: "Position out of bounds: {#{x}, #{y}}"
    end
  end

  defp edge_row(%Board{width: width}, cell_width) do
    (for _ <- 0..width - 1 do
      String.pad_leading("+", cell_width + 1, "-")
    end)
    |> List.insert_at(0, "+")
    |> Enum.join("")
  end

  defp row_to_string(board = %Board{}, y, stringifier, cell_width) do
    (
      for x <- 0..board.width - 1,
      do: String.pad_trailing(
        " #{board |> Board.get(x, y) |> stringifier.()}",
        cell_width
      )
      |> Kernel.<>("|")
    )
    |> List.insert_at(0, "|")
    |> Enum.join("")
  end

end
