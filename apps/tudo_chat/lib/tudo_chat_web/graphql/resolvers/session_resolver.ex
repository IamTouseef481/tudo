defmodule TudoChatWeb.GraphQL.Resolvers.SessionResolver do
  @moduledoc false
  alias TudoChat.Accounts
  #  def login _, _, _ do
  #    {:ok, Accounts.list_users}
  #  end

  def login_user(_, %{input: input}, _) do
    with {:ok, user} <- Accounts.authenticate(input),
         {:ok, jwt_token, _} <- TudoChatWeb.Guardian.encode_and_sign(user) do
      {:ok, %{token: jwt_token, user: user}}
    end
  end
end
