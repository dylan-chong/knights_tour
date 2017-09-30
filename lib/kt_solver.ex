defprotocol KTSolver do
  @moduledoc "A Knights Tour solver"

  def solve(board, start_x, start_y)

end

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
    |> Enum.filter(
      fn {dx, dy} ->
        Board.is_valid_point(
          board,
          start_x + dx,
          start_y + dy
        ) and
        Board.get(
          board,
          start_x + dx,
          start_y + dy
        ) == nil
      end
    )
  end

  def is_valid_tour(board = %Board{}, points) do
    unused_points =
      for x <- 0..board.width - 1,
          y <- 0..board.height - 1,
          Board.get(board, x, y) == nil,
          do: {x, y}

    unused_points == []
  end

  # def is_valid_next_move(board = %Board{}, []) do

  # end

  # def is_valid_next_move(board = %Board{}, [last_point]) do

  # end

  # def is_valid_next_move(board = %Board{}, [first_point | points]) do

  # end

end
