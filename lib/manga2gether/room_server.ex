defmodule Manga2gether.RoomServer do
  use GenServer

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

  defp broadcast!(room_code, event, message) do
    Manga2getherWeb.Endpoint.broadcast!("room:#{room_code}", event, message)
  end

  ################################################################################
  ### Client

  @spec get_room(integer()) :: RoomSession.t()
  def get_room(room_code) do
    call(room_code, :get_room)
  end

  ################################################################################
  ### Server

  @impl true
  def handle_call(:get_room, _reply, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(%{event: "presence_diff"} = _message, %{room_code: room_code} = state) do
    users = Manga2getherWeb.Presence.list_keys(room_code)
    broadcast!(room_code, "updated_users", %{users: users})
    {:noreply, %{state | users: users}}
  end

  @impl true
  def handle_info(_message, state) do
    {:noreply, state}
  end
end
