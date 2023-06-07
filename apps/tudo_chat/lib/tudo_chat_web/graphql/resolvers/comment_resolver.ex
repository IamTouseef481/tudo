defmodule TudoChatWeb.GraphQL.Resolvers.CommentResolver do
  @moduledoc false
  alias TudoChat.Blogs

  def comments(_, _, %{context: %{current_user: _current_user}}) do
    {:ok, Blogs.list_comments()}
  end

  def create_comment(_, %{input: input}, %{context: %{current_user: current_user}}) do
    comment = Map.merge(input, %{user_id: current_user.id, post_id: 1})

    Blogs.create_comment(comment)
  end
end
