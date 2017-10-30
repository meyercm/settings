defmodule Settings do
  @moduledoc """

  """
  alias Settings.EtsHelper
  @none :__none
  @default :__default
  @global :__global
  @all_but_default :__all_but_default
  @global_defaults :global_defaults


  @error_result {:error, :bad_key}
  @initial_defaults [app: @none, backend: @none]
  ##############################
  # API
  ##############################

  @doc """
  `set_defaults(opts)` accepts a keword list with the following valid keys:

  - `:backend` specify a default backend for all settings.
  - `:app`     specify a default app for all settings.

  This call's effect is scoped to the current Elixir node, and provides default
  values when the option is not specified in `get/2` or `set/3`. The function
  returns the defaults after the change is made.
  """
  def set_defaults(opts) do
    new_defaults = get_defaults()
                   |> Keyword.merge(opts)
    EtsHelper.set(@global_defaults, new_defaults)
    new_defaults
  end

  @doc """
  returns the current default app and backend. The initial values are `:__none`.

  ## Examples:

  ```elixir
  iex> Settings.get_defaults
  [app: :__none, backend: :__none]
  ...> Settings.set_defaults(app: :myapp)
  [app: :myapp, backend: :__none]
  ...> Settings.set_defaults(backend: MyBackend)
  [app: :myapp, backend: MyBackend]
  """
  def get_defaults do
    case EtsHelper.get(@global_defaults) do
      nil -> @initial_defaults
      other -> other
    end
  end

  @doc """
  `create(name, default_value, opts)` sets up a new setting, providing the name
  and default value. If `:backend` or `:app` are not specified in `opts`, they
  will default to those set using `set_defaults/1`

  When a persistent backend is used, `create` will update the default value for
  the setting, and will not impact overriding scopes already set.

  This function **must** be called each time the app is started.

  This function returns the setting name.

  #### Examples:

  ```elixir
  iex> Settings.set_defaults(app: :myapp, backend: MyBackend)
  [app: :myapp, backend: MyBackend]
  ...> Settings.create(:setting_1, "value")
  :setting_1
  ...> Settings.create(:setting_2, "value2", backend: OtherBackend)
  :setting_2
  ...> Settings.get(:setting_2) # <= retrieves from OtherBackend
  "value2"
  ```

  """
  @default_create_opts [app: @default, backend: @default]
  def create(name, default_value, opts \\ @default_create_opts) do
    opts = Keyword.merge(@default_create_opts, opts)
    backend = get_backend(Keyword.get(opts, :backend))
    app = get_app(Keyword.get(opts, :app))
    EtsHelper.set({:backend, app, name}, backend)
    apply(backend, :set, [app, name, @default, default_value])
    name
  end

  @doc """
  `get(name, opts)` retrieves a value for a setting. Valid opts:

  - `:app`      The application which this setting is part of. Default is
                `:__default`, which is replaced with `get_defaults[:app]`
  - `:scope`    The scope of the setting. Default: `:__global`
  - `:backend`  The backend to retrieve from. Default is :__default, which is
                replaced with `get_defaults[:backend]`

  `get` observes the following semantics: Settings first searches for a value
  matching `{app, name, scope}` using the scope passed in to `opts`. If nothing is
  found, Settings then searches for `{app, name, :__global}`, and finally for
  `{app, name, :__default}`

  ### Examples:

  ```elixir
  iex> Settings.create(:setting, "default_value")
  ...> Settings.set(:setting, "global_override")
  ...> Settings.set(:setting, "specific_scope", scope: node())
  ...> Settings.get(:setting, scope: node())
  "specific_scope"
  ...> Settings.get(:setting, scope: :other scope)
  "global_override"
  ```
  """
  @default_get_opts [app: @default, scope: @global, backend: @default]
  def get(name, opts \\ @default_get_opts) do
    opts = Keyword.merge(@default_get_opts, opts)
    app = get_app(Keyword.get(opts, :app))
    backend = get_backend_for(app, name, Keyword.get(opts, :backend))
    if exists?(backend, app, name) do
      scope = Keyword.get(opts, :scope)
      scopes = case scope do
        @global -> [@default, @global]
        other -> [@default, @global, other]
      end
      available_scopes = apply(backend, :get, [app, name, scopes])
                         |> Map.new(fn(map) -> {map.scope, map} end)
      do_get(backend, app, name, scope, available_scopes)
    else
      @error_result
    end
  end

  @doc """
  `set(name, value, opts)` sets a value for a setting. Valid opts:

  - `:app`      The application which this setting is part of. Default is
                `:__default`, which is replaced with `get_defaults[:app]`
  - `:scope`    The scope to set. Default: `:__global`
  - `:backend`  The backend to assign to. Default is :__default, which is
                replaced with `get_defaults[:backend]`

  This function returns the value that was set.
  """
  @default_set_opts [app: @default, scope: @global, backend: @default]
  def set(name, value, opts \\ @default_set_opts) do
    opts = Keyword.merge(@default_set_opts, opts)
    app = get_app(Keyword.get(opts, :app))
    scope = Keyword.get(opts, :scope)
    backend = get_backend_for(app, name, Keyword.get(opts, :backend))
    if exists?(backend, app, name) do
      apply(backend, :set, [app, name, scope, value])
      value
    else
      @error_result
    end
  end

  @doc """
  `all(opts)` retrieves all settings matching the options passed in. Valid opts:

  - `:app`      Limit the query to just this application's settings.
  - `:backend`  Retrieve from this backend

  `all` returns a list of maps, each having the following keys:

  - `:app`
  - `:name`
  - `:scope`
  - `:value`
  """
  @default_all_opts [app: @none, backend: @default]
  def all(opts \\ @default_all_opts) do
    opts = Keyword.merge(@default_all_opts, opts)
    app = Keyword.get(opts, :app)
    backend = get_backend(Keyword.get(opts, :backend))
    case app do
      @none -> apply(backend, :get, [])
      _ -> apply(backend, :get, [app])
    end
  end

  @doc """
  `delete(name, opts)` removes an entire setting from the backend.
  """
  @default_delete_opts [app: @default, backend: @default]
  def delete(name, opts \\ @default_delete_opts) do
    opts = Keyword.merge(@default_delete_opts, opts)
    app = get_app(Keyword.get(opts, :app))
    backend = get_backend_for(app, name, Keyword.get(opts, :backend))
    if exists?(backend, app, name) do
      apply(backend, :del, [app, name])
      EtsHelper.del({:backend, app, name})
    else
      @error_result
    end
  end

  @doc """
  `clear(name, opts)` removes overrides from the backend, without modifying the
  default value specified in `create/3`.

  If `:scope` is specified in `opts`, then clear will eliminate just that scope.
  Otherwise, `clear` will remove all overrides, restoring the setting to just
  the default value.
  """
  @default_clear_opts [app: @default, scope: @all_but_default, backend: @default]
  def clear(name, opts \\ @default_clear_opts) do
    opts = Keyword.merge(@default_clear_opts, opts)
    app = get_app(Keyword.get(opts, :app))
    backend = get_backend_for(app, name, Keyword.get(opts, :backend))
    scope = Keyword.get(opts, :scope)
    if exists?(backend, app, name) do
      do_clear(backend, app, name, scope)
    else
      @error_result
    end
  end

  ##############################
  # Internal Calls
  ##############################
  defp exists?(nil, _app, _name), do: false
  defp exists?(@none, _app, _name), do: false
  defp exists?(backend, app, name) do
    Enum.any?(apply(backend, :get, [app, name]))
  end
  defp get_backend(:__default) do
    EtsHelper.get(@global_defaults)[:backend]
  end
  defp get_backend(other), do: other

  defp get_backend_for(app, name, @default) do
    EtsHelper.get({:backend, app, name})
  end
  defp get_backend_for(_app, _name, other), do: other

  defp get_app(:__default) do
    EtsHelper.get(@global_defaults)[:app]
  end
  defp get_app(other), do: other

  defp do_get(_backend, _app, _name, @global, scopes) do
    Map.get(scopes, @global, scopes[@default])
    |> Map.get(:value)
  end
  defp do_get(backend, app, name, scope, scopes) do
    case Map.get(scopes, scope) do
      nil -> do_get(backend, app, name, @global, scopes)
      other -> Map.get(other, :value)
    end
  end

  defp do_clear(_backend, _app, _name, @default), do: :ok
  defp do_clear(backend, app, name, @all_but_default) do
    apply(backend, :keep_only, [app, name, [@default]])
  end
  defp do_clear(backend, app, name, scope) do
    apply(backend, :del, [app, name, [scope]])
  end
end
