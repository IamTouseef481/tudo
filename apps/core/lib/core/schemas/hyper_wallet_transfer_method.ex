defmodule Core.Schemas.HyperWalletTransferMethod do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "hyper_wallet_transfer_methods" do
    field :is_default, :boolean, default: false
    field :token, :string
    field :type, :string
    belongs_to :hw_user, Core.Schemas.HyperWalletUser

    timestamps()
  end

  @doc false
  def changeset(hyper_wallet_transfer_method, attrs) do
    hyper_wallet_transfer_method
    |> cast(attrs, [:token, :is_default, :type, :hw_user_id])
    |> validate_required([:token, :hw_user_id])
  end
end
