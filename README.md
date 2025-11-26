# ExUnit GitHub Formatter

Formatter for Elixir's ExUnit testing framework that produces annotations compatible with GitHub Actions checks.

## Installation

This package is not currently available on hex.pm.
To install it, refer to the repository directly:

```elixir
# In mix.exs

defp deps do
  [
    {:github_formatter, github: "aj-foster/exunit-github-formatter", branch: "main", only: :test}
  ]
end
```

## Usage

We recommend configuring this formatter alongside the default `ExUnit.CLIFormatter` in CI environments:

```elixir
# In test/test_helper.exs

if System.get_env("CI") do
  ExUnit.configure(formatters: [ExUnit.CLIFormatter, GitHubFormatter])
end
```
