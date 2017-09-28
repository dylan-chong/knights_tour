defmodule TimerTest do
  use ExUnit.Case
  doctest Timer

  @sleep 50

  test "measure/2 should return a reasonable measurement" do
    measurement = Timer.measure(
      fn -> nil end,
      fn _ -> :timer.sleep(@sleep) end
    )
    assert measurement > @sleep
    assert measurement < @sleep * 10
  end

  test "measure/1 should return a reasonable measurement" do
    measurement = Timer.measure(
      fn -> :timer.sleep(@sleep) end
    )
    assert measurement > @sleep
    assert measurement < @sleep * 10
  end

end
