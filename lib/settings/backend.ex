defprotocol Settings.Backend do
  @moduledoc """
  The backend protocol represents a client-defined datastore (probably
  persistent) to abstract those concerns from the intricacies of Settings.

  Clients should define a struct that implements this protocol, using the first
  parameter of the methods to store connection information, filename, Repo name,
  etc.

  """

  @doc """
  This method shall accept any term as a key, and return the value associated
  with that key, or  `{:error, :bad_key}` if the key does not exist.
  """
  def get(backend, key)

  @doc """
  This method shall accept any term as a key or value, overwriting previous
  values. The return value is ignored.
  """
  def set(backend, key, value)

  @doc """
  This method shall accept any term as a key, and remove it from the backend.
  The return value is ignored.
  """
  def del(backend, key)

  @doc """
  This methods must return a list of `{key, value}` for every key and value
  stored in the backend.
  """
  def all(backend)
end
