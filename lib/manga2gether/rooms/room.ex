defmodule Manga2gether.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Phoenix.Param, key: :room_code}
  schema "rooms" do
    field :description, :string
    field :name, :string
    field :room_code, :integer
    # field :owner_id, :binary_id, foreign_key: :owner_id

    belongs_to :user, Manga2gether.Accounts.User,
      references: :id,
      foreign_key: :owner_id

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :description, :room_code, :owner_id])
    |> validate_required([:name, :description, :room_code, :owner_id])
    |> unique_constraint(:owner_id)
    |> unique_constraint(:room_code)
  end

  def generate_room_code(attrs) do
    attrs
    |> Map.put("room_code", generate_room_code())
  end

  defp generate_room_code(), do: Enum.random(1_0000..9_9999)
end
