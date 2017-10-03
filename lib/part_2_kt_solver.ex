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
    {start_x, start_y} = List.last(points)

    board
    |> KTSolverUtil.valid_moves(start_x, start_y)
    |> case do
      [] ->
        # We have blocked off the path back to the start
        false
      valid_moves ->
        Enum.any?(valid_moves, fn {x, y} ->
          board
          |> KTSolverUtil.valid_moves(x, y)
          |> length()
          |> Kernel.>=(1)
        end)
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
      |> KTSolverUtil.valid_moves(x, y)
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

  defp hash(board, points) do
    {Board.empty_points(board), List.first(points)}
  end

end
