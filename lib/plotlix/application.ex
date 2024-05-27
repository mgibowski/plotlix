defmodule Plotlix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PlotlixWeb.Telemetry,
      Plotlix.Repo,
      {DNSCluster, query: Application.get_env(:plotlix, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Plotlix.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Plotlix.Finch},
      # Start a worker by calling: Plotlix.Worker.start_link(arg)
      # {Plotlix.Worker, arg},
      # Start to serve requests, typically the last entry
      PlotlixWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Plotlix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PlotlixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
