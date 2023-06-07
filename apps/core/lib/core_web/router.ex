defmodule CoreWeb.Router do
  @moduledoc false
  use CoreWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    #    use Plug.ErrorHandler
    #    use Sentry.Plug
    plug CORSPlug, origin: "*"
    plug :accepts, ["json"]
    plug CoreWeb.Plugs.Translation, "en"
    plug CoreWeb.Plugs.Context
    #    plug CoreWeb.Plugs.Authorization
    plug CoreWeb.Plugs.Params
  end

  scope "/" do
    pipe_through :api

    forward("/graphql", Absinthe.Plug, schema: CoreWeb.GraphQL.Schema)

    if Mix.env() == :dev do
      forward "/graphiql",
              Absinthe.Plug.GraphiQL,
              schema: CoreWeb.GraphQL.Schema,
              socket: CoreWeb.GraphQL.UserSocket
    end

    post "/files", CoreWeb.Controllers.RestFileController, :upload
    post "/files/remove", CoreWeb.Controllers.RestFileController, :remove
    post "/icon_files", CoreWeb.Controllers.RestFileController, :upload_icons
  end

  scope "/", CoreWeb do
    pipe_through :browser

    get "/", Controllers.PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", CoreWeb do
  #   pipe_through :api
  # end
end
