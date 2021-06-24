defmodule Manga2gether.Repo do
  use Ecto.Repo,
    otp_app: :manga2gether,
    adapter: Ecto.Adapters.Postgres
end
