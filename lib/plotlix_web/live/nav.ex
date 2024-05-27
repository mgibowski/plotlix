defmodule PlotlixWeb.Nav do
  @moduledoc false

  use Phoenix.Component

  import Phoenix.LiveView

  alias PlotlixWeb.PlotLive.SharedWithYou
  alias PlotlixWeb.PlotLive.YourPlots

  def on_mount(:default, _params, _session, socket) do
    {:cont, attach_hook(socket, :active_tab, :handle_params, &handle_active_tab_params/3)}
  end

  defp handle_active_tab_params(_params, _url, socket) do
    active_tab =
      case {socket.view, socket.assigns.live_action} do
        {YourPlots, _} ->
          :your_plots

        {SharedWithYou, _} ->
          :shared_with_you

        {PlotlixWeb.UserSettingsLive, _} ->
          :settings

        {_, _} ->
          nil
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end
end
