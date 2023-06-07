defmodule Core.Repo.Migrations.CreateTableUserInstalls do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:user_installs) do
      add :fcm_token, :text
      add :device_token, :text
      add :os, :string
      add :device_info, :map
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:user_installs, [:user_id])
    create unique_index(:user_installs, [:device_token])
  end
end
