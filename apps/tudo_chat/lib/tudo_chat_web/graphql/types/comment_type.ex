defmodule TudoChatWeb.GraphQL.Types.CommentType do
  @moduledoc false
  use TudoChatWeb.GraphQL, :type
  import Ecto.Query
  alias TudoChat.{Accounts.User, Blogs.Post}

  object :comment_type do
    field(:id, non_null(:id))
    field(:title, non_null(:string))

    field :user, :user_type do
      resolve(fn post, _, _ ->
        batch({__MODULE__, :users_by_id}, post.user_id, fn batch_results ->
          {:ok, Map.get(batch_results, post.user_id)}
        end)
      end)
    end

    field :post, :post_type do
      resolve(fn post, _, _ ->
        batch({__MODULE__, :posts_by_id}, post.post_id, fn batch_results ->
          {:ok, Map.get(batch_results, post.post_id)}
        end)
      end)
    end
  end

  def users_by_id(_a, ids) do
    User
    |> where([m], m.id in ^ids)
    |> TudoChat.Repo.all(prefix: Triplex.to_prefix("tudo_"))
    |> Map.new(&{&1.id, &1})
  end

  def posts_by_id(_a, ids) do
    Post
    |> where([m], m.id in ^ids)
    |> TudoChat.Repo.all(prefix: Triplex.to_prefix("tudo_"))
    |> Map.new(&{&1.id, &1})
  end

  input_object :comment_input_type do
    field :title, non_null(:string)
  end
end
