defmodule Part2KTSolver do

  def solve(board = %Board{}) do
    empty_points = board |> Board.empty_points
    number_empty_points = empty_points |> length

    {x, y} =
      empty_points
      |> Enum.fetch!(0) # OK since we are finding a closed tour

    cache = :ets.new(:cache, [])

    result = solve_with_cache(
      Board.put(board, x, y, 0),
      [{x, y}],
      0,
      x,
      y,
      number_empty_points,
      cache
    ) || :no_closed_tour_found

    :ets.delete(cache)
    result
  end

  def can_finish_tour(_, _, depth, original_empty_points)
      when depth > original_empty_points - 3, do: true

  def can_finish_tour(board, points, _, _) do
    start_point = List.last(points)
    can_return_to_start(board, start_point)
  end

  defp can_return_to_start(board, {start_x, start_y}) do
    board
    |> KTSolverUtil.valid_moves(start_x, start_y)
    |> case do
      [] ->
        # We have blocked off the path back to the start
        false
      valid_moves ->
        true
        # Check if there is a valid move to a valid move.
        # This is faster for skinny boards but slower for square boards
        # Enum.any?(valid_moves, fn {x, y} ->
          # board
          # |> KTSolverUtil.valid_moves(x, y)
          # |> length()
          # |> Kernel.>=(1)
        # end)
    end
  end

  defp solve_with_cache(
    board,
    points,
    depth,
    x,
    y,
    original_empty_points,
    cache
  ) do
    h = hash(board, points)

    cache
    |> :ets.lookup(h)
    |> case do
      [{_h, result} | _] ->
        result
      [] ->
        result = solve(
          board,
          points,
          depth,
          x,
          y,
          original_empty_points,
          cache
        )
        :ets.insert(cache, {h, result})
        result
    end
  end

  defp solve(
    board,
    points,
    depth,
    _x,
    _y,
    original_empty_points,
    _cache
  ) when depth == original_empty_points - 1 do
    # We have reached the end of the tour
    start_point = List.last(points)
    last_point = List.first(points)

    if length(points) <= 1 or
        KTSolverUtil.points_in_range(start_point, last_point) do
      [board: board, points: points]
    else
      # Not a Eulerian tour
      nil
    end
  end

  defp solve(
    board,
    points,
    depth,
    x,
    y,
    original_empty_points,
    cache
  ) do
    if not can_finish_tour(board, points, depth, original_empty_points) do
      nil
    else
      # Returns nil when there are no valid moves
      board
      |> valid_moves(x, y)
      |> Enum.find_value(fn {dx, dy} ->
        next_x = x + dx
        next_y = y + dy
        next_depth = depth + 1
        next_board = Board.put(board, next_x, next_y, next_depth)
        next_points = [{next_x, next_y} | points]

        solve_with_cache(
          next_board,
          next_points,
          next_depth,
          next_x,
          next_y,
          original_empty_points,
          cache
        )
      end)
    end
  end

  defp valid_moves(board, x, y) do
    moves = KTSolverUtil.valid_moves(board, x, y) |> MapSet.new
    corners = Board.corner_points(board) |> MapSet.new

    # Array of 0 or 1
    corner_moves = MapSet.intersection(moves, corners)

    # If we can move to a corner we have to move to it,
    # otherwise we will block the entrance or exit to the corner.
    if corner_moves == [] do
      [corner_moves]
    else
      moves
    end
  end

  defp hash(board, points) do
    {Board.empty_points(board), List.first(points)}
  end

end
