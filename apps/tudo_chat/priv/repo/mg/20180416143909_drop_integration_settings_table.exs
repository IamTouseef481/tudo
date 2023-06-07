defmodule Stitch.Repo.Migrations.DropIntegrationSettingsTable do
  @moduledoc false
  use Ecto.Migration

  def change do
    drop(table("integration_configs"))
  end
end
