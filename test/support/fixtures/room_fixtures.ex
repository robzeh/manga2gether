defmodule Manga2gether.RoomFixtures do
  def valid_room_attributes(attrs \\ %{}) do
    Map.merge(
      %{
        room_id: Ecto.UUID.generate(),
        room_code: valid_room_code(),
        owner_id: Ecto.UUID.generate()
      },
      attrs
    )
  end

  def valid_room_code(), do: Enum.random(1_0000..9_9999)
end
