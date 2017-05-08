# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :tino,
  ecto_repos: [Tino.Repo]

config :tino, Tino.Repo, migration_source: "tino_migrations" #Esto es una mierda figurante para que no pida la tabla schema_migrations
  # Tell Alfred about us.
config :alfred, :app, :tino

# Cipher keys.
config :cipher, keyphrase: "unomasuno",
                ivphrase: "memomimamamemima",
                magic_token: "monikakogonzalezz"

# Configures the endpoint
config :tino, Tino.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "k/4wN/IC1uBdi9Y/sZtgNz5k922UoWHox5jBydii+7q3r9UbcdchuIzx58PP5ERB",
  render_errors: [view: Tino.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Tino.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :bottler, :params, [servers: [gce_project: "lolamaster-1314", match: "^tino-*"],
                          remote_user: "epdp",
                          cookie: "monikako",
                          forced_branch: "master",
                          ship: [timeout: 300_000,
                                 method: :scp]]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
