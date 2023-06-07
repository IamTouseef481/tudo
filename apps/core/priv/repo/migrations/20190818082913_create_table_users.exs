defmodule Core.Repo.Migrations.CreateTableUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :mobile, :string
      add :is_verified, :boolean, default: false, null: false
      add :password_hash, :string
      add :profile, :map
      add :availability, :map
      add :reset_password_token, :string
      add :birth_at, :string
      add :address, :string
      add :gender, :string
      add :reset_password_sent_at, :utc_datetime
      add :failed_attempts, :integer
      add :sign_in_count, :integer, default: 0
      add :current_sign_in_at, :utc_datetime
      add :locked_at, :utc_datetime
      add :unlock_token, :string
      add :confirmation_token, :string
      add :confirmed_at, :utc_datetime
      add :confirmation_sent_at, :utc_datetime
      add :platform_terms_and_condition_id, :integer
      add :is_bsp, :boolean, default: false, null: false
      add :scopes, :string
      add :rating, :float, default: 0.0
      add :rating_count, :integer, default: 0
      add :profile_public, :boolean, default: true, null: false
      add :acl_role_id, {:array, :string}
      add :language_id, references(:languages, on_delete: :nothing)
      add :country_id, references(:countries, on_delete: :nothing)

      add :status_id, references(:user_statuses, type: :varchar),
        default: "confirmed",
        null: false

      timestamps()
    end

    create unique_index(:users, [:email], name: "unique_email")
  end
end
