defmodule Manga2getherWeb.RoomLive.Show do
  use Manga2getherWeb, :live_view

  alias Manga2gether.Accounts
  alias Manga2gether.RoomServer
  alias Manga2gether.RoomUser

  @impl true
  def mount(
        %{"room_code" => room_code} = _params,
        %{"user_token" => session_token} = _session,
        socket
      ) do
    user = assign_user(socket, session_token) |> Map.get(:assigns) |> Map.get(:current_user)
    room = RoomServer.get_room(String.to_integer(room_code))

    if connected?(socket) do
      room_user = RoomUser.new(%{username: user.username})
      Manga2getherWeb.Endpoint.subscribe("room:#{room_code}")

      Manga2getherWeb.Presence.track(
        self(),
        "room:#{room_code}",
        user.id,
        room_user
      )
    end

    {:ok,
     socket
     |> assign(:current_room, room)
     |> assign(:owner, RoomServer.is_owner(room_code, user.id))}
  end

  @impl true
  def handle_info(%{event: "updated_users", payload: %{users: users}} = _message, socket) do
    {:noreply,
     socket
     |> assign(:current_room, %{socket.assigns.current_room | users: users})}
  end

  @impl true
  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  def assign_user(socket, token) do
    assign_new(socket, :current_user, fn ->
      Accounts.get_user_by_session_token(token)
    end)
  end
end
