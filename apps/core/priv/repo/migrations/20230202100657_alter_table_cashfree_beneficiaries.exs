defmodule Core.Repo.Migrations.AlterTableCashfreeBeneficiaries do
  use Ecto.Migration

  def change do
    alter table(:cashfree_beneficiaries) do
      add :phone, :string
      add :vpa, :string
      add :bank_account, :string
      add :ifsc, :string
    end
  end
end
