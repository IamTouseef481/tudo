defmodule TudoChatWeb.Router do
  @moduledoc false
  use TudoChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    #    plug TudoChatWeb.Plugs.Translation, "en"
    plug TudoChatWeb.Plugs.Context
    plug TudoChatWeb.Plugs.Params
  end

  scope "/" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug, schema: TudoChatWeb.GraphQL.Schema

    if Mix.env() == :dev do
      forward "/graphiql",
              Absinthe.Plug.GraphiQL,
              schema: TudoChatWeb.GraphQL.Schema,
              socket: TudoChatWeb.GraphQL.UserSocket
    end

    post "/files", TudoChatWeb.Controllers.RestFileController, :upload
    post "/message_files", TudoChatWeb.Controllers.RestFileController, :upload_messages

    post "/message_files/remove",
         TudoChatWeb.Controllers.RestFileController,
         :remove_message_files
  end

  # Other scopes may use custom stacks.
  # scope "/api", TudoChatWeb do
  #   pipe_through :api
  # end
end
