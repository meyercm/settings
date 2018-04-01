# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :settings, Settings.EctoBackend.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "settings_repo",
  username: "elixir",
  password: "elixir",
  hostname: "localhost",
  port: 15432

config :ecto_app, ecto_repos: [Settings.EctoBackend.Repo]  