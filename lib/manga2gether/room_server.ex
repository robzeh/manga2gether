defmodule Manga2gether.RoomServer do
  use GenServer

  alias Manga2gether.MangaSession
  alias Manga2gether.Rooms
  alias Manga2gether.RoomSession

  ################################################################################
  ### Initialization

  @spec start_link(map()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(room) do
    GenServer.start_link(__MODULE__, room, name: via_tuple(room.room_code))
  end

  @impl true
  @spec init(map()) :: {:ok, Manga2gether.RoomSession.t()}
  def init(room) do
    # Subscribe to room's presence
    Manga2getherWeb.Endpoint.subscribe("room:#{room.room_code}")
    {:ok, RoomSession.new(room)}
  end

  @impl true
  def terminate(_reason, _state) do
    :ok
  end

  ################################################################################
  ### Misc

  defp cast(room_code, params), do: GenServer.cast(via_tuple(room_code), params)
  defp call(room_code, params), do: GenServer.call(via_tuple(room_code), params)

  defp via_tuple(room_code) do
    {:via, Registry, {Manga2gether.RoomRegistry, room_code}}
  end

  @doc """
  Return PID of active room or nil
  """
  @spec room_pid(integer()) :: nil | pid | {atom, atom}
  def room_pid(room_code) do
    room_code
    |> via_tuple()
    |> GenServer.whereis()
  end

  @doc """
  Returns boolean of whether user is owner of room
  """
  @spec is_owner(binary(), Ecto.UUID.t()) :: boolean()
  def is_owner(room_code, user_id) do
    room_code
    |> String.to_integer()
    |> get_room()
    |> Map.get(:owner_id) == user_id
  end

  @spec broadcast!(integer(), String.t(), map()) :: :ok
  defp broadcast!(room_code, event, message) do
    Manga2getherWeb.Endpoint.broadcast!("room:#{room_code}", event, message)
  end

  ################################################################################
  ### Client

  @spec get_room(integer()) :: RoomSession.t()
  def get_room(room_code) do
    cond do
      room_pid(room_code) == nil ->
        nil
      true ->
        call(room_code, :get_room)
    end
  end

  def get_users(room_code) do
    call(room_code, :get_users)
  end

  @spec set_manga(integer(), map()) :: :ok
  def set_manga(room_code, manga) do
    cast(room_code, {:set_manga, manga})
  end

  @spec next_page(integer()) :: :ok
  def next_page(room_code) do
    cast(room_code, {:next_page})
  end

  @spec prev_page(integer()) :: :ok
  def prev_page(room_code) do
    cast(room_code, {:prev_page})
  end

  @spec set_reading(integer(), boolean()) :: :ok
  def set_reading(room_code, status) do
    cast(room_code, {:set_reading, status})
  end

  def end_room(room_code) do
    cast(room_code, {:end_room})
  end

  ################################################################################
  ### Server

  @impl true
  def handle_call(:get_room, _reply, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:get_users, _reply, state) do
    users = Manga2getherWeb.Presence.list_users(state.room_code)
    {:reply, %{users: users}, state}
  end

  @impl true
  def handle_cast({:end_room}, state) do
    # broadcast to room users
    broadcast!(state.room_code, "end_room", %{})

    # delete room in db
    room = Rooms.get_room!(state.room_code)
    {:ok, _} = Rooms.delete_room(room)
    updated_rooms = Rooms.list_rooms()
    Manga2getherWeb.Endpoint.broadcast!("rooms", "new_room", %{rooms: updated_rooms})

    # End genserver
    {:stop, :normal, state}
  end

  @impl true
  def handle_cast({:set_manga, manga}, state) do
    new_manga = MangaSession.new(manga)
    broadcast!(state.room_code, "set_manga", %{manga: new_manga})

    # update room in db
    room = Rooms.get_room!(state.room_code)
    {:ok, _} = Rooms.update_room(room, %{current_manga: new_manga.manga_title})
    updated_rooms = Rooms.list_rooms()
    Manga2getherWeb.Endpoint.broadcast!("rooms", "new_room", %{rooms: updated_rooms})

    {:noreply, %{state | manga: new_manga}}
  end

  @impl true
  def handle_cast({:next_page}, state) do
    new_manga = MangaSession.next_page(state.manga)
    broadcast!(state.room_code, "new_manga_page", %{manga: new_manga})
    {:noreply, %{state | manga: new_manga}}
  end

  @impl true
  def handle_cast({:prev_page}, state) do
    new_manga = MangaSession.prev_page(state.manga)
    broadcast!(state.room_code, "new_manga_page", %{manga: new_manga})
    {:noreply, %{state | manga: new_manga}}
  end

  @impl true
  def handle_cast({:set_reading, status}, state) do
    broadcast!(state.room_code, "reading_status", %{reading: status})
    # if not reading, update room in db
    if status == false do
      room = Rooms.get_room!(state.room_code)
      {:ok, _} = Rooms.update_room(room, %{current_manga: nil})
      updated_rooms = Rooms.list_rooms()
      Manga2getherWeb.Endpoint.broadcast!("rooms", "new_room", %{rooms: updated_rooms})
    end

    {:noreply, %{state | reading: status}}
  end

  @impl true
  def handle_info(
        %{event: "presence_diff"} = _message,
        %{room_code: room_code, users: room_users} = state
      ) do
    # Get list and size of present users
    users = Manga2getherWeb.Presence.list_users(room_code)
    num_ppl = Manga2getherWeb.Presence.room_size(room_code)

    # Num ppl in room changed, update room in db
    if length(room_users) != num_ppl do
      room = Rooms.get_room!(room_code)
      {:ok, _} = Rooms.update_room(room, %{num_ppl: num_ppl})
      # Update user count of room on homepage
      updated_rooms = Rooms.list_rooms()
      Manga2getherWeb.Endpoint.broadcast!("rooms", "new_room", %{rooms: updated_rooms})
    end

    # Updated users for ppl in room
    broadcast!(room_code, "updated_users", %{users: users})
    {:noreply, %{state | users: users}}
  end

  @impl true
  def handle_info(_message, state) do
    {:noreply, state}
  end
end
