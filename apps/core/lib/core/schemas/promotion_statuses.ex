defmodule Core.Schemas.PromotionStatuses do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  schema "promotion_statuses" do
    field :id, :string, primary_key: true
    field :title, :string
    field :description, :string
  end

  @doc false
  def changeset(promotion_statuses, attrs) do
    promotion_statuses
    |> cast(attrs, [:id, :title, :description])
    |> validate_required([:id, :title])
  end
end
