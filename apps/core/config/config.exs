# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :core,
  ecto_repos: [Core.Repo]

# Configures the endpoint
config :core, CoreWeb.Endpoint,
  pubsub_server: Core.PubSub,
  url: [host: "localhost"],
  render_errors: [view: CoreWeb.Views.ErrorView, accepts: ~w(html json)]

config :core, :package,
  dev: "app.tudo.dev",
  prod: "app.tudo.prod"

# config :pigeon, :apns,
#       apns_tudo_prod: %{
#         cert: {:core, "static/certs/prod_cert.pem"},
#         key: {:core, "static/certs/prod_key_unencrypted.pem"},
#         mode: :prod
#       },
#       apns_tudo_dev: %{
#         cert: {:core, "static/certs/dev_cert.pem"},
#         key: {:core, "static/certs/dev_key_unencrypted.pem"},
#         mode: :dev
#       },
#       apns_default: %{
#         cert: {:core, "static/certs/dev_cert.pem"},
#         key: {:core, "static/certs/dev_key_unencrypted.pem"},
#         mode: :dev
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

# config :sentry,
#   dsn: System.get_env("SENTRY_DSN"),
#   environment_name: Mix.env(),
#   enable_source_code_context: true,
#   root_source_code_path: File.cwd!(),
#   tags: %{
#     env: Mix.env()
#   },
#   included_environments: [:prod, :dev]

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

config :core, :repo,
  seed_base_path: "apps/core/priv/repo/seeds/",
  seed_raw_business: "apps/core/priv/repo/seeds/raw-business-seeds/",
  default_limit: 10,
  max_limit: 100

# config :sentry,
#  environment_name: Mix.env(),
#  enable_source_code_context: true,
#  root_source_code_path: File.cwd!(),
#  tags: %{
#    env: Mix.env()
#  },
#  included_environments: [:prod]

# Configures Elixir's Logger
# config :logger, backends: [:console, Sentry.LoggerBackend]
config :logger, backends: [:console]

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

config :core, :ex_aws,
  url: "https://s3.amazonaws.com/",
  bucket: "tudodev",
  icon_bucket: "tudoicons",
  expires_in: 86_400 * 3,
  icon_expires_in: 86_400 * 7,
  acl: :public_read,
  icon_acl: :public_read

config :ex_aws, :sqs,
  access_key_id: System.get_env("EX_AWS_SQS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("EX_AWS_SQS_SECRET_ACCESS_KEY"),
  region: "ap-south-1"

config :core, :broker,
  url: "adpq://guest:guest@localhost:6782",
  access_key_id: System.get_env("EX_AWS_SQS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("EX_AWS_SQS_SECRET_ACCESS_KEY"),
  queue_name: "queue",
  region: "ap-south-1"

config :ex_aws, :hackney_opts,
  follow_redirect: true,
  recv_timeout: 30_000

config :ex_aws_sqs, parser: ExAws.SQS.SweetXmlParser

config :geo_postgis, json_library: Jason

config :triplex,
  repo: Core.Repo,
  prefix: "tudo_"

config :core, CoreWeb.Guardian,
  issuer: "core",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

config :guardian, Guardian.DB,
  repo: Core.Repo,
  schema_name: "guardian_tokens",
  # 1 week 60*24*7
  sweep_interval: 10_080

#       sweep_interval: 1

# braintree sandbox configuration
config :braintree,
  environment: System.get_env("BRAINTREE_ENVIRONMENT"),
  master_merchant_id: System.get_env("BRAINTREE_MASTER_MERCHANT_ID"),
  merchant_id: System.get_env("BRAINTREE_MERCHANT_ID"),
  public_key: System.get_env("BRAINTREE_PUBLIC_KEY"),
  private_key: System.get_env("BRAINTREE_PRIVATE_KEY")

config :core, :scrivener,
  page_size: 30,
  page_number: 1,
  module: Core.Repo

config :core, :gettext,
  default_locale: "en",
  locales: ["en", "ur", "hi", "te", "es", "ar"],
  url_key: "lang"

config :core, CoreWeb.Mailer, adapter: Bamboo.MailgunAdapter

config :core, :sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY"),
  username: System.get_env("STAGING_EMAIL_SENDER")

config :core, :openid_connect_providers,
  google: [
    discovery_document_uri: "https://accounts.google.com/.well-known/openid-configuration"
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
