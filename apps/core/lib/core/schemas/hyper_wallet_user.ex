defmodule Core.Schemas.HyperWalletUser do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "hyper_wallet_users" do
    field :user_token, :string
    belongs_to :user, Core.Schemas.User

    timestamps()
  end

  @doc false
  def changeset(hyper_wallet_user, attrs) do
    hyper_wallet_user
    |> cast(attrs, [:user_token, :user_id])
    |> validate_required([:user_token, :user_id])
  end
end
