defmodule Core.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :core,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [warnings_as_errors: true],
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Core.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :timex,
        :ex_aws,
        :arc_ecto,
        :bamboo,
        :exq,
        :httpoison,
        :scrivener_ecto
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Phoenix
      {:phoenix, "~> 1.6"},
      {:phoenix_pubsub, "~> 2.1"},
      {:phoenix_ecto, "~> 4.4.0"},
      {:phoenix_html, "~> 3.2"},
      {:phoenix_live_reload, "~> 1.3.3", only: :dev},
      {:phoenix_swagger, github: "CleverBytes/phoenix_swagger"},

      # Database
      {:ecto_sql, "~> 3.8"},
      {:scrivener_ecto, git: "https://github.com/Tanbits/scrivener_ecto"},
      {:geo_postgis, "~> 3.4.2"},
      {:inflex, "~> 2.1.0"},

      # Translations
      {:gettext, "~> 0.20"},

      # JSON encoder / decoder
      {:jason, "~> 1.1"},

      # HTTP server
      {:plug_cowboy, "~> 2.5.2"},
      {:plug, "~> 1.13.6"},
      {:cors_plug, "~> 3.0.3"},

      # Errors
      # {:sentry, "~> 8.0.6"},

      # Time
      {:timex, "~> 3.7.8"},
      {:faker, "~> 0.17.0", only: :test},

      # Notifications
      {:pigeon, "~> 1.6.1"},
      {:kadabra, "~> 0.6.0"},

      # Scheduler
      {:exq, "~> 0.16.1"},

      # Convertion
      {:atomic_map, "~> 0.9.3"},
      {:sweet_xml, "~> 0.7.2"},
      {:triplex, "~> 1.3.0"},
      {:recase, "~> 0.6"},

      # Parse Http requests
      {:httpoison, "~> 1.7"},

      # SQS queue
      {:broadway_sqs, "~> 0.7.1"},

      # HTTP Client
      {:hackney, "~> 1.18.1"},
      {:braintree, "~> 0.13.0"},

      # File Uploading
      {:arc, "~> 0.11.0"},
      {:arc_ecto, "~> 0.11.1"},

      # AWS
      {:ex_aws, "~> 2.3"},
      {:ex_aws_s3, "~> 2.3.2"},

      # Mime Override
      {:mime, "~> 2.0", override: true},

      # data import
      {:csv, "~> 2.3"},

      # Password Hashing
      {:argon2_elixir, "~> 3.0.0"},

      # Authentication
      {:guardian, "~> 2.2.3"},
      {:guardian_db, "~> 2.1"},

      # GraphQL
      {:absinthe, "~> 1.7"},
      {:dataloader, "~> 1.0.10"},
      {:absinthe_phoenix, "~> 2.0"},
      {:absinthe_plug, "~> 1.5"},
      {:absinthe_ecto, github: "Tanbits/absinthe_ecto"},

      # Transaction
      {:sage, "~> 0.6.1"},

      # Creation and sending Email
      {:sendgrid, "~> 2.0"},
      {:bamboo, "~> 2.2.0"},
      {:bamboo_smtp, "~> 4.2"},

      # Utils
      {:distillery, "~> 2.1"},

      # Distance
      {:distance, "~> 1.1.0"},

      # Linting
      {:credo, "~> 1.6", only: [:dev, :test], override: true},
      {:credo_envvar, "~> 0.1", only: [:dev, :test], runtime: false},
      {:credo_naming, "~> 2.0", only: [:dev, :test], runtime: false},

      # Image Library
      {:fastimage, "~> 1.0.0-rc4"},

      # Assets Builder
      {:esbuild, "~> 0.4", runtime: Mix.env() == :dev},

      # social Oauth
      {:openid_connect, "~> 0.2.2"},
      {:qrcode_ex, "~> 0.1.0"},
      {:pdf, "~> 0.6.0"},
      {:pdf_generator, "~> 0.6.2"},
      {:sneeze, "~> 1.2"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "assets.deploy", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.migrate": ["ecto.migrate", "ecto.dump"],
      "db.rollback": ["ecto.rollback", "ecto.dump"],
      deploy: [
        "deps.get",
        "compile",
        "ecto.reset"
      ],
      migrate: "triplex.migrate",
      merge: ["gettext.merge priv/gettext/"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"],
      "assets.deploy": [
        "cmd --cd assets",
        "cmd yarn install",
        "esbuild default --minify",
        "phx.digest"
      ]
    ]
  end
end
