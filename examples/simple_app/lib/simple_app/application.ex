defmodule SimpleApp.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      Settings.InMemoryBackend, # first, start the backend
      SimpleApp.AppSettings,    # then load it with items
      SimpleApp.Worker,         # then start any clients
    ]
    opts = [strategy: :one_for_one, name: SimpleApp.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
