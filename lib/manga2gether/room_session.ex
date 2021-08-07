defmodule Manga2gether.RoomSession do
  alias Manga2gether.MangaSession
  alias Manga2gether.RoomUser

  # TODO: really need id, owner?
  defstruct room_id: nil,
            room_code: nil,
            room_name: nil,
            owner_id: nil,
            users: [],
            reading: false,
            manga: %MangaSession{}

  @type t :: %__MODULE__{
          room_id: Ecto.UUID.t(),
          room_code: integer(),
          room_name: String.t(),
          owner_id: Ecto.UUID.t(),
          users: list(RoomUser.t()),
          reading: boolean(),
          manga: MangaSession.t()
        }

  @doc """
  Initialize struct with given fields
  """
  @spec new(map()) :: t()
  def new(room) do
    struct!(__MODULE__, room)
  end
end
