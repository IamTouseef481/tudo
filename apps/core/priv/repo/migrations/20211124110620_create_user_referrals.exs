defmodule Core.Repo.Migrations.CreateUserReferrals do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:user_referrals) do
      add :payment_method_setup, :boolean, default: false, null: false
      add :is_accept, :boolean, default: false, null: false
      add :email, :string, null: false
      add :user_from_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:user_referrals, [:user_from_id, :email])
  end
end
