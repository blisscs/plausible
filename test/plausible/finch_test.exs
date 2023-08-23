defmodule Plausible.FinchTest do
  use ExUnit.Case, async: true

  test "PlausibleFinch is alive" do
    pid = Process.whereis(Plausible.Finch)

    assert Process.alive?(pid)
  end
end
