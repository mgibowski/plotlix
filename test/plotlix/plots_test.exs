defmodule Plotlix.PlotsTest do
  use Plotlix.DataCase

  describe "plots" do
    import Plotlix.AccountsFixtures
    import Plotlix.PlotsFixtures
    import Plotlix.PlotSharesFixtures

    alias Plotlix.Plots
    alias Plotlix.Plots.Plot

    @invalid_attrs %{name: nil, dataset_name: nil, expression: nil}

    test "list_user_plots/1 returns all plots for given user" do
      plot_owner = user_fixture()

      plot =
        %{owner_id: plot_owner.id}
        |> plot_fixture()
        |> Plots.add_plotly_params()

      assert [^plot] = Plots.list_user_plots(plot_owner)
    end

    test "list_user_plots/1 doesn't return plots of other users" do
      plot_owner = user_fixture()
      other_user = user_fixture()

      %{owner_id: plot_owner.id}
      |> plot_fixture()
      |> Plots.add_plotly_params()

      assert [] = Plots.list_user_plots(other_user)
    end

    test "list_shared_plots/1 returns plots shared with given user" do
      plot_owner = user_fixture()
      other_user = user_fixture()

      plot = plot_fixture(%{owner_id: plot_owner.id})

      plot_share_fixture(plot, %{"user_id" => other_user.id})

      assert [dispalyed_plot] = Plots.list_shared_plots(other_user)
      assert dispalyed_plot.id == plot.id
    end

    test "list_shared_plots/1 does not return plot that was not shared" do
      plot_owner = user_fixture()
      other_user = user_fixture()

      %{owner_id: plot_owner.id}
      |> plot_fixture()
      |> Plots.add_plotly_params()

      assert [] == Plots.list_shared_plots(other_user)
    end

    test "get_plot!/2 returns plot for the owner" do
      plot_owner = user_fixture()

      plot = plot_fixture(%{owner_id: plot_owner.id})
      returned_plot = Plots.get_plot!(plot_owner, plot.id)
      assert returned_plot.id == plot.id
    end

    test "get_plot!/2 raises when the user is not an owner" do
      plot_owner = user_fixture()
      other_user = user_fixture()

      plot = plot_fixture(%{owner_id: plot_owner.id})

      assert_raise Ecto.NoResultsError, fn ->
        Plots.get_plot!(other_user, plot.id)
      end
    end

    test "create_plot/1 with valid data creates a plot" do
      owner = user_fixture()
      valid_attrs = %{name: "some name", dataset_name: "iris", expression: "SepalWidth", owner_id: owner.id}

      assert {:ok, %Plot{} = plot} = Plots.create_plot(valid_attrs)
      assert plot.name == "some name"
      assert plot.dataset_name == "iris"
      assert plot.expression == "SepalWidth"
    end

    test "create_plot/1 with empty params returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Plots.create_plot(@invalid_attrs)
    end

    test "create_plot/1 with invalid dataset name returns error changeset" do
      owner = user_fixture()

      invalid_dataset_name_params = %{
        name: "some name",
        dataset_name: "some dataset_name",
        expression: "some expression",
        owner_id: owner.id
      }

      assert {:error, %Ecto.Changeset{errors: [dataset_name: {"Not found", []}]}} =
               Plots.create_plot(invalid_dataset_name_params)
    end

    test "create_plot/1 with invalid expression returns error changeset" do
      owner = user_fixture()

      invalid_dataset_name_params = %{
        name: "some name",
        dataset_name: "iris",
        expression: "some expression",
        owner_id: owner.id
      }

      assert {:error, %Ecto.Changeset{errors: [expression: {"Invalid expression", []}]}} =
               Plots.create_plot(invalid_dataset_name_params)
    end

    test "update_plot/2 with valid data updates the plot" do
      plot = plot_fixture()

      update_attrs = %{
        name: "some updated name",
        dataset_name: "beers",
        expression: "ounces"
      }

      assert {:ok, %Plot{} = plot} = Plots.update_plot(plot, update_attrs)
      assert plot.name == "some updated name"
      assert plot.dataset_name == "beers"
      assert plot.expression == "ounces"
    end

    test "delete_plot/1 deletes the plot" do
      plot_owner = user_fixture()
      plot = plot_fixture(%{owner_id: plot_owner.id})
      assert {:ok, %Plot{}} = Plots.delete_plot(plot)
      assert_raise Ecto.NoResultsError, fn -> Plots.get_plot!(plot_owner, plot.id) end
    end

    test "change_plot/1 returns a plot changeset" do
      plot = plot_fixture()
      assert %Ecto.Changeset{} = Plots.change_plot(plot)
    end
  end
end
