defmodule Core.Schemas.OrderHistory do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Schemas.{Order, JobStatus}

  schema "order_history" do
    field :inserted_by, :integer
    field :invoice_id, :integer
    field :payment_id, :integer
    field :reason, :string
    field :updated_by, :integer
    field :user_role, :string
    field :created_at, :utc_datetime
    belongs_to :order, Order
    belongs_to :order_status, JobStatus, type: :string

    timestamps()
  end

  @doc false
  def changeset(order_history, attrs) do
    order_history
    |> cast(attrs, [
      :reason,
      :inserted_by,
      :updated_by,
      :user_role,
      :invoice_id,
      :payment_id,
      :created_at,
      :order_id,
      :order_status_id
    ])
    |> validate_required([:order_id])
  end
end
