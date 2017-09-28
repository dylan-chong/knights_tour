defmodule Timer do

  def measure(prepare_function, work_function) do
    preparation_data = prepare_function.()

    fn -> work_function.(preparation_data) end
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1.0e3) # convert microseconds to milliseconds
  end

  def measure(work_function) do
    measure(
      fn -> nil end,
      fn _ -> work_function.() end
    )
  end

end
