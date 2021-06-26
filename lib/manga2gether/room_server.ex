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
end
