defmodule TudoChatWeb.GraphQL.Resolvers.SearchPersonResolver do
  @moduledoc false
  use TudoChatWeb.GraphQL, :resolver
  alias TudoChatWeb.Controllers.SearchPersonController

  @default_error ["unexpected error occurred"]

  def search_persons(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    case SearchPersonController.search_persons(input) do
      {:ok, persons} -> {:ok, persons}
      {:error, error} -> {:error, error}
    end
  rescue
    exception ->
      logger(__MODULE__, exception, @default_error, __ENV__.line)
  end
end
