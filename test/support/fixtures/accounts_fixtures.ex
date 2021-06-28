defmodule Manga2gether.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Manga2gether.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
  def valid_discord_id, do: "123456789123456789"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(
      attrs,
      %{
        email: unique_user_email(),
        password: valid_user_password()
      }
    )
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Manga2gether.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end

  def custom_user_fixture(user) do
    {:ok, user} =
      user
      |> Manga2gether.Accounts.register_user()

    user
  end

  # TODO: improve
  def ueberauth_fixture() do
    %{
      uid: valid_discord_id(),
      info: %{
        email: unique_user_email()
      },
      extra: %{
        raw_info: %{
          user: %{
            "username" => "username"
          }
        }
      }
    }
  end
end
