defmodule Timer do

  def bench_increasing_square(
    solver,
    min \\ 6,
    max \\ 150,
    interval \\ 6
  ) do
    (
      for x <- min..max,
      rem(x, interval) == 0,
      x != 42,
      do: x
    )
    |> Enum.map(fn size ->
      r = bench_square(solver, size, false)
      IO.puts "Finished for size: #{size}, millis: #{elem(r, 0)}"
    end)
  end

  def bench_square(solver, size, print \\ true) when is_number(size) do
    bench_size(solver, size, size, print)
  end

  def bench_board(solver, board = %Board{}, print \\ true) do
    measure_result =
      {millis, result} =
        measure(fn ->
          solver.solve(board)
        end)

    if print do
      IO.puts "* Duration: #{millis} ms"
      if result == :no_closed_tour_found do
        IO.puts "  * Result: :no_closed_tour_found"
      else
        IO.puts "  * Result:"
        result
        |> Keyword.fetch!(:board)
        |> Board.to_string
        |> IO.puts
      end
    end

    measure_result
  end

  def bench_size(solver, width, height, print \\ true) do
    bench_board(solver, %Board{width: width, height: height}, print)
  end

  def measure(prepare_function, work_function) do
    preparation_data = prepare_function.()

    {micros, work_result} =
      fn -> work_function.(preparation_data) end
      |> :timer.tc

    {micros / 1.0e3, work_result}
  end

  def measure(work_function) do
    measure(
      fn -> nil end,
      fn _ -> work_function.() end
    )
  end

end
