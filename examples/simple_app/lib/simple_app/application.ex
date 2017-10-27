defmodule SimpleApp.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = []
    opts = [strategy: :one_for_one, name: SimpleApp.Supervisor]
    #FIXME: this is hideous.
    {:ok, _pid} = Settings.InMemoryBackend.start_link
    # load up the default settings before the app starts.
    # check ./app_settings.ex for more info.
    SimpleApp.AppSettings.load

    Supervisor.start_link(children, opts)
  end
end
