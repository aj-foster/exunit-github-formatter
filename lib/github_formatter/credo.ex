if Code.ensure_loaded?(Credo.Plugin) do
  defmodule GitHubFormatter.Credo do
    @moduledoc """
    Provides a Credo plugin that outputs issues as GitHub Action annotations

    ## Usage

    To use this plugin, add it to your Credo configuration (e.g., `.credo.exs`):

        %{
          plugins: [{GitHubFormatter.Credo, []}]
        }

    Full output — using your chosen formatter — will still be available in the logs.
    """
    use Credo.Execution.Task
    import Credo.Plugin

    # impl Credo.Plugin
    @doc false
    @spec init(Credo.Execution.t()) :: Credo.Execution.t()
    def init(exec) do
      append_task(
        exec,
        Credo.CLI.Command.Suggest.SuggestCommand,
        :print_after_analysis,
        __MODULE__
      )
    end

    @impl Credo.Execution.Task
    def call(exec, _opts) do
      exec
      |> Execution.get_issues()
      |> Enum.each(&print_issue/1)

      exec
    end

    defp print_issue(issue) do
      %Credo.Issue{
        check: check,
        filename: filename,
        line_no: line,
        message: message,
        priority: priority
      } = issue

      message_type = priority_to_message_type(priority)

      title = "Credo: #{Credo.Code.Name.full(check)}"
      message = String.replace(message, "\n", "%0A")

      IO.puts("::#{message_type} file=#{filename},line=#{line},title=#{title}::#{message}")
    end

    @spec priority_to_message_type(integer | atom) :: String.t()
    defp priority_to_message_type(priority) when is_number(priority) do
      cond do
        # :higher
        priority > 19 -> "error"
        # :high
        priority in 10..19 -> "error"
        # :normal
        priority in 0..9 -> "warning"
        # :low
        priority in -10..-1 -> "info"
        # :ignore
        priority < -10 -> "debug"
      end
    end

    defp priority_to_message_type(_), do: "warning"
  end
end
