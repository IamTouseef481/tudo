defmodule CoreWeb.Controllers.PageController do
  @moduledoc false

  use CoreWeb, :controller

  def index(conn, _params) do
    redirect_to = if Mix.env() == :dev, do: "/graphiql", else: "/graphql"

    conn
    |> redirect(to: redirect_to)
  end
end
