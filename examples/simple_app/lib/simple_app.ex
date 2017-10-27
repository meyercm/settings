defmodule SimpleApp do
  @moduledoc """
  From the console, just run `iex -S mix` to play with this app.

  Some other things to try from iex:

  - `Settings.get_all()`
  - `Settings.get_default(:setting_1)`
  """
  def get_setting_1 do
    # Because a default has been set for both application and backend, the
    # default opts are sufficient
    Settings.get(:setting_1)
  end

  def set_setting_1(new_value) do
    # this is something you'd want to do from the command line while debugging,
    # or possibly put in a script for provisioning.
    # Again, based on the simple nature of our app, the default opts are
    # sufficient.
    Settings.set(:setting_1, new_value)
  end



end
