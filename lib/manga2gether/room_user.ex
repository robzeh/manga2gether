defmodule Manga2gether.RoomUser do
  defstruct username: nil,
            ready: false,
            color: nil

  @type t :: %__MODULE__{
          username: String.t(),
          ready: boolean(),
          color: String.t()
        }

  @spec new(map()) :: t()
  def new(room_user) do
    struct!(__MODULE__, room_user)
  end
end
