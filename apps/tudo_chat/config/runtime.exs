# credo:disable-for-this-file
import Config

Code.require_file("environment.exs", Path.join(:code.lib_dir(:tudo_chat), "priv/config"))

config :tudo_chat, TudoChat.Repo,
  adapter: Ecto.Adapters.Postgres,
  types: TudoChat.PostgresTypes,
  username: Environment.get("CHAT_DB_USER") || "postgres",
  password: Environment.get("CHAT_DB_PASSWORD") || "postgres",
  database: Environment.get("CHAT_DB_NAME") || "tudo_chat",
  hostname: Environment.get("CHAT_DB_HOST") || "localhost",
  superuser: Environment.get("SUPER_USER") || "postgres",
  superpass: Environment.get("SUPER_USER_PASSWORD") || "postgres",
  pool_size: Environment.get_integer("CHAT_POOL_SIZE") || 10,
  log: if(Environment.get_boolean("ECTO_DEBUG"), do: :debug, else: false)

config :tudo_chat, TudoChatWeb.Endpoint,
  debug_errors: Environment.get_boolean("DEBUG_ERRORS"),
  http: [port: Environment.get("CHAT_PORT")],
  secret_key_base: Environment.get("SECRET_KEY_BASE")

config :tudo_chat, TudoChatWeb.Mailer,
  api_key: Environment.get_boolean("CHAT_MAILER_API_KEY"),
  domain: Environment.get_boolean("CHAT_MAILER_DOMAIN"),
  username: Environment.get_boolean("MAILER_USERNAME")
