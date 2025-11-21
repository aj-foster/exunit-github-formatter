defmodule GitHubFormatter do
  @moduledoc """
  TODO
  """
  use GenServer
  import ExUnit.Formatter

  @typep test_status :: :excluded | :failed | :invalid | :passed | :skipped
  @typep state :: %{
           counts: %{
             total: non_neg_integer,
             excluded: non_neg_integer,
             failed: non_neg_integer,
             invalid: non_neg_integer,
             passed: non_neg_integer,
             skipped: non_neg_integer
           }
         }

  @doc false
  @impl GenServer
  @spec init(keyword) :: {:ok, state}
  def init(_opts) do
    {:ok, %{counts: %{total: 0, excluded: 0, failed: 0, invalid: 0, passed: 0, skipped: 0}}}
  end

  @doc false
  @impl GenServer
  def handle_cast(request, state)

  def handle_cast({:test_finished, %ExUnit.Test{state: nil} = _test}, state) do
    state
    |> increment(:passed)
    |> noreply()
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:excluded, _reason}}}, state) do
    state
    |> increment(:excluded)
    |> noreply()
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:skipped, _reason}}}, state) do
    state
    |> increment(:skipped)
    |> noreply()
  end

  def handle_cast(
        {:test_finished,
         %ExUnit.Test{state: {:invalid, %ExUnit.TestModule{state: {:failed, _}}}}},
        state
      ) do
    state
    |> increment(:invalid)
    |> noreply()
  end

  def handle_cast({:test_finished, %ExUnit.Test{state: {:failed, failures}} = test}, state) do
    file = Path.relative_to_cwd(test.tags.file)
    title = "Test Failure"

    message =
      format_test_failure(
        test,
        failures,
        state.counts.failed + 1,
        80,
        fn _key, value -> value end
      )
      |> String.replace("\n", "%0A")

    IO.puts("::error file=#{file},line=#{test.tags.line},title=#{title}::#{message}")

    state
    |> increment(:failed)
    |> noreply()
  end

  # Failure in setup_all
  def handle_cast(
        {:module_finished, %ExUnit.TestModule{state: {:failed, failures}} = test_module},
        state
      ) do
    file = Path.relative_to_cwd(test_module.file)
    title = "Test Module Failure"
    # Failed tests have already been counted; only need to add successful tests.
    non_failed_test_count = Enum.count(test_module.tests, &is_nil(&1.state))

    message =
      format_test_all_failure(
        test_module,
        failures,
        state.counts.failed + non_failed_test_count,
        80,
        fn _key, value -> value end
      )
      |> String.replace("\n", "%0A")

    IO.puts("::error file=#{file},line=1,title=#{title}::#{message}")

    state
    |> increment(:failed, non_failed_test_count)
    |> noreply()
  end

  def handle_cast({:suite_finished, times_us}, state) do
    if summary_file = System.get_env("GITHUB_STEP_SUMMARY") do
      test_counts =
        [
          pluralize(state.counts.total, "test", "tests"),
          if_nonzero(state.counts.failed, "failed"),
          if_nonzero(state.counts.invalid, "invalid"),
          "#{state.counts.passed} passed",
          if_nonzero(state.counts.skipped, "skipped"),
          if_nonzero(state.counts.excluded, "excluded")
        ]
        |> Enum.filter(& &1)
        |> Enum.join(", ")

      emoji =
        cond do
          state.counts.failed > 0 -> ":red_circle:"
          state.counts.invalid > 0 -> ":orange_circle:"
          state.counts.passed == 0 -> ":yellow_circle:"
          :else -> ":green_circle:"
        end

      summary =
        """
        ## ExUnit Test Summary #{emoji}

        #{format_times(times_us)}
        #{test_counts}
        """

      File.write!(summary_file, summary, [:append])
    end

    {:noreply, state}
  end

  def handle_cast(_event, state) do
    {:noreply, state}
  end

  #
  # Helpers
  #

  @spec increment(state, test_status) :: state
  @spec increment(state, test_status, non_neg_integer) :: state
  defp increment(state, test_status, count \\ 1) do
    counts =
      state.counts
      |> Map.update(:total, count, &(&1 + count))
      |> Map.update(test_status, count, &(&1 + count))

    %{state | counts: counts}
  end

  @spec pluralize(non_neg_integer, String.t(), String.t()) :: String.t()
  defp pluralize(1, singular, _plural), do: "1 #{singular}"
  defp pluralize(count, _singular, plural), do: "#{count} #{plural}"

  @spec if_nonzero(non_neg_integer, String.t()) :: String.t() | nil
  defp if_nonzero(0, _string), do: nil
  defp if_nonzero(count, string), do: "#{count} #{string}"

  @spec noreply(state) :: {:noreply, state}
  defp noreply(state), do: {:noreply, state}
end
