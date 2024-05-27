defmodule Plotlix.Repo.Migrations.CreatePlotShares do
  use Ecto.Migration

  def change do
    create table(:plot_shares) do
      add :plot_id, references(:plots, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:plot_shares, [:plot_id, :user_id])
  end
end
