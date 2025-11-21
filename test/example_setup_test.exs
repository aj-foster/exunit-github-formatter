defmodule ExampleSetupTest do
  use ExUnit.Case, async: true

  setup_all do
    raise "Setup all failure"
    %{}
  end

  describe "when everything goes right" do
    test "the test should pass" do
      assert 1 + 1 == 2
    end
  end

  describe "when things go wrong" do
    test "the test will fail" do
      assert 1 + 1 == 3
    end
  end
end
