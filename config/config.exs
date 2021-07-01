# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :manga2gether,
  ecto_repos: [Manga2gether.Repo],
  generators: [binary_id: true],
  migration_primary_key: [id: :uuid, type: :binary_id]

# Configures the endpoint
config :manga2gether, Manga2getherWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FO0N29D6jqdSSbpl506piXGhk6RoCLZckb0MYe2RkfCZgNB7TLH3UAnKIvZ9Ppv2",
  render_errors: [view: Manga2getherWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Manga2gether.PubSub,
  live_view: [signing_salt: "qYLA3kWf"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    discord: {Ueberauth.Strategy.Discord, [default_scope: "identify email"]}
  ]

config :ueberauth, Ueberauth.Strategy.Discord.OAuth,
  client_id: "",
  client_secret: ""

config :tesla, adapter: Tesla.Adapter.Hackney

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
