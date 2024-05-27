defmodule Plotlix.DatasetsTest do
  use ExUnit.Case, async: true

  alias Plotlix.Datasets

  describe "validate_dataset_name/1" do
    test "iris" do
      assert [] == Datasets.validate_dataset_name("iris")
    end

    test "wind_speed_laurel_nebraska" do
      assert [] == Datasets.validate_dataset_name("wind_speed_laurel_nebraska")
    end

    test "non-existing" do
      assert [dataset_name: "Not found"] == Datasets.validate_dataset_name("non-existing")
    end
  end

  describe "validate_expression/2" do
    test "iris and PetalLength" do
      assert [] == Datasets.validate_expression("iris", "PetalLength")
    end

    test "iris and SepalWidth + PetalLength" do
      assert [] == Datasets.validate_expression("iris", "SepalWidth + PetalLength")
    end

    test "iris and 'SepalWidth' + 'PetalLength'" do
      assert [] == Datasets.validate_expression("iris", "'SepalWidth' + 'PetalLength'")
    end

    test "iris and SepalWidth - PetalLength" do
      assert [] == Datasets.validate_expression("iris", "SepalWidth - PetalLength")
    end

    test "iris and SepalWidth * PetalLength" do
      assert [] == Datasets.validate_expression("iris", "SepalWidth * PetalLength")
    end

    test "iris and SepalWidth / PetalLength" do
      assert [] == Datasets.validate_expression("iris", "SepalWidth / PetalLength")
    end

    test "2010_alcohol_consumption_by_country and alcohol" do
      assert [] == Datasets.validate_expression("2010_alcohol_consumption_by_country", "alcohol")
    end

    test "2014_ebola and Month * Year" do
      assert [] == Datasets.validate_expression("2014_ebola", "Month * Year")
    end

    test "iris and SepalWidth & PetalLength" do
      assert [expression: "Invalid expression"] == Datasets.validate_expression("iris", "SepalWidth & PetalLength")
    end

    test "iris and WrongExpression" do
      assert [expression: "Invalid expression"] == Datasets.validate_expression("iris", "WrongExpression")
    end

    test "iris and SepalWidth % PetalLength" do
      assert [expression: "Invalid expression"] == Datasets.validate_expression("iris", "SepalWidth % PetalLength")
    end

    test "2014_ebola and SepalWidth" do
      assert [expression: "Invalid expression"] == Datasets.validate_expression("2014_ebola", "SepalWidth")
    end
  end

  describe "eval_expression/2" do
    test "iris and SepalWidth" do
      {:ok, series} = Datasets.eval_expression("iris", "SepalWidth")
      assert [3.5, 3.0, 3.2, 3.1, 3.6] == Enum.take(series["x"], 5)
    end

    test "iris and PetalLength" do
      {:ok, series} = Datasets.eval_expression("iris", "PetalLength")
      assert [1.4, 1.4, 1.3, 1.5, 1.4] == Enum.take(series["x"], 5)
    end

    test "iris and SepalWidth + PetalLength" do
      {:ok, series} = Datasets.eval_expression("iris", "SepalWidth + PetalLength")
      assert [4.9, 4.4, 4.5, 4.6, 5.0] == Enum.take(series["x"], 5)
    end

    test "iris and 'SepalWidth' + 'PetalLength'" do
      {:ok, series} = Datasets.eval_expression("iris", "'SepalWidth' + 'PetalLength'")
      assert [4.9, 4.4, 4.5, 4.6, 5.0] == Enum.take(series["x"], 5)
    end

    test "iris and SepalWidth * PetalLength" do
      {:ok, series} = Datasets.eval_expression("iris", "SepalWidth * PetalLength")
      assert [4.8999999999999995, 4.199999999999999, 4.16, 4.65, 5.04] == Enum.take(series["x"], 5)
    end

    test "wind_speed_laurel_nebraska and 10 Min Std Dev" do
      {:ok, series} = Datasets.eval_expression("wind_speed_laurel_nebraska", "10 Min Std Dev")
      assert [2.73, 1.98, 1.87, 2.03, 3.1] == Enum.take(series["x"], 5)
    end

    test "wind_speed_laurel_nebraska and '10 Min Std Dev' + '10 Min Sampled Avg'" do
      {:ok, series} = Datasets.eval_expression("wind_speed_laurel_nebraska", "'10 Min Std Dev' + '10 Min Sampled Avg'")
      assert [25.03, 24.98, 25.17, 24.03, 23.6] == Enum.take(series["x"], 5)
    end
  end
end
