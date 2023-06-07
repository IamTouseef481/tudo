defmodule TudoChat.Blogs.Post do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  #  alias TudoChat.Accounts.User

  schema "posts" do
    field :title, :string
    #    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
