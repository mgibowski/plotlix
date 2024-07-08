defmodule PlotlixWeb.PlotLiveTest do
  use PlotlixWeb.ConnCase

  import Phoenix.LiveViewTest
  import Plotlix.AccountsFixtures
  import Plotlix.PlotsFixtures

  @create_attrs %{name: "some name", dataset_name: "iris", expression: "SepalWidth"}
  @update_attrs %{
    name: "some updated name",
    dataset_name: "2014_ebola",
    expression: "Month"
  }
  @invalid_attrs %{name: nil, dataset_name: nil, expression: nil}
  @invalid_expression_attrs %{name: "some name", dataset_name: "iris", expression: "Month"}
  @mismatched_column_types_attrs %{name: "some name", dataset_name: "iris", expression: "SepalWidth + Name"}

  defp create_plot(%{conn: conn}) do
    user = user_fixture()
    conn = log_in_user(conn, user)

    plot = plot_fixture(%{owner_id: user.id})
    %{conn: conn, plot: plot, user: user}
  end

  describe "Index" do
    setup [:create_plot]

    test "lists all plots", %{conn: conn, plot: plot} do
      {:ok, _index_live, html} = live(conn, ~p"/plots/yours")

      assert html =~ "Listing Plots"
      assert html =~ plot.name
    end

    test "saves new plot", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/plots/yours")

      assert index_live |> element("a", "New Plot") |> render_click() =~
               "New Plot"

      assert_patch(index_live, ~p"/plots/yours/new")

      assert index_live
             |> form("#plot-form", plot: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#plot-form", plot: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/plots/yours")

      html = render(index_live)
      assert html =~ "Plot created successfully"
      assert html =~ "some name"
    end

    test "suggests available column names", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/plots/yours")

      assert index_live |> element("a", "New Plot") |> render_click() =~
               "New Plot"

      assert_patch(index_live, ~p"/plots/yours/new")

      assert index_live
             |> form("#plot-form", plot: @invalid_expression_attrs)
             |> render_change() =~ "Available column names: SepalLength, SepalWidth"
    end

    test "updates plot in listing", %{conn: conn, plot: plot} do
      {:ok, index_live, _html} = live(conn, ~p"/plots/yours")

      assert index_live |> element("#plots-#{plot.id} a", "Edit") |> render_click() =~
               "Edit Plot"

      assert_patch(index_live, ~p"/plots/yours/#{plot}/edit")

      assert index_live
             |> form("#plot-form", plot: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#plot-form", plot: @invalid_expression_attrs)
             |> render_change() =~ "Invalid expression"

      assert index_live
             |> form("#plot-form", plot: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/plots/yours")

      html = render(index_live)
      assert html =~ "Plot updated successfully"
      assert html =~ "some updated name"
    end

    test "reports error on expression with mismatched column types", %{conn: conn, plot: plot} do
      {:ok, index_live, _html} = live(conn, ~p"/plots/yours")

      assert index_live |> element("#plots-#{plot.id} a", "Edit") |> render_click() =~
               "Edit Plot"

      assert_patch(index_live, ~p"/plots/yours/#{plot}/edit")

      assert index_live
             |> form("#plot-form", plot: @mismatched_column_types_attrs)
             |> render_change() =~ "Invalid expression"
    end

    test "deletes plot in listing", %{conn: conn, plot: plot} do
      {:ok, index_live, _html} = live(conn, ~p"/plots/yours")

      assert index_live |> element("#plots-#{plot.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#plots-#{plot.id}")
    end
  end
end
