defmodule Wall.Repo.Migrations.CreateProject do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false

      timestamps
    end

    alter table(:events) do
      add :project_id, references(:projects)
    end
  end
end
