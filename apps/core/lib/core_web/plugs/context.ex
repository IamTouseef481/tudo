defmodule CoreWeb.Plugs.Context do
  @moduledoc false
  @behaviour Plug

  import Plug.Conn

  def init(default), do: default

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, claims} <- CoreWeb.Guardian.decode_and_verify(token),
         {:ok, user} <- CoreWeb.Guardian.resource_from_claims(claims) do
      %{current_user: user}
    else
      _ -> %{}
    end
  end
end
