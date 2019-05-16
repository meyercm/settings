defmodule Settings.ConfigSettingsBackend do
  @moduledoc """
  Settings backend that does nothing allowing passthrough to the config file
  """
  @behaviour SettingsBackend
  def get(_key) do
    {:error, :notfound}
  end

  def set(_key, _val) do
    :ok
  end

  def del(_key) do
    :ok
  end

  def get_all(_app) do
    []
  end
end
