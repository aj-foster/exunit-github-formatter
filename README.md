# ExUnit GitHub Formatter

Formatter for Elixir's ExUnit testing framework that produces annotations compatible with GitHub Actions checks.

This package also provides a plugin for [Credo](https://github.com/rrrene/credo) that similarly outputs annotations for Credo issues.

## Installation

This package is not currently available on hex.pm.
To install it, refer to the repository directly:

```elixir
# In mix.exs

defp deps do
  [
    {:github_formatter, github: "aj-foster/exunit-github-formatter", branch: "main", only: [:dev, :test]}
  ]
end
```

Installing this package in the `test` environment is necessary for ExUnit integration.
You may want to include it in other environments (for example, `dev`) to make configuring Credo easier.

## Usage (ExUnit)

We recommend configuring this formatter alongside the default `ExUnit.CLIFormatter` in CI environments:

```elixir
# In test/test_helper.exs

if System.get_env("CI") do
  ExUnit.configure(formatters: [ExUnit.CLIFormatter, GitHubFormatter])
end
```

Annotations will be output when `mix test` is run in a CI environment.
Try it out by running `CI=true mix test`.

## Usage (Credo)

Add `GitHubFormatter.Credo` as a plugin to your Credo configuration:

```elixir
# In .credo.exs

%{
  configs: [
    %{
      # ...
      plugins: [{GitHubFormatter.Credo, []}]
    }
  ]
}
```

You may wish to create a separate configuration for your CI environment to avoid extra output in development.

When calling Credo in CI, avoid the default output format (which can display duplicate annotations):

```shell
mix credo --config-name="..." --format=oneline
```
