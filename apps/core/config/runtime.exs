# credo:disable-for-this-file
import Config

Code.require_file("environment.exs", Path.join(:code.lib_dir(:core), "priv/config"))

config :core, Core.Repo,
  adapter: Ecto.Adapters.Postgres,
  types: Core.PostgresTypes,
  username: Environment.get("CORE_DB_USER") || "postgres",
  password: Environment.get("CORE_DB_PASSWORD") || "postgres",
  database: Environment.get("CORE_DB_NAME") || "core_dev",
  hostname: Environment.get("CORE_DB_HOST") || "localhost",
  superuser: Environment.get("CORE_SUPER_USER") || "postgres",
  superpass: Environment.get("CORE_SUPER_USER_PASSWORD") || "postgres",
  pool_size: Environment.get_integer("CORE_POOL_SIZE") || 10,
  log: if(Environment.get_boolean("ECTO_DEBUG"), do: :debug, else: false)

config :core, CoreWeb.Endpoint,
  debug_errors: Environment.get_boolean("DEBUG_ERRORS"),
  http: [port: Environment.get("CORE_PORT")],
  secret_key_base: Environment.get("SECRET_KEY_BASE")

config :core, CoreWeb.Mailer,
  api_key: Environment.get_boolean("CORE_MAILER_API_KEY"),
  domain: Environment.get_boolean("CORE_MAILER_DOMAIN"),
  username: Environment.get_boolean("MAILER_USERNAME")
