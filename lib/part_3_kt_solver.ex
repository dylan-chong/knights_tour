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
    |> join_and_connect_boards
  end

  defp rectangle_to_solved_board(r = %Rectangle{}) do
    %Board{width: r.w, height: r.h}
    |> Part3KTSolver.solve
    |> Keyword.fetch!(:board)
    |> KTSolverUtil.remove_nums
  end

  defp join_and_connect_boards(boards) do
    anchor_points = make_anchor_points(hd(boards))
    joined_board = join_boards(boards)

    disconnected_joined_board = Enum.reduce(
      anchor_points,
      joined_board,
      fn ({x, y}, board) ->
        disconnect_point(board, x, y, anchor_points)
      end
    )

    # TODO NEXT get rejoin working
  end

  defp join_boards(boards = [tl_board, tr_board, bl_board, br_board]) do
    empty_joined_board = %Board{
      width: tl_board.width + tr_board.width,
      height: tl_board.height + bl_board.height,
    }

    w1 = tl_board.width
    h1 = tl_board.height

    make_translator = fn ({dx, dy}) ->
      fn {{x, y}, cell} ->
        do_translate = fn {xx, yy} -> {xx + dx, y + dy} end
        {
          do_translate({x, y}),
          cell
          |> Keyword.replace(:prev, do_translate(cell[:prev]))
          |> Keyword.replace(:next, do_translate(cell[:next]))
        }
      end
    end

    [
      tl_board
      |> Board.all_points_to_cells
      |> Stream.map(&(&1)),

      tr_board
      |> Board.all_points_to_cells
      |> Stream.map(make_translator(x + tl_board.width, y)),

      br_board
      |> Board.all_points_to_cells
      |> Stream.map(make_translator(x + tl_board.width, y + tl_board.height)),

      bl_board
      |> Board.all_points_to_cells
      |> Stream.map(make_translator(x, y + tl_board.height)),
    ]
    |> Stream.flat_map(&(&1))
    |> Enum.reduce(
      empty_joined_board,
      fn ({{x, y}, cell}, board) ->
        Board.put(board, x, y, cell)
      end
    )
  end

  @doc "Points used for joining, clockwise order"
  defp make_anchor_points(tl_board) do
    w1 = tl_board.width
    h1 = tl_board.height
    [
      # tl
      {w1 - 3, h1 - 1},
      {w1 - 1, h1 - 2},
      # tr
      {w1 + 1, h1 - 3},
      {w1, h1 - 1},
      # br
      {w1 + 2, h1},
      {w1, h1 + 1},
      # bl
      {w1 - 2, h1 + 2},
      {w1 - 1, h1},
    ]
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
