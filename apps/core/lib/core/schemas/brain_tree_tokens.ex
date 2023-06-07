defmodule Core.Schemas.BrainTreeTokens do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "brain_tree_tokens" do
    field :token, :string
    belongs_to :user, Core.Schemas.User
    field :branch_id, :id

    timestamps()
  end

  @doc false
  def changeset(brain_tree_tokens, attrs) do
    brain_tree_tokens
    |> cast(attrs, [:user_id, :branch_id, :token])
    |> validate_required([:user_id, :token])
  end
end
