defmodule Core.Repo.Migrations.AlterTableUsersAddReferralCode do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :referral_code, :string
    end

    create unique_index(:users, [:referral_code])
  end
end
