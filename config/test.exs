use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :wall, Wall.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :wall, :authstrategy, Wall.AuthStrategy.Password

# Configure your database
config :wall, Wall.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "wall_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
