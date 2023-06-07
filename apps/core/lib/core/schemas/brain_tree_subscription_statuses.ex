defmodule Core.Schemas.BrainTreeSubscriptionStatuses do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "brain_tree_subscription_statuses" do
    field :id, :string, primary_key: true
    field :description, :string
  end

  @doc false
  def changeset(brain_tree_subscription_statuses, attrs) do
    brain_tree_subscription_statuses
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
