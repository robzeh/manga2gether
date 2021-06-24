defmodule Manga2getherWeb.UserOAuthController do
  use Manga2getherWeb, :controller

  plug Ueberauth

  @doc """
  Successful Discord authentication callback. Either finds existing user with discord_id,
  links discord_id for user with existing email, or creates new user
  """
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"provider" => "discord"}) do
    IO.inspect(conn)

    conn
    |> redirect(to: "/")
  end

  # Unsuccessful Discord authentication callback. Redirects to log in page
  def callback(%{assigns: %{ueberauth_failure: _reason}} = conn, _params) do
    conn
    |> redirect(to: "/")
  end
end
