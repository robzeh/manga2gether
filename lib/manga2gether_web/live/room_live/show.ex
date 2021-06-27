defmodule Manga2getherWeb.RoomLive.Show do
  use Manga2getherWeb, :live_view

  alias Manga2gether.Accounts
  alias Manga2gether.Rooms
  alias Manga2gether.RoomServer

  @impl true
  def mount(
        %{"room_code" => room_code} = _params,
        %{"user_token" => session_token} = _session,
        socket
      ) do
    user = assign_user(socket, session_token)
    room = RoomServer.get_room(String.to_integer(room_code))

    if connected?(socket) do
      Manga2getherWeb.Endpoint.subscribe("room:#{room_code}")

      Manga2getherWeb.Presence.track(
        self(),
        "room:#{room_code}",
        user.assigns.current_user.id,
        %{username: user.assigns.current_user.username}
      )
    end

    {:ok, socket |> assign(:current_room, room)}
  end

  @impl true
  def handle_params(%{"room_code" => room_code}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:room, Rooms.get_room!(room_code))}
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

  defp page_title(:show), do: "Show Room"
  defp page_title(:edit), do: "Edit Room"

  def assign_user(socket, token) do
    assign_new(socket, :current_user, fn ->
      Accounts.get_user_by_session_token(token)
    end)
  end
end
