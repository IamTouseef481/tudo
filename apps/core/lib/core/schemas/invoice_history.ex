defmodule Core.Schemas.InvoiceHistory do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "invoice_history" do
    field :amount, :map
    field :discount_ids, {:array, :integer}
    field :tax_ids, {:array, :integer}
    field :change, :boolean, default: false
    field :comment, :string
    belongs_to :invoice, Core.Schemas.Invoice

    timestamps()
  end

  @doc false
  def changeset(invoice_history, attrs) do
    invoice_history
    |> cast(attrs, [:invoice_id, :change, :comment, :discount_ids, :tax_ids, :amount])
    |> validate_required([:invoice_id])
  end
end
