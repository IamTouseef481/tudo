defmodule TudoChatWeb.Controllers.PageController do
  @moduledoc false
  use TudoChatWeb, :controller

  def index1(conn, _params) do
    data = [
      %{name: "Joe", email: "joe@example.com", password: "topsecret", stooge: "moe"},
      %{name: "Anne", email: "anne@example.com", password: "guessme", stooge: "larry"},
      %{name: "Franklin", email: "franklin@example.com", password: "guessme", stooge: "curly"}
    ]

    conn
    |> success(data)
  end
end
