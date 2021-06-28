defmodule Manga2gether.RoomServer do
  use GenServer

  alias Manga2gether.MangaSession
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

  defp broadcast!(room_code, event, message) do
    Manga2getherWeb.Endpoint.broadcast!("room:#{room_code}", event, message)
  end

  ################################################################################
  ### Client

  @spec get_room(integer()) :: RoomSession.t()
  def get_room(room_code) do
    call(room_code, :get_room)
  end

  @spec set_manga(integer(), map()) :: :ok
  def set_manga(room_code, manga) do
    cast(room_code, {:set_manga, manga})
  end

  @spec set_reading(integer(), boolean()) :: :ok
  def set_reading(room_code, status) do
    cast(room_code, {:set_reading, status})
  end

  ################################################################################
  ### Server

  @impl true
  def handle_call(:get_room, _reply, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:set_manga, manga}, state) do
    new_manga = MangaSession.new(manga)
    # TODO: broadcast?
    {:noreply, %{state | manga: new_manga}}
  end

  @impl true
  def handle_cast({:set_reading, status}, state) do
    broadcast!(state.room_code, "reading_status", %{reading: status})
    {:noreply, %{state | reading: status}}
  end

  @impl true
  def handle_info(%{event: "presence_diff"} = _message, %{room_code: room_code} = state) do
    users = Manga2getherWeb.Presence.list_users(room_code)
    broadcast!(room_code, "updated_users", %{users: users})
    {:noreply, %{state | users: users}}
  end

  @impl true
  def handle_info(_message, state) do
    {:noreply, state}
  end
end
