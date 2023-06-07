defmodule Core.Schemas.CashfreeBeneficiary do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "cashfree_beneficiaries" do
    field :beneficiary_id, :string
    field :email, :string
    field :bank_account, :string
    field :vpa, :string
    field :ifsc, :string
    field :phone, :string
    field :transfer_mode, {:array, :string}
    field :default, :boolean, default: false
    belongs_to :user, Core.Schemas.User

    timestamps()
  end

  @doc false
  def changeset(paypal_seller, attrs) do
    paypal_seller
    |> cast(attrs, [
      :email,
      :default,
      :beneficiary_id,
      :user_id,
      :transfer_mode,
      :bank_account,
      :ifsc,
      :phone,
      :vpa
    ])
    |> validate_required([:user_id, :email])
    |> update_change(:email, &String.downcase(&1))
  end
end
