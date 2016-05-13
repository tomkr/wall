defmodule Wall.Repo.Migrations.CreateEvent do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :payload, :map, null: false
      add :topic, :string, null: false
      add :status, :string, null: false
      add :date, :datetime, null: false
      add :subtopic, :string
      add :notes, :string
      timestamps
    end

  end
end
