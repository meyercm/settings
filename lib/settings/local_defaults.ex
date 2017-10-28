defmodule Settings.LocalDefaults do
  @moduledoc """

  This module's `using` macro allows specifying defaults for `Settings` that are
  scoped to the module that uses it.

  ### Example

  ```elixir
  defmodule LocalDefaultsExample do
    use Settings.LocalDefaults, app: :this_app

  end
  ```

  """
  defmacro __using__(opts) do
    quote do
      require Settings.Macros
      alias Settings.Macros, as: Settings
      Module.register_attribute(__MODULE__, :settings_local_defaults, persist: true)
      @settings_local_defaults unquote(opts)
    end
  end

  @doc false
  def get_local(module, opts_to_keep) do
    module.__info__(:attributes)
    |> Keyword.get(:settings_local_defaults)
    |> Keyword.take(opts_to_keep)
  end
end
