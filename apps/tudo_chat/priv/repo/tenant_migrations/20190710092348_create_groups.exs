defmodule TudoChat.Repo.Migrations.CreateGroups do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      add :reference_id, :integer
      add :is_active, :boolean, default: false, null: false
      add :service_request_id, :integer
      add :editable, :boolean, default: false, null: false
      add :forward, :boolean, default: false, null: false
      add :add_members, :boolean, default: false, null: false
      add :allow_pvt_message, :boolean, default: false, null: false
      add :profile_pic, :string
      add :expires_by_date, :utc_datetime
      add :created_by_id, references(:users, on_delete: :nothing)
      add :group_type_id, references(:group_types, on_delete: :nothing)

      timestamps()
    end

    create index(:groups, [:created_by_id])
    create index(:groups, [:group_type_id])
  end
end
