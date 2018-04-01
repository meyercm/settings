defmodule EctoApp.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      Settings.EctoBackend.Repo,
      Settings.EctoBackend,
      #Settings.InMemoryBackend,
      EctoApp.AppSettings,    # then load it with items
      # EctoApp.Worker,         # then start any clients
    ]
    opts = [strategy: :one_for_one, name: SimpleApp.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
