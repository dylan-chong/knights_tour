defmodule Part1KTSolver do

  ## Part1KTSolver.solve(%Board{width: 5, height: 5})[:board] |> Board.to_string |> IO.puts

  def solve(board = %Board{}) do
    # TODO
    # cache =

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
    t1 = :erlang.system_time / 1.0e6 |> round
    h = hash(board, points)
    cache
    |> :ets.lookup(h)
    |> case do
      [{_h, result} | _] ->
        t2 = :erlang.system_time / 1.0e6 |> round
        #        IO.write "C#{t2 - t1}"
        result
      [] ->
        t2 = :erlang.system_time / 1.0e6 |> round
        #        IO.write "C#{t2 - t1}"
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

  # TODO AFTER does 5x6 pass?
  # TODO Tidy print

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
      IO.inspect {"success", points}
      [board: board, points: points]
    else
      # Not a Eulerian tour
      IO.write "E"
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
      IO.write "D"
      nil # Dead end
    else
      #IO.inspect {"valid moves", valid_moves}
      valid_moves
      |> Enum.find_value(fn {dx, dy} ->
        next_x = x + dx
        next_y = y + dy
        next_board = Board.put(board, next_x, next_y, depth)
        next_points = [{next_x, next_y} | points]

        #IO.inspect {"finding another at depth: #{depth}"}
        solve_with_cache(
          next_board,
          next_points,
          depth + 1,
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
