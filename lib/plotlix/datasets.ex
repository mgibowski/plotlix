defmodule Plotlix.Datasets do
  @moduledoc false

  alias Plotlix.Datasets.Expression

  require Explorer.DataFrame, as: DF
  require Logger

  ## API

  def validate_dataset_name(dataset_name) do
    case get_dataset_names() do
      {:ok, valid_names} ->
        if Enum.member?(valid_names, dataset_name) do
          []
        else
          [dataset_name: "Not found"]
        end

      {:error, error} ->
        Logger.error("Unable to fetch dataset names, error: #{inspect(error)}")
        [dataset_name: "Could not verify dataset name"]
    end
  end

  def validate_expression(dataset_name, expression) do
    with {:ok, df} <- get_data_frame(dataset_name),
         {:ok, _expression} <- Expression.parse(df, expression) do
      []
    else
      {:error, error_msg} ->
        [expression: error_msg]
    end
  end

  def eval_expression(dataset_name, expression) do
    with {:ok, df} <- get_data_frame(dataset_name) do
      Expression.eval(df, expression)
    end
  end

  def get_column_names(dataset_name) do
    with {:ok, df} <- get_data_frame(dataset_name) do
      DF.names(df)
    end
  end

  ## Helpers
  ## Datasets are cached with :persistent_term for simplicity and performance

  defp get_dataset_names do
    key = :plotly_datasets_list

    case :persistent_term.get(key, nil) do
      nil ->
        with {:ok, resp} <- Req.get("https://api.github.com/repos/plotly/datasets/contents") do
          list =
            resp.body
            # Get file names
            |> Enum.map(& &1["name"])
            # Filter to csv files
            |> Enum.filter(&String.ends_with?(&1, ".csv"))
            # Strip the ".csv" file extension
            |> Enum.map(&String.replace(&1, ".csv", ""))
            # Store in cache
            |> tap(&:persistent_term.put(key, &1))

          {:ok, list}
        end

      list when is_list(list) ->
        {:ok, list}
    end
  end

  defp get_data_frame(dataset_name) do
    key = {:plotly_dataset, dataset_name}

    case :persistent_term.get(key, nil) do
      nil ->
        url = "https://raw.githubusercontent.com/plotly/datasets/master/#{dataset_name}.csv"

        with {:ok, df} <- DF.from_csv(url) do
          :persistent_term.put(key, df)
          {:ok, df}
        end

      %{} = df ->
        {:ok, df}
    end
  end
end
