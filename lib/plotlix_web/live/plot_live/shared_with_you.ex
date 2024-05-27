defmodule PlotlixWeb.PlotLive.SharedWithYou do
  @moduledoc false
  use PlotlixWeb, :live_view

  alias Plotlix.Plots

  @impl true
  def mount(_params, _session, socket) do
    plots = Plots.list_shared_plots(socket.assigns.current_user)
    empty_plots? = plots == []

    socket =
      socket
      |> assign(:page_title, "Plots shared with you")
      |> assign(:empty_plots?, empty_plots?)
      |> stream(:plots, plots)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Plots shared with you
    </.header>

    <%= if @empty_plots? do %>
      <p class="text-center mt-4 text-gray-700">
        There are no plots shared with you yet.
      </p>
    <% else %>
      <.table id="plots" rows={@streams.plots}>
        <:col :let={{_id, plot}} label="Name"><%= plot.name %></:col>
        <:col :let={{_id, plot}} label="Dataset name"><%= plot.dataset_name %></:col>
        <:col :let={{_id, plot}} label="Expression"><%= plot.expression %></:col>
        <:col :let={{_id, plot}} label="Author"><%= plot.owner.email %></:col>
        <:col :let={{_id, plot}} label="Plot">
          <div
            id={"plot-#{plot.id}"}
            phx-hook="Plot"
            data-series={plot.plotly_params.series}
            data-plot-valid="true"
            data-x-title={plot.plotly_params.x_title}
            data-y-title={plot.plotly_params.y_title}
          >
            <div id={"plot-#{plot.id}-target"} phx-update="ignore" class="w-96 h-64 mx-auto"></div>
          </div>
        </:col>
      </.table>
    <% end %>
    """
  end
end
