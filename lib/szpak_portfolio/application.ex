defmodule SzpakPortfolio.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SzpakPortfolioWeb.Telemetry,
      # Temporarily disabled for production deployment
      # SzpakPortfolio.Repo,
      {DNSCluster, query: Application.get_env(:szpak_portfolio, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SzpakPortfolio.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SzpakPortfolio.Finch},
      # Start a worker by calling: SzpakPortfolio.Worker.start_link(arg)
      # {SzpakPortfolio.Worker, arg},
      # Start to serve requests, typically the last entry
      SzpakPortfolioWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SzpakPortfolio.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SzpakPortfolioWeb.Endpoint.config_change(changed, removed)
    :ok
  end

end
