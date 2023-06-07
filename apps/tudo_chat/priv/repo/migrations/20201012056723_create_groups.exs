defmodule TudoChat.Repo.Migrations.CreateGroups do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      #      add :group_type, :string
      add :reference_id, :integer
      add :public, :boolean, default: false, null: false
      add :service_request_id, :integer
      add :bid_id, :integer
      add :created_by_id, :integer
      add :editable, :boolean, default: false, null: false
      add :forward, :boolean, default: false, null: false
      add :add_members, :boolean, default: false, null: false
      add :allow_pvt_message, :boolean, default: false, null: false
      add :profile_pic, :map
      add :proposal_id, :integer
      add :created_at, :utc_datetime
      add :branch_id, :integer
      add :group_type_id, references(:group_types, on_delete: :nothing, type: :varchar)
      add :group_status_id, references(:group_statuses, on_delete: :nothing, type: :varchar)

      timestamps()
    end

    #    create index(:groups, [:created_by_id])
    create index(:groups, [:group_type_id])
    create index(:groups, [:group_status_id])
  end
end
