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
    # [tl_board, tr_board, bl_board, br_board] = boards
    tl_board = hd(boards)

    # anchor_points = make_anchor_points(tl_board)
    w1 = tl_board.width
    h1 = tl_board.height
    anchor_points = [
      [board_index: 0, point: tl_1 = {w1 - 3, h1 - 1}],
      [board_index: 0, point: tl_2 = {w1 - 1, h1 - 2}],
      [board_index: 1, point: tr_1 = {w1 + 1, h1 - 3}],
      [board_index: 1, point: tr_2 = {w1, h1 - 1}],
      [board_index: 3, point: br_1 = {w1 + 2, h1}],
      [board_index: 3, point: br_2 = {w1, h1 + 1}],
      [board_index: 2, point: bl_1 = {w1 - 2, h1 + 2}],
      [board_index: 2, point: bl_2 = {w1 - 1, h1}],
    ]

    disconnected_boards = Enum.reduce(
      anchor_points,
      boards,
      fn ([board_index: bi, point: {x, y}], current_boards) ->
        updated_target_board =
          current_boards
          |> Enum.at(bi)
          |> disconnect_point(x, y, anchor_points)

        current_boards
        |> List.replace_at(bi, {x, y}, updated_target_board)
      end
    )

    # %Board{
      # width: tl_board.width + tr_board.width,
      # height: tl_board.height + bl_board.height,
    # }
    # TODO NEXT get this working
  end

  @doc "Points used for joining, clockwise order"
  defp make_anchor_points(tl_board) do
    # TODO ?
  end

  defp disconnect_point(board, p = {x, y}, anchor_points) do
    cell = Board.get(board, x, y)
    {next_px, next_py} = next_p = cell[:next]
    {prev_px, prev_py} = prev_p = cell[:prev]

    match? = fn (point) ->
      Enum.any?(
        anchor_points,
        fn ([board_index: _, point: point]) ->
          point == p
        end
      )
    end

    cond do
      match?(next_p)->
        next_cell =
          board
          |> Board.get(next_px, next_py)
          |> Keyword.replace(:prev, :to_replace)
        updated_cell = Keyword.replace(cell, :next, :to_replace)

        board
        |> Board.put(updated_cell, x, y)
        |> Board.put(next_cell, next_px, next_py)

      match?(prev_p)->
        prev_cell =
          board
          |> Board.get(prev_px, prev_py)
          |> Keyword.replace(:next, :to_replace)
        updated_cell = Keyword.replace(cell, :prev, :to_replace)

        board
        |> Board.put(updated_cell, x, y)
        |> Board.put(prev_cell, prev_px, prev_py)

      true ->
        raise CaseClauseError, "Anchor points must be wrong"
    end
  end

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
