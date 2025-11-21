defmodule ExampleTest do
  use ExUnit.Case, async: true

  describe "when everything goes right" do
    test "should pass" do
      assert 1 + 1 == 2
    end
  end

  describe "when things go wrong" do
    test "will fail" do
      assert 1 + 1 == 3
    end
  end
end
