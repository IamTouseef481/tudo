defmodule Core.Repo.Migrations.CreateTableGoogleCalenders do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:google_calenders) do
      add :cmr_event_id, :string
      add :bsp_event_id, :string
      add :job_id, references(:jobs)

      timestamps()
    end
  end
end
