defmodule Manga2getherWeb.Presence do
  use Phoenix.Presence,
    otp_app: :manga2gether,
    pubsub_server: Manga2gether.PubSub

  alias Manga2getherWeb.Presence

  @spec list_keys(integer()) :: list
  def list_keys(room_code) do
    Presence.list("room:#{room_code}")
    |> Map.keys()
  end
end
