defmodule SettingsSpec do
  use ESpec

  describe "settings api" do
    describe "set(app, key, value, scope \\ :global)" do
      it "can set a value to the global scope"
      it "can set a value to a specific scope"
    end
    describe "get(app, key)" do
      it "returns {:error, :bad_key} if the setting does not exist"
      it "returns the value for the current node if the scope is set"
      it "returns the value for the global setting if there isn't a matching scope"
    end
    describe "lookup(app, key, scope \\ :global)" do
      it "returns {:error, :bad_key} if the setting does not exist"
      it "returns the value for the specified scope"
    end
    describe "Settings.delete(app, key)" do
      it "returns :ok when the setting does not exist"
      it "deletes the global scope"
      it "deletes specific scopes"
    end
    describe "delete(app, key, scope)" do
      it "returns :ok when the setting does not exist"
      it "deletes a specific scope"
    end
    describe "set_if_not_set(app, key, scope, value)" do
      it "returns the old value if already set"
      it "doesn't change the old value if already set"
      it "returns the new value if not previously set"
      it "sets a new value if not set"
    end
    describe "get_all()" do
      it "returns the list of all settings"
    end
    describe "get_all(app)" do
      it "returns the list of settings for the specifed app"
    end
  end
end
