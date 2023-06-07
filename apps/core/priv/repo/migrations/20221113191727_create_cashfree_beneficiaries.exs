defmodule Core.Repo.Migrations.CreateCashfreeBeneficiaries do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:cashfree_beneficiaries) do
      add :beneficiary_id, :string
      add :email, :string
      add :transfer_mode, {:array, :string}
      add :default, :boolean, null: false, default: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:cashfree_beneficiaries, [:user_id])
  end
end
