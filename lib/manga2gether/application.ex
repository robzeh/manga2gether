defmodule Manga2gether.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Manga2gether.Repo,
      # Start the Telemetry supervisor
      Manga2getherWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Manga2gether.PubSub},
      # Start the Endpoint (http/https)
      Manga2getherWeb.Endpoint
      # Start a worker by calling: Manga2gether.Worker.start_link(arg)
      # {Manga2gether.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Manga2gether.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Manga2getherWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
