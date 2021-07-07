defmodule Manga2getherWeb.Presence do
  use Phoenix.Presence,
    otp_app: :manga2gether,
    pubsub_server: Manga2gether.PubSub

  alias Manga2getherWeb.Presence

  @doc """
  Typically called after tracked user updates their presence
  """
  @spec list_users(integer()) :: list(Manga2gether.RoomUser.t())
  def list_users(room_code) do
    for {_user_id, room_user} <- Presence.list("room:#{room_code}") do
      hd(room_user.metas)
    end
  end

  def room_size(room_code), do: map_size(Presence.list("room:#{room_code}"))

  @spec list_keys(integer()) :: list
  def list_keys(room_code) do
    Presence.list("room:#{room_code}")
    |> Map.keys()
  end
end
