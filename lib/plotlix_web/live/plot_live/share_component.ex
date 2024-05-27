defmodule PlotlixWeb.PlotLive.ShareComponent do
  @moduledoc false

  use PlotlixWeb, :live_component

  alias Plotlix.PlotShares
  alias Plotlix.PlotShares.PlotShare

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Share plot
      </.header>

      <%= if @empty_plot_shares? do %>
        <p class="m-2 text-center text-gray-700 bg-gray-100 p-4 rounded-md">
          This plot is not yet shared with anybody
        </p>
      <% else %>
        <div class="mt-2 text-gray-700">
          This plot is already shared with the following users:
        </div>
        <.table id="plot-shares" rows={@streams.plot_shares}>
          <:col :let={{_id, plot_share}} label="User"><%= plot_share.user.email %></:col>
          <:action :let={{id, plot_share}}>
            <.link
              phx-target={@myself}
              phx-click={JS.push("delete", value: %{id: plot_share.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
            >
              Unshare
            </.link>
          </:action>
        </.table>
      <% end %>

      <%= if @empty_available_accounts? do %>
        <p class="m-2 text-center text-gray-700 bg-gray-100 p-4 rounded-md">
          There are no users with whom you could share this plot
        </p>
      <% else %>
        <.simple_form for={@form} id="plot_share-form" phx-target={@myself} phx-submit="save">
          <.input
            id="user_id"
            name="user_id"
            type="select"
            field={@form[:user_id]}
            options={@available_accounts}
          >
          </.input>
          <:actions>
            <.button phx-disable-with="Saving...">Share</.button>
          </:actions>
        </.simple_form>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(%{plot: plot} = assigns, socket) do
    changeset = PlotShare.change_plot_share(plot)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_form(changeset)
      |> assign_lists()
    }
  end

  defp assign_lists(socket) do
    plot = socket.assigns.plot
    plot_shares = PlotShares.list_plot_shares(plot)

    available_accounts =
      plot
      |> PlotShares.list_available_accounts()
      # Map to format required by select options
      |> Enum.map(fn %{id: id, email: email} -> {email, id} end)

    empty_plot_shares? = plot_shares == []
    empty_available_accounts? = available_accounts == []

    socket
    |> stream(:plot_shares, plot_shares)
    |> assign(:available_accounts, available_accounts)
    |> assign(:empty_plot_shares?, empty_plot_shares?)
    |> assign(:empty_available_accounts?, empty_available_accounts?)
  end

  def handle_event("save", params, socket) do
    case PlotShares.create_plot_share(socket.assigns.plot, params) do
      {:ok, _plot_share} ->
        {:noreply,
         socket
         |> put_flash(:info, "Plot shared successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => plot_share_id}, socket) do
    plot_share = PlotShares.get_plot_share!(plot_share_id)
    {:ok, _} = PlotShares.delete_plot_share(plot_share)

    {:noreply, assign_lists(socket)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
