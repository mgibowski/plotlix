defmodule Plotlix.Datasets.Expression do
  @moduledoc false

  require Explorer.DataFrame, as: DF

  ## API

  def validate(df, expression) do
    with {:ok, expression} <- parse(df, expression) do
      # Attempt to evaluate the expression
      try do
        # The underlying `DF.mutate/2` from Explorer may raise an error when column types are mismatched
        _discarded = apply_expression(df, expression)
        :ok
      rescue
        ArgumentError -> {:error, "Invalid expression - mismatched column types"}
      end
    end
  end

  def eval(df, expression) do
    with {:ok, expression} <- parse(df, expression) do
      {:ok, apply_expression(df, expression)}
    end
  end

  ## Helpers

  defp parse(df, expression) do
    # Match expression pattern using regex
    case match_expression(expression) do
      {:ok, {:single_column, col}} = res ->
        # Validate column name
        if column_exists?(df, col), do: res, else: {:error, "Invalid expression"}

      {:ok, {:binary_operation, %{column1: col_1, column2: col_2}}} = res ->
        # Validate column names
        if column_exists?(df, col_1) && column_exists?(df, col_2), do: res, else: {:error, "Invalid expression"}

      error ->
        error
    end
  end

  defp match_expression(expression) do
    regex_single_column = ~r/^[\w\s]+$/
    regex_unquoted_binary_operation = ~r/^([\w\s]+)\s*([\+\-\*\/])\s*([\w\s]+)$/
    regex_quoted_binary_operation = ~r/^'([^']+)'\s*([\+\-\*\/])\s*'([^']+)'$/

    case Regex.run(regex_quoted_binary_operation, expression) do
      [_, col1, operator, col2] ->
        {:ok, {:binary_operation, %{column1: col1, operator: operator, column2: col2}}}

      nil ->
        case Regex.run(regex_unquoted_binary_operation, expression) do
          [_, col1, operator, col2] ->
            {:ok, {:binary_operation, %{column1: String.trim(col1), operator: operator, column2: String.trim(col2)}}}

          nil ->
            match_single_column(expression, regex_single_column)
        end
    end
  end

  defp match_single_column(expression, regex) do
    if Regex.match?(regex, expression) do
      {:ok, {:single_column, expression}}
    else
      {:error, "Invalid expression"}
    end
  end

  defp apply_expression(df, {:single_column, column_name}) do
    df
    |> DF.select([column_name])
    |> DF.rename(["x"])
    |> DF.to_columns()
  end

  defp apply_expression(df, {:binary_operation, %{column1: col_1, operator: op, column2: col_2}}) do
    df
    |> mutate(col_1, op, col_2)
    |> DF.select(["x"])
    |> DF.to_columns()
  end

  defp mutate(df, col_1, "+", col_2), do: DF.mutate(df, x: col(^col_1) + col(^col_2))
  defp mutate(df, col_1, "-", col_2), do: DF.mutate(df, x: col(^col_1) - col(^col_2))
  defp mutate(df, col_1, "*", col_2), do: DF.mutate(df, x: col(^col_1) * col(^col_2))
  defp mutate(df, col_1, "/", col_2), do: DF.mutate(df, x: col(^col_1) / col(^col_2))

  defp column_exists?(df, column_name), do: Enum.member?(DF.names(df), column_name)
end
