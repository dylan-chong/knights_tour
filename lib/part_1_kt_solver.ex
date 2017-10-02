defmodule Part1KTSolver do

  # r = [board: board, points: points] = %Board{width: 5, height: 6} |> Part1KTSolver.solve()

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
    )

    :ets.delete(cache)
    result
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
    x,
    y,
    original_empty_points,
    cache
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
    valid_moves = KTSolverUtil.valid_moves(board, x, y)

    if valid_moves == [] do
      nil # Dead end
    else
      valid_moves
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
