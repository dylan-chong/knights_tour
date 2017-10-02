defmodule BoardTest do
  use ExUnit.Case, async: true
  doctest Board

  test "to_string should not crash" do
    string =
      %Board{width: 8, height: 8}
      |> Board.put(4, 4, :a)
      |> Board.put(3, 2, :b)
      |> Board.put(0, 0, :c)
      |> Board.put(7, 7, :d)
      |> Board.to_string

    assert is_binary(string)
  end

  test "get and put should store and retrieve values" do
    board = %Board{width: 8, height: 8}

    assert Board.get(board, 1, 0) == nil

    value =
      board
      |> Board.put(1, 0, :value)
      |> Board.get(1, 0)

    assert value == :value
  end

  test "put invalid point should raise" do
    assert_raise ArgumentError, fn ->
      %Board{width: 8, height: 8}
      |> Board.put(-1, -1, :value)
    end
  end

  test "get invalid point should raise" do
    assert_raise ArgumentError, fn ->
      %Board{width: 8, height: 8}
      |> Board.get(-1, -1)
    end
  end

  test "empty_bounds finds empty bounds for two squares" do
    empty_points = [{1, 2}, {2, 4}]

    board =
      (for x <- 0..3, y <- 0..4, do: {x, y})
      |> Enum.reduce(
        %Board{width: 4, height: 5},
        fn p = {x, y}, b ->
          if p in empty_points do
            b
          else
            Board.put(b, x, y, 0)
          end
        end
      )

    assert Board.empty_bounds(board) == {1, 2, 3, 5}
  end

end
