defmodule Core.Schemas.UserReferral do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_referrals" do
    field :payment_method_setup, :boolean, default: false
    field :is_accept, :boolean, default: false
    field :email, :string
    belongs_to :user_from, Core.Schemas.User

    timestamps()
  end

  @doc false
  def changeset(user_referral, attrs) do
    user_referral
    |> cast(attrs, [:payment_method_setup, :is_accept, :email, :user_from_id])
    |> validate_required([:email])
    |> unique_constraint([:user_from_id, :email])
  end
end
