defmodule TimerTest do
  use ExUnit.Case
  doctest Timer

  @sleep 50

  test "measure/2 should return a reasonable measurement" do
    {time, _} = Timer.measure(
      fn -> nil end,
      fn _ -> :timer.sleep(@sleep) end
    )
    assert time > @sleep
    assert time < @sleep * 10
  end

  test "measure/1 should return a reasonable measurement" do
    {time, _} = Timer.measure(
      fn -> :timer.sleep(@sleep) end
    )
    assert time > @sleep
    assert time < @sleep * 10
  end

end
