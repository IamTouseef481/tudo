defmodule Core.Schemas.PaymentStatus do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "payment_statuses" do
    field :id, :string, primary_key: true
    field :description, :string
  end

  @doc false
  def changeset(dispute_status, attrs) do
    dispute_status
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
