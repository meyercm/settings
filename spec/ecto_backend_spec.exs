defmodule EctoBackendSpec do
  use ESpec
  alias Settings.EctoBackend

  before do
    children = [
      Settings.EctoBackend.Repo,
      Settings.EctoBackend,
    ]
    opts = [strategy: :one_for_one, name: EctoBackendSpec.Supervisor]

    Supervisor.start_link(children, opts)
  end

  finally do
    EctoBackend.del()
  end

  describe "EctoBackend" do
    describe "set" do
      it "sets a setting" do
        EctoBackend.set(:the_app, :the_name, :the_scope, "the_value")
        expect(EctoBackend.get(:the_app, :the_name, [:the_scope]))
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_scope, value: "the_value"}]))
      end

      it "can overwrite a setting" do
        EctoBackend.set(:the_app, :the_name, :the_scope, "not_the_value")
        EctoBackend.set(:the_app, :the_name, :the_scope, "the_value")
        expect(EctoBackend.get(:the_app, :the_name, [:the_scope]))
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_scope, value: "the_value"}]))
      end
    end

    describe "get/0" do
      it "gets them all" do
        EctoBackend.set(:the_app, :the_name, :the_scope, "the_value")
        EctoBackend.set(:the_app, :the_name, :the_other_scope, "the_value")
        expect(EctoBackend.get() |> Enum.sort)
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_scope, value: "the_value"},
                  %{app: :the_app, name: :the_name, scope: :the_other_scope, value: "the_value"}]
                  |> Enum.sort))
      end
    end
    describe "get/1" do
      it "only gets the stuff for that app" do
        EctoBackend.set(:the_app, :the_name, :the_scope, "the_value")
        EctoBackend.set(:the_other_app, :the_name, :the_other_scope, "the_value")
        expect(EctoBackend.get(:the_other_app))
        |> to(eq([%{app: :the_other_app, name: :the_name, scope: :the_other_scope, value: "the_value"}]))
      end
    end
    describe "get/2" do
      it "gets all scopes for an app/name pair" do
        EctoBackend.set(:the_app, :the_name, :the_scope, "the_value")
        EctoBackend.set(:the_app, :the_name, :the_other_scope, "the_second_value")
        EctoBackend.set(:the_other_app, :the_other_name, :the_scope, "the_value")
        expect(EctoBackend.get(:the_app, :the_name) |> Enum.sort)
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_scope, value: "the_value"},
                  %{app: :the_app, name: :the_name, scope: :the_other_scope, value: "the_second_value"}]
                  |> Enum.sort))
      end
    end
    describe "get/3" do
      it "can get a single scope" do
        EctoBackend.set(:the_app, :the_name, :the_scope, "the_value")
        EctoBackend.set(:the_app, :the_name, :the_other_scope, "the_second_value")
        EctoBackend.set(:the_other_app, :the_other_name, :the_scope, "the_value")
        expect(EctoBackend.get(:the_app, :the_name, [:the_scope]) |> Enum.sort)
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_scope, value: "the_value"}]
                  |> Enum.sort))
      end
      it "can get multiple scopes" do
        EctoBackend.set(:the_app, :the_name, :the_scope, "the_value")
        EctoBackend.set(:the_app, :the_name, :the_other_scope, "the_second_value")
        EctoBackend.set(:the_other_app, :the_other_name, :the_scope, "the_value")
        expect(EctoBackend.get(:the_app, :the_name, [:the_scope, :the_other_scope]) |> Enum.sort)
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_scope, value: "the_value"},
                  %{app: :the_app, name: :the_name, scope: :the_other_scope, value: "the_second_value"}]
                  |> Enum.sort))
      end
    end

    describe "del/0" do
      it "removes everything from the backend" do
        EctoBackend.set(:the_app, :the_name, :the_scope, :the_value)
        EctoBackend.set(:the_app, :the_name, :the_other_scope, :the_second_value)
        EctoBackend.set(:the_other_app, :the_other_name, :the_scope, :the_value)
        expect(EctoBackend.del()) |> to(eq :ok)
        expect(EctoBackend.get()) |> to(eq([]))
      end
    end
    describe "del/1" do
      it "removes all settings for an app" do
        EctoBackend.set(:the_app, :the_name, :the_scope, "the_value")
        EctoBackend.set(:the_app, :the_name, :the_other_scope, "the_second_value")
        EctoBackend.set(:the_other_app, :the_other_name, :the_scope, "the_value")
        expect(EctoBackend.del(:the_app)) |> to(eq :ok)
        expect(EctoBackend.get() |> Enum.sort)
        |> to(eq([%{app: :the_other_app, name: :the_other_name, scope: :the_scope, value: "the_value"}]
                  |> Enum.sort))
      end
    end
    describe "del/2" do
      it "removes all scopes for an app/name" do
        EctoBackend.set(:the_app, :the_name, :the_scope, "the_value")
        EctoBackend.set(:the_app, :the_name, :the_other_scope, "the_second_value")
        EctoBackend.set(:the_app, :the_other_name, :the_scope, "the_value")
        expect(EctoBackend.del(:the_app, :the_name)) |> to(eq :ok)
        expect(EctoBackend.get() |> Enum.sort)
        |> to(eq([%{app: :the_app, name: :the_other_name, scope: :the_scope, value: "the_value"}]
                  |> Enum.sort))
      end
    end
    describe "del/3" do
      it "removes the specified scopes for an app/name" do
        EctoBackend.set(:the_app, :the_name, :the_scope, "the_value")
        EctoBackend.set(:the_app, :the_name, :the_other_scope, :the_second_value)
        EctoBackend.set(:the_app, :the_name, :the_third_scope, :the_third_value)
        expect(EctoBackend.del(:the_app, :the_name, [:the_other_scope, :the_third_scope])) |> to(eq :ok)
        expect(EctoBackend.get() |> Enum.sort)
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_scope, value: "the_value"}]
                  |> Enum.sort))

      end
    end
    describe "keep_only/3" do
      it "removes all scopes except those specified for an app/name" do
        EctoBackend.set(:the_app, :the_name, :the_scope, "the_value")
        EctoBackend.set(:the_app, :the_name, :the_other_scope, "the_second_value")
        EctoBackend.set(:the_app, :the_name, :the_third_scope, "the_third_value")
        expect(EctoBackend.keep_only(:the_app, :the_name, [:the_other_scope, :the_third_scope])) |> to(eq :ok)
        expect(EctoBackend.get() |> Enum.sort)
        |> to(eq([%{app: :the_app, name: :the_name, scope: :the_other_scope, value: "the_second_value"},
                  %{app: :the_app, name: :the_name, scope: :the_third_scope, value: "the_third_value"}]
                  |> Enum.sort))

      end
    end
  end
end
