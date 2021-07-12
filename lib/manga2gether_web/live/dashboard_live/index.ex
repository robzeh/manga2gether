defmodule Manga2getherWeb.DashboardLive.Index do
  use Manga2getherWeb, :live_view

  alias Manga2gether.Accounts
  alias Manga2gether.Rooms
  alias Manga2gether.Rooms.Room
  alias Manga2gether.RoomSupervisor

  @impl true
  def mount(_params, %{"user_token" => session_token} = _session, socket) do
    if connected?(socket) do
      Manga2getherWeb.Endpoint.subscribe("rooms")
    end

    {:ok,
     socket
     |> assign(:rooms, list_rooms())
     |> assign_user(session_token)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Room")
    |> assign(:room, Rooms.get_room!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Room")
    |> assign(:room, %Room{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Rooms")
    |> assign(:room, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    room = Rooms.get_room!(id)
    {:ok, _} = Rooms.delete_room(room)
    :ok = RoomSupervisor.stop_room(room.room_code)

    rooms = list_rooms()
    Manga2getherWeb.Endpoint.broadcast!("rooms", "new_room", %{rooms: rooms})

    {:noreply, assign(socket, :rooms, list_rooms())}
  end

  @impl true
  def handle_event("join_room", %{"code" => room_code} = _params, socket) do
    {:noreply, push_redirect(socket, to: Routes.room_show_path(socket, :show, room_code))}
  end

  @impl true
  def handle_info(%{event: "new_room", payload: %{rooms: rooms}} = _params, socket) do
    {:noreply,
     socket
     |> assign(:rooms, rooms)}
  end

  defp list_rooms do
    Rooms.list_rooms()
  end

  defp assign_user(socket, token) do
    assign_new(socket, :current_user, fn ->
      Accounts.get_user_by_session_token(token)
    end)
  end
end
