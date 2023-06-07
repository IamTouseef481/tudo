defmodule TudoChatWeb.GraphQL.Resolvers.UserResolver do
  @moduledoc false
  import TudoChatWeb.Utils.Errors
  alias TudoChat.Accounts

  def users(_, _, _) do
    {:ok, Accounts.list_users()}
  end

  @spec create_user(any, %{:input => any, optional(any) => any}, any) :: tuple
  def create_user(_, %{input: input}, _) do
    case Accounts.create_user(input) do
      {:ok, user} ->
        #        Absinthe.Subscription.publish(TudoChatWeb.Endpoint, user, create_user: true)
        {:ok, user}

      {:error, _changeset} ->
        {:ok, "error"}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, ["unexpected error occurred"], __ENV__.line)
  end
end
