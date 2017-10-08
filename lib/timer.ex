defmodule Timer do

  def bench(solver, width, height) do
    bench(solver, %Board{width: width, height: height})
  end

  def bench(solver, board = %Board{}) do
    {millis, result} = measure(
      fn -> solver.solve(board) end
    )

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
