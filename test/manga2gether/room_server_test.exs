defmodule Manga2gether.RoomServerTest do
  use Manga2gether.DataCase
  alias Manga2gether.{RoomServer, RoomSession}
  import Manga2gether.RoomFixtures

  describe "RoomSession.new/1" do
    test "struct is created from map" do
      room = valid_room_attributes()
      room_struct = RoomSession.new(room)

      assert %RoomSession{} = room_struct
    end
  end

  # describe "RoomServer Initialization" do
  #   test "GenServer is started" do
  #     room = valid_room_attributes()
  #     {:ok, pid} = start_supervised(RoomServer, room)

  #     assert pid
  #   end
  # end
end

# response = RoomServer.handle_call(:get_room, _reply, state)

# assert {:reply, state, state} = response
# assert state.
