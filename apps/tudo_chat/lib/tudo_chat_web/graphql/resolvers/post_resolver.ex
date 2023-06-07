defmodule TudoChatWeb.GraphQL.Resolvers.PostResolver do
  @moduledoc false
  alias TudoChat.Blogs

  def posts(_, _, %{context: %{current_user: _current_user}}) do
    {:ok, Blogs.list_posts()}
  end

  def create_post(_, %{input: input}, %{context: %{current_user: _current_user}}) do
    post = Map.merge(input, %{})

    Blogs.create_post(post)
  end
end
