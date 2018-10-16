defmodule Settings.EctoBackend.Repo do
  use Ecto.Repo, otp_app: :settings

  import Ecto.Query
  alias Settings.EctoBackend.Setting

  def get_setting() do 
    Setting 
      |> all
  end

  def get_setting(app) do 
    Setting 
      |> Ecto.Query.where(app: ^app)
      |> all
  end

  def get_setting(app, name) do 
    Setting 
      |> Ecto.Query.where(app: ^app)
      |> Ecto.Query.where(name: ^name)
      |> all
  end

  def get_setting(app, name, scopes) do 
    Setting 
      |> Ecto.Query.where(app: ^app)
      |> Ecto.Query.where(name: ^name)
      |> Ecto.Query.where([s], s.scope in ^scopes)
      |> all
  end

  def get_one_setting(app, name, scope) do 
    Setting 
      |> Ecto.Query.where(app: ^app)
      |> Ecto.Query.where(name: ^name)
      |> Ecto.Query.where(scope: ^scope)
      |> one
  end

  def keep_only(app, name, scopes) do 
    Setting 
      |> Ecto.Query.where([s], s.app == ^app)
      |> Ecto.Query.where([s], s.name == ^name)
      |> Ecto.Query.where([s], s.scope not in ^scopes)
      |> delete_all
  end

  def delete_setting(app) do
    Setting 
    |> Ecto.Query.where(app: ^app)
    |> delete_all
  end

  def delete_setting(app, name) do
    Setting 
      |> Ecto.Query.where(app: ^app)
      |> Ecto.Query.where(name: ^name)
      |> delete_all
  end

  def delete_setting(app, name, scopes) do
    Setting 
    |> Ecto.Query.where(app: ^app)
    |> Ecto.Query.where(name: ^name)
    |> Ecto.Query.where([s], s.scope in ^scopes)
    |> delete_all
  end
end