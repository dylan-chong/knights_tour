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
    tl_board = hd(boards)
    anchor_points = make_anchor_points(tl_board.width, tl_board.height)
    joined_board = join_boards(boards)

    disconnected_joined_board =
      anchor_points
      |> pair_list
      |> Enum.reduce(joined_board, fn {ap1, ap2}, board ->
        disconnect_edge(board, ap1, ap2)
      end)

    reanchor_points(disconnected_joined_board, anchor_points)
  end

  defp reanchor_points(board, anchor_points = [first_anchor | _]) do
    anchor_points
    |> List.delete(first_anchor)
    |> Kernel.++([first_anchor])
    |> pair_list
    |> Enum.reduce(board, fn {point_a, point_b}, current_board ->
      join_edge(current_board, point_a, point_b)
    end)
  end

  defp join_edge(board, pa = {ax, ay}, pb = {bx, by}) do
    if {5, 4} in [pa, pb] do
      IO.puts ""
    end
    cell_a = Board.get(board, ax, ay)
    cell_b = Board.get(board, bx, by)

    updated_cell_a_neighbours =
      cell_a[:neighbours]
      |> List.delete(:to_replace)
      |> Kernel.++([pb])
    updated_cell_b_neighbours =
      cell_b[:neighbours]
      |> List.delete(:to_replace)
      |> Kernel.++([pa])

    if length(updated_cell_a_neighbours) != 2
        || length(updated_cell_b_neighbours) != 2
        || :to_replace in updated_cell_a_neighbours
        || :to_replace in updated_cell_b_neighbours do
      raise ArgumentError, inspect([
        updated_cell_a_neighbours: updated_cell_a_neighbours,
        updated_cell_b_neighbours: updated_cell_b_neighbours,
        board: board
      ], limit: :infinity)
    end

    board
    |> Board.put(
      ax, ay,
      cell_a |> Keyword.replace(:neighbours, updated_cell_a_neighbours)
    )
    |> Board.put(
      bx, by,
      cell_b |> Keyword.replace(:neighbours, updated_cell_b_neighbours)
    )
  end

  def disconnect_edge(board, pa = {ax, ay}, pb = {bx, by}) do
    cell_a = board |> Board.get(ax, ay)
    cell_b = board |> Board.get(bx, by)

    updated_cell_a = Keyword.replace!(
      cell_a,
      :neighbours,
      updated_cell_a_neighbours =
        cell_a
        |> Keyword.fetch!(:neighbours)
        |> List.delete(pb)
        |> Kernel.++([:to_replace])
    )

    updated_cell_b = Keyword.replace!(
      cell_b,
      :neighbours,
      updated_cell_b_neighbours =
        cell_b
        |> Keyword.fetch!(:neighbours)
        |> List.delete(pa)
        |> Kernel.++([:to_replace])
    )

    if length(updated_cell_a_neighbours) != 2
        || length(updated_cell_b_neighbours) != 2 do
      raise ArgumentError, inspect([
        updated_cell_a: updated_cell_a,
        updated_cell_b: updated_cell_b,
        board: board
      ], limit: :infinity)
    end

    board
    |> Board.put(ax, ay, updated_cell_a)
    |> Board.put(bx, by, updated_cell_b)
  end

  defp join_boards([tl_board, tr_board, bl_board, br_board]) do
    empty_joined_board = %Board{
      width: tl_board.width + tr_board.width,
      height: tl_board.height + bl_board.height,
    }

    make_translator = fn (dx, dy) ->
      fn {{x, y}, cell} ->
        do_translate = fn {xx, yy} -> {xx + dx, yy + dy} end
        {
          do_translate.({x, y}),
          Keyword.replace!(cell, :neighbours,
            cell[:neighbours] |> Enum.map(do_translate)
          )
        }
      end
    end

    [
      tl_board
      |> Board.all_points_to_cells
      |> Stream.map(&(&1)),

      tr_board
      |> Board.all_points_to_cells
      |> Stream.map(make_translator.(tl_board.width, 0)),

      br_board
      |> Board.all_points_to_cells
      |> Stream.map(make_translator.(tl_board.width, tl_board.height)),

      bl_board
      |> Board.all_points_to_cells
      |> Stream.map(make_translator.(0, tl_board.height)),
    ]
    |> Stream.flat_map(&(&1))
    |> Enum.reduce( # TODO optimise?: replace with make map from list
      empty_joined_board,
      fn ({{x, y}, cell}, board) ->
        Board.put(board, x, y, cell)
      end
    )
  end

  # "Points used for joining, clockwise order"
  def make_anchor_points(tl_width, tl_height) do
    w1 = tl_width
    h1 = tl_height
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

  def split_board(width, height)
      when width > height
      or Integer.is_odd(width)
      or Integer.is_odd(height)
      or width < 10
      or height < 12
      or height - width not in [0, 2],
    do: raise ArgumentError,
      "Invalid board of w: #{width}, h: #{height}"
  def split_board(width, height)
      when width == height and rem(width, 4) == 0 do
    half_width = Integer.floor_div(width, 2)
    half_height = Integer.floor_div(height, 2)

    four_sub_boards(half_width, half_width, half_height, half_height)
  end
  def split_board(width, height) when width == height do
    half_width = Integer.floor_div(width, 2)
    half_height = Integer.floor_div(height, 2)

    four_sub_boards(
      half_width - 1,
      half_width - 1,
      half_height + 1,
      half_height + 1
    )
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

  def pair_list(list) when is_list(list) do
    list
    |> Enum.reduce([], fn
      item, [{existing_item} | rest] ->
        [{existing_item, item} | rest]
      item, pairs when is_list(pairs) ->
        # pairs is empty at the start
        [{item} | pairs]
    end)
    |> Enum.reverse
  end

end
