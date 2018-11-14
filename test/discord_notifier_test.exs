defmodule DiscordNotifierTest do
  use ExUnit.Case
  doctest DiscordNotifier

  test "greets the world" do
    assert DiscordNotifier.hello() == :world
  end
end
