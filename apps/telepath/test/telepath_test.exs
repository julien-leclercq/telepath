defmodule TelepathTest do
  use ExUnit.Case
  doctest Telepath

  test "greets the world" do
    assert Telepath.hello() == :world
  end
end
