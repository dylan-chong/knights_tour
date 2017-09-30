defmodule Part1KTSolver do

  # Part1KTSolver.solve(%Board{width: 5, height: 5})[:board] |> Board.to_string |> IO.puts

  def solve(board = %Board{}) do
    # TODO
    # cache =

    empty_points = board |> Board.empty_points
    number_empty_points = empty_points |> length

    empty_points
    |> Enum.find_value(fn {x, y} ->
      solve(board, [], 0, x, y, number_empty_points)
    end)
  end

  defp solve(board=%Board{}, points, depth, x, y, original_empty_points) do
    # Generate solution in reverse order
    Board.require_valid_point(board, x, y)

    next_board = Board.put(board, x, y, depth)
    next_points = [point = {x, y} | points]

    if depth == original_empty_points - 1 do
      # We have reached the end of the tour
      start_point = List.last(next_points)

      if length(next_points) == 1 or
          KTSolverUtil.points_in_range(start_point, point) do
        [board: next_board, points: next_points]
      else
        # Not a Eulerian tour
        nil
      end
    else
      # We haven't reached the end of the tour
      valid_moves = KTSolverUtil.valid_moves(board, x, y)

      if valid_moves == [] do
        nil # Incomplete tour
      else
        valid_moves
        |> Enum.find_value(fn {dx, dy} -> solve(
          next_board,
          next_points,
          depth + 1,
          x + dx,
          y + dy,
          original_empty_points
        ) end)
      end
    end
  end

end
