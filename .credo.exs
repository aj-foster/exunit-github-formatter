%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["test/example.ex"]
      },
      plugins: [{GitHubFormatter.Credo, []}]
    }
  ]
}
