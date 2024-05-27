defmodule Plotlix.PlotSharesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Plotlix.PlotShares` context.
  """

  @doc """
  Generate a plot_share.
  """
  def plot_share_fixture(plot, attrs \\ %{}) do
    attrs = Map.new(attrs)

    {:ok, plot_share} =
      Plotlix.PlotShares.create_plot_share(plot, attrs)

    plot_share
  end
end
