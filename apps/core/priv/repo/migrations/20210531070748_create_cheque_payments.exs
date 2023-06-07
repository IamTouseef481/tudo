defmodule Core.Repo.Migrations.CreateChequePayments do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:cheque_payments) do
      add :pay_due_amount, :float
      add :tudo_due_amount, :float
      add :bank_name, :string
      add :cheque_image, {:array, :map}
      add :cheque_number, :integer
      add :cheque_amount, :float
      add :signatory_name, :string
      add :in_favor_of_name, :string
      add :date, :date
      add :adjust, :boolean, default: false, null: false
      add :adjust_reason, :string
      add :invoice_id, references(:invoices, on_delete: :nothing)

      timestamps()
    end

    create index(:cheque_payments, [:invoice_id])
  end
end
