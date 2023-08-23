defmodule PlausibleTest do
  use ExUnit.Case
  doctest Plausible

  test "greets the world" do
    assert Plausible.hello() == :world
  end
end
