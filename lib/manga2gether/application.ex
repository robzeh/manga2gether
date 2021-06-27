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
      # Room Registry
      {Registry, keys: :unique, name: Manga2gether.RoomRegistry},
      # Dynamic Room Supervisor
      Manga2gether.RoomSupervisor,
      # Phoenix Presence
      Manga2getherWeb.Presence,
      # Start the Endpoint (http/https)
      Manga2getherWeb.Endpoint
      # Start a worker by calling: Manga2gether.Worker.start_link(arg)
      # {Manga2gether.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Manga2gether.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, pid} ->
        start_rooms()
        {:ok, pid}

      error ->
        error
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Manga2getherWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Start room servers for rooms already in database
  defp start_rooms() do
    Enum.each(Manga2gether.Rooms.list_rooms(), fn room ->
      Manga2gether.RoomSupervisor.start_room(%{
        room_id: room.id,
        room_code: room.room_code,
        owner_id: room.owner_id
      })
    end)
  end
end
