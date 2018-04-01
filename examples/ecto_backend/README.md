# SimpleApp

This is a single application, using the ecto settings backend, and is intended to showcase a simple way to setup
your application using `Settings`.

In particular, see `app_settings.ex`, which is used to populate the default
settings values, and serves as a point of reference for developers to know what
settings are available within the app, as well as the single location for adding
new settings to the application.

From the console, just run `iex -S mix` to play with this app. The
SimpleApp.Worker should be sending a log message every 5_000ms. To change it,
just modify the `:timer_tick_ms` setting.

Some things to try from `iex`:

- `Settings.get_all()`
- `Settings.get(:timer_tick_ms)`
- `Settings.set(:timer_tick_ms, 10_000)`
- `Settings.clear(:timer_tick_ms)`
