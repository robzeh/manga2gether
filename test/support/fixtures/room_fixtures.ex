defmodule Manga2gether.RoomFixtures do
  alias Manga2gether.RoomSession

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

  def valid_manga_attributes(attrs \\ %{}) do
    Map.merge(
      %{
        title: "manga test",
        pages: ["test.png"]
      },
      attrs
    )
  end

  def valid_room_state(attrs \\ %{}) do
    attrs
    |> valid_room_attributes()
    |> RoomSession.new()
  end

  def valid_room_code(), do: Enum.random(1_0000..9_9999)
end
