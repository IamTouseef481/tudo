# credo:disable-for-this-file
defmodule AclWeb.Router do
  @moduledoc false

  use AclWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AclWeb do
    pipe_through :api
    # get "/", Core.Acl.RuleController, :index
  end
end
