defmodule Rectangle do
  # import Part3KTSolver
  @enforce_keys [:x, :y, :w, :h]
  defstruct [:x, :y, :w, :h]

  def of({x, y, w, h}) do
    %Rectangle{x: x, y: y, w: w, h: h}
  end
end

defmodule Part3KTSolver do
  require Integer

  def solve(board = %Board{}) do
    board
    |> do_solve
    |> KTSolverUtil.linked_board_with_nums
  end

  defp do_solve(%Board{width: width, height: height})
      when width <= 10 and height <= 12 do
    {width, height}
    |> HardCodedBoards.for_size
    |> KTSolverUtil.points_to_linked_board
  end
  defp do_solve(%Board{width: width, height: height}) do
    split_board(width, height)
    |> Enum.map(&Rectangle.of/1)
    |> Enum.map(&rectangle_to_solved_board/1)
    |> join_boards
  end

  defp rectangle_to_solved_board(r = %Rectangle{}) do
    %Board{width: r.w, height: r.h}
    |> Part3KTSolver.solve
    |> Keyword.fetch!(:board)
    |> KTSolverUtil.remove_nums
  end

  defp join_boards(boards) do
    [tl_board, tr_board, bl_board, br_board] = boards

    # Points used for joining, clockwise order
    w1 = tl_board.width
    h1 = tl_board.height
    points = [
      tl_1 = {w1 - 3, h1 - 1},
      tl_2 = {w1 - 1, h1 - 2},
      tr_1 = {w1 + 1, h1 - 3},
      tr_2 = {w1, h1 - 1},
      br_1 = {w1 + 2, h1},
      br_2 = {w1, h1 + 1},
      bl_1 = {w1 - 2, h1 + 2},
      bl_2 = {w1 - 1, h1}
    ]
    %Board{
      width: tl_board.width + tr_board.width,
      height: tl_board.height + bl_board.height,
    }
    # TODO NEXT get this working
    # |> Enum.reduce(
      # %Board{
        # width: tl_rect.w + tr_rect.w,
        # height: tl_rect.h + bl_rect.h,
      # },
      # fn {x, y}, b ->
        # b |> Board.put(x, y, 1)
      # end
    # )
    # |> Board.to_string
    # |> IO.puts
  end

  # def connect_points({board_a, board_b}, {ax, ay}, {bx, by}) do
    # {}
  # end

  def split_board(width, height)
      when width > height
      or Integer.is_odd(width)
      or Integer.is_odd(height)
      or width < 10
      or height < 12
      or height - width not in [0, 2],
    do: raise ArgumentError,
      "Invalid board of w: #{width}, h: #{height}"
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
