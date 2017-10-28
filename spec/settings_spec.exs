defmodule SettingsSpec do
  use ESpec

  before do
    Settings.EtsHelper.clear()
  end

  describe "function-based api" do
    describe "defaults" do
      describe "set_defaults(opts)" do
        it "accepts a :backend" do
          result = Settings.set_defaults(backend: :a_backend)
          expect(result[:backend]) |> to(eq(:a_backend))
          expect(result[:app]) |> to(eq(:__none))
        end
        it "accepts an :app" do
          result = Settings.set_defaults(app: :an_app)
          expect(result[:app]) |> to(eq(:an_app))
          expect(result[:backend]) |> to(eq(:__none))
        end
      end
      describe "get_defaults" do
        it "starts with :__none for all" do
          expect(Settings.get_defaults[:backend]) |> to(eq :__none)
          expect(Settings.get_defaults[:app]) |> to(eq :__none)
        end
        it "returns the current defaults" do
          Settings.set_defaults(app: :my_app, backend: :my_backend)
          result = Settings.get_defaults
          expect(result[:backend]) |> to(eq :my_backend)
          expect(result[:app]) |> to(eq :my_app)
        end
      end
    end
    describe "using a backend" do
      before do
        {:ok, _pid} = Settings.InMemoryBackend.start_link
        Settings.set_defaults(app: :my_app, backend: Settings.InMemoryBackend)
      end
      finally do
        Settings.InMemoryBackend.stop
      end

      describe "create(name, default_value, opts)" do
        it "creates a default" do
          Settings.create(:name, :value)
          expect(Settings.get(:name) |> to(eq(:value)))
        end
        it "overwrites the old default" do
          Settings.create(:name, :value)
          Settings.create(:name, :new_value)
          expect(Settings.get(:name) |> to(eq(:new_value)))
        end
        it "allows specifying an app" do
          Settings.create(:name, :value, app: :other_app)
          expect(Settings.get(:name, app: :other_app))
          |> to(eq(:value))
        end
        it "allows specifying a custom backend" do
          Settings.set_defaults(backend: :nil)
          Settings.create(:name, :value, backend: Settings.InMemoryBackend)
          expect(Settings.get(:name))
          |> to(eq(:value))
        end
        it "returns the setting name" do
          expect(Settings.create(:name, :value)) |> to(eq(:name))
        end
      end
      describe "get(name, opts)" do
        it "can use a specific app" do
          Settings.create(:name, :value, app: :custom_app)
          expect(Settings.get(:name, app: :custom_app))
          |> to(eq(:value))
        end
        it "can use the default app" do
          Settings.create(:name, :value)
          expect(Settings.get(:name))
          |> to(eq(:value))
        end
        it "gets specific scope first" do
          Settings.create(:name, :default_value)
          Settings.set(:name, :global_value)
          Settings.set(:name, :specific_value, scope: :specific)
          expect(Settings.get(:name, scope: :specific))
          |> to(eq(:specific_value))
        end
        it "gets global scope if specific scope is not set" do
          Settings.create(:name, :default_value)
          Settings.set(:name, :global_value)
          expect(Settings.get(:name, scope: :specific))
          |> to(eq(:global_value))
        end
        it "gets default scope if specific and global scope are not set" do
          Settings.create(:name, :default_value)
          expect(Settings.get(:name, scope: :specific))
          |> to(eq(:default_value))
        end
        it "gets default scope if global scope isn't set" do
          Settings.create(:name, :default_value)
          expect(Settings.get(:name))
          |> to(eq(:default_value))
        end
        it "returns {:error, :bad_key} if the setting doesn't exist" do
          expect(Settings.get(:name)) |> to(eq({:error, :bad_key}))
        end
      end
      describe "set(name, value, opts)" do
        it "returns {:error, :bad_key} if the setting doesn't exist" do
          expect(Settings.set(:name, :value)) |> to(eq({:error, :bad_key}))
        end
      end
      describe "all(opts)" do
        it "returns all settings for one app if :app is specified" do
          Settings.create(:setting_1, :value, app: :other_app)
          Settings.create(:setting_2, :value)
          expect(Settings.all(app: :other_app) |> Enum.sort)
          |> to(eq([%{name: :setting_1, app: :other_app, value: :value, scope: :__default},
                    ] |> Enum.sort))
        end
        it "returns all settings in the backend if no :app is specified" do
          Settings.create(:setting_1, :value, app: :other_app)
          Settings.create(:setting_2, :value)
          expect(Settings.all())
          |> to(eq([%{name: :setting_1, app: :other_app, value: :value, scope: :__default},
                    %{name: :setting_2, app: :my_app, value: :value, scope: :__default}] |> Enum.sort))
        end
      end
      describe "delete(name, opts)" do
        it "removes all scopes for a setting" do
          Settings.create(:name, :default_value)
          Settings.set(:name, :global_value)
          Settings.set(:name, :specific_value, scope: :specific)
          Settings.delete(:name)
          expect(Settings.get(:name)) |> to(eq({:error, :bad_key}))
        end
        it "returns {:error, :bad_key} if the setting doesn't exist" do
          expect(Settings.delete(:name)) |> to(eq({:error, :bad_key}))
        end
        it "returns {:error, :bad_key} if the setting was just deleted" do
          Settings.create(:name, :default_value)
          Settings.delete(:name)
          expect(Settings.delete(:name)) |> to(eq({:error, :bad_key}))
        end
      end
      describe "clear(name, opts)" do
        it "clears a single specified scope" do
          Settings.create(:name, :default_value)
          Settings.set(:name, :global_value)
          Settings.set(:name, :specific_value, scope: :specific)
          Settings.clear(:name, scope: :specific)
          expect(Settings.get(:name, scope: :specific)) |> to(eq(:global_value))
        end
        it "clears all non-default scopes if not specified" do
          Settings.create(:name, :default_value)
          Settings.set(:name, :global_value)
          Settings.set(:name, :specific_value, scope: :specific)
          Settings.clear(:name)
          expect(Settings.get(:name)) |> to(eq(:default_value))
          expect(Settings.get(:name, scope: :specific)) |> to(eq(:default_value))
        end
        it "refuses to remove :__default" do
          Settings.create(:name, :default_value)
          Settings.clear(:name, scope: :__default)
          expect(Settings.get(:name)) |> to(eq(:default_value))
        end
      end
    end
  end
end
