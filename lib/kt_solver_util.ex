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

  def points_to_linked_board(points = [first | the_rest])
      when is_list(points) and the_rest != nil do
    width =
      points
      |> Enum.max_by(fn {x, _} -> x end)
      |> elem(0)
      |> Kernel.+(1)
    height =
      points
      |> Enum.max_by(fn {_, y} -> y end)
      |> elem(1)
      |> Kernel.+(1)

    last = points |> List.last
    do_points_to_linked_board(
      %Board{width: width, height: height},
      last,
      first,
      the_rest,
      first
    )
  end

  def is_valid_tour(board = %Board{}, points) do
    Board.empty_points(board) == []
    and is_eulerian_tour(board, points)
  end

  def linked_board_with_nums(
    board,
    {x, y} \\ {0, 0},
    depth \\ 0,
    points \\ []
  ) do
    cell = Board.get(board, x, y)
    if cell[:num] do
      [board: board, points: points]
    else
      board
      |> Board.put(x, y, Keyword.put(cell, :num, depth))
      |> linked_board_with_nums(
        cell[:next],
        depth + 1,
        [{x, y} | points]
      )
    end
  end

  def remove_nums(board) do
    board
    |> Board.all_points
    |> Enum.reduce(board, fn {x, y}, current_board ->
      cell =
        current_board
        |> Board.get(x, y)
        |> Keyword.delete(:num)
      Board.put(current_board, x, y, cell)
    end)
  end

  defp is_eulerian_tour(_, []), do: true
  defp is_eulerian_tour(_, [_]), do: true
  defp is_eulerian_tour(board, points) do
    [first | _] = points
    last = List.last(points)
    points_in_range(first, last)
  end

  defp do_points_to_linked_board(
    board, prev, {x, y}, [], first
  ) do
    Board.put(board, x, y, [
      prev: prev,
      next: first,
    ])
  end
  defp do_points_to_linked_board(
    board, prev, curr = {x, y}, [next | points], first
  ) do
    board
    |> Board.put(x, y, [prev: prev, next: next])
    |> do_points_to_linked_board(curr, next, points, first)
  end

end
