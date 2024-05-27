defmodule Plotlix.PlotShares do
  @moduledoc false
  import Ecto.Query, warn: false

  alias Plotlix.Accounts.User
  alias Plotlix.Plots.Plot
  alias Plotlix.PlotShares.PlotShare
  alias Plotlix.Repo

  def list_plot_shares(%Plot{} = plot) do
    query =
      from PlotShare,
        where: [plot_id: ^plot.id],
        preload: [:user]

    Repo.all(query)
  end

  def list_available_accounts(%Plot{} = plot) do
    query =
      from u in User,
        left_join: ps in PlotShare,
        on: u.id == ps.user_id and ps.plot_id == ^plot.id,
        left_join: p in Plot,
        on: u.id == p.owner_id and p.id == ^plot.id,
        where: is_nil(ps.id) and is_nil(p.id)

    Repo.all(query)
  end

  def create_plot_share(%Plot{} = plot, attrs \\ %{}) do
    plot
    |> PlotShare.change_plot_share(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single plot_share.

  Raises `Ecto.NoResultsError` if the Plot share does not exist.

  ## Examples

      iex> get_plot_share!(123)
      %PlotShare{}

      iex> get_plot_share!(456)
      ** (Ecto.NoResultsError)

  """
  def get_plot_share!(id), do: Repo.get!(PlotShare, id)

  @doc """
  Deletes a plot_share.

  ## Examples

      iex> delete_plot_share(plot_share)
      {:ok, %PlotShare{}}

      iex> delete_plot_share(plot_share)
      {:error, %Ecto.Changeset{}}

  """
  def delete_plot_share(%PlotShare{} = plot_share) do
    Repo.delete(plot_share)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking plot_share changes.

  ## Examples

      iex> change_plot_share(plot_share)
      %Ecto.Changeset{data: %PlotShare{}}

  """
  def change_plot_share(%PlotShare{} = plot_share, attrs \\ %{}) do
    PlotShare.changeset(plot_share, attrs)
  end
end
