defmodule Core.Repo.Migrations.CreateTableRandomTokens do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:random_tokens) do
      add :token, :integer
      add :purpose, :string
      add :login, :string
      add :expired, :boolean, default: false
      add :app, :string, default: "mobile", null: false
      add :history, {:array, :string}
      add :min_count, :integer
      add :hour_count, :integer
      add :day_count, :integer
      add :expired_at, :utc_datetime
      add :device_id, references(:user_installs, on_delete: :delete_all)
      add :expired_by_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:random_tokens, [:device_id])
    create index(:random_tokens, [:expired_by_id])
  end
end
