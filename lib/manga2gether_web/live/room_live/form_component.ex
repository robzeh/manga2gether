defmodule Manga2getherWeb.RoomLive.FormComponent do
  use Manga2getherWeb, :live_component

  alias Manga2gether.Rooms
  alias Manga2gether.RoomSupervisor

  @impl true
  def update(%{room: room} = assigns, socket) do
    changeset = Rooms.change_room(room)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"room" => room_params}, socket) do
    changeset =
      socket.assigns.room
      |> Rooms.change_room(room_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"room" => room_params}, socket) do
    updated_room = Map.put(room_params, "owner_id", socket.assigns.current_user.id)
    save_room(socket, socket.assigns.action, updated_room)
  end

  defp save_room(socket, :edit, room_params) do
    case Rooms.update_room(socket.assigns.room, room_params) do
      {:ok, _room} ->
        {:noreply,
         socket
         |> put_flash(:info, "Room updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_room(socket, :new, room_params) do
    with {:ok, room} <- Rooms.create_room(room_params),
         {:ok, _} <-
           RoomSupervisor.start_room(%{
             room_id: room.id,
             room_code: room.room_code,
             room_name: room.name,
             owner_id: room.owner_id
           }) do
      rooms = Rooms.list_rooms()
      Manga2getherWeb.Endpoint.broadcast("rooms", "new_room", %{rooms: rooms})

      {:noreply,
       socket
       |> put_flash(:info, "Room created successfully")
       |> push_redirect(to: Routes.room_show_path(socket, :show, room.room_code))}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      error ->
        error
    end
  end
end
