defmodule KTSolverUtil do

  # Knight move {dx, dy} distances
  def possible_moves do
    [
      # Right (top, going down)
      {1, 2},
      {2, 1},
      {2, -1},
      {1, -2},
      # Left (top, going down)
      {-1, 2},
      {-2, 1},
      {-2, -1},
      {-1, -2},
    ]
  end

  def valid_moves(board = %Board{}, start_x, start_y) do
    possible_moves()
    |> Enum.filter(fn {dx, dy} ->
      Board.is_valid_point(board, start_x + dx, start_y + dy)
      and
      Board.get(board, start_x + dx, start_y + dy) == nil
    end)
  end

  def points_in_range({x1, y1}, {x2, y2}) do
    possible_moves()
    |> Enum.any?(fn {dx, dy} ->
      x1 + dx == x2 and
      y1 + dy == y2
    end)
  end

  def is_valid_tour(board = %Board{}, points) do
    Board.empty_points(board) == []
    and is_eulerian_tour(board, points)
  end

  defp is_eulerian_tour(_, []), do: true
  defp is_eulerian_tour(_, [_]), do: true
  defp is_eulerian_tour(board, points) do
    [first | _] = points
    last = List.last(points)
    points_in_range(first, last)
  end

end
