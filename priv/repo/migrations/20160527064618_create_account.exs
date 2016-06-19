defmodule Wall.Repo.Migrations.CreateAccount do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :email, :string, null: false
      add :family_name, :string
      add :given_name, :string
      add :hd, :string, null: false
      add :name, :string
      add :picture, :string
      add :sub, :string
      timestamps
    end

    create unique_index(:accounts, [:email])
  end
end
