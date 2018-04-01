# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :settings, Settings.EctoBackend.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "settings",
  username: "postgres",
  password: "",
  hostname: "localhost",
  port: 5432,
  log: false


config :settings, ecto_repos: [Settings.EctoBackend.Repo]