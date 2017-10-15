defmodule Part3KTSolver do
  require Integer

  def solve(board = %Board{width: width, height: height})
      when width != height do
    raise ArgumentError, "Board is not square #{inspect board}"
  end

  def solve(board = %Board{}) do
    :no_closed_tour_found
  end

  def split_board(width, height)
      when width > height
      or Integer.is_odd(width)
      or Integer.is_odd(height)
      or width < 10
      or height < 10
      or height - width not in [0, 2],
    do: raise ArgumentError, "Invalid board of w: #{width}, h: #{height}"
  def split_board(width, height) when width == height do
    half_width = round(width / 2)
    half_height = round(height / 2)

    four_sub_boards(half_width, half_width, half_height, half_height)
  end
  def split_board(width, height) when rem(width, 4) > 0 do
    # width / 2 is odd
    # height / 2 must be even
    w1 = Integer.floor_div(width, 2) - 1
    w2 = Integer.floor_div(width, 2) + 1
    h = Integer.floor_div(height, 2)
    four_sub_boards(w1, w2, h, h)
  end
  def split_board(width, height) when rem(width, 4) == 0 do
    # width / 2 is even
    # height / 2 must be odd
    w = Integer.floor_div(width, 2)
    h1 = Integer.floor_div(height, 2) - 1
    h2 = Integer.floor_div(height, 2) + 1
    four_sub_boards(w, w, h1, h2)
  end

  def four_sub_boards(w1, w2, h1, h2) do
    [
      {0, 0, w1, h1},
      {w1, 0, w2, h1},
      {0, h1, w1, h2},
      {w1, h1, w2, h2},
    ]
  end

end
