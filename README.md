# Settings

Use `Settings` to provide a database-backed update-able settings system with
a fallback to a configuration file.

Calling `Settings.set_backend(My.Backend.Api)` (which must conform to
`@behaviour SettingsBackend`) will allow you to get and set settings.

Also provided is a ConfigSettingsBackend that will just fallback to the config
file; this is useful for testing distributed apps in isolation.

In general:
* Settings that are present in the backend are loaded from the backend.
* Settings that are not present in the backend are loaded from the app's
config file.
* Overwriting a setting only happens in the backend, the config file is not
modified.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `settings` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:settings, "~> 0.1.0"}]
    end
    ```

  2. Ensure `settings` is started before your application:

    ```elixir
    def application do
      [applications: [:settings]]
    end
    ```
