defmodule HardCodedBoards do

  def for_size({width, height}) do
    for_size("#{width}x#{height}")
  end

  def for_size(size) when is_bitstring(size) do
    [w_string, h_string] = String.split(size, "x")
    points = all()[size]
        || (all()["#{h_string}x#{w_string}"] |> rotate)

    if !points do
      "not_found for size #{size}"
    else
      if List.last(points) == List.first(points) do
        [_first | rest] = points
        rest
      else
        points
      end
    end
  end

  def rotate(nil), do: nil
  def rotate(points) do
    Enum.map(points, fn {x, y} -> {y, x} end)
  end

  def all do
    %{
      "6x6" => [
        {0, 0}, {1, 2}, {0, 4}, {2, 5}, {4, 4}, {5, 2}, {4, 0}, {3, 2}, {2, 0},
        {0, 1}, {1, 3}, {0, 5}, {2, 4}, {4, 5}, {5, 3}, {4, 1}, {3, 3}, {5, 4},
        {3, 5}, {1, 4}, {2, 2}, {0, 3}, {1, 5}, {3, 4}, {5, 5}, {4, 3}, {5, 1},
        {3, 0}, {1, 1}, {2, 3}, {4, 2}, {5, 0}, {3, 1}, {1, 0}, {0, 2}, {2, 1},
        {0, 0}
      ],

      "6x8" => [
        {0, 0}, {1, 2}, {2, 0}, {0, 1}, {1, 3}, {0, 5}, {1, 7}, {3, 6}, {5, 7},
        {4, 5}, {5, 3}, {4, 1}, {3, 3}, {5, 4}, {4, 6}, {2, 7}, {0, 6}, {2, 5},
        {3, 7}, {5, 6}, {4, 4}, {5, 2}, {4, 0}, {3, 2}, {5, 1}, {3, 0}, {1, 1},
        {0, 3}, {2, 4}, {1, 6}, {0, 4}, {2, 3}, {1, 5}, {0, 7}, {2, 6}, {4, 7},
        {5, 5}, {3, 4}, {4, 2}, {5, 0}, {3, 1}, {4, 3}, {3, 5}, {1, 4}, {2, 2},
        {1, 0}, {0, 2}, {2, 1}, {0, 0}
      ],

      "8x8" => [
        {0, 0}, {1, 2}, {2, 0}, {0, 1}, {1, 3}, {0, 5}, {1, 7}, {3, 6}, {5, 7},
        {7, 6}, {6, 4}, {7, 2}, {6, 0}, {4, 1}, {6, 2}, {7, 0}, {5, 1}, {3, 0},
        {1, 1}, {0, 3}, {1, 5}, {0, 7}, {2, 6}, {4, 7}, {6, 6}, {7, 4}, {5, 5},
        {6, 7}, {7, 5}, {6, 3}, {7, 1}, {5, 0}, {3, 1}, {1, 0}, {0, 2}, {1, 4},
        {2, 2}, {4, 3}, {2, 4}, {3, 2}, {4, 0}, {5, 2}, {7, 3}, {6, 1}, {5, 3},
        {4, 5}, {3, 7}, {1, 6}, {0, 4}, {2, 3}, {3, 5}, {2, 7}, {0, 6}, {2, 5},
        {4, 4}, {5, 6}, {7, 7}, {6, 5}, {4, 6}, {3, 4}, {4, 2}, {5, 4}, {3, 3},
        {2, 1}, {0, 0}
      ],

      "8x10"=> [
        {0, 0}, {2, 1}, {0, 2}, {1, 0}, {3, 1}, {5, 0}, {7, 1}, {6, 3}, {7, 5},
        {6, 7}, {7, 9}, {5, 8}, {3, 9}, {1, 8}, {3, 7}, {4, 9}, {6, 8}, {4, 7},
        {2, 6}, {0, 5}, {2, 4}, {0, 3}, {1, 1}, {3, 0}, {5, 1}, {7, 0}, {6, 2},
        {7, 4}, {5, 5}, {7, 6}, {5, 7}, {6, 9}, {7, 7}, {5, 6}, {4, 8}, {3, 6},
        {1, 5}, {2, 7}, {0, 6}, {1, 4}, {3, 5}, {4, 3}, {6, 4}, {7, 2}, {6, 0},
        {4, 1}, {2, 2}, {0, 1}, {2, 0}, {3, 2}, {1, 3}, {3, 4}, {5, 3}, {6, 5},
        {4, 6}, {2, 5}, {4, 4}, {2, 3}, {4, 2}, {6, 1}, {4, 0}, {5, 2}, {7, 3},
        {5, 4}, {3, 3}, {4, 5}, {6, 6}, {7, 8}, {5, 9}, {3, 8}, {1, 9}, {0, 7},
        {2, 8}, {0, 9}, {1, 7}, {2, 9}, {0, 8}, {1, 6}, {0, 4}, {1, 2}, {0, 0}
      ],

      "10x10"=>[
        {0, 0}, {1, 2}, {0, 4}, {1, 6}, {0, 8}, {2, 9}, {4, 8}, {6, 9}, {8, 8},
        {6, 7}, {5, 9}, {3, 8}, {1, 9}, {0, 7}, {1, 5}, {0, 3}, {1, 1}, {3, 0},
        {5, 1}, {7, 0}, {9, 1}, {8, 3}, {9, 5}, {7, 6}, {5, 7}, {6, 5}, {8, 4},
        {9, 6}, {7, 7}, {5, 8}, {3, 9}, {1, 8}, {3, 7}, {5, 6}, {7, 5}, {6, 3},
        {4, 4}, {2, 5}, {0, 6}, {2, 7}, {4, 6}, {3, 4}, {1, 3}, {0, 5}, {2, 6},
        {4, 7}, {6, 6}, {8, 5}, {9, 3}, {7, 4}, {5, 3}, {3, 2}, {2, 4}, {4, 5},
        {6, 4}, {7, 2}, {6, 0}, {8, 1}, {7, 3}, {5, 2}, {3, 3}, {1, 4}, {0, 2},
        {1, 0}, {3, 1}, {5, 0}, {4, 2}, {2, 3}, {3, 5}, {5, 4}, {6, 2}, {4, 1},
        {2, 0}, {0, 1}, {2, 2}, {4, 3}, {5, 5}, {3, 6}, {1, 7}, {0, 9}, {2, 8},
        {4, 9}, {6, 8}, {8, 9}, {9, 7}, {7, 8}, {9, 9}, {8, 7}, {7, 9}, {9, 8},
        {8, 6}, {9, 4}, {8, 2}, {9, 0}, {7, 1}, {9, 2}, {8, 0}, {6, 1}, {4, 0},
        {2, 1}, {0, 0}
      ],

      "10x12"=>[
        {0, 0}, {1, 2}, {0, 4}, {1, 6}, {0, 8}, {1, 10}, {3, 11}, {2, 9},
        {1, 11}, {0, 9}, {2, 10}, {0, 11}, {1, 9}, {0, 7}, {2, 8}, {3, 10},
        {5, 11}, {4, 9}, {6, 10}, {4, 11}, {3, 9}, {5, 10}, {7, 11}, {9, 10},
        {7, 9}, {8, 11}, {9, 9}, {7, 10}, {9, 11}, {8, 9}, {6, 8}, {8, 7},
        {9, 5}, {8, 3}, {9, 1}, {7, 0}, {5, 1}, {3, 0}, {1, 1}, {0, 3}, {1, 5},
        {2, 7}, {0, 6}, {2, 5}, {1, 7}, {0, 5}, {1, 3}, {0, 1}, {2, 0}, {3, 2},
        {2, 4}, {3, 6}, {4, 8}, {6, 9}, {8, 8}, {9, 6}, {7, 7}, {5, 8}, {4, 6},
        {6, 7}, {7, 5}, {6, 3}, {4, 4}, {6, 5}, {8, 4}, {7, 6}, {9, 7}, {7, 8},
        {5, 9}, {3, 8}, {5, 7}, {4, 5}, {2, 6}, {4, 7}, {6, 6}, {8, 5}, {6, 4},
        {7, 2}, {9, 3}, {7, 4}, {5, 5}, {3, 4}, {5, 3}, {4, 1}, {6, 0}, {8, 1},
        {7, 3}, {5, 2}, {3, 3}, {1, 4}, {2, 2}, {1, 0}, {0, 2}, {2, 3}, {4, 2},
        {5, 4}, {6, 2}, {5, 0}, {3, 1}, {4, 3}, {3, 5}, {5, 6}, {3, 7}, {1, 8},
        {0, 10}, {2, 11}, {4, 10}, {6, 11}, {8, 10}, {9, 8}, {8, 6}, {9, 4},
        {8, 2}, {9, 0}, {7, 1}, {9, 2}, {8, 0}, {6, 1}, {4, 0}, {2, 1}, {0, 0}
      ],
    }
  end
end
