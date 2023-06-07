defmodule Core.Repo.Migrations.CreateTableOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :location_dest, :geometry
      add :location_src, :geometry
      add :rating, :float
      add :arrive_at, :utc_datetime
      add :picked_at, :utc_datetime
      add :src_to_dest_distance, :float
      add :cmr_to_bsp_comment, :map
      add :bsp_to_cmr_comment, :map
      add :est_work_duration, :utc_datetime
      add :instruction_to_rider, :string
      add :chat_group_id, :integer
      add :description, :string
      add :authorization_id, :string

      add :user_id, references(:users, on_delete: :nothing)
      add :status_id, references(:job_statuses, on_delete: :nothing, type: :string)
      add :payment_method_id, references(:payment_methods, on_delete: :nothing, type: :string)

      timestamps()
    end
  end
end
