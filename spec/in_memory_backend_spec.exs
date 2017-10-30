defmodule InMemoryBackendSpec do
  use ESpec
  alias Settings.InMemoryBackend

  before do
    {:ok, _pid} = InMemoryBackend.start_link([])
  end

  finally do
    InMemoryBackend.stop
  end

  describe "InMemoryBackend" do
    describe "set" do
      it "sets a setting" do
        InMemoryBackend.set(:the_app, :the_name, :the_scope, :the_value)
        expect(InMemoryBackend.get(:the_app, :the_name, [:the_scope]))
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_scope, value: :the_value}]))
      end

      it "can overwrite a setting" do
        InMemoryBackend.set(:the_app, :the_name, :the_scope, :not_the_value)
        InMemoryBackend.set(:the_app, :the_name, :the_scope, :the_value)
        expect(InMemoryBackend.get(:the_app, :the_name, [:the_scope]))
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_scope, value: :the_value}]))
      end
    end

    describe "get/0" do
      it "gets them all" do
        InMemoryBackend.set(:the_app, :the_name, :the_scope, :the_value)
        InMemoryBackend.set(:the_app, :the_name, :the_other_scope, :the_value)
        expect(InMemoryBackend.get() |> Enum.sort)
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_scope, value: :the_value},
                  %{app: :the_app, name: :the_name, scope: :the_other_scope, value: :the_value}]
                  |> Enum.sort))
      end
    end
    describe "get/1" do
      it "only gets the stuff for that app" do
        InMemoryBackend.set(:the_app, :the_name, :the_scope, :the_value)
        InMemoryBackend.set(:the_other_app, :the_name, :the_other_scope, :the_value)
        expect(InMemoryBackend.get(:the_other_app))
        |> to(eq([%{app: :the_other_app, name: :the_name, scope: :the_other_scope, value: :the_value}]))
      end
    end
    describe "get/2" do
      it "gets all scopes for an app/name pair" do
        InMemoryBackend.set(:the_app, :the_name, :the_scope, :the_value)
        InMemoryBackend.set(:the_app, :the_name, :the_other_scope, :the_second_value)
        InMemoryBackend.set(:the_other_app, :the_other_name, :the_scope, :the_value)
        expect(InMemoryBackend.get(:the_app, :the_name) |> Enum.sort)
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_scope, value: :the_value},
                  %{app: :the_app, name: :the_name, scope: :the_other_scope, value: :the_second_value}]
                  |> Enum.sort))
      end
    end
    describe "get/3" do
      it "can get a single scope" do
        InMemoryBackend.set(:the_app, :the_name, :the_scope, :the_value)
        InMemoryBackend.set(:the_app, :the_name, :the_other_scope, :the_second_value)
        InMemoryBackend.set(:the_other_app, :the_other_name, :the_scope, :the_value)
        expect(InMemoryBackend.get(:the_app, :the_name, [:the_scope]) |> Enum.sort)
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_scope, value: :the_value}]
                  |> Enum.sort))
      end
      it "can get multiple scopes" do
        InMemoryBackend.set(:the_app, :the_name, :the_scope, :the_value)
        InMemoryBackend.set(:the_app, :the_name, :the_other_scope, :the_second_value)
        InMemoryBackend.set(:the_other_app, :the_other_name, :the_scope, :the_value)
        expect(InMemoryBackend.get(:the_app, :the_name, [:the_scope, :the_other_scope]) |> Enum.sort)
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_scope, value: :the_value},
                  %{app: :the_app, name: :the_name, scope: :the_other_scope, value: :the_second_value}]
                  |> Enum.sort))
      end
    end

    describe "del/0" do
      it "removes everything from the backend" do
        InMemoryBackend.set(:the_app, :the_name, :the_scope, :the_value)
        InMemoryBackend.set(:the_app, :the_name, :the_other_scope, :the_second_value)
        InMemoryBackend.set(:the_other_app, :the_other_name, :the_scope, :the_value)
        expect(InMemoryBackend.del()) |> to(eq :ok)
        expect(InMemoryBackend.get()) |> to(eq([]))
      end
    end
    describe "del/1" do
      it "removes all settings for an app" do
        InMemoryBackend.set(:the_app, :the_name, :the_scope, :the_value)
        InMemoryBackend.set(:the_app, :the_name, :the_other_scope, :the_second_value)
        InMemoryBackend.set(:the_other_app, :the_other_name, :the_scope, :the_value)
        expect(InMemoryBackend.del(:the_app)) |> to(eq :ok)
        expect(InMemoryBackend.get() |> Enum.sort)
        |> to(eq([%{app: :the_other_app, name: :the_other_name, scope: :the_scope, value: :the_value}]
                  |> Enum.sort))
      end
    end
    describe "del/2" do
      it "removes all scopes for an app/name" do
        InMemoryBackend.set(:the_app, :the_name, :the_scope, :the_value)
        InMemoryBackend.set(:the_app, :the_name, :the_other_scope, :the_second_value)
        InMemoryBackend.set(:the_app, :the_other_name, :the_scope, :the_value)
        expect(InMemoryBackend.del(:the_app, :the_name)) |> to(eq :ok)
        expect(InMemoryBackend.get() |> Enum.sort)
        |> to(eq([%{app: :the_app, name: :the_other_name, scope: :the_scope, value: :the_value}]
                  |> Enum.sort))
      end
    end
    describe "del/3" do
      it "removes the specified scopes for an app/name" do
        InMemoryBackend.set(:the_app, :the_name, :the_scope, :the_value)
        InMemoryBackend.set(:the_app, :the_name, :the_other_scope, :the_second_value)
        InMemoryBackend.set(:the_app, :the_name, :the_third_scope, :the_third_value)
        expect(InMemoryBackend.del(:the_app, :the_name, [:the_other_scope, :the_third_scope])) |> to(eq :ok)
        expect(InMemoryBackend.get() |> Enum.sort)
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_scope, value: :the_value}]
                  |> Enum.sort))

      end
    end
    describe "keep_only/3" do
      it "removes all scopes except those specified for an app/name" do
        InMemoryBackend.set(:the_app, :the_name, :the_scope, :the_value)
        InMemoryBackend.set(:the_app, :the_name, :the_other_scope, :the_second_value)
        InMemoryBackend.set(:the_app, :the_name, :the_third_scope, :the_third_value)
        expect(InMemoryBackend.keep_only(:the_app, :the_name, [:the_other_scope, :the_third_scope])) |> to(eq :ok)
        expect(InMemoryBackend.get() |> Enum.sort)
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_other_scope, value: :the_second_value},
                  %{app: :the_app, name: :the_name, scope: :the_third_scope, value: :the_third_value}]
                  |> Enum.sort))

      end
    end
  end
end
