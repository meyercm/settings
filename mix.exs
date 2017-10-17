defmodule Settings.Mixfile do
  use Mix.Project

  @version "0.2.0"
  @repo_url "https://github.com/meyercm/settings"

  def project do
    [
      app: :settings,
      version: @version,
      elixir: "~> 1.0",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      # Hex
      package: hex_package(),
      description: "A generic Elixir application settings library",
      # Docs
      name: "Settings",
      # Testing
      preferred_cli_env: [espec: :test],
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp hex_package do
    [maintainers: ["Chris Meyer"],
     licenses: ["MIT"],
     links: %{"GitHub" => @repo_url}]
  end

  defp deps do
    [
      {:espec, "~> 1.4.6", only: :test},
    ]
  end
end
