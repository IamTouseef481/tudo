defmodule Core.Schemas.Deal do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  alias Core.Schemas.{Promotion, Service, User}

  schema "deals" do
    belongs_to :user, User
    belongs_to :promotion, Promotion
    belongs_to :service, Service

    timestamps()
  end

  @doc false
  def changeset(deal, attrs) do
    deal
    |> cast(attrs, [:user_id, :promotion_id, :service_id])
    |> validate_required([:user_id, :promotion_id, :service_id])
  end
end
