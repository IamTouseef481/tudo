defmodule TudoChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      #      {Receiver, []},
      TudoChat.Repo,
      # Start the endpoint when the application starts
      {Phoenix.PubSub, [name: TudoChat.PubSub, adapter: Phoenix.PubSub.PG2]},
      TudoChatWeb.Channels.Presence,
      TudoChatWeb.Endpoint,
      {Absinthe.Subscription, [TudoChatWeb.Endpoint]}
      # Starts a worker by calling: TudoChat.Worker.start_link(arg)
      # {TudoChat.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TudoChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TudoChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
