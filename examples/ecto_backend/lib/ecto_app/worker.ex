defmodule EctoApp.Worker do
  use GenServer
  ##############################
  # API
  ##############################

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  defmodule State do
    @doc false
    defstruct [
    ]
  end

  ##############################
  # GenServer Callbacks
  ##############################

  def init([]) do
    start_timer()
    {:ok, %State{}}
  end

  def handle_info(:tick, state) do
    require Logger
    Logger.info("tick!")
    start_timer()
    {:noreply, state}
  end

  ##############################
  # Internal Calls
  ##############################

  def start_timer do
    delay = Settings.get(:timer_tick_ms)
    Process.send_after(self(), :tick, delay)
  end
end
