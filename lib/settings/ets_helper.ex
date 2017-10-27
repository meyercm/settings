defmodule Settings.EtsHelper do
  @moduledoc false
  @table __MODULE__
  def _table, do: @table

  def setup, do: EtsOwner.create_table(@table, :set)

  def set(key, value) do
    setup()
    :ets.insert(@table, {key, value})
    :ok
  end

  def get(key) do
    setup()
    case :ets.lookup(@table, key) do
      [] -> nil
      [{^key, value}] -> value
    end
  end

  def del(key) do
    setup()
    :ets.delete(@table, key)
    :ok
  end

  def clear do
    setup()
    :ets.delete(@table)
    :ok
  end
end
