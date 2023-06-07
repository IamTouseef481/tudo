defmodule Core.CashfreePayments do
  @moduledoc """
  The PaypalPayments context.
  """

  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Schemas.{
    CashfreeBeneficiary
  }

  def create_cashfree_beneficiary(attrs \\ %{}) do
    %CashfreeBeneficiary{}
    |> CashfreeBeneficiary.changeset(attrs)
    |> Repo.insert()
  end

  def get_cashfree_beneficiary!(id), do: Repo.get_by(CashfreeBeneficiary, %{beneficiary_id: id})
  def get_cashfree_beneficiary(id), do: Repo.get_by(CashfreeBeneficiary, %{beneficiary_id: id})

  def get_beneficiary_by(user_id) do
    CashfreeBeneficiary
    |> where([cb], cb.user_id == ^user_id)
    |> Repo.all()
  end

  def get_default_cashfree_beneficiary_account_by_user(user_id) do
    from(s in CashfreeBeneficiary,
      where: s.user_id == ^user_id and s.default,
      limit: 1,
      order_by: [desc: s.id]
    )
    |> Repo.one()
  end

  def delete_cashfree_beneficiary(%CashfreeBeneficiary{} = cashfree_beneficiary) do
    Repo.delete(cashfree_beneficiary)
  end
end
