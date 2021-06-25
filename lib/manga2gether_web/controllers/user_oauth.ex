defmodule Manga2getherWeb.UserOAuthController do
  use Manga2getherWeb, :controller

  plug Ueberauth

  alias Manga2gether.Accounts
  alias Manga2getherWeb.UserAuth

  @doc """
  Successful Discord authentication callback. Either finds existing user with discord_id,
  links discord_id for user with existing email, or creates new user
  """
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"provider" => "discord"}) do
    case Accounts.discord_find_or_create(auth) do
      {result, user} when result in [:find, :link, :create] ->
        conn
        |> UserAuth.log_in_user(user)

      {:error, _} ->
        conn
        |> redirect(to: "/")
    end
  end

  # Unsuccessful Discord authentication callback. Redirects to log in page
  def callback(%{assigns: %{ueberauth_failure: _reason}} = conn, _params) do
    conn
    |> redirect(to: "/")
  end
end
