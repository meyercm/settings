defmodule Settings.EctoBackend.Repo.Migrations.CreateSetting do
  use Ecto.Migration

  def change do
    create table(:setting) do
      add :app, :string
      add :name, :string
      add :scope, :string
      add :value, :map
    end
  end
end
