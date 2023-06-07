defmodule Core.Schemas.BrainTreeDispute do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "brain_tree_disputes" do
    field :attachments, {:array, :map}
    field :description, :string
    field :dispute_email, :string
    field :dispute_phone, :string
    field :title, :string
    field :transaction_id, :string
    field :dispute_status_id, :id
    field :dispute_category_id, :id
    belongs_to :user, Core.Schemas.User
    belongs_to :branch, Core.Schemas.Branch

    timestamps()
  end

  @doc false
  def changeset(brain_tree_dispute, attrs) do
    brain_tree_dispute
    |> cast(attrs, [
      :user_id,
      :branch_id,
      :title,
      :description,
      :attachments,
      :dispute_email,
      :dispute_phone,
      :transaction_id
    ])
    |> validate_required([:user_id, :branch_id, :title, :description, :transaction_id])
  end
end
