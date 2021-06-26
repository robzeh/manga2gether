defmodule Manga2gether.RoomServerTest do
  use Manga2gether.DataCase
  alias Manga2gether.{RoomServer, RoomSession, RoomSupervisor}
  import Manga2gether.RoomFixtures

  describe "RoomSession.new/1" do
    test "struct is created from map" do
      room = valid_room_attributes()
      room_struct = RoomSession.new(room)

      assert %RoomSession{} = room_struct
    end
  end

  describe "RoomServer Initialization" do
    test "GenServer is started" do
      room = valid_room_attributes()

      child_spec = %{
        id: RoomServer,
        start: {RoomServer, :start_link, [room]}
      }

      {:ok, pid} = start_supervised(child_spec)

      assert pid
    end
  end

  # TODO: setup? check timings of test
  describe "RoomSupervisor Initialization" do
    test "RoomSupervisor starts and has no children" do
      children = DynamicSupervisor.which_children(RoomSupervisor)

      assert children == []
    end

    test "RoomSupervisor.start_room/1" do
      room = valid_room_attributes()

      {:ok, pid} = RoomSupervisor.start_room(room)
      children = DynamicSupervisor.which_children(RoomSupervisor)
      num = length(children)

      assert pid
      assert num == 1
    end

    test "RoomSupervisor.stop_room/1" do
      room = valid_room_attributes()
      {:ok, pid} = RoomSupervisor.start_room(room)
      assert pid

      assert :ok = RoomSupervisor.stop_room(room.room_code)
    end

    # test "RoomSupervisor starts" do
    #   child_spec = %{
    #     id: RoomSupervisor,
    #     start: {RoomSupervisor, :start_link, [nil]}
    #   }

    #   {:ok, pid} = start_supervised(child_spec)

    #   assert pid
    # end
  end
end

# response = RoomServer.handle_call(:get_room, _reply, state)

# assert {:reply, state, state} = response
# assert state.
