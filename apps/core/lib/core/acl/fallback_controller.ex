# credo:disable-for-this-file
# defmodule Core.Acl.FallbackController do
#  @moduledoc false
# """
#  Translates controller action results into valid `Plug.Conn` responses.
#
#  See `Phoenix.Controller.action_fallback/1` for more details.
#  """
#  use AclWeb, :controller
#
#  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
#    conn
#    |> put_status(:unprocessable_entity)
#    |> render(AclWeb.ChangesetView, "error.json", changeset: changeset)
#  end
#
#  def call(conn, {:error, :not_found}) do
#    conn
#    |> put_status(:not_found)
#    |> render(AclWeb.ErrorView, :"404")
#  end
# end
