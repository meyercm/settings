defmodule Settings do
  use GenServer

  ##############################
  # API
  ##############################

  @doc """
  Start Settings. The `setting_backend_module` must implement
  `@behaviour SettingsBackend`.
  """
  def start_link(setting_backend_module) do
    GenServer.start_link(__MODULE__, [setting_backend_module], [name: __MODULE__])
  end

  @doc """
  Sets the backend module
  """
  def set_backend(setting_backend_module) do
    GenServer.call(__MODULE__, {:set_backend, setting_backend_module})
  end

  @doc """

  Returns map of settings both in config files and backend for given application

  """
  @spec get_all(atom) :: any
  def get_all(app), do: GenServer.call(__MODULE__, {:get_all, app})

  @doc """

  Retrieves a setting, from {scope, app, key} and will return default
  First, checks the setting_backend_module for a setting, and if not found,
  gives the default.

  Returns value or raises a match error on failure
  """
  @spec get_scoped(atom, atom, atom, any()) :: any
  def get_scoped(scope, app, key, default \\ nil) do
    case GenServer.call(__MODULE__, {:get, scope, get_app(app), key}) do
      {:ok, val} -> val
      {:error, :notfound} -> default
      error -> error
    end
  end
  @doc """
  Retrieves a setting, from {scope, app, key}
  First, checks the setting_backend_module for a setting, and if not found,
  pulls from the app env.

  Returns value or raises a match error on failure
  """
  @spec get(atom, atom, atom) :: any
  def get(app, key, default \\ nil), do: get_scoped(:global, app, key, default)

  @doc """
  Retrieves a setting, from {:global, :__unspecified, key}
  First, checks the setting_backend_module for a setting, and if not found,
  pulls from the app env.

  Returns value or raises a match error on failure
  """
  @spec get(atom) :: any
  def get(key), do: get(:__unspecified, key)

  @doc """
  Sets a setting, {scope, app, key} == value.

  Does not require that the setting already exist in the app_env; any setting
  may be set for any application (even applications which do not exist).

  Returns :ok or {:error, reason}
  """
  @spec set(atom, atom, atom, any) :: any
  def set(scope, app, key, value), do: GenServer.call(__MODULE__, {:set, scope, get_app(app), key, value})

  @doc """
  Sets a setting, {:global, app, key} == value.

  Does not require that the setting already exist in the app_env; any setting
  may be set for any application (even applications which do not exist).

  Returns :ok or {:error, reason}
  """
  @spec set(atom, atom, any) :: any
  def set(app, key, value), do: set(:global, app, key, value)

  @doc """
  Sets a setting, {:global, :__unspecified, key} == value.

  Does not require that the setting already exist in the app_env; any setting
  may be set for any application (even applications which do not exist).

  Returns :ok or {:error, reason}
  """
  @spec set(atom, any) :: any
  def set(key, value), do: set(:__unspecified, key, value)

  @doc """
  Removes a scope, app, key from the setting_backend_module store

  This has the effect of making completely custom settings unavailable, and
  of making pre-defined settings revert to their defaults.

  Returns :ok or {:error, reason}
  """
  @spec del(atom, atom, atom) :: any
  def del(scope, app, key), do: GenServer.call(__MODULE__, {:del, scope, get_app(app), key})

  @doc """
  Removes a :global, app, key from the setting_backend_module store

  This has the effect of making completely custom settings unavailable, and
  of making pre-defined settings revert to their defaults.

  Returns :ok or {:error, reason}
  """
  @spec del(atom, atom) :: any
  def del(app, key), do: del(:global, app, key)

  @doc """
  Removes a :global, :__unspecified, key from the setting_backend_module store

  This has the effect of making completely custom settings unavailable, and
  of making pre-defined settings revert to their defaults.

  Returns :ok or {:error, reason}
  """
  @spec del(atom) :: any
  def del(key), do: del(:__unspecified, key)

  @doc """
  Returns the app_env specified setting value

  Bypassing the setting_backend_module store, this method checks to see what the setting was in the
  application environment.

  Returns value or raises a match error on failure
  """
  @spec default(atom, atom) :: any
  def default(app \\ :__unspecified, key) do
    {:ok, val} = GenServer.call(__MODULE__, {:default, get_app(app), key})
    val
  end

  defmodule State do
    @doc false
    defstruct [
      sbm: nil, # settings_backend_module
    ]
  end

  ##############################
  # GenServer Callbacks
  ##############################

  def init([setting_backend_module]) do
    {:ok, %State{sbm: setting_backend_module}}
  end

  def handle_call({:set_backend, sbm}, _from, _state) do
    {:reply, :ok, %State{sbm: sbm}}
  end

  def handle_call({:get, scope, app, key}, _from, state) do
    {result, new_state} = do_get(state, scope, app, key)
    {:reply, result, new_state}
  end

  def handle_call({:set, scope, app, key, val}, _from, state) do
    {result, new_state} = do_set(state, scope, app, key, val)
    {:reply, result, new_state}
  end

  def handle_call({:del, scope, app, key}, _from, state) do
    {result, new_state} = do_del(state, scope, app, key)
    {:reply, result, new_state}
  end

  def handle_call({:default, app, key}, _from, state) do
    {result, new_state} = do_default(state, app, key)
    {:reply, result, new_state}
  end

  def handle_call({:get_all, app}, _from, state) do
    result = do_get_all(app, state)
    {:reply, result, state}
  end

  ##############################
  # Internal Calls
  ##############################

  def get_app(:__unspecified) do
      case :application.get_application do
        {:ok, app} -> app
        :undefined -> :undefined
      end
  end
  def get_app(app), do: app

  def do_get(state, scope, app, key) do
    result =
      case apply(state.sbm, :get, [{scope, app, key}]) do
        {:ok, val}          -> {:ok, val}
        {:error, :notfound} -> do_default(state, app, key)
      end
    {result, state}
  end
  def do_get_all(app, state) do
    backend_results = apply(state.sbm, :get_all, [app])
    default_results = Application.get_all_env(app)
                      |> Enum.map(fn {k, v} -> {{:global, app, k}, v} end)
    # Rely on the side effect that Map.new keeps the last key when a duplicate occurs
    Map.new(default_results ++ backend_results)
  end
  def do_set(state, scope, app, key, val), do: {apply(state.sbm, :set, [{scope, app, key}, val]), state}
  def do_del(state, scope, app, key), do: {apply(state.sbm, :del, [{scope, app, key}]), state}
  def do_default(_state, app, key) do
    case Application.get_env(app, key, __MODULE__.NotFound) do
      __MODULE__.NotFound -> {:error, :notfound}
      val                 -> {:ok, val}
    end
  end

end
