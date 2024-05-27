defmodule Plotlix.PlotSharesTest do
  use Plotlix.DataCase

  import Plotlix.AccountsFixtures
  import Plotlix.PlotsFixtures
  import Plotlix.PlotSharesFixtures

  alias Plotlix.PlotShares
  alias Plotlix.PlotShares.PlotShare

  describe "plot_shares" do
    test "list_plot_shares/1 returns all shares for given plot id" do
      plot = plot_fixture()
      unrelated_plot = plot_fixture()
      user = user_fixture()
      plot_share = plot_share_fixture(plot, %{"user_id" => user.id})
      _unrelated_plot_share = plot_share_fixture(unrelated_plot, %{"user_id" => user.id})

      assert [listed_plot_share] = PlotShares.list_plot_shares(plot)
      assert listed_plot_share.id == plot_share.id
      assert listed_plot_share.plot_id == plot_share.plot_id
      # User is preloaded
      assert listed_plot_share.user == user
    end

    test "delete_plot_share/1 deletes plot_share" do
      plot = plot_fixture()
      user = user_fixture()
      plot_share = plot_share_fixture(plot, %{"user_id" => user.id})
      PlotShares.delete_plot_share(plot_share)
      assert [] == PlotShares.list_plot_shares(plot)
    end

    test "list_available_accounts/1 lists other user accounts for which the plot was not shared yet" do
      plot_owner = user_fixture()
      plot = plot_fixture(%{owner_id: plot_owner.id})
      user = user_fixture()
      available_user = user_fixture()
      plot_share_fixture(plot, %{"user_id" => user.id})

      assert [available_user] == PlotShares.list_available_accounts(plot)
    end

    test "create_plot_share/1 with valid data creates a plot share" do
      plot = plot_fixture()
      user = user_fixture()
      valid_attrs = %{"user_id" => user.id}
      assert {:ok, %PlotShare{}} = PlotShares.create_plot_share(plot, valid_attrs)
    end
  end
end
