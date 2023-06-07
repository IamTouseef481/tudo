defmodule TudoChat.Blogs.Comment do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias TudoChat.Accounts.User
  alias TudoChat.Blogs.Post

  schema "comments" do
    field :title, :string
    belongs_to :user, User
    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:title, :user_id, :post_id])
    |> validate_required([:title, :user_id, :post_id])
  end
end
