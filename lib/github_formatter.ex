defmodule GitHubFormatter do
  @moduledoc """
  TODO
  """
  use GenServer
  import ExUnit.Formatter

  @impl GenServer
  def init(_opts) do
    {:ok, %{counter: 0, failure_counter: 0}}
  end

  @impl GenServer
  def handle_cast(request, state)

  def handle_cast(
        {:test_finished,
         %ExUnit.Test{state: {:invalid, %ExUnit.TestModule{state: {:failed, _}}}} = _test},
        state
      ) do
    {:noreply, %{state | counter: state.counter + 1, failure_counter: state.failure_counter + 1}}
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

    file = Path.relative_to_cwd(test.tags.file)
    output = "::error file=#{file},line=#{test.tags.line},title=#{title}::#{message}"

    IO.inspect(output, label: "GitHub Formatter Output")
    IO.puts(output)

    {:noreply, %{state | counter: state.counter + 1, failure_counter: state.failure_counter + 1}}
  end

  def handle_cast({:test_finished, _test}, state) do
    {:noreply, %{state | counter: state.counter + 1}}
  end

  def handle_cast({:suite_finished, times_us}, state) do
    if summary_file = System.get_env("GITHUB_STEP_SUMMARY") |> IO.inspect() do
      summary = """
      ## Test Suite Summary

      Total Time: #{format_times(times_us)}
      Total Tests: #{state.counter}
      Failures: #{state.failure_counter}
      """

      File.write!(summary_file, summary, [:append])
    end

    {:noreply, state}
  end

  def handle_cast(_event, state) do
    {:noreply, state}
  end
end
