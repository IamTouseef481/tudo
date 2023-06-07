defmodule Core.Schemas.PaypalAccessAttributes do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "paypal_access_attributes" do
    field :access_token, :string
    field :partner_attribution_id, :string

    timestamps()
  end

  @doc false
  def changeset(paypal_access_attributes, attrs) do
    paypal_access_attributes
    |> cast(attrs, [:access_token, :partner_attribution_id])
    |> validate_required([])
  end
end
