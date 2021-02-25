defmodule Coinjar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Coinjar.Repo,
      # Start the Telemetry supervisor
      CoinjarWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: :coins},
      # Start the Endpoint (http/https)
      CoinjarWeb.Endpoint,
      # Start a worker by calling: Coinjar.Worker.start_link(arg)
      # {Coinjar.Worker, arg}

      ## Start our API scraper
      %{start: {Coinjar.PriceUpdater, :start_link, [:btc]}, id: :price_updator_btc},
      %{start: {Coinjar.PriceUpdater, :start_link, [:eth]}, id: :price_updator_eth}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Coinjar.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CoinjarWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
