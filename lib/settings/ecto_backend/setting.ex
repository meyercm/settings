defmodule Settings.EctoBackend.Setting do
  use Ecto.Schema

  schema "setting" do
    field :app, Ecto.Atom
    field :name, Ecto.Atom
    field :scope, Ecto.Atom
    field :value, :map
  end

  def changeset(setting, params \\ %{}) do
    setting
    |> Ecto.Changeset.cast(params, [:app, :name, :scope, :value])
  end
end