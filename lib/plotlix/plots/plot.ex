defmodule Plotlix.Plots.Plot do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset

  alias Plotlix.Accounts.User
  alias Plotlix.Datasets

  schema "plots" do
    field :name, :string
    field :dataset_name, :string
    field :expression, :string
    field :plotly_params, :map, virtual: true

    belongs_to :owner, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(plot, attrs) do
    changeset =
      plot
      |> cast(attrs, [:owner_id, :name, :dataset_name, :expression])
      |> validate_required([:owner_id, :name, :dataset_name, :expression])
      |> validate_change(:dataset_name, fn :dataset_name, dataset_name ->
        Datasets.validate_dataset_name(dataset_name)
      end)

    # Only check expression if dataset is valid
    if changeset.valid? do
      validate_change(changeset, :expression, fn :expression, expression ->
        dataset_name = get_field(changeset, :dataset_name)
        Datasets.validate_expression(dataset_name, expression)
      end)
    else
      changeset
    end
  end
end
