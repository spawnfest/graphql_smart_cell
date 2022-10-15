defmodule GraphqlSmartCell.MixProject do
  use Mix.Project

  @version "0.1.0"
  @description "GraphQL integration with Livebook"

  def project do
    [
      app: :graphql_smart_cell,
      version: @version,
      description: @description,
      name: "GraphQL SmartCell",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {GraphqlSmartCell.Application, []}
    ]
  end

  defp deps do
    [
      {:absinthe_client, "~> 0.1.0"},
      {:kino, "~> 0.6.1 or ~> 0.7.0"},
      {:ex_doc, "~> 0.28", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "components",
      source_url: "https://github.com/spawnfest/graphql_smart_cell",
      source_ref: "v#{@version}",
      extras: ["guides/components.livemd"]
    ]
  end

  def package do
    [
      links: %{
        "GitHub" => "https://github.com/spawnfest/graphql_smart_cell"
      }
    ]
  end
end
