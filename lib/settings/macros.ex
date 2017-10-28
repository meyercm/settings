defmodule Settings.Macros do
  @moduledoc false

  def set_defaults(opts \\ []), do: Elixir.Settings.set_defaults(opts)

  def get_defaults, do: Elixir.Settings.get_defaults

  defmacro create(name, default_value, opts \\ []) do
    quote do
      local_opts = Settings.LocalDefaults.get_local(__MODULE__, [:app, :backend])
      opts = Keyword.merge(local_opts, unquote(opts))
      Elixir.Settings.create(unquote(name), unquote(default_value), opts)
    end
  end

  defmacro get(name, opts \\ []) do
    quote do
      local_opts = Settings.LocalDefaults.get_local(__MODULE__, [:app, :backend])
      opts = Keyword.merge(local_opts, unquote(opts))
      Elixir.Settings.get(unquote(name), opts)
    end
  end

  defmacro set(name, value, opts \\ []) do
    quote do
      local_opts = Settings.LocalDefaults.get_local(__MODULE__, [:app, :backend])
      opts = Keyword.merge(local_opts, unquote(opts))
      Elixir.Settings.set(unquote(name), unquote(value), opts)
    end
  end

  defmacro all(opts \\ []) do
    quote do
      local_opts = Settings.LocalDefaults.get_local(__MODULE__, [:backend])
      opts = Keyword.merge(local_opts, unquote(opts))
      Elixir.Settings.all(opts)
    end
  end

  defmacro delete(name, opts \\ []) do
    quote do
      local_opts = Settings.LocalDefaults.get_local(__MODULE__, [:app, :backend])
      opts = Keyword.merge(local_opts, unquote(opts))
      Elixir.Settings.delete(unquote(name), opts)
    end
  end

  defmacro clear(name, opts \\ []) do
    quote do
      local_opts = Settings.LocalDefaults.get_local(__MODULE__, [:app, :backend])
      opts = Keyword.merge(local_opts, unquote(opts))
      Elixir.Settings.clear(unquote(name), opts)
    end
  end

end
