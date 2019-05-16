defmodule SettingsBackend do
  @callback get(term()) :: {:ok, term()} | {:error, :notfound}
  @callback set(term(), term()) :: :ok | {:error, any()}
  @callback del(term()) :: :ok | {:error, any()}
  @callback get_all(term()) :: term()
end
