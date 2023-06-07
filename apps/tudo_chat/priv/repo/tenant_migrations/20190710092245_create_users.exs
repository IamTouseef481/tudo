defmodule TudoChat.Repo.Migrations.CreateUsers do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :mobile, :string
      add :is_verified, :boolean, default: false, null: false
      add :password_hash, :string
      add :profile, :map
      add :reset_password_token, :string
      add :reset_password_sent_at, :utc_datetime
      add :failed_attempts, :integer
      add :sign_in_count, :integer
      add :current_sign_in_at, :utc_datetime
      add :locked_at, :utc_datetime
      add :unlock_token, :string
      add :confirmation_token, :string
      add :confirmed_at, :utc_datetime
      add :confirmation_sent_at, :utc_datetime
      add :platform_terms_and_condition_id, :integer
      add :business_id, :integer
      add :scopes, :string

      timestamps()
    end

  end
end
