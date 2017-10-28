alias Settings.InMemoryBackend

defmodule TestingWrapper do
  @moduledoc """

  This module is a passthru to `Settings` from the perspective of a client
  module that has invoked the `LocalDefault.__using__/1` macro.

  """
  use Settings.LocalDefaults, app: :app1, backend: InMemoryBackend

  def all0, do: Settings.all
  def all1(opts), do: Settings.all(opts)
  def clear1(name), do: Settings.clear(name)
  def clear2(name, opts), do: Settings.clear(name, opts)
  def create2(name, default_val), do: Settings.create(name, default_val)
  def create3(name, default_val, opts), do: Settings.create(name, default_val, opts)
  def delete1(name), do: Settings.delete(name)
  def delete2(name, opts), do: Settings.delete(name, opts)
  def get1(name), do: Settings.get(name)
  def get2(name, opts), do: Settings.get(name, opts)
  def get_defaults0, do: Settings.get_defaults
  def set2(name, value), do: Settings.set(name, value)
  def set3(name, value, opts), do: Settings.set(name, value, opts)
  def set_defaults1(opts), do: Settings.set_defaults(opts)
end

defmodule Settings.LocalDefaultsSpec do
  use ESpec

  describe "get_and_set_defaults" do
    it "provides direct passthrough to the regular Settings module" do
      original_defaults = Settings.get_defaults
      expect(TestingWrapper.get_defaults0) |> to(eq original_defaults)
      new_defaults = [app: :new_app, backend: :new_backend]
      TestingWrapper.set_defaults1(new_defaults)
      # this is the test on set_defaults
      expect(TestingWrapper.get_defaults0) |> to(eq new_defaults)
      # undo our changes for the other tests
      Settings.set_defaults(original_defaults)
    end
  end

  describe "methods against the backend" do
    before do
      {:ok, _pid} = Settings.InMemoryBackend.start_link
      # set a default that is overridden in `TestingWrapper`
      Settings.set_defaults(app: :app2)
      # set up some Settings to test against
      Settings.create(:setting1, :default1, app: :app1, backend: InMemoryBackend)
      Settings.create(:setting2, :default2, app: :app1, backend: InMemoryBackend)
      Settings.create(:setting1, :default3, app: :app2, backend: InMemoryBackend)
      Settings.create(:setting2, :default4, app: :app2, backend: InMemoryBackend)
      Settings.set(:setting2, :global2, app: :app1)
      Settings.set(:setting2, :global4, app: :app2)

      Settings.create(:setting3, :default5, app: :app1, backend: InMemoryBackend)
      Settings.set(:setting3, :specific5, app: :app1, scope: :specific, backend: InMemoryBackend)
    end
    finally do
      Settings.InMemoryBackend.stop
    end

    describe "all" do
      it "provides the same answer as the function" do
        via_macros = TestingWrapper.all0 |> Enum.sort
        via_functions = Settings.all(backend: InMemoryBackend) |> Enum.sort
        expect(via_macros) |> to(eq(via_functions))
      end

      it "scopes to the specified app" do
        via_macros = TestingWrapper.all1(app: :app2) |> Enum.sort
        via_functions = Settings.all(app: :app2, backend: InMemoryBackend) |> Enum.sort
        expect(via_macros) |> to(eq(via_functions))
      end
    end

    describe "clear" do
      it "impacts a setting from the local default app" do
        expect(Settings.get(:setting2, app: :app1, backend: InMemoryBackend)) |> to(eq :global2)
        TestingWrapper.clear1(:setting2)
        expect(Settings.get(:setting2, app: :app1, backend: InMemoryBackend)) |> to(eq :default2)
      end
      it "impacts a setting with a custom app specified" do
        expect(Settings.get(:setting2, app: :app2, backend: InMemoryBackend)) |> to(eq :global4)
        TestingWrapper.clear2(:setting2, app: :app2)
        expect(Settings.get(:setting2, app: :app2, backend: InMemoryBackend)) |> to(eq :default4)
      end
    end

    describe "get" do
      it "uses the local app" do
        expect(TestingWrapper.get1(:setting1)) |> to(eq :default1)
      end
      it "uses the local app with custom scope" do
        expect(TestingWrapper.get2(:setting3, scope: :specific)) |> to(eq :specific5)
      end
      it "allows overriding the app" do
        expect(TestingWrapper.get2(:setting1, app: :app2)) |> to(eq :default3)
      end
    end

    describe "create" do
      it "uses the local app" do
        TestingWrapper.create2(:new_setting, :new_value)
        expect(Settings.get(:new_setting, app: :app1, backend: InMemoryBackend))
        |> to(eq(:new_value))
      end
      it "allows overriding the app" do
        TestingWrapper.create3(:new_setting, :new_value2, app: :app2)
        expect(Settings.get(:new_setting, app: :app2, backend: InMemoryBackend))
        |> to(eq(:new_value2))
      end
    end
    describe "delete" do
      it "uses the local app" do
        TestingWrapper.delete1(:setting1)
        expect(Settings.get(:setting1, app: :app1, backend: InMemoryBackend))
        |> to(eq({:error, :bad_key}))
      end
      it "allows overriding the app" do
        TestingWrapper.delete2(:setting1, app: :app2)
        expect(Settings.get(:setting1, app: :app2, backend: InMemoryBackend))
        |> to(eq({:error, :bad_key}))
      end
    end
    describe "set" do
      it "uses the local app" do
        TestingWrapper.set2(:setting1, :global_value)
        expect(Settings.get(:setting1, app: :app1, backend: InMemoryBackend))
        |> to(eq(:global_value))
      end
      it "uses the local app with custom scope" do
        TestingWrapper.set3(:setting1, :scoped_value, scope: :custom_scope)
        expect(Settings.get(:setting1, app: :app1, backend: InMemoryBackend, scope: :custom_scope))
        |> to(eq(:scoped_value))
      end
      it "allows overriding the app" do
        TestingWrapper.set3(:setting1, :global_value, app: :app2)
        expect(Settings.get(:setting1, app: :app2, backend: InMemoryBackend))
        |> to(eq(:global_value))
      end
    end
  end
end
