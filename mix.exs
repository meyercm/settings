defmodule Settings.Mixfile do
  use Mix.Project

  @version "0.1.0"
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
      {:shorter_maps, "~> 2.0"},
      {:ets_owner, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:ecto, "~> 2.2"},
      {:ecto_atom, "~> 1.0.0"},
      {:postgrex, "~> 0.13"},
      {:poison, "~> 3.0"}
    ]
  end
end
