defmodule EctoApp.AppSettings do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    load()
    {:ok, []}
  end

  # this method is idempotent and safe.  It can (and should) be run just before
  # every application startup, to ensure that the backend has been populated
  # with the proper defaults.
  def load do
    Settings.set_defaults(backend: Settings.EctoBackend, app: :ecto_app)

    # As we create settings, we specify the default value. Since `load` is called
    # each time the app starts, a developer can change values here, which will
    # update the default value.
    Settings.create(:timer_tick_ms, 5_000)
    Settings.create(:another_setting, "another_value")

  end
end
