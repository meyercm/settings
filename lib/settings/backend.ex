defmodule Settings.Backend do
  @moduledoc """

  The `Settings.Backend` behavior represents a client-defined datastore
  (probably persistent) to abstract those concerns from the intricacies of
  managing settings.
  """
  @type app :: atom
  @type key :: term
  @type scope :: term
  @type value :: term

  @type settings_result :: {app, key, scope, value} # TODO: fix this.

  @doc """
  get/0 returns all settings in the backend
  """
  @callback get() :: [settings_result]

  @doc """
  get/1 returns all settings for an app in the backend
  """
  @callback get(app) :: [settings_result]

  @doc """
  get/2 returns all settings for an app, key pair (i.e. all scopes for a setting)
  """
  @callback get(app, key) :: [settings_result]

  @doc """
  get/3 accepts a list of scopes.
  """
  @callback get(app, key, [scope]) :: [settings_result]

  @doc """
  set/4 sets a value in the backend, and returns the value
  """
  @callback set(app, key, scope, value) :: value

  @doc """
  del/0 removes all settings from the backend
  """
  @callback del() :: :ok

  @doc """
  del/1 removes all settings for an app from the backend
  """
  @callback del(app) :: :ok

  @doc """
  del/2 removes all settings for an app/key pair in the backend
  """
  @callback del(app, key) :: :ok

  @doc """
  del/3 accepts a list of scopes
  """
  @callback del(app, key, [scope]) :: :ok

  #TODO: how to just keep :__default scope easily?
end
