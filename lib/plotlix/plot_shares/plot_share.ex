defmodule Plotlix.PlotShares.PlotShare do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Plotlix.Accounts.User
  alias Plotlix.Plots.Plot

  schema "plot_shares" do
    field :plot_id, :id
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def change_plot_share(%Plot{} = plot, attrs \\ %{}) do
    attrs = Map.put(attrs, "plot_id", plot.id)

    %__MODULE__{}
    |> cast(attrs, [:plot_id, :user_id])
    |> validate_required([:plot_id, :user_id])
  end

  @doc false
  def changeset(plot_share, attrs) do
    plot_share
    |> cast(attrs, [:plot_id, :user_id])
    |> validate_required([:plot_id, :user_id])
  end
end
