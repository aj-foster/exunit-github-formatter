defmodule GitHubFormatter.MixProject do
  use Mix.Project

  def project do
    [
      app: :github_formatter,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def aliases do
    [
      credo: ["app.config", "credo"]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.2", optional: true}
    ]
  end
end
