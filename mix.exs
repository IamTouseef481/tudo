defmodule Tudo.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    []
  end

  defp aliases do
    [
      compile: ["deps.precompile", "compile"],
      deploy: ["deps.get", "compile", "assets.deploy", "ecto.reset"],
      "assets.deploy": [
        #      on ubuntu server not working, temporary commented #TODO fix this issue and uncomment it
        #        "cmd --app core --cd assets",
        #        "cmd yarn install",
        #        "cmd --app tudo_chat --cd assets",
        #        "cmd yarn install",
        "esbuild default --minify",
        "phx.digest"
      ],
      "ecto.setup": [
        "ecto.create",
        "ecto.migrate",
        "run apps/core/priv/repo/seeds.exs",
        "run apps/tudo_chat/priv/repo/seeds.exs"
      ],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: [
        "ecto.drop --quiet",
        "ecto.create --quiet",
        "ecto.load --quiet",
        "ecto.migrate --quiet",
        "test"
      ]
    ]
  end
end
