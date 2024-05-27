defmodule Plotlix.Plots do
  @moduledoc """
  The Plots context.
  """

  import Ecto.Query, warn: false

  alias Plotlix.Accounts.User
  alias Plotlix.Datasets
  alias Plotlix.Plots.Plot
  alias Plotlix.Plots.PlotlyParams
  alias Plotlix.PlotShares.PlotShare
  alias Plotlix.Repo

  @doc """
  Returns the list of plots for given user.

  ## Examples

      iex> list_user_plots(user)
      [%Plot{}, ...]

  """
  def list_user_plots(%User{id: user_id}) do
    query =
      from p in Plot,
        where: p.owner_id == ^user_id

    query
    |> Repo.all()
    |> Enum.map(&add_plotly_params/1)
  end

  @doc """
  Returns the list of plots shared with given user.

  ## Examples

      iex> list_shared_plots(user)
      [%Plot{}, ...]

  """
  def list_shared_plots(%User{id: user_id}) do
    query =
      from p in Plot,
        join: ps in PlotShare,
        on: p.id == ps.plot_id,
        where: ps.user_id == ^user_id,
        preload: [:owner]

    query
    |> Repo.all()
    |> Enum.map(&add_plotly_params/1)
  end

  def add_plotly_params(%Plot{dataset_name: dataset_name, expression: expression} = plot) do
    case plotly_params(dataset_name, expression) do
      {:ok, plotly_params} ->
        %Plot{plot | plotly_params: plotly_params}

      _ ->
        plot
    end
  end

  def add_plotly_params({:ok, %Plot{} = plot}), do: {:ok, add_plotly_params(plot)}
  def add_plotly_params({:error, _} = res), do: res

  def plotly_params(dataset_name, expression) do
    with {:ok, series} <- Datasets.eval_expression(dataset_name, expression),
         {:ok, encoded_series} <- Jason.encode(series) do
      {:ok, %PlotlyParams{series: encoded_series, x_title: expression, y_title: "Count of records"}}
    end
  end

  @doc """
  Gets a single plot for given user.

  Raises `Ecto.NoResultsError` if the Plot does not exist.

  ## Examples

      iex> get_plot!(user, 123)
      %Plot{}

      iex> get_plot!(user, 456)
      ** (Ecto.NoResultsError)

  """
  def get_plot!(%User{} = owner, id) do
    query = from p in Plot, where: p.id == ^id and p.owner_id == ^owner.id
    Repo.one!(query)
  end

  @doc """
  Creates a plot.

  ## Examples

      iex> create_plot(%{field: value})
      {:ok, %Plot{}}

      iex> create_plot(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_plot(attrs \\ %{}) do
    %Plot{}
    |> Plot.changeset(attrs)
    |> Repo.insert()
    |> add_plotly_params()
  end

  @doc """
  Updates a plot.

  ## Examples

      iex> update_plot(plot, %{field: new_value})
      {:ok, %Plot{}}

      iex> update_plot(plot, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_plot(%Plot{} = plot, attrs) do
    plot
    |> Plot.changeset(attrs)
    |> Repo.update()
    |> add_plotly_params()
  end

  @doc """
  Deletes a plot.

  ## Examples

      iex> delete_plot(plot)
      {:ok, %Plot{}}

      iex> delete_plot(plot)
      {:error, %Ecto.Changeset{}}

  """
  def delete_plot(%Plot{} = plot) do
    Repo.delete(plot)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking plot changes.

  ## Examples

      iex> change_plot(plot)
      %Ecto.Changeset{data: %Plot{}}

  """
  def change_plot(%Plot{} = plot, attrs \\ %{}) do
    Plot.changeset(plot, attrs)
  end
end
