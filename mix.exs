defmodule Mecp.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/amadeus-robot/mcp"

  def project do
    [
      app: :mecp,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      
      # Hex package info
      package: package(),
      description: description(),
      
      # Documentation
      name: "MECP",
      docs: docs(),
      
      # Source and homepage
      source_url: @source_url,
      homepage_url: @source_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp description do
    """
    A brief description of your MECP package.
    Replace this with an actual description of what your package does.
    """
  end

  defp package do
    [
      name: "mecp",
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"
      },
      maintainers: ["Your Name"],
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
