defmodule Settings.InMemoryBackend do
  use GenServer
  import ShorterMaps
  @behaviour Settings.Backend
  @moduledoc """
  A simple backend for testing or for non-persistent storage
  of settings, and as a showcase for how a backend should look.
  """
  ##############################
  # API
  ##############################

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def stop() do
    GenServer.stop(__MODULE__)
  end


  @impl true
  def get() do
    GenServer.call(__MODULE__, :get)
  end

  @impl true
  def get(app) do
    GenServer.call(__MODULE__, {:get, app})
  end

  @impl true
  def get(app, name) do
    GenServer.call(__MODULE__, {:get, app, name})
  end

  @impl true
  def get(app, name, scopes) do
    GenServer.call(__MODULE__, {:get, app, name, scopes})
  end

  @impl true
  def set(app, name, scope, value) do
    GenServer.call(__MODULE__, {:set, app, name, scope, value})
  end

  @impl true
  def del() do
    GenServer.call(__MODULE__, :del)
  end

  @impl true
  def del(app) do
    GenServer.call(__MODULE__, {:del, app})
  end

  @impl true
  def del(app, name) do
    GenServer.call(__MODULE__, {:del, app, name})
  end

  @impl true
  def del(app, name, scopes) do
    GenServer.call(__MODULE__, {:del, app, name, scopes})
  end

  @impl true
  def keep_only(app, name, scopes) do
    GenServer.call(__MODULE__, {:keep_only, app, name, scopes})
  end

  defmodule State do
    @doc false
    defstruct [
      settings: %{},
    ]
  end

  ##############################
  # GenServer Callbacks
  ##############################

  @impl true
  def init([]) do
    {:ok, %State{}}
  end

  # :: [settings_result]
  @impl true
  def handle_call(:get, _from, ~M{settings} = state) do
    {:reply, Map.values(settings), state}
  end

  # :: [settings_result]
  @impl true
  def handle_call({:get, app}, _from, ~M{settings} = state) do
    result = settings
             |> Map.values
             |> Enum.filter(fn s -> s[:app] == app end)
    {:reply, result, state}
  end

  # :: [settings_result]
  @impl true
  def handle_call({:get, app, name}, _from, ~M{settings} = state) do
    result = settings
             |> Map.values
             |> Enum.filter(fn s -> s[:app] == app end)
             |> Enum.filter(fn s -> s[:name] == name end)
    {:reply, result, state}
  end

  # :: [settings_result]
  @impl true
  def handle_call({:get, app, name, scopes}, _from, ~M{settings} = state) do
    result = settings
             |> Map.values
             |> Enum.filter(fn s -> s[:app] == app end)
             |> Enum.filter(fn s -> s[:name] == name end)
             |> Enum.filter(fn s -> Enum.member?(scopes, s[:scope]) end)
    {:reply, result, state}
  end

  # :: value
  @impl true
  def handle_call({:set, app, name, scope, value}, _from, ~M{settings} = state) do
    settings = Map.put(settings, {app, name, scope}, ~M{app, name, scope, value})
    {:reply, value, ~M{state|settings}}
  end

  # :: :ok
  @impl true
  def handle_call(:del, _from, state) do
    {:reply, :ok, %{state|settings: %{}}}
  end

  # :: :ok
  @impl true
  def handle_call({:del, app}, _from, ~M{settings} = state) do
    settings = Enum.reject(settings, fn {{k_app, _k_name, _k_scope}, _v} -> k_app == app end) |> Enum.into(%{})
    {:reply, :ok, ~M{state|settings}}
  end

  # :: :ok
  @impl true
  def handle_call({:del, app, name}, _from, ~M{settings} = state) do
    settings = Enum.reject(settings, fn {{k_app, k_name, _k_scope}, _v} ->
                                        k_app == app &&
                                        k_name == name
                                     end) |> Enum.into(%{})
    {:reply, :ok, ~M{state|settings}}
  end

  # :: :ok
  @impl true
  def handle_call({:del, app, name, scopes}, _from, ~M{settings} = state) do
    settings = Enum.reject(settings, fn {{k_app, k_name, k_scope}, _v} ->
                                        k_app == app &&
                                        k_name == name &&
                                        Enum.member?(scopes, k_scope)
                                     end) |> Enum.into(%{})
    {:reply, :ok, ~M{state|settings}}
  end

  # :: :ok
  @impl true
  def handle_call({:keep_only, app, name, scopes}, _from, ~M{settings} = state) do
    settings = Enum.reject(settings, fn {{k_app, k_name, k_scope}, _v} ->
                                        k_app == app &&
                                        k_name == name &&
                                        !Enum.member?(scopes, k_scope)
                                     end) |> Enum.into(%{})
    {:reply, :ok, ~M{state|settings}}
  end


  ##############################
  # Internal Calls
  ##############################
end
