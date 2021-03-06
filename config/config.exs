# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :wall,
  ecto_repos: [Wall.Repo]

# Configures the endpoint
config :wall, Wall.Endpoint,
  root: Path.dirname(__DIR__),
  url: [host: "localhost"],
  secret_key_base: "Pnt5X6VzmeChmO1aPYNSum+JnnEZKFsuqImOuHZt6UaEyYItY932cff0eMlHDj+w",
  render_errors: [view: Wall.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Wall.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
