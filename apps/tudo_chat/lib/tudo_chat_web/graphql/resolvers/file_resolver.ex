defmodule TudoChatWeb.GraphQL.Resolvers.FileResolver do
  @moduledoc false
  alias TudoChatWeb.Controllers.FileController

  def get_message_files(_, %{input: messages}, _) do
    {:ok, FileController.get_message_files(messages)}
  end
end
