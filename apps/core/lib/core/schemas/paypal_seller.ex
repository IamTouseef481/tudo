defmodule Core.Schemas.PaypalSeller do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "paypal_sellers" do
    field :partner_referral_id, :string
    field :email, :string
    field :default, :boolean, default: false
    belongs_to :user, Core.Schemas.User

    timestamps()
  end

  @doc false
  def changeset(paypal_seller, attrs) do
    paypal_seller
    |> cast(attrs, [:email, :default, :partner_referral_id, :user_id])
    |> validate_required([:user_id, :email])
    |> update_change(:email, &String.downcase(&1))
  end
end
