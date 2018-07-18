defmodule DeduperTest do
  use ExUnit.Case
  doctest Deduper

  test "greets the world" do
    assert Deduper.hello() == :world
  end
end
