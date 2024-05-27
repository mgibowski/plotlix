defmodule PlotlixWeb.PlotLive.FormComponent do
  @moduledoc false
  use PlotlixWeb, :live_component

  alias Ecto.Changeset
  alias Plotlix.Plots

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage plot records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="plot-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:dataset_name]} type="text" label="Dataset name" />
        <.input field={@form[:expression]} type="text" label="Expression" />
        <%= if assigns[:valid?]  do %>
          <div
            id="edited-plot"
            phx-hook="Plot"
            data-plot-valid={@valid?}
            data-series={@plotly_params.series}
            data-x-title={@plotly_params.x_title}
            data-y-title={@plotly_params.y_title}
          >
            <div id="edited-plot-target" phx-update="ignore" class="w-96 h-64 mx-auto"></div>
          </div>
        <% else %>
          <div class="w-96 h-64 mx-auto">
            <div class="flex items-center justify-center h-full">
              <p class="text-sm">No plot available.</p>
            </div>
          </div>
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Plot</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{plot: plot} = assigns, socket) do
    changeset = Plots.change_plot(plot)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"plot" => plot_params}, socket) do
    changeset =
      socket.assigns.plot
      |> Plots.change_plot(plot_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"plot" => plot_params}, socket) do
    save_plot(socket, socket.assigns.action, plot_params)
  end

  defp save_plot(socket, :edit, plot_params) do
    case Plots.update_plot(socket.assigns.plot, plot_params) do
      {:ok, plot} ->
        notify_parent({:saved, plot})

        {:noreply,
         socket
         |> put_flash(:info, "Plot updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_plot(socket, :new, plot_params) do
    plot_params = Map.put(plot_params, "owner_id", socket.assigns.current_user.id)

    case Plots.create_plot(plot_params) do
      {:ok, plot} ->
        notify_parent({:saved, plot})

        {:noreply,
         socket
         |> put_flash(:info, "Plot created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    socket =
      if changeset.valid? do
        dataset_name = Changeset.get_field(changeset, :dataset_name)
        expression = Changeset.get_field(changeset, :expression)

        case Plots.plotly_params(dataset_name, expression) do
          {:ok, plotly_params} ->
            socket
            |> assign(:valid?, true)
            |> assign(:plotly_params, plotly_params)

          _ ->
            assign(socket, :valid?, false)
        end
      else
        assign(socket, :valid?, false)
      end

    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
