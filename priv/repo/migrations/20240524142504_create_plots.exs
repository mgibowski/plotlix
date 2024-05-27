defmodule Plotlix.Repo.Migrations.CreatePlots do
  use Ecto.Migration

  def change do
    create table(:plots) do
      add :name, :text
      add :dataset_name, :text
      add :expression, :text
      add :owner_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:plots, [:owner_id])
  end
end
