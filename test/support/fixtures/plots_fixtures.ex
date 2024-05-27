defmodule Plotlix.PlotsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Plotlix.Plots` context.
  """

  import Plotlix.AccountsFixtures

  @doc """
  Generate a plot.
  """
  def plot_fixture(attrs \\ %{}) do
    attrs =
      case attrs do
        %{owner_id: _owner_id} ->
          attrs

        _ ->
          owner = user_fixture()
          Map.put(attrs, :owner_id, owner.id)
      end

    {:ok, plot} =
      attrs
      |> Enum.into(%{
        dataset_name: "iris",
        expression: "SepalWidth",
        name: "some name"
      })
      |> Plotlix.Plots.create_plot()

    plot
  end
end
