defmodule Core.Repo.Migrations.AlterTableJobsAddOnBehalfCmr do
  use Ecto.Migration

  def change do
    alter table(:jobs) do
      add :on_behalf_cmr, :boolean
    end
  end
end
