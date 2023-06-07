defmodule Core.Schemas.PayRate do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "pay_rates" do
    field :id, :string, primary_key: true
    field :name, :string
    field :details, :map

    timestamps()
  end

  @doc false
  def changeset(pay_rate, attrs) do
    pay_rate
    |> cast(attrs, [:id, :name, :details])
    |> validate_required([:id, :name])
  end
end
