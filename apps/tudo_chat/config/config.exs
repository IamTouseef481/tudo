# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :tudo_chat,
  ecto_repos: [TudoChat.Repo]

# Configures the endpoint
config :tudo_chat, TudoChatWeb.Endpoint,
  pubsub_server: TudoChat.PubSub,
  url: [host: "localhost"],
  render_errors: [view: TudoChatWeb.Views.ErrorView, accepts: ~w(html json)]

config :tudo_chat, :repo,
  seed_base_path: "apps/tudo_chat/priv/repo/seeds/",
  default_limit: 10,
  max_limit: 100

config :tudo_chat, :package,
  dev: "tudo.dev",
  prod: "tudo.prod"

# config :pigeon, :apns,
#       apns_tudo_prod: %{
#            cert: {:tudo_chat, "static/certs/prod_cert.pem"},
#            key: {:tudo_chat, "static/certs/prod_key_unencrypted.pem"},
#            mode: :prod
#       },
#       apns_tudo_dev: %{
#            cert: {:tudo_chat, "static/certs/dev_cert.pem"},
#            key: {:tudo_chat, "static/certs/dev_key_unencrypted.pem"},
#            mode: :dev
#       },
#       apns_default: %{
#            cert: {:tudo_chat, "static/certs/dev_cert.pem"},
#            key: {:tudo_chat, "static/certs/dev_key_unencrypted.pem"},
#            mode: :dev
#       }

config :pigeon, :fcm,
  dev: %{
    key: System.get_env("DEV_PIGEON_FCM_KEY")
  },
  prod: %{
    key: System.get_env("PROD_PIGEON_FCM_KEY")
  },
  fcm_default: %{
    key: System.get_env("DEFAULT_PIGEON_FCM_KEY")
  }

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../../../deps", __DIR__)}
  ]

# Exq related configurations
config :exq,
  name: Exq,
  host: "127.0.0.1",
  port: 6379,
  namespace: "exq",
  concurrency: :infinite,
  queues: ["default"],
  poll_timeout: 50,
  scheduler_poll_timeout: 200,
  scheduler_enable: true,
  max_retries: 3,
  #       start_on_application: false,
  shutdown_timeout: 5000,
  auto_cancel_job_after_sec: 6000

# config :sentry,
#   dsn: System.get_env("SENTRY_DSN"),
#   environment_name: Mix.env(),
#   enable_source_code_context: true,
#   root_source_code_path: File.cwd!(),
#   tags: %{
#     env: Mix.env()
#   },
#   included_environments: [:prod, :dev]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ex_aws, :sqs,
  access_key_id: System.get_env("EX_AWS_SQS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("EX_AWS_SQS_SECRET_ACCESS_KEY"),
  region: "ap-south-1"

config :tudo_chat, :broker,
  url: "adpq://guest:guest@localhost:6782",
  access_key_id: System.get_env("EX_AWS_SQS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("EX_AWS_SQS_SECRET_ACCESS_KEY"),
  queue_name: "queue",
  region: "ap-south-1"

config :ex_aws, :hackney_opts,
  follow_redirect: true,
  recv_timeout: 30_000

config :arc,
  bucket: "tudodev",
  virtual_host: true

config :ex_aws,
  access_key_id: System.get_env("EX_AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("EX_AWS_SECRET_ACCESS_KEY"),
  region: "us-east-1",
  host: "s3.us-east-1.amazonaws.com",
  s3: [
    region: "us-east-1"
  ]

config :tudo_chat, :ex_aws,
  url: "https://s3.amazonaws.com/",
  bucket: "tudodev",
  message_bucket: "tudodev",
  expires_in: 86_400 * 3,
  messages_expires_in: 86_400 * 7,
  acl: :public_read

config :triplex,
  repo: TudoChat.Repo,
  prefix: "tudo_"

config :tudo_chat, TudoChatWeb.Guardian,
  issuer: "tudo_chat",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

config :tudo_chat, :scrivener,
  page_size: 200,
  page_number: 1,
  module: TudoChat.Repo

config :tudo_chat, TudoChatWeb.Mailer, adapter: Bamboo.MailgunAdapter

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
