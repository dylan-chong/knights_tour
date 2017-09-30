defmodule Part1KTSolver do

  # Part1KTSolver.solve(%Board{width: 5, height: 5})[:board] |> Board.to_string |> IO.puts

  def solve(board = %Board{}) do
    # TODO
    # cache =

    board
    |> Board.empty_points()
    |> Enum.find_value(
      fn {x, y} -> solve(board, [], 0, x, y) end
    )
  end

  def solve(board=%Board{}, points, depth, start_x, start_y) do
    Board.require_valid_point(board, start_x, start_y)

    next_board = Board.put(board, start_x, start_y, depth)
    next_points = [{start_x, start_y} | points]

    if depth == board.width * board.height - 1 do
      # We have reached the end of the tour
      [board: next_board, points: next_points]
      # TODO make sure the end is the start
    else
      # We haven't reached the end of the tour
      valid_moves = KTSolverUtil.valid_moves(board, start_x, start_y)

      if valid_moves == [] do
        nil # Incomplete tour
      else
        valid_moves
        |> Enum.find_value(fn {dx, dy} -> solve(
          next_board,
          next_points,
          depth + 1,
          start_x + dx,
          start_y + dy
        ) end)
      end
    end
  end

end
