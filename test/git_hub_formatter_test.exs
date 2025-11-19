defmodule GitHubFormatterTest do
  use ExUnit.Case
  doctest GitHubFormatter

  test "greets the world" do
    assert GitHubFormatter.hello() == :world
  end
end
