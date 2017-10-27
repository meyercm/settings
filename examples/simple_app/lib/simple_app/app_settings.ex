defmodule SimpleApp.AppSettings do
  # TODO: use Settings.LocalDefaults, app: :device_manager
  # this method is idempotent and safe.  It can (and should) be run just before
  # application startup every time, to ensure that the backend has been
  # populated with the proper defaults.
  def load do
    Settings.set_defaults(backend: Settings.InMemoryBackend, app: :simple_app)

    # As we create settings, we specify the default value. Since `load` is called
    # each time the app starts, a developer can change values here, which will
    # update the default value.
    Settings.create(:setting_1, :value_1)
    Settings.create(:setting_2, "value_2")

  end
end
