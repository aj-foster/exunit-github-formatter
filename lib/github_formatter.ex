defmodule GitHubFormatter do
  @moduledoc """
  TODO
  """
  use GenServer
  import ExUnit.Formatter

  @impl GenServer
  def init(_opts) do
    {:ok, %{failure_counter: 0}}
  end

  @impl GenServer
  def handle_cast(request, state)

  def handle_cast(
        {:test_finished,
         %ExUnit.Test{state: {:invalid, %ExUnit.TestModule{state: {:failed, _}}}} = _test},
        state
      ) do
    {:noreply, state}
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:failed, failures}} = test}, state) do
    title = "Test Failure"

    message =
      format_test_failure(
        test,
        failures,
        state.failure_counter + 1,
        80,
        fn _key, value -> value end
      )
      |> String.replace("\n", "%0A")

    IO.puts("::error file=#{test.tags.file},line=#{test.tags.line},title=#{title}::#{message}")

    {:noreply, %{state | failure_counter: state.failure_counter + 1}}
  end

  def handle_cast(_event, state) do
    {:noreply, state}
  end
end
