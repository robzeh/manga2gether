defmodule Manga2gether.RoomSupervisor do
  use DynamicSupervisor

  alias Manga2gether.RoomServer

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  @spec init(any) ::
          {:ok,
           %{
             extra_arguments: list,
             intensity: non_neg_integer,
             max_children: :infinity | non_neg_integer,
             period: pos_integer,
             strategy: :one_for_one
           }}
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_room(map()) :: {:error, any} | {:ignored, pid} | {:ok, pid}
  def start_room(room) do
    child_spec = %{
      id: RoomServer,
      start: {RoomServer, :start_link, [room]},
      restart: :transient
    }

    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:error, {:already_started, pid}} -> {:ignored, pid}
      error -> error
    end
  end

  @spec stop_room(integer()) :: :ok | {:error, :not_found}
  def stop_room(room_code) do
    case RoomServer.room_pid(room_code) do
      pid when is_pid(pid) ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)

      nil ->
        :ok
    end
  end
end
