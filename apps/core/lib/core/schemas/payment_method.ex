defmodule Core.Schemas.PaymentMethod do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "payment_methods" do
    field :id, :string, primary_key: true
    field :description, :string
  end

  @doc false
  def changeset(payment_method, attrs) do
    payment_method
    |> cast(attrs, [:id, :description])
    |> validate_required([:id])
  end
end
