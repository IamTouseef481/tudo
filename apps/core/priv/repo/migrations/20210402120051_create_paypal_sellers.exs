defmodule Core.Repo.Migrations.CreatePaypalSellers do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:paypal_sellers) do
      add :partner_referral_id, :string
      add :email, :string
      add :default, :boolean, null: false, default: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:paypal_sellers, [:user_id])
  end
end
