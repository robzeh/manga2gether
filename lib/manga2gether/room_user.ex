defmodule Manga2gether.RoomUser do
  @colors ["red", "yellow", "green", "blue", "indigo", "purple", "pink"]

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

  @spec assign_color() :: String.t()
  def assign_color() do
    Enum.random(@colors)
  end
end
