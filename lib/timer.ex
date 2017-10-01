defmodule Timer do

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
