defmodule SpySupervisorTest do
  use ExUnit.Case
  doctest SpySupervisor

  test "greets the world" do
    assert SpySupervisor.hello() == :world
  end
end
