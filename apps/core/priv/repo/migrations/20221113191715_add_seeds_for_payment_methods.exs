defmodule Core.Repo.Migrations.AddSeedsForPaymentMethods do
  use Ecto.Migration

  alias Core.Context
  alias Core.Schemas.PaymentMethod

  def change do
    objs = [%{id: "cashfree", description: "Cashfree"}]

    Enum.each(
      objs,
      fn obj ->
        Context.insert_or_update(PaymentMethod, obj, id: obj.id, description: obj.description)
      end
    )

    flush()
  end
end
