defmodule Core.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Core.Repo,
      # Start the endpoint when the application starts
      {Phoenix.PubSub, [name: Core.PubSub, adapter: Phoenix.PubSub.PG2]},
      CoreWeb.Endpoint,
      {Absinthe.Subscription, [CoreWeb.Endpoint]},
      {Guardian.DB.Token.SweeperServer, []},
      {OpenIDConnect.Worker, Application.get_env(:core, :openid_connect_providers)}
      # Starts a worker by calling: Core.Worker.start_link(arg)
      # {Core.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CoreWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
