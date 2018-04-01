defmodule Settings.EctoBackend do
  use GenServer
  alias Settings.EctoBackend.Repo
  alias Settings.EctoBackend.Setting
  @behaviour Settings.Backend
  @moduledoc """
  A backend which uses Ecto as persistence.
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

  ##############################
  # GenServer Callbacks
  ##############################

  @impl true
  def init([]) do
    {:ok, []}
  end

  # :: [settings_result]
  @impl true
  def handle_call(:get, _from, _state) do
    case Repo.get_setting() do
      nil -> {:reply, %{}, []}
      values -> {:reply, values |> Enum.map( &map_setting/1), []}
    end
  end

  # :: [settings_result]
  @impl true
  def handle_call({:get, app}, _from, _state) do
    case Repo.get_setting(app) do
      nil -> {:reply, %{}, []}
      values -> {:reply, values |> Enum.map( &map_setting/1), []}
    end
  end

  # :: [settings_result]
  @impl true
  def handle_call({:get, app, name}, _from, _state) do
    case Repo.get_setting(app, name) do
      nil -> {:reply, %{}, []}
      values -> {:reply, values |> Enum.map( &map_setting/1), []}
    end
  end

  # :: [settings_result]
  @impl true
  def handle_call({:get, app, name, scopes}, _from, _state) do
    case Repo.get_setting(app, name, scopes) do
      nil -> {:reply, %{}, []}
      values -> {:reply, values |> Enum.map( &map_setting/1), []}
    end
  end

  # :: value
  @impl true
  def handle_call({:set, app, name, scope, value}, _from, _state) do
    changeset = case Repo.get_one_setting(app, name, scope) do
      nil -> 
        Setting.changeset(%Setting{}, %{app: app, name: name, scope: scope, value: %{value: value}})
      s -> 
        Setting.changeset(s, %{value: %{value: value}})
    end
    Repo.insert_or_update(changeset)
    {:reply, value, []}
  end

  # :: :ok
  @impl true
  def handle_call(:del, _from, _state) do
    Repo.delete_all(Setting)
    {:reply, :ok, %{}}
  end

  # :: :ok
  @impl true
  def handle_call({:del, app}, _from, _state) do
    Repo.delete_setting(app)
    {:reply, :ok, %{}}
  end

  # :: :ok
  @impl true
  def handle_call({:del, app, name}, _from, _state) do
    Repo.delete_setting(app, name)
    {:reply, :ok, %{}}
  end

  # :: :ok
  @impl true
  def handle_call({:del, app, name, scopes}, _from, _state) do
    Repo.delete_setting(app, name, scopes)
    {:reply, :ok, %{}}
  end

  # :: :ok
  @impl true
  def handle_call({:keep_only, app, name, scopes}, _from, _state) do
    Repo.keep_only(app, name, scopes)
    {:reply, :ok, %{}}
  end


  ##############################
  # Internal Calls
  ##############################
  defp map_setting(s) do
    %{app: s.app, name: s.name, scope: s.scope, value: s.value["value"]}
  end

end